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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

    interface IUniversalRouter {
        function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline) external payable;
    }   


contract MirrorBotV3 is Ownable{

        using SafeMath for uint256;
        uint256 private  adminFeeInETH;
        uint256 private  ownerShare; 
        address private  adminAddress;
        address private constant UNIVERSAL_ROUTER_ADDRESS = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD; 
        IUniversalRouter public  immutable uniswapRouter;
        address private wrapETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        event ExecutionResult(bool success);
        
    constructor(uint256 _adminFeeInETH) Ownable(msg.sender)  {
        uniswapRouter = IUniversalRouter(UNIVERSAL_ROUTER_ADDRESS);  
        adminFeeInETH = _adminFeeInETH;
        adminAddress = msg.sender;   
    }

    mapping(address => uint256) private  influencerMapping; 

    function setAdminAddress (address _adminAddress) external onlyOwner  {
        adminAddress = _adminAddress;
    }

    function setAdminFEE (uint256 _adminFeeInETH) external  onlyOwner  {
        adminFeeInETH = _adminFeeInETH;
    }

    function _adminAdress () external  view returns (address) {
        return adminAddress;
    }

    function _getAdminFee () external view returns (uint256) {
        return adminFeeInETH;
    }

    function _getInfluencerValue(address _influencerAddress) external  view returns (uint256) {
        return influencerMapping[_influencerAddress];
    }

    modifier onlyAdmin() {
    require(msg.sender == adminAddress , "Unauthorized access");
    _;
    }

    function processInfluencerPayment(address influencer, uint256 influencerFee) internal   {
        require(influencer != address(0), "Invalid influencer address");
        influencerMapping[influencer] = influencerMapping[influencer].add(influencerFee);  
    }

    function withdrawInfluencerFee() external  {
        require(influencerMapping[msg.sender] > 0, "No fees to withdraw");
        address payable influencer = payable(msg.sender);
        uint256 influencerFee = influencerMapping[influencer];
        influencer.transfer(influencerFee);
        influencerMapping[influencer] = 0;
    }

    function withdrawInfluencerFeeByAdmin(address __influencer) external onlyAdmin {
        require(influencerMapping[__influencer] > 0, "No fees to withdraw");
        address payable influencer = payable(msg.sender);
        uint256 influencerFee = influencerMapping[__influencer];
        influencer.transfer(influencerFee);
        influencerMapping[__influencer] = 0;
    }


    function withdrawBalanceByOwner() external onlyOwner {
        require(ownerShare > 0, "No Owner balance to withdraw");
        payable(owner()).transfer(ownerShare);
        ownerShare = 0;
    }

    function getOwnerBlance () external view  returns (uint256) {
        return ownerShare;
    }

    function calculateInfluencerFee(uint256 amount, uint256 feePercentage) internal pure returns (uint256) {
        return  (amount.mul (feePercentage)).div(100);
    }

    // function getTokenBalance(address tokenAddress) external view returns (uint256) {
    //     IERC20 token = IERC20(tokenAddress);
    //     uint256 balance = token.balanceOf(msg.sender);
    //     return balance;
    // }

    function buyv2(
        uint256 amountOutMin,
        address[] memory path,
        address influencer,
        uint256 influencerFeePercentage,
        address masterInfluencer,
        uint256 masterInfluencerFeePercentage

    ) external payable {

        require(influencerFeePercentage <= 100, "Influencer fee percentage must be <= 100");
        require(masterInfluencerFeePercentage <= 100, "Master influencer fee percentage must be <= 100");
        uint256 adminFee = adminFeeInETH;
        uint256 influencerFee = calculateInfluencerFee(adminFee, influencerFeePercentage);
        uint256 masterInfluencerFee = 0;
        if (masterInfluencer != address(0)) {
            masterInfluencerFee = calculateInfluencerFee(adminFee, masterInfluencerFeePercentage);
        }
        ownerShare += (adminFee.sub(influencerFee)).sub(masterInfluencerFee); 
        uint256 remainingAmount = msg.value.sub(adminFee);
        bytes memory commands = abi.encodePacked(bytes1(0x0b), bytes1(0x08));
        bytes memory wrapEthInputs = abi.encode(
            0x0000000000000000000000000000000000000002,
            remainingAmount
        );
        bytes memory swapExactInInputs = abi.encode(
            msg.sender,
            remainingAmount,               
            amountOutMin,            
            path,                    
            false                    
        );
        bytes[] memory inputsArray = new bytes[](2);
        inputsArray[0] = wrapEthInputs;
        inputsArray[1] = swapExactInInputs;
    uniswapRouter.execute{value: remainingAmount}(commands, inputsArray, block.timestamp + 10);
    processInfluencerPayments(influencer, influencerFee, masterInfluencer, masterInfluencerFee);
   
    }

    // function swapv2(
    //     uint256 amountIn,
    //     uint256 amountOutMin,
    //     address[] memory path,
    //     address influencer,
    //     uint256 influencerFeePercentage,
    //     address masterInfluencer,
    //     uint256 masterInfluencerFeePercentage
    // ) external payable {

    //     uint256 adminFee = adminFeeInETH; 
    //     require(influencerFeePercentage <= 100, "Influencer fee percentage must be <= 100");
    //     require(masterInfluencerFeePercentage <= 100, "Master influencer fee percentage must be <= 100");
    //     require(msg.value >= adminFee, "Insufficient balance for fee "); 
    //     uint256 influencerFee = calculateInfluencerFee( adminFee, influencerFeePercentage);
    //     uint256 masterInfluencerFee = 0;
    //     if (masterInfluencer != address(0)) {
    //         masterInfluencerFee = calculateInfluencerFee(adminFee, masterInfluencerFeePercentage);
    //     }
    //     ownerShare += (adminFee.sub(influencerFee)).sub(masterInfluencerFee); 

    //     bytes memory commands = abi.encodePacked(bytes1(0x08));
    //     bytes memory swapExactInInputs = abi.encode(
    //         msg.sender,
    //         amountIn,
    //         amountOutMin,            
    //         path,                    
    //         false                    
    //     );

    //     bytes[] memory inputsArray = new bytes[](1);
    //     inputsArray[0] = swapExactInInputs;

    // uniswapRouter.execute(commands, inputsArray, block.timestamp + 10);  
    // processInfluencerPayments(influencer, influencerFee, masterInfluencer, masterInfluencerFee);
   
    // }

    function sellV2(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address influencer,
        uint256 influencerFeePercentage,
        address masterInfluencer,
        uint256 masterInfluencerFeePercentage      
    ) external payable {
        uint256 adminFee = adminFeeInETH;
        require(influencerFeePercentage <= 100, "Influencer fee percentage must be <= 100");
        require(masterInfluencerFeePercentage <= 100, "Master influencer fee percentage must be <= 100");
        require(msg.value >= adminFee, "Insufficient balance for fee ");   
        uint256 influencerFee = calculateInfluencerFee( adminFee, influencerFeePercentage);
        uint256 masterInfluencerFee = 0;
        if (masterInfluencer != address(0)) {
            masterInfluencerFee = calculateInfluencerFee(adminFee, masterInfluencerFeePercentage);
        }
        ownerShare += (adminFee.sub(influencerFee)).sub(masterInfluencerFee); 
        
        bytes memory commands = abi.encodePacked( bytes1(0x08),bytes1(0x0c));
        bytes memory swapExactInInputs = abi.encode(
            0x0000000000000000000000000000000000000002,
            amountIn,               
            amountOutMin,            
            path,                    
            false                    
        );
        bytes memory unwrapEthInputs = abi.encode(msg.sender,amountOutMin);  
        bytes[] memory inputsArray = new bytes[](2);
        inputsArray[0] = swapExactInInputs;
        inputsArray[1] = unwrapEthInputs;

    uniswapRouter.execute(commands, inputsArray, block.timestamp + 10);
    processInfluencerPayments(influencer, influencerFee, masterInfluencer, masterInfluencerFee);
 
    }
   
    
    // function swapV3(
    //     uint256 amountIn,
    //     uint256 amountOutMin,
    //     address tokenIn,
    //     address tokenOut,
    //     uint24  fee,
    //     address influencer,
    //     uint256 influencerFeePercentage,
    //     address masterInfluencer,
    //     uint256 masterInfluencerFeePercentage
    // ) external payable {

    //     uint256 adminFee = adminFeeInETH;
    //     require(influencerFeePercentage <= 100, "Influencer fee percentage must be <= 100");
    //     require(masterInfluencerFeePercentage <= 100, "Master influencer fee percentage must be <= 100");
    //     require(msg.value >= adminFee, "Insufficient balance for fee");
    //     uint256 influencerFee = calculateInfluencerFee(adminFee, influencerFeePercentage);
    //     uint256 masterInfluencerFee = masterInfluencer != address(0) ? calculateInfluencerFee(adminFee, masterInfluencerFeePercentage) : 0;
    //     ownerShare += (adminFee.sub(influencerFee)).sub(masterInfluencerFee); 
    //     bytes memory v3SwapExactInCommand = abi.encodePacked( bytes1(0x00));
    //     bytes memory path = abi.encodePacked(tokenIn,fee ,tokenOut);
    //     bytes memory swapExactInInputs = abi.encode(
    //         msg.sender,
    //         amountIn,
    //         amountOutMin,
    //         path,
    //         false
    //     );
    //     bytes[] memory inputsArray = new bytes[](1);
    //     inputsArray[0] = swapExactInInputs;

    // uniswapRouter.execute(v3SwapExactInCommand, inputsArray, block.timestamp + 10);
    // processInfluencerPayments(influencer, influencerFee, masterInfluencer, masterInfluencerFee);
  
    // }

    function sellV3 (
        uint256 amountIn,
        uint256 amountOutMin,
        address tokenIn,
        uint24 fee,
        address influencer,
        uint256 influencerFeePercentage,
        address masterInfluencer,
        uint256 masterInfluencerFeePercentage
    ) external payable  {

        uint256 adminFee = adminFeeInETH; 
        require(influencerFeePercentage <= 100, "Influencer fee percentage must be <= 100");
        require(masterInfluencerFeePercentage <=100, "masterInfluencer fee percentage must be <= 100" );
        require(msg.value >= adminFee, "Insufficient balance for fee ");
        uint256 influencerFee = calculateInfluencerFee(adminFee, influencerFeePercentage);
        uint256 masterInfluencerFee = masterInfluencer != address(0) ? calculateInfluencerFee(adminFee, masterInfluencerFeePercentage) : 0;
        ownerShare += (adminFee.sub(influencerFee)).sub(masterInfluencerFee); 
        bytes memory v3SwapExactInCommand = abi.encodePacked(bytes1(0x00), bytes1 (0x0c));
        bytes memory path = abi.encodePacked(tokenIn,fee,wrapETH);
        bytes memory swapExactInInputs = abi.encode( 
            0x0000000000000000000000000000000000000002,
            amountIn,
            amountOutMin,
            path,
            false
        );
        bytes memory unwrapEthInputs = abi.encode(
            msg.sender,
            amountOutMin
        );  
        bytes[] memory inputsArray = new bytes[](2);
        inputsArray[0] = swapExactInInputs;
        inputsArray[1] = unwrapEthInputs;

    uniswapRouter.execute(v3SwapExactInCommand, inputsArray, block.timestamp + 10);
    processInfluencerPayments(influencer, influencerFee, masterInfluencer, masterInfluencerFee);
  
    }


    function buyV3(
        uint256 amountOutMin,
        address tokenOut,
        uint24 fee,
        address influencerAddress,
        uint256 influencerFeePercentage,
        address masterInfluencerAddress,
        uint256 masterInfluencerFeePercentage
    ) external payable {
        uint256 adminFee = adminFeeInETH;
        require(msg.value >= adminFee, "Insufficient balance for fee");
        require(influencerFeePercentage <= 100, "Influencer fee percentage must be <= 100");
        require(masterInfluencerFeePercentage <=100, "masterInfluencer fee percentage must be <= 100");


        uint256 influencerFee = calculateInfluencerFee(adminFee, influencerFeePercentage);
        uint256 masterInfluencerFee = (masterInfluencerAddress != address(0)) ? 
        calculateInfluencerFee(adminFee, masterInfluencerFeePercentage) : 0;
        ownerShare += (adminFee.sub(influencerFee)).sub(masterInfluencerFee); 
        uint256 remainingAmount = msg.value.sub(adminFee);

        executeUniswapTransaction(amountOutMin, tokenOut, fee, remainingAmount);
        processInfluencerPayments(influencerAddress, influencerFee, masterInfluencerAddress, masterInfluencerFee);
    }

    function executeUniswapTransaction(
        uint256 amountOutMin,
        address tokenOut,
        uint24 fee,
        uint256 remainingAmount
    )   internal {
    
        bytes memory v3SwapExactInCommand = abi.encodePacked(bytes1(0x0b), bytes1(0x00));
        bytes memory wrapEthInputs = abi.encode(
            0x0000000000000000000000000000000000000002,
            remainingAmount 
        );

    bytes memory path = abi.encodePacked(wrapETH, fee, tokenOut);
    bytes memory swapExactInInputs = abi.encode(
        msg.sender,
        remainingAmount,
        amountOutMin,
        path,
        false
    );

    bytes[] memory inputsArray = new bytes[](2);
    inputsArray[0] = wrapEthInputs;
    inputsArray[1] = swapExactInInputs;

    uniswapRouter.execute{value: remainingAmount}(v3SwapExactInCommand, inputsArray, block.timestamp + 10);
    }

    function processInfluencerPayments(
        address influencerAddress,
        uint256 influencerFee,
        address masterInfluencerAddress,
        uint256 masterInfluencerFee
    ) internal {
        processInfluencerPayment(influencerAddress, influencerFee);
        if (masterInfluencerAddress != address(0)) {
            processInfluencerPayment(masterInfluencerAddress, masterInfluencerFee);
        }
    }
   
    receive() external payable {   
    }

}