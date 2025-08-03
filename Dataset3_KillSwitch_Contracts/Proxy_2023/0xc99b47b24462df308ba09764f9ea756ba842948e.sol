// SPDX-License-Identifier: Unlicensed

//  Relaunch contract


//  Join Pepe's world of sheep! 

//  https://t.me/sheepereth
//  https://twitter.com/SheeperEth
//  https://sheeper.vip/

pragma solidity ^0.8.20;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract Sheeper {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFeeAndMaxTx;
    mapping(address => bool) private _isAutomatedMarketMaker;

    address private _owner;

    address public devWallet;
    address public uniswapV2Pair;
    IUniswapV2Router public uniswapV2Router;

    uint256 private _totalSupply;

    bool public tradingActive;

    uint256 public maxTransaction;
    uint256 public maxContractSwap;

    uint256 public buyFee;
    uint256 public sellFee;

    uint8 private _decimals = 9;

    string private _name;
    string private _symbol;

    modifier onlyOwner() {
        require(_owner == msg.sender);
        _;
    }

    event Approval(
        address indexed from,
        address indexed spender,
        uint256 amount
    );
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        address owner_
    ) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_;
        _balances[owner_] = totalSupply_;
        emit Transfer(address(0), owner_, totalSupply_);
        _owner = owner_;
        devWallet = owner_;
        maxTransaction = (totalSupply_ / 100) * 3;
        maxContractSwap = (totalSupply_ / 100) * 1;
        buyFee = 35;
        sellFee = 40;
        uniswapV2Router = IUniswapV2Router(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        address uniswapV2Factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Factory).createPair(
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            address(this)
        );
        _isAutomatedMarketMaker[uniswapV2Pair] = true;
        _isExcludedFromFeeAndMaxTx[address(this)] = true;
        _isExcludedFromFeeAndMaxTx[owner_] = true;
    }

    receive() external payable {}

    fallback() external payable {}

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function balanceOf(address _address) public view returns (uint256) {
        return _balances[_address];
    }

    function allowance(address from, address to) public view returns (uint256) {
        return _allowances[from][to];
    }

    function isAutomatedMarketMaker(address _address)
        public
        view
        returns (bool)
    {
        return _isAutomatedMarketMaker[_address];
    }

    function isExcludedFromFeeAndMaxTx(address _address)
        public
        view
        returns (bool)
    {
        return _isExcludedFromFeeAndMaxTx[_address];
    }

    function renounceOwnership() external onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address from,
        address spender,
        uint256 amount
    ) internal {
        _allowances[from][spender] = amount;
        emit Approval(from, spender, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        _approve(from, msg.sender, _allowances[from][msg.sender] - amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(_balances[from] >= amount);
        uint256 fee;
        if(!tradingActive){
            require(_isExcludedFromFeeAndMaxTx[from] || _isExcludedFromFeeAndMaxTx[to]);
        }
        if (
            !_isExcludedFromFeeAndMaxTx[from] && !_isExcludedFromFeeAndMaxTx[to]
        ) {
            require(amount < maxTransaction);
            if (_isAutomatedMarketMaker[from]) {
                _balances[address(this)] += (amount / 100) * buyFee;
                emit Transfer(from, address(this), (amount / 100) * buyFee);
                fee = buyFee;
            }
            if (_isAutomatedMarketMaker[to]) {
                if (_balances[address(this)] > 0) {
                    if (_balances[address(this)] > maxContractSwap) {
                        contractBalanceRealization(maxContractSwap);
                    } else {
                        contractBalanceRealization(_balances[address(this)]);
                    }
                }
                _balances[address(this)] += (amount / 100) * sellFee;
                emit Transfer(from, address(this), (amount / 100) * sellFee);
                fee = sellFee;
            }
        }
        uint256 feeAmount = (amount / 100) * fee;
        uint256 finalAmount = amount - feeAmount;
        _balances[from] -= amount;
        _balances[to] += finalAmount;
        emit Transfer(from, to, finalAmount);
    }

    function contractBalanceRealization(uint256 amount) internal {
        swapTokensForETH(amount);
        devWallet.call{value: address(this).balance}("");
    }

    function swapTokensForETH(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function enableTrading() external onlyOwner {
        tradingActive = true;
    }

    function setFees(uint256 newBuyFee, uint256 newSellFee) external onlyOwner {
        require(newBuyFee < 30 && newSellFee < 30);
        buyFee = newBuyFee;
        sellFee = newSellFee;
    }

    function removeLimits() external onlyOwner {
        maxTransaction = _totalSupply;
    }
}