/*
 *
 * ██╗███╗░░██╗███████╗██╗███╗░░██╗██╗████████╗███████╗  ███╗░░░███╗░█████╗░███╗░░██╗███████╗██╗░░░██╗
 * ██║████╗░██║██╔════╝██║████╗░██║██║╚══██╔══╝██╔════╝  ████╗░████║██╔══██╗████╗░██║██╔════╝╚██╗░██╔╝
 * ██║██╔██╗██║█████╗░░██║██╔██╗██║██║░░░██║░░░█████╗░░  ██╔████╔██║██║░░██║██╔██╗██║█████╗░░░╚████╔╝░
 * ██║██║╚████║██╔══╝░░██║██║╚████║██║░░░██║░░░██╔══╝░░  ██║╚██╔╝██║██║░░██║██║╚████║██╔══╝░░░░╚██╔╝░░
 * ██║██║░╚███║██║░░░░░██║██║░╚███║██║░░░██║░░░███████╗  ██║░╚═╝░██║╚█████╔╝██║░╚███║███████╗░░░██║░░░
 * ╚═╝╚═╝░░╚══╝╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═╝░░░╚═╝░░░╚══════╝  ╚═╝░░░░░╚═╝░╚════╝░╚═╝░░╚══╝╚══════╝░░░╚═╝░░░
 * ░██████╗░██╗░░░░░██╗████████╗░█████╗░██╗░░██╗
 * ██╔════╝░██║░░░░░██║╚══██╔══╝██╔══██╗██║░░██║
 * ██║░░██╗░██║░░░░░██║░░░██║░░░██║░░╚═╝███████║
 * ██║░░╚██╗██║░░░░░██║░░░██║░░░██║░░██╗██╔══██║
 * ╚██████╔╝███████╗██║░░░██║░░░╚█████╔╝██║░░██║
 * ░╚═════╝░╚══════╝╚═╝░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝
 * Description: Infinite Money Glitch ($IMG) Official Token Contract
 *
 * Telegram: https://t.me/TheInfiniteMoneyGlitch
 * Twitter: https://x.com/MoneyGlitchERC
 * Website: https://www.theglitch.money
 */

// SPDX-License-Identifier:MIT

