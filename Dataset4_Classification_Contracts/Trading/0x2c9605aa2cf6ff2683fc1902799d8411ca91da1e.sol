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
            // The assembly, OnchainDinos with the surrounding Solidity code, have been
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
    function uniform(
        PRNG memory prng,
        uint256 upper
    ) internal pure returns (uint256 result) {
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
pragma solidity >=0.8.17 .0;

interface NFTEventsAndErrors {
    error MaxSupplyReached();
    error IncorrectPayment();
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17 .0;

import { ERC721A } from "@erc721a/ERC721A.sol";
import { NFTEventsAndErrors } from "./NFTEventsAndErrors.sol";
import { Utils } from "./utils/Utils.sol";
import { Constants } from "./utils/Constants.sol";
import { LibString } from "./utils/LibString.sol";
import { LibPRNG } from "./LibPRNG.sol";
import { SVG } from "./utils/SVG.sol";

/// @title onchain dinos
/// @notice onchain dinos is an onchain generative dino NFT inspired by tiny dinos. rawr.
contract OnchainDinos is ERC721A, NFTEventsAndErrors, Constants {
    using LibString for uint256;
    using LibString for uint8;
    using LibPRNG for LibPRNG.PRNG;

    address private immutable _deployer;
    bytes32[MAX_DINOS + 1] internal _tokenToSeed;

    uint8[39] internal colors = [
        3,
        3,
        3,
        3,
        3,
        3,
        3,
        3,
        5,
        2,
        2,
        2,
        2,
        2,
        1,
        2,
        1,
        2,
        5,
        2,
        2,
        2,
        2,
        2,
        2,
        4,
        4,
        2,
        5,
        2,
        2,
        4,
        2,
        2,
        2,
        4,
        4,
        2,
        2
    ];
    uint8[39] internal x = [
        6,
        10,
        7,
        8,
        6,
        7,
        8,
        9,
        5,
        6,
        7,
        8,
        9,
        6,
        7,
        8,
        9,
        10,
        5,
        6,
        7,
        8,
        9,
        10,
        6,
        7,
        8,
        4,
        5,
        6,
        7,
        8,
        9,
        5,
        6,
        7,
        8,
        6,
        8
    ];
    uint8[39] internal y = [
        3,
        4,
        3,
        3,
        4,
        4,
        4,
        4,
        5,
        5,
        5,
        5,
        5,
        6,
        6,
        6,
        6,
        6,
        7,
        7,
        7,
        7,
        7,
        7,
        8,
        8,
        8,
        9,
        9,
        9,
        9,
        9,
        9,
        10,
        10,
        10,
        10,
        11,
        11
    ];

    constructor() ERC721A("onchain dinos", "DINO") {
        _deployer = msg.sender;
    }

    /// @notice Mint tokens.
    /// @param amount amount of tokens to mint
    function mint(uint8 amount) external payable {
        // Checks
        unchecked {
            if (amount * PRICE != msg.value) {
                // Check payment by sender is correct
                revert IncorrectPayment();
            }

            uint256 nextTokenId = _nextTokenId();

            if (MAX_DINOS + 1 < nextTokenId + amount) {
                // Check max supply not exceeded
                revert MaxSupplyReached();
            }

            // Effects
            for (uint256 i = nextTokenId; i < nextTokenId + amount;) {
                _tokenToSeed[i] = keccak256(abi.encodePacked(block.prevrandao, i));
                ++i;
            }
        }

        _mint(msg.sender, amount);
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    /// @notice Withdraw all ETH from the contract.
    function withdraw() external {
        (bool success,) = _deployer.call{ value: address(this).balance }("");
        require(success);
    }

    function getColors(uint256 tokenId)
        public
        view
        returns (string memory dinoColor, string memory prevDinoColor, string memory backgroundColor)
    {
        LibPRNG.PRNG memory dinoPrng;
        dinoPrng.seed(_tokenToSeed[tokenId]);
        uint256 dinoHue = dinoPrng.uniform(360);
        dinoColor = Utils.hslaString(dinoHue, 25 + dinoPrng.uniform(70), 65 + dinoPrng.uniform(15));

        if (tokenId > 1) {
            LibPRNG.PRNG memory prevDinoPrng;
            prevDinoPrng.seed(_tokenToSeed[tokenId - 1]);
            prevDinoColor = Utils.hslaString(
                prevDinoPrng.uniform(360), 25 + prevDinoPrng.uniform(70), 65 + prevDinoPrng.uniform(15)
            );
        } else {
            prevDinoColor = "#FFF";
        }

        backgroundColor = Utils.hslaString((dinoHue + 180) % 360, 60, 80);
    }

    function art(uint256 tokenId) public view returns (string memory) {
        (string memory bodyColor, string memory hatColor, string memory backgroundColor) = getColors(tokenId);

        string memory dino = "";
        unchecked {
            for (uint8 i; i < x.length; ++i) {
                string memory color = colors[i] == 1
                    ? "#FFF"
                    : colors[i] == 2
                        ? bodyColor
                        : colors[i] == 3 ? hatColor : colors[i] == 4 ? "#DBDBDB" : colors[i] == 5 ? "#EDEDED" : "";
                dino = string.concat(
                    dino,
                    SVG.rect(
                        string.concat(
                            SVG.prop("fill", color),
                            SVG.prop("x", x[i].toString()),
                            SVG.prop("y", y[i].toString()),
                            i == 0 ? SVG.prop("id", "a") : i == 1 ? SVG.prop("id", "b") : ""
                        )
                    )
                );
            }
        }

        return string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" shape-rendering="crispEdges" viewBox="0 0 16 16" style="background-color: ',
            backgroundColor,
            '">',
            dino,
            "</svg>"
        );
    }

    /// @notice Get token uri for token.
    /// @param tokenId token id
    /// @return tokenURI
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) {
            revert URIQueryForNonexistentToken();
        }

        string memory artSvg = art(tokenId);

        return Utils.formatTokenURI(
            tokenId,
            Utils.svgToURI(artSvg),
            string.concat(
                "data:text/html;base64,",
                Utils.encodeBase64(
                    bytes(
                        string.concat(
                            '<html style="overflow:hidden"><body style="margin:0">',
                            artSvg,
                            '<script>document.body.addEventListener("click",()=>{let t,e;"6"===document.getElementById("a").getAttribute("x")?(t="9",e="5"):(t="6",e="10"),document.getElementById("a").setAttribute("x",t),document.getElementById("b").setAttribute("x",e)});</script></body></html>'
                        )
                    )
                )
            ),
            string.concat("[", Utils.getTrait("metadata", "onchain", true), Utils.getTrait("dino", "rawr", false), "]")
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17 .0;

contract Constants {
    uint256 public constant PRICE = 0.005 ether;
    uint256 internal constant MAX_DINOS = 1111;
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

library SVG {
    /* MAIN ELEMENTS */

    function line(string memory _props) internal pure returns (string memory) {
        return string.concat("<line ", _props, "/>");
    }

    function rect(string memory _props) internal pure returns (string memory) {
        return string.concat('<rect height="1" width="1" ', _props, "/>");
    }

    /* COMMON */

    // an SVG attribute
    function prop(string memory _key, string memory _val) internal pure returns (string memory) {
        return string.concat(_key, "=", '"', _val, '" ');
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17 .0;

import { LibPRNG } from "./LibPRNG.sol";
import { LibString } from "./LibString.sol";

library Utils {
    using LibPRNG for LibPRNG.PRNG;
    using LibString for uint256;

    string internal constant _BASE64_TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function svgToURI(string memory _source) internal pure returns (string memory) {
        return string.concat("data:image/svg+xml;base64,", encodeBase64(bytes(_source)));
    }

    function formatTokenURI(
        uint256 _tokenId,
        string memory _imageURI,
        string memory _animationURI,
        string memory _properties
    )
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            "data:application/json;base64,",
            encodeBase64(
                bytes(
                    string.concat(
                        '{"name":"onchain dino #',
                        _tokenId.toString(),
                        '","description":"onchain dinos are generative onchain dinos inspired by tiny dinos. the hat each onchain dino is wearing was made by the previous onchain dino.","attributes":',
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
        bool includeTrailingComma
    )
        internal
        pure
        returns (string memory)
    {
        return string.concat('{"trait_type":"', traitType, '","value":"', value, '"}', includeTrailingComma ? "," : "");
    }

    // Encode some bytes in base64
    // https://gist.github.com/mbvissers/8ba9ac1eca9ed0ef6973bd49b3c999ba
    function encodeBase64(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        // load the table into memory
        string memory table = _BASE64_TABLE;

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
                for { } lt(dataPtr, endPtr) { } {
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
                case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
                case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
            }

            return result;
        }
    }

    function hslaString(uint256 hue, uint256 saturation, uint256 lightness) internal pure returns (string memory) {
        return string.concat("hsla(", hue.toString(), ",", saturation.toString(), "%,", lightness.toString(), "%,100%)");
    }
}