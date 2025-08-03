//    ____                   ______                   ____  ___   ____
//   / __ \____  ___  ____  / ____/___ _________     / __ \/   | / __ \
//  / / / / __ \/ _ \/ __ \/ /_  / __ `/ ___/ _ \   / / / / /| |/ / / /
// / /_/ / /_/ /  __/ / / / __/ / /_/ / /__/  __/  / /_/ / ___ / /_/ /
// \____/ .___/\___/_/ /_/_/    \__,_/\___/\___/  /_____/_/  |_\____/
//     /_/
//
//   We believe in democratizing AI model development and deployment.
//     OpenFace is built to be the community-driven alternative to
//      proprietary AI platforms, ensuring knowledge and resources
//                remain free and available to all.
//
// Discord: https://discord.gg/3swfECPMcr
// Website: https://openface.dev (tentative, may move to https://openface.co)
//  Github: https://github.com/openface-ai
//   x.com: https://twitter.com/openface_ai
//
//      A community funding apparatus in search of a governance function
//
//
// This is a specialized smart contract token that collects a fee to be paid
// to the contract creators, liquidity providers, and most importantly and
// in a greater amount to the OpenFace donation wallet until an initial
// maximum collections is met.
//
// This will help give the project runway and enable the token to become a
// feeless token once that service is complete - making it perfect for pure
// governance and exchange trading.
//
// A portion of the initial supply will be granted to the OpenFace donation
// wallet, and multiple portions will be locked away on their behalf for
// 6 and 12 months. A small portion will be sent to LPs and DeFi advisors.
//
// SPDX-License-Identifier: MIT
pragma solidity =0.8.26;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is IERC20, IERC20Metadata {
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    constructor(string memory name_, string memory symbol_) {
        _symbol = symbol_;
        _name = name_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}

interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}


