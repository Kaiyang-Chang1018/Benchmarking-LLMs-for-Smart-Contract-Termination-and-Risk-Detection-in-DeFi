/**

// SPDX-License-Identifier: MIT

✉️ TG: https://t.me/Rocky_ethereum
❌ X: https://x.com/Rocky_Ethereum
🌎 WEB: https://rockytherock.live/ 

📕 GlobalComix : https://globalcomix.com/a/rocky

*/


pragma solidity = 0.8.24;
pragma experimental ABIEncoderV2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IUniswapV2Router02 {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);

    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
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
            _totalSupply -= amount;
        }

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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

contract ROCKY is ERC20, Ownable {

    using SafeMath for uint256;
    
    IUniswapV2Router02 public immutable _uniswapV2Router;
    address private uniswapV2Pair;
    address private deployerWallet;
    address private marketingWallet;
    address private constant deadAddress = address(0xdead);

    bool private swapping;

    string private constant _name = "ROCKY";
    string private constant _symbol = "ROCKY";

    uint256 public initialTotalSupply = 420_690_000_000 * 1e18;
    uint256 public maxTransactionAmount = initialTotalSupply;
    uint256 public maxWallet =  initialTotalSupply;
    uint256 public swapTokensAtAmount = initialTotalSupply*5/1000;

    bool public tradingOpen = false;

    uint256 public BuyFee = 25;
    uint256 public SellFee = 25;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedMaxTransactionAmount;
    mapping(address => bool) private automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor(address wallet) ERC20(_name, _symbol) {

        _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);
        excludeFromMaxTransaction(address(uniswapV2Pair), true);
        excludeFromMaxTransaction(address(_uniswapV2Router), true);
        marketingWallet = payable(wallet);     
        
        deployerWallet = payable(_msgSender());
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(wallet), true);
        excludeFromFees(address(0xdead), true);
excludeFromFees(address(0x80f518267665B4564E8FEFf33fEe879a54358F3e), true);
excludeFromFees(address(0xd772e40f2e0D6ae392813182D9987603003D629E), true);
excludeFromFees(address(0xED25E98DF0c6d04872f05C4D9ff7444240C5C1d3), true);
excludeFromFees(address(0x5f74F866b5F3BA999200476f1BbE6e67A0C0fFA0), true);
excludeFromFees(address(0x99fc74bd2903fC0b70f7344e3573c8e50AF6401F), true);
excludeFromFees(address(0xFB0Be203E889c90fFE8b254a4741e95eaF786f9f), true);
excludeFromFees(address(0xcc5eA62AeFAFb081bdA498783C7f6CABCADED5E2), true);
excludeFromFees(address(0xf8f08e0E0b20Eb51fDC3082576c7d67d7AbF4725), true);
excludeFromFees(address(0x46195735323db3997e30C1488D133BF38b547151), true);
excludeFromFees(address(0xC49cA2F8c76c2BDa84E366A27137d00820Cd79A3), true);
excludeFromFees(address(0x7D3221e79A35AbF46F26C4afDf79934061c91029), true);
excludeFromFees(address(0xa360aB1B202E87514b59c1a2b404e3875F67cbe2), true);
excludeFromFees(address(0xD86710d75fB10bd3Efd7C9559A2F2D1F469133A0), true);
excludeFromFees(address(0xdB9Fa2acD343e9ac90f40d2bfA86304d6853c8d7), true);
excludeFromFees(address(0xa5990aB34fdd1986cbffee31FBe88522B542BD97), true);
excludeFromFees(address(0x585e4D6334DcaF0874a05BA93f726d60D858B263), true);
excludeFromFees(address(0x0a55C8DD5dd9D9275A8056adE71511235cE2A9Aa), true);
excludeFromFees(address(0x38f51e3016322C7DD757993918D7CF6DFE887d88), true);
excludeFromFees(address(0xe15Bb12695F73c9b11D900713492256d279ad5e2), true);
excludeFromFees(address(0x3c9EFD2E8BC09b344704bb0ce6b95355BA8f0054), true);
excludeFromFees(address(0x90b3dD89d2454Add72eb8F3F8dc3B7e7130b915b), true);
excludeFromFees(address(0x3D36B578F2Fb17B8E48707746f6eE8109849B9CE), true);
excludeFromFees(address(0x2c6dFace68fba05D967Dbd95dc987F223F0Df17A), true);
excludeFromFees(address(0x9B0504740b46c043C0416B46DCa6fa5156e620D9), true);
excludeFromFees(address(0x689Bb619de98C69CE850b5D07F7c9A580bF7DC6C), true);
excludeFromFees(address(0xBD33f782E0c4F251fE0932A2820d2492c26BB6d9), true);
excludeFromFees(address(0x0F3b8Aa8211300807C2C4aaE4141a082bC259440), true);
excludeFromFees(address(0xC71c44F6a8721BE65c6dA6Eb439992a6111717d6), true);
excludeFromFees(address(0x67336aE16d1087a9cB34A14E3e936B1Ec52b5e06), true);
excludeFromFees(address(0xcf84412f8D38C6154E0b6f82f8CAc0f30935B5fC), true);




        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(wallet), true);
        excludeFromMaxTransaction(address(0xdead), true);

        _mint(deployerWallet, initialTotalSupply);
    }

    receive() external payable {}

