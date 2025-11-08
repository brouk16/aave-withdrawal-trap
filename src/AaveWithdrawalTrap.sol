// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/drosera-contracts/interfaces/ITrap.sol";

contract AaveWithdrawalTrap is ITrap {
    // Simulated value representing observed withdrawals from Aave
    uint256 public simulatedWithdrawals; 

    // Helper function to update the simulated value
    function updateSimulatedWithdrawals(uint256 newValue) external {
        simulatedWithdrawals = newValue;
    }

    // collect() packages the current simulated state into bytes for Drosera
    function collect() external view returns (bytes memory) {
        return abi.encode(simulatedWithdrawals);
    }

    // shouldRespond() evaluates collected data (NO state reads allowed here)
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        // data[0] expected to contain encoded uint256 simulatedWithdrawals
        uint256 withdrawals = abi.decode(data[0], (uint256));

        // Condition for triggering a response:
        // Example: respond if more than 10 withdrawals detected
        bool trigger = withdrawals > 10;

        // Send back the withdrawals count as payload
        return (trigger, abi.encode(withdrawals));
    }
}
