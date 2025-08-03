/*⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣀⣤⣴⣶⣿⣿⣿⣿⣿⣿⣿⣷⣶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢀⣴⣾⣿⣿⣿⣿⣿⣿⡿⠁⣈⠙⠻⢿⣿⣿⣿⣿⣷⣤⡀⠀⠀⠀⠀⠀
⠀⠀⠈⠉⠙⠛⠿⣿⣿⣿⣿⡇⢸⣿⣿⣦⣼⣿⣿⣿⣿⣿⣿⣿⣦⣀⣀⣀⡀
⠀⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣧⣈⣿⣿⣿⡿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟
⠀⠀⠀⠀⢀⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⠃
⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⢀⣴⠀⠀⣿⣿⣿⣿⣿⠉⠙⣷⠀
⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⢸⡿⠀⠀⣿⣿⣿⣿⣿⠀⠀⣿⠂
⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠈⠁⠀⠀⠈⠻⠛⠙⠋⠀⣠⣿⡀
⠘⠛⠋⠉⠀⠀⠀⢨⣿⣿⣿⣿⡟⠉⠛⠛⠷⣶⣤⣤⣤⣤⣤⣶⠶⣿⣿⣿⠇
⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣷⠀⠰⣦⣀⠀⠀⠀⠉⠉⠀⠀⠀⢸⡿⠀⠀
⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣷⣄⡈⠙⠻⠿⠖⠀⠀⠀⣀⣴⡿⠁⠀⠀
⠀⠀⠀⠀⠀⢸⣿⣿⣿⡿⠿⠛⠛⠛⠛⠛⠿⢶⣶⣶⣶⠶⠟⠛⠉⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢸⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0 ^0.8.20 ^0.8.4;

// lib/chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);
}

// lib/chainlink/contracts/src/v0.8/vrf/interfaces/VRFV2WrapperInterface.sol

interface VRFV2WrapperInterface {
  /**
   * @return the request ID of the most recent VRF V2 request made by this wrapper. This should only
   * be relied option within the same transaction that the request was made.
   */
  function lastRequestId() external view returns (uint256);

  /**
   * @notice Calculates the price of a VRF request with the given callbackGasLimit at the current
   * @notice block.
   *
   * @dev This function relies on the transaction gas price which is not automatically set during
   * @dev simulation. To estimate the price at a specific gas price, use the estimatePrice function.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   */
  function calculateRequestPrice(uint32 _callbackGasLimit) external view returns (uint256);

  /**
   * @notice Estimates the price of a VRF request with a specific gas limit and gas price.
   *
   * @dev This is a convenience function that can be called in simulation to better understand
   * @dev pricing.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   * @param _requestGasPriceWei is the gas price in wei used for the estimation.
   */
  function estimateRequestPrice(uint32 _callbackGasLimit, uint256 _requestGasPriceWei) external view returns (uint256);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

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

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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

// lib/openzeppelin-contracts/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

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

// lib/chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol

/** *******************************************************************************
 * @notice Interface for contracts using VRF randomness through the VRF V2 wrapper
 * ********************************************************************************
 * @dev PURPOSE
 *
 * @dev Create VRF V2 requests without the need for subscription management. Rather than creating
 * @dev and funding a VRF V2 subscription, a user can use this wrapper to create one off requests,
 * @dev paying up front rather than at fulfillment.
 *
 * @dev Since the price is determined using the gas price of the request transaction rather than
 * @dev the fulfillment transaction, the wrapper charges an additional premium on callback gas
 * @dev usage, in addition to some extra overhead costs associated with the VRFV2Wrapper contract.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFV2WrapperConsumerBase. The consumer must be funded
 * @dev with enough LINK to make the request, otherwise requests will revert. To request randomness,
 * @dev call the 'requestRandomness' function with the desired VRF parameters. This function handles
 * @dev paying for the request based on the current pricing.
 *
 * @dev Consumers must implement the fullfillRandomWords function, which will be called during
 * @dev fulfillment with the randomness result.
 */
