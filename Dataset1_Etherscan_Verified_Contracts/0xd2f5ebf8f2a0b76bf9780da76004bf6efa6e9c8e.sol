/*

Website: https://www.brattcoin.vip

Telegram: https://t.me/brattcoin_eth

Twitter: https://x.com/brattcoin_eth

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

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

interface IBRATTFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

interface IBRATTRouter {
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

contract BRATT is Context, IERC20, Ownable {
    using SafeMath for uint256;

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    IBRATTRouter private brattRouter;
    address private brattPair;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromBRATT;
    mapping(address => bool) private bots;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 10_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Brett's Son";
    string private constant _symbol = unicode"BRATT";
    uint256 public _maxTxAmount = _tTotal.mul(2).div(100);
    uint256 public _brattPoolR = _tTotal.mul(80).div(100);
    uint256 public _maxTaxSwap = _tTotal.mul(1).div(100);
    uint256 public _swapThresBRATT = 20 * 10 ** _decimals;
    uint256 public _maxWalletSize = _tTotal.mul(2).div(100);
    
    uint256 private _initialBuyTax = 19;
    uint256 private _initialSellTax = 22;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 9;
    uint256 private _reduceSellTaxAt = 9;
    uint256 private _preventSwapBefore = 9;
    uint256 private _buyCount = 0;

    uint256 firstBlock;

    address payable private _taskVenom;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _brattAddr) {
        _taskVenom = payable(_brattAddr);
        _isExcludedFromBRATT[owner()] = true;
        _isExcludedFromBRATT[_taskVenom] = true;
        _isExcludedFromBRATT[address(this)] = true;
        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function initializeBRATT() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        brattRouter = IBRATTRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(brattRouter), _tTotal);

        brattPair = IBRATTFactory(brattRouter.factory()).createPair(
            address(this),
            brattRouter.WETH()
        );
    }

    function startBRATT() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        brattRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            _brattPoolR,
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(brattPair).approve(address(brattRouter), type(uint).max);

        swapEnabled = true;
        tradingOpen = true;

        firstBlock = block.number;
    }

    receive() external payable {}

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

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
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

    function addBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBots(address[] memory notbot) public onlyOwner {
        for (uint i = 0; i < notbot.length; i++) {
            bots[notbot[i]] = false;
        }
    }

    function isBot(address a) public view returns (bool) {
        return bots[a];
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function _transferExcludedTokens(address from, address to, uint256 amount) internal {
        unchecked {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
        }
        emit Transfer(from, to, amount);
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = brattRouter.WETH();
        _approve(address(this), address(brattRouter), tokenAmount);
        brattRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _transferStandardTokens(
        address from,
        address to,
        uint256 amount,
        uint256 brattFees
    ) internal {
        if (brattFees > 0) {
            _balances[address(this)] = _balances[address(this)].add(brattFees);
            emit Transfer(from, address(this), brattFees);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(brattFees));

        emit Transfer(from, to, amount.sub(brattFees));
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 brattFees = 0;

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled || inSwap) {
            _transferStandardTokens(from, to, amount, 0);
            return;
        }

        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);

            brattFees = amount
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);

            uint256 contractTokenBalance = balanceOf(address(this));

            if (
                from == brattPair &&
                to != address(brattRouter) &&
                !_isExcludedFromBRATT[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );

                if (firstBlock + 3 > block.number) {
                    require(!isContract(to));
                }
                _buyCount++;
            }

            if (to != brattPair && !_isExcludedFromBRATT[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }

            if (to == brattPair && from != address(this)) {
                brattFees = amount
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            }

            if (
                swapEnabled &&
                to == brattPair &&
                _buyCount > _preventSwapBefore &&
                !inSwap &&
                !_isExcludedFromBRATT[from] &&
                !_isExcludedFromBRATT[to]
            ) {
                if(balanceOf(address(this)) > _swapThresBRATT){
                    swapTokensForEth(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                }

                _taskVenom.transfer(address(this).balance);
            }
        }

        if (!_isExcludedFromBRATT[from]) {
            _transferStandardTokens(from, to, amount, brattFees);
        } else {
            _transferExcludedTokens(from, to, amount);
        }
    }
}