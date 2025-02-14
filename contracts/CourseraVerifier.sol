// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract CourseraVerifier {
    // Error definitions
    error InvalidSignature();
    error InvalidValidator();
    
    struct VerificationData {
        bytes32 taskId;
        bytes32 schemaId;
        bytes32 uHash;
        bytes32 publicFieldsHash;
        bytes validatorSignature;
        address validatorAddress;
    }
    
    // Convert string to bytes32
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        // Convert string to bytes
        bytes memory tempEmptyStringTest = bytes(source);
        
        // If empty string, return empty bytes32
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        
        assembly {
            result := mload(add(source, 32))
        }
    }
    
    // Get parameters hash
    function getParamsHash(
        bytes32 taskId,
        bytes32 schemaId,
        bytes32 uHash,
        bytes32 publicFieldsHash
    ) public pure returns (bytes32) {
        return keccak256(
            abi.encode(
                taskId,
                schemaId,
                uHash,
                publicFieldsHash
            )
        );
    }
    
    // Verify signature and recover signer
    function verifySignature(bytes32 messageHash, bytes memory signature) public pure returns (address) {
        // Convert message hash to eth signed message hash
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        
        // Split signature into r, s, v components
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        
        // Recover signer address
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        if (signer == address(0)) revert InvalidSignature();
        
        return signer;
    }
    
    // Main verification function
    function verifyTask(VerificationData memory data) public pure returns (bool) {
        // Get parameters hash
        bytes32 paramsHash = getParamsHash(
            data.taskId,
            data.schemaId,
            data.uHash,
            data.publicFieldsHash
        );
        
        // Verify signature and recover signer
        address recoveredValidator = verifySignature(paramsHash, data.validatorSignature);
        
        // Verify recovered address matches expected validator
        if (recoveredValidator != data.validatorAddress) revert InvalidValidator();
        
        return true;
    }
    
    // Helper function to verify task with string IDs
    function verifyTaskWithStrings(
        string memory taskId,
        string memory schemaId,
        bytes32 uHash,
        bytes32 publicFieldsHash,
        bytes memory validatorSignature,
        address validatorAddress
    ) external pure returns (bool) {
        VerificationData memory data = VerificationData({
            taskId: stringToBytes32(taskId),
            schemaId: stringToBytes32(schemaId),
            uHash: uHash,
            publicFieldsHash: publicFieldsHash,
            validatorSignature: validatorSignature,
            validatorAddress: validatorAddress
        });
        
        return verifyTask(data);
    }
}