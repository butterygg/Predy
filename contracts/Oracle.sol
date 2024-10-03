// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Oracle {
    function getAnswer(bytes32 _questionId) public view returns (bool) {
        // Simple random oracle for demonstration purposes
        return uint256(keccak256(abi.encodePacked(block.timestamp, _questionId))) % 2 == 0;
    }
}