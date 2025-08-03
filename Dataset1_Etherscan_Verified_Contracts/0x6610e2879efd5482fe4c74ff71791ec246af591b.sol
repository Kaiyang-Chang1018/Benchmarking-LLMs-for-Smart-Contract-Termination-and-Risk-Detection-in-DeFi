// SPDX_License_Identifier: Unlicensed


// The first time you see an ERC404 contract...

// (⌐■_■)
// ( •_•)>⌐■-■
// (•_•)

// But the second time...

// (•_•)
// ( •_•)>⌐■-■
// (⌐■_■)


pragma solidity ^0.8.18;


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


interface IRiggers {
    function balanceOf(address account) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}


interface IOil {
    function mint(address account, uint256 id, uint256 amount) external;
}


/// @title A presale contract for Riggers.
///
/// @notice Riggers
///             Telegram: https://t.me/riggersfinance
///             Twitter:  https://twitter.com/RiggersFinance
///             Web:      riggers.finance
///
/// @author Inspired by Pandora dev team (https://etherscan.io/address/0x9E9FbDE7C7a83c43913BddC8779158F1368F0413#code).
/// @author Prospector Howie ?️
///         Telegram: OilRigSheikh
///
/// @custom:security-contact Telegram: https://t.me/OilRigSheikh
contract RiggersPresale is Ownable,
                           ReentrancyGuard
{


    ////
    //// STATE
    ////


    bool public depositsEnabled;
    bool public claimsEnabled;

    uint256 public totalDeposits;
    mapping(address participant => uint256 deposit) public deposits;

    IRiggers public riggers;
    IOil public oil;
    uint256 public hardhat;


    ////
    //// EVENTS
    ////


    event Contribute(
        address indexed account,
        uint256 indexed sentEth,
        uint256 indexed totalSentEth
    );

    event Recover(
        uint256 indexed amount
    );

    event Claim(
        address indexed account,
        uint256 indexed tokensAmount
    );


    ////
    //// INIT
    ////


    /// Deploy.
    constructor() {}

    /// Config.
    ///
    /// @param _riggers Address of Riggers (RIG).
    /// @param _oil Address of Oil NFT collection.
    /// @param _hardhat ID of hardhat token.
    function config(
        address _riggers,
        address _oil,
        uint256 _hardhat
    )
        external
        onlyOwner
    {
        depositsEnabled = true;

        riggers = IRiggers(_riggers);

        oil = IOil(_oil);
        hardhat = _hardhat;
    }


    ////
    //// ENTER PRESALE
    ////


    /// Auto-receive ETH.
    receive()
        external
        payable
    {
        require(
            depositsEnabled,
            "Presale inactive"
        );

        require(
            deposits[msg.sender] + msg.value >= 0.1 ether,
            "Min 0.1 ETH"
        );

        require(
            deposits[msg.sender] + msg.value <= 1 ether,
            "Total max 1 ETH"
        );

        require(
            totalDeposits <= 30 ether,
            "Presale maxxed"
        );

        if (deposits[msg.sender] == 0) {
            oil.mint(
                msg.sender,
                hardhat,
                1
            );
        }

        totalDeposits += msg.value;
        deposits[msg.sender] += msg.value;

        emit Contribute(
            msg.sender,
            msg.value,
            deposits[msg.sender]
        );
    }


    ////
    //// ADMIN END PRESALE
    ////


    /// Withdraw ETH to owner.
    ///
    /// @param amount Quantity of ETH to withdraw, in Wei.
    function recoverETH(
        uint256 amount
    )
        external
        onlyOwner
    {
        (bool success, ) = payable(owner()).call{value: amount}('');
        require(
            success,
            "Transfer failed."
        );

        emit Recover(
            amount
        );
    }

    /// Toggle enabling of deposits.
    function toggleDepositsEnabled()
        external
        onlyOwner
    {
        depositsEnabled = !depositsEnabled;
    }

    /// Toggle enabling of claims.
    function toggleClaimsEnabled()
        external
        onlyOwner
    {
        claimsEnabled = !claimsEnabled;
    }

    ////
    //// PARTICIPANT CLAIM
    ////


    function getClaimAmount(
        address account
    )
        public
        view
        returns (uint256)
    {
        if (deposits[account] == 0) {
            return 0;
        }

        uint256 presaleAmount = 150 * 10 ** 18;
        return presaleAmount * deposits[account] / totalDeposits;
    }

    function claim()
        external
        nonReentrant
    {
        require(
            claimsEnabled,
            "Presale active"
        );

        uint256 claimAmount = getClaimAmount(msg.sender);

        require(
            claimAmount > 0,
            "Null claim"
        );

        deposits[msg.sender] = 0;

        riggers.transfer(
            msg.sender,
            claimAmount
        );

        emit Claim(
            msg.sender,
            claimAmount
        );
    }
}