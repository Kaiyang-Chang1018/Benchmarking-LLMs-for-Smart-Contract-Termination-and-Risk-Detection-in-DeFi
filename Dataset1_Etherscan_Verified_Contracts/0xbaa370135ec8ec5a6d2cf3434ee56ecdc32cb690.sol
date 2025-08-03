// Sources flattened with hardhat v2.22.2 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

// End consumer library.
library Client {
  /// @dev RMN depends on this struct, if changing, please notify the RMN maintainers.
  struct EVMTokenAmount {
    address token; // token address on the local chain.
    uint256 amount; // Amount of tokens.
  }

  struct Any2EVMMessage {
    bytes32 messageId; // MessageId corresponding to ccipSend on source.
    uint64 sourceChainSelector; // Source chain selector.
    bytes sender; // abi.decode(sender) if coming from an EVM chain.
    bytes data; // payload sent in original message.
    EVMTokenAmount[] destTokenAmounts; // Tokens and their amounts in their destination chain representation.
  }

  // If extraArgs is empty bytes, the default is 200k gas limit.
  struct EVM2AnyMessage {
    bytes receiver; // abi.encode(receiver address) for dest EVM chains
    bytes data; // Data payload
    EVMTokenAmount[] tokenAmounts; // Token transfers
    address feeToken; // Address of feeToken. address(0) means you will send msg.value.
    bytes extraArgs; // Populate this with _argsToBytes(EVMExtraArgsV1)
  }

  // bytes4(keccak256("CCIP EVMExtraArgsV1"));
  bytes4 public constant EVM_EXTRA_ARGS_V1_TAG = 0x97a657c9;
  struct EVMExtraArgsV1 {
    uint256 gasLimit;
  }

  function _argsToBytes(EVMExtraArgsV1 memory extraArgs) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(EVM_EXTRA_ARGS_V1_TAG, extraArgs);
  }
}


// File @chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IAny2EVMMessageReceiver.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Application contracts that intend to receive messages from
/// the router should implement this interface.
interface IAny2EVMMessageReceiver {
  /// @notice Called by the Router to deliver a message.
  /// If this reverts, any token transfers also revert. The message
  /// will move to a FAILED state and become available for manual execution.
  /// @param message CCIP Message
  /// @dev Note ensure you check the msg.sender is the OffRampRouter
  function ccipReceive(Client.Any2EVMMessage calldata message) external;
}


// File @chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/introspection/IERC165.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

/// @title CCIPReceiver - Base contract for CCIP applications that can receive messages.
abstract contract CCIPReceiver is IAny2EVMMessageReceiver, IERC165 {
  address internal immutable i_ccipRouter;

  constructor(address router) {
    if (router == address(0)) revert InvalidRouter(address(0));
    i_ccipRouter = router;
  }

  /// @notice IERC165 supports an interfaceId
  /// @param interfaceId The interfaceId to check
  /// @return true if the interfaceId is supported
  /// @dev Should indicate whether the contract implements IAny2EVMMessageReceiver
  /// e.g. return interfaceId == type(IAny2EVMMessageReceiver).interfaceId || interfaceId == type(IERC165).interfaceId
  /// This allows CCIP to check if ccipReceive is available before calling it.
  /// If this returns false or reverts, only tokens are transferred to the receiver.
  /// If this returns true, tokens are transferred and ccipReceive is called atomically.
  /// Additionally, if the receiver address does not have code associated with
  /// it at the time of execution (EXTCODESIZE returns 0), only tokens will be transferred.
  function supportsInterface(bytes4 interfaceId) public pure virtual override returns (bool) {
    return interfaceId == type(IAny2EVMMessageReceiver).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  /// @inheritdoc IAny2EVMMessageReceiver
  function ccipReceive(Client.Any2EVMMessage calldata message) external virtual override onlyRouter {
    _ccipReceive(message);
  }

  /// @notice Override this function in your implementation.
  /// @param message Any2EVMMessage
  function _ccipReceive(Client.Any2EVMMessage memory message) internal virtual;

  /////////////////////////////////////////////////////////////////////
  // Plumbing
  /////////////////////////////////////////////////////////////////////

  /// @notice Return the current router
  /// @return CCIP router address
  function getRouter() public view returns (address) {
    return address(i_ccipRouter);
  }

  error InvalidRouter(address router);

  /// @dev only calls from the set router are accepted.
  modifier onlyRouter() {
    if (msg.sender != address(i_ccipRouter)) revert InvalidRouter(msg.sender);
    _;
  }
}


// File @chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface IRouterClient {
  error UnsupportedDestinationChain(uint64 destChainSelector);
  error InsufficientFeeTokenAmount();
  error InvalidMsgValue();

  /// @notice Checks if the given chain ID is supported for sending/receiving.
  /// @param chainSelector The chain to check.
  /// @return supported is true if it is supported, false if not.
  function isChainSupported(uint64 chainSelector) external view returns (bool supported);

  /// @notice Gets a list of all supported tokens which can be sent or received
  /// to/from a given chain id.
  /// @param chainSelector The chainSelector.
  /// @return tokens The addresses of all tokens that are supported.
  function getSupportedTokens(uint64 chainSelector) external view returns (address[] memory tokens);

  /// @param destinationChainSelector The destination chainSelector
  /// @param message The cross-chain CCIP message including data and/or tokens
  /// @return fee returns execution fee for the message
  /// delivery to destination chain, denominated in the feeToken specified in the message.
  /// @dev Reverts with appropriate reason upon invalid message.
  function getFee(
    uint64 destinationChainSelector,
    Client.EVM2AnyMessage memory message
  ) external view returns (uint256 fee);

  /// @notice Request a message to be sent to the destination chain
  /// @param destinationChainSelector The destination chain ID
  /// @param message The cross-chain CCIP message including data and/or tokens
  /// @return messageId The message ID
  /// @dev Note if msg.value is larger than the required fee (from getFee) we accept
  /// the overpayment with no refund.
  /// @dev Reverts with appropriate reason upon invalid message.
  function ccipSend(
    uint64 destinationChainSelector,
    Client.EVM2AnyMessage calldata message
  ) external payable returns (bytes32);
}