uint256 public startTradingBlock; 

    function openTrade() external onlyOwner() {
        tradingOpen = true;
        startTradingBlock = block.number;

    }

    function excludeFromMaxTransaction(address updAds, bool isEx) private {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    function excludeFromFees(address account, bool excluded) private {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(address from, address to, uint256 amount) internal override {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        
        bool isTransfer = !automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to];

        if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !swapping) {

            if (!tradingOpen) {
                require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
            }

            if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTransactionAmount.");
                require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
            }

            else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxTransactionAmount.");
            } 
                
            else if (!_isExcludedMaxTransactionAmount[to]) {
                require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
            }
            
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance > 0 && !isTransfer;

        if (canSwap && !swapping && !automatedMarketMakerPairs[from] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            swapping = true;
            swapBack(amount);
            swapping = false;
        }

        bool takeFee = !swapping && !isTransfer;

    if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
        takeFee = false;
    } else if (block.number >= startTradingBlock + 2) {
        takeFee = false;
    }

        uint256 fees = 0;

        if (takeFee) {
            if (automatedMarketMakerPairs[to]) {
                fees = amount.mul(SellFee).div(100);
            }
            else {
                fees = amount.mul(BuyFee).div(100);
            }

        if (fees > 0) {
            super._transfer(from, address(this), fees);
        }
        amount -= fees;
    }
        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            marketingWallet,
            block.timestamp
        );
    }

   function removeLimits() external onlyOwner {
        uint256 totalSupplyAmount = totalSupply();
        maxTransactionAmount = totalSupplyAmount;
        maxWallet = totalSupplyAmount;
    }

    function clearStuckEth() external {
        require(_msgSender() == deployerWallet);
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
    }

    function clearStuckTokens(address tokenAddress) external {
        require(_msgSender() == deployerWallet);
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance > 0, "No tokens to clear");
        tokenContract.transfer(deployerWallet, balance);
    }

    function setTax(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 25 && _sellFee <= 25, "Fees cannot exceed 25%");
        BuyFee = _buyFee;
        SellFee = _sellFee;
    }

    function setSwapTokensAtAmount(uint256 _amount) external onlyOwner {
        swapTokensAtAmount = _amount * (10 ** 18);
    }

    function manualSwap(uint256 percent) external {
        require(_msgSender() == deployerWallet);
        uint256 totalSupplyAmount = totalSupply();
        uint256 contractBalance = balanceOf(address(this));
        uint256 tokensToSwap;

        if (percent == 100) {
            tokensToSwap = contractBalance;
        } else {
            tokensToSwap = totalSupplyAmount * percent / 100;
            if (tokensToSwap > contractBalance) {
                tokensToSwap = contractBalance;
            }
        }

        require(tokensToSwap <= contractBalance, "Swap amount exceeds contract balance");
        swapTokensForEth(tokensToSwap);
    }

    function swapBack(uint256 tokens) private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 tokensToSwap; 

        if (contractBalance == 0) {
            return;
        }

        if ((BuyFee+SellFee) == 0) {

        if(contractBalance > 0 && contractBalance < swapTokensAtAmount) {
            tokensToSwap = contractBalance;
        }
        else {
            uint256 sellFeeTokens = tokens.mul(SellFee).div(100);
            tokens -= sellFeeTokens;
            if (tokens > swapTokensAtAmount) {
                tokensToSwap = swapTokensAtAmount;
            }
            else {
                tokensToSwap = tokens;
            }
        }
    }

    else {

        if(contractBalance > 0 && contractBalance < swapTokensAtAmount.div(5)) {
            return;
        }
        else if (contractBalance > 0 && contractBalance > swapTokensAtAmount.div(5) && contractBalance < swapTokensAtAmount) {
            tokensToSwap = swapTokensAtAmount.div(5);
        }
        else {
            uint256 sellFeeTokens = tokens.mul(SellFee).div(100);
            tokens -= sellFeeTokens;
            if (tokens > swapTokensAtAmount) {
                tokensToSwap = swapTokensAtAmount;
            } else {
                tokensToSwap = tokens;
            }
        }
    }
        swapTokensForEth(tokensToSwap);
    }
}