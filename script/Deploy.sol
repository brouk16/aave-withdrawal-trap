// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AaveWithdrawalResponse {
    uint256 public lastResponded;
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function respond(uint256 amount) external {
        require(msg.sender == owner, "not authorized");
        lastResponded = amount;
    }
}
