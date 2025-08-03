// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract TEST is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "TEST INU";
    string private constant _symbol = "TEST";
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 10000000000 * 10**uint256(_decimals);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    address payable private _taxWallet;

    uint256 private _buyTax = 0;
    uint256 private _sellTax = 0;
    uint256 public _maxTxAmount = _tTotal * 15 / 1000; // 1.5% of total supply
    uint256 public _maxWalletSize = _tTotal * 15 / 1000; // 1.5% of total supply

    uint256 public _taxSwapThreshold = _tTotal / 500; // 0.2% of total supply

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool private tradingOpen = true;
    bool private inSwap = false;
    bool private swapEnabled = true;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    // Modifier to prevent reentrancy in swaps
    modifier lockTheSwap {
        require(!inSwap, "Currently in swap");
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxWallet = payable(_msgSender());

        address[13] memory wallets = [
            0xEE24B35dbDcc02eF83D6CFF38c5C7BE278eC78AD, // Team Wallet
            0xDa7db0548a61F05F334aDC8c0d08bB45911bF16f, // Binance Wallet
            0xa54B520781ea45a7D604d0E1A40d7129583A7878, // Coinbase Wallet
            0xEDd4e761936EA2D72a333c5a1d5BD44BF90462D7, // Bybit Wallet
            0xE171c3C4f0B2538d2270E9C33820e2b2AB77f195, // OKX Wallet
            0xB4a53a61fB4A7b77CA5CE87C553453166017F3f5, // Kucoin Wallet
            0x4f811bAe2f4B6413e6C757511a3B96ddd70adC0a, // Reserve/Ecosystem Wallet 1
            0xf835Ed06bb6bBcEDbe2F8713Feb75DaA718f21C9, // Reserve/Ecosystem Wallet 2
            0x2C2D02eF033FCDAc283Bc99C180972e5eda5429f, // Reserve/Ecosystem Wallet 3
            0x23Ac8d02c0FB4f0F76D1A31EF5C66B5fb6385d2C, // Reserve/Ecosystem Wallet 4
            0x5b9d07aff0e7e40e13FFAd0CFCC179b945f5279f, // Reserve/Ecosystem Wallet 5
            0xc788b40Bc6A01860dB7b152a1c44b1C4061d8A11, // Anti Snipe Wallet
            0xD5c8B24a1159Ea75E25709E3C5851982592804bC  // Airdrop Wallet
        ];

        uint256[13] memory amounts = [
            uint256(200000000) * 10**uint256(_decimals), // Team tokens
            uint256(200000000) * 10**uint256(_decimals), // Binance Wallet
            uint256(200000000) * 10**uint256(_decimals), // Coinbase Wallet
            uint256(150000000) * 10**uint256(_decimals), // Bybit Wallet
            uint256(150000000) * 10**uint256(_decimals), // OKX Wallet
            uint256(150000000) * 10**uint256(_decimals), // Kucoin Wallet
            uint256(200000000) * 10**uint256(_decimals), // Reserve/Ecosystem Wallet 1
            uint256(200000000) * 10**uint256(_decimals), // Reserve/Ecosystem Wallet 2
            uint256(200000000) * 10**uint256(_decimals), // Reserve/Ecosystem Wallet 3
            uint256(200000000) * 10**uint256(_decimals), // Reserve/Ecosystem Wallet 4
            uint256(200000000) * 10**uint256(_decimals), // Reserve/Ecosystem Wallet 5
            uint256(850000000) * 10**uint256(_decimals), // Anti Snipe Wallet
            uint256(300000000) * 10**uint256(_decimals)  // Airdrop Wallet
        ];

        for (uint i = 0; i < wallets.length; i++) {
            _balances[wallets[i]] = amounts[i];
            emit Transfer(address(0), wallets[i], amounts[i]); // Emit Transfer event for each wallet
        }

        uint256 totalAssigned = 0;
        for (uint i = 0; i < amounts.length; i++) {
            totalAssigned = totalAssigned.add(amounts[i]);
        }
        _balances[_msgSender()] = _tTotal.sub(totalAssigned);
        emit Transfer(address(0), _msgSender(), _balances[_msgSender()]); // Emit Transfer event for deployer

        // Set up Uniswap
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        // Exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
    }





    

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance.sub(amount));
        return true;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!bots[from] && !bots[to], "ERC20: Wallet is blacklisted!");

        uint256 taxAmount = 0;
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            if (from == uniswapV2Pair) { // Buying
                taxAmount = amount.mul(_buyTax).div(100);
            } else if (to == uniswapV2Pair) { // Selling
                taxAmount = amount.mul(_sellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= _maxTxAmount) {
                contractTokenBalance = _maxTxAmount;
            }

            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance >= _taxSwapThreshold) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(contractETHBalance);
                }
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    // Function to remove transaction and wallet size limits
    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_maxTxAmount);  // Assuming you have declared this event
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function setTax(uint256 buyTax, uint256 sellTax) external onlyOwner {
        _buyTax = buyTax;
        _sellTax = sellTax;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }
}