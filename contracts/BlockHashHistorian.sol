// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/**
 * @title BlockHashHistorian
 * @dev A contract to store and retrieve historical block hashes beyond
 * Ethereum's 256 block limit
 */
contract BlockHashHistorian {
    /// @dev Storage for historical block hashes
    mapping(uint256 => bytes32) public historicalBlockHashes;
    
    /// @dev Constants for optimization and clarity
    uint256 private constant BLOCK_HASH_WINDOW = 256;
    uint256 private constant PARENT_HASH_OFFSET = 0x24;
    uint256 private constant PARENT_HASH_LENGTH = 0x20; // 32 bytes

    // Custom errors
    error BlockHashNotAvailable(uint256 blockNumber);
    error InvalidBlock(uint256 blockNumber);
    error UnknownBlockHash(bytes32 blockHash);
    error InputLengthsMismatch();
    error BlockNumberTooRecent(uint256 blockNumber);
    error InvalidHeaderLength(uint256 length);

    // Events for better tracking
    event BlockHashRecorded(uint256 indexed blockNumber, bytes32 blockHash);
    event HistoricalBlockHashRecorded(uint256 indexed blockNumber, bytes32 blockHash);

    /**
     * @notice Retrieves a block hash from either recent blocks or historical storage
     * @param blockNumber The block number to query
     * @return The block hash for the specified block
     */
    function getBlockHash(uint256 blockNumber) external view returns (bytes32) {
        // Check if block is within recent window
        if (blockNumber >= block.number - BLOCK_HASH_WINDOW) {
            bytes32 recentHash = blockhash(blockNumber);
            if (recentHash != bytes32(0)) {
                return recentHash;
            }
        }

        // Check historical storage
        bytes32 historicalHash = historicalBlockHashes[blockNumber];
        if (historicalHash == bytes32(0)) {
            revert BlockHashNotAvailable(blockNumber);
        }

        return historicalHash;
    }

    /**
     * @notice Records the hash of a recent block
     * @param blockNumber The block number to record
     */
    function recordRecent(uint256 blockNumber) external {
        // Validate block number
        if (blockNumber >= block.number) {
            revert BlockNumberTooRecent(blockNumber);
        }

        if (blockNumber < block.number - BLOCK_HASH_WINDOW) {
            revert InvalidBlock(blockNumber);
        }

        // Get and store the block hash
        bytes32 hash = blockhash(blockNumber);
        if (hash == bytes32(0)) {
            revert BlockHashNotAvailable(blockNumber);
        }

        historicalBlockHashes[blockNumber] = hash;
        emit BlockHashRecorded(blockNumber, hash);
    }

    /**
     * @notice Records historical block hashes using RLP encoded block headers
     * @param blockNumbers Array of block numbers to record
     * @param blockHeaderRLPs Array of RLP encoded block headers for the subsequent blocks
     */
    function recordOld(
        uint256[] calldata blockNumbers,
        bytes[] calldata blockHeaderRLPs
    ) external {
        // Validate input arrays
        if (blockNumbers.length != blockHeaderRLPs.length) {
            revert InputLengthsMismatch();
        }

        for (uint256 i = 0; i < blockNumbers.length; ++i) {
            // Validate header length
            if (blockHeaderRLPs[i].length < PARENT_HASH_OFFSET + PARENT_HASH_LENGTH) {
                revert InvalidHeaderLength(blockHeaderRLPs[i].length);
            }

            // Verify the next block's hash is known
            bytes32 calculatedHash = keccak256(blockHeaderRLPs[i]);
            if (historicalBlockHashes[blockNumbers[i] + 1] != calculatedHash) {
                revert UnknownBlockHash(calculatedHash);
            }

            // Extract and store the parent hash
            bytes32 parentHash;
            assembly {
                // Load parent hash from calldata
                parentHash := calldataload(
                    add(add(blockHeaderRLPs.offset, mul(i, 0x20)), PARENT_HASH_OFFSET)
                )
            }

            historicalBlockHashes[blockNumbers[i]] = parentHash;
            emit HistoricalBlockHashRecorded(blockNumbers[i], parentHash);
        }
    }

    /**
     * @notice Checks if a block hash is available
     * @param blockNumber The block number to check
     * @return bool True if the block hash is available
     */
    function isBlockHashAvailable(uint256 blockNumber) external view returns (bool) {
        if (blockNumber >= block.number - BLOCK_HASH_WINDOW) {
            return blockhash(blockNumber) != bytes32(0);
        }
        return historicalBlockHashes[blockNumber] != bytes32(0);
    }

    /**
     * @notice Batch retrieval of block hashes
     * @param blockNumbers Array of block numbers to query
     * @return bytes32[] Array of corresponding block hashes
     */
    function getBatchBlockHashes(uint256[] calldata blockNumbers) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        bytes32[] memory hashes = new bytes32[](blockNumbers.length);
        
        for (uint256 i = 0; i < blockNumbers.length; i++) {
            if (blockNumbers[i] >= block.number - BLOCK_HASH_WINDOW) {
                hashes[i] = blockhash(blockNumbers[i]);
            } else {
                bytes32 historicalHash = historicalBlockHashes[blockNumbers[i]];
                if (historicalHash == bytes32(0)) {
                    revert BlockHashNotAvailable(blockNumbers[i]);
                }
                hashes[i] = historicalHash;
            }
        }
        
        return hashes;
    }
}