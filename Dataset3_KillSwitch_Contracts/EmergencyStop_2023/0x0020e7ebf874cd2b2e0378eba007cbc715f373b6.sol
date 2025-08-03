// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;



// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper::safeTransferETH: ETH transfer failed");
    }
}

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

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address internal _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    // /**
    //  * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
    //  * Can only be called by the current owner.
    //  */
    // function transferOwnership(address newOwner) public virtual override onlyOwner {
    //     _pendingOwner = newOwner;
    //     emit OwnershipTransferStarted(owner(), newOwner);
    // }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() external {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}

contract OwnableDelayModule is Ownable2Step {
  address internal delayModule;

  constructor() {
    delayModule = msg.sender;
  }

  function isDelayModule() internal view {
    require(msg.sender == delayModule, "NA");
  }

  function setDelayModule(address _delayModule) external {
    isDelayModule();
    require(_delayModule != address(0), "ODZ");
    delayModule = _delayModule;
  }

  function getDelayModule() external view returns (address) {
    return delayModule;
  }

  /**
   * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public override {
    isDelayModule();
    _pendingOwner = newOwner;
    emit OwnershipTransferStarted(owner(), newOwner);
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
}

// Reference: https://github.com/cryptofinlabs/cryptofin-solidity/blob/master/contracts/array-utils/AddressArrayUtils.sol
library ArrayUtils {
  /**
   * Deletes address at index and fills the spot with the last address.
   * Order is preserved.
   */
  // solhint-disable-next-line var-name-mixedcase
  function sPopAddress(address[] storage A, uint index) internal {
    uint length = A.length;
    if (index >= length) {
      revert("Error: index out of bounds");
    }

    for (uint i = index; i < length - 1; i++) {
      A[i] = A[i + 1];
    }
    A.pop();
  }

  // solhint-disable-next-line var-name-mixedcase
  function sPopUint256(uint[] storage A, uint index) internal {
    uint length = A.length;
    if (index >= length) {
      revert("Error: index out of bounds");
    }

    for (uint i = index; i < length - 1; i++) {
      A[i] = A[i + 1];
    }
    A.pop();
  }

  // solhint-disable-next-line var-name-mixedcase
  function sumOfMArrays(
    uint[] memory A,
    uint[] memory B
  ) internal pure returns (uint[] memory sum) {
    sum = new uint[](A.length);
    for (uint i = 0; i < A.length; i++) {
      sum[i] = A[i] + B[i];
    }
    return sum;
  }

  /**
   * Finds the index of the first occurrence of the given element.
   * @param A The input array to search
   * @param a The value to find
   * @return Returns (index and isIn) for the first occurrence starting from index 0
   */
  function indexOf(address[] memory A, address a) internal pure returns (uint, bool) {
    uint length = A.length;
    for (uint i = 0; i < length; i++) {
      if (A[i] == a) {
        return (i, true);
      }
    }
    return (type(uint).max, false);
  }

  /**
   * Returns true if the value is present in the list. Uses indexOf internally.
   * @param A The input array to search
   * @param a The value to find
   * @return Returns isIn for the first occurrence starting from index 0
   */
  function contains(address[] memory A, address a) internal pure returns (bool) {
    (, bool isIn) = indexOf(A, a);
    return isIn;
  }

  /**
   * Returns true if there are 2 elements that are the same in an array
   * @param A The input array to search
   * @return Returns boolean for the first occurrence of a duplicate
   */
  function hasDuplicate(address[] memory A) internal pure returns (bool) {
    require(A.length > 0, "A is empty");

    for (uint i = 0; i < A.length - 1; i++) {
      address current = A[i];
      for (uint j = i + 1; j < A.length; j++) {
        if (current == A[j]) {
          return true;
        }
      }
    }
    return false;
  }

  /**
   * @param A The input array to search
   * @param a The address to remove
   * @return Returns the array with the object removed.
   */
  function remove(
    address[] memory A,
    address a
  ) internal pure returns (address[] memory) {
    (uint index, bool isIn) = indexOf(A, a);
    if (!isIn) {
      revert("Address not in array.");
    } else {
      (address[] memory _A, ) = pop(A, index);
      return _A;
    }
  }

  /**
   * @param A The input array to search
   * @param a The address to remove
   */
  function removeStorage(address[] storage A, address a) internal {
    (uint index, bool isIn) = indexOf(A, a);
    if (!isIn) {
      revert("Address not in array.");
    } else {
      uint lastIndex = A.length - 1; // If the array would be empty, the previous line would throw, so no underflow here
      if (index != lastIndex) {
        A[index] = A[lastIndex];
      }
      A.pop();
    }
  }

  /**
   * Removes specified index from array
   * @param A The input array to search
   * @param index The index to remove
   * @return Returns the new array and the removed entry
   */
  function pop(
    address[] memory A,
    uint index
  ) internal pure returns (address[] memory, address) {
    uint length = A.length;
    require(index < A.length, "Index must be < A length");
    address[] memory newAddresses = new address[](length - 1);
    for (uint i = 0; i < index; i++) {
      newAddresses[i] = A[i];
    }
    for (uint j = index + 1; j < length; j++) {
      newAddresses[j - 1] = A[j];
    }
    return (newAddresses, A[index]);
  }

  /**
   * Returns the combination of the two arrays
   * @param A The first array
   * @param B The second array
   * @return Returns A extended by B
   */
  function extend(
    address[] memory A,
    address[] memory B
  ) internal pure returns (address[] memory) {
    uint aLength = A.length;
    uint bLength = B.length;
    address[] memory newAddresses = new address[](aLength + bLength);
    for (uint i = 0; i < aLength; i++) {
      newAddresses[i] = A[i];
    }
    for (uint j = 0; j < bLength; j++) {
      newAddresses[aLength + j] = B[j];
    }
    return newAddresses;
  }

  /**
   * Validate that address and uint array lengths match. Validate address array is not empty
   * and contains no duplicate elements.
   *
   * @param A         Array of addresses
   * @param B         Array of uint
   */
  function validatePairsWithArray(address[] memory A, uint[] memory B) internal pure {
    require(A.length == B.length, "Array length mismatch");
    _validateLengthAndUniqueness(A);
  }

  /**
   * Validate that address and bool array lengths match. Validate address array is not empty
   * and contains no duplicate elements.
   *
   * @param A         Array of addresses
   * @param B         Array of bool
   */
  function validatePairsWithArray(address[] memory A, bool[] memory B) internal pure {
    require(A.length == B.length, "Array length mismatch");
    _validateLengthAndUniqueness(A);
  }

  /**
   * Validate that address and string array lengths match. Validate address array is not empty
   * and contains no duplicate elements.
   *
   * @param A         Array of addresses
   * @param B         Array of strings
   */
  function validatePairsWithArray(address[] memory A, string[] memory B) internal pure {
    require(A.length == B.length, "Array length mismatch");
    _validateLengthAndUniqueness(A);
  }

  /**
   * Validate that address array lengths match, and calling address array are not empty
   * and contain no duplicate elements.
   *
   * @param A         Array of addresses
   * @param B         Array of addresses
   */
  function validatePairsWithArray(
    address[] memory A,
    address[] memory B
  ) internal pure {
    require(A.length == B.length, "Array length mismatch");
    _validateLengthAndUniqueness(A);
  }

  /**
   * Validate that address and bytes array lengths match. Validate address array is not empty
   * and contains no duplicate elements.
   *
   * @param A         Array of addresses
   * @param B         Array of bytes
   */
  function validatePairsWithArray(address[] memory A, bytes[] memory B) internal pure {
    require(A.length == B.length, "Array length mismatch");
    _validateLengthAndUniqueness(A);
  }

  /**
   * Validate address array is not empty and contains no duplicate elements.
   *
   * @param A          Array of addresses
   */
  function _validateLengthAndUniqueness(address[] memory A) internal pure {
    require(A.length > 0, "Array length must be > 0");
    require(!hasDuplicate(A), "Cannot duplicate addresses");
  }
}


/// @title The interface for the Uniswap V3 Factory
/// @notice The Uniswap V3 Factory facilitates creation of Uniswap V3 pools and control over the protocol fees
interface IUniswapV3Factory {
  /// @notice Emitted when the owner of the factory is changed
  /// @param oldOwner The owner before the owner was changed
  /// @param newOwner The owner after the owner was changed
  event OwnerChanged(address indexed oldOwner, address indexed newOwner);

