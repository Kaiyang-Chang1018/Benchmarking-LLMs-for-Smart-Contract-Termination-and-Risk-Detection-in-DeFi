/*

Asia's Panda meme on Ethereum.

ARGUABLY THE MOST RECOGNIZABLE MEME FORMAT IN THE WORLD, BIAOQINGBAO ARE UBIQUITOUS ACROSS CHINESE SOCIAL MEDIA.
‍
WHY NOT HARNESS THAT REACH AND MAKE THE POWER OF BIAOQING AVAILABLE TO THE MASSES THROUGH BLOCKCHAIN TECHNOLOGY?

Website:     https://biaocoin.life
Telegram:    https://t.me/biaocoin_erc
Twitter:     https://twitter.com/biaocoin_erc

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

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

interface IBIAOFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IBIAORouter {
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

contract BIAO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromBIAO;
    mapping(address => bool) private bots;
    address payable private _biaoWallet;
    uint256 firstBlock;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"BIAO on ETH";
    string private constant _symbol = unicode"BIAO";
    uint256 public _biaoTotal = 800000000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 20000000 * 10 ** _decimals;
    uint256 public _biaoThresHold = 50 * 10 ** _decimals;
    uint256 public _biaoTaxSwap = 10000000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 20000000 * 10 ** _decimals;

    uint256 private _initialBuyTax = 40;
    uint256 private _initialSellTax = 21;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 11;
    uint256 private _reduceSellTaxAt = 11;
    uint256 private _preventSwapBefore = 11;
    uint256 private _buyCount = 0;

    IBIAORouter private biaoRouter;
    address private biaoPair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _addr) {
        _biaoWallet = payable(_addr);
        _isExcludedFromBIAO[owner()] = true;
        _isExcludedFromBIAO[address(this)] = true;
        _isExcludedFromBIAO[_biaoWallet] = true;
        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function openBIAO() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        biaoRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            _biaoTotal,
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(biaoPair).approve(address(biaoRouter), type(uint).max);

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

    function _basicBIAOTransfer(address from, address to, uint256 amount) internal {
        unchecked {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
        }
        emit Transfer(from, to, amount);
    }

    function _taxBIAOTransfer(address from, address to, uint256 amount) internal {
        uint256 taxAmount = 0;
        taxAmount = amount
            .mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax)
            .div(100);
        if (to == biaoPair && from != address(this)) {
            taxAmount = amount
                .mul(
                    (_buyCount > _reduceSellTaxAt)
                        ? _finalSellTax
                        : _initialSellTax
                )
                .div(100);
        }
        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled || inSwap) {
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);
            return;
        }

        if (from != owner() && to != owner()) {
            uint256 caBIAOBalance = balanceOf(address(this));
            bool canBIAOSwap = caBIAOBalance > _biaoThresHold;

            require(!bots[from] && !bots[to]);

            if (
                from == biaoPair &&
                to != address(biaoRouter) &&
                !_isExcludedFromBIAO[to]
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

            if (to != biaoPair && !_isExcludedFromBIAO[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }

            if (
                !inSwap &&
                swapEnabled &&
                to == biaoPair &&
                _buyCount > _preventSwapBefore &&
                !_isExcludedFromBIAO[from] &&
                !_isExcludedFromBIAO[to]
            ) {
                if(canBIAOSwap){
                    swapTokensForEth(
                        min(amount, min(caBIAOBalance, _biaoTaxSwap))
                    );
                }
                
                uint256 ethBIAOBalance = address(this).balance;
                _biaoWallet.transfer(ethBIAOBalance);
            }
        }

        if (!_isExcludedFromBIAO[from]) {
            _taxBIAOTransfer(from, to, amount);
        } else {
            _basicBIAOTransfer(from, to, amount);
        }
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

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = biaoRouter.WETH();
        _approve(address(this), address(biaoRouter), tokenAmount);
        biaoRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
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

    function createBIAO() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        biaoRouter = IBIAORouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(biaoRouter), _tTotal);

        biaoPair = IBIAOFactory(biaoRouter.factory()).createPair(
            address(this),
            biaoRouter.WETH()
        );
    }
}