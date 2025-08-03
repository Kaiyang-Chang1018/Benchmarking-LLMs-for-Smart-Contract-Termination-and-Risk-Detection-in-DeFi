// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IMagicDropMetadata {
    /*==============================================================
    =                             EVENTS                           =
    ==============================================================*/

    /// @notice Emitted when the contract URI is updated.
    /// @param _contractURI The new contract URI.
    event ContractURIUpdated(string _contractURI);

    /// @notice Emitted when the royalty info is updated.
    /// @param receiver The new royalty receiver.
    /// @param bps The new royalty basis points.
    event RoyaltyInfoUpdated(address receiver, uint256 bps);

    /// @notice Emitted when the metadata is updated. (EIP-4906)
    /// @param _fromTokenId The starting token ID.
    /// @param _toTokenId The ending token ID.
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    /// @notice Emitted once when the token contract is deployed and initialized.
    event MagicDropTokenDeployed();

    /*==============================================================
    =                             ERRORS                           =
    ==============================================================*/

    /// @notice Throw when the max supply is exceeded.
    error CannotExceedMaxSupply();

    /// @notice Throw when the max supply is less than the current supply.
    error MaxSupplyCannotBeLessThanCurrentSupply();

    /// @notice Throw when trying to increase the max supply.
    error MaxSupplyCannotBeIncreased();

    /// @notice Throw when the max supply is greater than 2^64.
    error MaxSupplyCannotBeGreaterThan2ToThe64thPower();

    /*==============================================================
    =                      PUBLIC VIEW METHODS                     =
    ==============================================================*/

    /// @notice Returns the base URI used to construct token URIs
    /// @dev This is concatenated with the token ID to form the complete token URI
    /// @return The base URI string that prefixes all token URIs
    function baseURI() external view returns (string memory);

    /// @notice Returns the contract-level metadata URI
    /// @dev Used by marketplaces like MagicEden to display collection information
    /// @return The URI string pointing to the contract's metadata JSON
    function contractURI() external view returns (string memory);

    /// @notice Returns the address that receives royalty payments
    /// @dev Used in conjunction with royaltyBps for EIP-2981 royalty standard
    /// @return The address designated to receive royalty payments
    function royaltyAddress() external view returns (address);

    /// @notice Returns the royalty percentage in basis points (1/100th of a percent)
    /// @dev 100 basis points = 1%. Used in EIP-2981 royalty calculations
    /// @return The royalty percentage in basis points (e.g., 250 = 2.5%)
    function royaltyBps() external view returns (uint256);

    /*==============================================================
    =                      ADMIN OPERATIONS                        =
    ==============================================================*/

    /// @notice Sets the base URI for all token metadata
    /// @dev This is a critical function that determines where all token metadata is hosted
    ///      Changing this will update the metadata location for all tokens in the collection
    /// @param baseURI The new base URI string that will prefix all token URIs
    function setBaseURI(string calldata baseURI) external;

    /// @notice Sets the contract-level metadata URI
    /// @dev This metadata is used by marketplaces to display collection information
    ///      Should point to a JSON file following collection metadata standards
    /// @param contractURI The new URI string pointing to the contract's metadata JSON
    function setContractURI(string calldata contractURI) external;

    /// @notice Updates the royalty configuration for the collection
    /// @dev Implements EIP-2981 for NFT royalty standards
    ///      The bps (basis points) must be between 0 and 10000 (0% to 100%)
    /// @param newReceiver The address that will receive future royalty payments
    /// @param newBps The royalty percentage in basis points (e.g., 250 = 2.5%)
    function setRoyaltyInfo(address newReceiver, uint96 newBps) external;
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.3.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import {IERC721A} from "erc721a/contracts/IERC721A.sol";

import {Initializable} from "solady/src/utils/Initializable.sol";

/**
 * @dev Interface of ERC721 token receiver.
 */
interface ERC721A__IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4);
}

/**
 * @title ERC721ACloneable
 *
 * @dev Implementation of the [ERC721](https://eips.ethereum.org/EIPS/eip-721)
 * Non-Fungible Token Standard, including the Metadata extension.
 * Optimized for lower gas during batch mints.
 *
 * Token IDs are minted in sequential order (e.g. 0, 1, 2, 3, ...)
 * starting from `_startTokenId()`.
 *
 * The `_sequentialUpTo()` function can be overriden to enable spot mints
 * (i.e. non-consecutive mints) for `tokenId`s greater than `_sequentialUpTo()`.
 *
 * Assumptions:
 *
 * - An owner cannot have more than 2**64 - 1 (max value of uint64) of supply.
 * - The maximum token ID cannot exceed 2**256 - 1 (max value of uint256).
 */
