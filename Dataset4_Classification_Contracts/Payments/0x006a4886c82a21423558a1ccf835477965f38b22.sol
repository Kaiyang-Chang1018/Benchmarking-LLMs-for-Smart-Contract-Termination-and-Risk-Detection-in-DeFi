// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface FartCoin {
    function BuyToken(uint256 amount) external payable;
    function transfer(address _to, uint256 _value) external;
}

contract GetFartCoin {

    function buyFartCoin() external payable {
        uint256 amount = msg.value / 1e14;
        address addr = 0x93715112138dD0265a3888eb7458BB7BF3fF7C3e;
        FartCoin fc = FartCoin(addr);
        fc.BuyToken{value: msg.value}(amount);
        fc.transfer(msg.sender, amount);
    }
}