pragma solidity ^0.8.28;

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
    function balanceOf(address _account) external view returns (uint256);
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any _account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IDexSwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDexSwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IDexSwapRouter {
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

interface IREWARD {
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
}

contract IMG is Context, IERC20, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public immutable zeroAddress = 0x0000000000000000000000000000000000000000;
    address payable private _marketingWallet;
    address payable private _deployerWallet;

    struct FeeStruct {
        uint256 _marketingBuyTax;
        uint256 _rewardBuyTax;
        uint256 _marketingSellTax;
        uint256 _rewardSellTax;
    }
    FeeStruct public _runTax;

    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 69_420_420_420_420 * 10**_decimals;
    string private constant _name = unicode"Infinite Money Glitch";
    string private constant _symbol = unicode"IMG";
    uint256 public _maxTxAmount = _tTotal.mul(2).div(100);
    uint256 public _maxWalletSize = _tTotal.mul(2).div(100);
    uint256 public _taxSwapThreshold = _tTotal.mul(1).div(100);
    uint256 public _maxTaxSwap = _tTotal.mul(1).div(100);

    mapping (address => bool) public _isExcludedFromFee;
    mapping (address => bool) public isDividendExempt;

    uint256 private _launchedAt; 
    bool private Normalized;
    uint256 private _blockTaxReduction = 5 minutes;
    bool public swapEnabled;
    bool public openTrading; 

    IREWARD public rewardDividend;

    IDexSwapRouter public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwap;
    
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    constructor(address _taxWallet) {

        _deployerWallet = payable(_msgSender());
        _marketingWallet = payable(_taxWallet);

        IDexSwapRouter _dexRouter = IDexSwapRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        uniswapV2Pair = IDexSwapFactory(_dexRouter.factory()).createPair(
            address(this),
            _dexRouter.WETH()
        );

        uniswapV2Router = _dexRouter;

        _runTax = FeeStruct(5,0,15,0);

        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(uniswapV2Router)] = true;

        isDividendExempt[uniswapV2Pair] = true;
        isDividendExempt[_msgSender()] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[deadAddress] = true;
        isDividendExempt[zeroAddress] = true;
        isDividendExempt[address(uniswapV2Router)] = true;

        _balances[_msgSender()] = _tTotal;
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

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
      
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        else {

            if (!openTrading) {
                require(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient], "openTrading is not active.");
            }

            if (sender == uniswapV2Pair && !_isExcludedFromFee[recipient] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(recipient) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= _taxSwapThreshold;

            if (overMinimumTokenBalance && !inSwap && sender != uniswapV2Pair && swapEnabled) {                
                swapBack(min(amount, min(contractTokenBalance, _maxTaxSwap)));
            }
            
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            uint256 finalAmount = shouldNotTakeFee(sender,recipient) ? amount : takeFee(sender, recipient, amount);
            _balances[recipient] = _balances[recipient].add(finalAmount);

            if(!isDividendExempt[sender]){ try rewardDividend.setShare(sender, balanceOf(sender)) {} catch {} }
            if(!isDividendExempt[recipient]){ try rewardDividend.setShare(recipient, balanceOf(recipient)) {} catch {} }

            emit Transfer(sender, recipient, finalAmount);

        }

    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
        return (a>b)?b:a;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
    function shouldNotTakeFee(address sender, address recipient) internal view returns (bool) {
        if (sender == uniswapV2Pair || recipient == uniswapV2Pair ) {
            return false;
        }
        else if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            return true;
        }
        else {
            return true;
        }
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint feeAmount;
        uint marketing;
        uint reward;
        
        dynamicTax();

        unchecked {

            if(uniswapV2Pair == sender) { 
                marketing = amount.mul(_runTax._marketingBuyTax).div(100);
                reward = amount.mul(_runTax._rewardBuyTax).div(100);
                feeAmount = marketing.add(reward);
            }
            else if(uniswapV2Pair == recipient) {
                marketing = amount.mul(_runTax._marketingSellTax).div(100);
                reward = amount.mul(_runTax._rewardSellTax).div(100);
                feeAmount = marketing.add(reward);
            }
            
            if(feeAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(feeAmount);
                emit Transfer(sender, address(this), feeAmount);
            }

            return amount.sub(feeAmount);
        }
        
    }

    function dynamicTax() internal {
        if(Normalized) return;
        if (_launchedAt.add(_blockTaxReduction) >= block.timestamp) {
            _runTax = FeeStruct(5,0,15,0); 
        }
        else if (_launchedAt.add(_blockTaxReduction).add(_blockTaxReduction) >= block.timestamp) {
            _runTax = FeeStruct(5,0,5,0); 
        }
        else {
            _runTax = FeeStruct(1,2,1,2);
            Normalized = true;
        }
    }

    function setFees(uint _buyMarketing, uint _buyReward, uint _sellMarketing, uint _sellReward) 
        external 
        onlyOwner
    {
        _runTax._marketingBuyTax = _buyMarketing;
        _runTax._rewardBuyTax = _buyReward;
        _runTax._marketingSellTax = _sellMarketing;
        _runTax._rewardSellTax = _sellReward;
        require(_buyMarketing.add(_buyReward) <= 3, "MAX TAX 3%");
        require(_sellMarketing.add(_sellReward) <= 3, "MAX TAX 3%");
    }

    function swapBack(uint tokenAmount) internal swapping {

        uint256 marketingShare = _runTax._marketingBuyTax.add(_runTax._marketingSellTax);
        uint256 rewardShare = _runTax._rewardBuyTax.add(_runTax._rewardSellTax);
        uint256 totalShares = marketingShare.add(rewardShare);

        if(totalShares == 0) return;

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokenAmount);
        uint256 amountReceived = address(this).balance.sub(initialBalance);      

        uint amountETHMarketing = amountReceived.mul(marketingShare).div(totalShares);
        uint amountETHReward = amountReceived.sub(amountETHMarketing);  

        if(amountETHMarketing > 0) {
            _marketingWallet.transfer(amountETHMarketing);
        }

        if(amountETHReward > 0) {
            try rewardDividend.deposit { value: amountETHReward } () {} catch {}
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function enableTrade() external onlyOwner {
        require(!openTrading, "404");
        openTrading = true;
        swapEnabled = true;
        _launchedAt = block.timestamp;
    }

    function rescueFunds() external { 
        require(_msgSender() == _deployerWallet);
        (bool os,) = payable(msg.sender).call{value: address(this).balance}("");
        require(os,"Transaction Failed!!");
    }

    function rescueTokens(address _token,address recipient,uint _amount) external {
        require(_msgSender() == _deployerWallet);
        (bool success, ) = address(_token).call(abi.encodeWithSignature('transfer(address,uint256)',  recipient, _amount));
        require(success, 'Token payment failed');
    }

    function setMarketingWallet(address payable _newWallet) external onlyOwner {
        _marketingWallet = _newWallet;
    }

    function setRewardDividend(address _dividend) external onlyOwner {
        rewardDividend = IREWARD(_dividend); 
    }
    
    function setExcludeFromFee(address holder, bool exempt) 
        external 
        onlyOwner 
    {
        _isExcludedFromFee[holder] = exempt;
    }

    function setExcludeFromReward(address holder, bool exempt)
        external
        onlyOwner
    {
        if(exempt) {
            rewardDividend.setShare(holder,0);
        }
        else {
            rewardDividend.setShare(holder,balanceOf(holder));
        }
        isDividendExempt[holder] = exempt;
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
    }



}