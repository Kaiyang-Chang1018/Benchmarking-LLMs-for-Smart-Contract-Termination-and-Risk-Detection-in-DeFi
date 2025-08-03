/*

# Sky Raiders | Relaunch

Long ago, in 2040, Earth was nearly destroyed by meteors, forcing humans to escape to Mars.
Now, in 3169, you return as a Sky Raider, looking for signs of life.
However, when you arrive, the planet is quiet and empty.
Cities are in ruins, but something feels off.
The mystery of what happened after humans left is waiting for you to uncover.

# Explore, Craft, Battle, Conquer & Survive

Begin your saga in an expansive open-world, third-person RPG.
Explore, craft, build, battle or trade your way to glory.
Explore the ruins of Earth alone or with friends, battling enemies in PvP or PvE.
Take part in events for valuable rewards or trade items with other players using $SKY tokens in the marketplace.
Survival isn’t guaranteed, but the adventure is yours to create.

# Links

Play Online: https://skyraiders.app
Docs: https://docs.skyraiders.app
Telegram: https://t.me/skyraiders_game
YouTube:  https://www.youtube.com/@skyraiders_game
X: https://x.com/skyraiders_game

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

contract SKY is Context, IERC20, Ownable {
    string private constant _name = "Sky Raiders";
    string private constant _symbol = "SKY";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 216_000_000 ether;

    uint256 public _maxTransactionAmount = _totalSupply;
    uint256 public _maxWalletSize = _totalSupply;

    uint256 public _taxTrigger = 100_000 ether;
    uint256 public _taxThreshold = 100_000 ether;
    uint256 public _taxMaxSwap = 1_000_000 ether;

    uint256 public _buyTax = 5;
    uint256 public _sellTax = 5;

    uint256 private _accumulatedTax;

    bool public didLaunch = false;
    bool public tradingEnabled = false;
    bool public liquifyEnabled = false;
    bool private inSwap = false;

    address payable public _marketingWallet;
    address payable public _gameWallet;
    address payable public _deployerWallet;
 
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private uniswapV2Pair;
    IUniswapV2Router02 private uniswapV2Router;

    event Log(string, uint256);
    event AuditLog(string, address);
    event LaunchExecuted(uint256 tokenAmount, uint256 ethAmount, uint256 timestamp);
    event TradingEnabled(bool _tradingEnabled);
    event LiquidityAdded(uint256 tokenAmount, uint256 ethAmount);
    event SetTaxParameters(uint256 taxTrigger, uint256 taxThreshold);
    event MarketingWalletUpdated(address indexed oldAddress, address indexed newAddress);
    event GameWalletUpdated(address indexed oldAddress, address indexed newAddress);
    event DeployerWalletUpdated(address indexed oldAddress, address indexed newAddress);

    modifier onlyDeployer() {
        require(_deployerWallet == _msgSender(), "Caller is not the deployer");
        _;
    }

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _marketingWallet = payable(0x0C748043BACac3A572Fca56Bacf9b63de5472040);
        _gameWallet = payable(0x5F3f2f431D8b95a053a4F86DF1AaBdEfF49c3169);
        _deployerWallet = payable(_msgSender());

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_marketingWallet] = true;
        _isExcludedFromFee[_gameWallet] = true;
        _isExcludedFromFee[_deployerWallet] = true;
        _isExcludedFromFee[address(this)] = true;

        setInitialSupply(address(this), 66_000_000 ether); 
        setInitialSupply(_msgSender(), 150_000_000 ether); 

         if (block.chainid == 1) {
            uniswapV2Router = IUniswapV2Router02(
                0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
            );
        } else {
            revert("Unsupported chain ID");
        }
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
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            _allowances[sender][_msgSender()] >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(
            owner != address(0) && spender != address(0),
            "ERC20: approve the zero address"
        );
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(
            from != address(0) && to != address(0),
            "ERC20: transfer from or to the zero address"
        );
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxAmount = 0;
        uint256 finalAmount = amount;

        bool isBuy = from == uniswapV2Pair && to != address(this);
        bool isSell = to == uniswapV2Pair && from != address(this);

        if (from != _deployerWallet && to != _deployerWallet) {
            if (!tradingEnabled && (isBuy || isSell)) {
                require(
                    _isExcludedFromFee[to] || _isExcludedFromFee[from],
                    "Trading has not been enabled yet."
                );
            }

            if (isSell) {
                uint256 taxRate = _sellTax;
                if (!_isExcludedFromFee[from]) {
                    taxAmount = (amount * taxRate) / 100;
                    finalAmount = amount - taxAmount;
                }
            } else if (isBuy) {
                uint256 taxRate = _buyTax;
                if (!_isExcludedFromFee[to]) {
                    taxAmount = (amount * taxRate) / 100;
                    finalAmount = amount - taxAmount;
                }
            }

            if (
                isBuy &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(
                    finalAmount <= _maxTransactionAmount,
                    "Transaction amount exceeds the maximum allowed limit"
                );
                require(
                    balanceOf(to) + finalAmount <= _maxWalletSize,
                    "Recipient's wallet balance will exceed the maximum allowed limit"
                );
            }

            if (taxAmount > 0) {
                _accumulatedTax += taxAmount;
            }

            uint256 tokenBalance = balanceOf(address(this));

            if (
                !inSwap &&
                isSell &&
                tokenBalance >= _taxThreshold &&
                _accumulatedTax >= _taxTrigger
            ) {
                uint256 swapAmount = (tokenBalance > _taxMaxSwap)
                    ? _taxMaxSwap
                    : tokenBalance;
                swapAndDistribute(swapAmount);
                _accumulatedTax = 0;
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] += taxAmount;
            emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] -= amount;
        _balances[to] += finalAmount;
        emit Transfer(from, to, finalAmount);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
        emit LiquidityAdded(tokenAmount, ethAmount);
    }

    function toggleAddLiquidity() external onlyDeployer {
        liquifyEnabled = !liquifyEnabled;
        emit Log("Liquidity addition toggled", liquifyEnabled ? 1 : 0);
    }

    function distributeFees(uint256 amount) private {
        uint256 half = amount / 2;
        _gameWallet.transfer(half);

        if (liquifyEnabled) {
            uint256 totalTokens = balanceOf(address(this));
            addLiquidity(totalTokens, half);
        } else {
            _marketingWallet.transfer(half);
        }
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
            address(this),
            block.timestamp
        );
    }

    function setInitialSupply(address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");
        _balances[account] = amount;
        emit Transfer(address(0), account, amount);
    }

    function launch() external onlyDeployer {
        require(!didLaunch, "Launch already called");
        require(
            address(this).balance > 0 && _balances[address(this)] > 0,
            "Contract must have both ETH and Tokens to proceed with the launch"
        );
        _approve(
            address(this),
            address(uniswapV2Router),
            _balances[address(this)]
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
        uint256 tokenAmountToAdd = _balances[address(this)];
        uint256 ethAmountToAdd = address(this).balance;
        addLiquidity(tokenAmountToAdd, ethAmountToAdd);
        emit LaunchExecuted(tokenAmountToAdd, ethAmountToAdd, block.timestamp);
        emit AuditLog("Contract launched", address(this));
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        didLaunch = true;
    }

    function start() external onlyDeployer {
        require(!tradingEnabled, "Trading already opened");
        tradingEnabled = true;
        emit TradingEnabled(tradingEnabled);
    }

    function setTaxParameters(
        uint256 taxTrigger,
        uint256 taxThreshold
    ) external onlyDeployer {
        require(tradingEnabled, "Trading is not enabled");
        // You can add more validation as needed
        _taxTrigger = taxTrigger * 10 ** _decimals;
        _taxThreshold = taxThreshold * 10 ** _decimals;
        emit SetTaxParameters(taxTrigger, taxThreshold);
        emit Log("Tax parameters updated", block.timestamp);
    }

    function swapAndDistribute(uint256 swapAmount) private lockTheSwap {
        swapTokensForEth(swapAmount);
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            distributeFees(contractETHBalance);
            emit Log("Fees distributed", contractETHBalance);
        }
    }

    function setMarketingWallet(address payable newMarketingWallet) external onlyDeployer {
        require(newMarketingWallet != address(0), "Invalid address");
        address oldAddress = _marketingWallet;
        _marketingWallet = newMarketingWallet;
        _isExcludedFromFee[_marketingWallet] = true;
        _isExcludedFromFee[oldAddress] = false;
        emit MarketingWalletUpdated(oldAddress, newMarketingWallet);
        emit AuditLog("Marketing wallet updated to:", newMarketingWallet);
    }

    function setGameWallet(address payable newGameWallet) external onlyDeployer {
        require(newGameWallet != address(0), "Invalid address");
        address oldAddress = _gameWallet;
        _gameWallet = newGameWallet;
        _isExcludedFromFee[_gameWallet] = true;
        _isExcludedFromFee[oldAddress] = false;
        emit GameWalletUpdated(oldAddress, newGameWallet);
        emit AuditLog("Game wallet updated to:", newGameWallet);
    }

    function setDeployerWallet(address payable newDeployerWallet) external onlyDeployer {
        require(newDeployerWallet != address(0), "Invalid address");
        address oldAddress = _deployerWallet;
        _deployerWallet = newDeployerWallet;
        _isExcludedFromFee[_deployerWallet] = true;
        _isExcludedFromFee[oldAddress] = false;
        emit DeployerWalletUpdated(oldAddress, newDeployerWallet);
        emit AuditLog("Deployer wallet updated to:", newDeployerWallet);
    }

    function withdrawStuckTax() external onlyDeployer lockTheSwap {
        uint256 taxAmount = _accumulatedTax;
        require(taxAmount > 0, "No tax to withdraw");
        uint256 tokenBalance = balanceOf(address(this));
        require(tokenBalance >= taxAmount, "Insufficient tokens in contract");
        swapTokensForEth(taxAmount);
        uint256 contractETHBalance = address(this).balance;
        require(contractETHBalance > 0, "No ETH to distribute");
        distributeFees(contractETHBalance);
        _accumulatedTax = 0;
    }

    function withdrawStuckEther(uint256 amount) external onlyDeployer {
        require(tradingEnabled, "Trading must be enabled");
        require(didLaunch, "Liquidity must be added");
        require(amount <= address(this).balance, "Insufficient balance");
         _deployerWallet.transfer(amount);
         emit AuditLog("Withdrawn stuck Ether to deployer wallet", _deployerWallet);
         emit Log("Amount withdrawn:", amount);
    }

    function withdrawStuckTokens(
        address tokenAddress,
        uint256 amount
    ) external onlyDeployer {
        require(tradingEnabled, "Trading must be enabled");
        require(didLaunch, "Liquidity must be added");
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 contractBalance = tokenContract.balanceOf(address(this));
        require(amount <= contractBalance, "Insufficient balance");
        tokenContract.transfer(_deployerWallet, amount);
        emit AuditLog("Withdrawn stuck tokens to deployer wallet", _deployerWallet);
        emit Log("Amount withdrawn:", amount);
    }

    function excludeFromFee(address account) external onlyDeployer {
        require(account != address(0), "Cannot exclude zero address");
        _isExcludedFromFee[account] = true;
        emit AuditLog("Excluded from fee:", account);
    }

    function includeInFee(address account) external onlyDeployer {
        require(account != address(0), "Cannot include zero address");
        _isExcludedFromFee[account] = false;
        emit AuditLog("Included in fee:", account);
    }

    receive() external payable {}
}