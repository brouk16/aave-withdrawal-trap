// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AaveWithdrawalResponse {
    event WithdrawalSpike(uint256 newWithdrawals);

    function respond(uint256 newWithdrawals) external payable {
        // Просто логируем данные — без условий и без revert
        emit WithdrawalSpike(newWithdrawals);
    }

    // fallback и receive нужны, чтобы гарантировать, что контракт не ревертится ни при каких вызовах
    fallback() external payable {}
    receive() external payable {}
}
