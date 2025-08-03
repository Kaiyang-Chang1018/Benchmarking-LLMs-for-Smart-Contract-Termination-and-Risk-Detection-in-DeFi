// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "openzeppelin/token/ERC721/IERC721Receiver.sol";
import "openzeppelin/token/ERC1155/IERC1155.sol";

error MustOwnKey();
error JoinMustBeClosed();
error JoinMustBeOpen();
error OnlyFrogOwnerMayJoin();
error IncorrectPaymentAmount();
error OneFrogMustRemainLiving();
error AmountMustBeLessThan256();
error OnlyFrogOwnerOrOperatorMayClaim();
error NftMustBeKingFrog();
error OnlyOperatorMayPerformThisAction();
error FrogHasAlreadyJoined(uint256 id);
error TransferFailed();
error NoPendingWithdrawal();
error ExceededMaxBatchLimit();

contract Game is IERC721Receiver {
    // Associated contracts and addresses ///
    // The game operator (can control join state)
    address public operator;
    // The KingFrogs contract
    address public kingFrogAddress;
    // The DuckGod Clave contract
    address public keyAddress;

    /// Constants ///
    // @notice the item id also corresponds to the amount of lives it gives
    uint256 public constant WOOD = 1;
    uint256 public constant GOLD = 2;
    uint256 public constant JADE = 3;
    uint256 constant MAX_BATCH_SIZE = 25;

    /// Game state ///
    // Which item each frog has equipped
    mapping(uint256 => uint256) public frogsToItem;
    // Whether or not new players can join the game
    bool public joinAllowed = true;
    // The price (in wei) to join
    uint256 public joinPrice;
    // All frogs that have been staked
    mapping(uint256 => address) public frogsToOwner;
    // All frogs that have joined
    mapping(uint256 => bool) public frogsJoined;
    // All the frogs that are alive
    uint256[] public frogsAlive;
    // The lives reamining for each frog
    mapping(uint256 => uint256) public livesRemaining;
    // The amount of ETH the winner gets
    mapping(address => uint256) public pendingWithdrawals;

    /// Events ///
    event EquipmentPurchased(
        address indexed user,
        uint256 indexed item,
        uint256 indexed frogId
    );
    event FrogStaked(uint256 frogId, address indexed owner);
    event FrogJoined(uint256 frogId, address indexed owner);
    event Attack(uint256 amount, uint256 killed);

    // @param _operator The address of the operator
    // @param _kingFrogAddress The address of the KingFrogs contract
    // @param _joinPrice The price (in wei) to join the game
    // @param _keyAddress The address of the DuckGod Clave contract
    constructor(
        address _operator,
        address _kingFrogAddress,
        address _keyAddress,
        uint256 _joinPrice
    ) {
        operator = _operator;
        kingFrogAddress = _kingFrogAddress;
        keyAddress = _keyAddress;
        joinPrice = _joinPrice;
    }

    // @dev purchases equipment for the battel
    // @notice you must first transfer your KingFrog to this contract
    // @notice you must own a Duck God Clave to purchase equipment
    // @notice requires the purchaser to send the correct amount of ether
    // @notice requires join to be open
    // @param item the item id (see items above)
    // @param frogId the id of the KingFrog
    function purchaseEquipment(uint256 item, uint256 frogId) external payable {
        // check if the user owns a key
        if (IERC1155(keyAddress).balanceOf(msg.sender, 0) == 0) {
            revert MustOwnKey();
        }
        // check if join is open
        if (!joinAllowed) {
            revert JoinMustBeOpen();
        }
        // check if the user owns the frog
        if (frogsToOwner[frogId] != msg.sender) {
            revert OnlyFrogOwnerMayJoin();
        }

        // user can only upgrade items
        require(frogsToItem[frogId] < item, "you may only upgrade equipment");

        // charge the join price if the user hasn't joined yet
        uint256 joinFee;
        if (!frogsJoined[frogId]) {
            joinFee = joinPrice;
        }

        if (item == WOOD) {
            require(
                msg.value == joinFee + 0.01 ether,
                "wood equipment costs 0.01 ether"
            );
        } else if (item == GOLD) {
            require(
                msg.value == joinFee + 0.025 ether,
                "gold equipment costs 0.025 ether"
            );
        } else if (item == JADE) {
            require(
                msg.value == joinFee + 0.05 ether,
                "jade equipment costs 0.05 ether"
            );
        } else {
            revert("invalid item");
        }

        emit EquipmentPurchased(msg.sender, item, frogId);
        frogsToItem[frogId] = item;

        if (!frogsJoined[frogId]) {
            _join(frogId);
        }
    }

    // @param _joinAllowed Whether or not to allow new players to join
    function setJoinOpen(bool _joinAllowed) public onlyOperator {
        joinAllowed = _joinAllowed;
    }

    // @param _joinPrice The price (in wei) to join the game
    function setJoinPrice(uint256 _joinPrice) public onlyOperator {
        joinPrice = _joinPrice;
    }

    // @param frogId The id of the frog to join
    // @notice requires join to be open
    // @notice requires the frog to be owned by the sender
    // @notice requires the sender to send the correct amount of ether
    // @notice requires the sender to own a Duck God Clave
    function join(uint256 frogId) public payable {
        if (!joinAllowed) {
            revert JoinMustBeOpen();
        }
        if (frogsToOwner[frogId] != msg.sender) {
            revert OnlyFrogOwnerMayJoin();
        }
        if (msg.value != joinPrice) {
            revert IncorrectPaymentAmount();
        }
        if (IERC1155(keyAddress).balanceOf(msg.sender, 0) == 0) {
            revert MustOwnKey();
        }
        _join(frogId);
    }

    // @param frogIds The ids of the frogs to join
    // @notice requires join to be open
    // @notice requires the sender to own a Duck God Clave
    // @notice requires the number of frogs to be less than the max batch size
    // @notice requires the sender to send the correct amount of ether
    // @notice requires the sender to own all the frogs
    function batchJoin(uint256[] calldata frogIds) public payable {
        if (!joinAllowed) {
            revert JoinMustBeOpen();
        }
        if (IERC1155(keyAddress).balanceOf(msg.sender, 0) == 0) {
            revert MustOwnKey();
        }
        if (frogIds.length > MAX_BATCH_SIZE) {
            revert ExceededMaxBatchLimit();
        }
        if (msg.value / joinPrice != frogIds.length) {
            revert IncorrectPaymentAmount();
        }
        for (uint256 i; i < frogIds.length; ) {
            if (frogsToOwner[frogIds[i]] != msg.sender) {
                revert OnlyFrogOwnerMayJoin();
            }
            unchecked {
                ++i;
            }
        }
        for (uint256 i; i < frogIds.length; ) {
            _join(frogIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    // @param frogId The id of the frog to get the lives remaining for
    function getLivesRemaining(uint256 frogId) public view returns (uint256) {
        return livesRemaining[frogId];
    }

    // @notice The operator can choose to attack the game while joining is
    //         closed, reducing the lives of random frogs until there is only
    //         one frog remaining
    // @notice Burns frogs that have no lives remaining
    // @param amount The number of frogs to attack (must be less than 256)
    function attack(uint256 amount) public onlyOperator {
        if (joinAllowed) {
            revert JoinMustBeClosed();
        }
        if (amount >= frogsAlive.length) {
            revert OneFrogMustRemainLiving();
        }
        if (amount >= 256) {
            revert AmountMustBeLessThan256();
        }

        uint256 killed;

        for (uint256 i; i < amount; ) {
            uint256 randomIndex = uint256(blockhash(block.number - i)) %
                frogsAlive.length;
            uint256 frogId = frogsAlive[randomIndex];
            uint256 newLivesRemaining = getLivesRemaining(frogId) - 1;

            if (newLivesRemaining == 0) {
                frogsAlive[randomIndex] = frogsAlive[frogsAlive.length - 1];
                frogsAlive.pop();

                // burn frog
                (bool success, ) = kingFrogAddress.call(
                    abi.encodeWithSignature("burn(uint256)", frogId)
                );

                killed += success ? 1 : 0;
            } else {
                livesRemaining[frogId] = newLivesRemaining;
            }

            unchecked {
                ++i;
            }
        }

        emit Attack(amount, killed);
    }

    // @notice 70% of the contract balance is sent to the winner, 30% is sent
    //         to the operator
    function claim() public {
        if (frogsAlive.length != 1) {
            revert OneFrogMustRemainLiving();
        }
        if (
            frogsToOwner[frogsAlive[0]] != msg.sender && msg.sender != operator
        ) {
            revert OnlyFrogOwnerOrOperatorMayClaim();
        }

        // allocate rewards
        uint256 prize = (address(this).balance * 7) / 10;
        uint256 operatorReward = address(this).balance - prize;

        pendingWithdrawals[msg.sender] += prize;
        pendingWithdrawals[operator] += operatorReward;

        // send nft back to winner
        (bool success, ) = kingFrogAddress.call(
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256)",
                address(this),
                msg.sender,
                frogsAlive[0]
            )
        );
        if (!success) {
            revert TransferFailed();
        }
    }

    // @notice Withdraws the sender's pending refund
    function withdraw() public {
        uint256 amount = pendingWithdrawals[msg.sender];
        if (amount == 0) {
            revert NoPendingWithdrawal();
        }

        // Zero the pending refund before sending
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // @notice Sending a KingFrog to this contract will stake it
    function onERC721Received(
        address,
        address from,
        uint256 id,
        bytes calldata
    ) external override returns (bytes4) {
        if (msg.sender != kingFrogAddress) {
            revert NftMustBeKingFrog();
        }
        frogsToOwner[id] = from;
        emit FrogStaked(id, from);
        return this.onERC721Received.selector;
    }

    /// Internal functions ///

    modifier onlyOperator() {
        if (msg.sender != operator) {
            revert OnlyOperatorMayPerformThisAction();
        }
        _;
    }

    function _join(uint256 frogId) private {
        if (frogsJoined[frogId]) {
            revert FrogHasAlreadyJoined(frogId);
        }
        frogsJoined[frogId] = true;
        frogsAlive.push(frogId);
        livesRemaining[frogId] = frogsToItem[frogId] + 1;
        emit FrogJoined(frogId, frogsToOwner[frogId]);
    }
}