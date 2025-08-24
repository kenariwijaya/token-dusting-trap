// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TokenDustingResponseTrap {
    
    address public immutable OWNER;
    
    event DustingAlert(
        string message,
        address indexed tokenAddress,
        address indexed fromAddress,  
        address indexed toAddress,
        uint256 amount,
        uint256 timestamp
    );
    
    modifier onlyOwner() {
        require(msg.sender == OWNER, "Only owner");
        _;
    }
    
    constructor() {
        OWNER = msg.sender;
    }
    
    function handleResponse(bool shouldRespond, bytes memory responseData) external onlyOwner {
        if (shouldRespond && responseData.length > 0) {
            
            (
                string memory message,
                address tokenAddress,
                address fromAddress,
                address toAddress,
                uint256 amount
            ) = abi.decode(
                responseData,  
                (string, address, address, address, uint256)
            );
            
            emit DustingAlert(message, tokenAddress, fromAddress, toAddress, amount, block.timestamp);
        }
    }
}