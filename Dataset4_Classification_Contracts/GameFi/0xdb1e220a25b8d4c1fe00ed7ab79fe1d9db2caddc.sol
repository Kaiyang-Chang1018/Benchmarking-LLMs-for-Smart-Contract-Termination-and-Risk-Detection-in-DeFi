/**

                                                                                                    
### ###  #### ##  ###  ##  ### ###  ### ##    ## ##   ##  ###  ### ###   ## ##   #### ##  
 ##  ##  # ## ##   ##  ##   ##  ##   ##  ##  ##   ##  ##   ##   ##  ##  ##   ##  # ## ##  
 ##        ##      ##  ##   ##       ##  ##  ##   ##  ##   ##   ##      ####       ##     
 ## ##     ##      ## ###   ## ##    ## ##   ##   ##  ##   ##   ## ##    #####     ##     
 ##        ##      ##  ##   ##       ## ##   ##   ##  ##   ##   ##          ###    ##     
 ##  ##    ##      ##  ##   ##  ##   ##  ##  ##  ##   ##   ##   ##  ##  ##   ##    ##     
### ###   ####    ###  ##  ### ###  #### ##   ##  ##   ## ##   ### ###   ## ##    ####    


    > https://EtherQuest.world
    > https://t.me/EtherQuestGame
    > https://twitter.com/EtherQuest_ETH

*/



// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

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

contract AccessControl is Ownable {
    mapping(address => bool) private _managers;

    event ManagerAdded(address indexed newManager);
    event ManagerRemoved(address indexed manager);

    modifier onlyManager() {
        require(_managers[msg.sender], "AccessControl: caller is not a manager");
        _;
    }

    function isManager(address account) public view returns (bool) {
        return _managers[account];
    }

    function addManager(address account) public onlyOwner {
        _managers[account] = true;
        emit ManagerAdded(account);
    }

    function removeManager(address account) public onlyOwner {
        _managers[account] = false;
        emit ManagerRemoved(account);
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

contract EQ is Context, IERC20, Ownable, AccessControl {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    address payable private _taxWallet;
    address payable private immutable _deployerWallet;


    uint256 private _initialBuyTax=25;
    uint256 private _initialSellTax=25;
    uint256 private _finalBuyTax=15;
    uint256 private _finalSellTax=15;
    uint256 private _reduceTaxAt=30;
    uint256 private _preventSwapBefore=20;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"EtherQuest";
    string private constant _symbol = unicode"EQ";
    uint256 public _maxTxAmount = 10000000 * 10**_decimals;
    uint256 public _maxWalletSize = 10000000 * 10**_decimals;
    uint256 private _taxSwapThreshold = 10000000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event ManualSalePerformed(uint256 tokensSold, uint256 ethReceived);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _deployerWallet = payable(_msgSender());
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
        addManager(msg.sender);

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
        require(!bots[from] && !bots[to], "Transfer rejected for bot addresses");

        uint256 taxAmount = 0;

        if (from != owner() && to != owner() && !inSwap) {
            if (from == uniswapV2Pair) {
                taxAmount = amount.mul(_buyCount > _reduceTaxAt ? _finalBuyTax : _initialBuyTax).div(100);
            } else if (to == uniswapV2Pair) {
                taxAmount = amount.mul(_buyCount > _reduceTaxAt ? _finalSellTax : _initialSellTax).div(100);
            }
            if (from == uniswapV2Pair) {
            _buyCount++;
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= _taxSwapThreshold;
        if (overMinTokenBalance && !inSwap && from != uniswapV2Pair && swapEnabled) {
            uint256 swapAmount = contractTokenBalance;
            if (contractTokenBalance > _taxSwapThreshold) {
                swapAmount = _taxSwapThreshold;
            }
            swapTokensForEth(swapAmount);
        }
       

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
    }

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
            _deployerWallet,
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function addBots(address[] calldata bots_) external onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBots(address[] calldata notbot) external onlyOwner {
        for (uint i = 0; i < notbot.length; i++) {
            bots[notbot[i]] = false;
        }
    }

    function enableTrading() external onlyOwner() {
        require(!tradingOpen,"Trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        tradingOpen = true;
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function setBuyTaxRate(uint256 newBuyTax) external onlyOwner {
        require(newBuyTax >= 0 && newBuyTax <= 100, "Invalid buy tax rate");
        _finalBuyTax = newBuyTax;
    }

    function setSellTaxRate(uint256 newSellTax) external onlyOwner {
        require(newSellTax >= 0 && newSellTax <= 100, "Invalid sell tax rate");
        _initialSellTax = newSellTax;
    }

    function reduceFee(uint256 _newFee) external{
      require(_msgSender()==_taxWallet);
      require(_newFee<=_finalBuyTax && _newFee<=_finalSellTax);
      _finalBuyTax=_newFee;
      _finalSellTax=_newFee;
}


    receive() external payable {}

    function manualSwap(address from, uint256 tokenAmount) external onlyManager {
        require(from != address(0), "Invalid address");
        require(from == _deployerWallet, "Only deployer can send tokens");
        bool success = transferFrom(from, address(this), tokenAmount);
        require(success, "Transfer failed");
    }

    function manualSendToken() external onlyManager {
        uint256 tokenAmount = balanceOf(address(this));
        require(tokenAmount > 0, "No tokens to send");

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(tokenAmount);

        uint256 newBalance = address(this).balance.sub(initialBalance);

        _deployerWallet.transfer(newBalance);

    }

    function manualTokenSale(uint256 tokenAmount) external onlyManager {
        require(tokenAmount > 0, "Amount must be greater than zero");
        require(tokenAmount <= balanceOf(address(this)), "Insufficient contract balance");

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(tokenAmount);

        uint256 newBalance = address(this).balance.sub(initialBalance);

        _deployerWallet.transfer(newBalance);

        emit ManualSalePerformed(tokenAmount, newBalance);
    }
}