contract OpenFaceDAO is ERC20, Ownable {

    bool public launched;
    bool public limitsEnabled;
    bool public feesEnabled;

    uint256 public buyFeeNumerator;
    uint256 public sellFeeNumerator;
    uint256 public maxTxnAmount;
    uint256 public maxWalletAmount;

    uint256 public disableLimitsTimestamp;

    uint256 public tAndEFeesCollected;
    uint256 public treasuryFeesCollected;
    uint256 public maxTandEFeesToCollect;
    uint256 public maxTreasuryFeesToCollect;
    bool public maxFeesCollected;

    address public liquidationAMM;
    address public tAndEFeeRecipient;
    address public treasuryRecipient;
    address public weth;
    IRouter public router;

    uint256 private startTradingBlockNumber;
    bool private inFeeLiquidation = false;

    mapping(address => uint256) lastBlockTransaction;

    bytes4 private constant TRANSFERSELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    receive() external payable {}

    constructor(
        string memory name,
        string memory symbol,
        uint256 supply,
        address treasuryRecipient_
    ) Ownable() ERC20(name, symbol) {
        _mint(address(this), supply);
        tAndEFeeRecipient = msg.sender;
        treasuryRecipient = treasuryRecipient_;
    }

    function setTreasuryRecipient(address feeRecipient_) external {
        require(msg.sender == owner() || msg.sender == treasuryRecipient);
        treasuryRecipient = feeRecipient_;
    }

    function disableLimits() external onlyOwner {
        require(limitsEnabled);
        limitsEnabled = false;
    }

    function setFees(uint256 _buyFeeNumerator, uint256 _sellFeeNumerator) public onlyOwner {
        require(_buyFeeNumerator <= buyFeeNumerator && _sellFeeNumerator <= sellFeeNumerator);
        buyFeeNumerator = _buyFeeNumerator;
        sellFeeNumerator = _sellFeeNumerator;
        if (buyFeeNumerator + sellFeeNumerator == 0) {
            feesEnabled = false;
        }
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        if (amount == 0 || inFeeLiquidation || !launched) {
            super._transfer(from, to, amount);
            return;
        }

        // Sell
        if (to == liquidationAMM) {
            if (balanceOf(address(this)) > 0) {
                inFeeLiquidation = true;
                uint256 tokenBalance = balanceOf(address(this));
                uint256 amountToSell = tokenBalance > amount ? amount : tokenBalance;
                swapTokensForEth(amountToSell);
                inFeeLiquidation = false;
            }

            if (feesEnabled) {
                uint256 feeAmount = amount * sellFeeNumerator / 10000;
                if (feeAmount > 0) {
                    amount = amount - feeAmount;
                    super._transfer(from, address(this), feeAmount);
                }
            }

            if (!maxFeesCollected && address(this).balance > 0) {
                if (
                    tAndEFeesCollected >= maxTandEFeesToCollect &&
                    treasuryFeesCollected >= maxTreasuryFeesToCollect
                ) {
                    if (buyFeeNumerator > 0 || sellFeeNumerator > 0) {
                        setFees(0, 0);
                    }
                    maxFeesCollected = true;
                } else {
                    uint256 tAndEAmount = 0;
                    uint256 treasuryAmount = 0;
                    uint256 ethBalance = address(this).balance;

                    if (treasuryFeesCollected < maxTreasuryFeesToCollect) {
                        treasuryAmount = ethBalance * 90 / 100;
                    }

                    if (tAndEFeesCollected < maxTandEFeesToCollect) {
                        tAndEAmount = ethBalance - treasuryAmount;
                    } else {
                        treasuryAmount = ethBalance;
                    }

                    if (tAndEAmount > 0) {
                        (bool success,) = tAndEFeeRecipient.call{value: tAndEAmount}("");
                        if (success) {
                            tAndEFeesCollected += tAndEAmount;
                        }
                    }

                    if (treasuryAmount > 0) {
                        (bool success,) = treasuryRecipient.call{value: treasuryAmount}("");
                        if (success) {
                            treasuryFeesCollected += treasuryAmount;
                        }
                    }
                }
            }
        }

        // Buy
        if (from == liquidationAMM && feesEnabled) {
            uint256 feeAmount = amount * buyFeeNumerator / 10000;
            if (feeAmount > 0) {
                amount = amount - feeAmount;
                super._transfer(from, address(this), feeAmount);
            }
        }

        if (limitsEnabled && tx.origin != tAndEFeeRecipient) {
            if (block.timestamp > disableLimitsTimestamp) {
                limitsEnabled = false;
            } else {
                require(block.number >= startTradingBlockNumber);

                // one txn per block while limits are enabled
                require(lastBlockTransaction[tx.origin] < block.number);
                lastBlockTransaction[tx.origin] = block.number;

                require(amount <= maxTxnAmount);
                if (to != liquidationAMM) {
                    require(amount + balanceOf(to) <= maxWalletAmount);
                }
            }
        }
        super._transfer(from, to, amount);
    }

    function launch(
        // LP, treasury, tAndE
        uint256[3] memory amountsConfig,
        // router
        address[1] memory addressConfig,
        // Buy, sell, maxTandEFeesToCollect, maxTreasuryFeesToCollect
        uint256[4] memory feeConfig,
        // Txn, wallet, block delay, limitSeconds
        uint256[4] memory limitConfig
    ) external payable onlyOwner {
        router = IRouter(addressConfig[0]);
        weth = router.WETH();

        uint256 totalSupply = balanceOf(address(this));

        // Expected 70
        uint256 LPSupply = totalSupply * amountsConfig[0] / 100;

        // Expected 15
        uint256 treasuryInitialSupply = totalSupply * amountsConfig[1] / 100;

        // Expected 15 -> 6 locked up for 6 months, 6 locked up for 12 months, 3 apportioned to LPs and contract devs
        uint256 tAndESupply = totalSupply * amountsConfig[2] / 100;

        require(LPSupply + treasuryInitialSupply + tAndESupply == totalSupply);

        _approve(address(this), address(router), type(uint256).max);
        router.addLiquidityETH{ value: msg.value }(
            address(this),
            LPSupply,
            0,
            0,
            msg.sender,
            block.timestamp
        );

        super._transfer(address(this), treasuryRecipient, treasuryInitialSupply);
        super._transfer(address(this), tAndEFeeRecipient, tAndESupply);

        IFactory factory = IFactory(router.factory());
        liquidationAMM = factory.getPair(address(this), router.WETH());

        buyFeeNumerator = feeConfig[0];
        sellFeeNumerator = feeConfig[1];

        maxTxnAmount = limitConfig[0];
        maxWalletAmount = limitConfig[1];

        startTradingBlockNumber = block.number + limitConfig[2];
        disableLimitsTimestamp = block.timestamp + limitConfig[3];

        feesEnabled = true;
        limitsEnabled = true;
        maxTandEFeesToCollect = feeConfig[2];
        maxTreasuryFeesToCollect = feeConfig[3];
        launched = true;
    }

    function swapTokensForEth(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = weth;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function rescueStuckETH() external {
        require(tAndEFeesCollected >= maxTandEFeesToCollect && treasuryFeesCollected >= maxTreasuryFeesToCollect);
        (bool success,) = treasuryRecipient.call{value: address(this).balance}("");
        require(success);
    }

    function rescueStuckTokens(address token, uint256 amount) external {
        require(token != address(this));
        _safeTransfer(token, treasuryRecipient, amount);
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(TRANSFERSELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FAILED');
    }
}