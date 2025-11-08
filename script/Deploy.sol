// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/AaveWithdrawalTrap.sol";
import "../src/AaveWithdrawalResponse.sol";
import "forge-std/Script.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        AaveWithdrawalTrap trap = new AaveWithdrawalTrap();
        AaveWithdrawalResponse response = new AaveWithdrawalResponse();

        vm.stopBroadcast();
    }
}
