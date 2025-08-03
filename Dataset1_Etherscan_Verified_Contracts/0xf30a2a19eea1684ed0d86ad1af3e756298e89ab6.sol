// SPDX-License-Identifier: MIT
// ------------------------------------------------------------
// Flattened from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts)
// and your custom AstroLamToken code
// ------------------------------------------------------------

// File: @openzeppelin/contracts/utils/Context.sol

pragma solidity 0.8.20;  // Pinned version to avoid floating pragma

/**
 * @dev Provides information about the current execution context.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity 0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount)
        external
        returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

pragma solidity 0.8.20;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

pragma solidity 0.8.20;


/**
 * @dev Implementation of the ERC20 interface.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    /**
     * @dev Sets the token name and symbol. Defaults decimals to 18.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the token name.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token symbol, e.g. ASTROLAM.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * Defaults to 18.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev Returns total tokens in existence.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns account balance.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev Transfers `amount` from caller to `to`.
     */
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev Returns allowance of `spender` over `owner`.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev Sets `amount` as allowance of `spender` over caller's tokens.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev Transfers `amount` from `from` to `to`, deducting from allowance.
     */
    function transferFrom(address from, address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Increases allowance for `spender`.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(
            owner,
            spender,
            _allowances[owner][spender] + addedValue
        );
        return true;
    }

    /**
     * @dev Decreases allowance for `spender`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "Allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Internal transfer logic.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    )
        internal
        virtual
    {
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Creates `amount` new tokens for `account`.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "Mint to zero");

        _totalSupply += amount;
        _balances[account] += amount;
        
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "Burn from zero");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "Burn exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as allowance of `spender` over `owner`.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    )
        internal
        virtual
    {
        require(owner != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spends `amount` from `owner`'s allowance on behalf of `spender`.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    )
        internal
        virtual
    {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "Insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}

// File: AstroLamToken_flattened.sol

pragma solidity 0.8.20;

/**
 * @title AstroLamToken
 * @dev ERC20 token that distributes supply to specified addresses and 
 * includes optional burn functionalities from a liquidity wallet.
 */
contract AstroLamToken is ERC20 {

    // Using scientific notation for clarity & compile-time constant
    // 1e9 * 1e18 = 1e27
    uint256 public constant TOTAL_SUPPLY = 1e27;

    // Tracking last burn time
    uint256 public lastBurnTimestamp;

    // 0.05% weekly burn => 5 basis points out of 10,000
    uint256 public constant WEEKLY_BURN_PERCENTAGE = 5;

    // 2% one-time burn => 200 basis points out of 10,000
    uint256 public constant ONE_TIME_BURN_PERCENTAGE = 200;

    // 7-day interval for weekly burns
    uint256 public constant BURN_INTERVAL = 7 days;

    // March 28, 2025, in UNIX timestamp
    uint256 public constant ONE_TIME_BURN_DATE = 1742755200;

    // Allocations
    address public constant LIQUIDITY_ADDRESS =
        0x83d35c42ED189D554161550c01796F8E937B58C5; // 50%
    address public constant MARKETING_ADDRESS =
        0x596b9cF17108Ac5159D2Cef39cC9187B8B8429FF; // 10%
    address public constant COMMUNITY_ADDRESS =
        0x0782328b21b63C9078b218a254ca1C257d5C71Ac; // 30%
    address public constant DEVELOPER_TEAM_ADDRESS =
        0x76c91b96ae17B66624A5992b8454a9703d3495Ea; // 10%

    // 
    // "payable" constructor is optional — 
    // it can save gas but also lets the contract receive ETH on deploy.
    //
    constructor() payable ERC20("AstroLam", "ASTROLAM") {
        // Distribute supply at deployment
        uint256 liquidityAmount = (TOTAL_SUPPLY * 50) / 100;  // 50%
        uint256 marketingAmount = (TOTAL_SUPPLY * 10) / 100;  // 10%
        uint256 communityAmount = (TOTAL_SUPPLY * 30) / 100;  // 30%
        uint256 developerAmount = (TOTAL_SUPPLY * 10) / 100;  // 10%

        _mint(LIQUIDITY_ADDRESS, liquidityAmount);
        _mint(MARKETING_ADDRESS, marketingAmount);
        _mint(COMMUNITY_ADDRESS, communityAmount);
        _mint(DEVELOPER_TEAM_ADDRESS, developerAmount);

        // Start burn timer
        lastBurnTimestamp = block.timestamp;
    }

    /**
     * @dev Allows anyone to burn tokens from their own address.
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Burns 0.05% of total supply from the Liquidity wallet every 7 days.
     */
    function weeklyBurn() external {
        require(
            block.timestamp >= lastBurnTimestamp + BURN_INTERVAL,
            "Not time"
        );

        uint256 burnAmount = (totalSupply() * WEEKLY_BURN_PERCENTAGE) / 10000;
        _burn(LIQUIDITY_ADDRESS, burnAmount);

        lastBurnTimestamp = block.timestamp;
    }

    /**
     * @dev Burns 2% of total supply from the Liquidity wallet on/after 3/28/2025.
     */
    function oneTimeBurn() external {
        require(
            block.timestamp >= ONE_TIME_BURN_DATE,
            "Not date"
        );

        uint256 burnAmount = (totalSupply() * ONE_TIME_BURN_PERCENTAGE) / 10000;
        _burn(LIQUIDITY_ADDRESS, burnAmount);
    }

    /**
     * @dev Just a sample extra function to demonstrate expandability.
     */
    function specialFeature() external pure returns (string memory) {
        return "AstroLam to the moon!";
    }
}