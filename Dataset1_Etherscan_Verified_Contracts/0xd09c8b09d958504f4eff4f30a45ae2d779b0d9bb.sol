// SPDX-License-Identifier: MIT

/*

ERC42069 Protocol 
 
0 decimal, 42069 tokens, endless burn. 
 
Website: https://erc42069protocol.xyz/ 
Telegram: https://t.me/Protocol42069 
X: https://x.com/42069ERC20

*/

pragma solidity ^0.8.20;

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

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function sync() external;
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
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
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

contract ERC42069 is ERC20, Ownable {
    IUniswapV2Router02 public immutable dexRouter;
    address public dexPair;
    address private marketingWallet;
    address public constant deadAddress = address(0xdead);

    uint256 public marketBuyFee = 35;
    uint256 public burnBuyFee = 0;
    uint256 public totalBuyFees = 35;

    uint256 public marketSellFee = 32;
    uint256 public burnSellFee = 3;
    uint256 public totalSellFees = 35;

    uint256 public maxTxnAmount = 420;
    uint256 public maxWalletAmount = 420;
    uint256 public swapTokensAtAmount = 20;
    uint256 public maxSwapTokens = 328;
    uint256 public lpBurnFrequency = 8 hours;
    uint256 public lastLpBurnTime;
    uint256 private launchedAt;
    uint256 public sellCounter;
    uint256 public sellAmountCounter;

    bool public limitsInEffect = true;
    bool public isTrading;
    bool private isSwapping;

    mapping(address => bool) public _isExcludedFromFees;
    mapping(address => bool) public _isExcludedFromMaxTxn;
    mapping(address => bool) public _isExcludedFromMaxWallet;
    mapping(uint256 => uint256) private swapInBlock;
    mapping(address => bool) public dexPairs;

    event AutoNukeLP();
    event ExcludeFromFees(address indexed account, bool exempt);
    event ExcludeFromMaxTxn(address indexed account, bool exempt);
    event ExcludeFromMaxWallet(address indexed account, bool exempt);
    event DexPairUpdated(address indexed pair, bool indexed value);
    event MarketingWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );

    constructor() ERC20("ERC42069 Protocol", "$42069", 0) {
        marketingWallet = address(0x93e174c3f3E470083321a0CD8b0599b84A3782c7);
        dexRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        dexPair = IUniswapV2Factory(dexRouter.factory()).createPair(
            address(this),
            dexRouter.WETH()
        );
        dexPairs[dexPair] = true;

        _isExcludedFromFees[address(dexRouter)] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[deadAddress] = true;

        _isExcludedFromMaxTxn[address(dexRouter)] = true;
        _isExcludedFromMaxTxn[address(this)] = true;
        _isExcludedFromMaxTxn[deadAddress] = true;
        _isExcludedFromMaxTxn[owner()] = true;

        _isExcludedFromMaxWallet[address(dexRouter)] = true;
        _isExcludedFromMaxWallet[address(this)] = true;
        _isExcludedFromMaxWallet[deadAddress] = true;
        _isExcludedFromMaxWallet[owner()] = true;
        _isExcludedFromMaxWallet[dexPair] = true;

        _mint(msg.sender, 42069);
    }

    receive() external payable {}

    function enableTrading() external onlyOwner {
        isTrading = true;
        launchedAt = block.number;
    }

    function removeLimits() external onlyOwner returns (bool) {
        limitsInEffect = false;
        return true;
    }

    function excludeFromFees(address account, bool exempt) public onlyOwner {
        _isExcludedFromFees[account] = exempt;
        emit ExcludeFromFees(account, exempt);
    }

    function excludeFromMaxTxn(address account, bool exempt) public onlyOwner {
        _isExcludedFromMaxTxn[account] = exempt;
        emit ExcludeFromMaxTxn(account, exempt);
    }

    function excludeFromMaxWallet(address account, bool exempt) public onlyOwner {
        _isExcludedFromMaxWallet[account] = exempt;
        emit ExcludeFromMaxWallet(account, exempt);
    }

    function updateMarketingWallet(
        address newWallet
    ) external onlyOwner {
        marketingWallet = newWallet;
        emit MarketingWalletUpdated(newWallet, marketingWallet);
    }

    function updateSwapBackSetting(
        uint256 swapAmount,
        uint256 maxSwap
    ) external onlyOwner {
        require(swapAmount >= 1 && maxSwap >= 1);
        swapTokensAtAmount = swapAmount;
        maxSwapTokens = maxSwap;
    }

    function updateBuyFees(
        uint256 _mrktFee,
        uint256 _burnFee
    ) external onlyOwner {
        marketBuyFee = _mrktFee;
        burnBuyFee = _burnFee;
        totalBuyFees = marketBuyFee + burnBuyFee;
        require(totalBuyFees <= 35);
    }

    function updateSellFees(
        uint256 _mrktFee,
        uint256 _burnFee
    ) external onlyOwner {
        marketSellFee = _mrktFee;
        burnSellFee = _burnFee;
        totalSellFees = marketSellFee + burnSellFee;
        require(totalSellFees <= 35);
    }

    function setDexPair(
        address pair,
        bool value
    ) public onlyOwner {
        require(
            pair != dexPair,
            "The pair cannot be removed from dexPairs"
        );
        dexPairs[pair] = value;
        emit DexPairUpdated(pair, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0,"ERC20: transfer amount is zero");

        if (limitsInEffect) {    
            if (
                from != owner() &&
                to != owner() &&
                !isSwapping
            ) {
                if (!isTrading) {
                    require(
                        _isExcludedFromFees[from] || _isExcludedFromFees[to],
                        "Trading is not active."
                    );
                }

                if (
                    !_isExcludedFromMaxTxn[from] &&
                    !_isExcludedFromMaxTxn[to]
                ) {
                    require(
                        amount <= maxTxnAmount,
                        "Amount exceeds the maxTxnAmount."
                    );
                }
                
                if (!_isExcludedFromMaxWallet[to]) {
                    require(
                        amount + balanceOf(to) <= maxWalletAmount,
                        "Max wallet exceeded"
                    );
                }
            }   
        } 

        uint256 blockNumber = block.number;
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            !isSwapping &&
            (swapInBlock[blockNumber] <= 2) &&
            !dexPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            isSwapping = true;

            swapBack();

            ++swapInBlock[blockNumber];

            isSwapping = false;
        }

        if (
            !isSwapping &&
            dexPairs[to] &&
            !_isExcludedFromFees[from]
        ) {
            autoBurnLp();
        }

        bool takeFee = !isSwapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        uint256 toMrkt = 0;
        uint256 toBurn = 0;
        if (takeFee) {
            if (dexPairs[to] && totalSellFees > 0) {
                fees = (amount * totalSellFees) / 100;
                toBurn = (fees * burnSellFee) / totalSellFees;
                toMrkt = fees - toBurn;
                uint256 lpBalance = balanceOf(dexPair);
                sellCounter++;
                if (toBurn == 0) {
                    if (
                        (lpBalance > 21034 && sellCounter >= 2) ||
                        (lpBalance > 10517 && sellCounter >= 4) ||
                        (lpBalance > 5258 && sellCounter >= 8) ||
                        (lpBalance > 2629 && sellCounter >= 16)
                    ) {
                        sellCounter = 0;
                        toBurn = 10;
                        fees += 10;
                    }
                }

                sellAmountCounter += amount;
            }else if (totalBuyFees > 0 && dexPairs[from]) {
                fees = (amount * totalBuyFees) / 100;
                toBurn = (fees * burnBuyFee) / totalBuyFees;
                toMrkt = fees - toBurn;
            }

            if (toMrkt > 0) {
                super._transfer(from, address(this), toMrkt);
            }

            if (toBurn > 0) {
                super._transfer(from, deadAddress, toBurn);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        bool success;

        if (contractBalance == 0) {
            return;
        }

        if (contractBalance > maxSwapTokens) {
            contractBalance = maxSwapTokens;
        }

        uint256 amountToSwapForETH = contractBalance;

        swapTokensForEth(amountToSwapForETH);

        (success, ) = address(marketingWallet).call{
            value: address(this).balance
        }("");
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function autoBurnLp() internal {
        uint256 liquidityPairBalance = balanceOf(dexPair);

        if (liquidityPairBalance > 2629) {
            if (sellAmountCounter < 10517) {
                if (block.timestamp < lastLpBurnTime + lpBurnFrequency) {
                    return;
                } else {
                    lastLpBurnTime = block.timestamp;
                }
            } else {
                sellAmountCounter = 0;
            }

            super._transfer(dexPair, deadAddress, 10);
            IUniswapV2Pair(dexPair).sync();
            emit AutoNukeLP();
        }
    }
}