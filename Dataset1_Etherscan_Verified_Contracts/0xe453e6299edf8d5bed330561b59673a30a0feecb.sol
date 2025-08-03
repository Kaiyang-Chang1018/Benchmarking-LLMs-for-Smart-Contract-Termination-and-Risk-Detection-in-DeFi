// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/access/Ownable.sol";
import "./libs/ShufflerV3.sol";


contract PPP3 is Ownable {
    IDelegateRegistry internal constant registry = IDelegateRegistry(0x00000000000000447e69651d841bD8D104Bed493);
    INFT internal immutable CONTRACT_AD; // mainnet: 0x9CF0aB1cc434dB83097B7E9c831a764481DEc747
    INFT internal immutable CONTRACT_FPP; // mainnet: 0xA8A425864dB32fCBB459Bf527BdBb8128e6abF21

    struct UserStats {
        uint256 passCount;
        uint256 aDCount;
        uint256 availableExclusiveMints;
        uint256[10] mintsPerArtist;
        uint256[10] mintsAvailable;
    }

    uint256 public startTime;
    uint256 public exclusivePrice = 0.05 ether;
    uint256 public publicPrice = 0.1 ether;
    uint256 public maxPerArtist = 10;
    uint256 public mintsPerPass = 2;
    uint256 public stage1Duration = 30 minutes;
    uint256 public stage2Duration = 30 minutes; 
    address public mintable;
    bool public paused;
    uint256 public totalSold;

    mapping(address => uint256[10]) public mintCount;
    mapping(address => uint256) public exclusiveMintCount;
    mapping(uint256 => ShufflerV3) public collectionToShuffler;

    constructor(
        uint256 _startTime,
        address collectionAddress,
        address FPPAddress,
        address ADAddress
    ) Ownable(msg.sender) {
        startTime = _startTime;
        mintable = collectionAddress;
        for (uint256 i; i < 10; i++) {
            collectionToShuffler[i] = new ShufflerV3(100);
        }
        CONTRACT_FPP = INFT(FPPAddress);
        CONTRACT_AD = INFT(ADAddress);
    }

    function mint(
        uint256[] calldata wantedCollections,
        uint256[] calldata wantedQuantity
    ) external payable {
        require(totalSold < 1000, "Sold out.");
        require(!paused, "Sale is paused.");
        require(wantedCollections.length == wantedQuantity.length, "Array length mismatch.");
        require(
            block.timestamp >= startTime,
            "Sale not started."
        );
        uint256 totalQuantity;
        uint256 globalMax = fPPCount(msg.sender) * mintsPerPass;
        if (block.timestamp >= startTime + stage1Duration) {
            globalMax += aDCount(msg.sender) * mintsPerPass;
        }
        if(isPublic()) {
            globalMax = 1000;
        }

        for (uint256 i; i < wantedCollections.length; i++) {
            uint256 collection = wantedCollections[i];
            ShufflerV3 shuffler = collectionToShuffler[collection];
            uint256 amount = wantedQuantity[i];
            uint256 remaining = shuffler.remainingNumbers();
            if (amount > remaining) {
                amount = remaining;
            }
            uint256 alreadyMinted = mintCount[msg.sender][collection];
            uint256 allowance = maxPerArtist - alreadyMinted;
            if (amount > allowance) {
                amount = allowance;
            }
            uint256 alreadyMintedExclusive = exclusiveMintCount[msg.sender];
            uint256 globalAllowance = globalMax - alreadyMintedExclusive;
            if (amount > globalAllowance) {
              amount = globalAllowance;
            }
            mintCount[msg.sender][collection] += amount;
            // public mints don't count against pass limit
            if (!isPublic()) {
                exclusiveMintCount[msg.sender] += amount;
            }
            totalQuantity += amount;
            for (uint256 j; j < amount; j++) {
                INFT(mintable).mint(msg.sender, collection * 100 + shuffler.drawNext());
            }
        }
        totalSold += totalQuantity;
        uint256 price = isPublic() ? publicPrice : exclusivePrice;
        uint256 totalPrice = price * totalQuantity;
        require(totalPrice <= msg.value, "Insufficient ETH sent.");
        uint256 refund = msg.value - totalPrice;
        if (refund > 0) {
            (bool success,) = msg.sender.call{value: refund}("");
            require(success, "Refund failed");
        }
    }

    function aDCount(address user) internal view returns (uint256 total) {
        total = CONTRACT_AD.balanceOf(user);
        IDelegateRegistry.Delegation[] memory delegations = registry.getIncomingDelegations(user);
        for(uint256 i; i < delegations.length; i++) {
            IDelegateRegistry.Delegation memory dele = delegations[i];
            if (dele.type_ == IDelegateRegistry.DelegationType.ALL) {
                total += CONTRACT_AD.balanceOf(dele.from);
            }
            if (dele.type_ == IDelegateRegistry.DelegationType.CONTRACT && dele.contract_ == address(CONTRACT_AD)) {
                total += CONTRACT_AD.balanceOf(dele.from);
            }
        }
    }

    function fPPCount(address user) internal view returns (uint256 total) {
        total = CONTRACT_FPP.balanceOf(user);
        IDelegateRegistry.Delegation[] memory delegations = registry.getIncomingDelegations(user);
        for(uint256 i; i < delegations.length; i++) {
            IDelegateRegistry.Delegation memory dele = delegations[i];
            if (dele.type_ == IDelegateRegistry.DelegationType.ALL) {
                total += CONTRACT_FPP.balanceOf(dele.from);
            }
            if (dele.type_ == IDelegateRegistry.DelegationType.CONTRACT && dele.contract_ == address(CONTRACT_FPP)) {
                total += CONTRACT_FPP.balanceOf(dele.from);
            }
        }
    }

    function isPublic() public view returns (bool) {
        return block.timestamp >= startTime + stage1Duration + stage2Duration;
    }

    function userStats(address user) external view returns (UserStats memory stats) {
        uint256 _passCount = fPPCount(user);
        uint256 _aDCount = aDCount(user);
        uint256[10] memory mintsAvailable;
        for (uint256 i; i < 10; i++) {
            mintsAvailable[i] = collectionToShuffler[i].remainingNumbers();
        }
        stats = UserStats(
            _passCount,
            _aDCount,
            isPublic() ? 0 : 
                (block.timestamp >= startTime + stage1Duration ? 
                    (_passCount + _aDCount) * mintsPerPass : _passCount * mintsPerPass
                ) - exclusiveMintCount[user],
            mintCount[user],
            mintsAvailable
        );
    }

    // OWNER FUNCTIONS
    function editConfig(
        uint256 _startTime,
        uint256 _exclusivePrice,
        uint256 _publicPrice,
        uint256 _maxPerArtist,
        uint256 _mintsPerPass,
        uint256 _stage1Duration,
        uint256 _stage2Duration
    ) external onlyOwner {
        startTime = _startTime;
        exclusivePrice = _exclusivePrice;
        publicPrice = _publicPrice;
        maxPerArtist = _maxPerArtist;
        mintsPerPass = _mintsPerPass;
        stage1Duration = _stage1Duration;
        stage2Duration = _stage2Duration;
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    function withdraw(address recipient) external onlyOwner {
        (bool success,) = recipient.call{value: address(this).balance}("");
        require(success, "Withdraw failed.");
    }
}

interface INFT {
  function balanceOf(address account) external view returns (uint256);
  function mint(address to, uint256 tokenId) external;
}

interface IDelegateRegistry {
    /// @notice Delegation type, NONE is used when a delegation does not exist or is revoked
    enum DelegationType {
        NONE,
        ALL,
        CONTRACT,
        ERC721,
        ERC20,
        ERC1155
    }

    /// @notice Struct for returning delegations
    struct Delegation {
        DelegationType type_;
        address to;
        address from;
        bytes32 rights;
        address contract_;
        uint256 tokenId;
        uint256 amount;
    }

    function getIncomingDelegations(address to) external view returns (Delegation[] memory delegations);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/access/Ownable.sol";

contract ShufflerV3 is Ownable {
    uint256 internal immutable totalNumbers;
    uint256 public remainingNumbers;
    
    mapping(uint256 => uint256) public numberAtIndex;

    constructor(uint256 n) Ownable(msg.sender) {
        totalNumbers = n;
        remainingNumbers = n;
    }

    function drawNext() public onlyOwner returns (uint256) {
        require(remainingNumbers > 0);

        uint256 randomIndex = uint256(keccak256(abi.encodePacked(remainingNumbers, block.prevrandao))) %
            remainingNumbers;
        uint256 numberToDraw = numberAtIndex[randomIndex];
        if (numberToDraw == 0) {
            numberToDraw = randomIndex + 1;
        }

        remainingNumbers -= 1;

        uint256 swapNumber = numberAtIndex[remainingNumbers];
        if (swapNumber == 0) {
            swapNumber = remainingNumbers + 1;
        }

        numberAtIndex[randomIndex] = swapNumber;
        numberAtIndex[remainingNumbers] = numberToDraw;

        return numberToDraw;
    }
}