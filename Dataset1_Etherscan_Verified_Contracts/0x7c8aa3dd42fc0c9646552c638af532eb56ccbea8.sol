// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ClaimDelegation {
    /**
     * @dev Emitted whenever a user delegates `from` to `to`.
     */
    event Delegation(address indexed from, address indexed to);

    /**
     * @dev Who each address is currently delegating to.
     *
     * For example:
     * delegations[A] = B means A is currently delegating to B.
     */
    mapping(address => address) public delegations;

    /**
     * @dev How many addresses are currently delegating to a specific address.
     * If delegateCount[X] > 0, it means at least one user is delegating to X,
     * so X cannot itself delegate from.
     */
    mapping(address => uint256) public delegateCount;

    /**
     * @dev Delegate your address (`msg.sender`) to a given address (`_to`).
     *
     * Rules:
     * 1) If you are currently delegated to by anyone (delegateCount[msg.sender] > 0),
     *    you cannot delegate out (no re-delegation from a currently delegated address).
     * 2) If you had previously delegated to someone else, decrement that old delegate's count.
     * 3) Set a new delegate `_to`. Increment `_to`'s count if `_to` is not the zero address.
     */
    function delegateToAlternateAddress(address _to) external {
        // Rule 1: If msg.sender is currently a delegate for someone, revert.
        require(
            delegateCount[msg.sender] == 0,
            "You are currently a delegate; cannot re-delegate."
        );
        require(msg.sender != _to, "You cannot delegate to yourself.");

        // If msg.sender was already delegating to an address, decrement its count
        address currentDelegate = delegations[msg.sender];
        if (currentDelegate != address(0)) {
            delegateCount[currentDelegate] -= 1;
        }

        // Set the new delegate
        delegations[msg.sender] = _to;

        // Increment the new delegate's count, if not zero
        if (_to != address(0)) {
            delegateCount[_to] += 1;
        }

        // Emit the event for off-chain tracking
        emit Delegation(msg.sender, _to);
    }
}