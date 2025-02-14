// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Sets} from "./lib/Sets.sol";

import {BlockHashHistorian} from "./BlockHashHistorian.sol";

/// @title ZKVRF - Verifiable Random Function using zkSNARKs
/// @notice This contract provides a verifiable random function (VRF) using a custom public-key
///         cryptography scheme with deterministic signatures, enabled by zkSNARKs.
/// @dev The contract uses a SNARK verifier to ensure the correctness of randomness proofs.
interface ArbSys {
    function arbBlockNumber() external view returns (uint256);
}

contract ZKVRF {
    using Sets for Sets.Set;

    // Constants
    bytes32 public constant PROVING_SYSTEM_ID = keccak256(abi.encodePacked("ultraplonk"));
    bytes32 public constant VK_HASH = 0x86414bbdab18c8f12bb38dafeb2fd340339ae765165eb108455ea7df6758f7eb;
    address public constant ZKV_CONTRACT = 0x147AD899D1773f5De5e064C33088b58c7acb7acf;

    // BN254 field prime
    uint256 public constant P = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    // State variables
    address public immutable blockHashHistorian; // Block hash storage contract
    Sets.Set private operators; // Set of registered operator public keys
    uint256 public nextRequestId; // Counter for request IDs
    mapping(uint256 => bytes32) public requests; // Request commitments
    mapping(uint256 => uint256) public randomness; // Fulfilled randomness values
    mapping(address => uint256) public requestNonces; // Nonces for randomness seeds

    // Events
    event RandomnessRequested(
        uint256 indexed requestId,
        bytes32 indexed operatorPublicKey,
        address indexed requester,
        uint16 minBlockConfirmations,
        uint32 callbackGasLimit,
        uint256 nonce
    );
    event RandomnessFulfilled(
        uint256 indexed requestId,
        bytes32 indexed operatorPublicKey,
        address indexed requester,
        uint256 nonce,
        uint256 randomness
    );
    event OperatorRegistered(bytes32 indexed operatorPublicKey);

    // Constructor
    constructor(address blockHashHistorian_) {
        blockHashHistorian = blockHashHistorian_;
        operators.init();
    }

    /// @notice Register an operator public key (permissionless)
    /// @dev Operators can register their public keys to participate in the VRF process.
    /// @param publicKey The public key of the operator.
    function registerOperator(bytes32 publicKey) external {
        operators.add(publicKey);
        emit OperatorRegistered(publicKey);
    }

    /// @notice Get the total number of registered operators
    /// @return The number of registered operators.
    function getOperatorsCount() external view returns (uint256) {
        return operators.size;
    }

    /// @notice Check if a public key is registered as an operator
    /// @param operatorPublicKey The public key to check.
    /// @return True if the public key is registered, false otherwise.
    function isOperator(bytes32 operatorPublicKey) public view returns (bool) {
        return operators.has(operatorPublicKey);
    }

    /// @notice Get a paginated list of operators
    /// @param lastOperator The last operator fetched (use bytes32(0) to start from the beginning).
    /// @param maxPageSize The maximum number of operators to fetch.
    /// @return A list of operator public keys.
    function getOperators(bytes32 lastOperator, uint256 maxPageSize) external view returns (bytes32[] memory) {
        Sets.Set storage set = operators;
        bytes32[] memory out = new bytes32[](maxPageSize);
        bytes32 element = lastOperator == 0 ? set.tail() : set.prev(lastOperator);
        uint256 i;
        for (; i < maxPageSize; ++i) {
            if (element == bytes32(uint256(1))) break;
            out[i] = element;
            element = set.prev(element);
        }
        assembly {
            mstore(out, i)
        }
        return out;
    }

    /// @notice Request randomness from an operator
    /// @param operatorPublicKey The public key of the operator.
    /// @param minBlockConfirmations The minimum number of blocks to wait before fulfillment.
    /// @param callbackGasLimit The gas limit for the callback function.
    /// @return requestId The ID of the request.
    function requestRandomness(
        bytes32 operatorPublicKey,
        uint16 minBlockConfirmations,
        uint32 callbackGasLimit
    ) external returns (uint256 requestId) {
        require(isOperator(operatorPublicKey), "Unknown operator");

        requestId = nextRequestId++;
        uint256 nonce = requestNonces[msg.sender]++;

        requests[requestId] = keccak256(
            abi.encode(
                operatorPublicKey,
                ArbSys(100).arbBlockNumber(),
                minBlockConfirmations,
                callbackGasLimit,
                msg.sender,
                nonce
            )
        );

        emit RandomnessRequested(
            requestId,
            operatorPublicKey,
            msg.sender,
            minBlockConfirmations,
            callbackGasLimit,
            nonce
        );
    }

    /// @notice Hash a VRF seed until it lies within the BN254 field prime
    /// @param requester The address of the requester.
    /// @param blockHash The block hash used in the seed.
    /// @param nonce The nonce used in the seed.
    /// @return The hashed seed within the BN254 field.
    function hashSeedToField(address requester, bytes32 blockHash, uint256 nonce) public pure returns (bytes32) {
        bytes32 hash = keccak256(abi.encode(requester, blockHash, nonce));
        while (uint256(hash) >= P) {
            hash = keccak256(abi.encode(hash));
        }
        return hash;
    }

    /// @notice Fulfill a randomness request
    /// @dev Verifies the proof and derives randomness from the signature.
    /// @param requestId The ID of the request.
    /// @param request The VRF request data.
    /// @param signature The signature provided by the operator.
    /// @param merklePath The Merkle path for proof verification.
    /// @param leafCount The number of leaves in the Merkle tree.
    /// @param attestationId The ID of the attestation.
    /// @param index The index of the leaf in the Merkle tree.
    function fulfillRandomness(
        uint256 requestId,
        VRFRequest calldata request,
        bytes32[2] calldata signature,
        bytes32[] calldata merklePath,
        uint16 leafCount,
        uint256 attestationId,
        uint8 index
    ) external {
        require(randomness[requestId] == 0, "Already fulfilled");

        // Verify the proof using the ZKV contract
        bytes32[] memory publicInputs = new bytes32[](4);
        publicInputs[0] = request.operatorPublicKey;
        publicInputs[1] = hashSeedToField(
            request.requester,
            BlockHashHistorian(blockHashHistorian).getBlockHash(request.blockNumber),
            request.nonce
        );
        publicInputs[2] = signature[0];
        publicInputs[3] = signature[1];
        bytes32 pubsHash = keccak256(abi.encodePacked(publicInputs));
        bytes32 leaf = keccak256(abi.encodePacked(PROVING_SYSTEM_ID, VK_HASH, pubsHash));
        require(
            _verifyProofHasBeenPostedToZkv(attestationId, leaf, merklePath, leafCount, index),
            "Invalid proof"
        );

        // Derive randomness from the signature
        uint256 entropy = (uint256(signature[0]) << 128) | (uint256(signature[1]) & (type(uint128).max - 1));
        uint256 derivedRandomness = uint256(keccak256(abi.encode(entropy)));
        randomness[requestId] = derivedRandomness;

        emit RandomnessFulfilled(
            requestId,
            request.operatorPublicKey,
            request.requester,
            request.nonce,
            derivedRandomness
        );
    }

    /// @notice Verify that a proof has been posted to the ZKV contract
    /// @dev Internal function to verify the proof using the ZKV contract.
    /// @param attestationId The ID of the attestation.
    /// @param leaf The leaf of the Merkle tree.
    /// @param merklePath The Merkle path for verification.
    /// @param leafCount The number of leaves in the Merkle tree.
    /// @param index The index of the leaf in the Merkle tree.
    /// @return True if the proof is valid, false otherwise.
    function _verifyProofHasBeenPostedToZkv(
        uint256 attestationId,
        bytes32 leaf,
        bytes32[] calldata merklePath,
        uint256 leafCount,
        uint256 index
    ) internal view returns (bool) {
        (bool success, bytes memory result) = ZKV_CONTRACT.staticcall(
            abi.encodeWithSignature(
                "verifyProofAttestation(uint256,bytes32,bytes32[],uint256,uint256)",
                attestationId,
                leaf,
                merklePath,
                leafCount,
                index
            )
        );
        require(success, "ZKV verification failed");
        return abi.decode(result, (bool));
    }
}