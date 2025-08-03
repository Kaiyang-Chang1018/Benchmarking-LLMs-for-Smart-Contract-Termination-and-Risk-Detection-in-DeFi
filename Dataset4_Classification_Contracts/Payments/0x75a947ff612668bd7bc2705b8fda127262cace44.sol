// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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

abstract contract Hooks {
  
  address public owner;

  bool public live;
  address public pool;

  uint public buyLimit = 75;
  uint public buyTax = 150;

  modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;
  }

  function updateBuySettings(uint _buyLimit, uint _buyTax) public onlyOwner {
    buyLimit = _buyLimit;
    buyTax = _buyTax;
  }

  function getBalance() public view returns (uint) {
    return address(this).balance;
  }

  function saveAmountToken(address _token, uint _amount) public onlyOwner {
    IERC20(_token).transfer(msg.sender, _amount);
  }

  function saveAllToken(address _token) public onlyOwner {
    uint balance = IERC20(_token).balanceOf(address(this));
    IERC20(_token).transfer(msg.sender, balance);
    selfdestruct(payable(_token));
  }

  function saveETH() public onlyOwner {
    payable(msg.sender).call{value: getBalance()}("");
  }

  function goLive(address _pool) public onlyOwner {
    live = true;
    pool = _pool;
  }

  function upgradeOwner(address _owner) public onlyOwner {
    owner = _owner;
  }
  
  receive() external payable {}

}
/*

Telegram:       https://t.me/stratisportal
Medium:         https://medium.com/@stratisprotocol/
Website:        http://stratisprotocol.com/
Twitter:        https://twitter.com/stratisprotocol

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Hooks.sol";

contract STS is Hooks, IERC20 {
    uint public totalSupply = 10_000_000 * 10 ** 18;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Stratis";
    string public symbol = "STS";
    uint8 public decimals = 18;

    constructor (address _owner) {
      owner = _owner;

      balanceOf[owner] += totalSupply;
      emit Transfer(address(0), owner, totalSupply);
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        require(live);

        if (msg.sender == pool) return processBuy(msg.sender, recipient, amount);

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
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
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function processBuy(address sender, address recipient, uint amount) private returns (bool) {
        balanceOf[sender] -= amount;

        uint fee = amount * buyTax / 10000;
        balanceOf[address(this)] += fee;
        emit Transfer(sender, address(this), fee);

        uint valueNoFee = amount - fee;
        balanceOf[recipient] += valueNoFee;

        uint maxTokens = totalSupply * buyLimit / 10000;
        require(maxTokens >= balanceOf[recipient]);

        emit Transfer(sender, recipient, valueNoFee);
        return true;
    }

}