contract ERC721ACloneable is IERC721A, Initializable {
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

    // The amount of tokens minted above `_sequentialUpTo()`.
    // We call these spot mints (i.e. non-sequential mints).
    uint256 private _spotMinted;

    // =============================================================
    //                          INITIALIZER
    // =============================================================

    function __ERC721ACloneable__init(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();

        if (_sequentialUpTo() < _startTokenId()) {
            _revert(SequentialUpToTooSmall.selector);
        }
    }

    // =============================================================
    //                   TOKEN COUNTING OPERATIONS
    // =============================================================

    /**
     * @dev Returns the starting token ID for sequential mints.
     *
     * Override this function to change the starting token ID for sequential mints.
     *
     * Note: The value returned must never change after any tokens have been minted.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Returns the maximum token ID (inclusive) for sequential mints.
     *
     * Override this function to return a value less than 2**256 - 1,
     * but greater than `_startTokenId()`, to enable spot (non-sequential) mints.
     *
     * Note: The value returned must never change after any tokens have been minted.
     */
    function _sequentialUpTo() internal view virtual returns (uint256) {
        return type(uint256).max;
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
    function totalSupply() public view virtual override returns (uint256 result) {
        // Counter underflow is impossible as `_burnCounter` cannot be incremented
        // more than `_currentIndex + _spotMinted - _startTokenId()` times.
        unchecked {
            // With spot minting, the intermediate `result` can be temporarily negative,
            // and the computation must be unchecked.
            result = _currentIndex - _burnCounter - _startTokenId();
            if (_sequentialUpTo() != type(uint256).max) result += _spotMinted;
        }
    }

    /**
     * @dev Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view virtual returns (uint256 result) {
        // Counter underflow is impossible as `_currentIndex` does not decrement,
        // and it is initialized to `_startTokenId()`.
        unchecked {
            result = _currentIndex - _startTokenId();
            if (_sequentialUpTo() != type(uint256).max) result += _spotMinted;
        }
    }

    /**
     * @dev Returns the total number of tokens burned.
     */
    function _totalBurned() internal view virtual returns (uint256) {
        return _burnCounter;
    }

    /**
     * @dev Returns the total number of tokens that are spot-minted.
     */
    function _totalSpotMinted() internal view virtual returns (uint256) {
        return _spotMinted;
    }

    // =============================================================
    //                    ADDRESS DATA OPERATIONS
    // =============================================================

    /**
     * @dev Returns the number of tokens in `owner`'s account.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        if (owner == address(0)) _revert(BalanceQueryForZeroAddress.selector);
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
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) _revert(URIQueryForNonexistentToken.selector);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, it can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
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
     * @dev Returns whether the ownership slot at `index` is initialized.
     * An uninitialized slot does not necessarily mean that the slot has no owner.
     */
    function _ownershipIsInitialized(uint256 index) internal view virtual returns (bool) {
        return _packedOwnerships[index] != 0;
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
     * @dev Returns the packed ownership data of `tokenId`.
     */
    function _packedOwnershipOf(uint256 tokenId) private view returns (uint256 packed) {
        if (_startTokenId() <= tokenId) {
            packed = _packedOwnerships[tokenId];

            if (tokenId > _sequentialUpTo()) {
                if (_packedOwnershipExists(packed)) return packed;
                _revert(OwnerQueryForNonexistentToken.selector);
            }

            // If the data at the starting slot does not exist, start the scan.
            if (packed == 0) {
                if (tokenId >= _currentIndex) {
                    _revert(OwnerQueryForNonexistentToken.selector);
                }
                // Invariant:
                // There will always be an initialized ownership slot
                // (i.e. `ownership.addr != address(0) && ownership.burned == false`)
                // before an unintialized ownership slot
                // (i.e. `ownership.addr == address(0) && ownership.burned == false`)
                // Hence, `tokenId` will not underflow.
                //
                // We can directly compare the packed value.
                // If the address is zero, packed will be zero.
                for (;;) {
                    unchecked {
                        packed = _packedOwnerships[--tokenId];
                    }
                    if (packed == 0) continue;
                    if (packed & _BITMASK_BURNED == 0) return packed;
                    // Otherwise, the token is burned, and we must revert.
                    // This handles the case of batch burned tokens, where only the burned bit
                    // of the starting slot is set, and remaining slots are left uninitialized.
                    _revert(OwnerQueryForNonexistentToken.selector);
                }
            }
            // Otherwise, the data exists and we can skip the scan.
            // This is possible because we have already achieved the target condition.
            // This saves 2143 gas on transfers of initialized tokens.
            // If the token is not burned, return `packed`. Otherwise, revert.
            if (packed & _BITMASK_BURNED == 0) return packed;
        }
        _revert(OwnerQueryForNonexistentToken.selector);
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
     * @dev Gives permission to `to` to transfer `tokenId` token to another account. See {ERC721A-_approve}.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     */
    function approve(address to, uint256 tokenId) public payable virtual override {
        _approve(to, tokenId, true);
    }

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        if (!_exists(tokenId)) {
            _revert(ApprovalQueryForNonexistentToken.selector);
        }

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
    function _exists(uint256 tokenId) internal view virtual returns (bool result) {
        if (_startTokenId() <= tokenId) {
            if (tokenId > _sequentialUpTo()) {
                return _packedOwnershipExists(_packedOwnerships[tokenId]);
            }

            if (tokenId < _currentIndex) {
                uint256 packed;
                while ((packed = _packedOwnerships[tokenId]) == 0) --tokenId;
                result = packed & _BITMASK_BURNED == 0;
            }
        }
    }

    /**
     * @dev Returns whether `packed` represents a token that exists.
     */
    function _packedOwnershipExists(uint256 packed) private pure returns (bool result) {
        assembly {
            // The following is equivalent to `owner != address(0) && burned == false`.
            // Symbolically tested.
            result := gt(and(packed, _BITMASK_ADDRESS), and(packed, _BITMASK_BURNED))
        }
    }

    /**
     * @dev Returns whether `msgSender` is equal to `approvedAddress` or `owner`.
     */
    function _isSenderApprovedOrOwner(address approvedAddress, address owner, address msgSender)
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

        // Mask `from` to the lower 160 bits, in case the upper bits somehow aren't clean.
        from = address(uint160(uint256(uint160(from)) & _BITMASK_ADDRESS));

        if (address(uint160(prevOwnershipPacked)) != from) {
            _revert(TransferFromIncorrectOwner.selector);
        }

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

        // The nested ifs save around 20+ gas over a compound boolean condition.
        if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSenderERC721A())) {
            if (!isApprovedForAll(from, _msgSenderERC721A())) {
                _revert(TransferCallerNotOwnerNorApproved.selector);
            }
        }

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

        // Mask `to` to the lower 160 bits, in case the upper bits somehow aren't clean.
        uint256 toMasked = uint256(uint160(to)) & _BITMASK_ADDRESS;
        assembly {
            // Emit the `Transfer` event.
            log4(
                0, // Start of data (0, since no data).
                0, // End of data (0, since no data).
                _TRANSFER_EVENT_SIGNATURE, // Signature.
                from, // `from`.
                toMasked, // `to`.
                tokenId // `tokenId`.
            )
        }
        if (toMasked == 0) _revert(TransferToZeroAddress.selector);

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data)
        public
        payable
        virtual
        override
    {
        transferFrom(from, to, tokenId);
        if (to.code.length != 0) {
            if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
                _revert(TransferToNonERC721ReceiverImplementer.selector);
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
    function _beforeTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal virtual {}

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
    function _afterTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal virtual {}

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
    function _checkContractOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private
        returns (bool)
    {
        try ERC721A__IERC721Receiver(to).onERC721Received(_msgSenderERC721A(), from, tokenId, _data) returns (
            bytes4 retval
        ) {
            return retval == ERC721A__IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                _revert(TransferToNonERC721ReceiverImplementer.selector);
            }
            assembly {
                revert(add(32, reason), mload(reason))
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
        if (quantity == 0) _revert(MintZeroQuantity.selector);

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // `balance` and `numberMinted` have a maximum limit of 2**64.
        // `tokenId` has a maximum limit of 2**256.
        unchecked {
            // Updates:
            // - `address` to the owner.
            // - `startTimestamp` to the timestamp of minting.
            // - `burned` to `false`.
            // - `nextInitialized` to `quantity == 1`.
            _packedOwnerships[startTokenId] =
                _packOwnershipData(to, _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0));

            // Updates:
            // - `balance += quantity`.
            // - `numberMinted += quantity`.
            //
            // We can directly add to the `balance` and `numberMinted`.
            _packedAddressData[to] += quantity * ((1 << _BITPOS_NUMBER_MINTED) | 1);

            // Mask `to` to the lower 160 bits, in case the upper bits somehow aren't clean.
            uint256 toMasked = uint256(uint160(to)) & _BITMASK_ADDRESS;

            if (toMasked == 0) _revert(MintToZeroAddress.selector);

            uint256 end = startTokenId + quantity;
            uint256 tokenId = startTokenId;

            if (end - 1 > _sequentialUpTo()) {
                _revert(SequentialMintExceedsLimit.selector);
            }

            do {
                assembly {
                    // Emit the `Transfer` event.
                    log4(
                        0, // Start of data (0, since no data).
                        0, // End of data (0, since no data).
                        _TRANSFER_EVENT_SIGNATURE, // Signature.
                        0, // `address(0)`.
                        toMasked, // `to`.
                        tokenId // `tokenId`.
                    )
                }
                // The `!=` check ensures that large values of `quantity`
                // that overflows uint256 will make the loop run out of gas.
            } while (++tokenId != end);

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
        if (to == address(0)) _revert(MintToZeroAddress.selector);
        if (quantity == 0) _revert(MintZeroQuantity.selector);
        if (quantity > _MAX_MINT_ERC2309_QUANTITY_LIMIT) {
            _revert(MintERC2309QuantityExceedsLimit.selector);
        }

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

            if (startTokenId + quantity - 1 > _sequentialUpTo()) {
                _revert(SequentialMintExceedsLimit.selector);
            }

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
                        _revert(TransferToNonERC721ReceiverImplementer.selector);
                    }
                } while (index < end);
                // This prevents reentrancy to `_safeMint`.
                // It does not prevent reentrancy to `_safeMintSpot`.
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

    /**
     * @dev Mints a single token at `tokenId`.
     *
     * Note: A spot-minted `tokenId` that has been burned can be re-minted again.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` must be greater than `_sequentialUpTo()`.
     * - `tokenId` must not exist.
     *
     * Emits a {Transfer} event for each mint.
     */
    function _mintSpot(address to, uint256 tokenId) internal virtual {
        if (tokenId <= _sequentialUpTo()) {
            _revert(SpotMintTokenIdTooSmall.selector);
        }
        uint256 prevOwnershipPacked = _packedOwnerships[tokenId];
        if (_packedOwnershipExists(prevOwnershipPacked)) {
            _revert(TokenAlreadyExists.selector);
        }

        _beforeTokenTransfers(address(0), to, tokenId, 1);

        // Overflows are incredibly unrealistic.
        // The `numberMinted` for `to` is incremented by 1, and has a max limit of 2**64 - 1.
        // `_spotMinted` is incremented by 1, and has a max limit of 2**256 - 1.
        unchecked {
            // Updates:
            // - `address` to the owner.
            // - `startTimestamp` to the timestamp of minting.
            // - `burned` to `false`.
            // - `nextInitialized` to `true` (as `quantity == 1`).
            _packedOwnerships[tokenId] =
                _packOwnershipData(to, _nextInitializedFlag(1) | _nextExtraData(address(0), to, prevOwnershipPacked));

            // Updates:
            // - `balance += 1`.
            // - `numberMinted += 1`.
            //
            // We can directly add to the `balance` and `numberMinted`.
            _packedAddressData[to] += (1 << _BITPOS_NUMBER_MINTED) | 1;

            // Mask `to` to the lower 160 bits, in case the upper bits somehow aren't clean.
            uint256 toMasked = uint256(uint160(to)) & _BITMASK_ADDRESS;

            if (toMasked == 0) _revert(MintToZeroAddress.selector);

            assembly {
                // Emit the `Transfer` event.
                log4(
                    0, // Start of data (0, since no data).
                    0, // End of data (0, since no data).
                    _TRANSFER_EVENT_SIGNATURE, // Signature.
                    0, // `address(0)`.
                    toMasked, // `to`.
                    tokenId // `tokenId`.
                )
            }

            ++_spotMinted;
        }

        _afterTokenTransfers(address(0), to, tokenId, 1);
    }

    /**
     * @dev Safely mints a single token at `tokenId`.
     *
     * Note: A spot-minted `tokenId` that has been burned can be re-minted again.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}.
     * - `tokenId` must be greater than `_sequentialUpTo()`.
     * - `tokenId` must not exist.
     *
     * See {_mintSpot}.
     *
     * Emits a {Transfer} event.
     */
    function _safeMintSpot(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mintSpot(to, tokenId);

        unchecked {
            if (to.code.length != 0) {
                uint256 currentSpotMinted = _spotMinted;
                if (!_checkContractOnERC721Received(address(0), to, tokenId, _data)) {
                    _revert(TransferToNonERC721ReceiverImplementer.selector);
                }
                // This prevents reentrancy to `_safeMintSpot`.
                // It does not prevent reentrancy to `_safeMint`.
                if (_spotMinted != currentSpotMinted) revert();
            }
        }
    }

    /**
     * @dev Equivalent to `_safeMintSpot(to, tokenId, '')`.
     */
    function _safeMintSpot(address to, uint256 tokenId) internal virtual {
        _safeMintSpot(to, tokenId, "");
    }

    // =============================================================
    //                       APPROVAL OPERATIONS
    // =============================================================

    /**
     * @dev Equivalent to `_approve(to, tokenId, false)`.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _approve(to, tokenId, false);
    }

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the
     * zero address clears previous approvals.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId, bool approvalCheck) internal virtual {
        address owner = ownerOf(tokenId);

        if (approvalCheck && _msgSenderERC721A() != owner) {
            if (!isApprovedForAll(owner, _msgSenderERC721A())) {
                _revert(ApprovalCallerNotOwnerNorApproved.selector);
            }
        }

        _tokenApprovals[tokenId].value = to;
        emit Approval(owner, to, tokenId);
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
                if (!isApprovedForAll(from, _msgSenderERC721A())) {
                    _revert(TransferCallerNotOwnerNorApproved.selector);
                }
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

        // Overflow not possible, as `_burnCounter` cannot be exceed `_currentIndex + _spotMinted` times.
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
        if (packed == 0) _revert(OwnershipNotInitializedForExtraData.selector);
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
    function _extraData(address from, address to, uint24 previousExtraData) internal view virtual returns (uint24) {}

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
            for { let temp := value } 1 {} {
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

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC721AQueryableCloneable} from "./ERC721AQueryableCloneable.sol";
import {ERC721ACloneable} from "./ERC721ACloneable.sol";
import {IERC721A} from "erc721a/contracts/IERC721A.sol";

/// @title  ERC721AConduitPreapprovedCloneable
/// @notice ERC721A with the MagicEden conduit preapproved.
abstract contract ERC721AConduitPreapprovedCloneable is ERC721AQueryableCloneable {
    /// @dev The canonical MagicEden conduit.
    address internal constant _CONDUIT = 0x2052f8A2Ff46283B30084e5d84c89A2fdBE7f74b;

    /// @dev Returns if the `operator` is allowed to manage all of the
    ///     assets of `owner`. Always returns true for the conduit.
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override(ERC721ACloneable, IERC721A)
        returns (bool)
    {
        if (operator == _CONDUIT) {
            return true;
        }

        return ERC721ACloneable.isApprovedForAll(owner, operator);
    }
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.3.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import {IERC721AQueryable} from "erc721a/contracts/extensions/IERC721AQueryable.sol";
import {ERC721ACloneable} from "./ERC721ACloneable.sol";

/**
 * @title ERC721AQueryableCloneable.
 *
 * @dev ERC721A subclass with convenience query functions.
 */
abstract contract ERC721AQueryableCloneable is ERC721ACloneable, IERC721AQueryable {
    /**
     * @dev Returns the `TokenOwnership` struct at `tokenId` without reverting.
     *
     * If the `tokenId` is out of bounds:
     *
     * - `addr = address(0)`
     * - `startTimestamp = 0`
     * - `burned = false`
     * - `extraData = 0`
     *
     * If the `tokenId` is burned:
     *
     * - `addr = <Address of owner before token was burned>`
     * - `startTimestamp = <Timestamp when token was burned>`
     * - `burned = true`
     * - `extraData = <Extra data when token was burned>`
     *
     * Otherwise:
     *
     * - `addr = <Address of owner>`
     * - `startTimestamp = <Timestamp of start of ownership>`
     * - `burned = false`
     * - `extraData = <Extra data at start of ownership>`
     */
    function explicitOwnershipOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (TokenOwnership memory ownership)
    {
        unchecked {
            if (tokenId >= _startTokenId()) {
                if (tokenId > _sequentialUpTo()) return _ownershipAt(tokenId);

                if (tokenId < _nextTokenId()) {
                    // If the `tokenId` is within bounds,
                    // scan backwards for the initialized ownership slot.
                    while (!_ownershipIsInitialized(tokenId)) --tokenId;
                    return _ownershipAt(tokenId);
                }
            }
        }
    }

    /**
     * @dev Returns an array of `TokenOwnership` structs at `tokenIds` in order.
     * See {ERC721AQueryable-explicitOwnershipOf}
     */
    function explicitOwnershipsOf(uint256[] calldata tokenIds)
        external
        view
        virtual
        override
        returns (TokenOwnership[] memory)
    {
        TokenOwnership[] memory ownerships;
        uint256 i = tokenIds.length;
        assembly {
            // Grab the free memory pointer.
            ownerships := mload(0x40)
            // Store the length.
            mstore(ownerships, i)
            // Allocate one word for the length,
            // `tokenIds.length` words for the pointers.
            i := shl(5, i) // Multiply `i` by 32.
            mstore(0x40, add(add(ownerships, 0x20), i))
        }
        while (i != 0) {
            uint256 tokenId;
            assembly {
                i := sub(i, 0x20)
                tokenId := calldataload(add(tokenIds.offset, i))
            }
            TokenOwnership memory ownership = explicitOwnershipOf(tokenId);
            assembly {
                // Store the pointer of `ownership` in the `ownerships` array.
                mstore(add(add(ownerships, 0x20), i), ownership)
            }
        }
        return ownerships;
    }

    /**
     * @dev Returns an array of token IDs owned by `owner`,
     * in the range [`start`, `stop`)
     * (i.e. `start <= tokenId < stop`).
     *
     * This function allows for tokens to be queried if the collection
     * grows too big for a single call of {ERC721AQueryable-tokensOfOwner}.
     *
     * Requirements:
     *
     * - `start < stop`
     */
    function tokensOfOwnerIn(address owner, uint256 start, uint256 stop)
        external
        view
        virtual
        override
        returns (uint256[] memory)
    {
        return _tokensOfOwnerIn(owner, start, stop);
    }

    /**
     * @dev Returns an array of token IDs owned by `owner`.
     *
     * This function scans the ownership mapping and is O(`totalSupply`) in complexity.
     * It is meant to be called off-chain.
     *
     * See {ERC721AQueryable-tokensOfOwnerIn} for splitting the scan into
     * multiple smaller scans if the collection is large enough to cause
     * an out-of-gas error (10K collections should be fine).
     */
    function tokensOfOwner(address owner) external view virtual override returns (uint256[] memory) {
        // If spot mints are enabled, full-range scan is disabled.
        if (_sequentialUpTo() != type(uint256).max) {
            _revert(NotCompatibleWithSpotMints.selector);
        }
        uint256 start = _startTokenId();
        uint256 stop = _nextTokenId();
        uint256[] memory tokenIds;
        if (start != stop) tokenIds = _tokensOfOwnerIn(owner, start, stop);
        return tokenIds;
    }

    /**
     * @dev Helper function for returning an array of token IDs owned by `owner`.
     *
     * Note that this function is optimized for smaller bytecode size over runtime gas,
     * since it is meant to be called off-chain.
     */
    function _tokensOfOwnerIn(address owner, uint256 start, uint256 stop)
        private
        view
        returns (uint256[] memory tokenIds)
    {
        unchecked {
            if (start >= stop) _revert(InvalidQueryRange.selector);
            // Set `start = max(start, _startTokenId())`.
            if (start < _startTokenId()) start = _startTokenId();
            uint256 nextTokenId = _nextTokenId();
            // If spot mints are enabled, scan all the way until the specified `stop`.
            uint256 stopLimit = _sequentialUpTo() != type(uint256).max ? stop : nextTokenId;
            // Set `stop = min(stop, stopLimit)`.
            if (stop >= stopLimit) stop = stopLimit;
            // Number of tokens to scan.
            uint256 tokenIdsMaxLength = balanceOf(owner);
            // Set `tokenIdsMaxLength` to zero if the range contains no tokens.
            if (start >= stop) tokenIdsMaxLength = 0;
            // If there are one or more tokens to scan.
            if (tokenIdsMaxLength != 0) {
                // Set `tokenIdsMaxLength = min(balanceOf(owner), tokenIdsMaxLength)`.
                if (stop - start <= tokenIdsMaxLength) {
                    tokenIdsMaxLength = stop - start;
                }
                uint256 m; // Start of available memory.
                assembly {
                    // Grab the free memory pointer.
                    tokenIds := mload(0x40)
                    // Allocate one word for the length, and `tokenIdsMaxLength` words
                    // for the data. `shl(5, x)` is equivalent to `mul(32, x)`.
                    m := add(tokenIds, shl(5, add(tokenIdsMaxLength, 1)))
                    mstore(0x40, m)
                }
                // We need to call `explicitOwnershipOf(start)`,
                // because the slot at `start` may not be initialized.
                TokenOwnership memory ownership = explicitOwnershipOf(start);
                address currOwnershipAddr;
                // If the starting slot exists (i.e. not burned),
                // initialize `currOwnershipAddr`.
                // `ownership.address` will not be zero,
                // as `start` is clamped to the valid token ID range.
                if (!ownership.burned) currOwnershipAddr = ownership.addr;
                uint256 tokenIdsIdx;
                // Use a do-while, which is slightly more efficient for this case,
                // as the array will at least contain one element.
                do {
                    if (_sequentialUpTo() != type(uint256).max) {
                        // Skip the remaining unused sequential slots.
                        if (start == nextTokenId) start = _sequentialUpTo() + 1;
                        // Reset `currOwnershipAddr`, as each spot-minted token is a batch of one.
                        if (start > _sequentialUpTo()) {
                            currOwnershipAddr = address(0);
                        }
                    }
                    ownership = _ownershipAt(start); // This implicitly allocates memory.
                    assembly {
                        switch mload(add(ownership, 0x40))
                        // if `ownership.burned == false`.
                        case 0 {
                            // if `ownership.addr != address(0)`.
                            // The `addr` already has it's upper 96 bits clearned,
                            // since it is written to memory with regular Solidity.
                            if mload(ownership) { currOwnershipAddr := mload(ownership) }
                            // if `currOwnershipAddr == owner`.
                            // The `shl(96, x)` is to make the comparison agnostic to any
                            // dirty upper 96 bits in `owner`.
                            if iszero(shl(96, xor(currOwnershipAddr, owner))) {
                                tokenIdsIdx := add(tokenIdsIdx, 1)
                                mstore(add(tokenIds, shl(5, tokenIdsIdx)), start)
                            }
                        }
                        // Otherwise, reset `currOwnershipAddr`.
                        // This handles the case of batch burned tokens
                        // (burned bit of first slot set, remaining slots left uninitialized).
                        default { currOwnershipAddr := 0 }
                        start := add(start, 1)
                        // Free temporary memory implicitly allocated for ownership
                        // to avoid quadratic memory expansion costs.
                        mstore(0x40, m)
                    }
                } while (!(start == stop || tokenIdsIdx == tokenIdsMaxLength));
                // Store the length of the array.
                assembly {
                    mstore(tokenIds, tokenIdsIdx)
                }
            }
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {MerkleProofLib} from "solady/src/utils/MerkleProofLib.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";

import {IERC721A} from "erc721a/contracts/IERC721A.sol";

import {ERC721MagicDropMetadataCloneable} from "./ERC721MagicDropMetadataCloneable.sol";
import {ERC721ACloneable} from "./ERC721ACloneable.sol";
import {IERC721MagicDropMetadata} from "../interfaces/IERC721MagicDropMetadata.sol";
import {PublicStage, AllowlistStage, SetupConfig} from "./Types.sol";

///                                                     ........
///                             .....                   ..    ...
///                            ..    .....             ..     ..
///                            ..  ... .....           ..     ..
///                            ..  ......  ..          ...... ..
///                             ..   .........     .........  ....
///                             ....        ..   ..        ...
///                                ........  .........     ..
///                                    ..       ...  ...  ..       .........
///                                  ..    ..........  ....    .... ....... ........
///                                  .......     .. ..  ...    .... .....          ..
///                                                ........  .    ...  ..             ..
///                    .                       .....       ........     ....          ..
///                  .. ..                  ...              ...........   ...     ...
///               .......                 ..  ......                  ...          ..
///              ............           ...  ........                   ..          ..
///              ...  ..... ..        ..   ..    ..                     ..  ......
///          .. ........    ...     ..    ..   ..                ....   ....
///          .......         ..   ..     ......                .......    ..
///              ..           .....                            .. ....     ..
///              ..           ....    .........                .    ..     ..
///                ...       ....    ..       .........        .    ..     ..
///                  ....   ....     ..              .....     ......      ...
///                       .....      ..   ........         ...             ...
///                        ...       .. ..       .. ......   .....         ..
///                        ..         ....        ...    ...     ..        ..
///                       ..           ....                ..    ..        ..
///                       .              ......             ..  ..         ..
///                      ..                ......................         ..............
///                      ..                   ................           ....          ...
///                      .                                              ...           ........
///                       ..                                             ...          ......  ..
///                        ..                                            ....        ...EMMY....
///                         ..                                           .. ...     ....  .... ..
///                           ..                                         ..    ..... ..........
///                            ...                                      ..          ... ......
///                          ... ....                                  ..                 ..
///                         ..      .....                            ...
///                       .....          ....     ........         ...
///                       ........        .. .....       ..........
///                       .. ........    ..    ..MAGIC.....  .
///                        ....       ....    ....  ..EDEN....
///                             .....         . ...     ......
///                                           ..   .......  ..
///                                            .....    .....
///                                                  ....
/// @title ERC721MagicDropCloneable
/// @notice A cloneable ERC-721A drop contract that supports both a public minting stage and an allowlist minting stage.
/// @dev This contract extends metadata configuration, ownership, and royalty support from its parent, while adding
///      time-gated, price-defined minting stages. It also incorporates a payout recipient and protocol fee structure.
contract ERC721MagicDropCloneable is ERC721MagicDropMetadataCloneable {
    /*==============================================================
    =                            STORAGE                           =
    ==============================================================*/

    /// @dev Address that receives the primary sale proceeds of minted tokens.
    ///      Configurable by the owner. If unset, withdrawals may fail.
    address private _payoutRecipient;

    /// @dev The address that receives protocol fees on withdrawal.
    /// @notice This is fixed and cannot be changed.
    address public constant PROTOCOL_FEE_RECIPIENT = 0xA3833016a4eC61f5c253D71c77522cC8A1cC1106;

    /// @dev The protocol fee expressed in basis points (e.g., 500 = 5%).
    /// @notice This fee is taken from the contract's entire balance upon withdrawal.
    uint256 public constant PROTOCOL_FEE_BPS = 0; // 0%

    /// @dev The denominator used for calculating basis points.
    /// @notice 10,000 BPS = 100%. A fee of 500 BPS is therefore 5%.
    uint256 public constant BPS_DENOMINATOR = 10_000;

    /// @dev Configuration of the public mint stage, including timing and price.
    /// @notice Public mints occur only if the current timestamp is within [startTime, endTime].
    PublicStage private _publicStage;

    /// @dev Configuration of the allowlist mint stage, including timing, price, and a merkle root for verification.
    /// @notice Only addresses proven by a valid Merkle proof can mint during this stage.
    AllowlistStage private _allowlistStage;

    /*==============================================================
    =                             EVENTS                           =
    ==============================================================*/

    /// @notice Emitted when the public mint stage is set.
    event PublicStageSet(PublicStage stage);

    /// @notice Emitted when the allowlist mint stage is set.
    event AllowlistStageSet(AllowlistStage stage);

    /// @notice Emitted when the payout recipient is set.
    event PayoutRecipientSet(address newPayoutRecipient);

    /// @notice Emitted when a token is minted.
    event TokenMinted(address indexed to, uint256 tokenId, uint256 qty);

    /*==============================================================
    =                             ERRORS                           =
    ==============================================================*/

    /// @notice Thrown when attempting to mint during a public stage that is not currently active.
    error PublicStageNotActive();

    /// @notice Thrown when attempting to mint during an allowlist stage that is not currently active.
    error AllowlistStageNotActive();

    /// @notice Thrown when the provided ETH value for a mint is insufficient.
    error RequiredValueNotMet();

    /// @notice Thrown when the provided Merkle proof for an allowlist mint is invalid.
    error InvalidProof();

    /// @notice Thrown when a stage's start or end time configuration is invalid.
    error InvalidStageTime();

    /// @notice Thrown when the allowlist stage timing conflicts with the public stage timing.
    error InvalidAllowlistStageTime();

    /// @notice Thrown when the public stage timing conflicts with the allowlist stage timing.
    error InvalidPublicStageTime();

    /// @notice Thrown when the payout recipient is set to a zero address.
    error PayoutRecipientCannotBeZeroAddress();

    /*==============================================================
    =                          INITIALIZERS                        =
    ==============================================================*/

    /// @notice Initializes the contract with a name, symbol, and owner.
    /// @dev Can only be called once. It sets the owner, emits a deploy event, and prepares the token for minting stages.
    /// @param _name The ERC-721 name of the collection.
    /// @param _symbol The ERC-721 symbol of the collection.
    /// @param _owner The address designated as the initial owner of the contract.
    function initialize(string memory _name, string memory _symbol, address _owner) public initializer {
        __ERC721ACloneable__init(_name, _symbol);
        __ERC721MagicDropMetadataCloneable__init(_owner);
    }

    /*==============================================================
    =                     PUBLIC WRITE METHODS                     =
    ==============================================================*/

    /// @notice Mints tokens during the public stage.
    /// @dev Requires that the current time is within the configured public stage interval.
    ///      Reverts if the buyer does not send enough ETH, or if the wallet limit would be exceeded.
    /// @param to The recipient address for the minted tokens.
    /// @param qty The number of tokens to mint.
    function mintPublic(address to, uint256 qty) external payable {
        PublicStage memory stage = _publicStage;
        if (block.timestamp < stage.startTime || block.timestamp > stage.endTime) {
            revert PublicStageNotActive();
        }

        uint256 requiredPayment = stage.price * qty;
        if (msg.value != requiredPayment) {
            revert RequiredValueNotMet();
        }

        if (_walletLimit > 0 && _numberMinted(to) + qty > _walletLimit) {
            revert WalletLimitExceeded();
        }

        if (_totalMinted() + qty > _maxSupply) {
            revert CannotExceedMaxSupply();
        }

        _safeMint(to, qty);

        if (stage.price != 0) {
            _splitProceeds();
        }

        emit TokenMinted(to, _totalMinted(), qty);
    }

    /// @notice Mints tokens during the allowlist stage.
    /// @dev Requires a valid Merkle proof and the current time within the allowlist stage interval.
    ///      Reverts if the buyer sends insufficient ETH or if the wallet limit is exceeded.
    /// @param to The recipient address for the minted tokens.
    /// @param qty The number of tokens to mint.
    /// @param proof The Merkle proof verifying `to` is eligible for the allowlist.
    function mintAllowlist(address to, uint256 qty, bytes32[] calldata proof) external payable {
        AllowlistStage memory stage = _allowlistStage;
        if (block.timestamp < stage.startTime || block.timestamp > stage.endTime) {
            revert AllowlistStageNotActive();
        }

        if (!MerkleProofLib.verify(proof, stage.merkleRoot, keccak256(bytes.concat(keccak256(abi.encode(to)))))) {
            revert InvalidProof();
        }

        uint256 requiredPayment = stage.price * qty;
        if (msg.value != requiredPayment) {
            revert RequiredValueNotMet();
        }

        if (_walletLimit > 0 && _numberMinted(to) + qty > _walletLimit) {
            revert WalletLimitExceeded();
        }

        if (_totalMinted() + qty > _maxSupply) {
            revert CannotExceedMaxSupply();
        }

        _safeMint(to, qty);

        if (stage.price != 0) {
            _splitProceeds();
        }
    }

    /// @notice Burns a specific token.
    /// @dev Only callable by the token owner or an approved operator. The token must exist.
    /// @param tokenId The ID of the token to burn.
    function burn(uint256 tokenId) external {
        _burn(tokenId, true);
    }

    /*==============================================================
    =                      PUBLIC VIEW METHODS                     =
    ==============================================================*/

    /// @notice Returns the current configuration of the contract.
    /// @return The current configuration of the contract.
    function getConfig() external view returns (SetupConfig memory) {
        SetupConfig memory newConfig = SetupConfig({
            maxSupply: _maxSupply,
            walletLimit: _walletLimit,
            baseURI: _baseURI(),
            contractURI: _contractURI,
            allowlistStage: _allowlistStage,
            publicStage: _publicStage,
            payoutRecipient: _payoutRecipient,
            royaltyRecipient: _royaltyReceiver,
            royaltyBps: _royaltyBps
        });

        return newConfig;
    }

    /// @notice Returns the current public stage configuration (startTime, endTime, price).
    /// @return The current public stage settings.
    function getPublicStage() external view returns (PublicStage memory) {
        return _publicStage;
    }

    /// @notice Returns the current allowlist stage configuration (startTime, endTime, price, merkleRoot).
    /// @return The current allowlist stage settings.
    function getAllowlistStage() external view returns (AllowlistStage memory) {
        return _allowlistStage;
    }

    /// @notice Returns the current payout recipient who receives primary sales proceeds after protocol fees.
    /// @return The address currently set to receive payout funds.
    function payoutRecipient() external view returns (address) {
        return _payoutRecipient;
    }

    /// @notice Indicates whether the contract implements a given interface.
    /// @param interfaceId The interface ID to check for support.
    /// @return True if the interface is supported, false otherwise.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721MagicDropMetadataCloneable)
        returns (bool)
    {
        return interfaceId == type(IERC721MagicDropMetadata).interfaceId || super.supportsInterface(interfaceId);
    }

    /*==============================================================
    =                      ADMIN OPERATIONS                        =
    ==============================================================*/

    /// @notice Sets up the contract parameters in a single call.
    /// @dev Only callable by the owner. Configures max supply, wallet limit, URIs, stages, payout recipient.
    /// @param config A struct containing all setup parameters.
    function setup(SetupConfig calldata config) external onlyOwner {
        if (config.maxSupply > 0) {
            _setMaxSupply(config.maxSupply);
        }

        if (config.walletLimit > 0) {
            _setWalletLimit(config.walletLimit);
        }

        if (bytes(config.baseURI).length > 0) {
            _setBaseURI(config.baseURI);
        }

        if (bytes(config.contractURI).length > 0) {
            _setContractURI(config.contractURI);
        }

        if (config.allowlistStage.startTime != 0 || config.allowlistStage.endTime != 0) {
            _setAllowlistStage(config.allowlistStage);
        }

        if (config.publicStage.startTime != 0 || config.publicStage.endTime != 0) {
            _setPublicStage(config.publicStage);
        }

        if (config.payoutRecipient != address(0)) {
            _setPayoutRecipient(config.payoutRecipient);
        }

        if (config.royaltyRecipient != address(0)) {
            _setRoyaltyInfo(config.royaltyRecipient, config.royaltyBps);
        }
    }

    /// @notice Sets the configuration of the public mint stage.
    /// @dev Only callable by the owner. Ensures the public stage does not overlap improperly with the allowlist stage.
    /// @param stage A struct defining the public stage timing and price.
    function setPublicStage(PublicStage calldata stage) external onlyOwner {
        _setPublicStage(stage);
    }

    /// @notice Sets the configuration of the allowlist mint stage.
    /// @dev Only callable by the owner. Ensures the allowlist stage does not overlap improperly with the public stage.
    /// @param stage A struct defining the allowlist stage timing, price, and merkle root.
    function setAllowlistStage(AllowlistStage calldata stage) external onlyOwner {
        _setAllowlistStage(stage);
    }

    /// @notice Sets the payout recipient address for primary sale proceeds (after the protocol fee is deducted).
    /// @dev Only callable by the owner.
    /// @param newPayoutRecipient The address to receive future withdrawals.
    function setPayoutRecipient(address newPayoutRecipient) external onlyOwner {
        _setPayoutRecipient(newPayoutRecipient);
    }

    /*==============================================================
    =                      INTERNAL HELPERS                        =
    ==============================================================*/

    /// @notice Internal function to set the public mint stage configuration.
    /// @dev Reverts if timing is invalid or conflicts with the allowlist stage.
    /// @param stage A struct defining public stage timings and price.
    function _setPublicStage(PublicStage calldata stage) internal {
        if (stage.startTime >= stage.endTime) {
            revert InvalidStageTime();
        }

        // Ensure the public stage starts after the allowlist stage ends
        if (_allowlistStage.startTime != 0 && _allowlistStage.endTime != 0) {
            if (stage.startTime <= _allowlistStage.endTime) {
                revert InvalidPublicStageTime();
            }
        }

        _publicStage = stage;
        emit PublicStageSet(stage);
    }

    /// @notice Internal function to set the allowlist mint stage configuration.
    /// @dev Reverts if timing is invalid or conflicts with the public stage.
    /// @param stage A struct defining allowlist stage timings, price, and merkle root.
    function _setAllowlistStage(AllowlistStage calldata stage) internal {
        if (stage.startTime >= stage.endTime) {
            revert InvalidStageTime();
        }

        // Ensure the public stage starts after the allowlist stage ends
        if (_publicStage.startTime != 0 && _publicStage.endTime != 0) {
            if (stage.endTime >= _publicStage.startTime) {
                revert InvalidAllowlistStageTime();
            }
        }

        _allowlistStage = stage;
        emit AllowlistStageSet(stage);
    }

    /// @notice Internal function to set the payout recipient.
    /// @dev This function does not revert if given a zero address, but no payouts would succeed if so.
    /// @param newPayoutRecipient The address to receive the payout from mint proceeds.
    function _setPayoutRecipient(address newPayoutRecipient) internal {
        _payoutRecipient = newPayoutRecipient;
        emit PayoutRecipientSet(newPayoutRecipient);
    }

    /// @notice Internal function to split the proceeds of a mint.
    /// @dev This function is called by the mint functions to split the proceeds into a protocol fee and a payout.
    function _splitProceeds() internal {
        if (_payoutRecipient == address(0)) {
            revert PayoutRecipientCannotBeZeroAddress();
        }

        if (PROTOCOL_FEE_BPS > 0) {
            uint256 protocolFee = (msg.value * PROTOCOL_FEE_BPS) / BPS_DENOMINATOR;
            uint256 remainingBalance;
            unchecked {
                remainingBalance = msg.value - protocolFee;
            }
            SafeTransferLib.safeTransferETH(PROTOCOL_FEE_RECIPIENT, protocolFee);
            SafeTransferLib.safeTransferETH(_payoutRecipient, remainingBalance);
        } else {
            SafeTransferLib.safeTransferETH(_payoutRecipient, msg.value);
        }
    }

    /*==============================================================
    =                             META                             =
    ==============================================================*/

    /// @notice Returns the contract name and version.
    /// @dev Useful for external tools or metadata standards.
    /// @return The contract name and version strings.
    function contractNameAndVersion() public pure returns (string memory, string memory) {
        return ("ERC721MagicDropCloneable", "1.0.0");
    }

    /// @notice Retrieves the token metadata URI for a given token ID.
    /// @dev If no base URI is set, returns an empty string.
    ///      If a trailing slash is present, tokenId is appended; otherwise returns just the base URI.
    /// @param tokenId The ID of the token to retrieve the URI for.
    /// @return The token's metadata URI as a string.
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721ACloneable, IERC721A)
        returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        bool isBaseURIEmpty = bytes(baseURI).length == 0;
        bool hasNoTrailingSlash = !isBaseURIEmpty && bytes(baseURI)[bytes(baseURI).length - 1] != bytes("/")[0];

        if (isBaseURIEmpty) {
            return "";
        }
        if (hasNoTrailingSlash) {
            return baseURI;
        }

        return string(abi.encodePacked(baseURI, _toString(tokenId)));
    }

    /*==============================================================
    =                             MISC                             =
    ==============================================================*/

    /// @dev Overridden to allow this contract to properly manage owner initialization.
    ///      By always returning true, we ensure that the inherited initializer does not re-run.
    function _guardInitializeOwner() internal pure virtual override returns (bool) {
        return true;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC2981} from "solady/src/tokens/ERC2981.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

import {IERC721A} from "erc721a/contracts/IERC721A.sol";

import {ERC721AConduitPreapprovedCloneable} from "./ERC721AConduitPreapprovedCloneable.sol";
import {ERC721ACloneable} from "./ERC721ACloneable.sol";
import {IERC721MagicDropMetadata} from "../interfaces/IERC721MagicDropMetadata.sol";

/// @title ERC721MagicDropMetadataCloneable
/// @notice A cloneable ERC-721A implementation that supports adjustable metadata URIs, royalty configuration.
///         Inherits conduit-based preapprovals, making distribution more gas-efficient.
contract ERC721MagicDropMetadataCloneable is
    ERC721AConduitPreapprovedCloneable,
    IERC721MagicDropMetadata,
    ERC2981,
    Ownable
{
    /*==============================================================
    =                          INITIALIZERS                        =
    ==============================================================*/

    /// @notice Initializes the contract.
    /// @dev This function is called by the initializer of the parent contract.
    /// @param owner The address of the contract owner.
    function __ERC721MagicDropMetadataCloneable__init(address owner) internal onlyInitializing {
        _initializeOwner(owner);

        emit MagicDropTokenDeployed();
    }

    /*==============================================================
    =                            STORAGE                           =
    ==============================================================*/

    /// @notice The base URI used to construct `tokenURI` results.
    /// @dev This value can be updated by the contract owner. Typically points to an off-chain IPFS/HTTPS endpoint.
    string internal _tokenBaseURI;

    /// @notice A URI providing contract-level metadata (e.g., for marketplaces).
    /// @dev Can be updated by the owner. Often returns metadata in a JSON format describing the project.
    string internal _contractURI;

    /// @notice The maximum total number of tokens that can ever be minted.
    /// @dev Acts as a cap on supply. Decreasing is allowed (if no tokens are over that limit),
    ///      but increasing supply is forbidden after initialization.
    uint256 internal _maxSupply;

    /// @notice The per-wallet minting limit, restricting how many tokens a single address can mint.
    uint256 internal _walletLimit;

    /// @notice The address receiving royalty payments.
    address internal _royaltyReceiver;

    /// @notice The royalty amount (in basis points) for secondary sales (e.g., 100 = 1%).
    uint96 internal _royaltyBps;

    /*==============================================================
    =                      PUBLIC VIEW METHODS                     =
    ==============================================================*/

    /// @notice Returns the current base URI used to construct token URIs.
    /// @return The base URI as a string.
    function baseURI() public view override returns (string memory) {
        return _tokenBaseURI;
    }

    /// @notice Returns a URI representing contract-level metadata, often used by marketplaces.
    /// @return The contract-level metadata URI.
    function contractURI() public view override returns (string memory) {
        return _contractURI;
    }

    /// @notice The maximum number of tokens that can ever be minted by this contract.
    /// @return The maximum supply of tokens.
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    /// @notice The maximum number of tokens any single wallet can mint.
    /// @return The minting limit per wallet.
    function walletLimit() public view returns (uint256) {
        return _walletLimit;
    }

    /// @notice The address designated to receive royalty payments on secondary sales.
    /// @return The royalty receiver address.
    function royaltyAddress() public view returns (address) {
        return _royaltyReceiver;
    }

    /// @notice The royalty rate in basis points (e.g. 100 = 1%) for secondary sales.
    /// @return The royalty fee in basis points.
    function royaltyBps() public view returns (uint256) {
        return _royaltyBps;
    }

    /// @notice Returns the total number of tokens minted by a specific address.
    /// @param user The address to query.
    /// @return The total number of tokens minted by the specified address.
    function totalMintedByUser(address user) public view returns (uint256) {
        return _numberMinted(user);
    }

    /// @notice Indicates whether this contract implements a given interface.
    /// @dev Supports ERC-2981 (royalties) and ERC-4906 (batch metadata updates), in addition to inherited interfaces.
    /// @param interfaceId The interface ID to check for compliance.
    /// @return True if the contract implements the specified interface, otherwise false.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC2981, ERC721ACloneable, IERC721A)
        returns (bool)
    {
        return interfaceId == 0x2a55205a // ERC-2981 royalties
            || interfaceId == 0x49064906 // ERC-4906 metadata updates
            || ERC721ACloneable.supportsInterface(interfaceId);
    }

    /*==============================================================
    =                      ADMIN OPERATIONS                        =
    ==============================================================*/

    /// @notice Sets a new base URI for token metadata, affecting all tokens.
    /// @dev Emits a batch metadata update event if there are already minted tokens.
    /// @param newBaseURI The new base URI.
    function setBaseURI(string calldata newBaseURI) external override onlyOwner {
        _setBaseURI(newBaseURI);
    }

    /// @notice Updates the contract-level metadata URI.
    /// @dev Useful for marketplaces to display project details.
    /// @param newContractURI The new contract metadata URI.
    function setContractURI(string calldata newContractURI) external override onlyOwner {
        _setContractURI(newContractURI);

        emit ContractURIUpdated(newContractURI);
    }

    /// @notice Adjusts the maximum token supply.
    /// @dev Cannot increase beyond the original max supply. Cannot set below the current minted amount.
    /// @param newMaxSupply The new maximum supply.
    function setMaxSupply(uint256 newMaxSupply) external onlyOwner {
        _setMaxSupply(newMaxSupply);
    }

    /// @notice Updates the per-wallet minting limit.
    /// @dev This can be changed at any time to adjust distribution constraints.
    /// @param newWalletLimit The new per-wallet limit on minted tokens.
    function setWalletLimit(uint256 newWalletLimit) external onlyOwner {
        _setWalletLimit(newWalletLimit);
    }

    /// @notice Configures the royalty information for secondary sales.
    /// @dev Sets a new receiver and basis points for royalties. Basis points define the percentage rate.
    /// @param newReceiver The address to receive royalties.
    /// @param newBps The royalty rate in basis points (e.g., 100 = 1%).
    function setRoyaltyInfo(address newReceiver, uint96 newBps) external onlyOwner {
        _setRoyaltyInfo(newReceiver, newBps);
    }

    /// @notice Emits an event to notify clients of metadata changes for a specific token range.
    /// @dev Useful for updating external indexes after significant metadata alterations.
    /// @param fromTokenId The starting token ID in the updated range.
    /// @param toTokenId   The ending token ID in the updated range.
    function emitBatchMetadataUpdate(uint256 fromTokenId, uint256 toTokenId) external onlyOwner {
        emit BatchMetadataUpdate(fromTokenId, toTokenId);
    }

    /*==============================================================
    =                      INTERNAL HELPERS                        =
    ==============================================================*/

    /// @notice Internal function returning the current base URI for token metadata.
    /// @return The current base URI string.
    function _baseURI() internal view override returns (string memory) {
        return _tokenBaseURI;
    }

    /// @notice Internal function setting the base URI for token metadata.
    /// @param newBaseURI The new base URI string.
    function _setBaseURI(string calldata newBaseURI) internal {
        _tokenBaseURI = newBaseURI;

        if (totalSupply() != 0) {
            // Notify EIP-4906 compliant observers of a metadata update.
            emit BatchMetadataUpdate(0, totalSupply() - 1);
        }
    }

    /// @notice Internal function setting the maximum token supply.
    /// @dev Cannot increase beyond the original max supply. Cannot set below the current minted amount.
    /// @param newMaxSupply The new maximum supply.
    function _setMaxSupply(uint256 newMaxSupply) internal {
        if (_maxSupply != 0 && newMaxSupply > _maxSupply) {
            revert MaxSupplyCannotBeIncreased();
        }

        if (newMaxSupply < _totalMinted()) {
            revert MaxSupplyCannotBeLessThanCurrentSupply();
        }

        if (newMaxSupply > 2 ** 64 - 1) {
            revert MaxSupplyCannotBeGreaterThan2ToThe64thPower();
        }

        _maxSupply = newMaxSupply;
        emit MaxSupplyUpdated(newMaxSupply);
    }

    /// @notice Internal function setting the per-wallet minting limit.
    /// @param newWalletLimit The new per-wallet limit on minted tokens.
    function _setWalletLimit(uint256 newWalletLimit) internal {
        _walletLimit = newWalletLimit;
        emit WalletLimitUpdated(newWalletLimit);
    }

    /// @notice Internal function setting the royalty information.
    /// @param newReceiver The address to receive royalties.
    /// @param newBps The royalty rate in basis points (e.g., 100 = 1%).
    function _setRoyaltyInfo(address newReceiver, uint96 newBps) internal {
        _royaltyReceiver = newReceiver;
        _royaltyBps = newBps;
        super._setDefaultRoyalty(_royaltyReceiver, _royaltyBps);
        emit RoyaltyInfoUpdated(_royaltyReceiver, _royaltyBps);
    }

    /// @notice Internal function setting the contract URI.
    /// @param newContractURI The new contract metadata URI.
    function _setContractURI(string calldata newContractURI) internal {
        _contractURI = newContractURI;
        emit ContractURIUpdated(newContractURI);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

struct PublicStage {
    /// @dev The start time of the public mint stage.
    uint256 startTime;
    /// @dev The end time of the public mint stage.
    uint256 endTime;
    /// @dev The price of the public mint stage.
    uint256 price;
}

struct AllowlistStage {
    /// @dev The start time of the allowlist mint stage.
    uint256 startTime;
    /// @dev The end time of the allowlist mint stage.
    uint256 endTime;
    /// @dev The price of the allowlist mint stage.
    uint256 price;
    /// @dev The merkle root of the allowlist.
    bytes32 merkleRoot;
}

struct SetupConfig {
    /// @dev The maximum number of tokens that can be minted.
    ///      - Can be decreased if current supply < new max supply
    ///      - Cannot be increased once set
    uint256 maxSupply;
    /// @dev The maximum number of tokens that can be minted per wallet
    /// @notice A value of 0 indicates unlimited mints per wallet
    uint256 walletLimit;
    /// @dev The base URI of the token.
    string baseURI;
    /// @dev The contract URI of the token.
    string contractURI;
    /// @dev The public mint stage.
    PublicStage publicStage;
    /// @dev The allowlist mint stage.
    AllowlistStage allowlistStage;
    /// @dev The payout recipient of the token.
    address payoutRecipient;
    /// @dev The royalty recipient of the token.
    address royaltyRecipient;
    /// @dev The royalty basis points of the token.
    uint96 royaltyBps;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IMagicDropMetadata} from "contracts/common/interfaces/IMagicDropMetadata.sol";

interface IERC721MagicDropMetadata is IMagicDropMetadata {
    /// @notice Emitted when the wallet limit is updated.
    /// @param _walletLimit The new wallet limit.
    event WalletLimitUpdated(uint256 _walletLimit);

    /// @notice Emitted when the max supply is updated.
    /// @param newMaxSupply The new max supply.
    event MaxSupplyUpdated(uint256 newMaxSupply);

    /// @notice Thrown when a mint would exceed the wallet-specific minting limit.
    error WalletLimitExceeded();

    /// @notice Returns the maximum number of tokens that can be minted per wallet
    /// @dev Used to prevent excessive concentration of tokens in single wallets
    /// @return The maximum number of tokens allowed per wallet address
    function walletLimit() external view returns (uint256);

    /// @notice Returns the maximum number of tokens that can be minted
    /// @dev This value cannot be increased once set, only decreased
    /// @return The maximum supply cap for the collection
    function maxSupply() external view returns (uint256);

    /// @notice Updates the per-wallet token holding limit
    /// @dev Used to prevent token concentration and ensure fair distribution
    ///      Setting this to 0 effectively removes the wallet limit
    /// @param walletLimit The new maximum number of tokens allowed per wallet
    function setWalletLimit(uint256 walletLimit) external;

    /// @notice Updates the maximum supply cap for the collection
    /// @dev Can only decrease the max supply, never increase it
    ///      Must be greater than or equal to the current total supply
    /// @param maxSupply The new maximum number of tokens that can be minted
    function setMaxSupply(uint256 maxSupply) external;
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.3.0
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

    /**
     * `_sequentialUpTo()` must be greater than `_startTokenId()`.
     */
    error SequentialUpToTooSmall();

    /**
     * The `tokenId` of a sequential mint exceeds `_sequentialUpTo()`.
     */
    error SequentialMintExceedsLimit();

    /**
     * Spot minting requires a `tokenId` greater than `_sequentialUpTo()`.
     */
    error SpotMintTokenIdTooSmall();

    /**
     * Cannot mint over a token that already exists.
     */
    error TokenAlreadyExists();

    /**
     * The feature is not compatible with spot mints.
     */
    error NotCompatibleWithSpotMints();

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
// ERC721A Contracts v4.3.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import '../IERC721A.sol';

/**
 * @dev Interface of ERC721AQueryable.
 */
interface IERC721AQueryable is IERC721A {
    /**
     * Invalid query range (`start` >= `stop`).
     */
    error InvalidQueryRange();

    /**
     * @dev Returns the `TokenOwnership` struct at `tokenId` without reverting.
     *
     * If the `tokenId` is out of bounds:
     *
     * - `addr = address(0)`
     * - `startTimestamp = 0`
     * - `burned = false`
     * - `extraData = 0`
     *
     * If the `tokenId` is burned:
     *
     * - `addr = <Address of owner before token was burned>`
     * - `startTimestamp = <Timestamp when token was burned>`
     * - `burned = true`
     * - `extraData = <Extra data when token was burned>`
     *
     * Otherwise:
     *
     * - `addr = <Address of owner>`
     * - `startTimestamp = <Timestamp of start of ownership>`
     * - `burned = false`
     * - `extraData = <Extra data at start of ownership>`
     */
    function explicitOwnershipOf(uint256 tokenId) external view returns (TokenOwnership memory);

    /**
     * @dev Returns an array of `TokenOwnership` structs at `tokenIds` in order.
     * See {ERC721AQueryable-explicitOwnershipOf}
     */
    function explicitOwnershipsOf(uint256[] memory tokenIds) external view returns (TokenOwnership[] memory);

    /**
     * @dev Returns an array of token IDs owned by `owner`,
     * in the range [`start`, `stop`)
     * (i.e. `start <= tokenId < stop`).
     *
     * This function allows for tokens to be queried if the collection
     * grows too big for a single call of {ERC721AQueryable-tokensOfOwner}.
     *
     * Requirements:
     *
     * - `start < stop`
     */
    function tokensOfOwnerIn(
        address owner,
        uint256 start,
        uint256 stop
    ) external view returns (uint256[] memory);

    /**
     * @dev Returns an array of token IDs owned by `owner`.
     *
     * This function scans the ownership mapping and is O(`totalSupply`) in complexity.
     * It is meant to be called off-chain.
     *
     * See {ERC721AQueryable-tokensOfOwnerIn} for splitting the scan into
     * multiple smaller scans if the collection is large enough to cause
     * an out-of-gas error (10K collections should be fine).
     */
    function tokensOfOwner(address owner) external view returns (uint256[] memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Simple single owner authorization mixin.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/auth/Ownable.sol)
///
/// @dev Note:
/// This implementation does NOT auto-initialize the owner to `msg.sender`.
/// You MUST call the `_initializeOwner` in the constructor / initializer.
///
/// While the ownable portion follows
/// [EIP-173](https://eips.ethereum.org/EIPS/eip-173) for compatibility,
/// the nomenclature for the 2-step ownership handover may be unique to this codebase.
abstract contract Ownable {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The caller is not authorized to call the function.
    error Unauthorized();

    /// @dev The `newOwner` cannot be the zero address.
    error NewOwnerIsZeroAddress();

    /// @dev The `pendingOwner` does not have a valid handover request.
    error NoHandoverRequest();

    /// @dev Cannot double-initialize.
    error AlreadyInitialized();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ownership is transferred from `oldOwner` to `newOwner`.
    /// This event is intentionally kept the same as OpenZeppelin's Ownable to be
    /// compatible with indexers and [EIP-173](https://eips.ethereum.org/EIPS/eip-173),
    /// despite it not being as lightweight as a single argument event.
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /// @dev An ownership handover to `pendingOwner` has been requested.
    event OwnershipHandoverRequested(address indexed pendingOwner);

    /// @dev The ownership handover to `pendingOwner` has been canceled.
    event OwnershipHandoverCanceled(address indexed pendingOwner);

    /// @dev `keccak256(bytes("OwnershipTransferred(address,address)"))`.
    uint256 private constant _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE =
        0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0;

    /// @dev `keccak256(bytes("OwnershipHandoverRequested(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE =
        0xdbf36a107da19e49527a7176a1babf963b4b0ff8cde35ee35d6cd8f1f9ac7e1d;

    /// @dev `keccak256(bytes("OwnershipHandoverCanceled(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE =
        0xfa7b8eab7da67f412cc9575ed43464468f9bfbae89d1675917346ca6d8fe3c92;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The owner slot is given by:
    /// `bytes32(~uint256(uint32(bytes4(keccak256("_OWNER_SLOT_NOT")))))`.
    /// It is intentionally chosen to be a high value
    /// to avoid collision with lower slots.
    /// The choice of manual storage layout is to enable compatibility
    /// with both regular and upgradeable contracts.
    bytes32 internal constant _OWNER_SLOT =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff74873927;

    /// The ownership handover slot of `newOwner` is given by:
    /// ```
    ///     mstore(0x00, or(shl(96, user), _HANDOVER_SLOT_SEED))
    ///     let handoverSlot := keccak256(0x00, 0x20)
    /// ```
    /// It stores the expiry timestamp of the two-step ownership handover.
    uint256 private constant _HANDOVER_SLOT_SEED = 0x389a75e1;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     INTERNAL FUNCTIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Override to return true to make `_initializeOwner` prevent double-initialization.
    function _guardInitializeOwner() internal pure virtual returns (bool guard) {}

    /// @dev Initializes the owner directly without authorization guard.
    /// This function must be called upon initialization,
    /// regardless of whether the contract is upgradeable or not.
    /// This is to enable generalization to both regular and upgradeable contracts,
    /// and to save gas in case the initial owner is not the caller.
    /// For performance reasons, this function will not check if there
    /// is an existing owner.
    function _initializeOwner(address newOwner) internal virtual {
        if (_guardInitializeOwner()) {
            /// @solidity memory-safe-assembly
            assembly {
                let ownerSlot := _OWNER_SLOT
                if sload(ownerSlot) {
                    mstore(0x00, 0x0dc149f0) // `AlreadyInitialized()`.
                    revert(0x1c, 0x04)
                }
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Store the new value.
                sstore(ownerSlot, or(newOwner, shl(255, iszero(newOwner))))
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
            }
        } else {
            /// @solidity memory-safe-assembly
            assembly {
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Store the new value.
                sstore(_OWNER_SLOT, newOwner)
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
            }
        }
    }

    /// @dev Sets the owner directly without authorization guard.
    function _setOwner(address newOwner) internal virtual {
        if (_guardInitializeOwner()) {
            /// @solidity memory-safe-assembly
            assembly {
                let ownerSlot := _OWNER_SLOT
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
                // Store the new value.
                sstore(ownerSlot, or(newOwner, shl(255, iszero(newOwner))))
            }
        } else {
            /// @solidity memory-safe-assembly
            assembly {
                let ownerSlot := _OWNER_SLOT
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
                // Store the new value.
                sstore(ownerSlot, newOwner)
            }
        }
    }

    /// @dev Throws if the sender is not the owner.
    function _checkOwner() internal view virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // If the caller is not the stored owner, revert.
            if iszero(eq(caller(), sload(_OWNER_SLOT))) {
                mstore(0x00, 0x82b42900) // `Unauthorized()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Returns how long a two-step ownership handover is valid for in seconds.
    /// Override to return a different value if needed.
    /// Made internal to conserve bytecode. Wrap it in a public function if needed.
    function _ownershipHandoverValidFor() internal view virtual returns (uint64) {
        return 48 * 3600;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  PUBLIC UPDATE FUNCTIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Allows the owner to transfer the ownership to `newOwner`.
    function transferOwnership(address newOwner) public payable virtual onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(shl(96, newOwner)) {
                mstore(0x00, 0x7448fbae) // `NewOwnerIsZeroAddress()`.
                revert(0x1c, 0x04)
            }
        }
        _setOwner(newOwner);
    }

    /// @dev Allows the owner to renounce their ownership.
    function renounceOwnership() public payable virtual onlyOwner {
        _setOwner(address(0));
    }

    /// @dev Request a two-step ownership handover to the caller.
    /// The request will automatically expire in 48 hours (172800 seconds) by default.
    function requestOwnershipHandover() public payable virtual {
        unchecked {
            uint256 expires = block.timestamp + _ownershipHandoverValidFor();
            /// @solidity memory-safe-assembly
            assembly {
                // Compute and set the handover slot to `expires`.
                mstore(0x0c, _HANDOVER_SLOT_SEED)
                mstore(0x00, caller())
                sstore(keccak256(0x0c, 0x20), expires)
                // Emit the {OwnershipHandoverRequested} event.
                log2(0, 0, _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE, caller())
            }
        }
    }

    /// @dev Cancels the two-step ownership handover to the caller, if any.
    function cancelOwnershipHandover() public payable virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and set the handover slot to 0.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, caller())
            sstore(keccak256(0x0c, 0x20), 0)
            // Emit the {OwnershipHandoverCanceled} event.
            log2(0, 0, _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE, caller())
        }
    }

    /// @dev Allows the owner to complete the two-step ownership handover to `pendingOwner`.
    /// Reverts if there is no existing ownership handover requested by `pendingOwner`.
    function completeOwnershipHandover(address pendingOwner) public payable virtual onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and set the handover slot to 0.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            let handoverSlot := keccak256(0x0c, 0x20)
            // If the handover does not exist, or has expired.
            if gt(timestamp(), sload(handoverSlot)) {
                mstore(0x00, 0x6f5e8818) // `NoHandoverRequest()`.
                revert(0x1c, 0x04)
            }
            // Set the handover slot to 0.
            sstore(handoverSlot, 0)
        }
        _setOwner(pendingOwner);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   PUBLIC READ FUNCTIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the owner of the contract.
    function owner() public view virtual returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := sload(_OWNER_SLOT)
        }
    }

    /// @dev Returns the expiry timestamp for the two-step ownership handover to `pendingOwner`.
    function ownershipHandoverExpiresAt(address pendingOwner)
        public
        view
        virtual
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the handover slot.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            // Load the handover slot.
            result := sload(keccak256(0x0c, 0x20))
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         MODIFIERS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Marks a function as only callable by the owner.
    modifier onlyOwner() virtual {
        _checkOwner();
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Simple ERC2981 NFT Royalty Standard implementation.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/tokens/ERC2981.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/common/ERC2981.sol)
abstract contract ERC2981 {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The royalty fee numerator exceeds the fee denominator.
    error RoyaltyOverflow();

    /// @dev The royalty receiver cannot be the zero address.
    error RoyaltyReceiverIsZeroAddress();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The default royalty info is given by:
    /// ```
    ///     let packed := sload(_ERC2981_MASTER_SLOT_SEED)
    ///     let receiver := shr(96, packed)
    ///     let royaltyFraction := xor(packed, shl(96, receiver))
    /// ```
    ///
    /// The per token royalty info is given by.
    /// ```
    ///     mstore(0x00, tokenId)
    ///     mstore(0x20, _ERC2981_MASTER_SLOT_SEED)
    ///     let packed := sload(keccak256(0x00, 0x40))
    ///     let receiver := shr(96, packed)
    ///     let royaltyFraction := xor(packed, shl(96, receiver))
    /// ```
    uint256 private constant _ERC2981_MASTER_SLOT_SEED = 0xaa4ec00224afccfdb7;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          ERC2981                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Checks that `_feeDenominator` is non-zero.
    constructor() {
        require(_feeDenominator() != 0, "Fee denominator cannot be zero.");
    }

    /// @dev Returns the denominator for the royalty amount.
    /// Defaults to 10000, which represents fees in basis points.
    /// Override this function to return a custom amount if needed.
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /// @dev Returns true if this contract implements the interface defined by `interfaceId`.
    /// See: https://eips.ethereum.org/EIPS/eip-165
    /// This function call must use less than 30000 gas.
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let s := shr(224, interfaceId)
            // ERC165: 0x01ffc9a7, ERC2981: 0x2a55205a.
            result := or(eq(s, 0x01ffc9a7), eq(s, 0x2a55205a))
        }
    }

    /// @dev Returns the `receiver` and `royaltyAmount` for `tokenId` sold at `salePrice`.
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        public
        view
        virtual
        returns (address receiver, uint256 royaltyAmount)
    {
        uint256 feeDenominator = _feeDenominator();
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _ERC2981_MASTER_SLOT_SEED)
            let packed := sload(keccak256(0x00, 0x40))
            receiver := shr(96, packed)
            if iszero(receiver) {
                packed := sload(mload(0x20))
                receiver := shr(96, packed)
            }
            let x := salePrice
            let y := xor(packed, shl(96, receiver)) // `feeNumerator`.
            // Overflow check, equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            // Out-of-gas revert. Should not be triggered in practice, but included for safety.
            returndatacopy(returndatasize(), returndatasize(), mul(y, gt(x, div(not(0), y))))
            royaltyAmount := div(mul(x, y), feeDenominator)
        }
    }

    /// @dev Sets the default royalty `receiver` and `feeNumerator`.
    ///
    /// Requirements:
    /// - `receiver` must not be the zero address.
    /// - `feeNumerator` must not be greater than the fee denominator.
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        uint256 feeDenominator = _feeDenominator();
        /// @solidity memory-safe-assembly
        assembly {
            feeNumerator := shr(160, shl(160, feeNumerator))
            if gt(feeNumerator, feeDenominator) {
                mstore(0x00, 0x350a88b3) // `RoyaltyOverflow()`.
                revert(0x1c, 0x04)
            }
            let packed := shl(96, receiver)
            if iszero(packed) {
                mstore(0x00, 0xb4457eaa) // `RoyaltyReceiverIsZeroAddress()`.
                revert(0x1c, 0x04)
            }
            sstore(_ERC2981_MASTER_SLOT_SEED, or(packed, feeNumerator))
        }
    }

    /// @dev Sets the default royalty `receiver` and `feeNumerator` to zero.
    function _deleteDefaultRoyalty() internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
            sstore(_ERC2981_MASTER_SLOT_SEED, 0)
        }
    }

    /// @dev Sets the royalty `receiver` and `feeNumerator` for `tokenId`.
    ///
    /// Requirements:
    /// - `receiver` must not be the zero address.
    /// - `feeNumerator` must not be greater than the fee denominator.
    function _setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator)
        internal
        virtual
    {
        uint256 feeDenominator = _feeDenominator();
        /// @solidity memory-safe-assembly
        assembly {
            feeNumerator := shr(160, shl(160, feeNumerator))
            if gt(feeNumerator, feeDenominator) {
                mstore(0x00, 0x350a88b3) // `RoyaltyOverflow()`.
                revert(0x1c, 0x04)
            }
            let packed := shl(96, receiver)
            if iszero(packed) {
                mstore(0x00, 0xb4457eaa) // `RoyaltyReceiverIsZeroAddress()`.
                revert(0x1c, 0x04)
            }
            mstore(0x00, tokenId)
            mstore(0x20, _ERC2981_MASTER_SLOT_SEED)
            sstore(keccak256(0x00, 0x40), or(packed, feeNumerator))
        }
    }

    /// @dev Sets the royalty `receiver` and `feeNumerator` for `tokenId` to zero.
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _ERC2981_MASTER_SLOT_SEED)
            sstore(keccak256(0x00, 0x40), 0)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Initializable mixin for the upgradeable contracts.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/Initializable.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/proxy/utils/Initializable.sol)