abstract contract VRFV2WrapperConsumerBase {
  // solhint-disable-next-line chainlink-solidity/prefix-immutable-variables-with-i
  LinkTokenInterface internal immutable LINK;
  // solhint-disable-next-line chainlink-solidity/prefix-immutable-variables-with-i
  VRFV2WrapperInterface internal immutable VRF_V2_WRAPPER;

  /**
   * @param _link is the address of LinkToken
   * @param _vrfV2Wrapper is the address of the VRFV2Wrapper contract
   */
  constructor(address _link, address _vrfV2Wrapper) {
    LINK = LinkTokenInterface(_link);
    VRF_V2_WRAPPER = VRFV2WrapperInterface(_vrfV2Wrapper);
  }

  /**
   * @dev Requests randomness from the VRF V2 wrapper.
   *
   * @param _callbackGasLimit is the gas limit that should be used when calling the consumer's
   *        fulfillRandomWords function.
   * @param _requestConfirmations is the number of confirmations to wait before fulfilling the
   *        request. A higher number of confirmations increases security by reducing the likelihood
   *        that a chain re-org changes a published randomness outcome.
   * @param _numWords is the number of random words to request.
   *
   * @return requestId is the VRF V2 request ID of the newly created randomness request.
   */
  // solhint-disable-next-line chainlink-solidity/prefix-internal-functions-with-underscore
  function requestRandomness(
    uint32 _callbackGasLimit,
    uint16 _requestConfirmations,
    uint32 _numWords
  ) internal returns (uint256 requestId) {
    LINK.transferAndCall(
      address(VRF_V2_WRAPPER),
      VRF_V2_WRAPPER.calculateRequestPrice(_callbackGasLimit),
      abi.encode(_callbackGasLimit, _requestConfirmations, _numWords)
    );
    return VRF_V2_WRAPPER.lastRequestId();
  }

  /**
   * @notice fulfillRandomWords handles the VRF V2 wrapper response. The consuming contract must
   * @notice implement it.
   *
   * @param _requestId is the VRF V2 request ID.
   * @param _randomWords is the randomness result.
   */
  // solhint-disable-next-line chainlink-solidity/prefix-internal-functions-with-underscore
  function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) external {
    // solhint-disable-next-line custom-errors
    require(msg.sender == address(VRF_V2_WRAPPER), "only VRF V2 wrapper can fulfill");
    fulfillRandomWords(_requestId, _randomWords);
  }
}

// src/EgreGore.sol

