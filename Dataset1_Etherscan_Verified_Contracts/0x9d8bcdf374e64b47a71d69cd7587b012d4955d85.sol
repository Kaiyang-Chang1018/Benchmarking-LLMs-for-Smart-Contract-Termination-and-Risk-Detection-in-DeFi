// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

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
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
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
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IFeeDistributor {
    function updateUserStake(
        address user,
        uint256 previousAdjustedStake,
        uint256 newAdjustedStake
    ) external;
}

contract YieldManagerOutpostV2 is ReentrancyGuard {

    address public owner;

    // pending owner
    address public _pendingOwner;

    // FeeDistributor contract address
    address public feeDistributor;

    // User's adjusted stake (after applying multiplicators)
    mapping(address => uint256) public userAdjustedStake;

    // Total adjusted stake across all users
    uint256 public totalAdjustedStake;

    // Bool to check if the fee distributor should get updated
    bool public isUpdatingFeeDistributor;

    mapping(address => address) public affiliateLookup;
    mapping(address => bool) public setAffiliateFactorAddress;
    mapping(address => bool) public canSetSponsor;
    mapping(address => uint) public userLevel;

    event AffiliateSet(address indexed sponsor, address indexed client);
    event NewOwner(address owner);
    event NewCanSetSponsor(address canSet, bool status);
    event SetAffiliateFactorAddressUpdated(address setAffiliateFactorAddress, bool allowed);
    event UserLevelSet(address user, uint level);
    event OwnerChanged(address oldOwner, address newOwner);
    event ChangedIsUpdatingFeeDistributor(bool changed);
    event UserAdjustedStakeUpdated(address indexed user, uint256 newAdjustedStake);
    event FeeDistributorChanged(address oldAddress, address newAddress);

    // struct configStruct
    // val1 client:  withdrawal fee sponsor: % of fee
    struct configStruct {
        uint level;
        uint val1;
        uint val2;
        uint val3;
        uint val4;
    }

    configStruct[] public clientLevels;
    configStruct[] public sponsorLevels;

    // only owner modifier
    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
        setAffiliateFactorAddress[owner] = true;
        isUpdatingFeeDistributor = true;

        // Initial client levels setup
        clientLevels.push(configStruct(0, 0, 3000, 100, 200));
        clientLevels.push(configStruct(500 * 10 ** 18, 0, 2850, 100, 200));
        clientLevels.push(configStruct(2500 * 10 ** 18, 0, 2700, 100, 200));
        clientLevels.push(configStruct(5000 * 10 ** 18, 0, 2500, 100, 200));
        clientLevels.push(configStruct(10000 * 10 ** 18, 0, 2400, 100, 200));
        clientLevels.push(configStruct(25000 * 10 ** 18, 0, 2250, 100, 200));
        clientLevels.push(configStruct(50000 * 10 ** 18, 0, 2100, 75, 200));
        clientLevels.push(configStruct(100000 * 10 ** 18, 0, 1950, 75, 125));
        clientLevels.push(configStruct(250000 * 10 ** 18, 0, 1950, 50, 125));
        clientLevels.push(configStruct(500000 * 10 ** 18, 0, 1800, 50, 125));


        // Initial sponsor levels setup
        sponsorLevels.push(configStruct(0, 0, 0, 0, 0));
        sponsorLevels.push(configStruct(500 * 10 ** 18, 500, 500, 0, 0));
        sponsorLevels.push(configStruct(2500 * 10 ** 18, 1000, 1000, 0, 0));
        sponsorLevels.push(configStruct(5000 * 10 ** 18, 1500, 1500, 0, 0));
        sponsorLevels.push(configStruct(10000 * 10 ** 18, 2000, 2000, 0, 0));
        sponsorLevels.push(configStruct(25000 * 10 ** 18, 2500, 2500, 0, 0));
        sponsorLevels.push(configStruct(50000 * 10 ** 18, 3000, 3000, 0, 0));
        sponsorLevels.push(configStruct(100000 * 10 ** 18, 3500, 3500, 0, 0));
        sponsorLevels.push(configStruct(250000 * 10 ** 18, 4000, 4000, 0, 0));
        sponsorLevels.push(configStruct(500000 * 10 ** 18, 4500, 4500, 0, 0));
    }

    // Function to be called by staking contracts when a user's stake changes
    function updateUserStake(address user, uint256 _userTotalStake) internal nonReentrant {

        // security feature
        if (!isUpdatingFeeDistributor) {
            return;
        }

        uint256 previousAdjustedStake = userAdjustedStake[user];

        // Update user adjusted stake
        uint256 newAdjustedStake = _userTotalStake;
        userAdjustedStake[user] = newAdjustedStake;

        // Update total adjusted stake
        if (newAdjustedStake > previousAdjustedStake) {
            totalAdjustedStake += (newAdjustedStake - previousAdjustedStake);
        } else if (newAdjustedStake < previousAdjustedStake) {
            totalAdjustedStake -= (previousAdjustedStake - newAdjustedStake);
        }

        // Notify FeeDistributor
        IFeeDistributor(feeDistributor).updateUserStake(user, previousAdjustedStake, newAdjustedStake);

        emit UserAdjustedStakeUpdated(user, newAdjustedStake);
    }

    //updates client levels
    function setClientLevels(uint256[] memory levels, uint256[] memory val1s, uint256[] memory val2s, uint256[] memory val3s, uint256[] memory val4s) public onlyOwner {
        require(levels.length == val1s.length, "Length mismatch");
        require(val1s.length == val2s.length, "Length mismatch");
        require(val2s.length == val3s.length, "Length mismatch");
        require(val3s.length == val4s.length, "Length mismatch");
        delete clientLevels;

        for (uint i=0; i<levels.length; i++) {
            clientLevels.push(
                configStruct({
                    level: levels[i],
                    val1: val1s[i],
                    val2: val2s[i],
                    val3: val3s[i],
                    val4: val4s[i]
            })
            );
        }
    }

    //updates client levels
    function setSponsorLevels(uint256[] memory levels, uint256[] memory val1s, uint256[] memory val2s, uint256[] memory val3s, uint256[] memory val4s) public onlyOwner {
        require(levels.length == val1s.length, "Length mismatch");
        require(val1s.length == val2s.length, "Length mismatch");
        require(val2s.length == val3s.length, "Length mismatch");
        require(val3s.length == val4s.length, "Length mismatch");
        delete sponsorLevels;

        for (uint i=0; i<levels.length; i++) {
            sponsorLevels.push(
                configStruct({
                    level: levels[i],
                    val1: val1s[i],
                    val2: val2s[i],
                    val3: val3s[i],
                    val4: val4s[i]
            })
            );
        }
    }

    // returns sponsor
    function getAffiliate(address client) public view returns (address) {
        return affiliateLookup[client];
    }

    function setAffiliate(address client, address sponsor) public {
        require(canSetSponsor[msg.sender], "Not allowed to set sponsor");
        require(affiliateLookup[client] == address(0), "Sponsor already set");
        affiliateLookup[client] = sponsor;
        emit AffiliateSet(sponsor, client);
    }

    function ownerSetAffiliate(address client, address sponsor) public {
        require(setAffiliateFactorAddress[msg.sender], "not allowed to set affiliate");
        affiliateLookup[client] = sponsor;
        emit AffiliateSet(sponsor, client);
    }

    function ownerSetUserLevel(address client, uint level) public {
        require(setAffiliateFactorAddress[msg.sender], "not allowed to set affiliate");
        userLevel[client] = level;

        //update the reward
        updateUserStake(client, level);

        emit UserLevelSet(client, level);
    }

    function getUserFactors(
        address user,
        uint typer
    ) public view returns (uint, uint, uint, uint) {
        uint level = userLevel[user];

        if (typer == 0) {
            // Client levels
            for (uint i = clientLevels.length; i > 0; i--) {
                uint index = i - 1;
                if (level >= clientLevels[index].level) {
                    return (
                        clientLevels[index].val1,
                        clientLevels[index].val2,
                        clientLevels[index].val3,
                        clientLevels[index].val4
                    );
                }
            }
        } else {
            // Sponsor levels
            for (uint i = sponsorLevels.length; i > 0; i--) {
                uint index = i - 1;
                if (level >= sponsorLevels[index].level) {
                    return (
                        sponsorLevels[index].val1,
                        sponsorLevels[index].val2,
                        sponsorLevels[index].val3,
                        sponsorLevels[index].val4
                    );
                }
            }
        }
        return (0, 0, 0, 0); // Default case
    }

    // Function to change the FeeDistributor address
    function changeFeeDistributor(address newFeeDistributor) external onlyOwner {
        require(newFeeDistributor != address(0), "FeeDistributor address cannot be zero");
        address oldAddress = feeDistributor;
        feeDistributor = newFeeDistributor;
        emit FeeDistributorChanged(oldAddress, newFeeDistributor);
    }

    // Function to change the changeIsUpdatingFeeDistributor variable
    function changeIsUpdatingFeeDistributor(bool _isUpdatingFeeDistributor) external onlyOwner {
        isUpdatingFeeDistributor = _isUpdatingFeeDistributor;
        emit ChangedIsUpdatingFeeDistributor(_isUpdatingFeeDistributor);
    }

    /// @notice Initiates the ownership transfer process.
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        _pendingOwner = newOwner;
    }

    /// @notice Accepts the ownership transfer.
    function acceptOwnership() external {
        require(msg.sender == _pendingOwner, "Unauthorized");
        address oldOwner = owner;
        owner = _pendingOwner;
        delete _pendingOwner;
        emit OwnerChanged(oldOwner, owner);
    }

    function setCanSetSponsor(address factoryContract, bool val) external onlyOwner {
        canSetSponsor[factoryContract] = val;
        emit NewCanSetSponsor(factoryContract, val);
    }

    function setSetAffiliateFactorAddress(address setAddress, bool allowed) external onlyOwner {
        setAffiliateFactorAddress[setAddress] = allowed;
        emit SetAffiliateFactorAddressUpdated(setAddress, allowed);
    }
}