// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface AyeAyeCoin {
    function sendCoin(address _receiver, uint256 _amount) external;
}

contract ClaimAyeAye {

    function grab(uint256 n) external {
        for (uint256 i = 0; i < n; i++) {
          0x3edDc7ebC7db94f54b72D8Ed1F42cE6A527305bB.call(hex"5479f98b");
        }

        AyeAyeCoin(0x3edDc7ebC7db94f54b72D8Ed1F42cE6A527305bB).sendCoin(msg.sender, n);
    }
    }