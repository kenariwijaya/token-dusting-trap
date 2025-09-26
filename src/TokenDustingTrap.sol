// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IDustRegistry {
    function flagged(bytes32) external view returns (bool);
}

contract TokenDustingTrap is ITrap {
    // Hardcode or point to a config contract
    address public constant MONITORED_WALLET = 0x0000000000000000000000000000000000000000;
    address public constant REGISTRY = 0x0000000000000000000000000000000000000000;

    bytes4 public constant TAG = 0x44555354; // "DUST"

    struct CollectOutput {
        uint256 blockNumber;
        bytes32 lastId;
        bool isFlagged;
    }

    constructor() {}

    function collect() external view returns (bytes memory) {
        bytes32 id = keccak256(abi.encode(MONITORED_WALLET, block.number));
        bool f = IDustRegistry(REGISTRY).flagged(id);
        return abi.encode(CollectOutput({
            blockNumber: block.number,
            lastId: id,
            isFlagged: f
        }));
    }

    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        if (data.length == 0) return (false, "");

        CollectOutput memory cur = abi.decode(data[0], (CollectOutput));

        if (cur.isFlagged) {
            // Payload = TAG || wallet || id || block
            return (true, abi.encodePacked(
                TAG,
                abi.encode(MONITORED_WALLET, cur.lastId, cur.blockNumber)
            ));
        }
        return (false, "");
    }
}
