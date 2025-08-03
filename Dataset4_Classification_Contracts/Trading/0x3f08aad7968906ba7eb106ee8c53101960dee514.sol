// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
Name: VistaArcade
Ticker: $VAR

✅Telegram: https://t.me/VistaArcade
?Twitter: https://x.com/VistaArcade
?Website: https://vistaarcade.com

**/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }


    function name() public view virtual override returns (string memory) {
        return _name;
    }


    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual override returns (uint8) {
        return 18;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {
        _approve(sender, _msgSender(), currentAllowance - amount);
    }

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

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[sender] = senderBalance - amount;
    }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
    }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface EtherVistaRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

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
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function usdcToEth(uint256 usdcAmount) external returns(uint256);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        uint deadline
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function launch(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        uint8 buyLpFee,
        uint8 sellLpFee,
        uint8 buyProtocolFee,
        uint8 sellProtocolFee,
        address protocolAddress
    ) external payable returns (
        uint amountToken,
        uint amountETH,
        uint liquidity
    );
}

interface EtherVistaFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function routerSetter() external view returns (address);
    function router() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setRouterSetter(address) external;
    function setRouter(address) external;
}

interface EtherVistaPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function setMetadata(string calldata website, string calldata image, string calldata description, string calldata chat, string calldata social) external;
    function websiteUrl() external view returns (string memory);
    function imageUrl() external view returns (string memory);
    function tokenDescription() external view returns (string memory);
    function chatUrl() external view returns (string memory);
    function socialUrl() external view returns (string memory);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function updateProvider(address user) external;
    function euler(uint) external view returns (uint256);
    function viewShare() external view returns (uint256 share);
    function claimShare() external;
    function poolBalance() external view returns (uint);
    function totalCollected() external view returns (uint);

    function setProtocol(address) external;
    function protocol() external view returns (address);
    function payableProtocol() external view returns (address payable origin);

    function creator() external view returns (address);
    function renounce() external;

    function setFees() external;
    function updateFees(uint8, uint8, uint8, uint8) external;
    function buyLpFee() external view returns (uint8);
    function sellLpFee() external view returns (uint8);
    function buyProtocolFee() external view returns (uint8);
    function sellProtocolFee() external view returns (uint8);
    function buyTotalFee() external view returns (uint8);
    function sellTotalFee() external view returns (uint8);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function first_mint(address to, uint8 buyLp, uint8 sellLp, uint8 buyProtocol, uint8 sellProtocol, address protocolAddress) external returns (uint liquidity);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address _token0, address _token1) external;
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }


    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}

