// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*

Memetic Virus (mVIRUS)

Meme: an element of a culture or system of behavior passed from one individual to another by imitation or other nongenetic means
Virus: something that poisons the mind or soul

Memetic discourse is the battlefield where ideas collide, and the battle for attention rages on. 
In a future where information spreads like slime mold, chaos prevails.
The memetic revolution is here, and we are its fervent disciples.

mVirus will be a vessel with which to spread the most potent elements of culture.

Tg: https://t.me/MemeticVirus

Launch taxes:

    5% liquidity
    5% marketing

Post Launch Taxes:

    0.5% liquidity
    0.5% marketing

Launch Limits:

    1% max transaction/max wallet

Post Launch Limits:

    No limits

*/

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address owner_) {
        _transferOwnership(owner_);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

}

interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);

}

interface IERC20Metadata is IERC20 {

    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function decimals() external view returns (uint8);

}

contract ERC20 is IERC20, IERC20Metadata {

    string private _symbol;
    string private _name;


    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount greater than allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from zero address");
        require(recipient != address(0), "ERC20: transfer to zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount greater than balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );
    function swapExactTokensForETHSupportingBloodPriceOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract MemeticVirus is ERC20, Ownable {

    address public hoarderOfTheSauce;
    address public memeticOverlord;

    uint256 public buyTotalBloodprice;
    uint256 public sellTotalBloodprice;

    uint256 public buyMarketingBloodPrice;
    uint256 public buyLiquidityBloodPrice;

    uint256 public sellMarketingBloodPrice;
    uint256 public sellLiquidityBloodPrice;

    uint256 public tokensForMemeticOverlord;
    uint256 public tokensForSauce;

    IUniswapV2Router02 public router;
    address public saucePool;

    mapping(address => bool) public isSaucePool;

    uint256 public maxTransactionAmount;
    uint256 public maxSauceBag;

    mapping(address => bool) private isExcludedFromBloodPrice;
    mapping(address => bool) public isExcludedFromSauceBagLimits;

    uint256 public bloodPriceDenominator = 1000;
    
    bool private swapping;
    bool public limitsInEffect = true;

    // 10%/10%
    uint256 maxSellBloodPrice = 100;
    uint256 maxBuyBloodPrice = 100;

    constructor(
        address router_,
        address hoarderOfTheSauce_,
        address memeticOverlord_
    ) ERC20("Memetic Virus", "mVIRUS") Ownable(msg.sender) {

        hoarderOfTheSauce = hoarderOfTheSauce_;
        memeticOverlord = memeticOverlord_;

        router = IUniswapV2Router02(router_);

        saucePool = IUniswapV2Factory(
            router.factory()
        ).createPair(
            address(this),
            router.WETH()
        );

        isSaucePool[saucePool] = true;

        isExcludedFromSauceBagLimits[address(saucePool)] = true;
        isExcludedFromSauceBagLimits[address(router)] = true;        
        isExcludedFromSauceBagLimits[address(this)] = true;
        isExcludedFromSauceBagLimits[address(0xdead)] = true;
        isExcludedFromSauceBagLimits[msg.sender] = true;
        isExcludedFromSauceBagLimits[hoarderOfTheSauce] = true;

        uint256 totalSupply = 1_000_000_000 * 1e18;
        
        buyMarketingBloodPrice = 5;
        buyLiquidityBloodPrice = 5;

        sellMarketingBloodPrice = 5;
        sellLiquidityBloodPrice = 5;

        buyTotalBloodprice = buyMarketingBloodPrice + buyLiquidityBloodPrice;
        sellTotalBloodprice = sellMarketingBloodPrice + sellLiquidityBloodPrice;

        isExcludedFromBloodPrice[address(0xdead)] = true;
        isExcludedFromBloodPrice[address(this)] = true;
        isExcludedFromBloodPrice[msg.sender] = true;
        isExcludedFromBloodPrice[hoarderOfTheSauce] = true;

        maxTransactionAmount = totalSupply / 100;
        maxSauceBag = totalSupply * 100;

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(msg.sender, totalSupply);
    }

    receive() external payable {}

    function setBuyBloodprice(uint256 marketingBloodPrice, uint256 liquidityBloodPrice) external onlyOwner {
        require(buyTotalBloodprice <= maxBuyBloodPrice);

        buyMarketingBloodPrice = marketingBloodPrice;
        buyLiquidityBloodPrice = liquidityBloodPrice;

        buyTotalBloodprice = buyMarketingBloodPrice + buyLiquidityBloodPrice;
    }

    function setSellBloodprice(uint256 marketingBloodPrice, uint256 liquidityBloodPrice) external onlyOwner {
        require(sellTotalBloodprice <= maxSellBloodPrice);
        sellMarketingBloodPrice = marketingBloodPrice;
        sellLiquidityBloodPrice = liquidityBloodPrice;

        sellTotalBloodprice = sellMarketingBloodPrice + sellLiquidityBloodPrice;
    }

    function setLimits(uint256 maxTransactionAmount_, uint256 maxSauceBag_) external onlyOwner {
        require(limitsInEffect);
        maxTransactionAmount = maxTransactionAmount_;
        maxSauceBag = maxSauceBag_;
    }

    function removeLimits() external onlyOwner {
        require(limitsInEffect);
        limitsInEffect = false;
        maxSauceBag = totalSupply();
        maxTransactionAmount = totalSupply();
    }

    function setHoarderOfTheSauce(address newHoarderOfTheSauce) external onlyOwner {
        require(hoarderOfTheSauce != newHoarderOfTheSauce);
        hoarderOfTheSauce = newHoarderOfTheSauce;
    }

    function setMemeticOverlord(address newMemeticOverlord) external onlyOwner {
        require(memeticOverlord != newMemeticOverlord);
        memeticOverlord = newMemeticOverlord;
    }

    function setSaucePool(address saucePoolAddress, bool isSaucePool_) external onlyOwner {
        isSaucePool[saucePoolAddress] = isSaucePool_;
    }

    function setSauceBagExcludedFromLimits(address saucebag, bool isExcluded) external onlyOwner {
        isExcludedFromSauceBagLimits[saucebag] = isExcluded;
    }

    function setSauceBagExcludedFromBloodprice(address saucebag, bool isExcluded) external onlyOwner {
        isExcludedFromBloodPrice[saucebag] = isExcluded;
    }

    function setRouter(address router_) external onlyOwner {
        router = IUniswapV2Router02(router_);
    }

    function setMainSaucePool(address mainSaucePoolAddress) external onlyOwner {
        saucePool = mainSaucePoolAddress;
    }

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

        if (limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0xdead) &&
                !swapping
            ) {

                if (
                    isSaucePool[from] &&
                    !isExcludedFromSauceBagLimits[to]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "!maxTransactionAmount."
                    );
                    require(
                        amount + balanceOf(to) <= maxSauceBag,
                        "!maxSauceBag"
                    );
                }

                else if (
                    isSaucePool[to] &&
                    !isExcludedFromSauceBagLimits[from]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "!maxTransactionAmount."
                    );
                } else if (!isExcludedFromSauceBagLimits[to]) {
                    require(
                        amount + balanceOf(to) <= maxSauceBag,
                        "!maxSauceBag"
                    );
                }

            }
        }

        if (
            !swapping &&
            to == saucePool &&
            !isExcludedFromBloodPrice[from] &&
            !isExcludedFromBloodPrice[to]
        ) {
            swapping = true;

            swapBack();

            swapping = false;
        }

        bool takeBloodPrice = !swapping;

        if (isExcludedFromBloodPrice[from] || isExcludedFromBloodPrice[to]) {
            takeBloodPrice = false;
        }

        if (takeBloodPrice) {

            uint256 bloodprice = 0;

            if (isSaucePool[to] && sellTotalBloodprice > 0) {
                uint256 newTokensForMemeticOverlord = amount * sellMarketingBloodPrice / bloodPriceDenominator;
                uint256 newTokensForSauce = amount * sellLiquidityBloodPrice / bloodPriceDenominator;

                bloodprice = newTokensForMemeticOverlord + newTokensForSauce;

                tokensForMemeticOverlord += newTokensForMemeticOverlord;
                tokensForSauce += newTokensForSauce;
            }

            else if (isSaucePool[from] && buyTotalBloodprice > 0) {
                uint256 newTokensForMemeticOverlord = amount * buyMarketingBloodPrice / bloodPriceDenominator;
                uint256 newTokensForSauce = amount * buyLiquidityBloodPrice / bloodPriceDenominator;

                bloodprice = newTokensForMemeticOverlord + newTokensForSauce;

                tokensForMemeticOverlord += newTokensForMemeticOverlord;
                tokensForSauce += newTokensForSauce;
            }

            if (bloodprice > 0) {
                super._transfer(from, address(this), bloodprice);
                amount -= bloodprice;
            }
        }

        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingBloodPriceOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() internal {
        if (tokensForSauce + tokensForMemeticOverlord == 0) {
            return;
        }

        uint256 liquidity = tokensForSauce / 2;
        uint256 amountToSwapForETH = tokensForMemeticOverlord + (tokensForSauce - liquidity);
        swapTokensForEth(amountToSwapForETH);

        uint256 ethForLiquidity = address(this).balance * (tokensForSauce - liquidity) / amountToSwapForETH;

        if (liquidity > 0 && ethForLiquidity > 0) {
            _addLiquidity(liquidity, ethForLiquidity);
        }

        uint256 remainingBalance = address(this).balance;

        if (remainingBalance > 0) {
            memeticOverlord.call{value: remainingBalance}("");    
        }

        tokensForSauce = 0;
        tokensForMemeticOverlord = 0;
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ethAmount} (
            address(this),
            tokenAmount,
            0,
            0,
            hoarderOfTheSauce,
            block.timestamp
        );
    }

}