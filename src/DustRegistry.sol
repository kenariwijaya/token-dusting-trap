// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DustRegistry {
    event DustFlag(
        address indexed wallet,
        address indexed token,
        address indexed from,
        uint256 amount,
        bytes32 id
    );

    mapping(bytes32 => bool) public flagged;

    function flag(
        address wallet,
        address token,
        address from,
        uint256 amount,
        uint256 blockNumber
    ) external {
        bytes32 id = keccak256(abi.encode(wallet, token, from, amount, blockNumber));
        flagged[id] = true;
        emit DustFlag(wallet, token, from, amount, id);
    }
}