contract VistaArcadeToken is ERC20, Ownable {
    using SafeMath for uint256;
    EtherVistaRouter private immutable etherVistaRouter;
    mapping(address => bool) private _isExcludedFromFees;
    address public immutable etherVistaPair;
    uint256 public amountPerMint = 888888;
    bool public tradingOpen = false;
    bool public mintOpen = false;
    uint256 public cap = 10 ether;
    address public vistaArcadeRewardsPool;
    uint256 public noDegenBuyTax = 1;
    uint256 public sellTax = 1;
    uint256 private _taxSwapThreshold;
    uint256 private _maxTaxSwap;
    bool public inSwap = false;
    bool public swapInFly = false;
    address _taxWallet;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address _etherVistaRouter,
        address _vistaArcadeRewardsPool,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        etherVistaRouter = EtherVistaRouter(_etherVistaRouter);
        etherVistaPair = EtherVistaFactory(etherVistaRouter.factory())
        .createPair(address(this), etherVistaRouter.WETH());
        vistaArcadeRewardsPool = _vistaArcadeRewardsPool;
        _taxWallet = msg.sender;
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(vistaArcadeRewardsPool, true);
    }

    receive() external payable {
        if (!tradingOpen && mintOpen) {
            mint();
        }
    }

    function mint() internal {
        require(msg.sender == tx.origin, "Cannot mint to contract.");
        require(msg.value == 0.1 ether, "Wrong mint value.");
        require(address(this).balance <= cap, "Maximum cap reached.");
        _mint(msg.sender, amountPerMint * 10 ** 18);
    }

    function excludeFromFees(address account, bool excluded) public {
        require(msg.sender == _taxWallet);
        _isExcludedFromFees[account] = excluded;
    }

    function setRewardsPool(address _vistaArcadeRewardsPool) public {
        require(msg.sender == _taxWallet);
        vistaArcadeRewardsPool = _vistaArcadeRewardsPool;
        excludeFromFees(vistaArcadeRewardsPool, true);
    }

    function removeTax() public {
        require(msg.sender == _taxWallet);
        noDegenBuyTax = 0;
        sellTax = 0;
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        uint256 taxAmount = 0;
        if (!_isExcludedFromFees[to] && !_isExcludedFromFees[from]) {
            require(tradingOpen, "trading not open yet");

            // Degen players save buy taxes
            if (from == etherVistaPair && to != address(vistaArcadeRewardsPool)) {
                taxAmount = amount.mul(noDegenBuyTax).div(100);
            }
            if (to == etherVistaPair) {
                taxAmount = amount.mul(sellTax).div(100);
            }
        }
        if (taxAmount > 0) {
            super._transfer(from, address(this), taxAmount);
            amount -= taxAmount;
        }
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (from != etherVistaPair && !inSwap && contractTokenBalance > _taxSwapThreshold) {
                if (swapInFly) {
                    swapTokensForEth(min(contractTokenBalance, _maxTaxSwap));
                } else {
                    super._transfer(address(this), _taxWallet, contractTokenBalance);
                }
            }
        }
        super._transfer(from, to, amount);
    }

    function start() external onlyOwner {
        _openTrading();
    }

    function toggleSwap() external {
        require(msg.sender == _taxWallet);
        swapInFly = !swapInFly;
    }

    function toggleMint() external {
        require(msg.sender == _taxWallet);
        mintOpen = !mintOpen;
    }

    function _openTrading() internal {
        require(!tradingOpen, "trading is already open");
        _approve(address(this), address(etherVistaRouter), type(uint256).max);
        uint256 liquidityToken = totalSupply() * 25 / 100;
        _mint(address(this), liquidityToken);
        tradingOpen = true;
        uint256 ethBalance = address(this).balance;
        uint256 liquidityEth = ethBalance * 25 / 100;
        uint256 rewardsPoolEth = ethBalance * 75 / 100;
        _taxSwapThreshold = totalSupply() * 5 / 10000;
        _maxTaxSwap = totalSupply() * 1 / 1000;
        (bool sentRewards,) = vistaArcadeRewardsPool.call{value: rewardsPoolEth}("");
        require(sentRewards, "Failed to add rewards pool");
        IERC20(etherVistaPair).approve(address(etherVistaRouter), type(uint).max);
        etherVistaRouter.launch{value : liquidityEth}(address(this), liquidityToken, 0, 0, 3, 3, 7, 7, owner());
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256){
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = etherVistaRouter.WETH();
        _approve(address(this), address(etherVistaRouter), tokenAmount);
        uint256 vistaSellFee = etherVistaRouter.usdcToEth(EtherVistaPair(etherVistaPair).sellTotalFee());
        etherVistaRouter.swapExactTokensForETHSupportingFeeOnTransferTokens{value: vistaSellFee}(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0.1 ether) {
            (bool sentRewards,) = vistaArcadeRewardsPool.call{value: ethBalance - 0.1 ether}("");
            require(sentRewards, "Failed to add rewards pool");
        }
    }

    function manualSwap() external payable {
        require(msg.sender == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
    }

    function execute(address target, uint256 value, bytes memory data) external returns (string memory){
        require(msg.sender == _taxWallet);
        (bool success, bytes memory ret) = target.call{value: value}(data);
        require(success, string(ret));
        return string(ret);
    }

    function ercTokenBalance(address token) public view returns(uint256 balance) {
        balance = IERC20(token).balanceOf(address(this));
    }

    function etherBalance() public view returns(uint256) {
        return address(this).balance;
    }

}