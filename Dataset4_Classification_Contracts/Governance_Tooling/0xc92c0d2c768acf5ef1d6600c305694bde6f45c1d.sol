// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBribeToken {
    function mint(address to, uint256 amount) external;
    function balanceOf(address who) external view returns (uint256);
    function burn(address to, uint256 amount) external;
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDubai {
    function depositPresaleUser(address _user, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFraudToken {
    function mint(address to, uint256 amount) external;
    function totalSupply() external view returns (uint256);
    function transferUnderlying(address to, uint256 value) external returns (bool);
    function fragmentToFraud(uint256 value) external view returns (uint256);
    function fraudToFragment(uint256 fraud) external view returns (uint256);
    function balanceOfUnderlying(address who) external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function getCurrentEpoch() external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);

    function burn(address from, uint256 amount) external;
    function rebase(
        uint256 epoch,
        uint256 indexDelta,
        bool positive
    ) external returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
/*⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⢦⡀⠉⠙⢦⡀⠀⠀⣀⣠⣤⣄⣀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣀⡤⠤⠴⠶⠤⠤⢽⣦⡀⠀⢹⡴⠚⠁⠀⢀⣀⣈⣳⣄⠀⠀
⠀⠀⠀⠀⠀⢠⠞⣁⡤⠴⠶⠶⣦⡄⠀⠀⠀⠀⠀⠀⠀⠶⠿⠭⠤⣄⣈⠙⠳⠀
⠀⠀⠀⠀⢠⡿⠋⠀⠀⢀⡴⠋⠁⠀⣀⡖⠛⢳⠴⠶⡄⠀⠀⠀⠀⠀⠈⠙⢦⠀
⠀⠀⠀⠀⠀⠀⠀⠀⡴⠋⣠⠴⠚⠉⠉⣧⣄⣷⡀⢀⣿⡀⠈⠙⠻⡍⠙⠲⢮⣧
⠀⠀⠀⠀⠀⠀⠀⡞⣠⠞⠁⠀⠀⠀⣰⠃⠀⣸⠉⠉⠀⠙⢦⡀⠀⠸⡄⠀⠈⠟
⠀⠀⠀⠀⠀⠀⢸⠟⠁⠀⠀⠀⠀⢠⠏⠉⢉⡇⠀⠀⠀⠀⠀⠉⠳⣄⢷⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡾⠤⠤⢼⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡇⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠉⠉⠉⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣀⣀⣀⣻⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣀⣀⡤⠤⠤⣿⠉⠉⠉⠘⣧⠤⢤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢀⡤⠖⠋⠉⠀⠀⠀⠀⠀⠙⠲⠤⠤⠴⠚⠁⠀⠀⠀⠉⠉⠓⠦⣄⠀⠀⠀
⢀⡞⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⣄⠀
⠘⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠚⠀
  _____ ____      _   _   _ ____    ____  ____  _____ ____    _    _     _____ 
 |  ___|  _ \    / \ | | | |  _ \  |  _ \|  _ \| ____/ ___|  / \  | |   | ____|
 | |_  | |_) |  / _ \| | | | | | | | |_) | |_) |  _| \___ \ / _ \ | |   |  _|  
 |  _| |  _ <  / ___ \ |_| | |_| | |  __/|  _ <| |___ ___) / ___ \| |___| |___ 
 |_|   |_| \_\/_/   \_\___/|____/  |_|   |_| \_\_____|____/_/   \_\_____|_____|
                                                                               
    Twitter: https://twitter.com/fraudeth_gg
    Telegram: http://t.me/fraudportal
    Website: https://fraudeth.gg
    Docs: https://docs.fraudeth.gg                                                                              

*/


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";  
import "./IFraudToken.sol";
import "./IBribeToken.sol";
import "./IDubai.sol";
contract PrivatePresale is Ownable {

    using SafeMath for uint256;
    
    // FRAUD
    IFraudToken public fraud;
    // Bribe
    IBribeToken public bribe;
    // Dubai
    IDubai public dubai;

    struct Allocation {
        uint256 bribeDelayed;
        uint256 fraudClaimable;
        uint256 fraudDelayed;
        uint256 fraudInDubai;
        uint256 ethAmount;
    }
    
    uint256 public claimOpenDate;
    uint256 public lockedInDubai;
    bool public claimOpen = false;
    uint256 public claimOpenEpoch;
    
    mapping(address => Allocation) public allocations;
    mapping(address => bool) public frozen;

    event AllocationsAdded(address[] participants, uint256[] ethAmounts);
    event Claimed(address indexed user, uint256 fraudAmount);
    event DelayedClaimed(address indexed user, uint256 fraudAmount, uint256 bribeAmount);

    constructor(address _fraud, address _bribe, address _dubai) {
        fraud = IFraudToken(_fraud);
        bribe = IBribeToken(_bribe);
        dubai = IDubai(_dubai);
    }
    
    function addAllocations(address[] calldata participants, uint256[] calldata ethAmounts, uint256[] calldata fraudAllocations, uint256[] calldata bribeAllocations) external onlyOwner(){
        require(participants.length == fraudAllocations.length, "Mismatched participants and fraudAllocations");
        require(participants.length == bribeAllocations.length, "Mismatched participants and bribeAllocations");
        require(participants.length == ethAmounts.length, "Mismatched participants and ethAmounts");
        
        for (uint256 i = 0; i < participants.length; i++) {
            uint256 ethAmount = ethAmounts[i];
            uint256 fraudAmount = fraudAllocations[i];
            uint256 bribeAmount = bribeAllocations[i];
            address participant = participants[i];

            allocations[participant].ethAmount = ethAmount;
            allocations[participant].fraudClaimable = fraudAmount.mul(60).div(100);
            allocations[participant].fraudDelayed = fraudAmount.mul(20).div(100);
            allocations[participant].fraudInDubai = fraudAmount.mul(20).div(100);
            allocations[participant].bribeDelayed = bribeAmount;

            lockedInDubai = lockedInDubai.add(allocations[participant].fraudInDubai);

        }
        emit AllocationsAdded(participants, ethAmounts);
    }
    
    // Should we burn or not tokens ? Here virtual tokens are burned
    // Rebase 
    function claim() external {
        require(claimOpen == true, "Claiming not yet opened");
        require(allocations[msg.sender].fraudClaimable > 0, "No tokens to claim");
        uint256 fraudClaimable = allocations[msg.sender].fraudClaimable;
        uint256 epochsElapsed = fraud.getCurrentEpoch().sub(claimOpenEpoch);
        if (epochsElapsed >= 1) {
            uint256 rebaseFactor = 1 ether;  
            for (uint256 i = 0; i < epochsElapsed; i++) {
                rebaseFactor = rebaseFactor.mul(900).div(1000); 
            }
            fraudClaimable = fraudClaimable.mul(rebaseFactor).div(1 ether);
        }

        fraud.mint(msg.sender, fraudClaimable);
        allocations[msg.sender].fraudClaimable = 0;
        emit Claimed(msg.sender, fraudClaimable);
    }

    function claimLocked() external {
        require(claimOpen == true, "Claiming not yet opened");
        require(allocations[msg.sender].fraudDelayed > 0, "No tokens to claim");
        require(block.timestamp >= claimOpenDate.add(1 days), "Claiming time not yet open");
        require(!frozen[msg.sender],"Not authorized");
        uint256 fraudDelayed = allocations[msg.sender].fraudDelayed;
        uint256 openEpoch = claimOpenEpoch.add(1); // 1 day lock = 1 epoch
        uint256 epochsElapsed = fraud.getCurrentEpoch().sub(openEpoch);

        if (epochsElapsed >= 1) {
            uint256 rebaseFactor = 1 ether;  
            for (uint256 i = 0; i < epochsElapsed; i++) {
                rebaseFactor = rebaseFactor.mul(900).div(1000); 
            }
            fraudDelayed = fraudDelayed.mul(rebaseFactor).div(1 ether);
        }
        uint256 bribeDelayed = allocations[msg.sender].bribeDelayed;
        fraud.mint(msg.sender, fraudDelayed);
        bribe.mint(msg.sender, bribeDelayed);
        allocations[msg.sender].fraudDelayed = 0;
        allocations[msg.sender].bribeDelayed = 0;
        emit DelayedClaimed(msg.sender, fraudDelayed, bribeDelayed);
    }
    function setClaimOpen(bool _claimOpen) external onlyOwner {
        claimOpen = _claimOpen;
        claimOpenDate = block.timestamp;
        claimOpenEpoch = fraud.getCurrentEpoch();
    }
    function freeze(address target, bool isFrozen)external onlyOwner{
        frozen[target] = isFrozen;
    }

    function getAllocationFraudInDubai(address _user) external view returns (uint256) {
        return allocations[_user].fraudInDubai;
    }

    function getClaimOpenDate() external view returns (uint256) {
        return claimOpenDate;
    }

    function getClaimOpenEpoch() external view returns (uint256) {
        return claimOpenEpoch;
    }

    function getLockedInDubai() external view returns (uint256) {
        return lockedInDubai;
    }
}