  /// @notice Emitted when a pool is created
  /// @param token0 The first token of the pool by address sort order
  /// @param token1 The second token of the pool by address sort order
  /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
  /// @param tickSpacing The minimum number of ticks between initialized ticks
  /// @param pool The address of the created pool
  event PoolCreated(
    address indexed token0,
    address indexed token1,
    uint24 indexed fee,
    int24 tickSpacing,
    address pool
  );

  /// @notice Emitted when a new fee amount is enabled for pool creation via the factory
  /// @param fee The enabled fee, denominated in hundredths of a bip
  /// @param tickSpacing The minimum number of ticks between initialized ticks for pools created with the given fee
  event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

  /// @notice Returns the current owner of the factory
  /// @dev Can be changed by the current owner via setOwner
  /// @return The address of the factory owner
  function owner() external view returns (address);

  /// @notice Returns the tick spacing for a given fee amount, if enabled, or 0 if not enabled
  /// @dev A fee amount can never be removed, so this value should be hard coded or cached in the calling context
  /// @param fee The enabled fee, denominated in hundredths of a bip. Returns 0 in case of unenabled fee
  /// @return The tick spacing
  function feeAmountTickSpacing(uint24 fee) external view returns (int24);

  /// @notice Returns the pool address for a given pair of tokens and a fee, or address 0 if it does not exist
  /// @dev tokenA and tokenB may be passed in either token0/token1 or token1/token0 order
  /// @param tokenA The contract address of either token0 or token1
  /// @param tokenB The contract address of the other token
  /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
  /// @return pool The pool address
  function getPool(
    address tokenA,
    address tokenB,
    uint24 fee
  ) external view returns (address pool);

  /// @notice Creates a pool for the given two tokens and fee
  /// @param tokenA One of the two tokens in the desired pool
  /// @param tokenB The other of the two tokens in the desired pool
  /// @param fee The desired fee for the pool
  /// @dev tokenA and tokenB may be passed in either order: token0/token1 or token1/token0. tickSpacing is retrieved
  /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
  /// are invalid.
  /// @return pool The address of the newly created pool
  function createPool(
    address tokenA,
    address tokenB,
    uint24 fee
  ) external returns (address pool);

  /// @notice Updates the owner of the factory
  /// @dev Must be called by the current owner
  /// @param _owner The new owner of the factory
  function setOwner(address _owner) external;

  /// @notice Enables a fee amount with the given tickSpacing
  /// @dev Fee amounts may never be removed once enabled
  /// @param fee The fee amount to enable, denominated in hundredths of a bip (i.e. 1e-6)
  /// @param tickSpacing The spacing between ticks to be enforced for all pools created with the given fee amount
  function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}

interface IUniswapV3Pool {
  function observe(
    uint32[] calldata secondsAgos
  ) external
    view
    returns (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulativeX128s
    );

  function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
  function fee() external returns(uint24);
}


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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);
}


/**
 * @title IAFiStorage.
 * @notice Interface of the AFiStorage.
 */

interface IIEarnManager {
  function recommend(
    address _token,
    address afiBase,
    address afiStorage
  ) external view returns (string memory choice, uint capr, uint aapr, uint dapr);
}

interface IAFiStorage {
  /**
   * @notice Struct representing investor details.
   * @param isPresent Boolean indicating whether an investor exists.
   * @param uTokenBalance Investor underlying token balance.
   * @param investedAmount Amount of StableCoin invested in the underlying token
   */
  struct Investor {
    bool isPresent;
    uint depositNAV;
    uint redemptionNAV;
  }

  struct RedemptionParams {
        address baseContract;
        uint r;
        address oToken;
        uint256 cSwapCounter;
        address[] uTokens;
        address[] iTokens;
        uint256 deadline;
        uint256[] minimumReturnAmount;
        uint256 _pool;
        uint256 tSupply;
        uint256 depositNAV;
    }

  /**
   * @notice Struct representing TeamWallet details.
   * @param isPresent Boolean indicating whether a wallet exists.
   * @param isActive Boolean indicating whether a wallet is active.
   * @param walletAddress Wallet address.
   */
  struct TeamWallet {
    bool isPresent;
    bool isActive;
    address walletAddress;
  }

  /**
   * @notice Struct representing Rebalance details.
   * @param scenario Scenario can be either of 0, 1 or 2.
   * @param rebalancedUToken Address of the underlying token that is rebalanced.
   * @param rebalancedToUTokens Array of addresses of underlying tokens to which the uToken has been rebalanced.
   */
  struct RebalanceDetails {
    uint8 scenario;
    address rebalancedUToken;
    address[] rebalancedToUTokens;
  }

  /**
   * @param walletAddress Address of the wallet.
   * @param isActive Boolean indicating wallet active status.
   */
  event TeamWalletActive(address indexed walletAddress, bool isActive);

  /**
   * @param walletAddress Address of the wallet.
   * @param isActive Boolean indicating wallet active status.
   */
  event TeamWalletAdd(address indexed walletAddress, bool isActive);

  /**
   * @notice Returns the team wallet details.
   * @param aFiContract Address of the AFi contract.
   * @param _wallet Wallet address
   * @return isPresent Boolean indicating the present status of the wallet.
   * @return isActive Boolean indicating whether to set the wallet to either active/inactive.
   */
  function getTeamWalletDetails(
    address aFiContract,
    address _wallet
  ) external view returns (bool isPresent, bool isActive);



   function handleRedemption(RedemptionParams memory params, uint _shares, uint swapMethod) external  returns (uint256 redemptionFromContract);

  /**
   * @notice To add a new team wallet.
   * @param aFiContract Address of the AFi contract.
   * @param _wallet Wallet address that has to be added in the `teamWallets` array.
   * @param isActive Boolean indicating whether to set the wallet to either active/inactive.
   * @param isPresent Boolean indicating the present status of the wallet.
   */
  function addTeamWallet(
    address aFiContract,
    address _wallet,
    bool isActive,
    bool isPresent
  ) external;

  /**
   * @notice Returns the team wallets for an AFi.
   * @param aFiContract Address of the AFi contract.
   * @return _teamWallets Array of teamWallets.
   */
  function getTeamWalletsOfAFi(
    address aFiContract
  ) external view returns (address[] memory _teamWallets);

  /**
   * @notice Sets the address for team wallets.
   * @param aFiContract Address of the AFi contract.
   * @param _teamWallets Array of addresses for the team wallets.
   */
  function setTeamWallets(address aFiContract, address[] memory _teamWallets) external;

  /**
   * @notice Sets the status for the AFi in the storage contract.
   * @param aFiContract Address of the AFi contract.
   * @param active status for afiContracts.
   */
  function setAFiActive(address aFiContract, bool active) external;

  /**
   * @notice Sets Active Rebalance status of an AFi.
   * @param aFiContract Address of the AFi contract.
   * @param status indicating active rebalance status of the AFi contract.
   */
  function setActiveRebalancedStatus(address aFiContract, bool status) external;

  /**
   * @notice gets Active Rebalance status of an AFi.
   * @param aFiContract Address of the AFi contract.
   * @return _isActiveRebalanced bool indicating active rebalance status of the AFi contract.
   */
  function isAFiActiveRebalanced(
    address aFiContract
  ) external view returns (bool _isActiveRebalanced);

  function getTotalActiveWallets(address aFiContract) external view returns (uint);

  function calcPoolValue(
    address tok,
    address afiContract
  ) external view returns (uint);

  function calculateBalanceOfUnderlying(
    address tok,
    address afiContract
  ) external view returns (uint);

  function calculatePoolInUsd(address afiContract) external view returns (uint);

  function afiSync(
    address afiContract,
    address tok,
    address aaveTok,
    address compV3Comet,
    address compTok
  ) external;

  function getPriceInUSDC(
    address tok
  ) external view returns (uint256, uint256);

  function validateAndGetDecimals(address tok) external view returns (uint256);

  function getStakedStatus(
    address aFiContract,
    address uToken
  ) external view returns (bool);

  function rearrange(address aFiContract,address[] memory underlyingTokens, uint256[] memory newProviders) external;

  function swapForOtherProduct(
    address afiContract,
    uint r,
    address oToken,
    uint deadline,
    uint[] memory minimumReturnAmount,
    address[] memory uToken
  ) external returns (uint256);

  function _withdrawAll(address afiContract, address tok) external returns(bool);
  function getAFiOracle() external view returns(address);

