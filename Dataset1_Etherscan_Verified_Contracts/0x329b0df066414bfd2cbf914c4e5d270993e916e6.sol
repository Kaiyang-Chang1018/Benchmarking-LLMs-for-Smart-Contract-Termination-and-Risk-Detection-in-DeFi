/*
    Website: https://doubledouble.fi/
    Telegram: https://t.me/doubledoublefi
    Twitter: https://twitter.com/DoubleDoubl_
*/

pragma solidity ^0.8.0;
import "./ERC20.sol";
import "./interfaces/IUniswapRouter.sol";
import "./interfaces/IUniswapFactory.sol";

contract DoubleDouble is ERC20 {
    mapping(address => bool) administrators;

    modifier onlyAdmin() {
        require(administrators[msg.sender], "Only administrators can call this function");
        _;
    }

    uint launchBlock = block.number;

    event SwapBackSuccess(
        uint256 tokenAmount,
        uint256 ethAmountReceived,
        bool success
    );
    bool private swapping;
    address public marketingWallet;

    address public devWallet;

    uint256 _totalSupply = 100_000_000 * 1e18;
    uint256 public maxTransactionAmount = (_totalSupply * 20) / 1000; // 1% from total supply maxTransactionAmountTxn;
    uint256 public swapTokensAtAmount = (_totalSupply * 10) / 10000; // 0.1% swap tokens at this amount. (10_000_000 * 10) / 10000 = 0.1%(10000 tokens) of the total supply
    uint256 public maxWallet = (_totalSupply * 20) / 1000; // 1% from total supply maxWallet

    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;

    uint256 public buyFees = 5;
    uint256 public sellFees = 5;

    uint256 public marketingAmount = 30; //
    uint256 public devAmount = 70; //

    IUniswapRouter public uniswapV2Router;
    address public uniswapV2Pair;
    address public constant deadAddress = address(0xdead);

    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isExcludedMaxTransactionAmount;
    mapping(address => bool) public automatedMarketMakerPairs;

    constructor(address marketing, address factoryAddress, address routerAddress) ERC20("DoubleDouble", "DOUBLE") {
        // exclude from paying fees or having max transaction amount
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[marketingWallet] = true;
        _isExcludedFromFees[devWallet] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(0xdead)] = true;
        _isExcludedMaxTransactionAmount[msg.sender] = true;
        _isExcludedMaxTransactionAmount[marketingWallet] = true;
        _isExcludedMaxTransactionAmount[devWallet] = true;
        _isExcludedMaxTransactionAmount[address(this)] = true;
        _isExcludedMaxTransactionAmount[address(0xdead)] = true;

        _mint(msg.sender, _totalSupply);
        administrators[msg.sender] = true;
        uniswapV2Router = IUniswapRouter(routerAddress);
        IUniswapFactory factory = IUniswapFactory(factoryAddress);
        address pairAddress = factory.createPair(address(this), uniswapV2Router.WETH());
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[msg.sender] = true;
        marketingWallet = marketing;
        devWallet = msg.sender;
        setAutomatedMarketMakerPair(pairAddress, true);
        launchBlock = block.number;
    }

    receive() external payable {}

    // once enabled, can never be turned off
    function enableTrading() external onlyAdmin {
        tradingActive = true;
        swapEnabled = true;
        launchBlock = block.number;
    }

    // remove limits after token is stable (sets sell fees to 5%)
    function removeLimits() external onlyAdmin returns (bool) {
        limitsInEffect = false;
        sellFees = 5;
        buyFees = 5;
        return true;
    }

    function excludeFromMaxTransaction(
        address addressToExclude,
        bool isExcluded
    ) public onlyAdmin {
        _isExcludedMaxTransactionAmount[addressToExclude] = isExcluded;
    }

    // only use to disable contract sales if absolutely necessary (emergency use only)
    function updateSwapEnabled(bool enabled) external onlyAdmin {
        swapEnabled = enabled;
    }

    function excludeFromFees(address account, bool excluded) public onlyAdmin {
        _isExcludedFromFees[account] = excluded;
    }

    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) public onlyAdmin {
        require(
            pair != uniswapV2Pair,
            "The pair cannot be removed from automatedMarketMakerPairs"
        );
        _setAutomatedMarketMakerPair(pair, value);
    }

    function setAdministrator(address admin, bool isAdmin) external onlyAdmin {
        administrators[admin] = isAdmin;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
    }

    function updateFeeWallet(
        address marketingWallet_,
        address devWallet_
    ) public onlyAdmin {
        devWallet = devWallet_;
        marketingWallet = marketingWallet_;
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (limitsInEffect) {
            if (
                !administrators[from] &&
                !administrators[to] &&
                to != address(0) &&
                to != address(0xdead) &&
                !swapping
            ) {
                if (!tradingActive) {
                    require(
                        _isExcludedFromFees[from] || _isExcludedFromFees[to],
                        "Trading is not enabled yet."
                    );
                }

                //when buy
                if (
                    automatedMarketMakerPairs[from] &&
                    !_isExcludedMaxTransactionAmount[to]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "Buy transfer amount exceeds the maxTransactionAmount."
                    );
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                }
                //when sell
                else if (
                    automatedMarketMakerPairs[to] &&
                    !_isExcludedMaxTransactionAmount[from]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "Sell transfer amount exceeds the maxTransactionAmount."
                    );
                } else if (!_isExcludedMaxTransactionAmount[to]) {
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        if (
            swapEnabled && //if this is true
            !swapping && //if this is false
            !automatedMarketMakerPairs[from] && //if this is false
            !_isExcludedFromFees[from] && //if this is false
            !_isExcludedFromFees[to] //if this is false
        ) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            // on sell
            if (automatedMarketMakerPairs[to] && sellFees > 0) {
                if (block.number - launchBlock <= 5){
                    fees = amount * 30 / 100;
                } else if (block.number - launchBlock <= 15) {
                    fees = amount * 15 / 100;
                } else {
                    fees = amount * (sellFees) / (100);
                }
            }
            // on buy
            else if (automatedMarketMakerPairs[from] && buyFees > 0) {
                if (block.number - launchBlock <= 5){
                    fees = amount * 30 / 100;
                } else if (block.number - launchBlock <= 15) {
                    fees = amount * 15 / 100;
                } else {
                    fees = amount * (buyFees) / (100);
                }
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }
            amount -= fees;
        }
        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    // Vault methods
    function distributeRewards(uint amount, address user) external onlyAdmin {
        _mint(user, amount);
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        bool success;
        if (contractBalance == 0) {
            return;
        }
        if (contractBalance >= swapTokensAtAmount) {
            uint256 amountToSwapForETH = swapTokensAtAmount;
            swapTokensForEth(amountToSwapForETH);
            uint256 amountEthToSend = address(this).balance;
            uint256 amountToMarketing = amountEthToSend
                * (marketingAmount)
                / (100);
            uint256 amountToDev = amountEthToSend - (amountToMarketing);
            (success, ) = address(marketingWallet).call{
                value: amountToMarketing
            }("");
            (success, ) = address(devWallet).call{value: amountToDev}("");
            emit SwapBackSuccess(amountToSwapForETH, amountEthToSend, success);
        }
    }
}
/*
    Website: https://doubledouble.fi/
    Telegram: https://t.me/doubledoublefi
    Twitter: https://twitter.com/DoubleDoubl_
*/

import "./utils/Context.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IERC20Metadata.sol";



contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
import "./IERC20.sol";

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
/*
    Website: https://doubledouble.fi/
    Telegram: https://t.me/doubledoublefi
    Twitter: https://twitter.com/DoubleDoubl_
*/

pragma solidity >=0.5.0;

interface IUniswapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
/*
    Website: https://doubledouble.fi/
    Telegram: https://t.me/doubledoublefi
    Twitter: https://twitter.com/DoubleDoubl_
*/

interface IUniswapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}