// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract TokenDustingTrap is ITrap {
    address public immutable MY_WALLET;
    
    constructor() {
        MY_WALLET = msg.sender;
    }
    
    function collect() external view returns (bytes memory) {
        return abi.encode(MY_WALLET);
    }
    
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        if (data.length < 2) {
            return (false, bytes(""));
        }
        
        if (data[0].length < 160) {
            return (false, bytes(""));
        }
        
        address tokenAddress;
        address fromAddress;
        address toAddress;
        uint256 amount;
        bool isKnownToken;
        
        (tokenAddress, fromAddress, toAddress, amount, isKnownToken) = abi.decode(
            data[0], 
            (address, address, address, uint256, bool)
        );
        
        address monitoredWallet;
        if (data[1].length >= 32) {
            (monitoredWallet) = abi.decode(data[1], (address));
        } else {
            return (false, bytes(""));
        }
        
        bool isDustingDetected = (toAddress == monitoredWallet && !isKnownToken);
        
        if (isDustingDetected) {
            bytes memory responseData = abi.encode(
                "DUSTING_DETECTED",
                tokenAddress,
                fromAddress,
                toAddress,
                amount
            );
            return (true, responseData);
        }
        
        return (false, bytes(""));
    }
}