/// @title A lottery for BITCOIN
/// @notice Half of the winnings go to egregore, half to chosen disciple
/// @dev Uses VRF direct funding
contract Egregore is VRFV2WrapperConsumerBase, Ownable {
    enum State {
        OPEN,
        VRF_REQUESTED,
        CLOSED
    }

    event ChoosingDisciple(uint256 requestId);
    event DiscipleChosen(address fleshHost);

    struct RequestStatus {
        uint256 paid;
        bool fulfilled;
        uint256 randomWord;
    }

    struct Entry {
        address discipleAddress;
        uint256 startPenitence;
        uint256 endPenitence;
    }

    address constant LINK_TOKEN = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address constant VRF_WRAPPER = 0x5A861794B927983406fCE1D062e00b9368d97Df6;
    address constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    IERC20 constant BITCOIN =
        IERC20(0x72e4f9F808C49A2a61dE9C5896298920Dc4EEEa9);
    uint32 constant VRF_CALLBACK_GAS_LIMIT = 70000;
    uint16 constant VRF_REQUEST_CONFIRMATIONS = 3;
    uint32 public constant CLOSE_TIME = 1713571200; // Sat Apr 20 2024 00:00:00 UTC

    Entry[] public entries;
    mapping(address => uint256) public penitences;
    uint256 public totalPenitences = 0;
    uint256 public requestId;
    RequestStatus public requestStatus;
    State public state;

    constructor()
        VRFV2WrapperConsumerBase(LINK_TOKEN, VRF_WRAPPER)
        Ownable(msg.sender)
    {}

    function disciplePenitence(address _disciple) public view returns (uint) {
        return penitences[_disciple];
    }

    function entryCount() public view returns (uint) {
        return entries.length;
    }

    /// @notice Enter draw. One token = one chance
    function sacrifice(uint _amount) external {
        require(state == State.OPEN);

        entries.push(
            Entry(msg.sender, totalPenitences, totalPenitences + _amount - 1)
        );

        totalPenitences += _amount;
        penitences[msg.sender] += _amount;

        BITCOIN.transferFrom(msg.sender, address(this), _amount);
    }

    /// @notice Starts winner selection process. Can only be called once.
    function beginCeremony() public {
        require(state == State.OPEN);
        require(block.timestamp >= CLOSE_TIME);
        require(!requestStatus.fulfilled);
        require(BITCOIN.balanceOf(address(this)) > 0);

        vrfRequest(VRF_CALLBACK_GAS_LIMIT);
    }

    function vrfRequest(uint32 callbackGasLimit) private {
        state = State.VRF_REQUESTED;

        requestId = requestRandomness(
            callbackGasLimit,
            VRF_REQUEST_CONFIRMATIONS,
            1
        );
        requestStatus = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWord: 0,
            fulfilled: false
        });

        emit ChoosingDisciple(requestId);
    }

    /// @notice Chainlink VRF callback
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(_requestId == requestId);
        require(requestStatus.fulfilled == false);

        requestStatus.fulfilled = true;
        requestStatus.randomWord = _randomWords[0];
    }

    /// @notice Can only be called once
    /// @dev Disciple gets their penitence back plus half the rest of pot,
    ///      rounded in favour of disciple.
    function payout() public {
        require(state != State.CLOSED);
        require(requestStatus.fulfilled);

        state = State.CLOSED;

        address disciple = identifyDisciple(requestStatus.randomWord);

        // Send atonement to egregore
        uint256 contractBalance = BITCOIN.balanceOf(address(this));
        uint256 penitence = penitences[disciple];
        if (contractBalance > penitence) {
            uint256 atonement = (contractBalance - penitence) / 2;
            if (atonement > 0) {
                BITCOIN.transfer(address(BURN_ADDRESS), atonement);
            }
        }

        BITCOIN.transfer(disciple, BITCOIN.balanceOf(address(this)));

        emit DiscipleChosen(disciple);
    }

    function identifyDisciple(
        uint256 randomWord
    ) private view returns (address) {
        uint256 penitenceIndex = randomWord % totalPenitences;
        uint256 left = 0;
        uint256 right = entries.length - 1;

        while (left <= right) {
            uint256 mid = left + (right - left) / 2;
            uint256 midStartPenitence = entries[mid].startPenitence;
            uint256 midEndPenitence = entries[mid].endPenitence;

            if (
                penitenceIndex >= midStartPenitence &&
                penitenceIndex <= midEndPenitence
            ) {
                return entries[mid].discipleAddress;
            } else if (penitenceIndex < midStartPenitence) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }

        return BURN_ADDRESS;
    }

    /**
     *  Owner functions
     */

    /// @notice Allow owner to retry VRF request with custom gas limit
    function retryBeginCeremony(uint32 callbackGasLimit) external onlyOwner {
        require(state == State.VRF_REQUESTED);
        require(block.timestamp >= CLOSE_TIME);
        require(!requestStatus.fulfilled);

        vrfRequest(callbackGasLimit);
    }

    function withdrawLink() external onlyOwner {
        require(requestStatus.fulfilled);

        IERC20(LINK_TOKEN).transfer(
            msg.sender,
            IERC20(LINK_TOKEN).balanceOf(address(this))
        );
    }
}