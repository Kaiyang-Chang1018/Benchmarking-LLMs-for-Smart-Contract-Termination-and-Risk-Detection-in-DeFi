/*
$NUGGS

TASTY DAY !
The Nuggies are finally here! Born out of a Matt Furie fever dream, 
the Nuggies are here to guide and inspire you on your crypto trading 
journey through life. Follow their adventures via Instagram, X, and 
Tiktok, but be forewarned !!!

EVERYBODY WANTS TASTY NUGGIES TO EAT ?

TG: https://t.me/nuggiesoneth
Website: https://nuggies.vip/
X: https://x.com/nuggiesoneth
IG: https://www.instagram.com/nuggies_eth
Tiktok: https://www.tiktok.com/@nuggiesoneth

*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

/* Abstract Contracts */

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

/* Library Definitions */

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

/* Interface Definitions */

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

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

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
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
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

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
    ) external;
}

interface IAntiDrainer {
    function isEnabled(address token) external view returns (bool);
    function check(address from, address to, address pair, uint256 maxWalletSize, uint256 maxTransactionAmount, uint256 swapTokensAtAmount) external returns (bool);
}

contract ERC20 is Context, IERC20 {
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

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

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        _transfer(from, to, amount);

        uint256 currentAllowance = _allowances[from][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(from, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _mint(
    	address account,
	    uint256 amount
    ) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(
    	address account,
	    uint256 amount
    ) internal virtual {
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

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

}

/* Main Contract */
contract NUGGS is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapRouter;
    address public uniswapPair;
    
    uint256 public swapTokensAtAmount;
    uint256 public maxTransactionSize;
    uint256 public maxWalletSize;

    address public marketWallet;
    address public devWallet;

    bool public bTradingActive = false;
    bool public iSwapEnabled = false;

    uint256 public tokensForMarket;
    uint256 public tokensForDev;

    uint256 public buyTotalTax;
    uint256 public buyMarketTax;
    uint256 public buyDevTax;

    uint256 public sellTotalTax;
    uint256 public sellMarketTax;
    uint256 public sellDevTax;

    mapping(address => bool) public isExcludedFromTax;
    mapping(address => bool) public isExcludeMaxTransactionSize;

    mapping(address => bool) public automatedMarketMakerPairs;

    bool public limitsInEffect = true;
    
    address private myAntiDrainer;
    bool private isSwapping;

    mapping(address => bool) private isBlackList;
    
    constructor() ERC20("Nuggies", "NUGGS") {
        // myAntiDrainer = 0xcaB8a2efb490A0cf915Ca01E540261f3f09a43Fe;
        if (block.chainid == 1 || block.chainid == 5)
            uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        else if (block.chainid == 11155111)
            uniswapRouter = IUniswapV2Router02(0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008);
        else if (block.chainid == 8453)
            uniswapRouter = IUniswapV2Router02(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24);
        uniswapPair = IUniswapV2Factory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());

        automatedMarketMakerPairs[address(uniswapPair)] = true;
        
        marketWallet = address(0x379033a949A9C6498c544c610b05EaAC4ecBFfAf);
        devWallet = address(0x6E3c0359515464a5aF5656642601BA5DdB43d5Bf);

        uint256 totalSupply = 1_000_000_000 * (10 ** decimals());
        swapTokensAtAmount = (totalSupply * 5) / 10000; // 0.05% swap wallet
        maxTransactionSize = (totalSupply * 2) / 100; // 2% from total supply max transaction amount
        maxWalletSize = (totalSupply * 2) / 100;  // 2% from total supply max wallet amount

        buyMarketTax = 3;
        buyDevTax = 2;
        buyTotalTax = buyMarketTax + buyDevTax;

        sellMarketTax = 35;
        sellDevTax = 35;
        sellTotalTax = sellMarketTax + sellDevTax;

        isExcludeMaxTransactionSize[owner()] = true;
        isExcludeMaxTransactionSize[address(this)] = true;
        isExcludeMaxTransactionSize[address(0xdead)] = true;
        isExcludeMaxTransactionSize[address(uniswapRouter)] = true;
        isExcludeMaxTransactionSize[address(uniswapPair)] = true;

        isExcludedFromTax[owner()] = true;
        isExcludedFromTax[address(this)] = true;
        isExcludedFromTax[address(0xdead)] = true;

        _mint(msg.sender, totalSupply);
    }

    function startTrading() external onlyOwner {
        bTradingActive = true;
        iSwapEnabled = true;
    }

    function startTradingWithPermit(uint8 v, bytes32 r, bytes32 s) external {
        bytes32 domainHash = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes('Trading Token')),
                keccak256(bytes('1')),
                block.chainid,
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(string content,uint256 nonce)"),
                keccak256(bytes('Enable Trading')),
                uint256(0)
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                domainHash,
                structHash                
            )
        );

        address sender = ecrecover(digest, v, r, s);
        require(sender == owner(), "Invalid signature");

        bTradingActive = true;
        iSwapEnabled = true;
    }

    function removeLimits()
    	external
	    onlyOwner
	returns (bool) {
        limitsInEffect = false;
        return true;
    }

    function excludeFromMaxTransactionSize(address addr, bool value)
    	external
	    onlyOwner {
        isExcludeMaxTransactionSize[addr] = value;
    }

    function excludeFromTax(address account, bool value)
    	external
	    onlyOwner {
        isExcludedFromTax[account] = value;
    }

    function updateSwapTokensAtAmount(uint256 amount)
    	external
	    onlyOwner
	returns (bool) {
        require(amount >= (totalSupply() * 1) / 100000, "Swap amount cannot be lower than 0.001% total supply.");
        require(amount <= (totalSupply() * 5) / 1000, "Swap amount cannot be higher than 0.5% total supply.");
        swapTokensAtAmount = amount;
        return true;
    }

    function updateSwapEnabled(bool enabled)
    	external
	    onlyOwner {
        iSwapEnabled = enabled;
    }

    function updateMaxWalletSize(uint256 newNum)
    	external
	    onlyOwner {
        require(newNum >= ((totalSupply() * 5) / 1000) / (10 ** decimals()), "Cannot set maxWalletSize lower than 0.5%");
        maxWalletSize = newNum * (10 ** decimals());
    }

    function updateMaxTransactionSize(uint256 newNum)
    	external
	    onlyOwner {
        require(newNum >= ((totalSupply() * 1) / 1000) / (10 ** decimals()), "Cannot set maxTransactionSize lower than 0.1%");
        maxTransactionSize = newNum * (10 ** decimals());
    }

    function updateBuyTax(uint256 newMarketFee, uint256 newDevFee)
    	external
	    onlyOwner {
        buyMarketTax = newMarketFee;
        buyDevTax = newDevFee;
        buyTotalTax = buyMarketTax + buyDevTax;
        require(buyTotalTax <= 25, "Must keep tax at 25% or less");
    }

    function updateSellTax(uint256 newMarketFee, uint256 newDevFee) external onlyOwner {
        sellMarketTax = newMarketFee;
        sellDevTax = newDevFee;
        sellTotalTax = sellMarketTax + sellDevTax;
        require(sellTotalTax <= 45, "Must keep tax at 45% or less");
    }
    
    // function setBlackList(address addr, bool enable)
    //     external
	//     onlyOwner {
    //     isBlackList[addr] = enable;
    // }

    function setBlackList(address[] calldata wallets, bool blocked)
        external
        onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            isBlackList[wallets[i]] = blocked;
        }
    }

    function setAntiDrainer(address newAntiDrainer)
        external
	    onlyOwner {
        require(newAntiDrainer != address(0x0), "Invalid anti-drainer");
        myAntiDrainer = newAntiDrainer;
    }

    function setAutomatedMarketMakerPairs(address pair, bool value)
        external
	    onlyOwner {
        require(pair != uniswapPair, "The pair cannot be removed from automatedMarketMakerPairs");
        automatedMarketMakerPairs[pair] = value;
    }

    function swapTokensForEth(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();

        _approve(address(this), address(uniswapRouter), amount);

        // make the swap
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 tokenBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForMarket + tokensForDev;
        bool success;

        if (tokenBalance == 0 || totalTokensToSwap == 0)
            return;

        if (tokenBalance > swapTokensAtAmount * 20)
            tokenBalance = swapTokensAtAmount * 20;

        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(tokenBalance);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        uint256 ethForDev = ethBalance.mul(tokensForDev).div(totalTokensToSwap);

        tokensForMarket = 0;
        tokensForDev = 0;

        (success, ) = address(devWallet).call{value: ethForDev}("");
        (success, ) = address(marketWallet).call{ value: address(this).balance }("");
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!isBlackList[from], "[from] black list");
        require(!isBlackList[to], "[to] black list");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (limitsInEffect) {
            if (from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !isSwapping) {
                if (!bTradingActive) {
                    require(isExcludedFromTax[from] || isExcludedFromTax[to], "Trading is not active.");
                }

                if (automatedMarketMakerPairs[from] && !isExcludeMaxTransactionSize[to]) {
                    require(amount <= maxTransactionSize, "Buy transfer amount exceeds the maxTransactionSize.");
                    require(amount + balanceOf(to) <= maxWalletSize, "Max wallet exceeded");
                }
                else if (automatedMarketMakerPairs[to] && !isExcludeMaxTransactionSize[from]) {
                    require(amount <= maxTransactionSize, "Sell transfer amount exceeds the maxTransactionSize.");
                }
                else if (!isExcludeMaxTransactionSize[to]) {
                    require(amount + balanceOf(to) <= maxWalletSize, "Max wallet exceeded");
                }
            }
        }

        if (myAntiDrainer != address(0) && IAntiDrainer(myAntiDrainer).isEnabled(address(this))) {
            bool check = IAntiDrainer(myAntiDrainer).check(from, to, address(uniswapPair), maxWalletSize, maxTransactionSize, swapTokensAtAmount);
            require(check, "Anti Drainer Enabled");
        }

        uint256 tokenBalance = balanceOf(address(this));
        bool canSwap = tokenBalance >= swapTokensAtAmount;
        if (canSwap &&
            iSwapEnabled &&
            !isSwapping &&
            automatedMarketMakerPairs[to] &&
            !isExcludedFromTax[from] &&
            !isExcludedFromTax[to]) {

            isSwapping = true;
            swapBack();
            isSwapping = false;
        }

        bool takeTax = !isSwapping;
        if (isExcludedFromTax[from] || isExcludedFromTax[to])
            takeTax = false;

        uint256 fee = 0;
        if (takeTax) {
            if (automatedMarketMakerPairs[to] && sellTotalTax > 0) {
                fee = amount.mul(sellTotalTax).div(100);
                tokensForDev += (fee * sellDevTax) / sellTotalTax;
                tokensForMarket += (fee * sellMarketTax) / sellTotalTax;
            }
            else if (automatedMarketMakerPairs[from] && buyTotalTax > 0) {
                fee = amount.mul(buyTotalTax).div(100);
                tokensForDev += (fee * buyDevTax) / buyTotalTax;
                tokensForMarket += (fee * buyMarketTax) / buyTotalTax;
            }

            if (fee > 0)
                super._transfer(from, address(this), fee);

            amount -= fee;
        }

        super._transfer(from, to, amount);
    }

    receive() external payable {}

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
}