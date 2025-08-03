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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function balanceOf(address owner) external view returns (uint256);
}

contract LancetMembership is Ownable,Pausable,ReentrancyGuard{
    using SafeMath for uint256;

    // =========================================================================
    //                               Types
    // =========================================================================
    enum Staking48HType{
        ThirtyDays,
        SixtyDays
    }

    struct MembershipType{
        uint256 membershipDays;
        bool    onSale;
        uint256 membershipPrice;
    }

    // =========================================================================
    //                               Storage
    // =========================================================================
    IERC721 public lancetPass ;

    uint256 public staking48HStartTimestamp;
    
    uint256 private constant _24H_SEC = 1 days;

    uint256[] public membershipCategory;

    bool public stakingEnabled;

    mapping(address => uint256) public ownedToken;

    mapping(uint256 => bool) public stakingAllowed;

    mapping(uint256 => uint256) public stakingEndAt;
    mapping(uint256 => uint256) public membershipEndAt;

    mapping(uint256 => MembershipType) public membershipState;

    // =========================================================================
    //                            Constructor
    // =========================================================================
    constructor(address _lancetPassAddress){
        membershipState[30] = MembershipType(30,true,0.2 ether);
        membershipState[60] = MembershipType(60,true,0.35 ether);
        membershipState[90] = MembershipType(90,true,0.5 ether);
        membershipState[180] = MembershipType(180,true,0.6 ether);
        membershipCategory.push(30);
        membershipCategory.push(60);
        membershipCategory.push(90);
        membershipCategory.push(180);

        lancetPass = IERC721(_lancetPassAddress);
    }

    // =========================================================================
    //                               Event
    // =========================================================================
    event Staking48H(address indexed owner,uint256 indexed startTimestamp,uint256 indexed endTimestamp,uint256 tokenId);
    event MembershipPurchase(address indexed owner,uint256 indexed startTimestamp,uint256 indexed endTimestamp,uint256 tokenId);
    event Staking(address indexed owner,uint256 indexed startTimestamp,uint256 indexed endTimestamp,uint256 tokenId);
    event SetMembershipPrice(uint256 indexed membershipDays,uint256 indexed price);
    event SetMembershipState(uint256 indexed membershipDays,uint256 indexed price,bool indexed onSale);
    event StakingTokenWithdraw(address indexed owner,uint256 indexed tokenId);

    // =========================================================================
    //                               Modifier
    // =========================================================================
    modifier Staking48HOpen{
        require(block.timestamp >= staking48HStartTimestamp && block.timestamp <= staking48HStartTimestamp.add(_24H_SEC.mul(2)),"48H Staking not opened");
        _;
    }
    
    modifier Staking48HClosed{
        require(block.timestamp > staking48HStartTimestamp.add(_24H_SEC.mul(2)),"48H Staking not closed");
        _;
    }

    modifier OnlyPassOwner(uint256 tokenId){
        require(tokenId != 0);
        require(ownedToken[msg.sender] == tokenId || lancetPass.ownerOf(tokenId) == msg.sender,"Not Lancet Pass Holder");
        _;
    }

    // =========================================================================
    //                               Function
    // =========================================================================
    function staking48H(Staking48HType staking48HType,uint256 tokenId) Staking48HOpen OnlyPassOwner(tokenId) external {
        require(ownedToken[msg.sender] == 0,"Already staked");
        lancetPass.transferFrom(msg.sender,address(this),tokenId);
        ownedToken[msg.sender] = tokenId;

        uint256 startTimestamp = block.timestamp;
        uint256 endTimestamp = startTimestamp.add(convertStakingTime(staking48HType));
        membershipEndAt[tokenId] = endTimestamp;
        stakingEndAt[tokenId] = endTimestamp;
        emit Staking48H(msg.sender, startTimestamp, endTimestamp, tokenId);
    }

    function membershipPurchase(uint256 membershipDays,uint256 tokenId) Staking48HClosed OnlyPassOwner(tokenId) nonReentrant payable public{
        require(msg.value == membershipState[membershipDays].membershipPrice,"Invalid Price");
        require(membershipState[membershipDays].onSale,"Not On Sale");
        uint256 startTimestamp = block.timestamp;
        uint256 membershipEndTimestamp;
        if (membershipEndAt[tokenId] > startTimestamp){
            membershipEndTimestamp = membershipEndAt[tokenId].add(_24H_SEC.mul(membershipDays));
        }else{
            membershipEndTimestamp = startTimestamp.add(_24H_SEC.mul(membershipDays));
        }        
        membershipEndAt[tokenId] = membershipEndTimestamp;
        stakingAllowed[tokenId] = true;
        emit MembershipPurchase(msg.sender,startTimestamp,membershipEndTimestamp,tokenId);
    }

    function stakingAndMembership(uint256 membershipDays,uint256 tokenId) Staking48HClosed OnlyPassOwner(tokenId) nonReentrant payable external{
        require(stakingEnabled,"Staking Not Open");
        require(msg.value == membershipState[membershipDays].membershipPrice,"Invalid Price");
        require(membershipState[membershipDays].onSale,"Not On Sale");
        uint256 startTimestamp = block.timestamp;
        uint256 endTimestamp;
        if (membershipEndAt[tokenId] > startTimestamp){
            endTimestamp = membershipEndAt[tokenId].add(_24H_SEC.mul(membershipDays));
        }else{
            endTimestamp = startTimestamp.add(_24H_SEC.mul(membershipDays));
        }        
        membershipEndAt[tokenId] = endTimestamp;
        if (ownedToken[msg.sender] == 0){
            lancetPass.transferFrom(msg.sender,address(this),tokenId);
            ownedToken[msg.sender] = tokenId;
        }
        stakingEndAt[tokenId] = endTimestamp;
        stakingAllowed[tokenId] = false;
        emit Staking(msg.sender,startTimestamp,endTimestamp,tokenId);
        emit MembershipPurchase(msg.sender,startTimestamp,endTimestamp,tokenId);
    }
    

    function staking(uint256 stakeDuration,uint256 tokenId) Staking48HClosed OnlyPassOwner(tokenId) nonReentrant public {
        require(stakingEnabled,"Staking Not Open");
        require(stakingAllowed[tokenId],"Staking not allowed");
        uint256 startTimestamp = block.timestamp;
        require(membershipEndAt[tokenId] > startTimestamp,"Only membership can staking");
        uint256 stakeEndTimestamp;
        if (ownedToken[msg.sender] == tokenId){
            if (stakingEndAt[tokenId] > startTimestamp){
                stakeEndTimestamp = stakingEndAt[tokenId].add(stakeDuration);
            }else{
                stakeEndTimestamp = startTimestamp.add(stakeDuration);
            }
        }else if (ownedToken[msg.sender] == 0){
            stakeEndTimestamp = startTimestamp.add(stakeDuration);
            lancetPass.transferFrom(msg.sender,address(this),tokenId);
            ownedToken[msg.sender] = tokenId;
        }else{
            revert();
        }
        if (membershipEndAt[tokenId] < stakeEndTimestamp){
            stakeEndTimestamp = membershipEndAt[tokenId];
        }
        stakingEndAt[tokenId] = stakeEndTimestamp;
        stakingAllowed[tokenId] = false;
        emit Staking(msg.sender,startTimestamp,stakeEndTimestamp,tokenId);
    }


    function stakingWithEndtime(uint256 stakeEndTimestamp,uint256 tokenId) Staking48HClosed OnlyPassOwner(tokenId) nonReentrant public {
        require(stakingEnabled,"Staking Not Open");
        require(stakingAllowed[tokenId],"Staking not allowed");
        uint256 startTimestamp = block.timestamp;
        require(membershipEndAt[tokenId] > startTimestamp,"Only membership can staking");

        if (ownedToken[msg.sender] == 0){
            lancetPass.transferFrom(msg.sender,address(this),tokenId);
            ownedToken[msg.sender] = tokenId;
        }
        if (membershipEndAt[tokenId] < stakeEndTimestamp){
            stakingEndAt[tokenId] = membershipEndAt[tokenId];
        }else{
            stakingEndAt[tokenId] = stakeEndTimestamp;
        }
        stakingAllowed[tokenId] = false;
        emit Staking(msg.sender,startTimestamp,stakeEndTimestamp,tokenId);
    }

    function stakingTokenWithdraw() nonReentrant external{
        uint256 ownedTokenId = ownedToken[msg.sender];
        require(ownedTokenId != 0,"Have't token in staking");
        require(stakingEndAt[ownedTokenId] <= block.timestamp,"Cannot withdraw");
        lancetPass.transferFrom(address(this),msg.sender,ownedTokenId);
        ownedToken[msg.sender] = 0;
        emit StakingTokenWithdraw(msg.sender,ownedTokenId);
    }

    function convertStakingTime(Staking48HType stakeWithin48HType) pure private returns(uint256){
        if (stakeWithin48HType == Staking48HType.ThirtyDays){
            return _24H_SEC.mul(30);
        }
        if (stakeWithin48HType == Staking48HType.SixtyDays){
            return _24H_SEC.mul(60);
        }
        return 0;
    }

    function convertMembershipTime(uint256 membershipDays) pure private returns(uint256){
        return  _24H_SEC.mul(membershipDays);
    }

    function setMembershipPrice(uint256 membershipDays,uint256 price) external onlyOwner{
        membershipState[membershipDays] = MembershipType(membershipDays,false,price);
        emit SetMembershipPrice(membershipDays,price);
    }

    function setMembershipState(uint256 membershipDays,uint256 price,bool onSale) external onlyOwner{
        require(membershipState[membershipDays].membershipPrice == price);
        if (membershipState[membershipDays].membershipDays == 0 && membershipDays != 0){
            membershipCategory.push(membershipDays);
        }
        membershipState[membershipDays].onSale = onSale;

        emit SetMembershipState(membershipDays,price,onSale);
    }

    function setStakingEnabled() external onlyOwner{
        stakingEnabled = !stakingEnabled;
    }

    function setStaking48HStartTimestamp(uint256 _staking48HStartTimestamp) external onlyOwner{
        staking48HStartTimestamp = _staking48HStartTimestamp;
    }

    function getAllMembershipTypes() external view returns(MembershipType[] memory){
        MembershipType[] memory membershipTypes = new MembershipType[](membershipCategory.length);
        for (uint256 i = 0;i < membershipCategory.length ;i ++){
            membershipTypes[i] = membershipState[membershipCategory[i]];
        }
        return membershipTypes;
    }

    function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: (address(this).balance)}("");
        require(success, "Withdraw: Transaction Unsuccessful.");
    }
}