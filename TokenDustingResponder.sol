// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TokenDustingResponder {
    event DustingAlert(
        address indexed caller,
        address indexed wallet,
        bytes32 indexed id,
        uint256 atBlock,
        bytes4 tag
    );

    address public owner;
    mapping(address => bool) public operators;

    bytes4 public constant EXPECTED_TAG = 0x44555354; // "DUST"

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setOperator(address op, bool ok) external onlyOwner {
        operators[op] = ok;
    }

    function execute(bytes calldata payload) external {
        require(operators[msg.sender] || msg.sender == owner, "not authorized");
        require(payload.length == 4 + 32 + 32 + 32, "bad payload"); // tag + wallet + id + block

        bytes4 tag;
        assembly {
            tag := calldataload(payload.offset)
        }
        require(tag == EXPECTED_TAG, "bad tag");

        (address wallet, bytes32 id, uint256 atBlock) = abi.decode(payload[4:], (address, bytes32, uint256));
        emit DustingAlert(msg.sender, wallet, id, atBlock, tag);
    }
}