  function calculateRedemptionFromContract(
    address afiContract,
    address tok,
    uint256 r
  ) external view returns (uint256, bool, uint256, uint256, uint256);



  function tvlRead(
    address tok,
    address afiContract
  ) external view returns (uint, uint256);

  function getPreSwapDepositsTokens(
    address aFiContract,
    uint256 _cSwapCounter,
    address stableToken
  ) external view returns (uint256);

  function setPreDepositedInputToken(uint256 _cSwapCounter, uint256 _amount,address _oToken) external;
  function setPreDepositedInputTokenInRebalance(
    address aficontract,
    uint256 _cSwapCounter,
    uint256 _amount,
    address _oToken
  ) external;

  function convertInUSDAndTok(
    address tok,
    uint256 amt,
    bool usd
  ) external view returns (uint256);

  function calculateShares(
    address afiContract,
    uint256 amount,
    uint256 prevPool,
    uint256 _totalSupply,
    address iToken,
    uint256 currentDepositNAV
  ) external view returns (uint256 shares, uint256 newDepositNAV);

  function deletePreDepositedInputToken(
    address aFiContract,
    address oToken,
    uint256 currentCounter
  )external;

  function doSwapForThewhiteListRemoval(
    address tok,
    uint256 _cSwapCounter,
    address swapToken,
    uint256 deadline,
    uint256 minAmountOut
  ) external;
}


interface IPassiveRebal {
  function applyRebalForProportions(
    address _aFiContract,
    address _aFiManager,
    address _aFiStorage,
    address[] memory _tokens,
    uint256 strategy
  ) external returns (uint[] memory proportions, uint256 totalProp);

  function getPauseStatus() external returns (bool);

  function setPassiveRebalancedStatus(address aFiContract, bool status) external;

  function isAFiPassiveRebalanced(
    address aFiContract
  ) external returns (bool _isPassiveRebalanced);

  function getRebalStrategyNumber(address aFiContract) external returns (uint);

  function uniswapV3Oracle(
    address afiContract,
    address _tokenIn,
    address _tokenOut,
    uint _amountIn,
    uint _maxTime,
    address middleToken,
    uint256 minimumReturnAmount
  ) external returns (bytes memory swapParams);

  function updateuniPool(address tok, address midTok) external;

  function getPool(address tok, address midTok) external view returns (address);

  function upDateInputTokPool(address[] memory iToken, bytes memory uniData) external;

  function getPriceOracle(address tok) external view returns (address);

  function updateOracleData(
    address _uToken,
    address _oracleAddress
  ) external;

   function removeToken(
    address[] memory _nonOverlappingITokens,
    address token
  ) external pure returns (address[] memory);

}



/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
 
/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

    /**
    * @title SafeERC20
    * @dev Wrappers around ERC20 operations that throw on failure (when the token
    * contract returns false). Tokens that return no value (and instead revert or
    * throw on failure) are also supported, non-reverting calls are assumed to be
    * successful.
    * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
    * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
    */
    library SafeERC20 {
        using Address for address;

        function safeTransfer(
            IERC20 token,
            address to,
            uint256 value
        ) internal {
            _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
        }

        function safeTransferFrom(
            IERC20 token,
            address from,
            address to,
            uint256 value
        ) internal {
            _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
        }

        /**
        * @dev Deprecated. This function has issues similar to the ones found in
        * {IERC20-approve}, and its usage is discouraged.
        *
        * Whenever possible, use {safeIncreaseAllowance} and
        * {safeDecreaseAllowance} instead.
        */
        function safeApprove(
            IERC20 token,
            address spender,
            uint256 value
        ) internal {
            // safeApprove should only be called when setting an initial allowance,
            // or when resetting it to zero. To increase and decrease it, use
            // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
            require(
                (value == 0) || (token.allowance(address(this), spender) == 0),
                "SafeERC20: approve from non-zero to non-zero allowance"
            );
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
        }

        function safeIncreaseAllowance(
            IERC20 token,
            address spender,
            uint256 value
        ) internal {
            uint256 newAllowance = token.allowance(address(this), spender) + value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }

        function safeDecreaseAllowance(
            IERC20 token,
            address spender,
            uint256 value
        ) internal {
            unchecked {
                uint256 oldAllowance = token.allowance(address(this), spender);
                require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
                uint256 newAllowance = oldAllowance - value;
                _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
            }
        }

        function safePermit(
            IERC20Permit token,
            address owner,
            address spender,
            uint256 value,
            uint256 deadline,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) internal {
            uint256 nonceBefore = token.nonces(owner);
            token.permit(owner, spender, value, deadline, v, r, s);
            uint256 nonceAfter = token.nonces(owner);
            require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
        }

        /**
        * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
        * on the return value: the return value is optional (but if data is returned, it must not be false).
        * @param token The token targeted by the call.
        * @param data The call data (encoded using abi.encode or one of its variants).
        */
        function _callOptionalReturn(IERC20 token, bytes memory data) private {
            // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
            // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
            // the target address contains contract code and also asserts for success in the low-level call.

            bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
            if (returndata.length > 0) {
                // Return data is optional
                require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
            }
        }
    }


/**
 * @title PassiveRebal.
 * @notice Interface of the Passive Rebalance contract.
 */
interface PassiveRebal {
  function applyRebalForProportions(
    address _aFiContract,
    address _aFiManager,
    address _aFiStorage,
    address[] memory _tokens,
    uint256 strategy
  ) external returns (uint[] memory proportions, uint256);

  function getPauseStatus() external returns (bool);

  function setPassiveRebalancedStatus(address aFiContract, bool status) external;

  function isAFiPassiveRebalanced(
    address aFiContract
  ) external returns (bool _isPassiveRebalanced);

  function getRebalStrategyNumber(address aFiContract) external returns (uint);
}

interface IAFiOracle {
  function uniswapV3Oracle(
    address afiContract,
    address _tokenIn,
    address _tokenOut,
    uint _amountIn,
    uint _maxTime,
    address middleToken,
    uint256 minimumReturnAmount
  ) external returns (bytes memory swapParams);
}

interface IAFiManager {
  function updateUTokenProportion(
    address aFiContract,
    address aFiStorage
  ) external returns (uint256[] memory);

  function inputTokenUSD(
    IAFi aFiContract,
    uint256 cSwapCounter,
    IAFiStorage _aFiStorage
  ) external view returns (uint256 totalPreDepositInUSD);

  function intializeData(
    address aFiContract,
    address[] memory underlyingTokens,
    uint[] memory underlyingProportion
  ) external;

  function uTokenslippage(
    address aFiContract,
    address uToken
  ) external view returns (uint uTokenSlippage);
}

/**
 * @title IAFi.
 * @notice Interface of the AToken.
 */
interface IAFi {

  struct UnderlyingData {
    address[] _underlyingTokens; //uTokens
    address[] _underlyingUniPoolToken; //uToken - MiddleToken
  }

  struct PoolsData {
    address[] _depositStableCoin;
    address[] _depositCoinOracle;
    bytes underlyingData;
    address[] _compound;
    address[] _aaveToken;
    address[] _priceOracles;
    uint[] _underlyingTokensProportion;
    address[] compoundV3Comet;
    uint _typeOfProduct;
  }


  /**
   * @param account Address of the account that paused the contract.
   * @param isDeposit True if we want to pause deposit otherwise false if want to pause withdraw.
   */
  event Paused(address account, bool isDeposit);
  /**
   * @param account Address of the account that unpaused the contract.
   * @param isDeposit True if we want to unpause deposit otherwise false if want to unpause withdraw.
   */
  event Unpaused(address account, bool isDeposit);

  /**
   * @notice Function to initialize the data, owner and afi token related data.
   * @dev the function should be called once only by factory
   * @param newOwner indicates the owner of the created afi product.
   * @param _name indicates the name of the afi Token
   * @param _symbol indicates symbol of the the afi Token.
   * @param data indicates the encoded data that follows the PoolsData struct format.
   * @param _isActiveRebalanced indicates the active rebalance status of the afi contract.
   * @param _aFiStorage indicates the afi storage contract address.
   */
  function initialize(
    address newOwner,
    string memory _name,
    string memory _symbol,
    bytes memory data,
    bool _isActiveRebalanced,
    IAFiStorage _aFiStorage,
    address[] memory _commonInputTokens
  ) external;

