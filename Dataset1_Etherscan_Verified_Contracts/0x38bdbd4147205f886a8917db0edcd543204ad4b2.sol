// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PriceOracle {
    uint256 public trxEthPrice; // TRX per ETH (scaled by 1e6)
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
    event PriceUpdated(uint256 newPrice, uint256 timestamp);

    constructor() {
        owner = msg.sender;
    }

    function updatePrice(uint256 _trxEthPrice) external onlyOwner {
        require(_trxEthPrice > 0, "Invalid price");
        trxEthPrice = _trxEthPrice;
        emit PriceUpdated(_trxEthPrice, block.timestamp);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }
    
    function getPrice() external view returns (uint256) {
        return trxEthPrice;
    }
}