// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/drosera-contracts/interfaces/ITrap.sol";

/*
AaveWithdrawalTrap (event-driven, Drosera-friendly)
- collect() is view-safe and does NOT call external contracts (returns a valid bytes blob).
- shouldRespond(bytes[] calldata data) expects Drosera to pass event-derived numeric blobs,
  with data[0] == newest (most Drosera runners use newest-first).
- planner-safety checks: ensures blobs are non-empty before decoding to avoid reverts.
- threshold logic: triggers when newest >= minWithdrawal and delta (newest - previous) >= minDelta.
- Comments: Configure Drosera to filter LendingPool Withdraw events for WETH and pass `amount` as blobs.
*/

contract AaveWithdrawalTrap is ITrap {
    uint256 public constant DEFAULT_MIN_WITHDRAWAL = 5 ether;
    uint256 public minWithdrawal = DEFAULT_MIN_WITHDRAWAL;
    uint256 public minDelta = 0; // optional second threshold

    // collect() must be view-safe and not revert. Return a valid encoded uint256 (dummy)
    // Drosera will instead supply event amounts into shouldRespond's data.
    function collect() external view override returns (bytes memory) {
        // Return a harmless zero value to ensure eth_call never reverts.
        uint256 dummy = 0;
        return abi.encode(dummy);
    }

    // shouldRespond should be pure/deterministic and protect against malformed blobs.
    // Expectation (recommended Drosera behavior): data[0] = newest amount, data[1] = previous, ...
    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        // No data -> nothing to do
        if (data.length == 0) {
            return (false, abi.encode(uint256(0)));
        }

        // Planner-safety: ensure data[0] is non-empty
        if (data[0].length == 0) {
            return (false, abi.encode(uint256(0)));
        }

        // decode newest amount (data[0] is newest per most Drosera runners)
        uint256 newest;
        // safe decode inside unchecked block for clarity (we already checked length>0)
        newest = abi.decode(data[0], (uint256));

        // previous = data[1] if present and non-empty, otherwise same as newest
        uint256 previous = newest;
        if (data.length > 1 && data[1].length > 0) {
            previous = abi.decode(data[1], (uint256));
        }

        // If newest below minimum, ignore
        if (newest < DEFAULT_MIN_WITHDRAWAL) {
            return (false, abi.encode(uint256(0)));
        }

        // Optional delta check (if enabled by setting minDelta > 0)
        if (minDelta > 0) {
            // protect against underflow: newest >= previous
            if (newest >= previous) {
                uint256 diff = newest - previous;
                if (diff >= minDelta) {
                    return (true, abi.encode(newest));
                } else {
                    return (false, abi.encode(uint256(0)));
                }
            } else {
                // newest < previous -> treat as no trigger
                return (false, abi.encode(uint256(0)));
            }
        }

        // Default: trigger if newest >= minWithdrawal
        if (newest >= minWithdrawal) {
            return (true, abi.encode(newest));
        }

        return (false, abi.encode(uint256(0)));
    }

    // Optional setters (no constructor args). Ownerless for simplicity — control via Git commits & deployment account.
    // If you want on-chain ACL for parameter changes, add owner + onlyOwner (allowed as no constructor args).
    function setMinWithdrawal(uint256 _min) external {
        minWithdrawal = _min;
    }

    function setMinDelta(uint256 _delta) external {
        minDelta = _delta;
    }
}
