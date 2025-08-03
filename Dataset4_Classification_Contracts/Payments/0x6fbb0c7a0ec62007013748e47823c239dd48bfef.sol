// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import '../interfaces/IPayable.sol';
import './AbstractPayer.sol';

/// @title Abstract base contract for contracts receiving the Reactive Network callbacks.
abstract contract AbstractCallback is AbstractPayer {
    address internal rvm_id;

    constructor(address _callback_sender) {
        rvm_id = msg.sender;
        vendor = IPayable(payable(_callback_sender));
        addAuthorizedSender(_callback_sender);
    }

    modifier rvmIdOnly(address _rvm_id) {
        require(rvm_id == address(0) || rvm_id == _rvm_id, 'Authorized RVM ID only');
        _;
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import '../interfaces/IPayer.sol';
import '../interfaces/IPayable.sol';

/// @title Abstract base contract for contracts needing to handle payments to the system contract or callback proxies.
abstract contract AbstractPayer is IPayer {
    IPayable internal vendor;

    /// @notice ACL for addresses allowed to make callbacks and/or request payment.
    mapping(address => bool) senders;

    constructor() {
    }

    /// @inheritdoc IPayer
    receive() virtual external payable {
    }

    modifier authorizedSenderOnly() {
        require(senders[msg.sender], 'Authorized sender only');
        _;
    }

    /// @inheritdoc IPayer
    function pay(uint256 amount) external authorizedSenderOnly {
        _pay(payable(msg.sender), amount);
    }

    /// @notice Automatically cover the outstanding debt to the system contract or callback proxy, provided the contract has sufficient funds.
    function coverDebt() external {
        uint256 amount = vendor.debt(address(this));
        _pay(payable(vendor), amount);
    }

    /// @notice Attempts to safely transfer the specified sum to the given address.
    /// @param recipient Address of the transfer's recipient.
    /// @param amount Amount to be transferred.
    function _pay(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Insufficient funds');
        if (amount > 0) {
            (bool success,) = payable(recipient).call{value: amount}(new bytes(0));
            require(success, 'Transfer failed');
        }
    }

    /// @notice Adds the given address to the ACL.
    /// @param sender Sender address to add.
    function addAuthorizedSender(address sender) internal {
        senders[sender] = true;
    }

    /// @notice Removes the given address from the ACL.
    /// @param sender Sender address to remove.
    function removeAuthorizedSender(address sender) internal {
        senders[sender] = false;
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

/// @title Common interface for the system contract and the callback proxy, allows contracts to check and pay their debts.
interface IPayable {
    /// @notice Allows contracts to pay their debts and resume subscriptions.
    receive() external payable;

    /// @notice Allows reactive contracts to check their outstanding debt.
    /// @param _contract Reactive contract's address.
    /// @return Reactive contract's current debt due to unpaid reactive transactions and/or callbacks.
    function debt(address _contract) external view returns (uint256);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

/// @title Common interface for the contracts that need to pay for system contract's or proxies' services.
interface IPayer {
    /// @notice Method called by the system contract and/or proxies when payment is due.
    /// @dev Make sure to check the msg.sender.
    /// @param amount Amount owed due to reactive transactions and/or callbacks.
    function pay(uint256 amount) external;

    /// @notice Allows the reactive contracts and callback contracts to receive funds for their operational expenses.
    receive() external payable;
}
// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

/// @title Abstract base contract implementing the abstract message transport protocol.
/// @dev Specific bridge implementation must implement concrete cross-chain transport.
abstract contract AbstractBridgehead {
    enum MessageStatus {
        NONE,
        REJECTED,
        PENDING,
        DELIVERING,
        DELIVERED
    }

    enum RequestStatus {
        NONE,
        SENT,
        RECEIVED
    }

    struct MessageId {
        uint256 tx;
        uint256 index;
        uint256 amount;
        address sender;
        address recipient;
    }

    struct MessageState {
        MessageStatus status;
        uint8 confirmations;
        uint256 last_touched;
        mapping (uint256 => RequestStatus) seen;
    }

    uint256 private constant INIT_SUBMSG_ID = 0;
    uint256 private constant REJECTED_SUBMSG_ID = 0xDEADBEEF;
    uint256 private constant DELIVERING_SUBMSG_ID = 0xCAFEBABE;
    uint256 private constant DELIVERED_SUBMSG_ID = 0xBEEFCAFE;

    /// @notice Number of active sender confirmation. required to fully confirm the delivery.
    uint8 confirmations;

    /// @notice Inddicates whether message cancellations are allowed.
    bool allow_cancellations;

    /// @notice Allowed cancellation threshold since last activity (in blocks).
    uint256 cancellation_threshold;

    /// @notice Maps outgoing message IDs to message states.
    mapping (uint256 => MessageState) outbox;

    /// @notice Maps incoming message IDs to message states.
    mapping (uint256 => MessageState) inbox;

    constructor(
        uint8 _confirmations,
        bool _allow_cancellations,
        uint256 _cancellation_threshold
    ) payable {
        confirmations = _confirmations;
        allow_cancellations = _allow_cancellations;
        cancellation_threshold = _cancellation_threshold;
    }

    // Outbox side methods

    /// @notice Implementing classes must implement delivery of the initial message.
    /// @param id Original message ID.
    function _sendInitialMessage(MessageId memory id) virtual internal;

    /// @notice Implementing classes must implement delivery of message confirmation.
    /// @param submsg_id Current message ID in the confirmation chain.
    /// @param id Original message ID.
    function _sendConfirmation(uint256 submsg_id, MessageId memory id) virtual internal;

    /// @notice Implementing classes must implement delivery of message rejection.
    /// @param submsg_id Current message ID in the confirmation chain.
    /// @param id Original message ID.
    function _sendRejection(uint256 submsg_id, MessageId memory id) virtual internal;

    /// @notice Implementing classes must implement returning of rejected messages.
    /// @param id Original message ID.
    function _returnMessage(MessageId memory id) virtual internal;

    /// @notice Implementing classes must implement returning of finalization of delivered messages (if required).
    /// @param id Original message ID.
    function _finalizeMessage(MessageId memory id) virtual internal;

    /// @notice Checks for duplicates, updates the message state, and triggers the delivery of the initial message.
    /// @param id Original message ID.
    function _sendMessage(MessageId memory id) internal {
        MessageState storage state = outbox[_hashId(id)];
        require(state.status == MessageStatus.NONE, '[SM] Duplicate message ID');
        _touch(state, INIT_SUBMSG_ID, MessageStatus.PENDING, RequestStatus.RECEIVED, false);
        _sendInitialMessage(id);
    }

    /// @notice Cancels the outgoing message if possible.
    /// @param id Original message ID.
    function _cancelMessage(MessageId memory id) internal {
        require(allow_cancellations, 'Cancellations not allowed');
        MessageState storage state = outbox[_hashId(id)];
        require(
            state.status == MessageStatus.PENDING && (block.number - state.last_touched) > cancellation_threshold,
            '[CM] Invalid message ID'
        );
        _touch(state, REJECTED_SUBMSG_ID, MessageStatus.REJECTED, RequestStatus.RECEIVED, false);
        _returnMessage(id);
    }

    /// @notice Verifies the incoming confirmation request, and sends confirmation or rejection as appropriate.
    /// @param submsg_id Current message ID in the confirmation chain.
    /// @param id Original message ID.
    function _processConfirmationRequest(uint256 submsg_id, MessageId memory id) internal {
        MessageState storage state = outbox[_hashId(id)];
        if (_valid(state, submsg_id, RequestStatus.NONE)) {
            _touch(state, submsg_id, MessageStatus.PENDING, RequestStatus.RECEIVED, true);
            _sendConfirmation(submsg_id, id);
        } else {
            _sendRejection(submsg_id, id);
        }
    }

    /// @notice Processes the delivery rejection of a given message, initiates message retun if verified..
    /// @param id Original message ID.
    function _processDeliveryRejection(MessageId memory id) internal {
        MessageState storage state = outbox[_hashId(id)];
        require(state.status == MessageStatus.PENDING, '[PDR] Invalid message ID');
        _touch(state, REJECTED_SUBMSG_ID, MessageStatus.REJECTED, RequestStatus.RECEIVED, false);
        _returnMessage(id);
    }

    /// @notice Processes the delivery confirmation of a given message, initiates message finalization if verified..
    /// @param id Original message ID.
    function _processDeliveryConfirmation(MessageId memory id) internal {
        MessageState storage state = outbox[_hashId(id)];
        require(state.status == MessageStatus.PENDING, '[PDC] Invalid message ID');
        _touch(state, DELIVERED_SUBMSG_ID, MessageStatus.DELIVERED, RequestStatus.RECEIVED, false);
        _finalizeMessage(id);
    }

    // Inbox side methods

    /// @notice Implementing classes must implement sending of confirmation requests.
    /// @param submsg_id Current message ID in the confirmation chain.
    /// @param id Original message ID.
    function _sendConfirmationRequest(uint256 submsg_id, MessageId memory id) virtual internal;

    /// @notice Implementing classes must implement the final message delivery.
    /// @param id Original message ID.
    function _deliver(MessageId memory id) virtual internal;

    /// @notice Implementing classes must implement the transport of delivery confirmations.
    /// @param id Original message ID.
    function _sendDeliveryConfirmation(MessageId memory id) virtual internal;

    /// @notice Implementing classes must implement the transport of delivery rejections.
    /// @param id Original message ID.
    function _sendDeliveryRejection(MessageId memory id) virtual internal;

    /// @notice Processes the initial message request, initiates the sending of initial confirmation requests.
    /// @param submsg_id Current message ID in the confirmation chain.
    /// @param id Original message ID.
    function _processInitialMessage(uint256 submsg_id, MessageId memory id) internal {
        MessageState storage state = inbox[_hashId(id)];
        require(state.status == MessageStatus.NONE, '[PIM] Duplicate message ID');
        _touch(state, INIT_SUBMSG_ID, MessageStatus.PENDING, RequestStatus.RECEIVED, false);
        _requestConfirmation(submsg_id, id);
    }

    /// @notice Allows to retry the delivery of stuck messages by requesting additional confirmations.
    /// @param submsg_id Current message ID in the confirmation chain.
    /// @param id Original message ID.
    function _retry(uint256 submsg_id, MessageId memory id) internal {
        MessageState storage state = inbox[_hashId(id)];
        require(state.status == MessageStatus.PENDING, '[R] Invalid message ID');
        _requestConfirmation(submsg_id, id);
    }

    /// @notice Requests the message confirmation from the outbox side of the bridge.
    /// @param submsg_id Current message ID in the confirmation chain.
    /// @param id Original message ID.
    function _requestConfirmation(uint256 submsg_id, MessageId memory id) internal {
        MessageState storage state = inbox[_hashId(id)];
        if (_valid(state, submsg_id, RequestStatus.NONE)) {
            _touch(state, submsg_id, MessageStatus.PENDING, RequestStatus.SENT, false);
            _sendConfirmationRequest(submsg_id, id);
        }
    }

    /// @notice Processed incoming message confirmation, requesting additional confirmation if needed, or delivering the message.
    /// @param submsg_id Current message ID in the confirmation chain.
    /// @param new_submsg_id Next message ID in the confirmation chain.
    /// @param id Original message ID.
    function _processConfirmation(uint256 submsg_id, uint256 new_submsg_id, MessageId memory id) internal {
        MessageState storage state = inbox[_hashId(id)];
        if (_valid(state, submsg_id, RequestStatus.SENT)) {
            _touch(state, submsg_id, MessageStatus.PENDING, RequestStatus.RECEIVED, true);
            if (state.confirmations >= confirmations) {
                _touch(state, DELIVERING_SUBMSG_ID, MessageStatus.DELIVERING, RequestStatus.RECEIVED, false);
                _deliver(id);
            } else {
                _requestConfirmation(new_submsg_id, id);
            }
        }
    }

    /// @notice Processes incoming message rejection.
    /// @param submsg_id Current message ID in the confirmation chain.
    /// @param id Original message ID.
    function _processRejection(uint256 submsg_id, MessageId memory id) internal {
        MessageState storage state = inbox[_hashId(id)];
        if (_valid(state, submsg_id, RequestStatus.SENT)) {
            _touch(state, DELIVERING_SUBMSG_ID, MessageStatus.DELIVERING, RequestStatus.RECEIVED, false);
            _rejectDelivery(id);
        }
    }

    /// @notice Triggers the transport of delivery confirmation to the outbox.
    /// @param id Original message ID.
    function _confirmDelivery(MessageId memory id) internal {
        MessageState storage state = inbox[_hashId(id)];
        require(state.status == MessageStatus.DELIVERING, '[CD] Invalid message ID');
        _touch(state, DELIVERED_SUBMSG_ID, MessageStatus.DELIVERED, RequestStatus.RECEIVED, false);
        _sendDeliveryConfirmation(id);
    }

    /// @notice Triggers the transport of delivery rejection to the outbox.
    /// @param id Original message ID.
    function _rejectDelivery(MessageId memory id) internal {
        MessageState storage state = inbox[_hashId(id)];
        require(state.status == MessageStatus.DELIVERING, '[RD] Invalid message ID');
        _touch(state, REJECTED_SUBMSG_ID, MessageStatus.REJECTED, RequestStatus.RECEIVED, false);
        _sendDeliveryRejection(id);
    }

    // Common methods

    /// @notice Update the message and submessage state.
    /// @param state Current message state.
    /// @param submsg_id Message ID of the current message in the confirmation chain.
    /// @param status New message status.
    /// @param rq_status New sub-message (confirmation request/confirmation) status.
    /// @param increase_confirmations Indicates whether the number of sent/received confirmations should be increased.
    function _touch(
        MessageState storage state,
        uint256 submsg_id,
        MessageStatus status,
        RequestStatus rq_status,
        bool increase_confirmations
    ) private {
        if (state.seen[submsg_id] != RequestStatus.RECEIVED) {
            state.seen[submsg_id] = rq_status;
            state.status = status;
            state.last_touched = block.number;
            if (increase_confirmations) {
                ++state.confirmations;
            }
        }
    }

    /// @notice Checks the validity of the current message state in accordance with provided parameters.
    /// @param state Message state to be checked.
    /// @param submsg_id Sub-message ID in the confirmation chain.
    /// @param status Expected sub-message status.
    /// @return Indicates whether the state matches expectations.
    function _valid(MessageState storage state, uint256 submsg_id, RequestStatus status) private view returns (bool) {
        return state.status == MessageStatus.PENDING && state.seen[submsg_id] == status;
    }

    /// @notice Computes the mapping key from the message.
    /// @param id Message to be processed.
    /// @return Mapping key for inbox/outbox.
    function _hashId(MessageId memory id) private pure returns (uint256) {
        return uint256(keccak256(abi.encode(id.tx, id.amount, id.sender, id.recipient)));
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

import '../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

/// @title Abstract base contract implementing ownership and withdrawal of stuck tokens.
contract AbstractDispenser {
    /// @notice Address of the contract's deployer/owner.
    address owner;

    /// @notice Indicates whether the contract is currently active.
    bool active;

    constructor() {
        owner = msg.sender;
        active = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Not authorized');
        _;
    }

    modifier onlyActive() {
        require(active, 'Not active right now');
        _;
    }

    /// @notice Allows withdrawal of native or ERC20 tokens on the contract's balance.
    /// @param token Token address, or `0` for native.
    /// @param amount Amount to be withdrawn.
    function withdraw(address token, uint256 amount) external onlyOwner {
        if (token == address(0)) {
            require(address(this).balance >= amount, 'Insufficient funds');
            (bool success,) = payable(msg.sender).call{ value: amount }(new bytes(0));
            require(success, 'Failure');
        } else {
            require(IERC20(token).balanceOf(address(this)) >= amount, 'Insufficient funds');
            IERC20(token).transfer(msg.sender, amount);
        }
    }

    function pause() external onlyOwner onlyActive {
        active = false;
    }

    function unpause() external onlyOwner {
        require(!active, 'Already active');
        active = true;
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

/// @title Abstract base contract implementing the calculation of bridge fees.
contract AbstractFeeCalculator {
    uint256 constant MAX_FIXED_FEE = 0.1 ether;
    uint256 constant MAX_PERC_FEE = 1000;

    /// @notice Fixed fee (in wei).
    uint256 fixed_fee;

    /// @notice Fee rate in 0.01%s.
    uint256 perc_fee;

    constructor(uint256 _fixed_fee, uint256 _perc_fee) {
        require(_fixed_fee <= MAX_FIXED_FEE, 'Fixed fee set too high');
        require(_perc_fee <= MAX_PERC_FEE, 'Fee rate set too high');
        fixed_fee = _fixed_fee;
        perc_fee = _perc_fee;
    }

    /// @notice Computed the total fee for the given amount to be bridged.
    /// @param amount Amount to be bridged in wei.
    /// @return Total fee to be withheld.
    function _computeFee(uint256 amount) internal view returns (uint256) {
        return fixed_fee + (amount * perc_fee / 10000);
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

import '../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import '../lib/reactive-lib/src/abstract-base/AbstractCallback.sol';
import './AbstractDispenser.sol';
import './AbstractFeeCalculator.sol';
import './AbstractBridgehead.sol';
import './BridgeLib.sol';

/// @title Interface for extended ERC20 tokens used by the ERC20/REACT bridge.
interface IERC20ForciblyMintableBurnable is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

/// @title Implements the ERC20/non-reactive part of the bridge using the abstract protocol defined in `AbstractBridgehead`.
/// @dev The transport to the other part of the bridge is implemented as log records intercepted by the Reactive Network and delivered to the reactive contract on the other side.
contract Bridge is AbstractCallback, AbstractDispenser, AbstractFeeCalculator, AbstractBridgehead {
    event InitialMessage(
        uint256 indexed tx,
        uint256 indexed index,
        uint256 indexed amount,
        address sender,
        address recipient
    );

    event Confirmation(
        uint256 indexed rq,
        uint256 indexed tx,
        uint256 indexed index,
        uint256 amount,
        address sender,
        address recipient
    );

    event Rejection(
        uint256 indexed rq,
        uint256 indexed tx,
        uint256 indexed index,
        uint256 amount,
        address sender,
        address recipient
    );

    event ConfirmationRequest(
        uint256 indexed rq,
        uint256 indexed tx,
        uint256 indexed index,
        uint256 amount,
        address sender,
        address recipient
    );

    event DeliveryConfirmation(
        uint256 indexed tx,
        uint256 indexed index,
        uint256 indexed amount,
        address sender,
        address recipient
    );

    event DeliveryRejection(
        uint256 indexed tx,
        uint256 indexed index,
        uint256 indexed amount,
        address sender,
        address recipient
    );

    /// @notice Address of the Wrapped REACT, or any other token to be bridged.
    IERC20ForciblyMintableBurnable wreact;

    /// @notice Indicated whether `wreact` can be minted. Will lock the incoming tokens otherwise.
    bool is_mintable;

    /// @notice Indicated whether token burning should be through `burn(uint256)` or `burn(address,uint256)` method.
    bool is_standard_burn;

    /// @notice The amount of extra gas the bridging party will pay for to account for confirmation callbacks.
    uint256 public gas_fee;

    constructor(
        address _callback_proxy,
        uint8 _confirmations,
        bool _allow_cancellations,
        uint256 _cancellation_threshold,
        IERC20ForciblyMintableBurnable _wreact,
        bool _is_mintable,
        bool _is_standard_burn,
        uint256 _fixed_fee,
        uint256 _perc_fee,
        uint256 _gas_fee
    ) AbstractCallback(
        _callback_proxy
    ) AbstractFeeCalculator(
        _fixed_fee,
        _perc_fee
    ) AbstractBridgehead(
        _confirmations,
        _allow_cancellations,
        _cancellation_threshold
    ) payable {
        wreact = _wreact;
        is_mintable = _is_mintable;
        is_standard_burn = _is_standard_burn;
        gas_fee = _gas_fee;
    }

    // Outbox methods

    /// @notice Initiate the bridging sequence from ERC20 to native REACT.
    /// @param uniqueish A reasonably unique-ish number identifying this transaction, provided by the client. Should be unique across messages with the same sender-recipient-amount combination.
    /// @param recipient Recipient's addres on the Reactive Network side.
    /// @param amount Amount of ERC20 to be bridged. 1-to-1 minus the bridging fee.
    function bridge(uint256 uniqueish, address recipient, uint256 amount) external payable onlyActive {
        uint256 extra_gas_price = tx.gasprice * gas_fee;
        require(msg.value >= extra_gas_price, 'Insufficient fee paid for bridging - pay at least tx.gas times gas_fee()');
        if (msg.value > extra_gas_price) {
            (bool success,) = payable(msg.sender).call{ value: msg.value - extra_gas_price }(new bytes(0));
            require(success, 'Unable to return the excess fee');
        }
        require(wreact.balanceOf(msg.sender) >= amount, 'Insufficient funds');
        require(wreact.allowance(msg.sender, address(this)) >= amount, 'Insufficient approved funds');
        require(_computeFee(amount) < amount, 'Not enough to cover the fee');
        wreact.transferFrom(msg.sender, address(this), amount);
        MessageId memory message = MessageId({
            tx: uniqueish,
            index: gasleft(),
            amount: amount,
            sender: msg.sender,
            recipient: recipient
        });
        _sendMessage(message);
    }

    /// @notice Cancels the previously sent briging request, if allowed and possible.
    /// @param uniqueish A reasonably unique-ish number identifying this transaction, provided by the client. Must be unique across messages with the same sender-recipient-amount combination.
    /// @param index `gasleft()` at the point where the original message ID has been computed.
    /// @param recipient Recipient's addres on the Reactive Network side.
    /// @param amount Amount of ERC20 to be bridged. 1-to-1 minus the bridging fee.
    function cancel(uint256 uniqueish, uint256 index, address recipient, uint256 amount) external {
        MessageId memory message = MessageId({
            tx: uniqueish,
            index: index,
            amount: amount,
            sender: msg.sender,
            recipient: recipient
        });
        _cancelMessage(message);
    }

    // Outbox callbacks

    /// @notice Entry point for the confirmation requests received as callback transactions from the reactive part of the bridge.
    /// @param rvm_id RVM ID (i.e., reactive contract's deployer address) injected by the reactive node.
    /// @param submsg_id ID of the confirmation request.
    /// @param txh Original unique-ish number identifying the message.
    /// @param index `gasleft()` at the moment the original message ID has been computed.
    /// @param amount Amount sent.
    /// @param sender Sender address.
    /// @param recipient Recipient address.
    function requestConfirmation(
        address rvm_id,
        uint256 submsg_id,
        uint256 txh,
        uint256 index,
        uint256 amount,
        address sender,
        address recipient
    ) external authorizedSenderOnly rvmIdOnly(rvm_id) {
        MessageId memory message = MessageId({
            tx: txh,
            index: index,
            amount: amount,
            sender: sender,
            recipient: recipient
        });
        _processConfirmationRequest(submsg_id, message);
    }

    /// @notice Entry point for the delivery confirmations received as callback transactions from the reactive part of the bridge.
    /// @param rvm_id RVM ID (i.e., reactive contract's deployer address) injected by the reactive node.
    /// @param txh Original unique-ish number identifying the message.
    /// @param index `gasleft()` at the moment the original message ID has been computed.
    /// @param amount Amount sent.
    /// @param sender Sender address.
    /// @param recipient Recipient address.
    function confirmDelivery(
        address rvm_id,
        uint256 txh,
        uint256 index,
        uint256 amount,
        address sender,
        address recipient
    ) external authorizedSenderOnly rvmIdOnly(rvm_id) {
        MessageId memory message = MessageId({
            tx: txh,
            index: index,
            amount: amount,
            sender: sender,
            recipient: recipient
        });
        _processDeliveryConfirmation(message);
    }

    /// @notice Entry point for the delivery rejections received as callback transactions from the reactive part of the bridge.
    /// @param rvm_id RVM ID (i.e., reactive contract's deployer address) injected by the reactive node.
    /// @param txh Original unique-ish number identifying the message.
    /// @param index `gasleft()` at the moment the original message ID has been computed.
    /// @param amount Amount sent.
    /// @param sender Sender address.
    /// @param recipient Recipient address.
    function rejectDelivery(
        address rvm_id,
        uint256 txh,
        uint256 index,
        uint256 amount,
        address sender,
        address recipient
    ) external authorizedSenderOnly rvmIdOnly(rvm_id) {
        MessageId memory message = MessageId({
            tx: txh,
            index: index,
            amount: amount,
            sender: sender,
            recipient: recipient
        });
        _processDeliveryRejection(message);
    }

    // Outbox transport

    /// @notice Initial message implemented as a log record intercepted by the Reactive Network.
    /// @inheritdoc AbstractBridgehead
    function _sendInitialMessage(MessageId memory id) override internal {
        emit InitialMessage(
            id.tx,
            id.index,
            id.amount,
            id.sender,
            id.recipient
        );
    }

    /// @notice Confirmation sending implemented as a log record intercepted by the Reactive Network.
    /// @inheritdoc AbstractBridgehead
    function _sendConfirmation(uint256 submsg_id, MessageId memory id) override internal {
        emit Confirmation(
            submsg_id,
            id.tx,
            id.index,
            id.amount,
            id.sender,
            id.recipient
        );
    }

    /// @notice Rejection sending implemented as a log record intercepted by the Reactive Network.
    /// @inheritdoc AbstractBridgehead
    function _sendRejection(uint256 submsg_id, MessageId memory id) override internal {
        emit Rejection(
            submsg_id,
            id.tx,
            id.index,
            id.amount,
            id.sender,
            id.recipient
        );
    }

    /// @notice Returning the message boils down to sending the locked tokens back to the sender.
    /// @inheritdoc AbstractBridgehead
    function _returnMessage(MessageId memory id) override internal {
        require(wreact.balanceOf(address(this)) >= id.amount, 'Insufficient funds');
        wreact.transfer(id.sender, id.amount);
    }

    /// @notice Finalizing the message is a no-op in token-locking mode. Burnable tokens are burned to finalize.
    /// @inheritdoc AbstractBridgehead
    function _finalizeMessage(MessageId memory id) override internal {
        require(wreact.balanceOf(address(this)) >= id.amount, 'Insufficient funds');
        if (is_mintable) {
            if (is_standard_burn) {
                wreact.burn(id.amount);
            } else {
                wreact.burn(address(this), id.amount);
            }
        }
    }

    // Inbox methods

    /// @notice Attempt to retry the delivery of a stuck message.
    /// @dev Must be attempted by the message recipient.
    /// @param uniqueish A reasonably unique-ish number identifying this transaction, provided by the client. Must be unique across messages with the same sender-recipient-amount combination.
    /// @param index `gasleft()` at the point where the original message ID has been computed.
    /// @param sender Sender's address on the Reactive Network side.
    /// @param recipient Recipient's address on the destination network side.
    /// @param amount Amount of ERC20 to be bridged. 1-to-1 minus the bridging fee.
    /// @param uniqueish_2 A reasonably unique-ish number to avoid confirmation request collision with the stuck one.
    function retry(uint256 uniqueish, uint256 index, address sender, address recipient, uint256 amount, uint256 uniqueish_2) external {
        MessageId memory message = MessageId({
            tx: uniqueish,
            index: index,
            amount: amount,
            sender: sender,
            recipient: recipient
        });
        _retry(_genId(uniqueish_2), message);
    }

    // Inbox callbacks

    /// @notice Entry point for initial messages received as callback transactions from the reactive part of the bridge.
    /// @param rvm_id RVM ID (i.e., reactive contract's deployer address) injected by the reactive node.
    /// @param txh Original unique-ish number identifying the message.
    /// @param index `gasleft()` at the moment the original message ID has been computed.
    /// @param amount Amount sent.
    /// @param sender Sender address.
    /// @param recipient Recipient address.
    function initialMessage(
        address rvm_id,
        uint256 txh,
        uint256 index,
        uint256 amount,
        address sender,
        address recipient
    ) external authorizedSenderOnly rvmIdOnly(rvm_id) {
        MessageId memory message = MessageId({
            tx: txh,
            index: index,
            amount: amount,
            sender: sender,
            recipient: recipient
        });
        _processInitialMessage(_genId(txh), message);
    }

    /// @notice Entry point for the message confirmations received as callback transactions from the reactive part of the bridge.
    /// @param rvm_id RVM ID (i.e., reactive contract's deployer address) injected by the reactive node.
    /// @param submsg_id ID of the confirmation request.
    /// @param txh Original unique-ish number identifying the message.
    /// @param index `gasleft()` at the moment the original message ID has been computed.
    /// @param amount Amount sent.
    /// @param sender Sender address.
    /// @param recipient Recipient address.
    function confirm(
        address rvm_id,
        uint256 submsg_id,
        uint256 txh,
        uint256 index,
        uint256 amount,
        address sender,
        address recipient
    ) external authorizedSenderOnly rvmIdOnly(rvm_id) {
        MessageId memory message = MessageId({
            tx: txh,
            index: index,
            amount: amount,
            sender: sender,
            recipient: recipient
        });
        _processConfirmation(submsg_id, _genId(submsg_id), message);
    }

    /// @notice Entry point for message rejections received as callback transactions from the reactive part of the bridge.
    /// @param rvm_id RVM ID (i.e., reactive contract's deployer address) injected by the reactive node.
    /// @param submsg_id ID of the confirmation request.
    /// @param txh Original unique-ish number identifying the message.
    /// @param index `gasleft()` at the moment the original message ID has been computed.
    /// @param amount Amount sent.
    /// @param sender Sender address.
    /// @param recipient Recipient address.
    function reject(
        address rvm_id,
        uint256 submsg_id,
        uint256 txh,
        uint256 index,
        uint256 amount,
        address sender,
        address recipient
    ) external authorizedSenderOnly rvmIdOnly(rvm_id) {
        MessageId memory message = MessageId({
            tx: txh,
            index: index,
            amount: amount,
            sender: sender,
            recipient: recipient
        });
        _processRejection(submsg_id, message);
    }

    // Inbox transport

    /// @notice Confirmation request sending implemented as a log record intercepted by the Reactive Network.
    /// @inheritdoc AbstractBridgehead
    function _sendConfirmationRequest(uint256 submsg_id, MessageId memory id) override internal {
        emit ConfirmationRequest(
            submsg_id,
            id.tx,
            id.index,
            id.amount,
            id.sender,
            id.recipient
        );
    }

    /// @notice Delivery is from token reserves if not mintable. New tokens are minted for delivery otherwise.
    /// @inheritdoc AbstractBridgehead
    function _deliver(MessageId memory id) override internal {
        if (is_mintable) {
            try wreact.mint(id.recipient, id.amount - _computeFee(id.amount)) {
                _confirmDelivery(id);
            } catch {
                _rejectDelivery(id);
            }
        } else {
            try wreact.transfer(id.recipient, id.amount - _computeFee(id.amount)) {
                _confirmDelivery(id);
            } catch {
                _rejectDelivery(id);
            }
        }
    }

    /// @notice Delivery confirmation sending implemented as a log record intercepted by the Reactive Network.
    /// @inheritdoc AbstractBridgehead
    function _sendDeliveryConfirmation(MessageId memory id) override internal {
        emit DeliveryConfirmation(
            id.tx,
            id.index,
            id.amount,
            id.sender,
            id.recipient
        );
    }

    /// @notice Delivery rejection sending implemented as a log record intercepted by the Reactive Network.
    /// @inheritdoc AbstractBridgehead
    function _sendDeliveryRejection(MessageId memory id) override internal {
        emit DeliveryRejection(
            id.tx,
            id.index,
            id.amount,
            id.sender,
            id.recipient
        );
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

/// @notice Computes the next collision resistant key in message/confirmation chain from the previous one.
/// @param seed Original message ID or seed.
/// @return The next message id.
function _genId(uint256 seed) pure returns (uint256) {
    return uint256(keccak256(abi.encode(seed)));
}