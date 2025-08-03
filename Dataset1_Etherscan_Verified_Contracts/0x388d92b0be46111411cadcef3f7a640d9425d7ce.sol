//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


interface INFT {
    function isRare(uint256 tokenId) external view returns (bool);
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

/**
    Vampire Slayers Staking

    Users can stake tokens and NFTs to earn rewards
    Tokens are the basis of rewards
    NFTs can be added to increase rewards, allowing the user to earn up to the maximum percentage allocated

    Standard NFTs add an additional 12% of rewards
    Rare NFTs add an additional 24% of rewards
 */
contract StakingContract is Ownable, ReentrancyGuard {

    // name and symbol for tokenized contract
    string private _name;
    string private _symbol;
    uint8 private immutable _decimals;

    // lock time in seconds
    uint256 public lockTime;

    // Staking Token
    address public immutable token;

    // Reward Token
    address public immutable reward;

    // NFT Asset
    address public NFT;

    // User Info
    struct UserInfo {
        uint256 amount;
        uint256 rewardAmount;
        uint256 unlockTime;
        uint256 totalExcluded;
        EnumerableSet.UintSet nftsStaked;
    }
    // Address => UserInfo
    mapping ( address => UserInfo ) private userInfo;

    // Tracks Dividends
    uint256 public totalRewards;
    uint256 private totalShares;
    uint256 public totalRewardAmount;
    uint256 private dividendsPerShare;
    uint256 private constant precision = 10**18;

    // Tracks NFTs Staked to Users
    mapping ( uint256 => address ) public ownerOfTokenId;

    // Events
    event SetLockTime(uint LockTime);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(
        address token_, 
        address reward_, 
        address NFT_,
        uint256 lockTime_,
        string memory name_, 
        string memory symbol_
    ){
        require(
            token_ != address(0) &&
            reward_ != address(0) &&
            NFT_ != address(0),
            'Zero Address'
        );
        token = token_;
        reward = reward_;
        NFT = NFT_;
        lockTime = lockTime_;
        _name = name_;
        _symbol = symbol_;
        _decimals = IERC20(token_).decimals();

        emit Transfer(address(0), msg.sender, 0);
    }

    /** Returns the total number of tokens in existence */
    function totalSupply() external view returns (uint256) { 
        return totalShares; 
    }

    /** Returns the number of tokens owned by `account` */
    function balanceOf(address account) public view returns (uint256) { 
        return userInfo[account].amount;
    }

    /** Token Name */
    function name() public view returns (string memory) {
        return _name;
    }

    /** Token Ticker Symbol */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /** Tokens decimals */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function setLockTime(uint256 newLockTime) external onlyOwner {
        require(
            newLockTime <= 10**7,
            'Lock Time Too Long'
        );
        lockTime = newLockTime;
        emit SetLockTime(newLockTime);
    }

    function withdrawForeignToken(address token_) external onlyOwner {
        require(
            token != token_,
            'Cannot Withdraw Staked Token'
        );
        require(
            IERC20(token_).transfer(
                msg.sender,
                IERC20(token_).balanceOf(address(this))
            ),
            'Failure On Token Withdraw'
        );
    }

    function setNFT(address newNFT) external onlyOwner {
        require(
            newNFT != address(0),
            'Zero Address'
        );
        NFT = newNFT;
    }

    function claimRewards() external nonReentrant {
        _claimReward(msg.sender);
    }

    function withdraw(uint256 amount, uint256[] calldata nftIds) external nonReentrant {
        require(
            amount <= userInfo[msg.sender].amount,
            'Insufficient Amount'
        );
        require(
            amount > 0,
            'Zero Amount'
        );

        // claim rewards for user
        _claimReward(msg.sender);

        // reduce total shares
        totalShares -= amount;
        userInfo[msg.sender].amount -= amount;

        // ensure user owns all these nfts
        uint len = nftIds.length;
        for (uint i = 0; i < len;) {
            require(INFT(NFT).ownerOf(nftIds[i]) == address(this), 'Not Staked');
            require(ownerOfTokenId[nftIds[i]] == msg.sender, 'Not Token Owner');
            require(EnumerableSet.contains(userInfo[msg.sender].nftsStaked, nftIds[i]), 'Not Registered In Contract');

            // remove nft from users staked nfts
            EnumerableSet.remove(userInfo[msg.sender].nftsStaked, nftIds[i]);

            // remove internal ownership of nft
            delete ownerOfTokenId[nftIds[i]];

            // send nft to user
            INFT(NFT).transferFrom(address(this), msg.sender, nftIds[i]);

            // ensure nft was sent correctly
            require(INFT(NFT).ownerOf(nftIds[i]) != address(this), 'Error on Transfer');

            unchecked { ++i; }
        }

        if (userInfo[msg.sender].amount == 0) {
            unchecked {
                totalRewardAmount -= userInfo[msg.sender].rewardAmount;
            }
            delete userInfo[msg.sender].rewardAmount;
        } else {
            // determine how many of the users remaining nfts are rare vs standard
            (uint16 numRare, uint16 numStandard) = fetchRarities(EnumerableSet.values(userInfo[msg.sender].nftsStaked));

            // determine users reward amount based on NFTs
            uint256 rewardAmount = determineRewardAmount(userInfo[msg.sender].amount, numRare, numStandard);
            if (rewardAmount > userInfo[msg.sender].rewardAmount) {
                unchecked {
                    totalRewardAmount += ( rewardAmount - userInfo[msg.sender].rewardAmount );
                    userInfo[msg.sender].rewardAmount = rewardAmount;
                }
            } else {
                unchecked {
                    totalRewardAmount -= ( userInfo[msg.sender].rewardAmount - rewardAmount );
                    userInfo[msg.sender].rewardAmount = rewardAmount;
                }
            }
        }

        // update total excluded to reset pending rewards
        userInfo[msg.sender].totalExcluded = getCumulativeDividends(userInfo[msg.sender].rewardAmount);

        // send tokens back to users
        require(
            IERC20(token).transfer(msg.sender, amount),
            'Failure On Token Transfer To Sender'
        );
        emit Transfer(msg.sender, address(0), amount);
    }


    function ownerStake(address user, uint256 amount, uint256[] calldata tokenIds) external onlyOwner {

        // get tokenId length for gas savings
        uint256 len = tokenIds.length;

        // loop through tokenIds, transferring them in
        for (uint i = 0; i < len;) {
            require(INFT(NFT).ownerOf(tokenIds[i]) == address(this), 'Not Token Owner');
            ownerOfTokenId[tokenIds[i]] = user;
            EnumerableSet.add(userInfo[user].nftsStaked, tokenIds[i]);
            unchecked { ++i; }
        }
        
        // update data
        unchecked {
            totalShares += amount;
            userInfo[user].amount += amount;
            userInfo[user].unlockTime = ( block.timestamp + lockTime ) - 1 days;
        }

        // determine how many of the users nfts are rare vs standard
        (uint16 numRare, uint16 numStandard) = fetchRarities(EnumerableSet.values(userInfo[user].nftsStaked));

        // determine users reward amount based on NFTs
        uint256 rewardAmount = determineRewardAmount(userInfo[user].amount, numRare, numStandard);
        if (rewardAmount > userInfo[user].rewardAmount) {
            unchecked {
                totalRewardAmount += ( rewardAmount - userInfo[user].rewardAmount );
                userInfo[user].rewardAmount = rewardAmount;
            }
        } else {
            unchecked {
                totalRewardAmount -= ( userInfo[user].rewardAmount - rewardAmount );
                userInfo[user].rewardAmount = rewardAmount;
            }
        }

        // update total excluded to reset pending rewards
        userInfo[user].totalExcluded = getCumulativeDividends(userInfo[user].rewardAmount);

        emit Transfer(address(0), user, amount);
    }


    function stake(uint256 amount, uint256[] calldata tokenIds) external nonReentrant {
        if (userInfo[msg.sender].rewardAmount > 0) {
            _claimReward(msg.sender);
        }

        // get tokenId length for gas savings
        uint256 len = tokenIds.length;

        // loop through tokenIds, transferring them in
        for (uint i = 0; i < len;) {
            require(INFT(NFT).ownerOf(tokenIds[i]) == msg.sender, 'Not Token Owner');
            INFT(NFT).transferFrom(msg.sender, address(this), tokenIds[i]);
            require(INFT(NFT).ownerOf(tokenIds[i]) == address(this), 'Error on Transfer');
            ownerOfTokenId[tokenIds[i]] = msg.sender;
            EnumerableSet.add(userInfo[msg.sender].nftsStaked, tokenIds[i]);
            unchecked { ++i; }
        }

        // transfer in tokens
        uint received = _transferIn(token, amount);
        
        // update data
        unchecked {
            totalShares += received;
            userInfo[msg.sender].amount += received;
            userInfo[msg.sender].unlockTime = block.timestamp + lockTime;
        }

        // determine how many of the users nfts are rare vs standard
        (uint16 numRare, uint16 numStandard) = fetchRarities(EnumerableSet.values(userInfo[msg.sender].nftsStaked));

        // determine users reward amount based on NFTs
        uint256 rewardAmount = determineRewardAmount(userInfo[msg.sender].amount, numRare, numStandard);
        if (rewardAmount > userInfo[msg.sender].rewardAmount) {
            unchecked {
                totalRewardAmount += ( rewardAmount - userInfo[msg.sender].rewardAmount );
                userInfo[msg.sender].rewardAmount = rewardAmount;
            }
        } else {
            unchecked {
                totalRewardAmount -= ( userInfo[msg.sender].rewardAmount - rewardAmount );
                userInfo[msg.sender].rewardAmount = rewardAmount;
            }
        }

        // update total excluded to reset pending rewards
        userInfo[msg.sender].totalExcluded = getCumulativeDividends(userInfo[msg.sender].rewardAmount);

        emit Transfer(address(0), msg.sender, amount);
    }

    function depositRewards(uint256 amount) external nonReentrant {
        if (totalRewardAmount == 0) {
            return;
        }
        
        // transfer in reward token
        uint received = _transferIn(reward, amount);

        // update state
        unchecked {
            dividendsPerShare += ( received * precision ) / totalRewardAmount;
            totalRewards += received;
        }        
    }


    function _claimReward(address user) internal {

        // exit if zero value locked
        if (userInfo[user].rewardAmount == 0) {
            return;
        }

        // fetch pending rewards
        uint256 amount = pendingRewards(user);
        
        // exit if zero rewards
        if (amount == 0) {
            return;
        }

        // update total excluded
        userInfo[user].totalExcluded = getCumulativeDividends(userInfo[user].rewardAmount);

        // transfer reward to user
        require(
            IERC20(reward).transfer(user, amount),
            'Failure On Token Claim'
        );
    }

    function _transferIn(address _token, uint256 amount) internal returns (uint256) {
        uint before = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transferFrom(msg.sender, address(this), amount);
        uint After = IERC20(_token).balanceOf(address(this));
        require(
            After > before,
            'Error On TransferIn'
        );
        return After - before;
    }

    function timeUntilUnlock(address user) public view returns (uint256) {
        return userInfo[user].unlockTime < block.timestamp ? 0 : userInfo[user].unlockTime - block.timestamp;
    }

    function determineRewardAmount(uint256 numTokens, uint16 numRare, uint16 numStandard) public pure returns (uint256 rewardPoints) {
        // max is 100x numTokens
        // min is 4x numTokens
        // rewardAmount = ( 4 * numTokens ) + ( numRare * 24 * numTokens ) + ( numStandard * 12 * numTokens)
        // rewardAmount = numTokens * Math.min(( 4 + ( numRare * 24 ) + ( numStandard * 12 ) ), 100)
        return ( numTokens * clamp(4 + ( numRare * 24 ) + ( numStandard * 12 ), 100) );
    }

    function clamp(uint256 value, uint256 max) public pure returns (uint256) {
        return value > max ? max : value;
    }

    function fetchRarities(uint256[] memory tokenIds) public view returns (uint16 numRare, uint16 numStandard) {
        uint len = tokenIds.length;
        for (uint i = 0; i < len;) {
            if (INFT(NFT).isRare(tokenIds[i])) {
                unchecked { ++numRare; }
            } else {
                unchecked { ++numStandard; }
            }
            unchecked { ++i; }
        }
    }

    function pendingRewards(address shareholder) public view returns (uint256) {
        if(userInfo[shareholder].rewardAmount == 0){ return 0; }

        uint256 totalDividends = getCumulativeDividends(userInfo[shareholder].rewardAmount);
        uint256 tExcluded = userInfo[shareholder].totalExcluded;

        if(totalDividends <= tExcluded){ return 0; }

        return totalDividends <= tExcluded ? 0 : totalDividends - tExcluded;
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return ( share * dividendsPerShare ) / precision;
    }

    function getNFTsStaked(address user) external view returns (uint256[] memory) {
        return EnumerableSet.values(userInfo[user].nftsStaked);
    }

    function getUserInfo(address user) external view returns(
        uint256 amount,
        uint256 rewardAmount,
        uint256 unlockTime,
        uint256 totalExcluded,
        uint256[] memory nftsStaked
    ) {
        return (userInfo[user].amount, userInfo[user].rewardAmount, userInfo[user].unlockTime, userInfo[user].totalExcluded, EnumerableSet.values(userInfo[user].nftsStaked));
    }

    receive() external payable {}

}