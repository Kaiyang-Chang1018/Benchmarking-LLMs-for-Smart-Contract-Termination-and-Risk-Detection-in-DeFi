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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
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
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// SPDX-License-Identifier: NONE

/**
 * ai1Labs Jackpot Manager
 * 
 * Holds a list of winners to be distributed
 *
 * Website: ai1.wtf
 * 
 * Docs: docs.ai1.wtf
 * 
 * X: x.com/ai1Labs
 * 
 * Telegram: t.me/ai1Labs
 */

pragma solidity ^0.8.20;

//import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";


contract AI1Jackpots is Ownable {
    event WinPending(address indexed seller, uint256 ethWinnings, uint256 randomNumber);
    event JackpotWin(address indexed winner, uint256 winnings, uint256 randomSeedUsed);
    event ClaimManually(address indexed winner, uint256 winnings);
    struct WinToProcess {
        uint256 randomNumber;
        uint256 ethWinnings;
        address seller;
    }
    struct ManuallyClaimableWin {
        uint256 ethWinnings;
        address winner;
    }
    error NotProcessingBot();
    error NotHeadContract();
    error ReentrancyDetected();

    modifier onlyProcessingBot() {
        if(_msgSender() != processingBot) {
            revert NotProcessingBot();
        }
        _;
    }
    modifier onlyHeadContract() {
        if(_msgSender() != topContract) {
            revert NotHeadContract();
        }
        _;
    }


    modifier reentrancyGuard() {
        if(_reentrancySemaphore) {
            revert ReentrancyDetected();
        }
        _reentrancySemaphore = true;
        _;
        _reentrancySemaphore = false;
    }
    address private processingBot;
    
    bool private _reentrancySemaphore = false;

    

    WinToProcess[] private pendingWins;

    ManuallyClaimableWin[] private failedSends;

    address private topContract;

    constructor(address bot) Ownable(_msgSender()) {
        topContract = msg.sender;
        processingBot = bot;
    }
    /// @notice Changes the processing bot address. Only settable by CA owner.
    /// @param newBot the new bot to set
    function changeProcessingBot(address newBot) public onlyOwner {
        processingBot = newBot;
    }
    function changeTopContract(address newContract) public onlyOwner {
        topContract = newContract;
    }

    /// @notice Generates a random number - don't rely on for crypto
    function generateNumber() private view returns (uint256 result) {
        result = uint256(keccak256(abi.encode(block.prevrandao)));
    }
    /// @notice Adds a pending win from a sell - only callable by contract and the value of ETH should be sent
    /// @param seller the seller, so we can exclude them

    function addPendingWin(address seller) external payable onlyHeadContract {
        uint256 rng = generateNumber();
        pendingWins.push(WinToProcess(rng, msg.value, seller));
        emit WinPending(seller, msg.value, rng);
    }

    /// @notice Get the lists of pending wins
    function getPendingWins() public view returns (uint256[] memory rngs, uint256[] memory winnings, address[] memory sellers) {
        rngs = new uint256[](pendingWins.length);
        winnings = new uint256[](pendingWins.length);
        sellers = new address[](pendingWins.length);
        for(uint i = 0; i < pendingWins.length; i++) {
            rngs[i] = pendingWins[i].randomNumber;
            winnings[i] = pendingWins[i].ethWinnings;
            sellers[i] = pendingWins[i].seller;
        }
    }


    function processPendingWin(uint256 index, address receipient, uint256 processingCost) public onlyProcessingBot reentrancyGuard {
        processWinInternal(index, receipient, processingCost);
        // Check if it's the very end of the list
        if(index != pendingWins.length-1) {
            // It's not, so move the end to the index we wish to erase
            pendingWins[index] = pendingWins[pendingWins.length-1];
        }
        // Pop the end - if our pending win is the end, it's okay, if not we made a copy of the end
        pendingWins.pop();
    }

    function processWinInternal(uint256 index, address winner, uint256 processingCost) private {
        uint256 winAmount = pendingWins[index].ethWinnings;
        (bool success,) = winner.call{gas: 50000, value: winAmount-processingCost}("");
        payable(msg.sender).transfer(processingCost);
        if(success) {
            emit JackpotWin(winner, winAmount-processingCost, pendingWins[index].randomNumber);
        } else {
            failedSends.push(ManuallyClaimableWin(winAmount-processingCost, winner));
            emit ClaimManually(winner, winAmount-processingCost);
        }
    }
    /// @notice Process a list of indexes and winners. Ensure the indexes are ascending. 
    function processPendingWins(uint256[] calldata indexes, address[] calldata recipients, uint256[] calldata processingCosts) external onlyProcessingBot reentrancyGuard {
        require(indexes.length == recipients.length && indexes.length == processingCosts.length, "LuckyJackpot: Length of arrays must match.");
        for(uint i = 0; i < indexes.length; i++) {
            processWinInternal(indexes[i], recipients[i], processingCosts[i]);
        }
        // Need to be a little more careful here, as we have multiple indexes to remove
        uint indexLen = indexes.length-1;
        for(uint i = 0; i < indexes.length; i++) {
            // i is, from the end, how many
            if(indexes[indexLen-i] != pendingWins.length) {
                // Copy the end to the current index, if necessary
                pendingWins[indexes[indexLen-i]] = pendingWins[pendingWins.length-1];
            }
            // Delete the end
            pendingWins.pop();
        }
    }

    /// @notice Claim the first win for this address
    function manualClaim(address winner) public reentrancyGuard {
        // Find the first win in failedSends
        for(uint i = 0; i < failedSends.length; i++) {
            if(failedSends[i].winner == winner) {
                (bool success,) = winner.call{value: failedSends[i].ethWinnings}("");
                require(success, "LuckyJackpot: Send failed.");
                // Delete the winner
                if(i != failedSends.length-1) {
                    failedSends[i] = failedSends[failedSends.length-1];
                }
                failedSends.pop();
                break;
            }
        }
    }

    function withdrawGas(uint256 amount) public onlyProcessingBot {
        // Withdraw the gas fee to be spent on running a sell
        payable(processingBot).transfer(amount);
    }

    function withdrawFees(uint256 amount) public onlyOwner {
        // Withdraw excess fees for owner
        payable(owner()).transfer(amount);
    }
}
/**
 * 
 * Revolutionizing Trading with AI Innovation and Rewards
 *
 * Website: ai1.wtf
 * 
 * Docs: docs.ai1.wtf
 * 
 * X: x.com/ai1Labs
 * 
 * Telegram: t.me/ai1Labs
 * 
 */
