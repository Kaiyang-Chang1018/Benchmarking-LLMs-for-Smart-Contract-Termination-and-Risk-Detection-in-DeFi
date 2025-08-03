// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface InterfaceLP {
    function sync() external;
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals
    ) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}


/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) internal _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` to `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
    returns (uint[] memory amounts);
}

contract YieldFu is ERC20Detailed, AccessControl {
    bytes32 public constant TOKEN_MANAGER = keccak256("TOKEN_MANAGER");
    bytes32 public constant UNRESTRICTED = keccak256("UNRESTRICTED");
    
    event LogRebase(uint256 totalSupply);

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 private constant DECIMALS = 9;
    uint256 private constant MAX_UINT256 = type(uint256).max;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    IDEXRouter immutable router;
    address[] public pairs;
    mapping(address => bool) public isPair;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 888_888_888_000 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 internal gonMaxWallet = (TOTAL_GONS / 100000) * 2;

    uint256 private constant MAX_SUPPLY = type(uint128).max;

    uint256 private _totalSupply;
    uint256 private _excessSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;

    mapping(address => mapping(address => uint256)) private _allowedFragments;
    
    bool public autoRebase = true;
    uint256 public autoRebasePercent = 125;
    uint256 autoRebaseTimer = 1 hours;
    uint256 public lastRebase = 0;

    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 public immutable _maxSwap;
    address immutable treasury;

    uint256 internal launched;
    bool internal generalTrading = false;

    modifier lockSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    function runAutoRebase() public {
        uint256 elapsed = block.timestamp - lastRebase;
        uint256 cycles = elapsed / autoRebaseTimer;
        if (autoRebase && cycles > 0) {
            rebase(-int256((_totalSupply * autoRebasePercent * cycles) / 100000), false);
            lastRebase = block.timestamp - (elapsed % autoRebaseTimer);
        }
    }
    
    function rebasePercent(uint256 _percent, bool up, bool priceChange) external onlyRole(TOKEN_MANAGER) returns (uint256) {
        if (up) {
            return rebase(int256((_totalSupply * _percent) / 100), priceChange);
        } else {
            return rebase(-int256((_totalSupply * _percent) / 100), priceChange);
        }
    }

    function rebase(int256 supplyDelta, bool priceChange)
        internal
        returns (uint256)
    {
        if (supplyDelta == 0) {
            emit LogRebase(_totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply -= uint256(-supplyDelta);
        } else {
            _totalSupply += uint256(supplyDelta);
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        uint256 prev = _gonsPerFragment;
        
        _gonsPerFragment = TOTAL_GONS / _totalSupply;
        
        uint256 diff;
        for(uint256 i = 0; i < pairs.length; i++) {
            address pair = pairs[i];
            if(!priceChange) {
                if (supplyDelta < 0) {
                    diff = (_gonBalances[pair] / prev) - balanceOf(pair);
                    _gonBalances[pair] += diff * _gonsPerFragment;
                }
                else {
                    diff = balanceOf(pair) - (_gonBalances[pair] / prev);
                    _gonBalances[pair] -= diff * _gonsPerFragment;
                }
            } else {
                try InterfaceLP(pair).sync() {}
                catch {}
            }
        }

        emit LogRebase(_totalSupply);
        return _totalSupply;
    }

    constructor() ERC20Detailed("YieldFu", "FU", uint8(DECIMALS)) {
        lastRebase = block.timestamp;
        treasury = 0x192A4F559Ff5B8aE8D78914078f6F592055aB813;
        
        router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UNRESTRICTED, msg.sender);
        _grantRole(UNRESTRICTED, DEAD);
        _grantRole(UNRESTRICTED, address(this));
        
        _allowedFragments[address(this)][address(router)] = type(uint256).max;
        _allowedFragments[msg.sender][address(router)] = type(uint256).max;
        
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonsPerFragment = TOTAL_GONS / _totalSupply;
        _gonBalances[address(this)] = TOTAL_GONS / 1000;
        _excessSupply = TOTAL_GONS - (TOTAL_GONS / 1000);

        _maxSwap = _totalSupply * 3 / 1000000;
        
        emit Transfer(address(0), address(this), _totalSupply / 1000);
    }
    
    function setAutoRebase(bool _auto, uint256 _percent, uint256 _timer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_percent <= 5000);
        require(_timer >= 1 hours);
        autoRebase = _auto;
        autoRebasePercent = _percent;
        autoRebaseTimer = _timer;
    }
    
    function setAutoRebaseTimer(uint256 _timer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_timer >= 1 hours);
        autoRebaseTimer = _timer;
    }

    function addLP(address _address) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(pairs.length < 10, "Too many pairs");
        pairs.push(_address);
        isPair[_address] = true;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply - _excessSupply / _gonsPerFragment;
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who] / _gonsPerFragment;
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != type(uint256).max) {
            _allowedFragments[from][msg.sender] -= value;
        }

        _transferFrom(from, to, value);
        return true;
    }

    function getTax() internal view returns(uint256) {
        if(block.number - launched > 50) return 0;
        else if(block.number - launched > 4) return 3;
        else return 35;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount * _gonsPerFragment;
        uint256 taxAmount = 0;
        uint256 tax = getTax();
        if (!generalTrading) {
            require(hasRole(UNRESTRICTED, recipient) || hasRole(UNRESTRICTED, sender), "Try again shortly");
        }
        if (launched > 0) {
            if (tax > 0 && sender != address(this)) {
                taxAmount = gonAmount / 100 * tax;
                if(taxAmount>0){
                    _gonBalances[sender] -= taxAmount;
                    _gonBalances[address(this)] += taxAmount;
                }
            }

            if (!inSwap && isPair[recipient] && swapEnabled && sender != address(this)) {
                tokensToEth(amount);
            }

            if (!hasRole(UNRESTRICTED,sender) && !hasRole(UNRESTRICTED,recipient)) {
                runAutoRebase();
            }
        }

        _gonBalances[sender] -= (gonAmount-taxAmount);
        _gonBalances[recipient] += (gonAmount-taxAmount);
        
        emit Transfer(
            sender,
            recipient,
            (gonAmount-taxAmount) / _gonsPerFragment
        );
        return true;
    }

    function tokensToEth(uint256 tokenAmount) private lockSwap {
        uint256 bal = balanceOf(address(this));
        tokenAmount = tokenAmount / 3;
        if(tokenAmount > bal) tokenAmount = bal;
        if(tokenAmount > _maxSwap) tokenAmount = _maxSwap;

        if(tokenAmount > 0) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = router.WETH();
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }

        clearETH();
    }

    function issueRewards(address to, uint256 amount) external onlyRole(TOKEN_MANAGER) {
        uint256 gonAmount = amount * _gonsPerFragment;
        _gonBalances[to] += gonAmount;
        _excessSupply -= gonAmount;
        emit Transfer(
            address(0),
            to,
            gonAmount / _gonsPerFragment
        );
    }
    
    function removeRewards(address from, uint256 amount) external onlyRole(TOKEN_MANAGER) {
        uint256 gonAmount = amount * _gonsPerFragment;
        if (_allowedFragments[from][msg.sender] != type(uint256).max) {
            _allowedFragments[from][msg.sender] -= amount;
        }
        _gonBalances[from] -= gonAmount;
        _excessSupply += gonAmount;
        emit Transfer(
            from,
            address(0),
            gonAmount / _gonsPerFragment
        );
    }

    function clearTax() external onlyRole(DEFAULT_ADMIN_ROLE) {
        tokensToEth(_maxSwap);
    }

    function clearETH() public {
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            bool success;
            (success, ) = treasury.call{value: contractETHBalance}("");
        }
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] += addedValue;
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        if (subtractedValue >= _allowedFragments[msg.sender][spender]) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] -= subtractedValue;
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function lp(address deliver) external payable onlyRole(DEFAULT_ADMIN_ROLE) {
        address uniswapV2Pair = IDEXFactory(router.factory()).createPair(address(this), router.WETH());
        addLP(uniswapV2Pair);
        router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,deliver,block.timestamp);

        swapEnabled = true;
    }

    function enableTax() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(launched == 0);
        launched = block.number;
        lastRebase = block.timestamp;
    }

    function generalOpen() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!generalTrading);
        launched = block.number;
        generalTrading = true;
        lastRebase = block.timestamp;
    }

    function setRoles(bytes32 role, address[] calldata wallets, bool active) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint256 i = 0; i < wallets.length; i++) {
            _roles[role].hasRole[wallets[i]] = active;
        }
    }

    function toggleSwap() external onlyRole(DEFAULT_ADMIN_ROLE) {
        swapEnabled = !swapEnabled;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (TOTAL_GONS - (_gonBalances[DEAD] + _gonBalances[ZERO] + _excessSupply)) / _gonsPerFragment;
    }

    receive() external payable {}
}