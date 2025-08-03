// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.3
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import "./IERC721A.sol";

/**
 * @dev Interface of ERC721 token receiver.
 */
interface ERC721A__IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    )
        external
        returns (bytes4);
}

/**
 * @title ERC721A
 *
 * @dev Implementation of the [ERC721](https://eips.ethereum.org/EIPS/eip-721)
 * Non-Fungible Token Standard, including the Metadata extension.
 * Optimized for lower gas during batch mints.
 *
 * Token IDs are minted in sequential order (e.g. 0, 1, 2, 3, ...)
 * starting from `_startTokenId()`.
 *
 * Assumptions:
 *
 * - An owner cannot have more than 2**64 - 1 (max value of uint64) of supply.
 * - The maximum token ID cannot exceed 2**256 - 1 (max value of uint256).
 */
contract ERC721A is IERC721A {
    // Bypass for a `--via-ir` bug (https://github.com/chiru-labs/ERC721A/pull/364).
    struct TokenApprovalRef {
        address value;
    }

    // =============================================================
    //                           CONSTANTS
    // =============================================================

    // Mask of an entry in packed address data.
    uint256 private constant _BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;

    // The bit position of `numberMinted` in packed address data.
    uint256 private constant _BITPOS_NUMBER_MINTED = 64;

    // The bit position of `numberBurned` in packed address data.
    uint256 private constant _BITPOS_NUMBER_BURNED = 128;

    // The bit position of `aux` in packed address data.
    uint256 private constant _BITPOS_AUX = 192;

    // Mask of all 256 bits in packed address data except the 64 bits for `aux`.
    uint256 private constant _BITMASK_AUX_COMPLEMENT = (1 << 192) - 1;

    // The bit position of `startTimestamp` in packed ownership.
    uint256 private constant _BITPOS_START_TIMESTAMP = 160;

    // The bit mask of the `burned` bit in packed ownership.
    uint256 private constant _BITMASK_BURNED = 1 << 224;

    // The bit position of the `nextInitialized` bit in packed ownership.
    uint256 private constant _BITPOS_NEXT_INITIALIZED = 225;

    // The bit mask of the `nextInitialized` bit in packed ownership.
    uint256 private constant _BITMASK_NEXT_INITIALIZED = 1 << 225;

    // The bit position of `extraData` in packed ownership.
    uint256 private constant _BITPOS_EXTRA_DATA = 232;

    // Mask of all 256 bits in a packed ownership except the 24 bits for `extraData`.
    uint256 private constant _BITMASK_EXTRA_DATA_COMPLEMENT = (1 << 232) - 1;

    // The mask of the lower 160 bits for addresses.
    uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;

    // The maximum `quantity` that can be minted with {_mintERC2309}.
    // This limit is to prevent overflows on the address data entries.
    // For a limit of 5000, a total of 3.689e15 calls to {_mintERC2309}
    // is required to cause an overflow, which is unrealistic.
    uint256 private constant _MAX_MINT_ERC2309_QUANTITY_LIMIT = 5000;

    // The `Transfer` event signature is given by:
    // `keccak256(bytes("Transfer(address,address,uint256)"))`.
    bytes32 private constant _TRANSFER_EVENT_SIGNATURE =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

    // =============================================================
    //                            STORAGE
    // =============================================================

    // The next token ID to be minted.
    uint256 private _currentIndex;

    // The number of tokens burned.
    uint256 private _burnCounter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to ownership details
    // An empty struct value does not necessarily mean the token is unowned.
    // See {_packedOwnershipOf} implementation for details.
    //
    // Bits Layout:
    // - [0..159]   `addr`
    // - [160..223] `startTimestamp`
    // - [224]      `burned`
    // - [225]      `nextInitialized`
    // - [232..255] `extraData`
    mapping(uint256 => uint256) private _packedOwnerships;

    // Mapping owner address to address data.
    //
    // Bits Layout:
    // - [0..63]    `balance`
    // - [64..127]  `numberMinted`
    // - [128..191] `numberBurned`
    // - [192..255] `aux`
    mapping(address => uint256) private _packedAddressData;

    // Mapping from token ID to approved address.
    mapping(uint256 => TokenApprovalRef) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    // =============================================================
    //                   TOKEN COUNTING OPERATIONS
    // =============================================================

    /**
     * @dev Returns the starting token ID.
     * To change the starting token ID, please override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 1;
    }

    /**
     * @dev Returns the next token ID to be minted.
     */
    function _nextTokenId() internal view virtual returns (uint256) {
        return _currentIndex;
    }

    /**
     * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     * To get the total number of tokens minted, please see {_totalMinted}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        // Counter underflow is impossible as _burnCounter cannot be incremented
        // more than `_currentIndex - _startTokenId()` times.
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    /**
     * @dev Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view virtual returns (uint256) {
        // Counter underflow is impossible as `_currentIndex` does not decrement,
        // and it is initialized to `_startTokenId()`.
        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

    /**
     * @dev Returns the total number of tokens burned.
     */
    function _totalBurned() internal view virtual returns (uint256) {
        return _burnCounter;
    }

    // =============================================================
    //                    ADDRESS DATA OPERATIONS
    // =============================================================

    /**
     * @dev Returns the number of tokens in `owner`'s account.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return _packedAddressData[owner] & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * Returns the number of tokens minted by `owner`.
     */
    function _numberMinted(address owner) internal view returns (uint256) {
        return (_packedAddressData[owner] >> _BITPOS_NUMBER_MINTED) & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * Returns the number of tokens burned by or on behalf of `owner`.
     */
    function _numberBurned(address owner) internal view returns (uint256) {
        return (_packedAddressData[owner] >> _BITPOS_NUMBER_BURNED) & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * Returns the auxiliary data for `owner`. (e.g. number of whitelist mint slots used).
     */
    function _getAux(address owner) internal view returns (uint64) {
        return uint64(_packedAddressData[owner] >> _BITPOS_AUX);
    }

    /**
     * Sets the auxiliary data for `owner`. (e.g. number of whitelist mint slots used).
     * If there are multiple variables, please pack them into a uint64.
     */
    function _setAux(address owner, uint64 aux) internal virtual {
        uint256 packed = _packedAddressData[owner];
        uint256 auxCasted;
        // Cast `aux` with assembly to avoid redundant masking.
        assembly {
            auxCasted := aux
        }
        packed = (packed & _BITMASK_AUX_COMPLEMENT) | (auxCasted << _BITPOS_AUX);
        _packedAddressData[owner] = packed;
    }

    // =============================================================
    //                            IERC165
    // =============================================================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        // The interface IDs are constants representing the first 4 bytes
        // of the XOR of all function selectors in the interface.
        // See: [ERC165](https://eips.ethereum.org/EIPS/eip-165)
        // (e.g. `bytes4(i.functionA.selector ^ i.functionB.selector ^ ...)`)
        return interfaceId == 0x01ffc9a7 // ERC165 interface ID for ERC165.
            || interfaceId == 0x80ac58cd // ERC165 interface ID for ERC721.
            || interfaceId == 0x5b5e139f; // ERC165 interface ID for ERC721Metadata.
    }

    // =============================================================
    //                        IERC721Metadata
    // =============================================================

    /**
     * @dev Returns the token collection name.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256) public view virtual override returns (string memory) {
        return "";
    }

    // =============================================================
    //                     OWNERSHIPS OPERATIONS
    // =============================================================

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return address(uint160(_packedOwnershipOf(tokenId)));
    }

    /**
     * @dev Gas spent here starts off proportional to the maximum mint batch size.
     * It gradually moves to O(1) as tokens get transferred around over time.
     */
    function _ownershipOf(uint256 tokenId) internal view virtual returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnershipOf(tokenId));
    }

    /**
     * @dev Returns the unpacked `TokenOwnership` struct at `index`.
     */
    function _ownershipAt(uint256 index) internal view virtual returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnerships[index]);
    }

    /**
     * @dev Initializes the ownership slot minted at `index` for efficiency purposes.
     */
    function _initializeOwnershipAt(uint256 index) internal virtual {
        if (_packedOwnerships[index] == 0) {
            _packedOwnerships[index] = _packedOwnershipOf(index);
        }
    }

    /**
     * Returns the packed ownership data of `tokenId`.
     */
    function _packedOwnershipOf(uint256 tokenId) private view returns (uint256) {
        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr) {
                if (curr < _currentIndex) {
                    uint256 packed = _packedOwnerships[curr];
                    // If not burned.
                    if (packed & _BITMASK_BURNED == 0) {
                        // Invariant:
                        // There will always be an initialized ownership slot
                        // (i.e. `ownership.addr != address(0) && ownership.burned == false`)
                        // before an unintialized ownership slot
                        // (i.e. `ownership.addr == address(0) && ownership.burned == false`)
                        // Hence, `curr` will not underflow.
                        //
                        // We can directly compare the packed value.
                        // If the address is zero, packed will be zero.
                        while (packed == 0) {
                            packed = _packedOwnerships[--curr];
                        }
                        return packed;
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

    /**
     * @dev Returns the unpacked `TokenOwnership` struct from `packed`.
     */
    function _unpackedOwnership(uint256 packed) private pure returns (TokenOwnership memory ownership) {
        ownership.addr = address(uint160(packed));
        ownership.startTimestamp = uint64(packed >> _BITPOS_START_TIMESTAMP);
        ownership.burned = packed & _BITMASK_BURNED != 0;
        ownership.extraData = uint24(packed >> _BITPOS_EXTRA_DATA);
    }

    /**
     * @dev Packs ownership data into a single uint256.
     */
    function _packOwnershipData(address owner, uint256 flags) private view returns (uint256 result) {
        assembly {
            // Mask `owner` to the lower 160 bits, in case the upper bits somehow aren't clean.
            owner := and(owner, _BITMASK_ADDRESS)
            // `owner | (block.timestamp << _BITPOS_START_TIMESTAMP) | flags`.
            result := or(owner, or(shl(_BITPOS_START_TIMESTAMP, timestamp()), flags))
        }
    }

    /**
     * @dev Returns the `nextInitialized` flag set if `quantity` equals 1.
     */
    function _nextInitializedFlag(uint256 quantity) private pure returns (uint256 result) {
        // For branchless setting of the `nextInitialized` flag.
        assembly {
            // `(quantity == 1) << _BITPOS_NEXT_INITIALIZED`.
            result := shl(_BITPOS_NEXT_INITIALIZED, eq(quantity, 1))
        }
    }

    // =============================================================
    //                      APPROVAL OPERATIONS
    // =============================================================

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the
     * zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) public payable virtual override {
        address owner = ownerOf(tokenId);

        if (_msgSenderERC721A() != owner) {
            if (!isApprovedForAll(owner, _msgSenderERC721A())) {
                revert ApprovalCallerNotOwnerNorApproved();
            }
        }

        _tokenApprovals[tokenId].value = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId].value;
    }

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom}
     * for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _operatorApprovals[_msgSenderERC721A()][operator] = approved;
        emit ApprovalForAll(_msgSenderERC721A(), operator, approved);
    }

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted. See {_mint}.
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _startTokenId() <= tokenId && tokenId < _currentIndex // If within bounds,
            && _packedOwnerships[tokenId] & _BITMASK_BURNED == 0; // and not burned.
    }

    /**
     * @dev Returns whether `msgSender` is equal to `approvedAddress` or `owner`.
     */
    function _isSenderApprovedOrOwner(
        address approvedAddress,
        address owner,
        address msgSender
    )
        private
        pure
        returns (bool result)
    {
        assembly {
            // Mask `owner` to the lower 160 bits, in case the upper bits somehow aren't clean.
            owner := and(owner, _BITMASK_ADDRESS)
            // Mask `msgSender` to the lower 160 bits, in case the upper bits somehow aren't clean.
            msgSender := and(msgSender, _BITMASK_ADDRESS)
            // `msgSender == owner || msgSender == approvedAddress`.
            result := or(eq(msgSender, owner), eq(msgSender, approvedAddress))
        }
    }

    /**
     * @dev Returns the storage slot and value for the approved address of `tokenId`.
     */
    function _getApprovedSlotAndAddress(uint256 tokenId)
        private
        view
        returns (uint256 approvedAddressSlot, address approvedAddress)
    {
        TokenApprovalRef storage tokenApproval = _tokenApprovals[tokenId];
        // The following is equivalent to `approvedAddress = _tokenApprovals[tokenId].value`.
        assembly {
            approvedAddressSlot := tokenApproval.slot
            approvedAddress := sload(approvedAddressSlot)
        }
    }

    // =============================================================
    //                      TRANSFER OPERATIONS
    // =============================================================

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) public payable virtual override {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        if (address(uint160(prevOwnershipPacked)) != from) revert TransferFromIncorrectOwner();

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

        // The nested ifs save around 20+ gas over a compound boolean condition.
        if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSenderERC721A())) {
            if (!isApprovedForAll(from, _msgSenderERC721A())) revert TransferCallerNotOwnerNorApproved();
        }

        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner.
        assembly {
            if approvedAddress {
                // This is equivalent to `delete _tokenApprovals[tokenId]`.
                sstore(approvedAddressSlot, 0)
            }
        }

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as `tokenId` would have to be 2**256.
        unchecked {
            // We can directly increment and decrement the balances.
            --_packedAddressData[from]; // Updates: `balance -= 1`.
            ++_packedAddressData[to]; // Updates: `balance += 1`.

            // Updates:
            // - `address` to the next owner.
            // - `startTimestamp` to the timestamp of transfering.
            // - `burned` to `false`.
            // - `nextInitialized` to `true`.
            _packedOwnerships[tokenId] =
                _packOwnershipData(to, _BITMASK_NEXT_INITIALIZED | _nextExtraData(from, to, prevOwnershipPacked));

            // If the next slot may not have been initialized (i.e. `nextInitialized == false`) .
            if (prevOwnershipPacked & _BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                // If the next slot's address is zero and not burned (i.e. packed value is zero).
                if (_packedOwnerships[nextTokenId] == 0) {
                    // If the next slot is within bounds.
                    if (nextTokenId != _currentIndex) {
                        // Initialize the next slot to maintain correctness for `ownerOf(tokenId + 1)`.
                        _packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev Equivalent to `safeTransferFrom(from, to, tokenId, '')`.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public payable virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement
     * {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    )
        public
        payable
        virtual
        override
    {
        transferFrom(from, to, tokenId);
        if (to.code.length != 0) {
            if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
                revert TransferToNonERC721ReceiverImplementer();
            }
        }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token IDs
     * are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * `startTokenId` - the first token ID to be transferred.
     * `quantity` - the amount to be transferred.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal virtual { }

    /**
     * @dev Hook that is called after a set of serially-ordered token IDs
     * have been transferred. This includes minting.
     * And also called after one token has been burned.
     *
     * `startTokenId` - the first token ID to be transferred.
     * `quantity` - the amount to be transferred.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal virtual { }

    /**
     * @dev Private function to invoke {IERC721Receiver-onERC721Received} on a target contract.
     *
     * `from` - Previous owner of the given token ID.
     * `to` - Target address that will receive the token.
     * `tokenId` - Token ID to be transferred.
     * `_data` - Optional data to send along with the call.
     *
     * Returns whether the call correctly returned the expected magic value.
     */
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    )
        private
        returns (bool)
    {
        try ERC721A__IERC721Receiver(to).onERC721Received(_msgSenderERC721A(), from, tokenId, _data) returns (
            bytes4 retval
        ) {
            return retval == ERC721A__IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    // =============================================================
    //                        MINT OPERATIONS
    // =============================================================

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event for each mint.
     */
    function _mint(address to, uint256 quantity) internal virtual {
        uint256 startTokenId = _currentIndex;
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // `balance` and `numberMinted` have a maximum limit of 2**64.
        // `tokenId` has a maximum limit of 2**256.
        unchecked {
            // Updates:
            // - `balance += quantity`.
            // - `numberMinted += quantity`.
            //
            // We can directly add to the `balance` and `numberMinted`.
            _packedAddressData[to] += quantity * ((1 << _BITPOS_NUMBER_MINTED) | 1);

            // Updates:
            // - `address` to the owner.
            // - `startTimestamp` to the timestamp of minting.
            // - `burned` to `false`.
            // - `nextInitialized` to `quantity == 1`.
            _packedOwnerships[startTokenId] =
                _packOwnershipData(to, _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0));

            uint256 toMasked;
            uint256 end = startTokenId + quantity;

            // Use assembly to loop and emit the `Transfer` event for gas savings.
            // The duplicated `log4` removes an extra check and reduces stack juggling.
            // The assembly, together with the surrounding Solidity code, have been
            // delicately arranged to nudge the compiler into producing optimized opcodes.
            assembly {
                // Mask `to` to the lower 160 bits, in case the upper bits somehow aren't clean.
                toMasked := and(to, _BITMASK_ADDRESS)
                // Emit the `Transfer` event.
                log4(
                    0, // Start of data (0, since no data).
                    0, // End of data (0, since no data).
                    _TRANSFER_EVENT_SIGNATURE, // Signature.
                    0, // `address(0)`.
                    toMasked, // `to`.
                    startTokenId // `tokenId`.
                )

                // The `iszero(eq(,))` check ensures that large values of `quantity`
                // that overflows uint256 will make the loop run out of gas.
                // The compiler will optimize the `iszero` away for performance.
                for { let tokenId := add(startTokenId, 1) } iszero(eq(tokenId, end)) { tokenId := add(tokenId, 1) } {
                    // Emit the `Transfer` event. Similar to above.
                    log4(0, 0, _TRANSFER_EVENT_SIGNATURE, 0, toMasked, tokenId)
                }
            }
            if (toMasked == 0) revert MintToZeroAddress();

            _currentIndex = end;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * This function is intended for efficient minting only during contract creation.
     *
     * It emits only one {ConsecutiveTransfer} as defined in
     * [ERC2309](https://eips.ethereum.org/EIPS/eip-2309),
     * instead of a sequence of {Transfer} event(s).
     *
     * Calling this function outside of contract creation WILL make your contract
     * non-compliant with the ERC721 standard.
     * For full ERC721 compliance, substituting ERC721 {Transfer} event(s) with the ERC2309
     * {ConsecutiveTransfer} event is only permissible during contract creation.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {ConsecutiveTransfer} event.
     */
    function _mintERC2309(address to, uint256 quantity) internal virtual {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();
        if (quantity > _MAX_MINT_ERC2309_QUANTITY_LIMIT) revert MintERC2309QuantityExceedsLimit();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are unrealistic due to the above check for `quantity` to be below the limit.
        unchecked {
            // Updates:
            // - `balance += quantity`.
            // - `numberMinted += quantity`.
            //
            // We can directly add to the `balance` and `numberMinted`.
            _packedAddressData[to] += quantity * ((1 << _BITPOS_NUMBER_MINTED) | 1);

            // Updates:
            // - `address` to the owner.
            // - `startTimestamp` to the timestamp of minting.
            // - `burned` to `false`.
            // - `nextInitialized` to `quantity == 1`.
            _packedOwnerships[startTokenId] =
                _packOwnershipData(to, _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0));

            emit ConsecutiveTransfer(startTokenId, startTokenId + quantity - 1, address(0), to);

            _currentIndex = startTokenId + quantity;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Safely mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement
     * {IERC721Receiver-onERC721Received}, which is called for each safe transfer.
     * - `quantity` must be greater than 0.
     *
     * See {_mint}.
     *
     * Emits a {Transfer} event for each mint.
     */
    function _safeMint(address to, uint256 quantity, bytes memory _data) internal virtual {
        _mint(to, quantity);

        unchecked {
            if (to.code.length != 0) {
                uint256 end = _currentIndex;
                uint256 index = end - quantity;
                do {
                    if (!_checkContractOnERC721Received(address(0), to, index++, _data)) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (index < end);
                // Reentrancy protection.
                if (_currentIndex != end) revert();
            }
        }
    }

    /**
     * @dev Equivalent to `_safeMint(to, quantity, '')`.
     */
    function _safeMint(address to, uint256 quantity) internal virtual {
        _safeMint(to, quantity, "");
    }

    // =============================================================
    //                        BURN OPERATIONS
    // =============================================================

    /**
     * @dev Equivalent to `_burn(tokenId, false)`.
     */
    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        address from = address(uint160(prevOwnershipPacked));

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

        if (approvalCheck) {
            // The nested ifs save around 20+ gas over a compound boolean condition.
            if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSenderERC721A())) {
                if (!isApprovedForAll(from, _msgSenderERC721A())) revert TransferCallerNotOwnerNorApproved();
            }
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        // Clear approvals from the previous owner.
        assembly {
            if approvedAddress {
                // This is equivalent to `delete _tokenApprovals[tokenId]`.
                sstore(approvedAddressSlot, 0)
            }
        }

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as `tokenId` would have to be 2**256.
        unchecked {
            // Updates:
            // - `balance -= 1`.
            // - `numberBurned += 1`.
            //
            // We can directly decrement the balance, and increment the number burned.
            // This is equivalent to `packed -= 1; packed += 1 << _BITPOS_NUMBER_BURNED;`.
            _packedAddressData[from] += (1 << _BITPOS_NUMBER_BURNED) - 1;

            // Updates:
            // - `address` to the last owner.
            // - `startTimestamp` to the timestamp of burning.
            // - `burned` to `true`.
            // - `nextInitialized` to `true`.
            _packedOwnerships[tokenId] = _packOwnershipData(
                from,
                (_BITMASK_BURNED | _BITMASK_NEXT_INITIALIZED) | _nextExtraData(from, address(0), prevOwnershipPacked)
            );

            // If the next slot may not have been initialized (i.e. `nextInitialized == false`) .
            if (prevOwnershipPacked & _BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                // If the next slot's address is zero and not burned (i.e. packed value is zero).
                if (_packedOwnerships[nextTokenId] == 0) {
                    // If the next slot is within bounds.
                    if (nextTokenId != _currentIndex) {
                        // Initialize the next slot to maintain correctness for `ownerOf(tokenId + 1)`.
                        _packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        // Overflow not possible, as _burnCounter cannot be exceed _currentIndex times.
        unchecked {
            _burnCounter++;
        }
    }

    // =============================================================
    //                     EXTRA DATA OPERATIONS
    // =============================================================

    /**
     * @dev Directly sets the extra data for the ownership data `index`.
     */
    function _setExtraDataAt(uint256 index, uint24 extraData) internal virtual {
        uint256 packed = _packedOwnerships[index];
        if (packed == 0) revert OwnershipNotInitializedForExtraData();
        uint256 extraDataCasted;
        // Cast `extraData` with assembly to avoid redundant masking.
        assembly {
            extraDataCasted := extraData
        }
        packed = (packed & _BITMASK_EXTRA_DATA_COMPLEMENT) | (extraDataCasted << _BITPOS_EXTRA_DATA);
        _packedOwnerships[index] = packed;
    }

    /**
     * @dev Called during each token transfer to set the 24bit `extraData` field.
     * Intended to be overridden by the cosumer contract.
     *
     * `previousExtraData` - the value of `extraData` before transfer.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _extraData(address from, address to, uint24 previousExtraData) internal view virtual returns (uint24) { }

    /**
     * @dev Returns the next extra data for the packed ownership data.
     * The returned result is shifted into position.
     */
    function _nextExtraData(address from, address to, uint256 prevOwnershipPacked) private view returns (uint256) {
        uint24 extraData = uint24(prevOwnershipPacked >> _BITPOS_EXTRA_DATA);
        return uint256(_extraData(from, to, extraData)) << _BITPOS_EXTRA_DATA;
    }

    // =============================================================
    //                       OTHER OPERATIONS
    // =============================================================

    /**
     * @dev Returns the message sender (defaults to `msg.sender`).
     *
     * If you are writing GSN compatible contracts, you need to override this function.
     */
    function _msgSenderERC721A() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @dev Converts a uint256 to its ASCII string decimal representation.
     */
    function _toString(uint256 value) internal pure virtual returns (string memory str) {
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits. Total: 5 * 0x20 = 0xa0.
            let m := add(mload(0x40), 0xa0)
            // Update the free memory pointer to allocate.
            mstore(0x40, m)
            // Assign the `str` to the end.
            str := sub(m, 0x20)
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 { } {
                str := sub(str, 1)
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                // prettier-ignore
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.3
// Creator: Chiru Labs

pragma solidity ^0.8.4;

/**
 * @dev Interface of ERC721A.
 */
interface IERC721A {
    /**
     * The caller must own the token or be an approved operator.
     */
    error ApprovalCallerNotOwnerNorApproved();

    /**
     * The token does not exist.
     */
    error ApprovalQueryForNonexistentToken();

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The token does not exist.
     */
    error OwnerQueryForNonexistentToken();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the
     * ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * The token does not exist.
     */
    error URIQueryForNonexistentToken();

    /**
     * The `quantity` minted with ERC2309 exceeds the safety limit.
     */
    error MintERC2309QuantityExceedsLimit();

    /**
     * The `extraData` cannot be set on an unintialized ownership slot.
     */
    error OwnershipNotInitializedForExtraData();

    // =============================================================
    //                            STRUCTS
    // =============================================================

    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Stores the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
        // Arbitrary data similar to `startTimestamp` that can be set via {_extraData}.
        uint24 extraData;
    }

    // =============================================================
    //                         TOKEN COUNTERS
    // =============================================================

    /**
     * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     * To get the total number of tokens minted, please see {_totalMinted}.
     */
    function totalSupply() external view returns (uint256);

    // =============================================================
    //                            IERC165
    // =============================================================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    // =============================================================
    //                            IERC721
    // =============================================================

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables
     * (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in `owner`'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`,
     * checking first that contract recipients are aware of the ERC721 protocol
     * to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move
     * this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement
     * {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external payable;

    /**
     * @dev Equivalent to `safeTransferFrom(from, to, tokenId, '')`.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom}
     * whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the
     * zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external payable;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom}
     * for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // =============================================================
    //                        IERC721Metadata
    // =============================================================

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    // =============================================================
    //                           IERC2309
    // =============================================================

    /**
     * @dev Emitted when tokens in `fromTokenId` to `toTokenId`
     * (inclusive) is transferred from `from` to `to`, as defined in the
     * [ERC2309](https://eips.ethereum.org/EIPS/eip-2309) standard.
     *
     * See {_mintERC2309} for more details.
     */
    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Base64.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides a set of functions to operate with Base64 strings.
 *
 * _Available since v4.5._
 */
library Base64 {
    /**
     * @dev Base64 Encoding/Decoding Table
     */
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /**
     * @dev Converts a `bytes` to its Bytes64 `string` representation.
     */
    function encode(bytes memory data) internal pure returns (string memory) {
        /**
         * Inspired by Brecht Devos (Brechtpd) implementation - MIT licence
         * https://github.com/Brechtpd/base64/blob/e78d9fd951e7b0977ddca77d92dc85183770daf4/base64.sol
         */
        if (data.length == 0) return "";

        // Loads the table into memory
        string memory table = _TABLE;

        // Encoding takes 3 bytes chunks of binary data from `bytes` data parameter
        // and split into 4 numbers of 6 bits.
        // The final Base64 length should be `bytes` data length multiplied by 4/3 rounded up
        // - `data.length + 2`  -> Round up
        // - `/ 3`              -> Number of 3-bytes chunks
        // - `4 *`              -> 4 characters for each chunk
        string memory result = new string(4 * ((data.length + 2) / 3));

        /// @solidity memory-safe-assembly
        assembly {
            // Prepare the lookup table (skip the first "length" byte)
            let tablePtr := add(table, 1)

            // Prepare result pointer, jump over length
            let resultPtr := add(result, 32)

            // Run over the input, 3 bytes at a time
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                // Advance 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // To write each character, shift the 3 bytes (18 bits) chunk
                // 4 times in blocks of 6 bits for each character (18, 12, 6, 0)
                // and apply logical AND with 0x3F which is the number of
                // the previous character in the ASCII table prior to the Base64 Table
                // The result is then added to the table to get the character to write,
                // and finally write it in the result pointer but with a left shift
                // of 256 (1 byte) - 8 (1 ASCII char) = 248 bits

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            // When data `bytes` is not exactly 3 bytes long
            // it is padded with `=` characters at the end
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
    }
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
pragma solidity >=0.8.17 .0;

interface NFTEventsAndErrors {
  error AlreadyCommenced();
  error PublicMintNotEnabled();
  error AllowListMintCapPerWalletExceeded();
  error AllowListMintCapExceeded();
  error PublicMintMaxPerTransactionExceeded();
  error MintNotStarted();
  error MaxSupplyReached();
  error IncorrectPayment();
  error MsgSenderDoesNotOwnXXYYZZToken();
  error MsgSenderNotTokenOwner();
  event MetadataUpdate(uint256 tokenId);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17 .0;

import { ERC721A } from "@erc721a/ERC721A.sol";
import { NFTEventsAndErrors } from "./NFTEventsAndErrors.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { IERC2981 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import { IERC721 } from "@openzeppelin/contracts/interfaces/IERC721.sol";
import { Utils } from "./utils/Utils.sol";
import { Constants } from "./utils/Constants.sol";
import { ColorfulArt } from "./utils/ColorfulArt.sol";
import { LibString } from "./utils/LibString.sol";
import { AllowList } from "./utils/AllowList.sol";

/// @title Together NFT
/// @author Aspyn Palatnick (aspyn.eth, stuckinaboot.eth)
/// @notice Together is an onchain NFT where the art of each token builds on the art of all previous tokens.
contract Together is ColorfulArt, ERC721A, NFTEventsAndErrors, Constants, AllowList {
  using LibString for uint256;

  bool public publicMintEnabled;
  uint16 internal immutable _allowListMintMaxTotal;
  uint8 internal immutable _allowListMintMaxPerWallet;
  mapping(address user => uint8 minted) internal _allowListMinted;

  constructor(
    bytes32 allowListMerkleRoot,
    uint16 allowListMintMaxTotalVal,
    uint8 allowListMintMaxPerWalletVal
  ) AllowList(allowListMerkleRoot) ERC721A("Together", "TGR") {
    _allowListMintMaxTotal = allowListMintMaxTotalVal;
    _allowListMintMaxPerWallet = allowListMintMaxPerWalletVal;
  }

  // Commence

  /// @notice Update public mint enabled.
  function updatePublicMintEnabled(bool _publicMintEnabled) external onlyOwner {
    publicMintEnabled = _publicMintEnabled;
  }

  function commence() external onlyOwner {
    // Checks

    // Check if already commenced
    if (commenced) {
      revert AlreadyCommenced();
    }

    // Effects

    // Update commenced to be true
    commenced = true;

    // Mint initial tokens
    _coreMint(msg.sender, _MINT_AMOUNT_DURING_COMMENCE);
  }

  // Mint

  function _coreMint(address to, uint8 amount) internal {
    // Checks
    if (!commenced) {
      // Check mint has started
      revert MintNotStarted();
    }

    uint256 nextTokenIdToBeMinted = _nextTokenId();

    unchecked {
      if (MAX_POINTS_TOTAL + 1 < nextTokenIdToBeMinted + amount) {
        // Check max supply not exceeded
        revert MaxSupplyReached();
      }
    }

    // Effects

    // Set colors
    unchecked {
      for (uint256 i = nextTokenIdToBeMinted; i < nextTokenIdToBeMinted + amount; ) {
        tokenToColor[i] = Utils.getPackedRGBColor(keccak256(abi.encodePacked(block.prevrandao, i)));
        ++i;
      }
    }

    // Perform mint
    _mint(to, amount);
  }

  /// @notice Mint tokens for allowlist minters.
  /// @param proof proof
  /// @param amount amount of tokens to mint
  function mintAllowList(bytes32[] calldata proof, uint8 amount) external payable onlyAllowListed(proof) {
    // Checks

    unchecked {
      if (amount * PRICE != msg.value) {
        // Check payment by sender is correct
        revert IncorrectPayment();
      }

      if (_totalMinted() + amount > _allowListMintMaxTotal) {
        // Check allowlist mint total is not exceeding max allowed to be minted during allowlist phase
        revert AllowListMintCapExceeded();
      }

      if (_allowListMinted[msg.sender] + amount > _allowListMintMaxPerWallet) {
        // Check wallet is not exceeding max allowed during allowlist phase
        revert AllowListMintCapPerWalletExceeded();
      }
    }

    // Effects

    // Increase allowlist minted by amount
    unchecked {
      _allowListMinted[msg.sender] += amount;
    }

    // Perform mint
    _coreMint(msg.sender, amount);
  }

  /// @notice Mint tokens.
  /// @param amount amount of tokens to mint
  function mintPublic(uint8 amount) external payable {
    // Checks
    if (!publicMintEnabled) {
      // Check public mint enabled
      revert PublicMintNotEnabled();
    }

    if (amount > _MAX_PUBLIC_MINT_AMOUNT_PER_TRANSACTION) {
      revert PublicMintMaxPerTransactionExceeded();
    }

    unchecked {
      if (amount * PRICE != msg.value) {
        // Check payment by sender is correct
        revert IncorrectPayment();
      }
    }

    // Effects

    _coreMint(msg.sender, amount);
  }

  function _startTokenId() internal pure override returns (uint256) {
    return 1;
  }

  // Withdraw

  /// @notice Withdraw all ETH from the contract to the vault.
  function withdraw() external {
    (bool success, ) = _VAULT_ADDRESS.call{ value: address(this).balance }("");
    require(success);
  }

  // Metadata

  /// @notice Set the background color of your token.
  /// @param tokenId Together token id
  /// @param xxyyzzTokenId XXYYZZ token id (this will be what your Together
  /// token's background color is set to)
  function colorBackground(uint256 tokenId, uint24 xxyyzzTokenId) external {
    // Checks
    if (ownerOf(tokenId) != msg.sender) {
      // Revert if msg.sender does not own this token
      revert MsgSenderNotTokenOwner();
    }
    if (
      // Background color can always be reset to black
      xxyyzzTokenId != 0 &&
      // For any other color, check if msg.sender owns that xxyyzz token
      IERC721(_XXYYZZ_TOKEN_ADDRESS).ownerOf(xxyyzzTokenId) != msg.sender
    ) {
      // Revert if msg.sender is not owner of the input xxyyzz token
      revert MsgSenderDoesNotOwnXXYYZZToken();
    }

    // Effects
    // Update token background to xxyyzz token color
    tokenToBackgroundColor[tokenId] = xxyyzzTokenId;

    emit MetadataUpdate(tokenId);
  }

  function _getTraits(uint256 tokenId) internal view returns (string memory) {
    unchecked {
      uint256 innerShapePoints = tokenId % MAX_POINTS_PER_POLYGON;
      return
        string.concat(
          "[",
          Utils.getTrait("Total Points", tokenId.toString(), true, true),
          Utils.getTrait("Depth", (tokenId / MAX_POINTS_PER_POLYGON).toString(), true, true),
          Utils.getTrait(
            "Inner Shape Points",
            (innerShapePoints > 0 ? innerShapePoints : MAX_POINTS_PER_POLYGON).toString(),
            true,
            true
          ),
          Utils.getTrait("New Line Color", Utils.getRGBStr(tokenToColor[tokenId]), false, true),
          Utils.getTrait("Background Color", Utils.getRGBStr(tokenToBackgroundColor[tokenId]), false, false),
          "]"
        );
    }
  }

  /// @notice Get token uri for a particular token.
  /// @param tokenId token id
  /// @return tokenURI
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    if (!_exists(tokenId)) {
      revert URIQueryForNonexistentToken();
    }

    string memory artSvg = art(uint16(tokenId));

    return
      Utils.formatTokenURI(
        tokenId,
        Utils.svgToURI(artSvg),
        string.concat(
          "data:text/html;base64,",
          Utils.encodeBase64(
            bytes(
              string.concat(
                '<html style="overflow:hidden"><body style="margin:0">',
                artSvg,
                '<script>let a=!1,b=!1,o=Array.from(document.getElementsByTagName("line")).map(e=>e.style.stroke),s=e=>new Promise(t=>setTimeout(t,e)),c=()=>Math.floor(256*Math.random());document.body.addEventListener("click",async()=>{if(!a||b)return;b=!0;let e=document.getElementsByTagName("line");for(;a;){for(let t=0;t<e.length;t++)e[t].style.stroke=`rgb(${c()},${c()},${c()})`;await s(50)}for(let l=0;l<e.length;l++)e[l].style.stroke=o[l];b=!1},!0),document.body.addEventListener("click",async()=>{if(a)return;a=!0;let e=document.getElementsByTagName("line");for(let t=0;t<2*e.length;t++){let l=t<e.length?"0":"1",n=t<e.length?t:2*e.length-t-1;"m"!==e[n].id&&(e[n].style.strokeOpacity=l);let g=e.length%100;await s((t<e.length?t>=e.length-g:t>e.length&&t-e.length<=g)?20+(100-g)/100*75:10)}a=!1},!0);</script></body></html>'
              )
            )
          )
        ),
        _getTraits(tokenId)
      );
  }

  // Royalties

  function royaltyInfo(uint256, uint256 salePrice) external pure returns (address receiver, uint256 royaltyAmount) {
    unchecked {
      return (_VAULT_ADDRESS, (salePrice * 250) / 10_000);
    }
  }

  // IERC165

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A) returns (bool) {
    return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17.0;

import { TwoStepOwnable } from "./TwoStepOwnable.sol";

/**
 * @notice Smart contract that verifies and tracks allow list redemptions against a configurable Merkle root, up to a
 * max number configured at deploy
 */
contract AllowList is TwoStepOwnable {
    bytes32 public merkleRoot;

    error NotAllowListed();

    ///@notice Checks if msg.sender is included in AllowList, revert otherwise
    ///@param proof Merkle proof
    modifier onlyAllowListed(bytes32[] calldata proof) {
        if (!isAllowListed(proof, msg.sender)) {
            revert NotAllowListed();
        }
        _;
    }

    constructor(bytes32 _merkleRoot) {
        merkleRoot = _merkleRoot;
    }

    ///@notice set the Merkle root in the contract. OnlyOwner.
    ///@param _merkleRoot the new Merkle root
    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    ///@notice Given a Merkle proof, check if an address is AllowListed against the root
    ///@param proof Merkle proof
    ///@param data abi-encoded data to be checked against the root
    ///@return boolean isAllowListed
    function isAllowListed(bytes32[] calldata proof, bytes memory data) public view returns (bool) {
        return verifyCalldata(proof, merkleRoot, keccak256(data));
    }

    ///@notice Given a Merkle proof, check if an address is AllowListed against the root
    ///@param proof Merkle proof
    ///@param addr address to check against allow list
    ///@return boolean isAllowListed
    function isAllowListed(bytes32[] calldata proof, address addr) public view returns (bool) {
        return verifyCalldata(proof, merkleRoot, keccak256(abi.encodePacked(addr)));
    }

    /**
     * @dev Calldata version of {verify}
     * Copied from OpenZeppelin's MerkleProof.sol
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {processProof}
     * Copied from OpenZeppelin's MerkleProof.sol
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length;) {
            computedHash = _hashPair(computedHash, proof[i]);
            unchecked {
                ++i;
            }
        }
        return computedHash;
    }

    /// @dev Copied from OpenZeppelin's MerkleProof.sol
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    /// @dev Copied from OpenZeppelin's MerkleProof.sol
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17 .0;

import { Utils } from "./Utils.sol";
import { Trigonometry } from "./Trigonometry.sol";
import { svg } from "./SVG.sol";
import { LibPRNG } from "./LibPRNG.sol";
import { LibString } from "./LibString.sol";

/// @title ColorfulArt
/// @author Aspyn Palatnick (aspyn.eth, stuckinaboot.eth)
/// @notice ColorfulArt provides utility functions for creating colorful polygon art
contract ColorfulArt {
  using LibPRNG for LibPRNG.PRNG;
  using LibString for uint256;

  struct Point {
    // Scale by 1e18
    uint256 x;
    uint256 y;
  }

  uint16 internal constant MAX_POINTS_TOTAL = 1000;
  uint24[MAX_POINTS_TOTAL + 1] internal tokenToColor;
  uint24[MAX_POINTS_TOTAL + 1] internal tokenToBackgroundColor;

  uint8 internal constant MAX_POINTS_PER_POLYGON = 100;
  uint8 private constant LINE_WIDTH = 10;
  uint8 private constant MAX_RADIUS = 120;
  bool internal commenced;

  function polarToCartesian(uint256 radius, uint256 angleInDegrees) internal pure returns (Point memory) {
    int256 angleInRadians = ((int256(angleInDegrees)) * int256(Trigonometry.PI)) /
      (180.0 * 1e18) +
      // Add 2 PI to ensure radians is always positive
      int256(
        Trigonometry.TWO_PI -
          // Rotate 90 degrees counterclockwise
          Trigonometry.PI /
          2.0
      );

    return
      // Point has both x and y scaled by 1e18
      Point({
        x: uint256(
          int256(
            // Scale by 1e18
            200 * 1e18
          ) + ((int256(radius) * Trigonometry.cos(uint256(angleInRadians))))
        ),
        y: uint256(
          int256(
            // Scale by 1e18
            200 * 1e18
          ) + ((int256(radius) * Trigonometry.sin(uint256(angleInRadians))))
        )
      });
  }

  function getDecimalStringFrom1e18ScaledUint256(uint256 scaled) internal pure returns (string memory decimal) {
    uint256 partBeforeDecimal = scaled / 1e18;
    uint256 partAfterDecimal = (scaled % 1e18);
    if (partAfterDecimal > 1e17) {
      // Throw out last 12 digits, as that much precision is unnecessary and bloats the string size
      partAfterDecimal = partAfterDecimal / 1e12;
    }
    return string.concat(partBeforeDecimal.toString(), ".", partAfterDecimal.toString());
  }

  function polygon(uint256 radius, uint16 numPoints) internal pure returns (Point[] memory points) {
    points = new Point[](numPoints);

    // Degrees scaled by 1e18 for precision
    unchecked {
      uint256 degreeIncrement = (360 * 1e18) / numPoints;
      for (uint32 i; i < numPoints; ++i) {
        uint256 angleInDegrees = degreeIncrement * i;
        points[i] = polarToCartesian(radius, angleInDegrees);
      }
    }
  }

  function linesSvgFromPoints(
    Point[] memory points,
    uint16 startColorIdx,
    // This is the token id
    uint16 pointWithIdIdx
  ) internal view returns (string memory linesSvg) {
    if (points.length == 1) {
      // Return a dot in the center
      return
        svg.line(
          string.concat(
            svg.prop("x1", "200"),
            svg.prop("y1", "200"),
            svg.prop("x2", "200"),
            svg.prop("y2", "200"),
            svg.prop("stroke-linecap", "round"),
            svg.prop("stroke", Utils.getRGBStr(tokenToColor[startColorIdx])),
            svg.prop("id", "m")
          )
        );
    }

    unchecked {
      for (uint16 i; i < points.length; ++i) {
        bool isEnd = i + 1 == points.length;
        uint32 colorIdx = i + startColorIdx;
        linesSvg = string.concat(
          linesSvg,
          svg.line(
            string.concat(
              svg.prop("x1", getDecimalStringFrom1e18ScaledUint256(points[i].x)),
              svg.prop("y1", getDecimalStringFrom1e18ScaledUint256(points[i].y)),
              svg.prop("x2", getDecimalStringFrom1e18ScaledUint256(isEnd ? points[0].x : points[i + 1].x)),
              svg.prop("y2", getDecimalStringFrom1e18ScaledUint256(isEnd ? points[0].y : points[i + 1].y)),
              svg.prop("stroke", Utils.getRGBStr(tokenToColor[colorIdx])),
              pointWithIdIdx == colorIdx ? svg.prop("id", "m") : ""
            )
          )
        );
      }
    }
  }

  function art(uint16 numberOfPoints) public view returns (string memory) {
    if (!commenced) {
      return "";
    }

    string memory lines;

    unchecked {
      uint256 fullPolygonsCount = numberOfPoints / MAX_POINTS_PER_POLYGON;

      for (uint8 i; i < fullPolygonsCount; ++i) {
        Point[] memory polyPoints = polygon(MAX_RADIUS - i * LINE_WIDTH, MAX_POINTS_PER_POLYGON);
        lines = string.concat(
          lines,
          linesSvgFromPoints(polyPoints, uint16(i * MAX_POINTS_PER_POLYGON + 1), numberOfPoints)
        );
      }

      uint16 remainingPoints = numberOfPoints % MAX_POINTS_PER_POLYGON;

      if (remainingPoints > 0) {
        lines = string.concat(
          lines,
          linesSvgFromPoints(
            polygon(uint16(MAX_RADIUS - fullPolygonsCount * LINE_WIDTH), remainingPoints),
            uint16(fullPolygonsCount * MAX_POINTS_PER_POLYGON + 1),
            numberOfPoints
          )
        );
      }
    }

    return
      string.concat(
        '<svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" viewBox="0 0 400 400" style="background:',
        Utils.getRGBStr(tokenToBackgroundColor[numberOfPoints]),
        ';display:block;margin:auto"><style>line{stroke-width:10;}</style>',
        lines,
        "</svg>"
      );
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17 .0;

/// @title Constants
/// @author Aspyn Palatnick (aspyn.eth, stuckinaboot.eth)
/// @notice Constants for constructing onchain Together NFT
contract Constants {
  uint256 public constant PRICE = 0.01 ether;

  address payable internal constant _VAULT_ADDRESS = payable(address(0x39Ab90066cec746A032D67e4fe3378f16294CF6b));
  address internal constant _XXYYZZ_TOKEN_ADDRESS = address(0xFf6000a85baAc9c4854fAA7155e70BA850BF726b);
  uint8 internal constant _MINT_AMOUNT_DURING_COMMENCE = 5;
  uint8 internal constant _MAX_PUBLIC_MINT_AMOUNT_PER_TRANSACTION = 5;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for generating psuedorandom numbers.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibPRNG.sol)
library LibPRNG {
  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                          STRUCTS                           */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  /// @dev A psuedorandom number state in memory.
  struct PRNG {
    uint256 state;
  }

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                         OPERATIONS                         */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  /// @dev Seeds the `prng` with `state`.
  function seed(PRNG memory prng, bytes32 state) internal pure {
    /// @solidity memory-safe-assembly
    assembly {
      mstore(prng, state)
    }
  }

  /// @dev Returns a psuedorandom uint256, uniformly distributed
  /// between 0 (inclusive) and `upper` (exclusive).
  /// If your modulus is big, this method is recommended
  /// for uniform sampling to avoid modulo bias.
  /// For uniform sampling across all uint256 values,
  /// or for small enough moduli such that the bias is neligible,
  /// use {next} instead.
  function uniform(PRNG memory prng, uint256 upper) internal pure returns (uint256 result) {
    /// @solidity memory-safe-assembly
    assembly {
      // prettier-ignore
      for {} 1 {} {
                result := keccak256(prng, 0x20)
                mstore(prng, result)
                // prettier-ignore
                if iszero(lt(result, mod(sub(0, upper), upper))) { break }
            }
      result := mod(result, upper)
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for converting numbers into strings and other string operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibString.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)
library LibString {
  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                        CUSTOM ERRORS                       */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  /// @dev The `length` of the output is too small to contain all the hex digits.
  error HexLengthInsufficient();

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                         CONSTANTS                          */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  /// @dev The constant returned when the `search` is not found in the string.
  uint256 internal constant NOT_FOUND = type(uint256).max;

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                     DECIMAL OPERATIONS                     */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  /// @dev Returns the base 10 decimal representation of `value`.
  function toString(uint256 value) internal pure returns (string memory str) {
    /// @solidity memory-safe-assembly
    assembly {
      // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
      // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
      // We will need 1 word for the trailing zeros padding, 1 word for the length,
      // and 3 words for a maximum of 78 digits.
      str := add(mload(0x40), 0x80)
      // Update the free memory pointer to allocate.
      mstore(0x40, add(str, 0x20))
      // Zeroize the slot after the string.
      mstore(str, 0)

      // Cache the end of the memory to calculate the length later.
      let end := str

      let w := not(0) // Tsk.
      // We write the string from rightmost digit to leftmost digit.
      // The following is essentially a do-while loop that also handles the zero case.
      for {
        let temp := value
      } 1 {

      } {
        str := add(str, w) // `sub(str, 1)`.
        // Write the character to the pointer.
        // The ASCII index of the '0' character is 48.
        mstore8(str, add(48, mod(temp, 10)))
        // Keep dividing `temp` until zero.
        temp := div(temp, 10)
        if iszero(temp) {
          break
        }
      }

      let length := sub(end, str)
      // Move the pointer 32 bytes leftwards to make room for the length.
      str := sub(str, 0x20)
      // Store the length.
      mstore(str, length)
    }
  }

  /// @dev Returns the base 10 decimal representation of `value`.
  function toString(int256 value) internal pure returns (string memory str) {
    if (value >= 0) {
      return toString(uint256(value));
    }
    unchecked {
      str = toString(uint256(-value));
    }
    /// @solidity memory-safe-assembly
    assembly {
      // We still have some spare memory space on the left,
      // as we have allocated 3 words (96 bytes) for up to 78 digits.
      let length := mload(str) // Load the string length.
      mstore(str, 0x2d) // Store the '-' character.
      str := sub(str, 1) // Move back the string pointer by a byte.
      mstore(str, add(length, 1)) // Update the string length.
    }
  }

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                   HEXADECIMAL OPERATIONS                   */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  /// @dev Returns the hexadecimal representation of `value`,
  /// left-padded to an input length of `length` bytes.
  /// The output is prefixed with "0x" encoded using 2 hexadecimal digits per byte,
  /// giving a total length of `length * 2 + 2` bytes.
  /// Reverts if `length` is too small for the output to contain all the digits.
  function toHexString(uint256 value, uint256 length) internal pure returns (string memory str) {
    str = toHexStringNoPrefix(value, length);
    /// @solidity memory-safe-assembly
    assembly {
      let strLength := add(mload(str), 2) // Compute the length.
      mstore(str, 0x3078) // Write the "0x" prefix.
      str := sub(str, 2) // Move the pointer.
      mstore(str, strLength) // Write the length.
    }
  }

  /// @dev Returns the hexadecimal representation of `value`,
  /// left-padded to an input length of `length` bytes.
  /// The output is prefixed with "0x" encoded using 2 hexadecimal digits per byte,
  /// giving a total length of `length * 2` bytes.
  /// Reverts if `length` is too small for the output to contain all the digits.
  function toHexStringNoPrefix(uint256 value, uint256 length) internal pure returns (string memory str) {
    /// @solidity memory-safe-assembly
    assembly {
      // We need 0x20 bytes for the trailing zeros padding, `length * 2` bytes
      // for the digits, 0x02 bytes for the prefix, and 0x20 bytes for the length.
      // We add 0x20 to the total and round down to a multiple of 0x20.
      // (0x20 + 0x20 + 0x02 + 0x20) = 0x62.
      str := add(mload(0x40), and(add(shl(1, length), 0x42), not(0x1f)))
      // Allocate the memory.
      mstore(0x40, add(str, 0x20))
      // Zeroize the slot after the string.
      mstore(str, 0)

      // Cache the end to calculate the length later.
      let end := str
      // Store "0123456789abcdef" in scratch space.
      mstore(0x0f, 0x30313233343536373839616263646566)

      let start := sub(str, add(length, length))
      let w := not(1) // Tsk.
      let temp := value
      // We write the string from rightmost digit to leftmost digit.
      // The following is essentially a do-while loop that also handles the zero case.
      for {

      } 1 {

      } {
        str := add(str, w) // `sub(str, 2)`.
        mstore8(add(str, 1), mload(and(temp, 15)))
        mstore8(str, mload(and(shr(4, temp), 15)))
        temp := shr(8, temp)
        if iszero(xor(str, start)) {
          break
        }
      }

      if temp {
        // Store the function selector of `HexLengthInsufficient()`.
        mstore(0x00, 0x2194895a)
        // Revert with (offset, size).
        revert(0x1c, 0x04)
      }

      // Compute the string's length.
      let strLength := sub(end, str)
      // Move the pointer and write the length.
      str := sub(str, 0x20)
      mstore(str, strLength)
    }
  }

  /// @dev Returns the hexadecimal representation of `value`.
  /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
  /// As address are 20 bytes long, the output will left-padded to have
  /// a length of `20 * 2 + 2` bytes.
  function toHexString(uint256 value) internal pure returns (string memory str) {
    str = toHexStringNoPrefix(value);
    /// @solidity memory-safe-assembly
    assembly {
      let strLength := add(mload(str), 2) // Compute the length.
      mstore(str, 0x3078) // Write the "0x" prefix.
      str := sub(str, 2) // Move the pointer.
      mstore(str, strLength) // Write the length.
    }
  }

  /// @dev Returns the hexadecimal representation of `value`.
  /// The output is encoded using 2 hexadecimal digits per byte.
  /// As address are 20 bytes long, the output will left-padded to have
  /// a length of `20 * 2` bytes.
  function toHexStringNoPrefix(uint256 value) internal pure returns (string memory str) {
    /// @solidity memory-safe-assembly
    assembly {
      // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
      // 0x02 bytes for the prefix, and 0x40 bytes for the digits.
      // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x40) is 0xa0.
      str := add(mload(0x40), 0x80)
      // Allocate the memory.
      mstore(0x40, add(str, 0x20))
      // Zeroize the slot after the string.
      mstore(str, 0)

      // Cache the end to calculate the length later.
      let end := str
      // Store "0123456789abcdef" in scratch space.
      mstore(0x0f, 0x30313233343536373839616263646566)

      let w := not(1) // Tsk.
      // We write the string from rightmost digit to leftmost digit.
      // The following is essentially a do-while loop that also handles the zero case.
      for {
        let temp := value
      } 1 {

      } {
        str := add(str, w) // `sub(str, 2)`.
        mstore8(add(str, 1), mload(and(temp, 15)))
        mstore8(str, mload(and(shr(4, temp), 15)))
        temp := shr(8, temp)
        if iszero(temp) {
          break
        }
      }

      // Compute the string's length.
      let strLength := sub(end, str)
      // Move the pointer and write the length.
      str := sub(str, 0x20)
      mstore(str, strLength)
    }
  }

  /// @dev Returns the hexadecimal representation of `value`.
  /// The output is prefixed with "0x", encoded using 2 hexadecimal digits per byte,
  /// and the alphabets are capitalized conditionally according to
  /// https://eips.ethereum.org/EIPS/eip-55
  function toHexStringChecksumed(address value) internal pure returns (string memory str) {
    str = toHexString(value);
    /// @solidity memory-safe-assembly
    assembly {
      let mask := shl(6, div(not(0), 255)) // `0b010000000100000000 ...`
      let o := add(str, 0x22)
      let hashed := and(keccak256(o, 40), mul(34, mask)) // `0b10001000 ... `
      let t := shl(240, 136) // `0b10001000 << 240`
      for {
        let i := 0
      } 1 {

      } {
        mstore(add(i, i), mul(t, byte(i, hashed)))
        i := add(i, 1)
        if eq(i, 20) {
          break
        }
      }
      mstore(o, xor(mload(o), shr(1, and(mload(0x00), and(mload(o), mask)))))
      o := add(o, 0x20)
      mstore(o, xor(mload(o), shr(1, and(mload(0x20), and(mload(o), mask)))))
    }
  }

  /// @dev Returns the hexadecimal representation of `value`.
  /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
  function toHexString(address value) internal pure returns (string memory str) {
    str = toHexStringNoPrefix(value);
    /// @solidity memory-safe-assembly
    assembly {
      let strLength := add(mload(str), 2) // Compute the length.
      mstore(str, 0x3078) // Write the "0x" prefix.
      str := sub(str, 2) // Move the pointer.
      mstore(str, strLength) // Write the length.
    }
  }

  /// @dev Returns the hexadecimal representation of `value`.
  /// The output is encoded using 2 hexadecimal digits per byte.
  function toHexStringNoPrefix(address value) internal pure returns (string memory str) {
    /// @solidity memory-safe-assembly
    assembly {
      str := mload(0x40)

      // Allocate the memory.
      // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
      // 0x02 bytes for the prefix, and 0x28 bytes for the digits.
      // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x28) is 0x80.
      mstore(0x40, add(str, 0x80))

      // Store "0123456789abcdef" in scratch space.
      mstore(0x0f, 0x30313233343536373839616263646566)

      str := add(str, 2)
      mstore(str, 40)

      let o := add(str, 0x20)
      mstore(add(o, 40), 0)

      value := shl(96, value)

      // We write the string from rightmost digit to leftmost digit.
      // The following is essentially a do-while loop that also handles the zero case.
      for {
        let i := 0
      } 1 {

      } {
        let p := add(o, add(i, i))
        let temp := byte(i, value)
        mstore8(add(p, 1), mload(and(temp, 15)))
        mstore8(p, mload(shr(4, temp)))
        i := add(i, 1)
        if eq(i, 20) {
          break
        }
      }
    }
  }

  /// @dev Returns the hex encoded string from the raw bytes.
  /// The output is encoded using 2 hexadecimal digits per byte.
  function toHexString(bytes memory raw) internal pure returns (string memory str) {
    str = toHexStringNoPrefix(raw);
    /// @solidity memory-safe-assembly
    assembly {
      let strLength := add(mload(str), 2) // Compute the length.
      mstore(str, 0x3078) // Write the "0x" prefix.
      str := sub(str, 2) // Move the pointer.
      mstore(str, strLength) // Write the length.
    }
  }

  /// @dev Returns the hex encoded string from the raw bytes.
  /// The output is encoded using 2 hexadecimal digits per byte.
  function toHexStringNoPrefix(bytes memory raw) internal pure returns (string memory str) {
    /// @solidity memory-safe-assembly
    assembly {
      let length := mload(raw)
      str := add(mload(0x40), 2) // Skip 2 bytes for the optional prefix.
      mstore(str, add(length, length)) // Store the length of the output.

      // Store "0123456789abcdef" in scratch space.
      mstore(0x0f, 0x30313233343536373839616263646566)

      let o := add(str, 0x20)
      let end := add(raw, length)

      for {

      } iszero(eq(raw, end)) {

      } {
        raw := add(raw, 1)
        mstore8(add(o, 1), mload(and(mload(raw), 15)))
        mstore8(o, mload(and(shr(4, mload(raw)), 15)))
        o := add(o, 2)
      }
      mstore(o, 0) // Zeroize the slot after the string.
      mstore(0x40, and(add(o, 31), not(31))) // Allocate the memory.
    }
  }

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                   RUNE STRING OPERATIONS                   */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  /// @dev Returns the number of UTF characters in the string.
  function runeCount(string memory s) internal pure returns (uint256 result) {
    /// @solidity memory-safe-assembly
    assembly {
      if mload(s) {
        mstore(0x00, div(not(0), 255))
        mstore(0x20, 0x0202020202020202020202020202020202020202020202020303030304040506)
        let o := add(s, 0x20)
        let end := add(o, mload(s))
        for {
          result := 1
        } 1 {
          result := add(result, 1)
        } {
          o := add(o, byte(0, mload(shr(250, mload(o)))))
          if iszero(lt(o, end)) {
            break
          }
        }
      }
    }
  }

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                   BYTE STRING OPERATIONS                   */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  // For performance and bytecode compactness, all indices of the following operations
  // are byte (ASCII) offsets, not UTF character offsets.

  /// @dev Returns `subject` all occurrences of `search` replaced with `replacement`.
  function replace(
    string memory subject,
    string memory search,
    string memory replacement
  ) internal pure returns (string memory result) {
    /// @solidity memory-safe-assembly
    assembly {
      let subjectLength := mload(subject)
      let searchLength := mload(search)
      let replacementLength := mload(replacement)

      subject := add(subject, 0x20)
      search := add(search, 0x20)
      replacement := add(replacement, 0x20)
      result := add(mload(0x40), 0x20)

      let subjectEnd := add(subject, subjectLength)
      if iszero(gt(searchLength, subjectLength)) {
        let subjectSearchEnd := add(sub(subjectEnd, searchLength), 1)
        let h := 0
        if iszero(lt(searchLength, 32)) {
          h := keccak256(search, searchLength)
        }
        let m := shl(3, sub(32, and(searchLength, 31)))
        let s := mload(search)
        for {

        } 1 {

        } {
          let t := mload(subject)
          // Whether the first `searchLength % 32` bytes of
          // `subject` and `search` matches.
          if iszero(shr(m, xor(t, s))) {
            if h {
              if iszero(eq(keccak256(subject, searchLength), h)) {
                mstore(result, t)
                result := add(result, 1)
                subject := add(subject, 1)
                if iszero(lt(subject, subjectSearchEnd)) {
                  break
                }
                continue
              }
            }
            // Copy the `replacement` one word at a time.
            for {
              let o := 0
            } 1 {

            } {
              mstore(add(result, o), mload(add(replacement, o)))
              o := add(o, 0x20)
              if iszero(lt(o, replacementLength)) {
                break
              }
            }
            result := add(result, replacementLength)
            subject := add(subject, searchLength)
            if searchLength {
              if iszero(lt(subject, subjectSearchEnd)) {
                break
              }
              continue
            }
          }
          mstore(result, t)
          result := add(result, 1)
          subject := add(subject, 1)
          if iszero(lt(subject, subjectSearchEnd)) {
            break
          }
        }
      }

      let resultRemainder := result
      result := add(mload(0x40), 0x20)
      let k := add(sub(resultRemainder, result), sub(subjectEnd, subject))
      // Copy the rest of the string one word at a time.
      for {

      } lt(subject, subjectEnd) {

      } {
        mstore(resultRemainder, mload(subject))
        resultRemainder := add(resultRemainder, 0x20)
        subject := add(subject, 0x20)
      }
      result := sub(result, 0x20)
      // Zeroize the slot after the string.
      let last := add(add(result, 0x20), k)
      mstore(last, 0)
      // Allocate memory for the length and the bytes,
      // rounded up to a multiple of 32.
      mstore(0x40, and(add(last, 31), not(31)))
      // Store the length of the result.
      mstore(result, k)
    }
  }

  /// @dev Returns the byte index of the first location of `search` in `subject`,
  /// searching from left to right, starting from `from`.
  /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
  function indexOf(string memory subject, string memory search, uint256 from) internal pure returns (uint256 result) {
    /// @solidity memory-safe-assembly
    assembly {
      for {
        let subjectLength := mload(subject)
      } 1 {

      } {
        if iszero(mload(search)) {
          if iszero(gt(from, subjectLength)) {
            result := from
            break
          }
          result := subjectLength
          break
        }
        let searchLength := mload(search)
        let subjectStart := add(subject, 0x20)

        result := not(0) // Initialize to `NOT_FOUND`.

        subject := add(subjectStart, from)
        let end := add(sub(add(subjectStart, subjectLength), searchLength), 1)

        let m := shl(3, sub(32, and(searchLength, 31)))
        let s := mload(add(search, 0x20))

        if iszero(and(lt(subject, end), lt(from, subjectLength))) {
          break
        }

        if iszero(lt(searchLength, 32)) {
          for {
            let h := keccak256(add(search, 0x20), searchLength)
          } 1 {

          } {
            if iszero(shr(m, xor(mload(subject), s))) {
              if eq(keccak256(subject, searchLength), h) {
                result := sub(subject, subjectStart)
                break
              }
            }
            subject := add(subject, 1)
            if iszero(lt(subject, end)) {
              break
            }
          }
          break
        }
        for {

        } 1 {

        } {
          if iszero(shr(m, xor(mload(subject), s))) {
            result := sub(subject, subjectStart)
            break
          }
          subject := add(subject, 1)
          if iszero(lt(subject, end)) {
            break
          }
        }
        break
      }
    }
  }

  /// @dev Returns the byte index of the first location of `search` in `subject`,
  /// searching from left to right.
  /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
  function indexOf(string memory subject, string memory search) internal pure returns (uint256 result) {
    result = indexOf(subject, search, 0);
  }

  /// @dev Returns the byte index of the first location of `search` in `subject`,
  /// searching from right to left, starting from `from`.
  /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
  function lastIndexOf(
    string memory subject,
    string memory search,
    uint256 from
  ) internal pure returns (uint256 result) {
    /// @solidity memory-safe-assembly
    assembly {
      for {

      } 1 {

      } {
        result := not(0) // Initialize to `NOT_FOUND`.
        let searchLength := mload(search)
        if gt(searchLength, mload(subject)) {
          break
        }
        let w := result

        let fromMax := sub(mload(subject), searchLength)
        if iszero(gt(fromMax, from)) {
          from := fromMax
        }

        let end := add(add(subject, 0x20), w)
        subject := add(add(subject, 0x20), from)
        if iszero(gt(subject, end)) {
          break
        }
        // As this function is not too often used,
        // we shall simply use keccak256 for smaller bytecode size.
        for {
          let h := keccak256(add(search, 0x20), searchLength)
        } 1 {

        } {
          if eq(keccak256(subject, searchLength), h) {
            result := sub(subject, add(end, 1))
            break
          }
          subject := add(subject, w) // `sub(subject, 1)`.
          if iszero(gt(subject, end)) {
            break
          }
        }
        break
      }
    }
  }

  /// @dev Returns the byte index of the first location of `search` in `subject`,
  /// searching from right to left.
  /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
  function lastIndexOf(string memory subject, string memory search) internal pure returns (uint256 result) {
    result = lastIndexOf(subject, search, uint256(int256(-1)));
  }

  /// @dev Returns whether `subject` starts with `search`.
  function startsWith(string memory subject, string memory search) internal pure returns (bool result) {
    /// @solidity memory-safe-assembly
    assembly {
      let searchLength := mload(search)
      // Just using keccak256 directly is actually cheaper.
      // forgefmt: disable-next-item
      result := and(
        iszero(gt(searchLength, mload(subject))),
        eq(keccak256(add(subject, 0x20), searchLength), keccak256(add(search, 0x20), searchLength))
      )
    }
  }

  /// @dev Returns whether `subject` ends with `search`.
  function endsWith(string memory subject, string memory search) internal pure returns (bool result) {
    /// @solidity memory-safe-assembly
    assembly {
      let searchLength := mload(search)
      let subjectLength := mload(subject)
      // Whether `search` is not longer than `subject`.
      let withinRange := iszero(gt(searchLength, subjectLength))
      // Just using keccak256 directly is actually cheaper.
      // forgefmt: disable-next-item
      result := and(
        withinRange,
        eq(
          keccak256(
            // `subject + 0x20 + max(subjectLength - searchLength, 0)`.
            add(add(subject, 0x20), mul(withinRange, sub(subjectLength, searchLength))),
            searchLength
          ),
          keccak256(add(search, 0x20), searchLength)
        )
      )
    }
  }

  /// @dev Returns `subject` repeated `times`.
  function repeat(string memory subject, uint256 times) internal pure returns (string memory result) {
    /// @solidity memory-safe-assembly
    assembly {
      let subjectLength := mload(subject)
      if iszero(or(iszero(times), iszero(subjectLength))) {
        subject := add(subject, 0x20)
        result := mload(0x40)
        let output := add(result, 0x20)
        for {

        } 1 {

        } {
          // Copy the `subject` one word at a time.
          for {
            let o := 0
          } 1 {

          } {
            mstore(add(output, o), mload(add(subject, o)))
            o := add(o, 0x20)
            if iszero(lt(o, subjectLength)) {
              break
            }
          }
          output := add(output, subjectLength)
          times := sub(times, 1)
          if iszero(times) {
            break
          }
        }
        // Zeroize the slot after the string.
        mstore(output, 0)
        // Store the length.
        let resultLength := sub(output, add(result, 0x20))
        mstore(result, resultLength)
        // Allocate memory for the length and the bytes,
        // rounded up to a multiple of 32.
        mstore(0x40, add(result, and(add(resultLength, 63), not(31))))
      }
    }
  }

  /// @dev Returns a copy of `subject` sliced from `start` to `end` (exclusive).
  /// `start` and `end` are byte offsets.
  function slice(string memory subject, uint256 start, uint256 end) internal pure returns (string memory result) {
    /// @solidity memory-safe-assembly
    assembly {
      let subjectLength := mload(subject)
      if iszero(gt(subjectLength, end)) {
        end := subjectLength
      }
      if iszero(gt(subjectLength, start)) {
        start := subjectLength
      }
      if lt(start, end) {
        result := mload(0x40)
        let resultLength := sub(end, start)
        mstore(result, resultLength)
        subject := add(subject, start)
        let w := not(31)
        // Copy the `subject` one word at a time, backwards.
        for {
          let o := and(add(resultLength, 31), w)
        } 1 {

        } {
          mstore(add(result, o), mload(add(subject, o)))
          o := add(o, w) // `sub(o, 0x20)`.
          if iszero(o) {
            break
          }
        }
        // Zeroize the slot after the string.
        mstore(add(add(result, 0x20), resultLength), 0)
        // Allocate memory for the length and the bytes,
        // rounded up to a multiple of 32.
        mstore(0x40, add(result, and(add(resultLength, 63), w)))
      }
    }
  }

  /// @dev Returns a copy of `subject` sliced from `start` to the end of the string.
  /// `start` is a byte offset.
  function slice(string memory subject, uint256 start) internal pure returns (string memory result) {
    result = slice(subject, start, uint256(int256(-1)));
  }

  /// @dev Returns all the indices of `search` in `subject`.
  /// The indices are byte offsets.
  function indicesOf(string memory subject, string memory search) internal pure returns (uint256[] memory result) {
    /// @solidity memory-safe-assembly
    assembly {
      let subjectLength := mload(subject)
      let searchLength := mload(search)

      if iszero(gt(searchLength, subjectLength)) {
        subject := add(subject, 0x20)
        search := add(search, 0x20)
        result := add(mload(0x40), 0x20)

        let subjectStart := subject
        let subjectSearchEnd := add(sub(add(subject, subjectLength), searchLength), 1)
        let h := 0
        if iszero(lt(searchLength, 32)) {
          h := keccak256(search, searchLength)
        }
        let m := shl(3, sub(32, and(searchLength, 31)))
        let s := mload(search)
        for {

        } 1 {

        } {
          let t := mload(subject)
          // Whether the first `searchLength % 32` bytes of
          // `subject` and `search` matches.
          if iszero(shr(m, xor(t, s))) {
            if h {
              if iszero(eq(keccak256(subject, searchLength), h)) {
                subject := add(subject, 1)
                if iszero(lt(subject, subjectSearchEnd)) {
                  break
                }
                continue
              }
            }
            // Append to `result`.
            mstore(result, sub(subject, subjectStart))
            result := add(result, 0x20)
            // Advance `subject` by `searchLength`.
            subject := add(subject, searchLength)
            if searchLength {
              if iszero(lt(subject, subjectSearchEnd)) {
                break
              }
              continue
            }
          }
          subject := add(subject, 1)
          if iszero(lt(subject, subjectSearchEnd)) {
            break
          }
        }
        let resultEnd := result
        // Assign `result` to the free memory pointer.
        result := mload(0x40)
        // Store the length of `result`.
        mstore(result, shr(5, sub(resultEnd, add(result, 0x20))))
        // Allocate memory for result.
        // We allocate one more word, so this array can be recycled for {split}.
        mstore(0x40, add(resultEnd, 0x20))
      }
    }
  }

  /// @dev Returns a arrays of strings based on the `delimiter` inside of the `subject` string.
  function split(string memory subject, string memory delimiter) internal pure returns (string[] memory result) {
    uint256[] memory indices = indicesOf(subject, delimiter);
    /// @solidity memory-safe-assembly
    assembly {
      let w := not(31)
      let indexPtr := add(indices, 0x20)
      let indicesEnd := add(indexPtr, shl(5, add(mload(indices), 1)))
      mstore(add(indicesEnd, w), mload(subject))
      mstore(indices, add(mload(indices), 1))
      let prevIndex := 0
      for {

      } 1 {

      } {
        let index := mload(indexPtr)
        mstore(indexPtr, 0x60)
        if iszero(eq(index, prevIndex)) {
          let element := mload(0x40)
          let elementLength := sub(index, prevIndex)
          mstore(element, elementLength)
          // Copy the `subject` one word at a time, backwards.
          for {
            let o := and(add(elementLength, 31), w)
          } 1 {

          } {
            mstore(add(element, o), mload(add(add(subject, prevIndex), o)))
            o := add(o, w) // `sub(o, 0x20)`.
            if iszero(o) {
              break
            }
          }
          // Zeroize the slot after the string.
          mstore(add(add(element, 0x20), elementLength), 0)
          // Allocate memory for the length and the bytes,
          // rounded up to a multiple of 32.
          mstore(0x40, add(element, and(add(elementLength, 63), w)))
          // Store the `element` into the array.
          mstore(indexPtr, element)
        }
        prevIndex := add(index, mload(delimiter))
        indexPtr := add(indexPtr, 0x20)
        if iszero(lt(indexPtr, indicesEnd)) {
          break
        }
      }
      result := indices
      if iszero(mload(delimiter)) {
        result := add(indices, 0x20)
        mstore(result, sub(mload(indices), 2))
      }
    }
  }

  /// @dev Returns a concatenated string of `a` and `b`.
  /// Cheaper than `string.concat()` and does not de-align the free memory pointer.
  function concat(string memory a, string memory b) internal pure returns (string memory result) {
    /// @solidity memory-safe-assembly
    assembly {
      let w := not(31)
      result := mload(0x40)
      let aLength := mload(a)
      // Copy `a` one word at a time, backwards.
      for {
        let o := and(add(mload(a), 32), w)
      } 1 {

      } {
        mstore(add(result, o), mload(add(a, o)))
        o := add(o, w) // `sub(o, 0x20)`.
        if iszero(o) {
          break
        }
      }
      let bLength := mload(b)
      let output := add(result, mload(a))
      // Copy `b` one word at a time, backwards.
      for {
        let o := and(add(bLength, 32), w)
      } 1 {

      } {
        mstore(add(output, o), mload(add(b, o)))
        o := add(o, w) // `sub(o, 0x20)`.
        if iszero(o) {
          break
        }
      }
      let totalLength := add(aLength, bLength)
      let last := add(add(result, 0x20), totalLength)
      // Zeroize the slot after the string.
      mstore(last, 0)
      // Stores the length.
      mstore(result, totalLength)
      // Allocate memory for the length and the bytes,
      // rounded up to a multiple of 32.
      mstore(0x40, and(add(last, 31), w))
    }
  }

  /// @dev Returns a copy of the string in either lowercase or UPPERCASE.
  function toCase(string memory subject, bool toUpper) internal pure returns (string memory result) {
    /// @solidity memory-safe-assembly
    assembly {
      let length := mload(subject)
      if length {
        result := add(mload(0x40), 0x20)
        subject := add(subject, 1)
        let flags := shl(add(70, shl(5, toUpper)), 67108863)
        let w := not(0)
        for {
          let o := length
        } 1 {

        } {
          o := add(o, w)
          let b := and(0xff, mload(add(subject, o)))
          mstore8(add(result, o), xor(b, and(shr(b, flags), 0x20)))
          if iszero(o) {
            break
          }
        }
        // Restore the result.
        result := mload(0x40)
        // Stores the string length.
        mstore(result, length)
        // Zeroize the slot after the string.
        let last := add(add(result, 0x20), length)
        mstore(last, 0)
        // Allocate memory for the length and the bytes,
        // rounded up to a multiple of 32.
        mstore(0x40, and(add(last, 31), not(31)))
      }
    }
  }

  /// @dev Returns a lowercased copy of the string.
  function lower(string memory subject) internal pure returns (string memory result) {
    result = toCase(subject, false);
  }

  /// @dev Returns an UPPERCASED copy of the string.
  function upper(string memory subject) internal pure returns (string memory result) {
    result = toCase(subject, true);
  }

  /// @dev Escapes the string to be used within HTML tags.
  function escapeHTML(string memory s) internal pure returns (string memory result) {
    /// @solidity memory-safe-assembly
    assembly {
      for {
        let end := add(s, mload(s))
        result := add(mload(0x40), 0x20)
        // Store the bytes of the packed offsets and strides into the scratch space.
        // `packed = (stride << 5) | offset`. Max offset is 20. Max stride is 6.
        mstore(0x1f, 0x900094)
        mstore(0x08, 0xc0000000a6ab)
        // Store "&quot;&amp;&#39;&lt;&gt;" into the scratch space.
        mstore(0x00, shl(64, 0x2671756f743b26616d703b262333393b266c743b2667743b))
      } iszero(eq(s, end)) {

      } {
        s := add(s, 1)
        let c := and(mload(s), 0xff)
        // Not in `["\"","'","&","<",">"]`.
        if iszero(and(shl(c, 1), 0x500000c400000000)) {
          mstore8(result, c)
          result := add(result, 1)
          continue
        }
        let t := shr(248, mload(c))
        mstore(result, mload(and(t, 31)))
        result := add(result, shr(5, t))
      }
      let last := result
      // Zeroize the slot after the string.
      mstore(last, 0)
      // Restore the result to the start of the free memory.
      result := mload(0x40)
      // Store the length of the result.
      mstore(result, sub(last, add(result, 0x20)))
      // Allocate memory for the length and the bytes,
      // rounded up to a multiple of 32.
      mstore(0x40, and(add(last, 31), not(31)))
    }
  }

  /// @dev Escapes the string to be used within double-quotes in a JSON.
  function escapeJSON(string memory s) internal pure returns (string memory result) {
    /// @solidity memory-safe-assembly
    assembly {
      for {
        let end := add(s, mload(s))
        result := add(mload(0x40), 0x20)
        // Store "\\u0000" in scratch space.
        // Store "0123456789abcdef" in scratch space.
        // Also, store `{0x08:"b", 0x09:"t", 0x0a:"n", 0x0c:"f", 0x0d:"r"}`.
        // into the scratch space.
        mstore(0x15, 0x5c75303030303031323334353637383961626364656662746e006672)
        // Bitmask for detecting `["\"","\\"]`.
        let e := or(shl(0x22, 1), shl(0x5c, 1))
      } iszero(eq(s, end)) {

      } {
        s := add(s, 1)
        let c := and(mload(s), 0xff)
        if iszero(lt(c, 0x20)) {
          if iszero(and(shl(c, 1), e)) {
            // Not in `["\"","\\"]`.
            mstore8(result, c)
            result := add(result, 1)
            continue
          }
          mstore8(result, 0x5c) // "\\".
          mstore8(add(result, 1), c)
          result := add(result, 2)
          continue
        }
        if iszero(and(shl(c, 1), 0x3700)) {
          // Not in `["\b","\t","\n","\f","\d"]`.
          mstore8(0x1d, mload(shr(4, c))) // Hex value.
          mstore8(0x1e, mload(and(c, 15))) // Hex value.
          mstore(result, mload(0x19)) // "\\u00XX".
          result := add(result, 6)
          continue
        }
        mstore8(result, 0x5c) // "\\".
        mstore8(add(result, 1), mload(add(c, 8)))
        result := add(result, 2)
      }
      let last := result
      // Zeroize the slot after the string.
      mstore(last, 0)
      // Restore the result to the start of the free memory.
      result := mload(0x40)
      // Store the length of the result.
      mstore(result, sub(last, add(result, 0x20)))
      // Allocate memory for the length and the bytes,
      // rounded up to a multiple of 32.
      mstore(0x40, and(add(last, 31), not(31)))
    }
  }

  /// @dev Returns whether `a` equals `b`.
  function eq(string memory a, string memory b) internal pure returns (bool result) {
    assembly {
      result := eq(keccak256(add(a, 0x20), mload(a)), keccak256(add(b, 0x20), mload(b)))
    }
  }

  /// @dev Packs a single string with its length into a single word.
  /// Returns `bytes32(0)` if the length is zero or greater than 31.
  function packOne(string memory a) internal pure returns (bytes32 result) {
    /// @solidity memory-safe-assembly
    assembly {
      // We don't need to zero right pad the string,
      // since this is our own custom non-standard packing scheme.
      result := mul(
        // Load the length and the bytes.
        mload(add(a, 0x1f)),
        // `length != 0 && length < 32`. Abuses underflow.
        // Assumes that the length is valid and within the block gas limit.
        lt(sub(mload(a), 1), 0x1f)
      )
    }
  }

  /// @dev Unpacks a string packed using {packOne}.
  /// Returns the empty string if `packed` is `bytes32(0)`.
  /// If `packed` is not an output of {packOne}, the output behaviour is undefined.
  function unpackOne(bytes32 packed) internal pure returns (string memory result) {
    /// @solidity memory-safe-assembly
    assembly {
      // Grab the free memory pointer.
      result := mload(0x40)
      // Allocate 2 words (1 for the length, 1 for the bytes).
      mstore(0x40, add(result, 0x40))
      // Zeroize the length slot.
      mstore(result, 0)
      // Store the length and bytes.
      mstore(add(result, 0x1f), packed)
      // Right pad with zeroes.
      mstore(add(add(result, 0x20), mload(result)), 0)
    }
  }

  /// @dev Packs two strings with their lengths into a single word.
  /// Returns `bytes32(0)` if combined length is zero or greater than 30.
  function packTwo(string memory a, string memory b) internal pure returns (bytes32 result) {
    /// @solidity memory-safe-assembly
    assembly {
      let aLength := mload(a)
      // We don't need to zero right pad the strings,
      // since this is our own custom non-standard packing scheme.
      result := mul(
        // Load the length and the bytes of `a` and `b`.
        or(shl(shl(3, sub(0x1f, aLength)), mload(add(a, aLength))), mload(sub(add(b, 0x1e), aLength))),
        // `totalLength != 0 && totalLength < 31`. Abuses underflow.
        // Assumes that the lengths are valid and within the block gas limit.
        lt(sub(add(aLength, mload(b)), 1), 0x1e)
      )
    }
  }

  /// @dev Unpacks strings packed using {packTwo}.
  /// Returns the empty strings if `packed` is `bytes32(0)`.
  /// If `packed` is not an output of {packTwo}, the output behaviour is undefined.
  function unpackTwo(bytes32 packed) internal pure returns (string memory resultA, string memory resultB) {
    /// @solidity memory-safe-assembly
    assembly {
      // Grab the free memory pointer.
      resultA := mload(0x40)
      resultB := add(resultA, 0x40)
      // Allocate 2 words for each string (1 for the length, 1 for the byte). Total 4 words.
      mstore(0x40, add(resultB, 0x40))
      // Zeroize the length slots.
      mstore(resultA, 0)
      mstore(resultB, 0)
      // Store the lengths and bytes.
      mstore(add(resultA, 0x1f), packed)
      mstore(add(resultB, 0x1f), mload(add(add(resultA, 0x20), mload(resultA))))
      // Right pad with zeroes.
      mstore(add(add(resultA, 0x20), mload(resultA)), 0)
      mstore(add(add(resultB, 0x20), mload(resultB)), 0)
    }
  }

  /// @dev Directly returns `a` without copying.
  function directReturn(string memory a) internal pure {
    assembly {
      // Assumes that the string does not start from the scratch space.
      let retStart := sub(a, 0x20)
      let retSize := add(mload(a), 0x40)
      // Right pad with zeroes. Just in case the string is produced
      // by a method that doesn't zero right pad.
      mstore(add(retStart, retSize), 0)
      // Store the return offset.
      mstore(retStart, 0x20)
      // End the transaction, returning the string.
      return(retStart, retSize)
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17 .0;

// Core SVG utility library which helps us construct
// onchain SVG's with a simple, web-like API.
// Credit to w1nt3r.eth for the base of this.
library svg {
  /* MAIN ELEMENTS */

  function line(string memory _props) internal pure returns (string memory) {
    return string.concat("<line ", _props, "/>");
  }

  /* COMMON */

  // an SVG attribute
  function prop(string memory _key, string memory _val) internal pure returns (string memory) {
    return string.concat(_key, "=", '"', _val, '" ');
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @notice Solidity library offering basic trigonometry functions where inputs and outputs are
 * integers. Inputs are specified in radians scaled by 1e18, and similarly outputs are scaled by 1e18.
 *
 * This implementation is based off the Solidity trigonometry library written by Lefteris Karapetsas
 * which can be found here: https://github.com/Sikorkaio/sikorka/blob/e75c91925c914beaedf4841c0336a806f2b5f66d/contracts/trigonometry.sol
 *
 * Compared to Lefteris' implementation, this version makes the following changes:
 *   - Uses a 32 bits instead of 16 bits for improved accuracy
 *   - Updated for Solidity 0.8.x
 *   - Various gas optimizations
 *   - Change inputs/outputs to standard trig format (scaled by 1e18) instead of requiring the
 *     integer format used by the algorithm
 *
 * Lefertis' implementation is based off Dave Dribin's trigint C library
 *     http://www.dribin.org/dave/trigint/
 *
 * Which in turn is based from a now deleted article which can be found in the Wayback Machine:
 *     http://web.archive.org/web/20120301144605/http://www.dattalo.com/technical/software/pic/picsine.html
 */
library Trigonometry {
  // Table index into the trigonometric table
  uint256 constant INDEX_WIDTH = 8;
  // Interpolation between successive entries in the table
  uint256 constant INTERP_WIDTH = 16;
  uint256 constant INDEX_OFFSET = 28 - INDEX_WIDTH;
  uint256 constant INTERP_OFFSET = INDEX_OFFSET - INTERP_WIDTH;
  uint32 constant ANGLES_IN_CYCLE = 1073741824;
  uint32 constant QUADRANT_HIGH_MASK = 536870912;
  uint32 constant QUADRANT_LOW_MASK = 268435456;
  uint256 constant SINE_TABLE_SIZE = 256;

  // Pi as an 18 decimal value, which is plenty of accuracy: "For JPL's highest accuracy calculations, which are for
  // interplanetary navigation, we use 3.141592653589793: https://www.jpl.nasa.gov/edu/news/2016/3/16/how-many-decimals-of-pi-do-we-really-need/
  uint256 constant PI = 3141592653589793238;
  uint256 constant TWO_PI = 2 * PI;
  uint256 constant PI_OVER_TWO = PI / 2;

  // The constant sine lookup table was generated by generate_trigonometry.py. We must use a constant
  // bytes array because constant arrays are not supported in Solidity. Each entry in the lookup
  // table is 4 bytes. Since we're using 32-bit parameters for the lookup table, we get a table size
  // of 2^(32/4) + 1 = 257, where the first and last entries are equivalent (hence the table size of
  // 256 defined above)
  uint8 constant entry_bytes = 4; // each entry in the lookup table is 4 bytes
  uint256 constant entry_mask = ((1 << (8 * entry_bytes)) - 1); // mask used to cast bytes32 -> lookup table entry
  bytes constant sin_table =
    hex"00_00_00_00_00_c9_0f_88_01_92_1d_20_02_5b_26_d7_03_24_2a_bf_03_ed_26_e6_04_b6_19_5d_05_7f_00_35_06_47_d9_7c_07_10_a3_45_07_d9_5b_9e_08_a2_00_9a_09_6a_90_49_0a_33_08_bc_0a_fb_68_05_0b_c3_ac_35_0c_8b_d3_5e_0d_53_db_92_0e_1b_c2_e4_0e_e3_87_66_0f_ab_27_2b_10_72_a0_48_11_39_f0_cf_12_01_16_d5_12_c8_10_6e_13_8e_db_b1_14_55_76_b1_15_1b_df_85_15_e2_14_44_16_a8_13_05_17_6d_d9_de_18_33_66_e8_18_f8_b8_3c_19_bd_cb_f3_1a_82_a0_25_1b_47_32_ef_1c_0b_82_6a_1c_cf_8c_b3_1d_93_4f_e5_1e_56_ca_1e_1f_19_f9_7b_1f_dc_dc_1b_20_9f_70_1c_21_61_b3_9f_22_23_a4_c5_22_e5_41_af_23_a6_88_7e_24_67_77_57_25_28_0c_5d_25_e8_45_b6_26_a8_21_85_27_67_9d_f4_28_26_b9_28_28_e5_71_4a_29_a3_c4_85_2a_61_b1_01_2b_1f_34_eb_2b_dc_4e_6f_2c_98_fb_ba_2d_55_3a_fb_2e_11_0a_62_2e_cc_68_1e_2f_87_52_62_30_41_c7_60_30_fb_c5_4d_31_b5_4a_5d_32_6e_54_c7_33_26_e2_c2_33_de_f2_87_34_96_82_4f_35_4d_90_56_36_04_1a_d9_36_ba_20_13_37_6f_9e_46_38_24_93_b0_38_d8_fe_93_39_8c_dd_32_3a_40_2d_d1_3a_f2_ee_b7_3b_a5_1e_29_3c_56_ba_70_3d_07_c1_d5_3d_b8_32_a5_3e_68_0b_2c_3f_17_49_b7_3f_c5_ec_97_40_73_f2_1d_41_21_58_9a_41_ce_1e_64_42_7a_41_d0_43_25_c1_35_43_d0_9a_ec_44_7a_cd_50_45_24_56_bc_45_cd_35_8f_46_75_68_27_47_1c_ec_e6_47_c3_c2_2e_48_69_e6_64_49_0f_57_ee_49_b4_15_33_4a_58_1c_9d_4a_fb_6c_97_4b_9e_03_8f_4c_3f_df_f3_4c_e1_00_34_4d_81_62_c3_4e_21_06_17_4e_bf_e8_a4_4f_5e_08_e2_4f_fb_65_4c_50_97_fc_5e_51_33_cc_94_51_ce_d4_6e_52_69_12_6e_53_02_85_17_53_9b_2a_ef_54_33_02_7d_54_ca_0a_4a_55_60_40_e2_55_f5_a4_d2_56_8a_34_a9_57_1d_ee_f9_57_b0_d2_55_58_42_dd_54_58_d4_0e_8c_59_64_64_97_59_f3_de_12_5a_82_79_99_5b_10_35_ce_5b_9d_11_53_5c_29_0a_cc_5c_b4_20_df_5d_3e_52_36_5d_c7_9d_7b_5e_50_01_5d_5e_d7_7c_89_5f_5e_0d_b2_5f_e3_b3_8d_60_68_6c_ce_60_ec_38_2f_61_6f_14_6b_61_f1_00_3e_62_71_fa_68_62_f2_01_ac_63_71_14_cc_63_ef_32_8f_64_6c_59_bf_64_e8_89_25_65_63_bf_91_65_dd_fb_d2_66_57_3c_bb_66_cf_81_1f_67_46_c7_d7_67_bd_0f_bc_68_32_57_aa_68_a6_9e_80_69_19_e3_1f_69_8c_24_6b_69_fd_61_4a_6a_6d_98_a3_6a_dc_c9_64_6b_4a_f2_78_6b_b8_12_d0_6c_24_29_5f_6c_8f_35_1b_6c_f9_34_fb_6d_62_27_f9_6d_ca_0d_14_6e_30_e3_49_6e_96_a9_9c_6e_fb_5f_11_6f_5f_02_b1_6f_c1_93_84_70_23_10_99_70_83_78_fe_70_e2_cb_c5_71_41_08_04_71_9e_2c_d1_71_fa_39_48_72_55_2c_84_72_af_05_a6_73_07_c3_cf_73_5f_66_25_73_b5_eb_d0_74_0b_53_fa_74_5f_9d_d0_74_b2_c8_83_75_04_d3_44_75_55_bd_4b_75_a5_85_ce_75_f4_2c_0a_76_41_af_3c_76_8e_0e_a5_76_d9_49_88_77_23_5f_2c_77_6c_4e_da_77_b4_17_df_77_fa_b9_88_78_40_33_28_78_84_84_13_78_c7_ab_a1_79_09_a9_2c_79_4a_7c_11_79_8a_23_b0_79_c8_9f_6d_7a_05_ee_ac_7a_42_10_d8_7a_7d_05_5a_7a_b6_cb_a3_7a_ef_63_23_7b_26_cb_4e_7b_5d_03_9d_7b_92_0b_88_7b_c5_e2_8f_7b_f8_88_2f_7c_29_fb_ed_7c_5a_3d_4f_7c_89_4b_dd_7c_b7_27_23_7c_e3_ce_b1_7d_0f_42_17_7d_39_80_eb_7d_62_8a_c5_7d_8a_5f_3f_7d_b0_fd_f7_7d_d6_66_8e_7d_fa_98_a7_7e_1d_93_e9_7e_3f_57_fe_7e_5f_e4_92_7e_7f_39_56_7e_9d_55_fb_7e_ba_3a_38_7e_d5_e5_c5_7e_f0_58_5f_7f_09_91_c3_7f_21_91_b3_7f_38_57_f5_7f_4d_e4_50_7f_62_36_8e_7f_75_4e_7f_7f_87_2b_f2_7f_97_ce_bc_7f_a7_36_b3_7f_b5_63_b2_7f_c2_55_95_7f_ce_0c_3d_7f_d8_87_8d_7f_e1_c7_6a_7f_e9_cb_bf_7f_f0_94_77_7f_f6_21_81_7f_fa_72_d0_7f_fd_88_59_7f_ff_62_15_7f_ff_ff_ff";

  /**
   * @notice Return the sine of a value, specified in radians scaled by 1e18
   * @dev This algorithm for converting sine only uses integer values, and it works by dividing the
   * circle into 30 bit angles, i.e. there are 1,073,741,824 (2^30) angle units, instead of the
   * standard 360 degrees (2pi radians). From there, we get an output in range -2,147,483,647 to
   * 2,147,483,647, (which is the max value of an int32) which is then converted back to the standard
   * range of -1 to 1, again scaled by 1e18
   * @param _angle Angle to convert
   * @return Result scaled by 1e18
   */
  function sin(uint256 _angle) internal pure returns (int256) {
    unchecked {
      // Convert angle from from arbitrary radian value (range of 0 to 2pi) to the algorithm's range
      // of 0 to 1,073,741,824
      _angle = (ANGLES_IN_CYCLE * (_angle % TWO_PI)) / TWO_PI;

      // Apply a mask on an integer to extract a certain number of bits, where angle is the integer
      // whose bits we want to get, the width is the width of the bits (in bits) we want to extract,
      // and the offset is the offset of the bits (in bits) we want to extract. The result is an
      // integer containing _width bits of _value starting at the offset bit
      uint256 interp = (_angle >> INTERP_OFFSET) & ((1 << INTERP_WIDTH) - 1);
      uint256 index = (_angle >> INDEX_OFFSET) & ((1 << INDEX_WIDTH) - 1);

      // The lookup table only contains data for one quadrant (since sin is symmetric around both
      // axes), so here we figure out which quadrant we're in, then we lookup the values in the
      // table then modify values accordingly
      bool is_odd_quadrant = (_angle & QUADRANT_LOW_MASK) == 0;
      bool is_negative_quadrant = (_angle & QUADRANT_HIGH_MASK) != 0;

      if (!is_odd_quadrant) {
        index = SINE_TABLE_SIZE - 1 - index;
      }

      bytes memory table = sin_table;
      // We are looking for two consecutive indices in our lookup table
      // Since EVM is left aligned, to read n bytes of data from idx i, we must read from `i * data_len` + `n`
      // therefore, to read two entries of size entry_bytes `index * entry_bytes` + `entry_bytes * 2`
      uint256 offset1_2 = (index + 2) * entry_bytes;

      // This following snippet will function for any entry_bytes <= 15
      uint256 x1_2;
      assembly {
        // mload will grab one word worth of bytes (32), as that is the minimum size in EVM
        x1_2 := mload(add(table, offset1_2))
      }

      // We now read the last two numbers of size entry_bytes from x1_2
      // in example: entry_bytes = 4; x1_2 = 0x00...12345678abcdefgh
      // therefore: entry_mask = 0xFFFFFFFF

      // 0x00...12345678abcdefgh >> 8*4 = 0x00...12345678
      // 0x00...12345678 & 0xFFFFFFFF = 0x12345678
      uint256 x1 = (x1_2 >> (8 * entry_bytes)) & entry_mask;
      // 0x00...12345678abcdefgh & 0xFFFFFFFF = 0xabcdefgh
      uint256 x2 = x1_2 & entry_mask;

      // Approximate angle by interpolating in the table, accounting for the quadrant
      uint256 approximation = ((x2 - x1) * interp) >> INTERP_WIDTH;
      int256 sine = is_odd_quadrant ? int256(x1) + int256(approximation) : int256(x2) - int256(approximation);
      if (is_negative_quadrant) {
        sine *= -1;
      }

      // Bring result from the range of -2,147,483,647 through 2,147,483,647 to -1e18 through 1e18.
      // This can never overflow because sine is bounded by the above values
      return (sine * 1e18) / 2_147_483_647;
    }
  }

  /**
   * @notice Return the cosine of a value, specified in radians scaled by 1e18
   * @dev This is identical to the sin() method, and just computes the value by delegating to the
   * sin() method using the identity cos(x) = sin(x + pi/2)
   * @dev Overflow when `angle + PI_OVER_TWO > type(uint256).max` is ok, results are still accurate
   * @param _angle Angle to convert
   * @return Result scaled by 1e18
   */
  function cos(uint256 _angle) internal pure returns (int256) {
    unchecked {
      return sin(_angle + PI_OVER_TWO);
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

/**
 * @notice A two-step extension of Ownable, where the new owner must claim ownership of the contract after owner
 * initiates transfer
 * Owner can cancel the transfer at any point before the new owner claims ownership.
 * Helpful in guarding against transferring ownership to an address that is unable to act as the Owner.
 */
abstract contract TwoStepOwnable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address internal potentialOwner;

    event PotentialOwnerUpdated(address newPotentialAdministrator);

    error NewOwnerIsZeroAddress();
    error NotNextOwner();
    error OnlyOwner();

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    constructor() {
        _transferOwnership(msg.sender);
    }

    ///@notice Initiate ownership transfer to newPotentialOwner. Note: new owner will have to manually acceptOwnership
    ///@param newPotentialOwner address of potential new owner
    function transferOwnership(address newPotentialOwner) public virtual onlyOwner {
        if (newPotentialOwner == address(0)) {
            revert NewOwnerIsZeroAddress();
        }
        potentialOwner = newPotentialOwner;
        emit PotentialOwnerUpdated(newPotentialOwner);
    }

    ///@notice Claim ownership of smart contract, after the current owner has initiated the process with
    /// transferOwnership
    function acceptOwnership() public virtual {
        address _potentialOwner = potentialOwner;
        if (msg.sender != _potentialOwner) {
            revert NotNextOwner();
        }
        delete potentialOwner;
        emit PotentialOwnerUpdated(address(0));
        _transferOwnership(_potentialOwner);
    }

    ///@notice cancel ownership transfer
    function cancelOwnershipTransfer() public virtual onlyOwner {
        delete potentialOwner;
        emit PotentialOwnerUpdated(address(0));
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (_owner != msg.sender) {
            revert OnlyOwner();
        }
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
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17 .0;

import { LibPRNG } from "./LibPRNG.sol";
import { LibString } from "./LibString.sol";

/// @title Utils
/// @author Aspyn Palatnick (aspyn.eth, stuckinaboot.eth)
/// @notice Utility functions for constructing onchain Together NFT
library Utils {
  using LibPRNG for LibPRNG.PRNG;
  using LibString for uint256;

  string internal constant BASE64_TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  function svgToURI(string memory _source) internal pure returns (string memory) {
    return string.concat("data:image/svg+xml;base64,", encodeBase64(bytes(_source)));
  }

  function formatTokenURI(
    uint256 _tokenId,
    string memory _imageURI,
    string memory _animationURI,
    string memory _properties
  ) internal pure returns (string memory) {
    return
      string.concat(
        "data:application/json;base64,",
        encodeBase64(
          bytes(
            string.concat(
              '{"name":"Together #',
              _tokenId.toString(),
              '","description":"Together is a generative onchain NFT with colorful art formed by its minters. The art of each token builds on the art of all previous tokens plus a new line generated at the time of mint. Tap once to unwind your art. Tap twice to unwind your mind.","attributes":',
              _properties,
              ',"image":"',
              _imageURI,
              '","animation_url":"',
              _animationURI,
              '"}'
            )
          )
        )
      );
  }

  function getTrait(
    string memory traitType,
    string memory value,
    bool isNumberValue,
    bool includeTrailingComma
  ) internal pure returns (string memory) {
    return
      string.concat(
        '{"trait_type":"',
        traitType,
        '","value":',
        isNumberValue ? value : string.concat('"', value, '"'),
        "}",
        includeTrailingComma ? "," : ""
      );
  }

  // Encode some bytes in base64
  // https://gist.github.com/mbvissers/8ba9ac1eca9ed0ef6973bd49b3c999ba
  function encodeBase64(bytes memory data) internal pure returns (string memory) {
    if (data.length == 0) return "";

    // load the table into memory
    string memory table = BASE64_TABLE;

    unchecked {
      // multiply by 4/3 rounded up
      uint256 encodedLen = 4 * ((data.length + 2) / 3);

      // add some extra buffer at the end required for the writing
      string memory result = new string(encodedLen + 32);

      assembly {
        // set the actual output length
        mstore(result, encodedLen)

        // prepare the lookup table
        let tablePtr := add(table, 1)

        // input ptr
        let dataPtr := data
        let endPtr := add(dataPtr, mload(data))

        // result ptr, jump over length
        let resultPtr := add(result, 32)

        // run over the input, 3 bytes at a time
        for {

        } lt(dataPtr, endPtr) {

        } {
          dataPtr := add(dataPtr, 3)

          // read 3 bytes
          let input := mload(dataPtr)

          // write 4 characters
          mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
          resultPtr := add(resultPtr, 1)
          mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
          resultPtr := add(resultPtr, 1)
          mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F)))))
          resultPtr := add(resultPtr, 1)
          mstore(resultPtr, shl(248, mload(add(tablePtr, and(input, 0x3F)))))
          resultPtr := add(resultPtr, 1)
        }

        // padding with '='
        switch mod(mload(data), 3)
        case 1 {
          mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
        }
        case 2 {
          mstore(sub(resultPtr, 1), shl(248, 0x3d))
        }
      }

      return result;
    }
  }

  function getPackedRGBColor(bytes32 seed) internal pure returns (uint24) {
    LibPRNG.PRNG memory prng;
    prng.seed(seed);
    unchecked {
      return (uint24(prng.uniform(256)) << 16) + (uint24(prng.uniform(256)) << 8) + uint8(prng.uniform(256));
    }
  }

  function getRGBStr(uint24 packedRgb) internal pure returns (string memory) {
    return string.concat("#", uint256(packedRgb).toHexStringNoPrefix(3));
  }
}