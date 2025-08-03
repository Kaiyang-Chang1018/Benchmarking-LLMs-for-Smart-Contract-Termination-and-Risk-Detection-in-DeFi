// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function decimals() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external;

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external;
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IAccessControl {
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    error AccessControlBadConfirmation();

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address callerConfirmation) external;
}

library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

abstract contract ReentrancyGuardUpgradeable is Initializable {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    uint256[49] private __gap;
}

abstract contract ERC165Upgradeable is Initializable, IERC165 {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControl, ERC165Upgradeable {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    struct AccessControlStorage {
        mapping(bytes32 role => RoleData) _roles;
    }

    bytes32 private constant AccessControlStorageLocation = 0x02dd7bc7dec4dceedda775e58dd541e08a116c6c53815c0bd028192f7b626800;

    function _getAccessControlStorage() private pure returns (AccessControlStorage storage $) {
        assembly {
            $.slot := AccessControlStorageLocation
        }
    }

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        return $._roles[role].hasRole[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        return $._roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(DEFAULT_ADMIN_ROLE)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        AccessControlStorage storage $ = _getAccessControlStorage();
        bytes32 previousAdminRole = getRoleAdmin(role);
        $._roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        if (!hasRole(role, account)) {
            $._roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        if (hasRole(role, account)) {
            $._roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}

contract Presale is OwnableUpgradeable, ReentrancyGuardUpgradeable, AccessControlUpgradeable {
    uint256 public constant DENOMINATOR = 10000;
    uint256 public constant MONTH = 30 days;
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    IERC20 public schAddress; // SCH token address
    IERC20 public saleAddress; // USDT address

    uint256[] public PRICES = [10000, 75000, 125000, 175000, 250000, 500000];
    uint256[] public HARDCAPS = [150000, 40000, 88000, 80000, 600000, 400000];

    struct Stage {
        uint256 timeToStart;
        uint256 timeToEnd;
        uint256 timeToClaim;
        uint256 minAmount; // Token amount without considering decimals
        uint256 hardcap;
        uint256 totalSale;
        uint256 price; // Price for SCH token, multiplied by 10000 (e.g., 10000 = $1)
        uint256 affiliateFee; // Percentage fee for the affiliate, multiplied by 10000 (e.g., 5% = 500)
        uint256 vestingPeriod; // Total Months for vesting period
        uint256 affiliateCount;
    }

    struct Affiliate {
        uint256 amount;
        uint256 timeStamp;
        bool claimed;
    }

    struct AffiliateList {
        address referrer;
        address referee;
        uint256 reward;
        uint256 timeStamp;
    }

    Stage[] public stages;

    mapping(uint256 => mapping(address => uint256)) public userDeposited;
    mapping(uint256 => mapping(address => uint256)) public userClaimed;
    mapping(uint256 => mapping(address => uint256)) public userLastClaimed;
    mapping(address => mapping(address => Affiliate)) public affiliates;
    mapping(uint256 => AffiliateList[]) public affiliateList;

    event RoundCreated(uint256 indexed _stageId, uint256 _timeToStart, uint256 _timeToEnd, uint256 _timeToClaim, uint256 _minimumSCHAmount, uint256 _hardcap, uint256 _price, uint256 _affiliateFee, uint256 _vestingPeriod);
    event RoundUpdated(uint256 indexed _stageId, uint256 _timeToStart, uint256 _timeToEnd, uint256 _timeToClaim, uint256 _minimumSCHAmount, uint256 _hardcap, uint256 _price, uint256 _affiliateFee, uint256 _vestingPeriod);
    event SaleAddressUpdated(address indexed _newAddress);
    event Deposit(address indexed _from, uint256 indexed _stage, uint256 _amount, address indexed _affiliate);
    event Claim(address indexed _user, uint256 _stage, uint256 _amount, uint256 _timeStamp);
    event AffiliateRewardClaimed(address indexed _referrer, address indexed _referee, uint256 _amount, uint256 _timeStamp);
    event Withdrawal(address indexed _to, uint256 _amount, string _tokenType);

    receive() external payable {
        revert("Presale: Contract does not accept native currency");
    }

    fallback() external payable {
        revert("Presale: Contract does not accept native currency");
    }

    modifier onlyOwners() {
        require(hasRole(OWNER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Presale: Caller is not an owner");
        _;
    }

    function initialize(address _schAddr, address _saleAddr) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        schAddress = IERC20(_schAddr);
        saleAddress = IERC20(_saleAddr);        
    }

    function createRound(
        uint256 _timeToStart,
        uint256 _timeToEnd,
        uint256 _timeToClaim,
        uint256 _minAmount,
        uint256 _affiliateFee,
        uint256 _vestingPeriod
    ) external onlyOwners {
        stages.push(Stage({
            timeToStart: _timeToStart,
            timeToEnd: _timeToEnd,
            timeToClaim: _timeToClaim,
            minAmount: _minAmount,
            hardcap: HARDCAPS[stages.length],
            totalSale: 0,
            price: PRICES[stages.length],
            affiliateFee: _affiliateFee,
            vestingPeriod: _vestingPeriod,
            affiliateCount: 0
        }));

        emit RoundCreated(stages.length - 1, _timeToStart, _timeToEnd, _timeToClaim, _minAmount, HARDCAPS[stages.length], PRICES[stages.length], _affiliateFee, _vestingPeriod);
    }

    function updateStage(
        uint256 _stageId,
        uint256 _timeToStart,
        uint256 _timeToEnd,
        uint256 _timeToClaim,
        uint256 _minAmount,
        uint256 _hardcap,
        uint256 _price,
        uint256 _affiliateFee,
        uint256 _vestingPeriod
    ) external onlyOwners {
        require(_stageId < stages.length, "Presale: Invalid stage ID");

        Stage storage stage = stages[_stageId];
        stage.timeToStart = _timeToStart;
        stage.timeToEnd = _timeToEnd;
        stage.timeToClaim = _timeToClaim;
        stage.minAmount = _minAmount;
        stage.hardcap = _hardcap;
        stage.price = _price;
        stage.affiliateFee = _affiliateFee;
        stage.vestingPeriod = _vestingPeriod;

        emit RoundUpdated(_stageId, _timeToStart, _timeToEnd, _timeToClaim, _minAmount, _hardcap, _price, _affiliateFee, _vestingPeriod);
    }

    function deposit(uint256 _stageId, uint256 _amount, address _affiliate) external {
        require(_stageId < stages.length, "Presale: Invalid stage ID");

        Stage storage stage = stages[_stageId];
        require(block.timestamp >= stage.timeToStart && block.timestamp <= stage.timeToEnd, "Presale: Not presale period");
        require(_amount >= stage.minAmount, "Invalid request: minimum deposit amount not met");
        
        saleAddress.transferFrom(msg.sender, address(this), _amount);

        uint256 depositAmount = _amount;
        uint256 affiliateReward = 0;

        if (_affiliate != address(0) && _affiliate != msg.sender) {
            affiliateReward = (depositAmount * stage.affiliateFee) / DENOMINATOR;
            depositAmount -= affiliateReward;
            Affiliate memory affiliate = affiliates[_affiliate][msg.sender];
            if (affiliate.amount == 0) {
                affiliates[_affiliate][msg.sender] = Affiliate({
                    amount: affiliateReward,
                    timeStamp: block.timestamp,
                    claimed: false
                });
            } else {
                affiliates[_affiliate][msg.sender] = Affiliate({
                    amount: affiliate.amount + affiliateReward,
                    timeStamp: block.timestamp,
                    claimed: false
                });
            }
            
            affiliateList[_stageId].push(AffiliateList({
                referrer: _affiliate,
                referee: msg.sender,
                reward: affiliateReward,
                timeStamp: block.timestamp
            }));

            stage.affiliateCount++;
        }

        userDeposited[_stageId][msg.sender] += depositAmount;
        stage.totalSale += depositAmount;

        emit Deposit(msg.sender, _stageId, depositAmount, _affiliate);
    }

    function claim(uint256 _stageId) external {
        require(_stageId < stages.length, "Presale: Invalid stage ID");

        Stage storage stage = stages[_stageId];
        require(block.timestamp > stage.timeToClaim, "Presale: Invalid claim time!");
        require(userDeposited[_stageId][msg.sender] > 0, "Presale: Invalid claim amount!");

        uint256 vested = 0;
        vested = calculateVestedAmount(_stageId, msg.sender);
        require(vested > 0, "Presale: No vested tokens available for claim");
        
        uint256 lastClaimed = userLastClaimed[_stageId][msg.sender];
        require(block.timestamp >= lastClaimed + MONTH, "Presale: Can only claim once per month");

        userClaimed[_stageId][msg.sender] += vested;
        userLastClaimed[_stageId][msg.sender] = block.timestamp;
        
        emit Claim(msg.sender, _stageId, vested, block.timestamp);
        
        schAddress.transfer(msg.sender, (vested / (10 ** saleAddress.decimals())) * (10 ** schAddress.decimals()));

    }

    function calculateVestedAmount(uint256 _stageId, address _user) public view returns (uint256) {
        Stage storage stage = stages[_stageId];
        uint256 deposited = userDeposited[_stageId][_user];
        uint256 claimed = userClaimed[_stageId][_user];
        uint256 vestedAmount = (deposited * DENOMINATOR) / stage.price;
        uint256 timeElapsed = block.timestamp - stage.timeToClaim;

        if (timeElapsed >= stage.timeToClaim + stage.vestingPeriod * MONTH) {
            return vestedAmount - claimed;
        }

        uint256 monthsElapsed = timeElapsed / MONTH;

        uint256 monthlyVesting = vestedAmount / stage.vestingPeriod;

        uint256 vested = monthlyVesting * (monthsElapsed + 1);

        if (vested > vestedAmount) {
            vested = vestedAmount;
        }

        return vested - claimed;
    }

    function claimAffiliateReward(address _referrer) external {
        Affiliate memory affiliate = affiliates[msg.sender][_referrer];
        require(affiliate.amount > 0, "Presale: No affiliate rewards");

        affiliates[msg.sender][_referrer] = Affiliate({
            amount: affiliate.amount,
            timeStamp: affiliate.timeStamp,
            claimed: true
        });

        saleAddress.transfer(msg.sender, affiliate.amount);

        emit AffiliateRewardClaimed(msg.sender, _referrer, affiliate.amount, block.timestamp);
    }

    function RescueFunds(uint256 amount) external onlyOwners {
        uint256 balance = saleAddress.balanceOf(address(this));
        require(amount <= balance, "Presale: Insufficient amount");
        saleAddress.transfer(msg.sender, amount);

        emit Withdrawal(msg.sender, amount, "saleToken");
    }

    function RescueToken(uint256 amount) external onlyOwners {
        uint256 balance = schAddress.balanceOf(address(this));
        require(amount <= balance, "Presale: Insufficient amount");
        schAddress.transfer(msg.sender, amount);

        emit Withdrawal(msg.sender, amount, "schToken");
    }

    function setSaleTokenAddress(address _address) external onlyOwners {
        saleAddress = IERC20(_address);

        emit SaleAddressUpdated(_address);
    }

    function getRoundCount() public view returns (uint256) {
        return stages.length;
    }
}