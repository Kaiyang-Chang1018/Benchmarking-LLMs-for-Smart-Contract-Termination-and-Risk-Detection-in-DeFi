// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address _spender, uint _value) external;

    function transferFrom(address _from, address _to, uint _value) external ;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract swapToken is Ownable{

    uint256 public exchangeRate = 10000;

    address public token = 0xff4d578498C078446B51325a103379B8783bD1c8;

    function setToken(address addr) external onlyOwner{
        token = addr;
    }

    function setExchangeRate(uint256 rate) external onlyOwner{
        exchangeRate = rate;
    }

    receive() external payable {
        IERC20(token).transfer(msg.sender, msg.value * exchangeRate);
    }

    function withDrawal(address to) external onlyOwner{
        payable(to).transfer(address(this).balance);
    }

    function withDrawalToken(
        address token,
        uint256 amount,
        address to
    ) external  onlyOwner{
        IERC20(token).transfer(to, amount);
    }      
}