abstract contract Initializable {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The contract is already initialized.
    error InvalidInitialization();

    /// @dev The contract is not initializing.
    error NotInitializing();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Triggered when the contract has been initialized.
    event Initialized(uint64 version);

    /// @dev `keccak256(bytes("Initialized(uint64)"))`.
    bytes32 private constant _INTIALIZED_EVENT_SIGNATURE =
        0xc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d2;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The default initializable slot is given by:
    /// `bytes32(~uint256(uint32(bytes4(keccak256("_INITIALIZABLE_SLOT")))))`.
    ///
    /// Bits Layout:
    /// - [0]     `initializing`
    /// - [1..64] `initializedVersion`
    bytes32 private constant _INITIALIZABLE_SLOT =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffbf601132;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CONSTRUCTOR                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    constructor() {
        // Construction time check to ensure that `_initializableSlot()` is not
        // overridden to zero. Will be optimized away if there is no revert.
        require(_initializableSlot() != bytes32(0));
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         OPERATIONS                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Override to return a non-zero custom storage slot if required.
    function _initializableSlot() internal pure virtual returns (bytes32) {
        return _INITIALIZABLE_SLOT;
    }

    /// @dev Guards an initializer function so that it can be invoked at most once.
    ///
    /// You can guard a function with `onlyInitializing` such that it can be called
    /// through a function guarded with `initializer`.
    ///
    /// This is similar to `reinitializer(1)`, except that in the context of a constructor,
    /// an `initializer` guarded function can be invoked multiple times.
    /// This can be useful during testing and is not expected to be used in production.
    ///
    /// Emits an {Initialized} event.
    modifier initializer() virtual {
        bytes32 s = _initializableSlot();
        /// @solidity memory-safe-assembly
        assembly {
            let i := sload(s)
            // Set `initializing` to 1, `initializedVersion` to 1.
            sstore(s, 3)
            // If `!(initializing == 0 && initializedVersion == 0)`.
            if i {
                // If `!(address(this).code.length == 0 && initializedVersion == 1)`.
                if iszero(lt(extcodesize(address()), eq(shr(1, i), 1))) {
                    mstore(0x00, 0xf92ee8a9) // `InvalidInitialization()`.
                    revert(0x1c, 0x04)
                }
                s := shl(shl(255, i), s) // Skip initializing if `initializing == 1`.
            }
        }
        _;
        /// @solidity memory-safe-assembly
        assembly {
            if s {
                // Set `initializing` to 0, `initializedVersion` to 1.
                sstore(s, 2)
                // Emit the {Initialized} event.
                mstore(0x20, 1)
                log1(0x20, 0x20, _INTIALIZED_EVENT_SIGNATURE)
            }
        }
    }

    /// @dev Guards an reinitialzer function so that it can be invoked at most once.
    ///
    /// You can guard a function with `onlyInitializing` such that it can be called
    /// through a function guarded with `reinitializer`.
    ///
    /// Emits an {Initialized} event.
    modifier reinitializer(uint64 version) virtual {
        bytes32 s = _initializableSlot();
        /// @solidity memory-safe-assembly
        assembly {
            // Clean upper bits, and shift left by 1 to make space for the initializing bit.
            version := shl(1, and(version, 0xffffffffffffffff))
            let i := sload(s)
            // If `initializing == 1 || initializedVersion >= version`.
            if iszero(lt(and(i, 1), lt(i, version))) {
                mstore(0x00, 0xf92ee8a9) // `InvalidInitialization()`.
                revert(0x1c, 0x04)
            }
            // Set `initializing` to 1, `initializedVersion` to `version`.
            sstore(s, or(1, version))
        }
        _;
        /// @solidity memory-safe-assembly
        assembly {
            // Set `initializing` to 0, `initializedVersion` to `version`.
            sstore(s, version)
            // Emit the {Initialized} event.
            mstore(0x20, shr(1, version))
            log1(0x20, 0x20, _INTIALIZED_EVENT_SIGNATURE)
        }
    }

    /// @dev Guards a function such that it can only be called in the scope
    /// of a function guarded with `initializer` or `reinitializer`.
    modifier onlyInitializing() virtual {
        _checkInitializing();
        _;
    }

    /// @dev Reverts if the contract is not initializing.
    function _checkInitializing() internal view virtual {
        bytes32 s = _initializableSlot();
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(and(1, sload(s))) {
                mstore(0x00, 0xd7e6bcf8) // `NotInitializing()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Locks any future initializations by setting the initialized version to `2**64 - 1`.
    ///
    /// Calling this in the constructor will prevent the contract from being initialized
    /// or reinitialized. It is recommended to use this to lock implementation contracts
    /// that are designed to be called through proxies.
    ///
    /// Emits an {Initialized} event the first time it is successfully called.
    function _disableInitializers() internal virtual {
        bytes32 s = _initializableSlot();
        /// @solidity memory-safe-assembly
        assembly {
            let i := sload(s)
            if and(i, 1) {
                mstore(0x00, 0xf92ee8a9) // `InvalidInitialization()`.
                revert(0x1c, 0x04)
            }
            let uint64max := 0xffffffffffffffff
            if iszero(eq(shr(1, i), uint64max)) {
                // Set `initializing` to 0, `initializedVersion` to `2**64 - 1`.
                sstore(s, shl(1, uint64max))
                // Emit the {Initialized} event.
                mstore(0x20, uint64max)
                log1(0x20, 0x20, _INTIALIZED_EVENT_SIGNATURE)
            }
        }
    }

    /// @dev Returns the highest version that has been initialized.
    function _getInitializedVersion() internal view virtual returns (uint64 version) {
        bytes32 s = _initializableSlot();
        /// @solidity memory-safe-assembly
        assembly {
            version := shr(1, sload(s))
        }
    }

    /// @dev Returns whether the contract is currently initializing.
    function _isInitializing() internal view virtual returns (bool result) {
        bytes32 s = _initializableSlot();
        /// @solidity memory-safe-assembly
        assembly {
            result := and(1, sload(s))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Gas optimized verification of proof of inclusion for a leaf in a Merkle tree.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/MerkleProofLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/MerkleProofLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol)
library MerkleProofLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*            MERKLE PROOF VERIFICATION OPERATIONS            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns whether `leaf` exists in the Merkle tree with `root`, given `proof`.
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf)
        internal
        pure
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(proof) {
                // Initialize `offset` to the offset of `proof` elements in memory.
                let offset := add(proof, 0x20)
                // Left shift by 5 is equivalent to multiplying by 0x20.
                let end := add(offset, shl(5, mload(proof)))
                // Iterate over proof elements to compute root hash.
                for {} 1 {} {
                    // Slot of `leaf` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(leaf, mload(offset)))
                    // Store elements to hash contiguously in scratch space.
                    // Scratch space is 64 bytes (0x00 - 0x3f) and both elements are 32 bytes.
                    mstore(scratch, leaf)
                    mstore(xor(scratch, 0x20), mload(offset))
                    // Reuse `leaf` to store the hash to reduce stack operations.
                    leaf := keccak256(0x00, 0x40)
                    offset := add(offset, 0x20)
                    if iszero(lt(offset, end)) { break }
                }
            }
            isValid := eq(leaf, root)
        }
    }

    /// @dev Returns whether `leaf` exists in the Merkle tree with `root`, given `proof`.
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf)
        internal
        pure
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            if proof.length {
                // Left shift by 5 is equivalent to multiplying by 0x20.
                let end := add(proof.offset, shl(5, proof.length))
                // Initialize `offset` to the offset of `proof` in the calldata.
                let offset := proof.offset
                // Iterate over proof elements to compute root hash.
                for {} 1 {} {
                    // Slot of `leaf` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(leaf, calldataload(offset)))
                    // Store elements to hash contiguously in scratch space.
                    // Scratch space is 64 bytes (0x00 - 0x3f) and both elements are 32 bytes.
                    mstore(scratch, leaf)
                    mstore(xor(scratch, 0x20), calldataload(offset))
                    // Reuse `leaf` to store the hash to reduce stack operations.
                    leaf := keccak256(0x00, 0x40)
                    offset := add(offset, 0x20)
                    if iszero(lt(offset, end)) { break }
                }
            }
            isValid := eq(leaf, root)
        }
    }

    /// @dev Returns whether all `leaves` exist in the Merkle tree with `root`,
    /// given `proof` and `flags`.
    ///
    /// Note:
    /// - Breaking the invariant `flags.length == (leaves.length - 1) + proof.length`
    ///   will always return false.
    /// - The sum of the lengths of `proof` and `leaves` must never overflow.
    /// - Any non-zero word in the `flags` array is treated as true.
    /// - The memory offset of `proof` must be non-zero
    ///   (i.e. `proof` is not pointing to the scratch space).
    function verifyMultiProof(
        bytes32[] memory proof,
        bytes32 root,
        bytes32[] memory leaves,
        bool[] memory flags
    ) internal pure returns (bool isValid) {
        // Rebuilds the root by consuming and producing values on a queue.
        // The queue starts with the `leaves` array, and goes into a `hashes` array.
        // After the process, the last element on the queue is verified
        // to be equal to the `root`.
        //
        // The `flags` array denotes whether the sibling
        // should be popped from the queue (`flag == true`), or
        // should be popped from the `proof` (`flag == false`).
        /// @solidity memory-safe-assembly
        assembly {
            // Cache the lengths of the arrays.
            let leavesLength := mload(leaves)
            let proofLength := mload(proof)
            let flagsLength := mload(flags)

            // Advance the pointers of the arrays to point to the data.
            leaves := add(0x20, leaves)
            proof := add(0x20, proof)
            flags := add(0x20, flags)

            // If the number of flags is correct.
            for {} eq(add(leavesLength, proofLength), add(flagsLength, 1)) {} {
                // For the case where `proof.length + leaves.length == 1`.
                if iszero(flagsLength) {
                    // `isValid = (proof.length == 1 ? proof[0] : leaves[0]) == root`.
                    isValid := eq(mload(xor(leaves, mul(xor(proof, leaves), proofLength))), root)
                    break
                }

                // The required final proof offset if `flagsLength` is not zero, otherwise zero.
                let proofEnd := add(proof, shl(5, proofLength))
                // We can use the free memory space for the queue.
                // We don't need to allocate, since the queue is temporary.
                let hashesFront := mload(0x40)
                // Copy the leaves into the hashes.
                // Sometimes, a little memory expansion costs less than branching.
                // Should cost less, even with a high free memory offset of 0x7d00.
                leavesLength := shl(5, leavesLength)
                for { let i := 0 } iszero(eq(i, leavesLength)) { i := add(i, 0x20) } {
                    mstore(add(hashesFront, i), mload(add(leaves, i)))
                }
                // Compute the back of the hashes.
                let hashesBack := add(hashesFront, leavesLength)
                // This is the end of the memory for the queue.
                // We recycle `flagsLength` to save on stack variables (sometimes save gas).
                flagsLength := add(hashesBack, shl(5, flagsLength))

                for {} 1 {} {
                    // Pop from `hashes`.
                    let a := mload(hashesFront)
                    // Pop from `hashes`.
                    let b := mload(add(hashesFront, 0x20))
                    hashesFront := add(hashesFront, 0x40)

                    // If the flag is false, load the next proof,
                    // else, pops from the queue.
                    if iszero(mload(flags)) {
                        // Loads the next proof.
                        b := mload(proof)
                        proof := add(proof, 0x20)
                        // Unpop from `hashes`.
                        hashesFront := sub(hashesFront, 0x20)
                    }

                    // Advance to the next flag.
                    flags := add(flags, 0x20)

                    // Slot of `a` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(a, b))
                    // Hash the scratch space and push the result onto the queue.
                    mstore(scratch, a)
                    mstore(xor(scratch, 0x20), b)
                    mstore(hashesBack, keccak256(0x00, 0x40))
                    hashesBack := add(hashesBack, 0x20)
                    if iszero(lt(hashesBack, flagsLength)) { break }
                }
                isValid :=
                    and(
                        // Checks if the last value in the queue is same as the root.
                        eq(mload(sub(hashesBack, 0x20)), root),
                        // And whether all the proofs are used, if required.
                        eq(proofEnd, proof)
                    )
                break
            }
        }
    }

    /// @dev Returns whether all `leaves` exist in the Merkle tree with `root`,
    /// given `proof` and `flags`.
    ///
    /// Note:
    /// - Breaking the invariant `flags.length == (leaves.length - 1) + proof.length`
    ///   will always return false.
    /// - Any non-zero word in the `flags` array is treated as true.
    /// - The calldata offset of `proof` must be non-zero
    ///   (i.e. `proof` is from a regular Solidity function with a 4-byte selector).
    function verifyMultiProofCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32[] calldata leaves,
        bool[] calldata flags
    ) internal pure returns (bool isValid) {
        // Rebuilds the root by consuming and producing values on a queue.
        // The queue starts with the `leaves` array, and goes into a `hashes` array.
        // After the process, the last element on the queue is verified
        // to be equal to the `root`.
        //
        // The `flags` array denotes whether the sibling
        // should be popped from the queue (`flag == true`), or
        // should be popped from the `proof` (`flag == false`).
        /// @solidity memory-safe-assembly
        assembly {
            // If the number of flags is correct.
            for {} eq(add(leaves.length, proof.length), add(flags.length, 1)) {} {
                // For the case where `proof.length + leaves.length == 1`.
                if iszero(flags.length) {
                    // `isValid = (proof.length == 1 ? proof[0] : leaves[0]) == root`.
                    // forgefmt: disable-next-item
                    isValid := eq(
                        calldataload(
                            xor(leaves.offset, mul(xor(proof.offset, leaves.offset), proof.length))
                        ),
                        root
                    )
                    break
                }

                // The required final proof offset if `flagsLength` is not zero, otherwise zero.
                let proofEnd := add(proof.offset, shl(5, proof.length))
                // We can use the free memory space for the queue.
                // We don't need to allocate, since the queue is temporary.
                let hashesFront := mload(0x40)
                // Copy the leaves into the hashes.
                // Sometimes, a little memory expansion costs less than branching.
                // Should cost less, even with a high free memory offset of 0x7d00.
                calldatacopy(hashesFront, leaves.offset, shl(5, leaves.length))
                // Compute the back of the hashes.
                let hashesBack := add(hashesFront, shl(5, leaves.length))
                // This is the end of the memory for the queue.
                // We recycle `flagsLength` to save on stack variables (sometimes save gas).
                flags.length := add(hashesBack, shl(5, flags.length))

                // We don't need to make a copy of `proof.offset` or `flags.offset`,
                // as they are pass-by-value (this trick may not always save gas).

                for {} 1 {} {
                    // Pop from `hashes`.
                    let a := mload(hashesFront)
                    // Pop from `hashes`.
                    let b := mload(add(hashesFront, 0x20))
                    hashesFront := add(hashesFront, 0x40)

                    // If the flag is false, load the next proof,
                    // else, pops from the queue.
                    if iszero(calldataload(flags.offset)) {
                        // Loads the next proof.
                        b := calldataload(proof.offset)
                        proof.offset := add(proof.offset, 0x20)
                        // Unpop from `hashes`.
                        hashesFront := sub(hashesFront, 0x20)
                    }

                    // Advance to the next flag offset.
                    flags.offset := add(flags.offset, 0x20)

                    // Slot of `a` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(a, b))
                    // Hash the scratch space and push the result onto the queue.
                    mstore(scratch, a)
                    mstore(xor(scratch, 0x20), b)
                    mstore(hashesBack, keccak256(0x00, 0x40))
                    hashesBack := add(hashesBack, 0x20)
                    if iszero(lt(hashesBack, flags.length)) { break }
                }
                isValid :=
                    and(
                        // Checks if the last value in the queue is same as the root.
                        eq(mload(sub(hashesBack, 0x20)), root),
                        // And whether all the proofs are used, if required.
                        eq(proofEnd, proof.offset)
                    )
                break
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   EMPTY CALLDATA HELPERS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an empty calldata bytes32 array.
    function emptyProof() internal pure returns (bytes32[] calldata proof) {
        /// @solidity memory-safe-assembly
        assembly {
            proof.length := 0
        }
    }

    /// @dev Returns an empty calldata bytes32 array.
    function emptyLeaves() internal pure returns (bytes32[] calldata leaves) {
        /// @solidity memory-safe-assembly
        assembly {
            leaves.length := 0
        }
    }

    /// @dev Returns an empty calldata bool array.
    function emptyFlags() internal pure returns (bool[] calldata flags) {
        /// @solidity memory-safe-assembly
        assembly {
            flags.length := 0
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @author Permit2 operations from (https://github.com/Uniswap/permit2/blob/main/src/libraries/Permit2Lib.sol)
///
/// @dev Note:
/// - For ETH transfers, please use `forceSafeTransferETH` for DoS protection.
library SafeTransferLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ETH transfer has failed.
    error ETHTransferFailed();

    /// @dev The ERC20 `transferFrom` has failed.
    error TransferFromFailed();

    /// @dev The ERC20 `transfer` has failed.
    error TransferFailed();

    /// @dev The ERC20 `approve` has failed.
    error ApproveFailed();

    /// @dev The ERC20 `totalSupply` query has failed.
    error TotalSupplyQueryFailed();

    /// @dev The Permit2 operation has failed.
    error Permit2Failed();

    /// @dev The Permit2 amount must be less than `2**160 - 1`.
    error Permit2AmountOverflow();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH that disallows any storage writes.
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;

    /// @dev The unique EIP-712 domain domain separator for the DAI token contract.
    bytes32 internal constant DAI_DOMAIN_SEPARATOR =
        0xdbb8cf42e1ecb028be3f3dbc922e1d878b963f411dc388ced501601c60f7c6f7;

    /// @dev The address for the WETH9 contract on Ethereum mainnet.
    address internal constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @dev The canonical Permit2 address.
    /// [Github](https://github.com/Uniswap/permit2)
    /// [Etherscan](https://etherscan.io/address/0x000000000022D473030F116dDEE9F6B43aC78BA3)
    address internal constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // If the ETH transfer MUST succeed with a reasonable gas budget, use the force variants.
    //
    // The regular variants:
    // - Forwards all remaining gas to the target.
    // - Reverts if the target reverts.
    // - Reverts if the current contract has insufficient balance.
    //
    // The force variants:
    // - Forwards with an optional gas stipend
    //   (defaults to `GAS_STIPEND_NO_GRIEF`, which is sufficient for most cases).
    // - If the target reverts, or if the gas stipend is exhausted,
    //   creates a temporary contract to force send the ETH via `SELFDESTRUCT`.
    //   Future compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758.
    // - Reverts if the current contract has insufficient balance.
    //
    // The try variants:
    // - Forwards with a mandatory gas stipend.
    // - Instead of reverting, returns whether the transfer succeeded.

    /// @dev Sends `amount` (in wei) ETH to `to`.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gas(), to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`.
    function safeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer all the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function forceSafeTransferAllETH(address to, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function trySafeTransferAllETH(address to, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      ERC20 OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for
    /// the current contract to manage.
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            let success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function trySafeTransferFrom(address token, address from, address to, uint256 amount)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                success := lt(or(iszero(extcodesize(token)), returndatasize()), success)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have their entire balance approved for the current contract to manage.
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x00, 0x23b872dd) // `transferFrom(address,address,uint256)`.
            amount := mload(0x60) // The `amount` is already at 0x60. We'll need to return it.
            // Perform the transfer, reverting upon failure.
            let success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransfer(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x14, to) // Store the `to` argument.
            amount := mload(0x34) // The `amount` is already at 0x34. We'll need to return it.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// If the initial attempt to approve fails, attempts to reset the approved amount to zero,
    /// then retries the approval again (some tokens, e.g. USDT, requires this).
    /// Reverts upon failure.
    function safeApproveWithRetry(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, retrying upon failure.
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x34, 0) // Store 0 for the `amount`.
                    mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
                    pop(call(gas(), token, 0, 0x10, 0x44, codesize(), 0x00)) // Reset the approval.
                    mstore(0x34, amount) // Store back the original `amount`.
                    // Retry the approval, reverting upon failure.
                    success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    if iszero(and(eq(mload(0x00), 1), success)) {
                        // Check the `extcodesize` again just in case the token selfdestructs lol.
                        if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                            mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                            revert(0x1c, 0x04)
                        }
                    }
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, account) // Store the `account` argument.
            mstore(0x00, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            amount :=
                mul( // The arguments of `mul` are evaluated from right to left.
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }

    /// @dev Returns the total supply of the `token`.
    /// Reverts if the token does not exist or does not implement `totalSupply()`.
    function totalSupply(address token) internal view returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x18160ddd) // `totalSupply()`.
            if iszero(
                and(gt(returndatasize(), 0x1f), staticcall(gas(), token, 0x1c, 0x04, 0x00, 0x20))
            ) {
                mstore(0x00, 0x54cd9435) // `TotalSupplyQueryFailed()`.
                revert(0x1c, 0x04)
            }
            result := mload(0x00)
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// If the initial attempt fails, try to use Permit2 to transfer the token.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function safeTransferFrom2(address token, address from, address to, uint256 amount) internal {
        if (!trySafeTransferFrom(token, from, to, amount)) {
            permit2TransferFrom(token, from, to, amount);
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to` via Permit2.
    /// Reverts upon failure.
    function permit2TransferFrom(address token, address from, address to, uint256 amount)
        internal
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(add(m, 0x74), shr(96, shl(96, token)))
            mstore(add(m, 0x54), amount)
            mstore(add(m, 0x34), to)
            mstore(add(m, 0x20), shl(96, from))
            // `transferFrom(address,address,uint160,address)`.
            mstore(m, 0x36c78516000000000000000000000000)
            let p := PERMIT2
            let exists := eq(chainid(), 1)
            if iszero(exists) { exists := iszero(iszero(extcodesize(p))) }
            if iszero(
                and(
                    call(gas(), p, 0, add(m, 0x10), 0x84, codesize(), 0x00),
                    lt(iszero(extcodesize(token)), exists) // Token has code and Permit2 exists.
                )
            ) {
                mstore(0x00, 0x7939f4248757f0fd) // `TransferFromFailed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(iszero(shr(160, amount))))), 0x04)
            }
        }
    }

    /// @dev Permit a user to spend a given amount of
    /// another user's tokens via native EIP-2612 permit if possible, falling
    /// back to Permit2 if native permit fails or is not implemented on the token.
    function permit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        bool success;
        /// @solidity memory-safe-assembly
        assembly {
            for {} shl(96, xor(token, WETH9)) {} {
                mstore(0x00, 0x3644e515) // `DOMAIN_SEPARATOR()`.
                if iszero(
                    and( // The arguments of `and` are evaluated from right to left.
                        lt(iszero(mload(0x00)), eq(returndatasize(), 0x20)), // Returns 1 non-zero word.
                        // Gas stipend to limit gas burn for tokens that don't refund gas when
                        // an non-existing function is called. 5K should be enough for a SLOAD.
                        staticcall(5000, token, 0x1c, 0x04, 0x00, 0x20)
                    )
                ) { break }
                // After here, we can be sure that token is a contract.
                let m := mload(0x40)
                mstore(add(m, 0x34), spender)
                mstore(add(m, 0x20), shl(96, owner))
                mstore(add(m, 0x74), deadline)
                if eq(mload(0x00), DAI_DOMAIN_SEPARATOR) {
                    mstore(0x14, owner)
                    mstore(0x00, 0x7ecebe00000000000000000000000000) // `nonces(address)`.
                    mstore(
                        add(m, 0x94),
                        lt(iszero(amount), staticcall(gas(), token, 0x10, 0x24, add(m, 0x54), 0x20))
                    )
                    mstore(m, 0x8fcbaf0c000000000000000000000000) // `IDAIPermit.permit`.
                    // `nonces` is already at `add(m, 0x54)`.
                    // `amount != 0` is already stored at `add(m, 0x94)`.
                    mstore(add(m, 0xb4), and(0xff, v))
                    mstore(add(m, 0xd4), r)
                    mstore(add(m, 0xf4), s)
                    success := call(gas(), token, 0, add(m, 0x10), 0x104, codesize(), 0x00)
                    break
                }
                mstore(m, 0xd505accf000000000000000000000000) // `IERC20Permit.permit`.
                mstore(add(m, 0x54), amount)
                mstore(add(m, 0x94), and(0xff, v))
                mstore(add(m, 0xb4), r)
                mstore(add(m, 0xd4), s)
                success := call(gas(), token, 0, add(m, 0x10), 0xe4, codesize(), 0x00)
                break
            }
        }
        if (!success) simplePermit2(token, owner, spender, amount, deadline, v, r, s);
    }

    /// @dev Simple permit on the Permit2 contract.
    function simplePermit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(m, 0x927da105) // `allowance(address,address,address)`.
            {
                let addressMask := shr(96, not(0))
                mstore(add(m, 0x20), and(addressMask, owner))
                mstore(add(m, 0x40), and(addressMask, token))
                mstore(add(m, 0x60), and(addressMask, spender))
                mstore(add(m, 0xc0), and(addressMask, spender))
            }
            let p := mul(PERMIT2, iszero(shr(160, amount)))
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x5f), // Returns 3 words: `amount`, `expiration`, `nonce`.
                    staticcall(gas(), p, add(m, 0x1c), 0x64, add(m, 0x60), 0x60)
                )
            ) {
                mstore(0x00, 0x6b836e6b8757f0fd) // `Permit2Failed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(p))), 0x04)
            }
            mstore(m, 0x2b67b570) // `Permit2.permit` (PermitSingle variant).
            // `owner` is already `add(m, 0x20)`.
            // `token` is already at `add(m, 0x40)`.
            mstore(add(m, 0x60), amount)
            mstore(add(m, 0x80), 0xffffffffffff) // `expiration = type(uint48).max`.
            // `nonce` is already at `add(m, 0xa0)`.
            // `spender` is already at `add(m, 0xc0)`.
            mstore(add(m, 0xe0), deadline)
            mstore(add(m, 0x100), 0x100) // `signature` offset.
            mstore(add(m, 0x120), 0x41) // `signature` length.
            mstore(add(m, 0x140), r)
            mstore(add(m, 0x160), s)
            mstore(add(m, 0x180), shl(248, v))
            if iszero( // Revert if token does not have code, or if the call fails.
            mul(extcodesize(token), call(gas(), p, 0, add(m, 0x1c), 0x184, codesize(), 0x00))) {
                mstore(0x00, 0x6b836e6b) // `Permit2Failed()`.
                revert(0x1c, 0x04)
            }
        }
    }
}