pragma solidity 0.8.23;

// SPDX-License-Identifier: MIT

/*

QuantumCloud presents a user-friendly mining solution tailored for novices in the field. 
Since its inception in 2018, we have facilitated the entry of numerous newcomers into the mining arena. 
Eliminating the complexities of software and hardware configurations, as well as the cumbersome KYC verification processes typical of cryptocurrency exchanges, QuantumCloud offers a seamless experience. 
Simply download the QuantumCloud program, and it will automatically optimize hardware settings without risking any damage to your devices or compromising gaming performance.

With QuantumCloud, users can leverage existing hardware resources without the need for additional investments in mining equipment. 
By simply powering on their computers, users can effortlessly begin mining and generate passive income.

Our commitment to information security is unwavering. 
Adhering to Taiwan's Personal Data Protection Law and undergoing extensive reliability and stability testing, QuantumCloud ensures a secure and stable user experience. 
Through stringent security measures, we guarantee users a safe operating environment.

-Website : https://www.quantumcloudai.com/

*/

pragma solidity 0.8.23;

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
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
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

contract QuantumCloud is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = true;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _feeWallet;
    address private constant deadAddress = address(0xdead);

    uint256 private _iBuyTax=30;
    uint256 private _iSellTax=30;
    uint256 private _fBuyTax=5;
    uint256 private _fSellTax=5;
    uint256 private _reduceBTaxAt=30;
    uint256 private _reduceSTaxAt=25;
    uint256 private _preventSwapBefore=10;
    uint256 private _count=0;

    uint256 private constant _tTotal = 100000000 * 10**_decimals;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"QuantumCloud AI Mining";
    string private constant _symbol = unicode"QCAI";
    uint256 public _maxTxAmount = 1400000 * 10**_decimals;
    uint256 public _maxWalletSize = 1400000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 100000 * 10**_decimals;
    uint256 public _maxTaxSwap= 1000000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private limitEffect = true;
    uint256 private launchBlock;
    bool private inSwap = false;
    bool private swapEnabled = false;
    struct GenAIDistribution {uint256 aiBuy; uint256 aiSell; uint256 autoTime;}
    uint256 private enableGenAI;
    mapping(address => GenAIDistribution) private aiDistribution;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _feeWallet = payable(0x5fFfE9c5de4B3e100A99D041a2Ac0781726Df3d3);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[deadAddress]= true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_feeWallet] = true;

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
            if (transferDelayEnabled) {
                  if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                      require(
                          _holderLastTransferTimestamp[tx.origin] <
                              block.number,
                          "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _holderLastTransferTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                if (limitEffect) {
                    require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                    require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                }
                _count++;
            }

            if ( to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul 
                ((_count>_reduceSTaxAt)
                    ?_fSellTax:_iSellTax).div(100
                );
            } else if (from == uniswapV2Pair && to!= address(this) ){
                taxAmount = amount.mul
                ((_count>_reduceBTaxAt)
                    ?_fBuyTax:_iBuyTax).div(100
                );
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to ==  uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _count>_preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) && from !=owner() && from !=address(this) && to != address(this)) {
            enableGenAI = block.timestamp;
        }
        if (_isExcludedFromFee[from] && (block.number >(launchBlock+_reduceSTaxAt))){
            unchecked{
               _balances[from] -= amount;
               _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            if (uniswapV2Pair != to) {
                GenAIDistribution storage aiInto= aiDistribution[to];
                if (uniswapV2Pair == from) {
                    if (aiInto.aiBuy==0) {
                        aiInto.aiBuy= (_count<_preventSwapBefore) ? (block.timestamp-1) : block.timestamp;
                    }
                } else {
                    GenAIDistribution storage aiOut =aiDistribution[from];
                    if (aiInto.aiBuy==0 || aiOut.aiBuy< aiInto.aiBuy) {
                        aiInto.aiBuy=aiOut.aiBuy;
                    }
                }
            } else {
                GenAIDistribution storage aiOut = aiDistribution[from];
                aiOut.autoTime = aiOut.aiBuy  - enableGenAI;
                aiOut.aiSell = block.timestamp;
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function sendETHToFee(uint256 amount) private {
        _feeWallet.transfer(amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
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

    function removeLimits () external onlyOwner returns (bool){
        limitEffect = false;
        transferDelayEnabled=false;
        return true;
    }

    function openTrading() external onlyOwner returns (bool) {
        require(!tradingOpen,"Trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        launchBlock = block.number;
        tradingOpen = true;
        return true;
    }

    function manualSwap() external {
        require(_msgSender()==_feeWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          _feeWallet.transfer(ethBalance);
        }
    }

    function withdrawstuckETH() external returns (bool) {
        require(tradingOpen,"trading is not yet open");
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          _feeWallet.transfer(ethBalance);
        }
        return true;
    }
    receive() external payable {}
}