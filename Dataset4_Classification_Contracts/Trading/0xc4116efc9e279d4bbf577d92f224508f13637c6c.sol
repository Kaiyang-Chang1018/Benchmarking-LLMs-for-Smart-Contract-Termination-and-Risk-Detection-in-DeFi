/*

DEVHUB - All in one tool-kit for blockchain builders ?

TG - https://t.me/devhub_project
Twitter - https://x.com/devhub_project
Website - https://devhub.biz/
Docs - https://docs.devhub.biz/
Discord - https://discord.gg/xnQybTZz
Medium - https://medium.com/@devhub-project

*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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
    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
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
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract DevHubAI is Context, IERC20, Ownable {
    string private constant _name = "DevHub AI";
    string private constant _symbol = "DHUB";

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _IsWalletExempted;
    mapping(address => uint256) private _IsBotWallet;
    uint256 private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 18;

    uint256 private InitialBlockNo;

    uint256 public buyTax = 25;
    uint256 public sellTax = 59;
    uint256 public txtax = 70;

    uint256 private constant _totalSupply = 100000000 * 10**_decimals;
    uint256 private constant onePercent = (_totalSupply)/100;
    uint256 private constant minimumSwapAmount = 40000;
    uint256 private maxSwap = onePercent*5/10;
    uint256 public MaxTX = onePercent*13/10;
    uint256 public MxWall = onePercent*13/10;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    address public DevWallet ;
    address public AdminWallet;
    address public OperationWallet;

    bool private launch = false;
    bool public CanAddBots = true;

    constructor() {
        AdminWallet  = 0x997163611a90978E8Ff55d35007c4d6Ff71C2625;
        DevWallet = 0x769877fa1efbD3Ad190606Ad3d1cD170A20F13Ab;
        OperationWallet = 0xA65f9623e21cB5c56a786Cbc3cc2Be75F5f1d5FB;
        _balance[msg.sender] = _totalSupply;
        _IsWalletExempted[DevWallet] = 1;
        _IsWalletExempted[msg.sender] = 1;
        _IsWalletExempted[address(this)] = 1;

        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if(currentAllowance != type(uint256).max) { 
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function OpenTrading() external onlyOwner {
        require(!launch,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        launch = true;
        InitialBlockNo = block.number;
    }

    function _ExemptTheWallet(address wallet) external onlyOwner {
        _IsWalletExempted[wallet] = 1;
    }

    function _RemoveWalletExemption(address wallet) external onlyOwner {
        _IsWalletExempted[wallet] = 0;
    }

    function changeTaxWallets(address _ad, address _de, address _op) external onlyOwner {
        DevWallet = _de;
        OperationWallet = _op;
        AdminWallet = _ad;
    }

    function AddBotWallet(address _wallet) external onlyOwner {
        require(CanAddBots, "Can't Add more bots now");
        require(_wallet != address(this) && _wallet != address(uniswapV2Pair) && _wallet != address(uniswapV2Router), "Invalid wallet");
        _IsBotWallet[_wallet] = 1;
    }

    function RemoveBotWllet(address _wallet) external onlyOwner {
        _IsBotWallet[_wallet] = 0;
    }

    function DisableAddBots() external onlyOwner {
        require(CanAddBots, "Already Disabled");
        CanAddBots = false;
    }

    function AddBotsInBulk(address[] memory _wallets) external onlyOwner {
        require(CanAddBots, "Can't Add more bots now");
        for (uint256 i = 0; i < _wallets.length; i++) {
            require(_wallets[i] != address(this) && _wallets[i] != address(uniswapV2Pair) && _wallets[i] != address(uniswapV2Router), "Invalid wallet");
            _IsBotWallet[_wallets[i]] = 1;
        }
    }

    function RemoveAllLimits() external onlyOwner {
        MaxTX = _totalSupply;
        MxWall = _totalSupply;
    }

    function ReduceTax(uint256 newBuyTax, uint256 newSellTax) external onlyOwner {
        require(newBuyTax <= buyTax && newSellTax <= sellTax, "Tax cannot be increased");
        buyTax = newBuyTax;
        sellTax = newSellTax;
    }

    function ReduceTransferTax(uint256 _txtax) external onlyOwner {
        require(_txtax <= txtax, "Tax cannot be increased");
        txtax = _txtax;
    }

    function ChangeSettings(uint256 newMaxSwapX10) external onlyOwner {
        require(newMaxSwapX10 <= 20, "can't be more than 2%");
        maxSwap = newMaxSwapX10*(onePercent/10);
    }

    function _tokenTransfer(address from, address to, uint256 amount, uint256 _tax) private {
        uint256 taxTokens = (amount * _tax) / 100;
        uint256 transferAmount = amount - taxTokens;

        _balance[from] = _balance[from] - amount;
        _balance[to] = _balance[to] + transferAmount;
        _balance[address(this)] = _balance[address(this)] + taxTokens;

        emit Transfer(from, to, transferAmount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "ERC20: no tokens transferred");
        uint256 _tax = 0;
        if (_IsWalletExempted[from] == 0 && _IsWalletExempted[to] == 0)
        {
            require(launch, "Trading not open");
            require(_IsBotWallet[from] == 0, "Please contact support");
            require(amount <= MaxTX, "MaxTx Enabled at launch");
            if (to != uniswapV2Pair && to != address(0xdead)) require(balanceOf(to) + amount <= MxWall, "MaxWallet Enabled at launch");
            if (block.number < InitialBlockNo + 3) {
                _tax = (from == uniswapV2Pair) ? buyTax : sellTax;
            } else {
                if (from == uniswapV2Pair) {
                    _tax = buyTax;
                } else if (to == uniswapV2Pair) {
                    uint256 tokensToSwap = balanceOf(address(this));
                    if (tokensToSwap > minimumSwapAmount) { 
                        uint256 mxSw = maxSwap;
                        if (tokensToSwap > amount) tokensToSwap = amount;
                        if (tokensToSwap > mxSw) tokensToSwap = mxSw;
                        swapTokensForEth(tokensToSwap);
                    }
                    _tax = sellTax;
                } else if (to != uniswapV2Pair && from != uniswapV2Pair) {
                    _tax = txtax;
                }
            }
        }
        _tokenTransfer(from, to, amount, _tax);
    }

    function WDeth() external onlyOwner {
        bool success;
        (success, ) = owner().call{value: address(this).balance}("");
    } 

    function ManualSwap(uint256 percent) external onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        uint256 amtswap = (percent*contractBalance)/100;
        swapTokensForEth(amtswap);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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
        bool success;
        uint256 devtax = address(this).balance *35/100;
        uint256 Admin = address(this).balance *33/100;
        uint256 stake = address(this).balance *32/100;

        (success, ) = OperationWallet.call{value: stake}("");
        (success, ) = AdminWallet.call{value: Admin}("");
        (success, ) = DevWallet.call{value: devtax}("");
    }
    receive() external payable {}
}