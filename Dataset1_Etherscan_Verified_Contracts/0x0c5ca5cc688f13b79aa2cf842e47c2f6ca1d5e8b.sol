// SPDX-License-Identifier: MIT

/*
                     ..-+++++=::++++-.                      
                    .-********#*******:.                    
                  ..=***##*****########:.                   
                 ..=*************#******+..                 
                 .=*****###########***%###=..               
               ..=*****##*+**##*+*####%#**#:.               
             ..:+********##%@%#-..*#=%@%+.+:.               
             .:***********#*###*+*########=..               
           ...+*****************#*****##***:.               
           ..=********##%#****************##..              
           ..+*********###########******##%..               
        ...:**-************###############*.                
    ..:=+%@@@@=.+**************###########:.                
..:=#@@@@@@@@@@-.:+**********************-..                
*%@@@@@@@@@@@@@@*..:********************:..                 
@@@@@@@@@@@@@@@@@@=..:+**************#:..  ......           
@@@@@@@@@@@@@@@@@@@@+...*%#*******+@@@...-*****=..          
@@@@@@@@@@@@@@@@@@@@@@+*@@@@@@#-%@@@@@@@####*****+....      
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@###*##*****=..      
@@@@@@@@@@@@@@@@@@@@@@@@#*%+-#@@@@@@@@%***###***#***=..     
@@@@@@@@@@@@@@@@@@@@@@@%-....-@@@@@@@%*******###*****:.     
@@@@@@@@@@@@@@@@@@@@@@@@+....=@@@@#:-************#***-.     
@@@@@@@@@@@@@@@@@@@@@@@@+....=@@@:....:**********#***+.     
@@@@@@@@@@@@@@@@@@@@@@@%-.. .=@+.     ..=****#*******#+:.   
@@@@@@@@@@@@@@@@@@@@@@@%:...-@@@#..    ..+@@%..=*****#+:.   
@@@@@@@@@@@@@@@@@@@@@@@#..=@@@@@@@-.    ..=@@*...=#%#-::    
@@@@@@@@@@@@@@@@@@@@@@@%=%@@@@@@@@%-.   ...=@+.  ..==.=.    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%:. ..+@@@#:. ..==.#:    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%:.=@@@@@@@*..:=-=@.    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%++@#.    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#.    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%--%@@@@@@@@@@@@@@@+.    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*....*@@@@@@@@@@@@@@:       

*/

pragma solidity ^0.8.25;

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

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract C69 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000 * 10 ** _decimals;
    string private constant _name = unicode"Chain 69";
    string private constant _symbol = unicode"C69";
    uint256 public _maxTxAmount;
    uint256 public _maxWalletSize;

    uint constant MAX_GENS_START = 1000;
    uint public constant GEN_MIN = 1;
    uint public constant gen_max = MAX_GENS_START;
    uint public gen = MAX_GENS_START;
    uint public constant max_breed = 1000;
    mapping(address owner => uint) public counts;
    uint public breed_total_count;
    uint breed_id;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;

    uint background_color;
    uint body;
    uint body_color;
    uint facial_hair;
    uint facial_hair_color;
    uint shirt_1;
    uint shirt_1_color;
    uint shirt_2;
    uint shirt_2_color;
    uint shirt_3;
    uint shirt_3_color;
    uint nose;
    uint nose_color;
    uint mouth;
    uint mouth_color;
    uint eyes_base_color;
    uint eyes;
    uint eyes_color;
    uint hair;
    uint hair_color;
    uint hat;
    uint hat_color;
    uint accessories;
    uint accessories_color;
    uint mask;
    uint mask_color;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);

    constructor() {
        _balances[_msgSender()] = _tTotal;
        _maxTxAmount = 1200000 * 10 ** _decimals;
        _maxWalletSize = 1200000 * 10 ** _decimals;
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

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function getMaxTxAmount() public view returns (uint256) {
        return _maxTxAmount;
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
        if (from != owner() && to != owner()) {
            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            }

            if (to != uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            }
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

     function resetMaxTxAmount() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function getETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function getTokens(address _tokenAddr) external onlyOwner {
        uint256 tokenBalance = IERC20(_tokenAddr).balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to transfer");
        IERC20(_tokenAddr).transfer(owner(), tokenBalance);
    }

    function startTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint256).max);
        tradingOpen = true;
    }

     function setBackgroundColor(uint256 _background_color) public {
        background_color = _background_color;
    }

    function setBody(uint256 _body) public {
        body = _body;
    }

    function setBodyColor(uint256 _body_color) public {
        body_color = _body_color;
    }

    function setFacialHair(uint256 _facial_hair) public {
        facial_hair = _facial_hair;
    }

    function setFacialHairColor(uint256 _facial_hair_color) public {
        facial_hair_color = _facial_hair_color;
    }

    function setShirt1(uint256 _shirt_1) public {
        shirt_1 = _shirt_1;
    }

    function setShirt1Color(uint256 _shirt_1_color) public {
        shirt_1_color = _shirt_1_color;
    }

    function setShirt2(uint256 _shirt_2) public {
        shirt_2 = _shirt_2;
    }

    function setShirt2Color(uint256 _shirt_2_color) public {
        shirt_2_color = _shirt_2_color;
    }

    function setShirt3(uint256 _shirt_3) public {
        shirt_3 = _shirt_3;
    }

    function setShirt3Color(uint256 _shirt_3_color) public {
        shirt_3_color = _shirt_3_color;
    }

    function setNose(uint256 _nose) public {
        nose = _nose;
    }

    function setNoseColor(uint256 _nose_color) public {
        nose_color = _nose_color;
    }

    function setMouth(uint256 _mouth) public {
        mouth = _mouth;
    }

    function setMouthColor(uint256 _mouth_color) public {
        mouth_color = _mouth_color;
    }

    function setEyesBaseColor(uint256 _eyes_base_color) public {
        eyes_base_color = _eyes_base_color;
    }

    function setEyes(uint256 _eyes) public {
        eyes = _eyes;
    }

    function setEyesColor(uint256 _eyes_color) public {
        eyes_color = _eyes_color;
    }

    function setHair(uint256 _hair) public {
        hair = _hair;
    }

    function setHairColor(uint256 _hair_color) public {
        hair_color = _hair_color;
    }

    function setHat(uint256 _hat) public {
        hat = _hat;
    }

    function setHatColor(uint256 _hat_color) public {
        hat_color = _hat_color;
    }

    function setAccessories(uint256 _accessories) public {
        accessories = _accessories;
    }

    function setAccessoriesColor(uint256 _accessories_color) public {
        accessories_color = _accessories_color;
    }

    function setMask(uint256 _mask) public {
        mask = _mask;
    }

    function setMaskColor(uint256 _mask_color) public {
        mask_color = _mask_color;
    }

    receive() external payable {}
}