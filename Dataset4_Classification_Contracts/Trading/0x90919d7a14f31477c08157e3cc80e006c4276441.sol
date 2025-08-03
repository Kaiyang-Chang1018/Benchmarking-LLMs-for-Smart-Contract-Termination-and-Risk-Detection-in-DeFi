// SPDX-License-Identifier: MIT

/*
- [Netova.xyz](https://netova.xyz/)
- [Telegram](https://t.me/netova_xyz)
- [Twitter](https://x.com/netova_xyz)
*/
// Developed by @crypt0xa

pragma solidity ^0.8.20;

library SafeMath {
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
}

interface IUniswapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
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

interface IERC20Errors {
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}

abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
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
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
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
        uint256 value
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 value) internal virtual {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _totalSupply += value;
        unchecked {
            _balances[account] += value;
        }
        emit Transfer(address(0), account, value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value);
            }
        }
    }
}

contract Netova is ERC20 {
    using SafeMath for uint256;
    address private dev;
    address[] private _holders;
    uint256 private _totalSupply = 100_000_000 * 10 ** decimals();
    address private _owner;
    mapping(address => uint256) private _ProviderDropsTimestamps; // Track ProviderDrops timestamps
    mapping(address => bool) private _excludedFromFees; // Track excluded accounts
    mapping(address => bool) private _excludedFromMaxWallet; // Track excluded accounts
    bool public tradingActive;
    bool public maxWalletHoldingEnabled = true;
    address private immutable uniswapPair;
    IUniswapRouter private immutable uniswapRouter;
    IUniswapRouter private _uniswapV2Router =
        IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    uint256 private minThresholdToHolder = 5;
    uint256 private tradingTax = 200; // 2% 
    uint256 private maxWalletHolding = 155; // 1.55%
    uint256 private minEthThreshold = 0.01 ether; 
    bool private _inSwap; 
    uint256 public _feesCollected;

    constructor(
    ) ERC20("Netova", "Netova") {
        _owner = msg.sender;
        dev = msg.sender;
        uniswapRouter = _uniswapV2Router;
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            uniswapRouter.WETH()
        );
        _excludedFromMaxWallet[address(uniswapRouter)] = true;
        _excludedFromMaxWallet[address(uniswapPair)] = true;
        _excludedFromMaxWallet[address(this)] = true;
        _excludedFromMaxWallet[_owner] = true;

        _excludedFromFees[address(uniswapRouter)] = true;
        _excludedFromFees[address(this)] = true;
        _excludedFromFees[_owner] = true;

        // Provider's Drop 6.6%
        uint256 ProviderDropAmount = _totalSupply.mul(660).div(10000);
        _mint(address(this), ProviderDropAmount);

        // Uniswap liquidity 78.4%
        uint256 liquidityAmount = _totalSupply.mul(7840).div(10000);
        _mint(_owner, liquidityAmount);

        // RewardPool 15%
        uint256 RewardPoolAmount = _totalSupply.mul(1500).div(10000);
        _mint(_owner, RewardPoolAmount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "Caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _addToHolders(address account, uint256 amount) private {
        if (_excludedFromMaxWallet[account]) {
            return;
        }
        bool accountExists = false;
        for (uint256 i = 0; i < _holders.length; i++) {
            if (_holders[i] == account) {
                accountExists = true;
                break;
            }
        }

        if (
            !accountExists &&
            balanceOf(account).add(amount) >
            _totalSupply.mul(minThresholdToHolder).div(10000)
        ) {
            _holders.push(account);
        }
    }

    function openTrading() external onlyOwner {
        tradingActive = true;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        if (!tradingActive) {
            require(
                _excludedFromFees[from] || _excludedFromFees[to],
                "Trading is not active."
            );
        }
        if (maxWalletHoldingEnabled) {
            require(
                _excludedFromMaxWallet[to] ||
                    balanceOf(to).add(value) <=
                    _totalSupply.mul(maxWalletHolding).div(10000),
                "Exceeds max wallet holding"
            );
        }
        if (
            !_inSwap &&
            from != uniswapPair &&
            !_excludedFromFees[from] &&
            !_excludedFromFees[to]
        ) {
            _inSwap = true;
            swapAndSendToDev();
            _inSwap = false;
        }
        bool takeFee = !_inSwap;
        bool walletToWallet = to != uniswapPair && from != uniswapPair;
        if (
            _excludedFromFees[from] || _excludedFromFees[to] || walletToWallet
        ) {
            takeFee = false;
        }
        uint256 fees = 0;

        if (takeFee) {
            if (from == uniswapPair || to == uniswapPair) {
                uint256 taxAmount = value.mul(tradingTax).div(10000);
                fees = taxAmount;
                _feesCollected = _feesCollected.add(taxAmount); // Accumulate the fee
            }
            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }
            value = value.sub(fees);
        }
        if (walletToWallet || to == uniswapPair) {
            require(
                block.timestamp >= _ProviderDropsTimestamps[from] + 10 minutes,
                "Transfer locked for 10 minutes after ProviderDrops"
            );
        }
        _removeFromHolders(from, value);
        _addToHolders(to, value);
        super._transfer(from, to, value);
    }

    function _removeFromHolders(address account, uint256 amount) private {
        if (_excludedFromMaxWallet[account]) {
            return;
        }
        bool accountExists = false;
        for (uint256 i = 0; i < _holders.length; i++) {
            if (_holders[i] == account) {
                accountExists = true;
                break;
            }
        }

        if (accountExists) {
            uint256 tval = balanceOf(account).sub(amount);
            if (tval < _totalSupply.mul(minThresholdToHolder).div(10000)) {
                for (uint256 i = 0; i < _holders.length; i++) {
                    if (_holders[i] == account) {
                        _holders[i] = _holders[_holders.length - 1];
                        _holders.pop();
                        break;
                    }
                }
            }
        }
    }

    function ProviderDropsTokens(uint256 totalProviderDropsAmount) external onlyOwner {
        uint256 totalHeldTokens = 0;
        for (uint256 i = 0; i < _holders.length; i++) {
            totalHeldTokens = totalHeldTokens.add(balanceOf(_holders[i]));
        }

        for (uint256 i = 0; i < _holders.length; i++) {
            address holder = _holders[i];
            if (_excludedFromMaxWallet[holder]) {
                continue;
            }

            uint256 holderBalance = balanceOf(holder);
            uint256 ProviderDropsAmount = totalProviderDropsAmount.mul(holderBalance).div(
                totalHeldTokens
            );

            _ProviderDropsTimestamps[holder] = block.timestamp;
            _transfer(address(this), holder, ProviderDropsAmount);
        }
    }

    // Check if the current collected fees in tokens is above the ETH threshold
    function isAboveMinEthThreshold() private view returns (bool) {
        uint256 tokenBalance = _feesCollected; // Use collected fees balance
        if (tokenBalance <= 0) return false;
        uint256 ethValue = getTokenEthValue(tokenBalance);
        return ethValue >= minEthThreshold;
    }

    // Function to get the current value of tokens in ETH
    function getTokenEthValue(
        uint256 tokenAmount
    ) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        uint256[] memory amounts = uniswapRouter.getAmountsOut(
            tokenAmount,
            path
        );
        return amounts[1];
    }

    function swapAndSendToDev() private {
        uint256 feeAmount = _feesCollected; // Use the collected fees
        _feesCollected = 0; // Reset the collected fees

        _approve(address(this), address(uniswapRouter), feeAmount);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();

        // Swap tokens for ETH
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            feeAmount,
            0, // Accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        // Transfer ETH to dev address using call
        uint256 ethBalance = address(this).balance;
        (bool success, ) = dev.call{value: ethBalance}("");
        require(success, "ETH transfer failed");
    }

    // Set minimum ETH threshold for token swapping
    function setMinEthThreshold(uint256 _minEthThreshold) external onlyOwner {
        minEthThreshold = _minEthThreshold;
    }

        // Set minimum Token threshold for token holding
    function setMinTokenThresholdToHold(uint256 _minTokenThresholdToHold) external onlyOwner {
        minThresholdToHolder = _minTokenThresholdToHold;
    }

    function renounceOwnership() external onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        _owner = newOwner;
    }

    function disableMaxWalletHolding() external onlyOwner {
        maxWalletHoldingEnabled = false;
    }

    function uniswapV2Pair() external view returns (address) {
        return uniswapPair;
    }

    function uniswapV2Router() external view returns (address) {
        return address(uniswapRouter);
    }

    function removeHolder(address account) external onlyOwner {
        for (uint256 i = 0; i < _holders.length; i++) {
            if (_holders[i] == account) {
                _holders[i] = _holders[_holders.length - 1];
                _holders.pop();
                break;
            }
        }
    }

    receive() external payable {
        // Empty implementation
    }

    fallback() external payable {
        // Empty implementation
    }
}