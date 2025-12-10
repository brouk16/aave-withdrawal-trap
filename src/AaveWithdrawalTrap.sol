// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/drosera-contracts/interfaces/ITrap.sol";

interface IAavePool {
    // Withdraw event — this is what we monitor
    event Withdraw(address indexed asset, address indexed user, address indexed to, uint256 amount);
}

contract AaveWithdrawalTrap is ITrap {
    // Aave V3 Ethereum Mainnet Pool
    address public constant AAVE_POOL = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;

    // WETH address (mainnet)
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // Minimal withdrawal size
    uint256 public constant MIN_WITHDRAW = 5 ether;

    /*
        collect() — safe for eth_call
        We DO NOT call the Pool contract.
        Instead, we just return an empty bytes blob.
        Drosera fetches logs separately.
    */
    function collect() external view override returns (bytes memory) {
        return abi.encode(uint256(0));
    }

    /*
        shouldRespond(data):

        Drosera provides event logs through `data[]`.
        We decode event logs manually.

        Data format:
        data[i] = abi.encode(asset, user, to, amount)

        Planner ordering:
        data[0] = newest
        data[data.length-1] = oldest
    */
    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        if (data.length == 0) return (false, "");

        uint256 totalWithdrawn;

        for (uint256 i = 0; i < data.length; i++) {
            if (data[i].length == 0) continue;

            (address asset,, , uint256 amount) =
                abi.decode(data[i], (address, address, address, uint256));

            if (asset == WETH) {
                totalWithdrawn += amount;
            }
        }

        if (totalWithdrawn >= MIN_WITHDRAW) {
            return (true, abi.encode(totalWithdrawn));
        }

        return (false, "");
    }
}