  /**
   * @notice Function to initialize accepted tokens in deposit and withdraw functions.
   * @dev  the function should be called once only by factory
   * @param iToken indicates the array of the accepted token addressess.
   */
  function initializeToken(
    address[] memory iToken,
    address[] memory _teamWallets,
    IPassiveRebal _rebalContract,
    bool _isPassiveRebalanced,
    address _aFiManager
  ) external;

  function getcSwapCounter() external view returns(uint256);

  /**
   * @notice Returns the array of underlying tokens.
   * @return uTokensArray Array of underlying tokens.
   */
  function getUTokens() external view returns (address[] memory uTokensArray);

  function swapViaStorageOrManager(
    address from,
    address to,
    uint amount,
    uint deadline,
    address midTok,
    uint minimumReturnAmount
  ) external returns (uint256);

  /**
   * @notice Returns the paused status of the contract.
   */
  function isPaused() external view returns (bool, bool);

  function getProportions()
    external
    view
    returns (uint[] memory, uint[] memory);

  /**
   * @notice Updates the pool data during Active Rebalance.
   * @param data that follows PoolsData format indicates the data of the token being rebalanced in Active Rebalance.
   */
  function updatePoolData(bytes memory data) external;

  function sendProfitOrFeeToManager(
    address wallet,
    uint profitShare,
    address oToken
  ) external;

  function totalSupply() external view returns (uint);

  function _supplyCompV3(address tok, uint amount) external;

  function _supplyAave(address tok, uint amount) external;

  function _supplyCompound(address tok, uint amount) external;

  function _withdrawAave(address tok, uint amount) external;

  function _withdrawCompoundV3(address tok, uint amount) external;

  function _withdrawCompound(address tok, uint amount) external;

  function getTVLandRebalContractandType()
    external
    view
  returns (uint256, address, uint256);

  function getInputToken() external view returns (address[] memory, address[] memory);

  function swap(
    address inputToken,
    address uTok,
    uint256 amountAsPerProportion,
    uint _deadline,
    address middleToken,
    uint256 minimumReturnAmount
  ) external returns (uint256);

  function updateDp(
    uint256[] memory _defaultProportion,
    uint256[] memory _uTokensProportion,
    uint256 activeStrategy
  ) external;

  function updateuTokAndProp(
    address[] memory _uTokens
  ) external;

  function underlyingTokensStaking(address[] memory _depositTokens) external returns(uint256 _totalProp);

  function depositUserNav(address user) external view returns (uint256);

  function setUnstakeData(uint256 totalQueuedShares) external returns (address[] memory, address[] memory, uint256, uint256);

  function isOTokenWhitelisted(address oToken) external view returns (bool);

  function validateWithdraw(address user, address oToken, uint256 _shares) external view returns( uint ibalance);

  function updateLockedTokens(address user, uint256 amount, bool lock, bool updateBalance) external;

  function getVaultDetails() external view returns(string memory, string memory);

  function checkTVL(bool _updateTVL) external;

  function updateInputTokens(address[] memory _inputTokens) external;
}

interface IUniswapOracleV3 {
  function PERIOD() external returns (uint256);
  function factory() external returns (address);
  function getTotalProfit() external view returns (uint256);
  function getDaoProfit() external view returns (uint256);
  function update(address _tokenIn, address _tokenOut) external;

  function quotePrice(IAFi aFiContract,address _tokenIn, address _depositToken, uint256 _amount) external view returns (uint256 price);


  function consult(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut
  ) external view returns (uint256 _amountOut);

  function estimateAmountOut(
    address tokenIn,
    uint128 amountIn,
    address tokenOut
  ) external view returns (uint amountOut);

  function estimateAmountOutMin(
    address tokenIn,
    uint128 amountIn,
    address tokenOut,
    address pool
  ) external view returns (uint amountOut);

  function updateAndConsult(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut
  ) external returns (uint256 _amountOut);

  function checkUnderlyingPool(address token) external view returns (bool hasPool);
  function getStalePriceDelay(address aFiContract, address uToken) external view returns(uint256);
  function getPriceAndDecimals(address aFiContract, address uToken, address feed) external view returns(int256 , uint8 );
  function getPriceInUSDC(address tok) external view returns (uint256, uint256);
  function getMidToken(address tok) external view returns (address);
  function updateMidToken(address[] memory tok, address[] memory midTok) external;
  function setRedeemData(address _oToken, uint256 _batchWithdrawCounter, uint256 _totalShares, uint256 _oTokenUnits) external;
  function getControllers(address afiContract) external view returns(address, address);
}


/**
 * @title AFiManager.
 * @notice Manager conntract for handling rebalancing and adding/updating team wallets in the AFi contracts.
 * @dev Error codes: AFM01: Caller is not MultiSig. AFM02: Cannot be address zero. AFM03: Teamwallet already present. AFM04: Previous and current active status cannot be the same.
 */
