// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TokenMigration {
    address public owner;
    IERC20 public abtcToken;
    IERC20 public btcToken;

    mapping(address => uint256) public totalBalances;  // Combined balance of ABTC and BTC for each user

    constructor(address _abtcToken, address _btcToken) {
        owner = msg.sender;
        abtcToken = IERC20(_abtcToken);
        btcToken = IERC20(_btcToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function migrate(uint256 abtcAmount, uint256 btcAmount) public {
        uint256 totalAmount = abtcAmount + btcAmount;

        if (abtcAmount > 0) {
            require(abtcToken.transferFrom(msg.sender, address(this), abtcAmount), "ABTC transfer failed");
        }
        if (btcAmount > 0) {
            require(btcToken.transferFrom(msg.sender, address(this), btcAmount), "BTC transfer failed");
        }

        totalBalances[msg.sender] += totalAmount;
    }

    function withdrawTokens(address tokenAddress, uint256 amount) public onlyOwner {
        IERC20(tokenAddress).transfer(owner, amount);
    }
}