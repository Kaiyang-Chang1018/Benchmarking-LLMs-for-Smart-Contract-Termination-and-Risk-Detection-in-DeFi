/* 

Important: SET SLIPPAGE RATE TO 3%  ! Otherwise transaction will not succeed. 
2% of $OCUS token swap amount is being reflected to marketing wallet 

Links to Socials: 
Website: https://theoctopus.zone/
Twitter: http://twitter.com/octopus_zone
Telegram: https://t.me/theoctopuszone
Discord: https://discord.com/invite/kM9yQtk4DC
Zealy airdrop: https://zealy.io/c/octopus-zone/

Tokenomics:
1 trillion total supply:

50% community airdrop (100% unlocked)
10% EM (Unlocked)
5% CEX Listing (Unlocked)
25% Periodic Burning
10% Team (7% locked for 1 year, 3% will be unlocked)

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

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
    event Burn(address indexed burner, uint256 value); 
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );
}

contract TheOctopusZone is Context, IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = "Octopus Zone";
    string private constant _symbol = "OCUS";
    uint8 private constant _decimals = 18;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 private _taxFeeOnSell = 2;
    

    // Original Fee
    
    uint256 private _taxFee = _taxFeeOnSell;
   

    // Define the fees as a percentage.
    uint256 public _marketingFee = 2;
    address payable private _marketingAddress = payable(0x121D256aD489F013713524B696732f66dFf1452b);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private inSwap = false;
    bool private swapEnabled = true;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
     function burn(uint256 amount) public {
      address burner = _msgSender();
      require(amount > 0, "Invalid amount");

       uint256 balance = balanceOf(burner);
      require(balance >= amount, "Insufficient balance");

      uint256 currentRate = _getRate();
      uint256 rAmount = amount.mul(currentRate);

      _rOwned[burner] = _rOwned[burner].sub(rAmount);
     _rTotal = _rTotal.sub(rAmount);

     emit Burn(burner, amount);
     emit Transfer(burner, address(0), amount);
}   



    constructor() {
        _rOwned[_msgSender()] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAddress] = true;

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
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(_rOwned[_msgSender()] >= amount, "Insufficient balance");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address

    spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(amount <= _allowances[sender][_msgSender()], "Amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));

        return true;
    }

    function tokenFromReflection(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

  

    function setFeePercent(uint256 marketingFee) external onlyOwner() {
        _marketingFee = marketingFee;
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

        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        uint256 marketingFeeAmount = amount.mul(_marketingFee).div(100);

        if (takeFee) {
            _tokenTransferWithFees(from, _marketingAddress, marketingFeeAmount);
            amount = amount.sub(marketingFeeAmount);
        }

        _tokenTransfer(from, to, amount);

        emit Transfer(from, to, amount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = amount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
    }

    function _tokenTransferWithFees(
        address sender,
        address recipient,
        uint256 marketingFeeAmount
    ) private {
        uint256 totalFeeAmount = marketingFeeAmount;
        uint256 currentRate = _getRate();
        uint256 rFeeAmount = totalFeeAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rFeeAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rFeeAmount);

        // Exclude reflection fee from token holders
        if (_isExcludedFromFee[sender]) {
            _tOwned[sender] = _tOwned[sender].sub(totalFeeAmount);
        }

        // Send fee to the marketing address
        if (marketingFeeAmount > 0) {
            _rOwned[_marketingAddress] = _rOwned[_marketingAddress].add(marketingFeeAmount.mul(currentRate));
            if (_isExcludedFromFee[_marketingAddress]) {
                _tOwned[_marketingAddress] = _tOwned[_marketingAddress].add(marketingFeeAmount);
            }
            emit Transfer(sender, _marketingAddress, marketingFeeAmount);
        }
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) {
            return (_rTotal, _tTotal);
        }
        return (rSupply, tSupply);
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

    function sendETHToFee(uint256 amount) private {
        (bool sent, ) = _marketingAddress.call{value: amount}("");
        require(sent, "Failed to send ETH to marketing address");
    }

    receive() external payable {}
}