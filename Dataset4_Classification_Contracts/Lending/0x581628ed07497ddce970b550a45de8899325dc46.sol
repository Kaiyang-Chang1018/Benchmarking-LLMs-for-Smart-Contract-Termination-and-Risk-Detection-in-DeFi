// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
library Address {
    error AddressInsufficientBalance(address account);

    error AddressEmptyCode(address target);

    error FailedInnerCall();

    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    function _revert(bytes memory returndata) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
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

    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
abstract contract ReentrancyGuard {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 value => uint256) _positions;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 position = set._positions[value];

        if (position != 0) {
            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];
                set._values[valueIndex] = lastValue;
                set._positions[lastValue] = position;
            }
            set._values.pop();
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }
    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        assembly {
            result := store
        }

        return result;
    }
    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;
        assembly {
            result := store
        }

        return result;
    }
}
contract Staking is Ownable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.UintSet;

    struct StakeInfo {
        uint256 id;
        uint256 amount;
        uint256 stakeDate;
        uint256 lastClaimDate;
        uint256 startPeriod;
        uint256 finishPeriod;
    }

    uint256 public startDate;
    uint256 public finishDate;
    uint256 public totalStaked;
    uint256 public totalPenalty;
    uint256 public stakeCount;
    uint256 public penaltyPercentage;
    uint256 public rewardCounter;

    IERC20 public stakingToken;
    IERC20 public rewardToken;

    mapping(address wallet => uint256) public stakeIdCount;
    mapping(address wallet => EnumerableSet.UintSet) private _stakeIdsPerWallet;
    mapping(address wallet => mapping(uint256 id => StakeInfo)) public stakeInfo;

    event Stake(address indexed user, uint256 indexed amount, uint256 indexed stakeId);
    event Unstake(address indexed user, uint256 indexed amount, uint256 indexed stakeId);
    event Claim(address indexed user, uint256 indexed reward, uint256 indexed stakeId);
    event SetPeriod(uint256 indexed startDate, uint256 indexed finishDate);
    
    constructor(address _stakingToken, address _rewardToken, uint256 _penaltyPercentage) Ownable(msg.sender) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        penaltyPercentage = _penaltyPercentage;
    }

    modifier isStakeIdExist(address _user, uint256 _stakeId) {
        bool isExist = _stakeIdsPerWallet[_user].contains(_stakeId);
        require(isExist, "You don't have stake with this stake id");
        _;
    }

    function stake(uint256 _amount) external nonReentrant {
        require(block.timestamp >= startDate && block.timestamp < finishDate, "Cannot stake outside staking period");

        stakingToken.transferFrom(msg.sender, address(this), _amount);
        totalStaked += _amount;
        stakeCount++;

        uint256 stakeId = stakeIdCount[msg.sender];
        _stakeIdsPerWallet[msg.sender].add(stakeId);
        stakeInfo[msg.sender][stakeId] = StakeInfo(stakeId, _amount, block.timestamp, 0, startDate, finishDate);
        stakeIdCount[msg.sender]++;

        emit Stake(msg.sender, _amount, stakeId);
    }

    function unstake(uint256 _id) external nonReentrant isStakeIdExist(msg.sender, _id) {
        uint256 penaltyAmount;
        uint256 amount = stakeInfo[msg.sender][_id].amount;
        uint256 _finishDate = stakeInfo[msg.sender][_id].finishPeriod;
        
        if (block.timestamp < _finishDate) {
            penaltyAmount = amount * penaltyPercentage / 100;
            amount -= penaltyAmount;
            totalPenalty += penaltyAmount;
        }

        _claimReward(msg.sender, _id);
        stakingToken.transfer(msg.sender, amount);
        stakeInfo[msg.sender][_id] = StakeInfo(0, 0, 0, 0, 0, 0);
        _stakeIdsPerWallet[msg.sender].remove(_id);
        totalStaked = totalStaked - (amount + penaltyAmount);
        stakeCount--;

        emit Unstake(msg.sender, amount + penaltyAmount, _id);
    }

    function claimReward(uint _id) public nonReentrant isStakeIdExist(msg.sender, _id) {
        _claimReward(msg.sender, _id);
    }

    function _claimReward(address _user, uint256 _id) private {
        uint256 rewards = calculateReward(_user, _id);
        rewardToken.transfer(_user, rewards);

        stakeInfo[_user][_id].lastClaimDate = block.timestamp > stakeInfo[_user][_id].finishPeriod ? stakeInfo[_user][_id].finishPeriod : block.timestamp;

        emit Claim(_user, rewards, _id);
    }

    function calculateReward(address _user, uint256 _stakeId) public isStakeIdExist(_user, _stakeId) view returns(uint256 rewards) {
        uint256 totalReward = getTotalReward();
        uint256 stakingTokenDecimals = stakingToken.decimals();
        uint256 rewardTokenDecimals = rewardToken.decimals();
        uint256 decimalsDifference = stakingTokenDecimals > rewardTokenDecimals ? stakingTokenDecimals - rewardTokenDecimals : rewardTokenDecimals - stakingTokenDecimals;
        StakeInfo memory _stakeInfo = stakeInfo[_user][_stakeId];
        uint256 convertedAmount = stakingTokenDecimals > rewardTokenDecimals ? _stakeInfo.amount / 10**decimalsDifference : _stakeInfo.amount * 10**decimalsDifference;
        uint256 convertedTotalStaked = stakingTokenDecimals > rewardTokenDecimals ? totalStaked / 10**decimalsDifference : totalStaked * 10**decimalsDifference;
        uint256 lastClaim = _stakeInfo.lastClaimDate > _stakeInfo.stakeDate ? _stakeInfo.lastClaimDate : _stakeInfo.stakeDate;
        uint256 claimTime = block.timestamp > _stakeInfo.finishPeriod ? _stakeInfo.finishPeriod : block.timestamp;
        uint256 stakeDuration = claimTime - lastClaim;
        uint256 stakePeriod = _stakeInfo.finishPeriod - _stakeInfo.startPeriod;
        rewards = (convertedAmount * stakeDuration * totalReward / convertedTotalStaked / stakePeriod);
    }

    function getTotalReward() public view returns(uint256) {
        return rewardCounter;
    }

    function rewardBalance() public view returns (uint256) {
        return  rewardToken.balanceOf(address(this));
    } 

    function getStakeIdList(address _user) public view returns(uint256[] memory stakeIds) {
        stakeIds = _stakeIdsPerWallet[_user].values();
    }

    function getStakeList(address _user) public view returns(StakeInfo[] memory stakeList) {
        uint256[] memory stakeIds = _stakeIdsPerWallet[_user].values();
        stakeList = new StakeInfo[](stakeIds.length);

        for (uint256 i; i < stakeIds.length; i++) 
        {
            stakeList[i] = stakeInfo[_user][stakeIds[i]];
        }
    }

    function setPenaltyPercentage(uint256 _percentage) external onlyOwner {
        penaltyPercentage = _percentage;
    }

    function setStakingRewardToken(address _stakingToken, address _rewardToken) external onlyOwner {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    function setPeriod(uint256 _startDate, uint256 _finishDate) external onlyOwner {
        require(_startDate > block.timestamp, "Start date staking period must be greater than now");
        require(_finishDate > _startDate, "Finish date must be greater than start date");
        startDate = _startDate;
        finishDate = _finishDate;

        emit SetPeriod(_startDate, _finishDate);
    }

    function depositReward(uint256 _amount) external onlyOwner {
        rewardToken.transferFrom(msg.sender, address(this), _amount);
        rewardCounter += _amount;
    }

    function withdrawReward(uint256 _amount) external onlyOwner {
        rewardToken.transfer(msg.sender, _amount);
    }

    function withdrawPenalty() external onlyOwner {
        uint256 penalty = totalPenalty;
        stakingToken.transfer(address(stakingToken), penalty);
        totalPenalty -= penalty;
    }
}