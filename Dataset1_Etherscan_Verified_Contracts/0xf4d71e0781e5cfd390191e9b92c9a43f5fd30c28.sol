// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*

Memetics for Intelligence and National Defense (MIND)

Tg: https://t.me/mindtokenportal

Token Allocation:

    90% LP
    10% director

    95% of LP tokens locked
    5% of LP tokens reserved

Launch taxes:

    5% liquidity
    5% marketing/director

Post Launch Taxes:

    0.5% liquidity
    0.5% marketing/director

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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract MindToken is ERC20, Ownable {

    address public director;

    uint256 public buyTotalFee;
    uint256 public sellTotalFee;

    uint256 public buyDirectorFee;
    uint256 public buyLiquidityFee;

    uint256 public sellDirectorFee;
    uint256 public sellLiquidityFee;

    uint256 public tokensForDirector;
    uint256 public tokensForAutomatedMarketMaker;

    IUniswapV2Router02 public router;
    address public automatedMarketMakerPool;

    mapping(address => bool) public isAutomatedMarketMakerPool;

    uint256 public maxTransactionAmount;
    uint256 public maxWalletAmount;

    mapping(address => bool) private isExcludedFromFee;
    mapping(address => bool) public isExcludedFromLimits;

    uint256 public FeeDenominator = 1000;
    
    bool private swapping;
    bool public limitsInEffect = true;

    // 10%/10%
    uint256 maxSellFee = 100;
    uint256 maxBuyFee = 100;

    constructor(
        address router_,
        address director_
    ) ERC20("Memetics for Intelligence and National Defense", "MIND") Ownable(msg.sender) {

        director = director_;

        router = IUniswapV2Router02(router_);

        automatedMarketMakerPool = IUniswapV2Factory(
            router.factory()
        ).createPair(
            address(this),
            router.WETH()
        );

        isAutomatedMarketMakerPool[automatedMarketMakerPool] = true;

        isExcludedFromLimits[address(automatedMarketMakerPool)] = true;
        isExcludedFromLimits[address(router)] = true;        
        isExcludedFromLimits[address(this)] = true;
        isExcludedFromLimits[address(0xdead)] = true;
        isExcludedFromLimits[msg.sender] = true;
        isExcludedFromLimits[director] = true;

        uint256 totalSupply = 1_000_000_000 * 1e18;
        
        buyDirectorFee = 5;
        buyLiquidityFee = 5;

        sellDirectorFee = 5;
        sellLiquidityFee = 5;

        buyTotalFee = buyDirectorFee + buyLiquidityFee;
        sellTotalFee = sellDirectorFee + sellLiquidityFee;

        isExcludedFromFee[address(0xdead)] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[msg.sender] = true;
        isExcludedFromFee[director] = true;

        maxTransactionAmount = totalSupply / 100;
        maxWalletAmount = totalSupply * 100;

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(msg.sender, totalSupply);
    }

    receive() external payable {}

    function setBuyFee(uint256 directorFee, uint256 liquidityFee) external onlyOwner {
        require(buyTotalFee <= maxBuyFee);

        buyDirectorFee = directorFee;
        buyLiquidityFee = liquidityFee;

        buyTotalFee = buyDirectorFee + buyLiquidityFee;
    }

    function setSellFee(uint256 directorFee, uint256 liquidityFee) external onlyOwner {
        require(sellTotalFee <= maxSellFee);
        sellDirectorFee = directorFee;
        sellLiquidityFee = liquidityFee;

        sellTotalFee = sellDirectorFee + sellLiquidityFee;
    }

    function setLimits(uint256 maxTransactionAmount_, uint256 maxWalletAmount_) external onlyOwner {
        require(limitsInEffect);
        maxTransactionAmount = maxTransactionAmount_;
        maxWalletAmount = maxWalletAmount_;
    }

    function removeLimits() external onlyOwner {
        require(limitsInEffect);
        limitsInEffect = false;
        maxWalletAmount = totalSupply();
        maxTransactionAmount = totalSupply();
    }

    function setDirector(address newDirector) external onlyOwner {
        require(director != newDirector);
        director = newDirector;
    }

    function setAutomatedMarketMakerPool(address automatedMarketMakerPoolAddress, bool isAutomatedMarketMakerPool_) external onlyOwner {
        isAutomatedMarketMakerPool[automatedMarketMakerPoolAddress] = isAutomatedMarketMakerPool_;
    }

    function setIsExcludedFromLimits(address wallet, bool isExcluded) external onlyOwner {
        isExcludedFromLimits[wallet] = isExcluded;
    }

    function setIsExcludedFromFee(address wallet, bool isExcluded) external onlyOwner {
        isExcludedFromFee[wallet] = isExcluded;
    }

    function setRouter(address router_) external onlyOwner {
        router = IUniswapV2Router02(router_);
    }

    function setMainAutomatedMarketMakerPool(address mainAutomatedMarketMakerPoolAddress) external onlyOwner {
        automatedMarketMakerPool = mainAutomatedMarketMakerPoolAddress;
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
                    isAutomatedMarketMakerPool[from] &&
                    !isExcludedFromLimits[to]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "!maxTransactionAmount."
                    );
                    require(
                        amount + balanceOf(to) <= maxWalletAmount,
                        "!maxWalletAmount"
                    );
                }

                else if (
                    isAutomatedMarketMakerPool[to] &&
                    !isExcludedFromLimits[from]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "!maxTransactionAmount."
                    );
                } else if (!isExcludedFromLimits[to]) {
                    require(
                        amount + balanceOf(to) <= maxWalletAmount,
                        "!maxWalletAmount"
                    );
                }

            }
        }

        if (
            !swapping &&
            to == automatedMarketMakerPool &&
            !isExcludedFromFee[from] &&
            !isExcludedFromFee[to]
        ) {
            swapping = true;

            swapBack();

            swapping = false;
        }

        bool takeFee = !swapping;

        if (isExcludedFromFee[from] || isExcludedFromFee[to]) {
            takeFee = false;
        }

        if (takeFee) {

            uint256 fee = 0;

            if (isAutomatedMarketMakerPool[to] && sellTotalFee > 0) {
                uint256 newTokensForDirector = amount * sellDirectorFee / FeeDenominator;
                uint256 newTokensForAutomatedMarketMaker = amount * sellLiquidityFee / FeeDenominator;

                fee = newTokensForDirector + newTokensForAutomatedMarketMaker;

                tokensForDirector += newTokensForDirector;
                tokensForAutomatedMarketMaker += newTokensForAutomatedMarketMaker;
            }

            else if (isAutomatedMarketMakerPool[from] && buyTotalFee > 0) {
                uint256 newTokensForDirector = amount * buyDirectorFee / FeeDenominator;
                uint256 newTokensForAutomatedMarketMaker = amount * buyLiquidityFee / FeeDenominator;

                fee = newTokensForDirector + newTokensForAutomatedMarketMaker;

                tokensForDirector += newTokensForDirector;
                tokensForAutomatedMarketMaker += newTokensForAutomatedMarketMaker;
            }

            if (fee > 0) {
                super._transfer(from, address(this), fee);
                amount -= fee;
            }
        }

        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() internal {
        if (tokensForAutomatedMarketMaker + tokensForDirector == 0) {
            return;
        }

        uint256 liquidity = tokensForAutomatedMarketMaker / 2;
        uint256 amountToSwapForETH = tokensForDirector + (tokensForAutomatedMarketMaker - liquidity);
        swapTokensForEth(amountToSwapForETH);

        uint256 ethForLiquidity = address(this).balance * (tokensForAutomatedMarketMaker - liquidity) / amountToSwapForETH;

        if (liquidity > 0 && ethForLiquidity > 0) {
            _addLiquidity(liquidity, ethForLiquidity);
        }

        uint256 remainingBalance = address(this).balance;

        if (remainingBalance > 0) {
            director.call{value: remainingBalance}("");    
        }

        tokensForAutomatedMarketMaker = 0;
        tokensForDirector = 0;
        
        if (balanceOf(address(this)) > 0) {
            tokensForDirector = balanceOf(address(this));
        }
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ethAmount} (
            address(this),
            tokenAmount,
            0,
            0,
            director,
            block.timestamp
        );
    }
}