// File @chainlink/contracts-ccip/src/v0.8/shared/interfaces/IOwnable.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface IOwnable {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}


// File @chainlink/contracts-ccip/src/v0.8/shared/access/ConfirmedOwnerWithProposal.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwnerWithProposal is IOwnable {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    // solhint-disable-next-line custom-errors
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /// @notice Allows an owner to begin transferring ownership to a new address.
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /// @notice Allows an ownership transfer to be completed by the recipient.
  function acceptOwnership() external override {
    // solhint-disable-next-line custom-errors
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /// @notice Get the current owner
  function owner() public view override returns (address) {
    return s_owner;
  }

  /// @notice validate, transfer ownership, and emit relevant events
  function _transferOwnership(address to) private {
    // solhint-disable-next-line custom-errors
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /// @notice validate access
  function _validateOwnership() internal view {
    // solhint-disable-next-line custom-errors
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /// @notice Reverts if called by anyone other than the contract owner.
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}


// File @chainlink/contracts-ccip/src/v0.8/shared/access/ConfirmedOwner.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}


// File @chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

/// @title The OwnerIsCreator contract
/// @notice A contract with helpers for basic contract ownership.
contract OwnerIsCreator is ConfirmedOwner {
  constructor() ConfirmedOwner(msg.sender) {}
}


// File contracts/CCWSTBTMessager.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.19;




interface ICCIPClient {
    function getCcSendData(address sender, address receiver, uint256 value) external view returns (bytes memory message);

    function ccSend(address sender, address recipient, uint256 value) external returns (bytes memory message);

    function ccReceive(bytes calldata message) external;
}

contract CCWSTBTMessager is CCIPReceiver, OwnerIsCreator {
    ICCIPClient public ccipClient;

    mapping(uint64 => mapping(address => bool)) public allowedPeer;

    event AllowedPeer(uint64 chainSelector, address messager, bool allowed);
    event CCReceive(bytes32 indexed messageID, bytes messageData);
    event CCSend(bytes32 indexed messageID, bytes messageData);

    error NotAllowlisted(uint64 chainSelector, address messager);

    constructor(
        address _router,
        address _ccipClient
    ) CCIPReceiver(_router) {
        ccipClient = ICCIPClient(_ccipClient);
    }

    function setAllowedPeer(uint64 chainSelector, address messager, bool allowed) external onlyOwner {
        allowedPeer[chainSelector][messager] = allowed;
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    ) internal override {
        address sender = abi.decode(any2EvmMessage.sender, (address));
        if (!allowedPeer[any2EvmMessage.sourceChainSelector][sender]) {
            revert NotAllowlisted(any2EvmMessage.sourceChainSelector, sender);
        }

        ccipClient.ccReceive(any2EvmMessage.data);
        emit CCReceive(any2EvmMessage.messageId, any2EvmMessage.data);
    }

    function calculateFeeAndMessage(
        uint64 destinationChainSelector,
        address messageReceiver,
        address sender,
        address recipient,
        uint value,
        bytes calldata extraArgs
    ) public view returns (uint256 fee, Client.EVM2AnyMessage memory evm2AnyMessage) {
        bytes memory data = ccipClient.getCcSendData(sender, recipient, value);
        evm2AnyMessage = Client.EVM2AnyMessage({
        receiver : abi.encode(messageReceiver),
        data : data,
        tokenAmounts : new Client.EVMTokenAmount[](0),
        extraArgs : extraArgs,
        feeToken : address(0)
        });
        fee = IRouterClient(getRouter()).getFee(destinationChainSelector, evm2AnyMessage);
    }

    function transferToChain(
        uint64 destinationChainSelector,
        address messageReceiver,
        address recipient,
        uint value,
        bytes calldata extraArgs
    ) external payable returns (bytes32 messageId) {
        if (!allowedPeer[destinationChainSelector][messageReceiver]) {
            revert NotAllowlisted(destinationChainSelector, messageReceiver);
        }
        bytes memory data = ccipClient.ccSend(msg.sender, recipient, value);
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
        receiver : abi.encode(messageReceiver),
        data : data,
        tokenAmounts : new Client.EVMTokenAmount[](0),
        extraArgs : extraArgs,
        feeToken : address(0)
        });
        uint256 fee = IRouterClient(getRouter()).getFee(destinationChainSelector, evm2AnyMessage);
        require(msg.value >= fee, "CCWSTBTMessager: INSUFFICIENT_FUNDS");
        messageId = IRouterClient(getRouter()).ccipSend{value : fee}(
            destinationChainSelector,
            evm2AnyMessage
        );
        if (msg.value - fee > 0) {
            bool success = payable(msg.sender).send(msg.value - fee);
            require(success, "CCWSTBTMessager: TRANSFER_FAILED");
        }
        emit CCSend(messageId, data);
        return messageId;
    }
}