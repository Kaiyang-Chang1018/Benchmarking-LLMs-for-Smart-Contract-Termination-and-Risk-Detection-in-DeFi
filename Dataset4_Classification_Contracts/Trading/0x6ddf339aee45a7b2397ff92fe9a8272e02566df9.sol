// SPDX-License-Identifier: Unlicensed

/*
Website: https://www.chainsendai.com/
Twitter: https://twitter.com/chainsendapp
Telegram: https://t.me/chainsend
*/

pragma solidity 0.8.24;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

 
    function _transfer(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

 
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _createInitialTokens(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }


    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

contract CHAINSEND is ERC20, Ownable {
    
    uint256 public maxWalletToken = 1500000 * 10**18; // 1.5% of total supply
    uint256 public swapAmount = 3000 * 10**18;
    uint256 public marketingFees = 5; // 5% fee on each buy/sell

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _isBot;
    mapping (address => bool) public tradingWhitelist;

    address payable public operationsWallet = payable(0xd4aE93809F0919C118Ad1CbA4d1DBCD63f212ba5);
    address payable public communityWallet = payable(0xc11F3b6f5B72Cd618f090A56e70A72A78cF88BC4);
    address payable public marketingWallet = payable(0x02e0095B2803feF26a21D788E1Cf0AB74225e4E4);

    event TradingAttempt(address indexed from, address indexed to, bool isFromWhitelisted, bool isToWhitelisted);
    event WhitelistUpdated(address indexed account, bool status);
    event TradingEnabledChanged(bool enabled);
    event SwapAndDistribute(uint256 tokensSwapped, uint256 ethReceived);
    event BotStatusChanged(address indexed account, bool isBlacklisted);


    bool public tradingEnabled = false;

    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
   

    constructor() ERC20("CHAINSEND", "CSEND") {
        _createInitialTokens(owner(), 100000000 * (10**18)); // Mint the total supply to the owner
        transferOwnership(owner());

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D // Uniswap Router address
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[marketingWallet] = true;
        _isExcludedFromFees[operationsWallet] = true;
        _isExcludedFromFees[communityWallet] = true;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        bool isFromWhitelisted = tradingWhitelist[from];
        bool isToWhitelisted = tradingWhitelist[to];
        emit TradingAttempt(from, to, isFromWhitelisted, isToWhitelisted);

        require(!_isBot[from] && !_isBot[to], "Bot address cannot transfer tokens");
        require(from != address(0) && to != address(0), "ERC20: transfer to/from the zero address");
        require(
            tradingEnabled || from == owner() || to == owner() || isFromWhitelisted || isToWhitelisted,
            "Trading is not enabled or address not whitelisted"
        );

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (from == uniswapV2Pair && !_isExcludedFromFees[from] && !_isExcludedFromFees[to] && to != address(uniswapV2Router)) {
            uint256 contractBalanceRecipient = balanceOf(to);
            require(contractBalanceRecipient + amount <= maxWalletToken, "Exceeds maximum wallet token amount.");
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= swapAmount;
        if (overMinTokenBalance && !inSwap && to == uniswapV2Pair) {
            swapAndDistribute(contractTokenBalance);
        }

        uint256 feeAmount = amount * marketingFees / 100;
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to] && (from == uniswapV2Pair || to == uniswapV2Pair)) {
            super._transfer(from, address(this), feeAmount);
            amount -= feeAmount;
        }

        super._transfer(from, to, amount);
    }

    function swapAndDistribute(uint256 tokenAmount) private {
        swapTokensForEth(tokenAmount); // This swaps the tokens for ETH and keeps it in the contract

        uint256 balance = address(this).balance;
        uint256 marketingAmount = balance * 40 / 100; // 40% for marketing
        uint256 operationsAmount = balance * 40 / 100; // 40% for operations
        uint256 communityAmount = balance - (marketingAmount + operationsAmount); // 20% for community

        marketingWallet.transfer(marketingAmount);
        operationsWallet.transfer(operationsAmount);
        communityWallet.transfer(communityAmount);

        emit SwapAndDistribute(tokenAmount, balance);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap{
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // Contract keeps the ETH
            block.timestamp
        );
    }


    function removeTax(uint256 _newFee) public onlyOwner {
        require(_newFee <= 5, "can't set more than 5%");
        marketingFees = _newFee;
    }

    function updateBotStatus(address account, bool value) public onlyOwner {
        _isBot[account] = value;
        emit BotStatusChanged(account, value);
    }

    function updateWhitelistStatus(address[] memory _addresses, bool[] memory _statuses) public onlyOwner {
        require(_addresses.length == _statuses.length, "Arrays length mismatch");

        for (uint256 i = 0; i < _addresses.length; i++) {
            tradingWhitelist[_addresses[i]] = _statuses[i];
            emit WhitelistUpdated(_addresses[i], _statuses[i]);
        }
    }

    function updateMaxWalletPercentage(uint256 _newMaxPercentage) public onlyOwner {
        require(_newMaxPercentage >= 1, "Cannot set below 1%");
        maxWalletToken = totalSupply() * _newMaxPercentage / 100;
    }
    
    function setSwapAmount(uint256 _newSwapAmount) public onlyOwner {
        swapAmount = _newSwapAmount;

    }

    function enableTrading() public onlyOwner {
        require(tradingEnabled != true, "Already enabled");
        tradingEnabled = true;
    }

    receive() external payable {
        // Allow the contract to receive ETH
    }

}