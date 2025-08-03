// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

error InvalidConfiguration();
error TokenTransferFailed();

contract Airdrop {

    constructor() {}

    function airdrop(IERC20 token, address[] calldata recipients, uint256[] calldata amounts) external {
        uint256 len = recipients.length;
        if (len != amounts.length) {
            revert InvalidConfiguration();
        }

        for (uint256 i = 0; i < len; i++) {
            if (!token.transferFrom(msg.sender, recipients[i], amounts[i])) {
                revert TokenTransferFailed();
            }
        }
    }
}