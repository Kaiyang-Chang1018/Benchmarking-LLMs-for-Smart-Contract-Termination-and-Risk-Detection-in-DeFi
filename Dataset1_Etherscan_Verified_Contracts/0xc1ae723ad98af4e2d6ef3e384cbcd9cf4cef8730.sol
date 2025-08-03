// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
}
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IERC20USDT {
    function transferFrom(address from, address to, uint value) external;

    function transfer(address to, uint value) external;
}

interface IYGME {
    function swap(address to, address _recommender, uint mintNum) external;

    function balanceOf(address owner) external view returns (uint256 balance);

    function PAY() external view returns (uint256 pay);

    function maxLevel() external view returns (uint256 level);

    function recommender(
        address _account
    ) external view returns (address _recommender);

    function rewardLevelAmount(
        uint256 _level
    ) external view returns (uint256 amount);
}

interface IYgmeStake {
    function getStakingTokenIds(
        address _account
    ) external view returns (uint256[] memory);
}

contract YgmeMint is Ownable, ReentrancyGuard {

    address constant ZERO_ADDRESS = address(0);

    IERC20USDT public immutable usdt;

    IYGME public immutable ygme;

    IYgmeStake public immutable ygmestake;

    IERC20 public immutable ygio;

    bool public rewardSwitch;

    bool public mintSwitch;

    constructor(
        address _usdt,
        address _ygme,
        address _ygmestake,
        address _ygio
    ) {
        usdt = IERC20USDT(_usdt);
        ygme = IYGME(_ygme);
        ygmestake = IYgmeStake(_ygmestake);
        ygio = IERC20(_ygio);
    }

    function setRewardSwitch() external onlyOwner {
        rewardSwitch = !rewardSwitch;
    }

    function setMintSwitch() external onlyOwner {
        mintSwitch = !mintSwitch;
    }

    function safeMint(
        address _recommender,
        uint256 mintNum
    ) external nonReentrant {
        address account = _msgSender();

        address superAddress = ygme.recommender(account);

        if(superAddress != ZERO_ADDRESS){
            _recommender = superAddress;
        }else{
            require(_recommender != ZERO_ADDRESS, "recommender can not be zero");
        }

        require(_recommender != account, "recommender can not be self");

        require(
            ygme.balanceOf(_recommender) > 0 ||
                ygmestake.getStakingTokenIds(_recommender).length > 0,
            "invalid recommender"
        );

        uint256 unitPrice = ygme.PAY();

        usdt.transferFrom(account, address(ygme), mintNum * unitPrice);

        ygme.swap(account, _recommender, mintNum);

        if (rewardSwitch) {
            _rewardMint(account, mintNum);
        }
    }

    function safeMintTwo(
        address _recommender,
        uint256 mintNum
    ) external nonReentrant {
        require(mintSwitch, "method invalide");
       
        address account = _msgSender();

        require(_recommender != account, "recommender can not be self");

        uint256 unitPrice = ygme.PAY();

        usdt.transferFrom(account, address(ygme), mintNum * unitPrice);

        ygme.swap(account, _recommender, mintNum);

        if (rewardSwitch) {
            _rewardMint(account, mintNum);
        }
    }

    function _rewardMint(address to, uint mintNum) private {
        address rewward;
        for (uint i = 0; i <= ygme.maxLevel(); i++) {
            if (0 == i) {
                rewward = to;
            } else {
                rewward = ygme.recommender(rewward);
            }

            if (rewward != ZERO_ADDRESS && 0 != ygme.rewardLevelAmount(i)) {
                ygio.transfer(rewward, ygme.rewardLevelAmount(i) * mintNum);
            }
        }
    }
}