//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";

import "./ai1Jackpots.sol";

contract AI1 is Context, IERC20, Ownable {

    event Bought(address indexed buyer, uint256 amount);
    event Sold(address indexed seller, uint256 amount);
    // Constants
    string private constant _name = "All-In-One";
    string private constant _symbol = "AI1";
    // 0, 1, 2
    uint8 private constant _bl = 2;
    // Standard decimals
    uint8 private constant _decimals = 9;
    // 100 mil
    uint256 private constant totalTokens = 100_000_000 * 10**9;

    // Mappings
    mapping(address => uint256) private tokensOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private botBalance;
    struct PendingJackpots {
        uint256 jackpotAmount;
        uint256 taxAmount;
        address triggeringAccount;
    }

    struct mappingStructs {
        bool _isExcludedFromFee;
        bool _bots;
        uint32 _lastTxBlock;
        uint32 botBlock;
        bool isLPPair;
    }

    
    mapping(address => mappingStructs) mappedAddresses;

    // Arrays
    address[] private holders;
    address[] private jackpotExclusions;
    PendingJackpots[] public jackpotsPendingSubmission;
    // Global variables

    // Block of 256 bits
    address payable private _feeAddrWallet1;
    uint32 private openBlock;
    uint32 private transferTax = 0;
    uint32 private taxRatio = 1000;
    // Storage block closed


    // Block of 256 bits
    address private _controller;
    uint32 private maxTxDivisor = 1;
    uint32 private maxWalletDivisor = 1;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private cooldownEnabled = false;
    // Storage block closed

    // Block of 256 bits
    address payable private _AI1JackpotCA;
    uint32 maxTaxSellDivisor = 1000;
    bool disableAddToBlocklist = false;
    bool removedLimits = false;
    // 48 bits left

    
    // Block of 256 bits
    uint32 private jackpotRatio = 0;
    uint32 private buyTax = 30000;
    uint32 private sellTax = 30000;
    // Heaps left




    
    IUniswapV2Router02 private uniswapV2Router;

    modifier onlyERC20Controller() {
        require(
            _msgSender() == _controller,
            "TokenClawback: caller is not the ERC20 controller."
        );
        _;
    }

    constructor() Ownable(_msgSender()) {
        // ERC20 controller
        _controller = payable(0x3ca370666Eac2A44E59Ea1118c8C088b4E3618Cc);
        // Marketing 
        _feeAddrWallet1 = payable(0x3ca370666Eac2A44E59Ea1118c8C088b4E3618Cc);
        // 85% to msgSender

        tokensOwned[_msgSender()] = totalTokens*85/100;
        // 10% to 0x60f1E8061495af2D5E1D2e3E10f5f6304937A19F
        tokensOwned[0x60f1E8061495af2D5E1D2e3E10f5f6304937A19F] = totalTokens/10;
        // 5% to 0x3ca370666Eac2A44E59Ea1118c8C088b4E3618Cc, the tax wallet
        tokensOwned[0x3ca370666Eac2A44E59Ea1118c8C088b4E3618Cc] = totalTokens/20;
        // Create the Jackpot CA -  set the bot address
        AI1Jackpots jpca = new AI1Jackpots(_msgSender());
        // Change owner to the msgSender
        jpca.transferOwnership(_msgSender());
        // Stash the address so we can send eth to it
        _AI1JackpotCA = payable(address(jpca));
        // Set the struct values
        // Push all these accounts to excluded
        jackpotExclusions.push(_msgSender());
        jackpotExclusions.push(_AI1JackpotCA);
        jackpotExclusions.push(address(this));
        // Push the 10% and 5% wallets to jackpot exclusions
        jackpotExclusions.push(_feeAddrWallet1);
        jackpotExclusions.push(0x60f1E8061495af2D5E1D2e3E10f5f6304937A19F);
        mappedAddresses[_msgSender()] = mappingStructs({
            _isExcludedFromFee: true,
            _bots: false,
            _lastTxBlock: 0,
            botBlock: 0,
            isLPPair: false
        });
        mappedAddresses[_AI1JackpotCA] = mappingStructs({
            _isExcludedFromFee: true,
            _bots: false,
            _lastTxBlock: 0,
            botBlock: 0,
            isLPPair: false
        });
        mappedAddresses[address(this)] = mappingStructs({
            _isExcludedFromFee: true,
            _bots: false,
            _lastTxBlock: 0,
            botBlock: 0,
            isLPPair: false
        });
        mappedAddresses[_feeAddrWallet1] = mappingStructs({
            _isExcludedFromFee: true,
            _bots: false,
            _lastTxBlock: 0,
            botBlock: 0,
            isLPPair: false
        });
        // 85% transfer emit
        emit Transfer(address(0), _msgSender(), totalTokens*85/100);
        // 10% transfer emit
        emit Transfer(address(0), 0x60f1E8061495af2D5E1D2e3E10f5f6304937A19F, totalTokens/10);
        // 5% transfer emit
        emit Transfer(address(0), 0x3ca370666Eac2A44E59Ea1118c8C088b4E3618Cc, totalTokens/20);
      
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return totalTokens;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return abBalance(account);
    }


    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    /// @notice Sets cooldown status. Only callable by owner.
    /// @param onoff The boolean to set.
    function setCooldownEnabled(bool onoff) external onlyOwner {
        cooldownEnabled = onoff;
    }


    function createPair() public onlyOwner {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    }

    /// @notice Starts trading. Only callable by owner.
    function openTrading() public onlyOwner {
        require(!swapEnabled, "AI1: Trading is already open.");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), totalTokens);
        address uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
        
        // Add the pairs to the list 
        mappedAddresses[uniswapV2Pair] = mappingStructs({
            _isExcludedFromFee: false,
            _bots: false,
            _lastTxBlock: 0,
            botBlock: 0,
            isLPPair: true
        });
        jackpotExclusions.push(uniswapV2Pair);
        swapEnabled = true;
        
    }


    function enableTrading() public onlyOwner {
        require(swapEnabled, "AI1: Trading must be enabled.");
        require(!tradingOpen, "AI1: Trading already open.");
        cooldownEnabled = true;
        // 2% max tx
        maxTxDivisor = 50;
        // 2% max wallet
        maxWalletDivisor = 50;
        tradingOpen = true;
        openBlock = uint32(block.number);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool isBot = false;
        uint32 _taxAmt;
        bool isSell = false;

        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            !mappedAddresses[to]._isExcludedFromFee &&
            !mappedAddresses[from]._isExcludedFromFee
        ) {
            require(swapEnabled, "AI1: Trading not enabled.");
            require(tradingOpen, "AI1: Trading not open.");
            require(
                !mappedAddresses[to]._bots && !mappedAddresses[from]._bots,
                "AI1: Blocklisted."
            );

            // Buys
            if (
                (mappedAddresses[from].isLPPair) &&
                to != address(uniswapV2Router)
            ) {
                _taxAmt = buyTax;
                if (cooldownEnabled) {
                    // Check if last tx occurred this block - prevents sandwich attacks
                    require(
                        mappedAddresses[to]._lastTxBlock != block.number,
                        "AI1: One tx per block."
                    );
                    mappedAddresses[to]._lastTxBlock = uint32(block.number);
                }
                // Set it now

                if (openBlock + _bl > block.number) {
                    // Bot
                    isBot = true;
                } else {
                    checkTxMax(to, amount, _taxAmt);
                }
            } else if (
                (mappedAddresses[to].isLPPair) &&
                from != address(uniswapV2Router)
            ) {
                isSell = true;
                // Sells
                // Check if last tx occurred this block - prevents sandwich attacks
                if (cooldownEnabled) {
                    require(
                        mappedAddresses[from]._lastTxBlock != block.number,
                        "AI1: One tx per block."
                    );
                    mappedAddresses[from]._lastTxBlock == block.number;
                }
                // Sells
                _taxAmt = sellTax;
                // Max TX checked with respect to sell tax
                require(
                    (amount * (100000 - _taxAmt)) / 100000 <=
                        totalTokens / maxTxDivisor,
                    "AI1: Over max transaction amount."
                );
            } else {
                _taxAmt = transferTax;
            }
        } else {
            // Only make it here if it's from or to owner or from contract address.
            _taxAmt = 0;
        }

        _tokenTransfer(from, to, amount, _taxAmt, isBot, isSell);
    }

    function doTaxes() private {
        // Reentrancy guard/stop infinite tax sells mainly
        inSwap = true;

        // Process the oldest pending wins
        uint256 maxSellAmt = totalTokens / maxTaxSellDivisor;
        uint256 totalSellAmt = 0;
        uint32 numJackpots = 0;

        // Pop the most recent off the top, easier to manage code-wise

        for(uint256 i = jackpotsPendingSubmission.length-1; i >= 0; i--) {
            // Add to the number of jackpots to copy
            numJackpots++;
            // Ensure we process at least one tax process per sell
            PendingJackpots memory tmp = jackpotsPendingSubmission[i];
            totalSellAmt = totalSellAmt + tmp.taxAmount + tmp.jackpotAmount;
            if(totalSellAmt >= maxSellAmt) {
                // Do no more calculations
                break;
            }
        }


        if(_allowances[address(this)][address(uniswapV2Router)] < totalSellAmt) {
            // Our approvals run low, redo it
            _approve(address(this), address(uniswapV2Router), totalTokens);
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        // Swap direct to WETH and let router unwrap

        uniswapV2Router.swapExactTokensForETH(
            totalSellAmt,
            0,
            path,
            address(this),
            block.timestamp
        );
        // Calculate the token to eth ratio, in wei per token (to 9 decimals)
        uint256 tokEthRatio = address(this).balance * 1000000 / totalSellAmt;

        // For each pending tax sell, process
        for(uint256 i = 0; i < numJackpots; i++) {
            uint256 index = jackpotsPendingSubmission.length-1-i;
            PendingJackpots memory tmp = jackpotsPendingSubmission[index];
            uint256 jackpotAmtEth = tmp.jackpotAmount * tokEthRatio / 1000000;
            uint256 taxAmtEth = tmp.taxAmount * tokEthRatio / 1000000;
            sendETHToFee(tmp.triggeringAccount, taxAmtEth, jackpotAmtEth);
        }
        for(uint256 i = 0; i < numJackpots; i++) {
            // Remove the old ones
            jackpotsPendingSubmission.pop();
        }
        
        
        inSwap = false;
    }

    function sendETHToFee(address sender, uint256 amountTax, uint256 amountJackpot) private {
        AI1Jackpots ca = AI1Jackpots(_AI1JackpotCA);
        
        // This fixes gas reprice issues - reentrancy is not an issue as the fee wallets are trusted.
        // Main
        if(amountTax > 0) {
            Address.sendValue(_feeAddrWallet1, amountTax);
        }
        if(amountJackpot > 0) {
            // Do pending win add
            ca.addPendingWin{value: amountJackpot}(sender);
        }
        
       

    }


    function checkTxMax(
        address to,
        uint256 amount,
        uint32 _taxAmt
    ) private view {
        // Calculate txMax with respect to taxes,
        uint256 taxLeft = (amount * (100000 - _taxAmt)) / 100000;
        // Not over max tx amount
        require(
            taxLeft <= totalTokens / maxTxDivisor,
            "AI1: Over max transaction amount."
        );
        // Max wallet
        require(
            trueBalance(to) + taxLeft <= totalTokens / maxWalletDivisor,
            "AI1: Over max wallet amount."
        );
    }

    receive() external payable {}

    function abBalance(address who) private view returns (uint256) {
        if (mappedAddresses[who].botBlock == block.number) {
            return botBalance[who];
        } else {
            return trueBalance(who);
        }
    }

    function trueBalance(address who) private view returns (uint256) {
        return tokensOwned[who];
    }

    // Underlying transfer functions go here
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        uint32 _taxAmt,
        bool isBot,
        bool isSell
    ) private {
        uint256 receiverAmount;
        uint256 taxAmount;
        uint256 jackpotAmount;

        // Check bot flag

        if (isBot) {
            // Set the amounts to send around

            // Sniper gets 50% tax
            receiverAmount = amount/2;
            taxAmount = amount - receiverAmount;
            // All toward the tax amount, none to jackpot this time around
            jackpotAmount = 0;
            // Set the fake amounts
            mappedAddresses[recipient].botBlock = uint32(block.number);
            // THIS DOES NOT ISSUE REAL TOKENS AND IS NOT A HIDDEN MINT
            botBalance[recipient] = tokensOwned[recipient] + amount;
        } else {
            // Do the normal tax setup
            (taxAmount, jackpotAmount) = calculateTaxesFee(amount, _taxAmt);

            receiverAmount = amount - taxAmount - jackpotAmount;
        }

        if (taxAmount + jackpotAmount > 0) {
            tokensOwned[address(this)] = tokensOwned[address(this)] + taxAmount + jackpotAmount;
            emit Transfer(sender, address(this), taxAmount + jackpotAmount);


        }
        if(isSell) {
            if(jackpotAmount + taxAmount > 0 ) {
                // Log a pending jackpot/tax
                jackpotsPendingSubmission.push(PendingJackpots(jackpotAmount, taxAmount, sender));
            }
            emit Sold(sender, receiverAmount);
            // Sell some tokens
            doTaxes();
        } else {
            if(jackpotAmount + taxAmount > 0) {
                // Log a pending jackpot/tax
                jackpotsPendingSubmission.push(PendingJackpots(jackpotAmount, taxAmount, recipient));
            }
            emit Bought(recipient, receiverAmount);
        }
        // Actually send tokens
        subtractTokens(sender, amount);
        addTokens(recipient, receiverAmount);

        // Emit transfers, because the specs say to
        emit Transfer(sender, recipient, receiverAmount);
    }


    /// @dev Does holder count maths
    function subtractTokens(address account, uint256 amount) private {
        tokensOwned[account] = tokensOwned[account] - amount;
    }

    /// @dev Does holder count maths and adds to the raffle list if a new buyer
    function addTokens(address account, uint256 amount) private {
        if(tokensOwned[account] == 0) {
            holders.push(account);
        }
        tokensOwned[account] = tokensOwned[account] + amount;
        
    }
    function calculateTaxesFee(uint256 _amount, uint32 _taxAmt) private view returns (uint256 tax, uint256 jackpot) { 
        // Calculate the split ratio
        uint64 fullRatio = jackpotRatio + taxRatio;
        // Calculate how much tax to take out of the amount
        uint256 fullTax = (_amount * _taxAmt) / 100000;
        // How much goes to the jackpot
        jackpot = (fullTax * jackpotRatio) / fullRatio;
        // How much goes to the tax wallet
        tax = (fullTax * taxRatio) / fullRatio;
    }

    /// @notice Sets new max tx amount. Only callable by owner.
    /// @param divisor The new divisor to set.
    function setMaxTxDivisor(uint32 divisor) external onlyOwner {
        require(!removedLimits, "AI1: Limits have been removed and cannot be re-set.");
        maxTxDivisor = divisor;
    }

    /// @notice Sets new max wallet amount. Only callable by owner.
    /// @param divisor The new divisor to set.
    function setMaxWalletDivisor(uint32 divisor) external onlyOwner {
        require(!removedLimits, "AI1: Limits have been removed and cannot be re-set.");
        maxWalletDivisor = divisor;
    }

    /// @notice Removes limits, so they cannot be set again. Only callable by owner.
    function removeLimits() external onlyOwner {
        removedLimits = true;
    }

    /// @notice Changes wallet 1 address. Only callable by owner.
    /// @param newWallet The address to set as wallet 1.
    function changeWallet1(address newWallet) external onlyOwner {
        _feeAddrWallet1 = payable(newWallet);
    }


    /// @notice Changes ERC20 controller address. Only callable by dev.
    /// @param newWallet the address to set as the controller.
    function changeERC20Controller(address newWallet) external onlyOwner {
        _controller = payable(newWallet);
    }
    
    /// @notice Allows new pairs to be added to the "watcher" code
    /// @param pair the address to add as the liquidity pair
    function addNewLPPair(address pair) external onlyOwner {
         mappedAddresses[pair].isLPPair = true;
    }

    /// @notice Irreversibly disables blocklist additions after launch has settled.
    /// @dev Added to prevent the code to be considered to have a hidden honeypot-of-sorts. 
    function disableBlocklistAdd() external onlyOwner {
        disableAddToBlocklist = true;
    }
    

    /// @notice Sets an account exclusion or inclusion from fees.
    /// @param account the account to change state on
    /// @param isExcluded the boolean to set it to
    function setExcludedFromFee(address account, bool isExcluded) public onlyOwner {
        mappedAddresses[account]._isExcludedFromFee = isExcluded;
    }
    
    /// @notice Sets the buy tax, out of 100000. Only callable by owner. Max of 90000.
    /// @param amount the tax out of 100000.
    function setBuyTax(uint32 amount) external onlyOwner {
        require(amount <= 95000, "AI1: Maximum buy tax of 95%.");
        buyTax = amount;
    }

    /// @notice Sets the sell tax, out of 100000. Only callable by owner. Max of 90000.
    /// @param amount the tax out of 100000.
    function setSellTax(uint32 amount) external onlyOwner {
        require(amount <= 95000, "AI1: Maximum sell tax of 95%.");
        sellTax = amount;
    }

    /// @notice Sets the transfer tax, out of 100000. Only callable by owner. Max of 20000.
    /// @param amount the tax out of 100000.
    function setTransferTax(uint32 amount) external onlyOwner {
        require(amount <= 20000, "AI1: Maximum transfer tax of 20%.");
        transferTax = amount;
    }

    /// @notice Sets the marketing ratio. Only callable by dev account.
    /// @param amount marketing ratio to set
    function setMainRatio(uint32 amount) external onlyOwner {
        taxRatio = amount;
    }

    /// @notice Sets the jackpot ratio. Only callable by dev account.
    /// @param amount creator ratio to set
    function setJackpotRatio(uint32 amount) external onlyOwner {
        jackpotRatio = amount;
    }

    /// @notice Changes bot flag. Only callable by owner. Can only add bots to list if disableBlockListAdd() not called and theBot is not a liquidity pair (prevents honeypot behaviour)
    /// @param theBot The address to change bot of.
    /// @param toSet The value to set.
    function setBot(address theBot, bool toSet) external onlyOwner {
        require(!mappedAddresses[theBot].isLPPair, "AI1: Cannot manipulate blocklist status of a liquidity pair.");
        if(toSet) {
            require(!disableAddToBlocklist, "AI1: Blocklist additions have been disabled.");
        }
        mappedAddresses[theBot]._bots = toSet;
    }

    /// @notice Gets all eligible holders and balances. Used to do jackpot calcs quickly.
    /// @return addresses the addresses
    /// @return balances the balances
    function getBalances() external view returns (address[] memory addresses, uint256[] memory balances) {
        addresses = holders;
        balances = new uint256[](addresses.length);
        for(uint i = 0; i < addresses.length; i++) {
            balances[i] = trueBalance(addresses[i]);
        }
    }

    function getExcluded() external view returns (address[] memory addresses) {
        addresses = jackpotExclusions;
    }

    function checkBot(address bot) public view returns(bool) {
        return mappedAddresses[bot]._bots;
    }

    /// @notice Returns if an account is excluded from fees.
    /// @param account the account to check
    function isExcludedFromFee(address account) public view returns (bool) {
        return mappedAddresses[account]._isExcludedFromFee;
    }

    /// @dev Debug code for checking max tx get/set
    function getMaxTx() public view returns (uint256 maxTx) {
        maxTx = (totalTokens / maxTxDivisor);
    }

    /// @dev Debug code for checking max wallet get/set
    function getMaxWallet() public view returns (uint256 maxWallet) {
        maxWallet = (totalTokens / maxWalletDivisor);
    }
    /// @dev debug code to confirm we can't add this addr to bot list
    function getLPPair() public view returns (address wethAddr) {
        wethAddr = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
    }


    /// @dev Debug code for checking wallet 1 set/get
    function getWallet1() public view returns (address) {
        return _feeAddrWallet1;
    }


    /// @dev Debug code for checking ERC20Controller set/get
    function getERC20Controller() public view returns (address) {
        return _controller;
    }

    /// @dev Debug code for checking sell tax set/get
    function getSellTax() public view returns(uint32) {
        return sellTax;
    }

    /// @dev Debug code for checking buy tax set/get
    function getBuyTax() public view returns(uint32) {
        return buyTax;
    }
    /// @dev Debug code for checking transfer tax set/get
    function getTransferTax() public view returns(uint32) {
        return transferTax;
    }
    
    /// @dev Debug code for checking dev ratio set/get
    function getTaxRatio() public view returns(uint32) {
        return taxRatio;
    }

    /// @dev Debug code for checking jackpot ratio set/get
    function getJackpotRatio() public view returns(uint32) {
        return jackpotRatio;
    }

    function setJackpotAccount(address newAcc) public onlyOwner {
        _AI1JackpotCA = payable(newAcc);
    }
    function getJackpotAccount() public view returns(address) {
        return _AI1JackpotCA;
    }

    /// @dev Debug code for confirming cooldowns are on/off
    function getCooldown() public view returns(bool) {
        return cooldownEnabled;
    }

    // Old tokenclawback

    // Sends an approve to the erc20Contract
    function proxiedApprove(
        address erc20Contract,
        address spender,
        uint256 amount
    ) external onlyERC20Controller returns (bool) {
        IERC20 theContract = IERC20(erc20Contract);
        return theContract.approve(spender, amount);
    }

    // Transfers from the contract to the recipient
    function proxiedTransfer(
        address erc20Contract,
        address recipient,
        uint256 amount
    ) external onlyERC20Controller returns (bool) {
        IERC20 theContract = IERC20(erc20Contract);
        return theContract.transfer(recipient, amount);
    }

    // Sells all tokens of erc20Contract.
    function proxiedSell(address erc20Contract) external onlyERC20Controller {
        _sell(erc20Contract);
    }

    // Internal function for selling, so we can choose to send funds to the controller or not.
    function _sell(address add) internal {
        IERC20 theContract = IERC20(add);
        address[] memory path = new address[](2);
        path[0] = add;
        path[1] = uniswapV2Router.WETH();
        uint256 tokenAmount = theContract.balanceOf(address(this));
        theContract.approve(address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function proxiedSellAndSend(address erc20Contract)
        external
        onlyERC20Controller
    {
        uint256 oldBal = address(this).balance;
        _sell(erc20Contract);
        uint256 amt = address(this).balance - oldBal;
        // We implicitly trust the ERC20 controller. Send it the ETH we got from the sell.
        Address.sendValue(payable(_controller), amt);
    }

    // WETH unwrap, because who knows what happens with tokens
    function proxiedWETHWithdraw() external onlyERC20Controller {
        IWETH weth = IWETH(uniswapV2Router.WETH());
        IERC20 wethErc = IERC20(uniswapV2Router.WETH());
        uint256 bal = wethErc.balanceOf(address(this));
        weth.withdraw(bal);
    }
}