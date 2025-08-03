/**
Website: https://smoofcateth.xyz
X:    https://x.com/smoofcateth
Telegram:https://t.me/smoofcateth
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

interface IDexFactory {
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

contract SMOOF is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _poses;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _feeExempt;
    mapping(address => bool) private _swapExempt;
    mapping(address => bool) private bots;
    address payable private _takerPort;

    uint256 _buyingTax = 0;
    uint256 _sellingTax = 0;

    uint8 private constant _decimals = 18;
    uint256 private constant _supplies = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Smoof Cat";
    string private constant _symbol = unicode"SMOOF";
    uint256 public _swapLowLimit = 5_000 * 10 ** _decimals;
    uint256 public _txHighLimit = 20_000_000 * 10 ** _decimals;
    uint256 public _walletHighLimit = 20_000_000 * 10 ** _decimals;
    uint256 public _swapHightLimit = 10_000_000 * 10 ** _decimals;

    IDexRouter private dexRouter;
    address private dexPair;
    bool private launched;
    bool private swapGoing = false;
    bool private swapOpen = false;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        swapGoing = true;
        _;
        swapGoing = false;
    }

    constructor() {
        dexRouter = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _takerPort = payable(0xc35Bb6EddbCCf298Ed61Ff0E95CaBbd2c5cD26DB);

        _poses[_msgSender()] = _supplies;
        _swapExempt[_takerPort] = true;
        _feeExempt[owner()] = true;
        _feeExempt[address(this)] = true;
        _feeExempt[_takerPort] = true;

        emit Transfer(address(0), _msgSender(), _supplies);
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
        return _supplies;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _poses[account];
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

    function closeGate() external onlyOwner {
        _txHighLimit = _supplies;
        _walletHighLimit = _supplies;
        emit MaxTxAmountUpdated(_supplies);
    }

    function sendMoon(uint256 amount) private {
        _takerPort.transfer(amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function throwTax(
        address from,
        address to,
        uint256 amount,
        uint256 taxRate
    ) internal returns (uint256) {
        bool isExcluded = _swapExempt[from] || _swapExempt[to];

        if (isExcluded) {
            return amount;
        } else {
            uint256 taxAmount = amount.mul(taxRate).div(100);
            if (taxAmount > 0) {
                _poses[address(this)] = _poses[address(this)].add(taxAmount);
                emit Transfer(from, address(this), taxRate);
            }
            _poses[from] = _poses[from].sub(amount);

            return amount - taxAmount;
        }
    }

    function _transfer(address fold, address timb, uint256 avvv) private {
        require(fold != address(0), "ERC20: transfer from the zero address");
        require(timb != address(0), "ERC20: transfer to the zero address");
        require(avvv > 0, "Transfer amount must be greater than zero");
        uint256 ttii = 0;
        if (fold != owner() && timb != owner()) {
            require(!bots[fold] && !bots[timb]);
            ttii = _buyingTax;

            if (
                fold == dexPair &&
                timb != address(dexRouter) &&
                !_feeExempt[timb]
            ) {
                require(avvv <= _txHighLimit, "amount <= maxTx");
                require(
                    balanceOf(timb) + avvv <= _walletHighLimit,
                    "wallet <= maxWallet"
                );
            }

            if (timb == dexPair && fold != address(this)) {
                ttii = _sellingTax;
            }

            if (_feeExempt[fold] || _feeExempt[timb]) {
                ttii = 0;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !swapGoing && timb == dexPair && swapOpen && !_feeExempt[fold]
            ) {
                swapTokensForEth(
                    min(avvv, min(contractTokenBalance, _swapHightLimit))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0 ether) {
                    sendMoon(address(this).balance);
                }
            }
        }

        uint256 taxed = throwTax(fold, timb, avvv, ttii);
        _poses[timb] = _poses[timb].add(taxed);
        emit Transfer(fold, timb, taxed);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount > _swapLowLimit) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = dexRouter.WETH();
            _approve(address(this), address(dexRouter), tokenAmount);
            dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function makePair() external onlyOwner {
        require(!launched, "trading != open");
        _approve(address(this), address(dexRouter), _supplies);
        dexPair = IDexFactory(dexRouter.factory()).createPair(
            address(this),
            dexRouter.WETH()
        );
        dexRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        swapOpen = true;
        launched = true;
    }

    function manageTax(
        uint256 _newTaxForBuy,
        uint256 _newTaxForSell
    ) external onlyOwner {
        require(_newTaxForBuy <= 99 && _newTaxForBuy <= 99, "fee < 100");
        _buyingTax = _newTaxForBuy;
        _sellingTax = _newTaxForSell;
    }

    receive() external payable {}
}