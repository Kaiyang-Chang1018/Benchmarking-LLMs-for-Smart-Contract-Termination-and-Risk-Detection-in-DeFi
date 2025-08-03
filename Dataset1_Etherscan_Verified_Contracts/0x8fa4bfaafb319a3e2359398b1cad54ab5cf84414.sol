// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface AyeAyeCoin {
    function sendCoin(address _receiver, uint256 _amount) external;
}

contract AyeAyeGet {

    function grab(uint n) public {
        address addr = 0x3edDc7ebC7db94f54b72D8Ed1F42cE6A527305bB;
        AyeAyeCoin aa = AyeAyeCoin(addr);
        bytes memory sign = hex"5479f98b";
        for (uint256 i = 0; i < n; i++) {
            addr.call(sign);
        }
        aa.sendCoin(msg.sender, n);
    }
}