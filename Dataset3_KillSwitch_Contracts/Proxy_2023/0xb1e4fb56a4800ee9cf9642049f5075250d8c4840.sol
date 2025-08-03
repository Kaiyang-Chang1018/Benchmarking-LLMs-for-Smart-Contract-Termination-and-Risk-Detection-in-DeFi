// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

// File: contracts/NFTStake/Stake.sol


pragma solidity ^0.8.0;




interface INFTMinter {
    function nftcallermint(address recipient, uint256 count)
        external
        returns (bool);
}

contract StakeNFT is Context, ReentrancyGuard {
    struct ClaimInfo {
        bool hasClaimedNFT;
        bool hasRefundedETH;
        uint256 refundAmount;
        uint256 transferAmount;
        uint256 nftCount;
    }

    struct Stake {
        uint256 id;
        address staker;
        uint256 price;
        uint256 timestamp;
    }

    event StakeEV(
        address indexed staker,
        uint256 indexed id,
        uint256 indexed timestamp,
        uint256 price
    );
    event Airdrop(
        address indexed staker,
        uint256 indexed nftAmount,
        uint256 indexed transferAmount
    );
    event Refund(address indexed staker, uint256 indexed refundAmount);
    event RaffleWon(uint256 indexed winner);

    address public immutable manager; /// The address of the contract manager.
    address public nftAddress; ///The address of the NFT contract.
    address public revenueWallet; ///The address of the wallet where revenue from NFT mints will be sent.
    uint256 public allstakeStart; ///The start time of the staking period.
    uint256 public allstakeEnd; ///The end time of the staking period.
    uint256 public GTDStart; ///The start time of the GTD whitelist staking period.
    uint256 public GTDEnd; ///The end time of the GTD whitelist staking period.
    uint256 public BackupEnd; ///The end time of the backup staking period.
    uint256 public revealRaffle; /// The time when the raffle will be revealed.
    uint256 public refundTime; /// The time when the user to airdrop/refund.
    uint256 private _counter;
    uint256 private immutable _ExtendAllstakeEnd;
    uint256 private immutable _ExtendGTDEnd;
    uint256 private immutable _ExtendBackupEnd;
    uint256 private immutable _ExtendRaffleEnd;
    uint256 private immutable _ExtendRefundTime;
    uint256 public immutable raffleCount; ///The number of NFTs that will be awarded to stakers during the raffle.
    uint256 public remainRaffleCount; ///The number of NFTs that will be awarded to stakers during the raffle.
    uint256 public avaWLCount; ///The number of NFTs that are available for Backup staking.
    uint256 public constant WHITESTAKEPRICE = 0.3 ether;
    uint256 public constant PUBLICSTAKEPRICE = 0.4 ether;
    uint256 public constant ONEDAY = 1 days;
    uint256 private executeNumber;
    uint256 private seedsInitialized;
    string public seeds;
    address[] public stakes;
    uint256[] private _publicStakesId; ///The array of staking ids in the allstakeStart~allstakeEnd period.
    uint256[] private _whiteStakesId; ///The array of staking ids in the GTDStart~BackupEnd period.

    mapping(address => bool) private _inStakes; ///Maps sender to whether he is in the staking array or not.
    mapping(address => uint256[]) private _userStakes; ///Maps stakers to their all staking IDs.
    mapping(uint256 => Stake) public stakeIdInfo; ///Maps staking IDs to their staking information.
    mapping(address => bool) public hasClaimedNFT; ///Maps stakers to whether they have claimed their NFTs or not.
    mapping(address => bool) public hasRefundedETH; ///Maps stakers to whether they have received a refund or not.
    mapping(uint256 => bool) public raffleWon; ///Maps staking IDs to whether they have won the raffle or not.
    mapping(address => bool) public GTDAddress; ///Maps sender to whether they are GTD whitelisted or not.
    mapping(address => uint256) public GTDTickets; ///Maps GTD whitelisted sender to their allowed staking number.
    mapping(address => bool) public BackupAddress; ///Maps sender to whether they are Backup whitelisted or not.
    mapping(address => bool) public BackupStaked; ///Maps Backup whitelisted sender to whether they have staked or not.

    constructor(
        address _manager,
        address _nftAddress,
        address _revenueWallet,
        uint256 _raffleCount,
        uint256 _avaWLCount,
        uint256 _allstakeStart,
        uint256 _allstakeEnd,
        uint256 _GTDStart,
        uint256 _GTDEnd,
        uint256 _BackupEnd,
        uint256 _revealRaffle,
        uint256 _refundTime
    ) {
        require(
            _allstakeEnd >= _allstakeStart,
            "allstakeStart less than allstakeEnd"
        );
        require(_GTDEnd >= _GTDStart, "GTDEnd less than GTDStart");
        require(_BackupEnd >= _GTDEnd, "BackupEnd less than GTDEnd");
        require(
            _revealRaffle >= _BackupEnd,
            "revealRaffle less than BackupEnd"
        );
        require(
            _refundTime >= _revealRaffle,
            "refundTime less than revealRaffle"
        );
        require(_manager != address(0), "invalid _manager address");
        require(_nftAddress != address(0), "invalid _nftAddress address");
        require(_revenueWallet != address(0), "invalid _revenueWallet address");
        manager = _manager;
        nftAddress = _nftAddress;
        revenueWallet = _revenueWallet;
        raffleCount = _raffleCount;
        remainRaffleCount = raffleCount;
        avaWLCount = _avaWLCount;
        allstakeStart = _allstakeStart;
        allstakeEnd = _allstakeEnd;
        _ExtendAllstakeEnd = ONEDAY + allstakeEnd;
        GTDStart = _GTDStart;
        GTDEnd = _GTDEnd;
        _ExtendGTDEnd = ONEDAY + GTDEnd;
        BackupEnd = _BackupEnd;
        _ExtendBackupEnd = ONEDAY + BackupEnd;
        revealRaffle = _revealRaffle;
        _ExtendRaffleEnd = ONEDAY + revealRaffle;
        refundTime = _refundTime;
        _ExtendRefundTime = refundTime + refundTime;
    }

    modifier onlyManager() {
        require(_msgSender() == manager, "ONLY_MANAGER_ROLE");
        _;
    }

    /// @notice  update revenueWallet.
    function setRevenueWallet(address addr) external onlyManager {
        require(addr != address(0), "invalid address");
        revenueWallet = addr;
    }

    /// @notice  update nftAddress.
    function setNftAddress(address addr) external onlyManager {
        require(addr != address(0), "invalid address");
        require(block.timestamp <= refundTime, "Staking end");
        nftAddress = addr;
    }

    /// @notice  update allstakeEnd.
    function setAllEndTime(uint256 time) external onlyManager {
        require(time <= _ExtendAllstakeEnd, "exceed maximum period");
        require(time >= allstakeStart, "must more than allstakeStart time");
        allstakeEnd = time;
    }

    /// @notice  update GTDEnd.
    function setGTDEndTime(uint256 time) external onlyManager {
        require(time <= _ExtendGTDEnd, "exceed maximum period");
        require(time >= GTDStart, "must more than GTDStart time");
        GTDEnd = time;
    }

    /// @notice  update BackupEnd.
    function setBackupEndTime(uint256 time) external onlyManager {
        require(time <= _ExtendBackupEnd, "exceed maximum period");
        require(time >= GTDEnd, "must more than GTDEnd time");
        BackupEnd = time;
    }

    /// @notice  update revealRaffle.
    function setRaffleTime(uint256 time) external onlyManager {
        require(time <= _ExtendRaffleEnd, "exceed maximum period");
        require(time >= BackupEnd, "must more than BackupEnd time");
        revealRaffle = time;
    }

    /// @notice  update refundTime.
    function setOperationTime(uint256 time) external onlyManager {
        require(time <= _ExtendRefundTime, "exceed maximum period");
        require(time >= revealRaffle, "must more than revealRaffle");
        refundTime = time;
    }

    /// @notice  set non-duplicated GTD whitelist address and their allowed staking tickets.
    function setGTDlist(
        address[] calldata GTDAddrs,
        uint256[] calldata GTDTicks
    ) external onlyManager {
        uint256 GTDAddrLength = GTDAddrs.length;
        uint256 GTDTickslength = GTDTicks.length;
        require(GTDAddrLength == GTDTickslength, "Mismatched length");
        address waddr;
        uint256 ticket;
        for (uint256 i = 0; i < GTDTickslength; i++) {
            waddr = GTDAddrs[i];
            ticket = GTDTicks[i];
            GTDAddress[waddr] = true;
            GTDTickets[waddr] = ticket;
        }
    }

    /// @notice  set non-duplicated Backup whitelist address.
    function setBackuplist(address[] calldata BackupAddrs)
        external
        onlyManager
    {
        address waddr;
        uint256 length = BackupAddrs.length;
        for (uint256 i = 0; i < length; i++) {
            waddr = BackupAddrs[i];
            BackupAddress[waddr] = true;
        }
    }

    /// @notice Allows users to stake ETH during a certain period of time.
    function allStake() external payable {
        require(
            block.timestamp >= allstakeStart,
            "StakeNFT: public stake not start"
        );
        require(block.timestamp <= allstakeEnd, "StakeNFT: public stake ended");
        uint256 value = msg.value;
        require(value != 0, "StakeNFT: invalid staking value");
        require(
            value % PUBLICSTAKEPRICE == 0,
            "StakeNFT: invalid staking value"
        );
        uint256 tickets = value / PUBLICSTAKEPRICE;
        for (uint256 i = 0; i < tickets; i++) {
            uint256 newId = uint256(keccak256(abi.encodePacked(_counter)));
            _counter += 1;
            Stake memory newStake = Stake(
                newId,
                _msgSender(),
                PUBLICSTAKEPRICE,
                block.timestamp
            );
            _userStakes[_msgSender()].push(newId);
            _publicStakesId.push(newId);
            stakeIdInfo[newId] = newStake;
            emit StakeEV(
                _msgSender(),
                newId,
                block.timestamp,
                PUBLICSTAKEPRICE
            );
        }
        if (!_inStakes[_msgSender()]) {
            _inStakes[_msgSender()] = true;
            stakes.push(_msgSender());
        }
    }

    /// @notice  Allows users who have been GTDwhitelisted to stake NFTs during a separate period of time.
    function GTDStake() external payable {
        require(block.timestamp >= GTDStart, "StakeNFT: GTD not start");
        require(block.timestamp < GTDEnd, "StakeNFT: GTD ended");
        require(GTDAddress[_msgSender()], "StakeNFT: not GTD address");
        uint256 tickets = GTDTickets[_msgSender()];
        require(tickets != 0, "StakeNFT: no qualifications left");
        uint256 value = msg.value;
        require(value != 0, "StakeNFT: invalid staking value");
        require(
            value % WHITESTAKEPRICE == 0,
            "StakeNFT: invalid staking value"
        );
        require(
            value <= tickets * WHITESTAKEPRICE,
            "StakeNFT: exceed maximum staking value"
        );

        tickets = value / WHITESTAKEPRICE;
        require(
            tickets <= avaWLCount,
            "StakeNFT: exceed maximum left staking qualifications"
        );
        avaWLCount -= tickets;
        GTDTickets[_msgSender()] -= tickets;
        for (uint256 i = 0; i < tickets; i++) {
            uint256 newId = uint256(keccak256(abi.encodePacked(_counter)));
            _counter += 1;
            Stake memory newStake = Stake(
                newId,
                _msgSender(),
                WHITESTAKEPRICE,
                block.timestamp
            );
            _userStakes[_msgSender()].push(newId);
            _whiteStakesId.push(newId);
            stakeIdInfo[newId] = newStake;
            emit StakeEV(_msgSender(), newId, block.timestamp, WHITESTAKEPRICE);
        }
        if (!_inStakes[_msgSender()]) {
            _inStakes[_msgSender()] = true;
            stakes.push(_msgSender());
        }
    }

    /// @notice  Allows users who have been Backupwhitelisted to stake NFTs during a separate period of time.
    function backupStake() external payable {
        require(avaWLCount != 0, "StakeNFT: no stake qualifications left");
        require(block.timestamp >= GTDEnd, "StakeNFT: Backup not start");
        require(block.timestamp <= BackupEnd, "StakeNFT: Backup ended");
        require(BackupAddress[_msgSender()], "StakeNFT: not Backup address");

        uint256 value = msg.value;
        require(value == WHITESTAKEPRICE, "StakeNFT: invalid staking value");
        require(!BackupStaked[_msgSender()], "StakeNFT: already staked");
        avaWLCount -= 1;
        BackupStaked[_msgSender()] = true;

        uint256 newId = uint256(keccak256(abi.encodePacked(_counter)));
        _counter += 1;
        Stake memory newStake = Stake(
            newId,
            _msgSender(),
            WHITESTAKEPRICE,
            block.timestamp
        );
        _userStakes[_msgSender()].push(newId);
        _whiteStakesId.push(newId);
        stakeIdInfo[newId] = newStake;
        if (!_inStakes[_msgSender()]) {
            _inStakes[_msgSender()] = true;
            stakes.push(_msgSender());
        }
        emit StakeEV(_msgSender(), newId, block.timestamp, WHITESTAKEPRICE);
    }

    /// @notice  Input random seeds.
    /// @param seed The random seed generated off-chain, which is a public and random info that could be verified anytime and anyone.
    function raffleSeed(string memory seed) external onlyManager {
        require(seedsInitialized == 0, "seeds already initialized");
        require(
            block.timestamp >= BackupEnd,
            "StakeNFT: raffle seeds not start"
        );
        require(block.timestamp <= refundTime, "StakeNFT: raffle seeds ended");
        seedsInitialized = 1;
        seeds = seed;
    }

    /// @notice  Executes a raffle to determine which stakers win NFTs.
    /// @param count The count determines how many stakes will be executed raffle in this loop condition.
    function executeRaffle(uint256 count) external {
        require(seedsInitialized == 1, "seeds not initialized");
        uint256 length = _publicStakesId.length;
        if (length <= raffleCount) {
            uint256 ncount = executeNumber + count >= length
                ? length
                : executeNumber + count;
            uint256 temp = executeNumber;
            executeNumber = ncount;
            for (uint256 i = temp; i < ncount; i++) {
                uint256 stakeid = _publicStakesId[i];
                raffleWon[stakeid] = true;
                emit RaffleWon(stakeid);
            }
        } else {
            if (count > remainRaffleCount) {
                count = remainRaffleCount;
            }
            remainRaffleCount -= count;
            for (uint256 i = 0; i < count; i++) {
                executeNumber++;
                uint256 index = uint256(
                    keccak256(abi.encodePacked(seeds, executeNumber, i))
                ) % length;
                uint256 stakeid = _publicStakesId[index];
                while (raffleWon[stakeid]) {
                    index = index < length - 1 ? index + 1 : 0;
                    stakeid = _publicStakesId[index];
                }
                raffleWon[stakeid] = true;
                emit RaffleWon(stakeid);
            }
        }
    }

    /// @notice   Returns information about a staker's stake, including whether they have claimed their NFTs or received a refund
    function claimInfo() external view returns (ClaimInfo memory info) {
        info = claimInfo(_msgSender());
    }

    function claimInfo(address addr)
        public
        view
        returns (ClaimInfo memory info)
    {
        if (block.timestamp < revealRaffle) {
            return info;
        }
        info.hasRefundedETH = hasRefundedETH[addr];
        info.hasClaimedNFT = hasClaimedNFT[addr];
        info.refundAmount = 0;
        info.nftCount = 0;
        info.transferAmount = 0;
        uint256[] memory stakedId = _userStakes[addr];
        uint256 length = stakedId.length;
        for (uint256 i = 0; i < length; i++) {
            uint256 stakeId = stakedId[i];
            Stake memory stakeInfo = stakeIdInfo[stakeId];
            uint256 stakedPrice = stakeInfo.price;
            if (stakedPrice == WHITESTAKEPRICE || raffleWon[stakeId]) {
                info.nftCount += 1;
                info.transferAmount += stakedPrice;
            } else {
                info.refundAmount += stakedPrice;
            }
        }
    }

    /// @notice   Airdrop stakers NFTs if they have won the raffle.
    /// @param start The start determines the start position of the stakers array in this loop condition.
    /// @param count The count determines how many stakes will be airdroped in this loop condition.
    function airdrop(uint256 start, uint256 count) external nonReentrant {
        require(block.timestamp >= refundTime, "StakeNFT: airdrop not start");
        uint256 length = stakes.length;
        uint256 ncount = start + count >= length ? length : start + count;
        for (uint256 j = start; j < ncount; j++) {
            address staker = stakes[j];
            ClaimInfo memory info = claimInfo(staker);
            if (!info.hasClaimedNFT) {
                hasClaimedNFT[staker] = true;
                if (info.transferAmount != 0) {
                    Address.sendValue(
                        payable(revenueWallet),
                        info.transferAmount
                    );
                }

                if (info.nftCount != 0) {
                    require(
                        INFTMinter(nftAddress).nftcallermint(
                            staker,
                            info.nftCount
                        ),
                        "nftcallermint failed"
                    );
                }
                emit Airdrop(staker, info.nftCount, info.transferAmount);
            }
        }
    }

    /// @notice   Allows stakers to receive a refund if they have not won the raffle.
    function refund() external nonReentrant {
        require(block.timestamp >= refundTime, "StakeNFT: refund not start");
        address staker = _msgSender();
        ClaimInfo memory info = claimInfo(staker);

        require(!info.hasRefundedETH, "StakeNFT: has refunded");
        require(info.refundAmount > 0, "StakeNFT: nothing to refund");

        hasRefundedETH[staker] = true;
        Address.sendValue(payable(staker), info.refundAmount);

        emit Refund(staker, info.refundAmount);
    }

    /**************** View Functions ****************/
    function tvl() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserStakes(
        address addr,
        uint256 start,
        uint256 count
    ) external view returns (Stake[] memory stakesinfo) {
        uint256[] memory stakeId = getUserTickets(addr, start, count);
        uint256 length = stakeId.length;
        stakesinfo = new Stake[](length);
        for (uint256 j = 0; j < length; j++) {
            uint256 id = stakeId[j];
            stakesinfo[j] = stakeIdInfo[id];
        }
    }

    function getUserTickets(
        address addr,
        uint256 start,
        uint256 count
    ) public view returns (uint256[] memory) {
        uint256 length = _userStakes[addr].length;
        uint256 ncount = start + count >= length ? length : start + count;
        uint256 index;
        uint256 arraylen = ncount - start;
        uint256[] memory usertickets = new uint256[](arraylen);
        for (uint256 j = start; j < ncount; j++) {
            usertickets[index] = _userStakes[addr][j];
            index++;
        }
        return usertickets;
    }

    function getWhiStakeIds() external view returns (uint256) {
        return _whiteStakesId.length;
    }

    function getWhiStakeIdInfo() external view returns (uint256[] memory) {
        return _whiteStakesId;
    }

    function getPubStakeIds() external view returns (uint256) {
        return _publicStakesId.length;
    }

    function getPubStakeIdInfo() external view returns (uint256[] memory) {
        return _publicStakesId;
    }

    function getRaffledId(uint256 start, uint256 count)
        external
        view
        returns (uint256[] memory raffleIds)
    {
        if (block.timestamp < revealRaffle) {
            return raffleIds;
        }
        uint256 length = _publicStakesId.length;
        uint256 ncount = start + count >= length ? length : start + count;
        uint256 counts = ncount - start;
        uint256[] memory raffleId = new uint256[](counts);
        uint256 index;

        for (uint256 j = start; j < ncount; j++) {
            uint256 stakeid = _publicStakesId[j];
            if (raffleWon[stakeid]) {
                raffleId[index] = stakeid;
                index++;
            }
        }
        return raffleId;
    }
}