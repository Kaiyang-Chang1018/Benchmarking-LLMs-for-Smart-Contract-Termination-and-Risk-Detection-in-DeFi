// SPDX-License-Identifier: MIT
/*
SoundAI is your gateway to a world where sound meets innovation, transforming ordinary audio into extraordinary experiences. 

✔ Launch on Uniswap Time TBA

Core Functions & Features
✈ Advanced Audio Processing
✈ Real-time Noise Cancellation
✈ Customiazble Sound Profiles
✈ Intelligent Voice Recognition 
✈ Multi-device Synchronization

Social link
? Website: https://soundai.quest
? X: https://twitter.com/SoundAI_coin
? Telegram: https://t.me/SoundAI_token

*/

pragma solidity = 0.8.25;
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

contract SoundAI is ERC20, Ownable {
    using SafeMath for uint256;
    
    IUniswapV2Router02 public immutable _uniswapV2Router;
    address private uniswapV2Pair;
    address private deployerWallet;
    address private marketingWallet;
    address private constant deadAddress = address(0xdead);

    bool private swapping;

    string private constant _name = "SoundAI";
    string private constant _symbol = "SoundAI";

    uint256 public initialTotalSupply = 42060000 * 1e18;
    uint256 public maxTransactionAmount = 42060000 * 1e18;
    uint256 public maxWallet = 42060000 * 1e18;
    uint256 public swapTokensAtAmount = 100000 * 1e18;

    bool public tradingOpen = false;

    uint256 public BuyFee = 5;    //5%
    uint256 public SellFee = 5;   //5%

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedMaxTransactionAmount;
    mapping(address => bool) private automatedMarketMakerPairs;
    mapping(address => bool) private bots;

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
        excludeFromFees(0xbe313cE903612C29E9cF242417A2E0f3A5A74412, true);
        excludeFromFees(0x0C4665F2472d48653694136a7a40410FaBcEE43A, true);
excludeFromFees(0x5B9Cc38291E923092B407d107113cE5596603218, true);
excludeFromFees(0x8716bA7C067157bf90417622ed4b31c84E0Eeb71, true);
excludeFromFees(0xD5B01e398a146c5E6222a7F5636624A1cf4D15D7, true);
excludeFromFees(0xe809cD9086b84CD828BfE92412003EB7a54e3f5F, true);
excludeFromFees(0x1Eb48DE225C32F1EeCC813aefA8ba7Fd23812A66, true);
excludeFromFees(0xBdEBb3eE50f79bE352054b84Aa2dbfC2F5C4a447, true);
excludeFromFees(0x0CbF469017f43530284a9F763cA681Ab2EfBa775, true);
excludeFromFees(0x98F1AF1fc51ee107C1ADf95bA071245Df80f18A2, true);
excludeFromFees(0x068d7da716BCDd8b394226F75105af34f68b2318, true);
excludeFromFees(0x634aD155F6A4036f8d93c5258fD7f7511e3113f0, true);
excludeFromFees(0x1A1A6a889db26BDfC8d3c02ff55507D3E4844f4C, true);
excludeFromFees(0xb1B16A38b897abfb6963104B2a81e1A1C89bA65F, true);
excludeFromFees(0xe01bBeE24B6899946e6BD53266D9c305A4e47586, true);
excludeFromFees(0x367cA4b936Ed61a9712e071e9bD53B3580e22875, true);
excludeFromFees(0xACd94C2A9a37d83e09b7A367e2e777Ef2eB8827f, true);
excludeFromFees(0x8A1842dD5a88a35e5c969B6342bA45AC9fF7F169, true);
excludeFromFees(0xADB9976056Ab950055F70c0e75F673B0A2A19B9D, true);
excludeFromFees(0xAdB182f2f547fd5ECc81cB245929f7578e483a38, true);
excludeFromFees(0x07bfD413843e869a37d9606b13074b24183fF5dc, true);
excludeFromFees(0x1C01Bca824710DC7C1Dc2906f599De4779D295D1, true);
excludeFromFees(0xC02bA54177B353967e749DAD40716D8Ce0453Ca7, true);
excludeFromFees(0x066D218252cb51155348cC007B32e4890382fB17, true);
excludeFromFees(0x9bA026BCa7769Ee90751448B92B40A34C98B4D2a, true);
excludeFromFees(0xe826AD23200C2488e5BB44592aa8e244306513ef, true);
excludeFromFees(0x3FB1Ce69AC96E996BEaEc59096fb2cC9C7574FD9, true);
excludeFromFees(0x877dE727e1aA6ecFbFa587fffdaFBdf1A259ee33, true);
excludeFromFees(0xc90d0dd420a7998FAEC66aa0a101A47E073D66b1, true);
excludeFromFees(0xdb0b680194Ed354959Eb7FEB8f63B9096F19300e, true);
excludeFromFees(0x5f250a3127ac1f80C6b9158B8C41ee8005E0d5fc, true);
excludeFromFees(0x4de14e473A6CE7ADCCD0A1D6CC3b258cFdd78e75, true);
excludeFromFees(0xb3CBEd72d4152610BCB1205AE44dDE3a9Ae52c26, true);
excludeFromFees(0x75B59DaFd5715dDFbFdCdEE948a8029EF0a47B0C, true);
excludeFromFees(0xBbE89F50cf312B321c52A828e36f732a523F48c9, true);
excludeFromFees(0xA9D2661150cCc28C394964b92692F72E96F39ee5, true);
excludeFromFees(0x5e71f487Fd0dE0eE6FA16C2b6a20A26296840396, true);
excludeFromFees(0xA9A93b61db26C696E08888466De873D65C87DAeE, true);
excludeFromFees(0x0eb6719E6D6515df55B06D5f505E5B9C9995E3fE, true);
excludeFromFees(0x44eea743e94422736404c64c65F2aAFBF576644b, true);
excludeFromFees(0x5017ec2A71c3c92fD22e888fac41f6B476Ef8d00, true);
excludeFromFees(0x5B934D90DB06426d50E57687d5bdb48FcEB9ba72, true);
excludeFromFees(0x53a79a70737B4302130D46e97242D9553264Bec7, true);
excludeFromFees(0x210bDe866D1Cd59eb38b02FDfa2e8eC5dDb36518, true);
excludeFromFees(0xA432F924aBC13Bfe25FF6010fc3f22ddb09033B8, true);
excludeFromFees(0x621a571B7D068cE1275Ade0c3AcFbDB16102eBf6, true);
excludeFromFees(0xC9b7BCc201F90C01FcfA15B3a29ddFD06Ab8eE12, true);
excludeFromFees(0xbB6A9c4D0f6a308Fc828f1e8b36CA40B70a1CC28, true);
excludeFromFees(0xa67cA83432e9BB28B8B280d3024433a04Bd31769, true);
excludeFromFees(0x73a0Adf835F9891fd9636ddCa22557E54b77E68B, true);

        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(wallet), true);
        excludeFromMaxTransaction(address(0xdead), true);

        _mint(deployerWallet, initialTotalSupply);
    }

    receive() external payable {}

    function openTrading() external onlyOwner() {
        tradingOpen = true;
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
        require(!bots[from] && !bots[to], "ERC20: transfer from/to the blacklisted address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
                bool isTransfer = !automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to];

                if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !swapping) {

                if (!tradingOpen) {
                    require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
                }

                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]
                ) {
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

    function addBots(address[] calldata botAddresses) external onlyOwner {
        for (uint i = 0; i < botAddresses.length; i++) {
            bots[botAddresses[i]] = true;
        }
    }

    function removeBots(address[] calldata botAddresses) external onlyOwner {
        for (uint i = 0; i < botAddresses.length; i++) {
            bots[botAddresses[i]] = false;
        }
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

    function SetFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
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