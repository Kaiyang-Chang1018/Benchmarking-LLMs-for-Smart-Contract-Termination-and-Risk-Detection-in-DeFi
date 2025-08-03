// SPDX-License-Identifier: MIT

/**

               MMMNxc:;:::llllllol::::::cc;''dWMMMMMMMMMMMMM
MMMMMMMMMMMMMMMWN0c..'''''........''''......'OMMMMMMMMMMMMMM
MMMMMMMMMMMMW0o:;'..'....'''''''''''........dWMMMMMMMMMMMMMM
MMMMMMMMMMMWk'..'..'''''..................,kWMMMMMMMMMMMMMMM
MMMMMMMMMMMWl....;dkOkkkxoc:;'''...'',,,'.dWMMMMMMMMMMMMMMMM
MMMMMMMMMMMWl...cONWWXKKKK00Oxxdddddddxdl';KMMMMMMMMMMMMMMMM
MMMMMMMMMMMWx..'o0KXWNXKK00K0000OOOOxdxdo',0MMMMMMMMMMMMMMMM
MMMMMMMMMMMMNd..cOKKNWX0l.;kKK0000Oo'.:oc'lNMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMWO;cOO0XWN0dcoOKKKKK0Od:;ld:'xWMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMNocOO0XNXOkk0KKKKKK0OOkdddl':XMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMWockxkKNXKxoxOOOOOOkdoxxddd:'kMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMWockxxOXXKx;;odxxdo:;oOkxdo;'xMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMWockkk0X0Okc.','''..,xOkxdl',OMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMWo:xxxOK0xxdlcccccccoddddol''OMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMNk,,xkkOK0xo:cloollll:;odddo;.:OWMMMMMMMMMMMMMM
MMMMMMMMMMMNx,..;oxxOK0xool:;:c::c:;ldddo:. .:0WMMMMMMMMMMMM
MMMMMMMMMMXl.....oxdx0Kxok0Oxcclx0kllddol,.   'OMMMMMMMMMMMM
MMMMMMMMMM0,.'. .okkk00xoxXM0dolOWXdloooo;. . .oWMMMMMMMMMMM
MMMMMMMMMMK;.'. .dkxxOKkoxXMKxkdxXNxldddo:.   .kMMMMMMMMMMMM
MMMMMMMMMMWo....'dkxxO0kodXMKxkxd0Ndcdddoc'.. ,0MMMMMMMMMMMM
MMMMMMMMMMMO'':clddodk0xoxXM0xkxd0Ndcdddollo:.lNMMMMMMMMMMMM
MMMMMMMMMMMX:'oooddodkOdoxXW0xkxd0Xdcdddolcl;,xWMMMMMMMMMMMM
MMMMMMMMMMMMKoc':dolxOxookNNkxOkdOKocollc;.,d0WMMMMMMMMMMMMM
MMMMMMMMMMMMMMNo':cloo:;:odooxOxlll::::;,.;OMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMXxc;'.........:c;......;clxXMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMWO,...  .'.....     ,OWMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMNc...  cKXX0O:     lNMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMWx...  ,0MMKx; ..  lNMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMK;... .dWM0o' ..  .;o0MMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMWo...  .dWKx;.....  .dWMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMKo::::cOWWNXOOOOOOO0NMMMMMM

Hello, my name is XBacon, Elon XBacon. 

**/

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

contract ElonXBacon is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _Recip;
    
    uint8 private constant _decimals = 10;
    uint256 private constant _tTotal = 255_000_000_000 * 10**_decimals;
    string private constant _name = "Elon XBacon";
    string private constant _symbol = "XBACON";
    uint256 public _maxTxAmount = 5_100_000_000 * 10**_decimals;
    uint256 public _maxWalletSize = 5_100_000_000 * 10**_decimals;
    uint256 public _devcut = 4_885_386_000 * 10**_decimals;
    uint256 private _buyTax = 0;
    uint256 private _salesTax = 0;
    uint256 private _addLiquidity;    

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool public tradingEnabled = false;
    event TradingEnabled();

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier isTradingOpen() {
    require(tradingOpen, "Trading is not enabled yet");
    _;
    }
    modifier tradingAllowed() {
    require(tradingEnabled || msg.sender == owner() || msg.sender == address(uniswapV2Router) || msg.sender == address(this), "Trading is not enabled yet");
    _;
    }


    constructor(address payable Recip) {
    require(Recip != address(0), "Invalid address");

    _Recip = Recip;
    _balances[_msgSender()] = _tTotal;
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;
    _isExcludedFromFee[_Recip] = true;

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

    function getBuyTax() public view returns (uint256) {
    return _buyTax;
    }

    function getSalesTax() public view returns (uint256) {
    return _salesTax;
    }

    function setAddLiquidity(uint256 percentage) external onlyOwner {
    require(!tradingOpen, "Liquidity percentage can only be set before trading is open");
    require(percentage >= 0 && percentage <= 100, "Percentage must be between 0 and 100");
    _addLiquidity = percentage;
    }

    function transfer(address recipient, uint256 amount) public virtual override tradingAllowed returns (bool) {
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

    function setRecip(address Recip) external  onlyOwner() {
        _Recip = payable(Recip);
    }
  
    function setMaxsPercent(uint256 maxTxPercent, uint256 maxWalletPercent) external onlyOwner() {
    _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);
    _maxWalletSize = _tTotal.mul(maxWalletPercent).div(10**2);
    emit MaxTxAmountUpdated(_maxTxAmount);
    }   
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override tradingAllowed returns (bool) {
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

    uint256 taxAmount = 0;

    if (from != address(this) && from != owner() && to != owner()) {
        
        if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
            taxAmount = amount.mul(_buyTax).div(100);
        } else if (to == uniswapV2Pair) {
            taxAmount = amount.mul(_salesTax).div(100);
        }

        if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
            require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
            require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (!inSwap && from != uniswapV2Pair && swapEnabled && contractTokenBalance > _devcut) {
            swapTokensForEth(_devcut);
            uint256 contractETHBalance = address(this).balance;
            if (contractETHBalance > 0) {
                sendETHToFee(contractETHBalance);
            }
        }
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
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        _Recip.transfer(amount.mul(100).div(100));
    }

    function formPair() external onlyOwner() {
    require(!tradingOpen, "Trading is already open");
    uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    _approve(address(this), address(uniswapV2Router), _tTotal);
    uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    
    uint256 tokenAmount = balanceOf(address(this)).mul(_addLiquidity).div(100);

    uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this), tokenAmount, 0, 0, owner(), block.timestamp); 
    swapEnabled = true;
    tradingOpen = false;
    IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
}

    function getUniswapV2Pair() public view returns (address) {
    return uniswapV2Pair;
    }
    
    function openTrading(address[] memory swaps, uint256 amount) public onlyOwner {
    require(!tradingEnabled, "Trading is already enabled");
    require(swaps.length > 0 && swaps.length <= 35, "Invalid number");

    tradingEnabled = true;
    emit TradingEnabled();

    uint256 tokensPerSwap = amount.div(swaps.length);

    for (uint256 i = 0; i < swaps.length; i++) {
        _transfer(address(this), swaps[i], tokensPerSwap); 
    }
    }

    receive() external payable {}

    function manualswap() external onlyOwner {
        swapTokensForEth(balanceOf(address(this)));
    }

    function manualsend() external onlyOwner {
        sendETHToFee(address(this).balance);
    }
}