contract AFiManager is OwnableDelayModule, ReentrancyGuard {
  using ArrayUtils for uint[];
  using ArrayUtils for address[];
  using SafeERC20 for IERC20;

  address internal rebal;
  uint256 internal preDepositsStablesInUSD;

  uint256 public rebalfee = 500;
  uint256 public rebalFeeUpperLimit = 5000;

  bool internal paused;
  address[] private _uTokensAfterRebalance;
  address[] public tokens;
  uint[] internal defaultProportion;
  address internal afiOracle;
  address internal constant UNISWAP_EXCHANGE =
    0xE592427A0AEce92De3Edee1F18E0157C05861564;
  mapping(address => mapping(address => bool)) internal underlyingExists;
  mapping(address => bool) internal isUnderlyingCommon;
  address public rebalanceController;

  struct RebalanceData {
    IAFi aFiContract;
    IAFiStorage _aFiStorage;
    IERC20 depositToken;
    address newUToken;
    address uTokenToRemove;
    uint256 scenario;
    address[] uTokensAfterS1; // uTokens array after scenario 1 rebalancing
    uint256[] uTokenProportions;
    uint256[] defaultProportion;
    uint256 uTokenToRemoveIndex;
  }

  event Rebalance(IAFi indexed _aFiContract, uint8 _scenario);
  event AddTeamWalletInAFi(address indexed aFiContract, address _wallet);
  event WithdrawFromPool(address indexed _aFiContract, address uToken);
  event AFiManagerSwap(
    IAFi indexed _aFiContract,
    address _fromToken,
    address _toToken,
    uint _amount
  );
  event SetActiveRebalStatus(address indexed _aFiContract, bool status);
  event RebalanceUnderlyingTokens(
    address indexed aFiContract,
    address _aFiStorage,
    address[] newUnderlyingTokens,
    address stableCoin,
    uint managerFee
  );
  event UTokenProportionUpdated(
    address indexed aFiContract,
    uint256[] uTokenProportions
  );

  /**
   * @param account Address of the account that paused the contract.
   */
  event Paused(address account);
  /**
   * @param account Address of the account that unpaused the contract.
   */
  event Unpaused(address account);

  modifier contractUnpaused() {
    require(!paused, "AM08");
    _;
  }

  modifier contractPaused() {
    require(paused, "AM09");
    _;
  }

  /**
   * @notice To pause the contract.
   * @dev Requirements: It can only be invoked by owner.
   */
  function pause() external contractUnpaused onlyOwner {
    paused = true;
    emit Paused(msg.sender);
  }

  /**
   * @notice To resume/unpause the contract.
   * @dev Requirements: It can only be invoked by the owner.
   */
  function unPause() external contractPaused onlyOwner {
    paused = false;
    emit Unpaused(msg.sender);
  }

  function validateGreaterEqual(uint256 val1, uint256 val2) internal pure {
    require(val1 >= val2, "AFS19");
  }

  function addressCheck(address add1, address add2) internal pure {
    require(add1 != add2, "AM04"); //solhint-disable-line reason-string
  }

  /**
   * @notice Returns the pause status of the contract.
   * @return bool pause status of the contract.
   */
  function getPauseStatus() external view returns (bool) {
    return paused;
  }

  function isPresentCheck(bool isPresent) internal pure {
    if (isPresent) revert("AFM03");
  }

  function setRebalanceController(address _rebalanceController) external onlyOwner {
    addressCheck(_rebalanceController, address(0));

    rebalanceController = _rebalanceController;
  }

  /**
   * @notice To add a new team wallet.
   * @dev The wallet must not be address zero. The wallet must not be present.
   * @param _aFiStorage Address of AFiStorage contract.
   * @param aFiContract Address of the AFi contract.
   * @param _wallet Wallet address that has to be added in the `teamWallets` array.
   */
  function addTeamWalletInAFi(
    IAFiStorage _aFiStorage,
    address aFiContract,
    address _wallet
  ) external nonReentrant onlyOwner contractUnpaused {
    require(_wallet != address(0), "AFM02");
    (, bool isPresent) = _aFiStorage.getTeamWalletDetails(aFiContract, _wallet);
    isPresentCheck(isPresent);
    _aFiStorage.addTeamWallet(aFiContract, _wallet, true, true);
    emit AddTeamWalletInAFi(aFiContract, _wallet);
  }

  /**
   * @notice To rebalance the underlying tokens.
   */
  function rebalance(
    bytes memory data,
    RebalanceData memory rebalData,
    uint deadline,
    uint[] memory minimumReturnAmount,
    uint stableAmountOut, // length of array should be >1 in second scenario
    uint256 _rebalFeeToDeduct
  ) external nonReentrant contractUnpaused {
    require(msg.sender == rebalanceController, "AM01");
    require(rebalData.scenario < 3 && rebalData.scenario > 0, "AM05");
    require(rebalData.uTokenToRemove != address(rebalData.depositToken), "AM010");
    require(
      rebalData._aFiStorage.isAFiActiveRebalanced(address(rebalData.aFiContract)),
      "AM00"
    );
    (, rebal, ) = IAFi(rebalData.aFiContract).getTVLandRebalContractandType();
    address[] memory uTokens = IAFi(rebalData.aFiContract).getUTokens();

    // Validate uTokenToRemove and uTokenToRemoveIndex
    require(uTokens[rebalData.uTokenToRemoveIndex] == rebalData.uTokenToRemove, "AM12");

    if (rebalData.scenario == 2) {
      (, bool present) = ArrayUtils.indexOf(uTokens, rebalData.newUToken);
      isPresentCheck(present);
      validateNewUTokenData(data, rebalData.newUToken);
    }

    uint totalReturnedDepositToken;
    {
      totalReturnedDepositToken = rebalData.depositToken.balanceOf(
        address(rebalData.aFiContract)
      );
      rebalData._aFiStorage._withdrawAll(
        address(rebalData.aFiContract),
        rebalData.uTokenToRemove
      );

      convertToStable(
        rebalData.aFiContract, 
        rebalData.uTokenToRemove, 
        address(rebalData.depositToken), 
        deadline, 
        stableAmountOut
      );

      checkRebalFeesandDeduct(
        _rebalFeeToDeduct,
        address(rebalData.depositToken),
        rebalData.aFiContract
      );

      totalReturnedDepositToken =
        rebalData.depositToken.balanceOf(address(rebalData.aFiContract)) -
        totalReturnedDepositToken;
    }
    (address[] memory inputStables, address[] memory nonOverlappingITokens) = IAFi(
      rebalData.aFiContract
    ).getInputToken();

    updateInputTokenData(
      address(rebalData.aFiContract),
      address(rebalData._aFiStorage),
      rebalData.uTokenToRemove,
      inputStables,
      nonOverlappingITokens
    );

    (, rebalData.defaultProportion) = rebalData.aFiContract.getProportions();

    bool isNewTokenPresent;
    {
      if (rebalData.scenario == 1) {
        if (
          IPassiveRebal(rebal).getRebalStrategyNumber(address(rebalData.aFiContract)) ==
          1
        ) {
          (rebalData.uTokenProportions, ) = updateProportion(
            address(rebalData.aFiContract),
            rebalData._aFiStorage,
            uTokens
          );
        } else {
          rebalData.uTokenProportions = rebalData.defaultProportion;
        }
        // investInOtherUTokens
        rebalData.uTokensAfterS1 = scenario1Investments(
          rebalData,
          uTokens,
          totalReturnedDepositToken,
          deadline,
          minimumReturnAmount
        );

        rebalData.aFiContract.updateuTokAndProp(rebalData.uTokensAfterS1);
      } else {
        (inputStables, nonOverlappingITokens) = IAFi(rebalData.aFiContract)
          .getInputToken();

        rebalData.aFiContract.updatePoolData(data);
        (, isNewTokenPresent) = ArrayUtils.indexOf(
          nonOverlappingITokens,
          rebalData.newUToken
        );

        if (isNewTokenPresent) {
          nonOverlappingITokens = removeFromNonOverlappingITokens(
            nonOverlappingITokens,
            rebalData.newUToken
          );
        }
        // Update nonOverlappingITokens in AFiBase
        IAFi(rebalData.aFiContract).updateInputTokens(nonOverlappingITokens);

        uTokens = scenario2Investments(
          rebalData.depositToken,
          rebalData.uTokenToRemoveIndex,
          rebalData.aFiContract,
          uTokens,
          rebalData.newUToken,
          totalReturnedDepositToken,
          deadline,
          minimumReturnAmount
        );

        (rebalData.uTokenProportions, ) = updateProportion(
          address(rebalData.aFiContract),
          rebalData._aFiStorage,
          uTokens
        );

        rebalData.aFiContract.updateDp(
          rebalData.uTokenProportions,
          rebalData.uTokenProportions,
          2
        );
        rebalData.aFiContract.updateuTokAndProp(uTokens);
      }
    }
  }

  function updateInputTokenData(
    address aFiContract,
    address _aFiStorage,
    address uTokenToRemove,
    address[] memory inputStables,
    address[] memory nonOverlappingITokens
  ) internal {
    // Check if uTokenToRemove exists in inputStables
    (, bool isInputStable) = ArrayUtils.indexOf(inputStables, uTokenToRemove);

    if (isInputStable) {
      // Clear preDepositedInputTokens and add uTokenToRemove to nonOverlappingITokens
      IAFiStorage(_aFiStorage).deletePreDepositedInputToken(
        aFiContract,
        uTokenToRemove,
        IAFi(aFiContract).getcSwapCounter()
      );
      // Add uTokenToRemove to nonOverlappingITokens if not already present
      nonOverlappingITokens = addToNonOverlappingITokens(
        nonOverlappingITokens,
        uTokenToRemove
      );
      // Update nonOverlappingITokens in AFiBase
      IAFi(aFiContract).updateInputTokens(nonOverlappingITokens);
    }
  }

  function addToNonOverlappingITokens(
    address[] memory _nonOverlappingITokens,
    address token
  ) internal pure returns (address[] memory) {
    (, bool isPresent) = ArrayUtils.indexOf(_nonOverlappingITokens, token);
    if (!isPresent) {
      address[] memory newTokens = new address[](_nonOverlappingITokens.length + 1);
      for (uint i = 0; i < _nonOverlappingITokens.length; i++) {
        newTokens[i] = _nonOverlappingITokens[i];
      }
      newTokens[_nonOverlappingITokens.length] = token;
      return newTokens;
    }
    return _nonOverlappingITokens;
  }

  function removeFromNonOverlappingITokens(
    address[] memory _nonOverlappingITokens,
    address token
  ) internal pure returns (address[] memory) {
    (, bool isPresent) = ArrayUtils.indexOf(_nonOverlappingITokens, token);
    if (isPresent) {
      return ArrayUtils.remove(_nonOverlappingITokens, token);
    }
    return _nonOverlappingITokens;
  }

  function updateUniPoolInRebal(
    address midTok,
    IERC20 depositToken,
    address tokToUpadte
  ) internal {
    if (midTok == address(depositToken)) {
      //update unipool
      IPassiveRebal(rebal).updateuniPool(tokToUpadte, midTok);
    }
  }

  /**
   * @notice To invest tokens as per scenario 1.
   * @dev 1 => Remove all DepositToken from U1 & Invest into U2, U3.
   */
  function scenario1Investments(
    RebalanceData memory rebalData,
    address[] memory uTokens,
    uint totalReturnedDepositToken,
    uint deadline,
    uint[] memory minimumReturnAmount
  ) internal returns (address[] memory rbtoUTokens) {
    uint256 _denominator;
    uint256 swapAmount;
    // Calculate the denominator as per the updated proportions
    for (uint i = 0; i < uTokens.length; i++) {
      if (i != rebalData.uTokenToRemoveIndex) {
        _denominator += rebalData.defaultProportion[i];
        //we have scenario from struct while declaring another varibale gettin stack to deep
        rebalData.scenario += rebalData.uTokenProportions[i];
      }
    }

    // Invest the totalReturnedDepositToken as per the proportions
    address midTok;
    uint256[] memory defaultTokens = new uint256[](uTokens.length - 1);
    rbtoUTokens = new address[](uTokens.length - 1);

    for (uint j = 0; j < uTokens.length; j++) {
      if (j != rebalData.uTokenToRemoveIndex) {
        uint256 proportion = (rebalData.defaultProportion[j] * 10000000) / _denominator;

        if (j > rebalData.uTokenToRemoveIndex) {
          defaultTokens[j - 1] = proportion;
          rbtoUTokens[j - 1] = uTokens[j];
        } else {
          rbtoUTokens[j] = uTokens[j];
          defaultTokens[j] = proportion;
        }

        midTok = IUniswapOracleV3(afiOracle).getMidToken(uTokens[j]);
        updateUniPoolInRebal(midTok, rebalData.depositToken, uTokens[j]);

        swapAmount =
          (rebalData.uTokenProportions[j] * totalReturnedDepositToken) /
          rebalData.scenario;

        aFiManagerSwap(
          address(rebalData.depositToken),
          uTokens[j],
          swapAmount,
          rebalData.aFiContract,
          deadline,
          midTok,
          minimumReturnAmount[j]
        );
      }
    }
    (rebalData.uTokenProportions, ) = updateProportion(
      address(rebalData.aFiContract),
      rebalData._aFiStorage,
      rbtoUTokens
    );

    rebalData.aFiContract.updateDp(defaultTokens, rebalData.uTokenProportions, 1);
    emit Rebalance(rebalData.aFiContract, 1);

    return rbtoUTokens;
  }

  /**
   * @notice To invest tokens as per scenario 2.
   * @dev 2 => Remove all DepositToken from U1, invest all in U4.
   * @param uTokenToRemoveIndex Index of the underlying token that has to be set to inactive.
   * @param aFiContract Address of AFi contract (AToken).
   * @param uTokens An array of underlying tokens.
   * @param newUToken Address of the new underlying token.
   */
  function scenario2Investments(
    IERC20 depositToken,
    uint uTokenToRemoveIndex,
    IAFi aFiContract,
    address[] memory uTokens,
    address newUToken,
    uint totalReturnedDepositToken,
    uint deadline,
    uint[] memory minimumReturnAmount
  ) internal returns (address[] memory rbtoUTokens) {
    {
      rbtoUTokens = new address[](uTokens.length);

      for (uint j = 0; j < uTokens.length; j++) {
        if (j != uTokenToRemoveIndex) {
          if (j < uTokenToRemoveIndex) {
            rbtoUTokens[j] = uTokens[j];
          } else {
            rbtoUTokens[j - 1] = uTokens[j];
          }
        }
      }

      rbtoUTokens[rbtoUTokens.length - 1] = newUToken;
      _uTokensAfterRebalance = rbtoUTokens;
      address midTok = IUniswapOracleV3(afiOracle).getMidToken(newUToken);
      updateUniPoolInRebal(midTok, depositToken, newUToken);

      aFiManagerSwap(
        address(depositToken),
        newUToken,
        totalReturnedDepositToken,
        aFiContract,
        deadline,
        midTok,
        minimumReturnAmount[0]
      );
    }

    emit Rebalance(aFiContract, 2);
  }

  /**
   * @notice Gateway for initiating a Swap from the AFiManager contract.
   * @dev The contract must not be paused. It can only be invoked by the AFiManager contract.
   * @param from The source token which is swapped for the destination token.
   * @param to The destination token to which the from token is swapped into.
   * @param amount Amount of from token for swapping.
   */
  function aFiManagerSwap(
    address from,
    address to,
    uint amount,
    IAFi aFiContract,
    uint256 deadline,
    address midTok,
    uint minimumReturnAmount
  ) internal {
    {
      // Initiate Swap via UniswapV3
      aFiContract.swapViaStorageOrManager(
        from,
        to,
        amount,
        deadline,
        midTok,
        minimumReturnAmount
      );
    }

    emit AFiManagerSwap(aFiContract, from, to, amount);
  }

  function validateNewUTokenData(bytes memory _data, address newUToken) internal pure {
    IAFi.PoolsData memory pooldata = abi.decode(_data, (IAFi.PoolsData));
    IAFi.UnderlyingData memory uniData = abi.decode(
      pooldata.underlyingData,
      (IAFi.UnderlyingData)
    );
    require(
      pooldata._underlyingTokensProportion.length == pooldata._compound.length &&
        pooldata._compound.length == pooldata.compoundV3Comet.length &&
        pooldata.compoundV3Comet.length == pooldata._aaveToken.length,
      "AFM05"
    );
    require(uniData._underlyingTokens.length == 1, "AFM06");
    require(pooldata._underlyingTokensProportion[0] == 0, "AFM07");
    require(uniData._underlyingTokens[0] == newUToken, "AFM08");
  }

  /**
   * @notice  To toggle Active Rebalace status of afiContract to either active/inactive.
   * @dev The contract must not be paused.It can invoke by owner
   * @param aFiContract Address of AFi contract (AToken).
   * @param _aFiStorage Address of the AFi Storage Contract.
   * @param status, bool value for rebalance status of afiContract.
   */
  function setActiveRebalStatus(
    IAFiStorage _aFiStorage,
    address aFiContract,
    bool status
  ) external nonReentrant onlyOwner contractUnpaused {
    _aFiStorage.setActiveRebalancedStatus(aFiContract, status);
    emit SetActiveRebalStatus(aFiContract, status);
  }

  struct AlgoRebalanceData {
    IAFi aFiContract;
    IAFiStorage _aFiStorage;
    bytes underlyingData;
    address[] newUnderlyingOracle;
    address[] prevUnderlying;
    address stableCoin;
    uint managerFee;
    uint deadline;
    uint[] minimumReturnAmount;
    uint[] minimumUnderlyingAmount;
  }

  /**
   * @notice To rebalance the underlying tokens in an algo product.
   * @dev Remove all DepositToken from multiple underlying tokens & Invest into new underlying tokens.
   */
  // Algo Rebalance 1
  function rebalanceUnderlyingTokens(
    AlgoRebalanceData memory rebalanceData
  ) external contractUnpaused {
    require(msg.sender == rebalanceController, "AM02");
    require(rebalanceData.newUnderlyingOracle.length <= 10, "AM07");
    rebalanceData.prevUnderlying = rebalanceData.aFiContract.getUTokens();
    checkProductType(rebalanceData.aFiContract);

    IAFi.UnderlyingData memory underlyingUniData = abi.decode(
      rebalanceData.underlyingData,
      (IAFi.UnderlyingData)
    );
    uint stableCoinBalance = IERC20(rebalanceData.stableCoin).balanceOf(
      address(rebalanceData.aFiContract)
    );
    uint sameUnderlyingCount = rebalanceAlgo(
      rebalanceData.aFiContract,
      rebalanceData._aFiStorage,
      rebalanceData.underlyingData,
      rebalanceData.newUnderlyingOracle,
      rebalanceData.prevUnderlying
    );
    swapUnderlying(
      rebalanceData,
      underlyingUniData._underlyingTokens,
      sameUnderlyingCount,
      stableCoinBalance,
      (rebalanceData.prevUnderlying.length ==
        underlyingUniData._underlyingTokens.length)
    );

    uint256[] memory newProp = new uint256[](
      underlyingUniData._underlyingTokens.length
    );
    (newProp, ) = updateProportion(
      address(rebalanceData.aFiContract),
      rebalanceData._aFiStorage,
      underlyingUniData._underlyingTokens
    );

    rebalanceData.aFiContract.updateDp(newProp, newProp, 1);
    rebalanceData.aFiContract.updateuTokAndProp(underlyingUniData._underlyingTokens);

    emit RebalanceUnderlyingTokens(
      address(rebalanceData.aFiContract),
      address(rebalanceData._aFiStorage),
      underlyingUniData._underlyingTokens,
      rebalanceData.stableCoin,
      rebalanceData.managerFee
    );
  }

  function setafiOracleContract(address _afiOracle) external onlyOwner {
    addressCheck(_afiOracle, address(0));
    afiOracle = _afiOracle;
  }

  /**
   * @notice Sets the rebalance Manager fee upper.
   * @dev Only the contract owner can call this function.
   * @param _rebalFeeUpperLimit New algo fee maximum limit.
   */
  function setRebalFeeUpperLimit(uint256 _rebalFeeUpperLimit) external onlyOwner {
    rebalFeeUpperLimit = _rebalFeeUpperLimit;
  }

  /**
   * @notice Sets the rebalance fee.
   * @dev Only the contract owner can call this function.
   * @param _rebalfee New rebalance fee.
   */
  function setRebalFee(uint256 _rebalfee) external onlyOwner {
    require(_rebalfee <= rebalFeeUpperLimit, "AFMO111");
    rebalfee = _rebalfee;
  }

  function rebalanceAlgo(
    IAFi aFiContract,
    IAFiStorage aFiStorage,
    bytes memory uniData,
    address[] memory newUnderlyingOracle,
    address[] memory prevUnderlying
  ) internal returns (uint256) {
    bool exist;
    uint sameUnderlyingCount;

    (, rebal, ) = aFiContract.getTVLandRebalContractandType();

    IAFi.UnderlyingData memory underlyingUniData = abi.decode(
      uniData,
      (IAFi.UnderlyingData)
    );

    for (uint i = 0; i < prevUnderlying.length; i++) {
      underlyingExists[address(aFiContract)][prevUnderlying[i]] = true;
    }

    for (uint i = 0; i < underlyingUniData._underlyingTokens.length; i++) {
      if (prevUnderlying.length == underlyingUniData._underlyingTokens.length) {
        exist = checkIfUTokenExist(
          address(aFiContract),
          underlyingUniData._underlyingTokens[i]
        );
        if (exist) {
          isUnderlyingCommon[underlyingUniData._underlyingTokens[i]] = true;
          delete exist;
          sameUnderlyingCount++;
        }
      }
      IPassiveRebal(rebal).updateOracleData(
        underlyingUniData._underlyingTokens[i],
        newUnderlyingOracle[i]
      );
    }
    IUniswapOracleV3(afiOracle).updateMidToken(
      underlyingUniData._underlyingTokens,
      underlyingUniData._underlyingUniPoolToken
    );
    return sameUnderlyingCount;
  }

  function swapUnderlying(
    AlgoRebalanceData memory rebalanceData,
    address[] memory uTokensToAdd,
    uint _sameUnderlying,
    uint oldBalance,
    bool isLengthEqual
  ) internal {
    address midTok;
    uint rebalanceAmount;
    uint stableCoinBalance;
    if (isLengthEqual) {
      for (uint i = 0; i < rebalanceData.prevUnderlying.length; i++) {
        if (!isUnderlyingCommon[rebalanceData.prevUnderlying[i]]) {
          rebalanceAmount = IERC20(rebalanceData.prevUnderlying[i]).balanceOf(
            address(rebalanceData.aFiContract)
          );
          midTok = IUniswapOracleV3(afiOracle).getMidToken(
            rebalanceData.prevUnderlying[i]
          );
          updateUniPoolInRebal(
            midTok,
            IERC20(rebalanceData.stableCoin),
            rebalanceData.prevUnderlying[i]
          );

          // Get Deposit token back from the UToken that is going to be rebalanced
          aFiManagerSwap(
            rebalanceData.prevUnderlying[i],
            rebalanceData.stableCoin,
            rebalanceAmount,
            rebalanceData.aFiContract,
            rebalanceData.deadline,
            midTok,
            rebalanceData.minimumReturnAmount[i]
          );
        }
      }
      checkRebalFeesandDeduct(
        rebalanceData.managerFee,
        rebalanceData.stableCoin,
        rebalanceData.aFiContract
      );

      stableCoinBalance = ((
        IERC20(rebalanceData.stableCoin).balanceOf(address(rebalanceData.aFiContract))
      ) - (oldBalance));
      rebalanceAmount = (stableCoinBalance) / (uTokensToAdd.length - _sameUnderlying);

      for (uint i = 0; i < uTokensToAdd.length; i++) {
        if (!isUnderlyingCommon[uTokensToAdd[i]]) {
          midTok = IUniswapOracleV3(afiOracle).getMidToken(uTokensToAdd[i]);
          updateUniPoolInRebal(
            midTok,
            IERC20(rebalanceData.stableCoin),
            uTokensToAdd[i]
          );

          // Swap stable token into into new underlying tokens in same proportions
          aFiManagerSwap(
            rebalanceData.stableCoin,
            uTokensToAdd[i],
            rebalanceAmount,
            rebalanceData.aFiContract,
            rebalanceData.deadline,
            midTok,
            rebalanceData.minimumUnderlyingAmount[i]
          );
        } else {
          delete isUnderlyingCommon[uTokensToAdd[i]];
        }
      }
    } else {
      //  When prevUnderlying length is not equal.All existing underlying token will be swapped
      for (uint i = 0; i < rebalanceData.prevUnderlying.length; i++) {
        rebalanceAmount = IERC20(rebalanceData.prevUnderlying[i]).balanceOf(
          address(rebalanceData.aFiContract)
        );
        midTok = IUniswapOracleV3(afiOracle).getMidToken(
          rebalanceData.prevUnderlying[i]
        );
        updateUniPoolInRebal(
          midTok,
          IERC20(rebalanceData.stableCoin),
          rebalanceData.prevUnderlying[i]
        );

        // Get Deposit token back from the UToken that is going to be rebalanced
        aFiManagerSwap(
          rebalanceData.prevUnderlying[i],
          rebalanceData.stableCoin,
          rebalanceAmount,
          rebalanceData.aFiContract,
          rebalanceData.deadline,
          midTok,
          rebalanceData.minimumReturnAmount[i]
        );
      }

      checkRebalFeesandDeduct(
        rebalanceData.managerFee,
        rebalanceData.stableCoin,
        rebalanceData.aFiContract
      );

      stableCoinBalance = ((
        IERC20(rebalanceData.stableCoin).balanceOf(address(rebalanceData.aFiContract))
      ) - (oldBalance));

      rebalanceAmount = (stableCoinBalance) / (uTokensToAdd.length);

      //stable coin swap into new underlying tokens
      for (uint i = 0; i < uTokensToAdd.length; i++) {
        midTok = IUniswapOracleV3(afiOracle).getMidToken(uTokensToAdd[i]);
        updateUniPoolInRebal(midTok, IERC20(rebalanceData.stableCoin), uTokensToAdd[i]);

        // Swap stable into into new underlying tokens
        aFiManagerSwap(
          rebalanceData.stableCoin,
          uTokensToAdd[i],
          rebalanceAmount,
          rebalanceData.aFiContract,
          rebalanceData.deadline,
          midTok,
          rebalanceData.minimumUnderlyingAmount[i]
        );
      }
    }

    for (uint256 i = 0; i < rebalanceData.prevUnderlying.length; i++) {
      delete underlyingExists[address(rebalanceData.aFiContract)][
        rebalanceData.prevUnderlying[i]
      ];
    }
  }

  function checkRebalFeesandDeduct(
    uint256 fee,
    address stableCoin,
    IAFi aficontract
  ) internal {
    require(fee / (10 ** IERC20(stableCoin).decimals()) <= rebalfee, "AB35");
    aficontract.sendProfitOrFeeToManager(msg.sender, fee, stableCoin);
  }

  // emergency withdraw from pools
  function withdrawFromPool(
    IAFiStorage _afiStorage,
    IAFi aFiContract,
    address underlyinToken
  ) external nonReentrant onlyOwner contractUnpaused {
    _afiStorage._withdrawAll(address(aFiContract), underlyinToken);
    emit WithdrawFromPool(address(aFiContract), underlyinToken);
  }

  /**
   * @notice gets the new proportions of the underlying tokens in an afiContract.
   * @param aFiContract indicates address of afiContract
   * @param _aFiStorage indicates address of afiStorage.
   * @param uTok array of new uTokens for logging.
   */
  function updateProportion(
    address aFiContract,
    IAFiStorage _aFiStorage,
    address[] memory uTok
  ) internal view returns (uint256[] memory prop, uint256 totalProp) {
    uint256 totalBalance;
    for (uint i = 0; i < uTok.length; i++) {
      totalBalance += (_aFiStorage.calcPoolValue(uTok[i], aFiContract) -
        getPredepBalInUSDC(uTok[i], aFiContract, _aFiStorage));
    }
    prop = new uint256[](uTok.length);

    //Update Proportions
    unchecked {
      for (uint j = 0; j < uTok.length; j++) {
        prop[j] =
          ((_aFiStorage.calcPoolValue(uTok[j], aFiContract) -
            getPredepBalInUSDC(uTok[j], aFiContract, _aFiStorage)) * (10000000)) /
          (totalBalance);
        totalProp = totalProp + prop[j];
      }
    }
    return (prop, totalProp);
  }

  function getPredepBalInUSDC(
    address tok,
    address aFiContract,
    IAFiStorage _aFiStorage
  ) internal view returns (uint256 tokPredepInUSD) {
    uint256 temp;
    uint256 multiplier;

    (temp, multiplier) = _aFiStorage.getPriceInUSDC(tok);
    uint256 depTok = _aFiStorage.getPreSwapDepositsTokens(
      aFiContract,
      IAFi(aFiContract).getcSwapCounter(),
      tok
    );

    tokPredepInUSD = (depTok) * (uint(temp));
    temp = _aFiStorage.validateAndGetDecimals(tok);
    tokPredepInUSD = ((tokPredepInUSD * (10 ** temp)) / (multiplier));
  }

  /**
   * @notice Checks the existence status of a token in an aFi contract.
   * @param uTok Address of the token to check.
   * @return bool Whether the token exists or not.
   */
  function checkIfUTokenExist(
    address afiContract,
    address uTok
  ) internal view returns (bool) {
    return underlyingExists[afiContract][uTok];
  }

  function updateStableUnitsInUSD(
    uint256 _preDepositsStablesInUSD
  ) external returns (uint256) {
    require(msg.sender == rebalanceController, "AM03");
    preDepositsStablesInUSD = _preDepositsStablesInUSD;
    return _preDepositsStablesInUSD;
  }

  /**
   * @notice Returns a new array of underlying token, token proportion and default proption that to be used by the AFiBase.
   * @param aFiContract address of the afiContract.
   * @param aFiContract address of the AFiStorage.
   * @return underlyingTokenProportions array of new proportion.
   */
  function getUTokenProportion(
    address aFiContract,
    address _aFiStorage
  )
    external
    view
    returns (uint256[] memory underlyingTokenProportions, uint256 totalProp)
  {
    (, address rebalAddress, ) = IAFi(aFiContract).getTVLandRebalContractandType();
    require(msg.sender == rebalAddress, "NA");

    (underlyingTokenProportions, totalProp) = updateProportion(
      aFiContract,
      IAFiStorage(_aFiStorage),
      IAFi(aFiContract).getUTokens()
    );
  }

  /**
   * @notice Calculates the total value of pre-swap deposits in USD.
   * @dev Internal function used to determine the total value of pre-swap deposits in USD.
   * @param aFiContract Instance of the aFi contract.
   * @param _aFiStorage Instance of the aFiStorage contract.
   * @return totalPreDepositInUSD The total value of pre-swap deposits in USD.
   */
  function inputTokenUSD(
    IAFi aFiContract,
    uint256 cSwapCounter,
    IAFiStorage _aFiStorage
  ) public view returns (uint256 totalPreDepositInUSD) {
    (address[] memory _iToken, ) = aFiContract.getInputToken();
    uint256 depTok;
    uint uTokensDecimal;
    uint256 price;
    uint256 multiplier;

    for (uint i = 0; i < _iToken.length; i++) {
      (depTok) = _aFiStorage.getPreSwapDepositsTokens(
        address(aFiContract),
        cSwapCounter,
        address(_iToken[i])
      );
      if (depTok > 0) {
        uTokensDecimal = IERC20(_iToken[i]).decimals();
        (price, multiplier) = _aFiStorage.getPriceInUSDC(
          _iToken[i]
        );

        validateGreaterEqual(18, uTokensDecimal);
        uTokensDecimal = 18 - uTokensDecimal;
        totalPreDepositInUSD += (((depTok) * (10 ** uTokensDecimal) * (uint(price))) /
          (multiplier));
      }
    }
  }

  /**
   * @notice Performs an emergency rebalance of the aFi contract.
   * @dev Only the contract owner can call this function, and it must not be reentrant.
   * @param aFiContract Instance of the aFi contract.
   * @param _aFiStorage Instance of the aFiStorage contract.
   * @param uTokenToRemove Address of the uToken to be removed.
   * @param defProp Array of default uTokens proportion to be updated.
   */
  function emergencyRebalance(
    IAFi aFiContract,
    IAFiStorage _aFiStorage,
    address uTokenToRemove,
    uint256[] memory defProp
  ) external nonReentrant onlyOwner contractUnpaused {
     rebalanceInternal(
      aFiContract,
      _aFiStorage,
      uTokenToRemove,
      defProp
    );
  }

  function rebalanceInternal(
    IAFi aFiContract,
    IAFiStorage _aFiStorage,
    address uTokenToRemove,
    uint256[] memory defProp
  ) internal {
    address[] memory uTok = aFiContract.getUTokens();

    (uint index, ) = ArrayUtils.indexOf(uTok, uTokenToRemove);

    for (uint i = 0; i < uTok.length; i++) {
      if (i >= index && i != (uTok.length - 1)) {
        uTok[i] = uTok[i + 1];
      }

      if (i == (uTok.length - 1)) {
        assembly {
          mstore(uTok, sub(mload(uTok), 1))
        }
      }
    }

    require(uTok.length == defProp.length, "AM11");

    _aFiStorage._withdrawAll(address(aFiContract), uTokenToRemove);

    // Update input token data after removing the uToken
    (
      address[] memory inputStables,
      address[] memory nonOverlappingITokens
    ) = aFiContract.getInputToken();

    updateInputTokenData(
      address(aFiContract),
      address(_aFiStorage),
      uTokenToRemove,
      inputStables,
      nonOverlappingITokens
    );

    aFiContract.updateDp(defProp, defProp, 1);
    aFiContract.updateuTokAndProp(uTok);
  }

  function checkProductType(IAFi afiContract) internal {
    (, , uint256 productType) = afiContract.getTVLandRebalContractandType();
    require(productType == 3, "AM10");
  }

  /**
   * @notice Performs an algo type 2 rebalance of the aFi contract.
   * @dev Only the contract owner can call this function, and it must not be reentrant.
   * @param aFiContract address of the aFi contract.
   * @param _aFiStorage address of the aFiStorage contract.
   * @param uTokenToRemove Address of the uToken to be removed.
   * @param defProp Array of default uTokens proportion to be updated.
   * @param deadline uint256 deadline to perform swaps on uniswapV3.
   * @param stableamountOut uint256 minimum amount out value of the depositTok after swap.
  */
  // Algo Rebalance 2
  function algoRebalance2(
    IAFi aFiContract, 
    IAFiStorage _aFiStorage, 
    address uTokenToRemove, 
    uint256[] memory defProp,
    address depositTok, 
    uint256 deadline, 
    uint256 stableamountOut
  ) external nonReentrant contractUnpaused{
    require(msg.sender == rebalanceController, "AM002");

    (address[] memory inputStables, ) = aFiContract.getInputToken();
    (, bool present) = ArrayUtils.indexOf(inputStables, depositTok);
    require(present, "AM003");

    checkProductType(aFiContract);

    rebalanceInternal(
      aFiContract,
      _aFiStorage,
      uTokenToRemove,
      defProp
    );

    uint256 balToConsider = convertToStable(aFiContract, uTokenToRemove, depositTok, deadline, stableamountOut);
    balToConsider = IERC20(depositTok).balanceOf(address(aFiContract)) - balToConsider;

    _aFiStorage.setPreDepositedInputTokenInRebalance(
      address(aFiContract),
      aFiContract.getcSwapCounter(), 
      balToConsider, 
      depositTok
    );
  }

  function convertToStable(
    IAFi aFiContract, 
    address uTokenToRemove, 
    address depositTok, 
    uint256 deadline, 
    uint256 stableamountOut
  ) internal returns(uint256 _stableBalToConsider){

    require(
      IERC20(uTokenToRemove).balanceOf(address(aFiContract)) > 0,
      "AM06"
    );

    // To avoid stack too deep error
    // Get Deposit token back from the UToken that is going to be rebalanced
    address midTok = IUniswapOracleV3(afiOracle).getMidToken(
      uTokenToRemove
    );

    updateUniPoolInRebal(midTok, IERC20(depositTok), uTokenToRemove);

    _stableBalToConsider = IERC20(depositTok).balanceOf(address(aFiContract));

    aFiManagerSwap(
      uTokenToRemove,
      depositTok,
      IERC20(uTokenToRemove).balanceOf(address(aFiContract)),
      aFiContract,
      deadline,
      midTok,
      stableamountOut
    );
  }
}