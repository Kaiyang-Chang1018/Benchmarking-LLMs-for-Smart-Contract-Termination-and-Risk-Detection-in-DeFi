// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeSwapRouter02 {
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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract WRAPPED is IERC20, Context {

IPancakeSwapRouter02 public PCSRouter;
address public PCSPair;

mapping(address => uint256) private _balances;
mapping(address => mapping(address => uint256)) private _allowances;
mapping(address => bool) private automatedMarketMakerPairs;
mapping(address => bool) public isBlacklisted; 

uint256 private _totalSupply = 100_000_000_000_000 * 1e18;
string private _name = "WRAPPED";
string private _symbol = "$WRAP";

address public _owner;
address public marketingWallet;
uint256 public taxesBuy = 1;
uint256 public taxesSell = 1;
uint256 public taxesTransfer = 0;
uint256 public tokensForAutoSwap = _totalSupply / 5000; // 0.02% of total supply
address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Uniswap V2 mainnet
bool internal isInternalTransaction;
uint256 public launchedAt;
bool private tokenLaunched;

event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

constructor (address _marketingWallet) {
    IPancakeSwapRouter02 _PCSRouter = IPancakeSwapRouter02(router);
    address _PCSPair = IPancakeFactory(_PCSRouter.factory()).createPair(address(this), _PCSRouter.WETH());
    PCSRouter = _PCSRouter;
    PCSPair   = _PCSPair;
    automatedMarketMakerPairs[PCSPair] = true;
    _owner = msg.sender;
    marketingWallet = _marketingWallet;
    _balances[_owner] = _totalSupply;
    emit Transfer(address(0), _owner, _totalSupply);
}

modifier FastTx() {
    isInternalTransaction = true;
    _;
    isInternalTransaction = false;
}

// Ownable

function getOwner() public view returns(address) {
    return _owner;
}

modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
}

function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
}

function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
}

function setAutoSwapPercent(uint256 newPercent) public {
    require(msg.sender == _owner || msg.sender == marketingWallet, "Err.");
    require(newPercent >= 1 && newPercent <= 100, "Can be set between 0.01% and 1% of total supply.");
    tokensForAutoSwap = _totalSupply * newPercent / 10000;
}

function blackListAddress(address who) public onlyOwner {
    require(who != router && who != PCSPair, "Cannot blacklist router and pair.");
    isBlacklisted[who] = true;
}

function unBlacklistAddress(address who) public onlyOwner {
    isBlacklisted[who] = false;
}

function launch() public onlyOwner {
    require(!tokenLaunched, "Tokens is already launched.");
    tokenLaunched = true;
    launchedAt = block.number;
}

function rescueTokens(address tokenAddress) public {
    require(msg.sender == _owner || msg.sender == marketingWallet, "Err.");
    if(tokenAddress == address(0)) {
       payable(msg.sender).transfer(address(this).balance);
    } else {
        uint256 tokenBalances = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(msg.sender, tokenBalances);
    }
}

// ERC20 Standard

function decimals() public pure returns (uint8) {return 18;}
function name() public view returns (string memory) {return _name;}
function symbol() public view  returns (string memory) {return _symbol;}
function totalSupply() public view returns (uint256) {return _totalSupply;}
function balanceOf(address account) public view returns (uint256) {return _balances[account];}

function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
}

function allowance(address owner, address spender) public view returns (uint256) {
    return _allowances[owner][spender];
}

function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    uint256 currentAllowance = _allowances[sender][_msgSender()];
    if (currentAllowance != type(uint256).max) {
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
    }

    _transfer(sender, recipient, amount);

    return true;
}

function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
}

function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }
    return true;
}

function _approve(address owner, address spender, uint256 amount) internal virtual {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
}

function _transfer(address from, address to, uint256 amount) internal virtual {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "Cannot send 0 tokens.");
    require(!isBlacklisted[from], "Address is blacklisted.");

    if(!tokenLaunched) {
        require(from == _owner || from == marketingWallet || to == _owner || to == marketingWallet, "Token not launched yet.");
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        return;
    }
    
    if(!isInternalTransaction) {
        uint256 taxes;
        uint256 taxedAmount;
        uint256 transferAmount;
        uint256 contractBalances = balanceOf(address(this));

        if(contractBalances > 0 && contractBalances >= tokensForAutoSwap && automatedMarketMakerPairs[to]) {
            swapFees(tokensForAutoSwap);
        }

        if(automatedMarketMakerPairs[from]) {
            taxes = taxesBuy;
        } else if(automatedMarketMakerPairs[to]) {
            taxes = taxesSell;
        } else if(!automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to]) {
            taxes = taxesTransfer;
        }

        if(from == _owner || from == marketingWallet || to == _owner || to == marketingWallet) {
            taxes = 0;
        }

        taxedAmount = amount * taxes / 100;
        transferAmount = amount - taxedAmount;

        _balances[from] -= amount;
        _balances[to] += transferAmount;
        emit Transfer(from, to, transferAmount);

        if(taxedAmount > 0) {
            _balances[address(this)] += taxedAmount;
            emit Transfer(from, address(this), taxedAmount);
        }

    } else {
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }
    
}

function swapFees(uint256 tokenAmount) private FastTx {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = PCSRouter.WETH();
    _approve(address(this), address(PCSRouter), type(uint256).max);
    try PCSRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp) {} catch {}
    
    uint256 ethForMarketing = address(this).balance;

    if(ethForMarketing > 0) {
        bool success;
        (success, ) = marketingWallet.call{value: ethForMarketing}("");
    }
    
}

    receive() external payable {}
}