// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20721T.sol";

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC20721T is IERC20721T {
    struct TokenApprovalRef {
        address value;
    }

    struct UserApprovalRef {
        mapping(address => uint256) allowance;
        mapping(address => bool) approved;
    }

    uint256 private constant _BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;
    uint256 private constant _BITPOS_NUMBER_MINTED = 64;
    uint256 private constant _BITPOS_NUMBER_BURNED = 128;
    uint256 private constant _BITPOS_AUX = 192;
    uint256 private constant _BITMASK_AUX_COMPLEMENT = (1 << 192) - 1;
    uint256 private constant _BITPOS_START_TIMESTAMP = 160;
    uint256 private constant _BITMASK_BURNED = 1 << 224;
    uint256 private constant _BITPOS_NEXT_INITIALIZED = 225;
    uint256 private constant _BITMASK_NEXT_INITIALIZED = 1 << 225;
    uint256 private constant _BITPOS_EXTRA_DATA = 232;
    uint256 private constant _BITMASK_EXTRA_DATA_COMPLEMENT = (1 << 232) - 1;
    uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;
    uint256 private constant _MAX_MINT_ERC2309_QUANTITY_LIMIT = 5000;
    bytes32 private constant _ERC721_TRANSFER_SIGNATURE =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
    bytes32 private constant _ERC20_TRANSFER_SIGNATURE =
        keccak256(bytes("Transfer(address,address,uint256)"));
    bytes32 private constant _ERC20_APPROVAL_SIGNATURE =
        keccak256(bytes("Approval(address,address,uint256)"));

    address private _wrapper;
    uint256 private _currentIndex;
    uint256 private _burnCounter;
    uint256 public decimals;
    string private _name;
    string private _symbol;
    mapping(uint256 => uint256) private _packedOwnerships;
    mapping(address => uint256) private _packedAddressData;
    mapping(uint256 => TokenApprovalRef) private _tokenApprovals;
    mapping(address => UserApprovalRef) private _userApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    function _maxSupply() internal view virtual returns (uint256) {
        return 1000;
    }

    function _startTokenId() internal view virtual returns (uint256) {
        return _maxSupply() + 1;
    }

    function _nextTokenId() internal view virtual returns (uint256) {
        return _currentIndex;
    }

    function wrapper() public view virtual returns (address) {
        return _wrapper;
    }

    function totalSupply() public view virtual returns (uint256) {
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    function _totalMinted() internal view virtual returns (uint256) {
        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

    function _totalBurned() internal view virtual returns (uint256) {
        return _burnCounter;
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) _revert(BalanceQueryForZeroAddress.selector);
        return _packedAddressData[owner] & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return _userApprovals[owner].allowance[spender];
    }

    function _numberMinted(address owner) internal view returns (uint256) {
        return
            (_packedAddressData[owner] >> _BITPOS_NUMBER_MINTED) &
            _BITMASK_ADDRESS_DATA_ENTRY;
    }

    function _numberBurned(address owner) internal view returns (uint256) {
        return
            (_packedAddressData[owner] >> _BITPOS_NUMBER_BURNED) &
            _BITMASK_ADDRESS_DATA_ENTRY;
    }

    function _getAux(address owner) internal view returns (uint64) {
        return uint64(_packedAddressData[owner] >> _BITPOS_AUX);
    }

    function _setAux(address owner, uint64 aux) internal virtual {
        uint256 packed = _packedAddressData[owner];
        uint256 auxCasted;
        assembly {
            auxCasted := aux
        }
        packed =
            (packed & _BITMASK_AUX_COMPLEMENT) |
            (auxCasted << _BITPOS_AUX);
        _packedAddressData[owner] = packed;
    }

    function _setWrapper(address w) internal virtual {
        _wrapper = w;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 interface ID for ERC165.
            interfaceId == 0x80ac58cd || // ERC165 interface ID for ERC721.
            interfaceId == 0x5b5e139f; // ERC165 interface ID for ERC721Metadata.
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual returns (string memory) {
        if (!_exists(tokenId)) _revert(URIQueryForNonexistentToken.selector);

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, _toString(tokenId)))
                : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return address(uint160(_packedOwnershipOf(tokenId)));
    }

    function _ownershipOf(
        uint256 tokenId
    ) internal view virtual returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnershipOf(tokenId));
    }

    function _ownershipAt(
        uint256 index
    ) internal view virtual returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnerships[index]);
    }

    function _ownershipIsInitialized(
        uint256 index
    ) internal view virtual returns (bool) {
        return _packedOwnerships[index] != 0;
    }

    function _initializeOwnershipAt(uint256 index) internal virtual {
        if (_packedOwnerships[index] == 0) {
            _packedOwnerships[index] = _packedOwnershipOf(index);
        }
    }

    function _packedOwnershipOf(
        uint256 tokenId
    ) private view returns (uint256) {
        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr)
                if (curr < _currentIndex) {
                    uint256 packed = _packedOwnerships[curr];
                    if (packed & _BITMASK_BURNED == 0) {
                        while (packed == 0) {
                            packed = _packedOwnerships[--curr];
                        }
                        return packed;
                    }
                }
        }
        _revert(OwnerQueryForNonexistentToken.selector);
    }

    function _unpackedOwnership(
        uint256 packed
    ) private pure returns (TokenOwnership memory ownership) {
        ownership.addr = address(uint160(packed));
        ownership.startTimestamp = uint64(packed >> _BITPOS_START_TIMESTAMP);
        ownership.burned = packed & _BITMASK_BURNED != 0;
        ownership.extraData = uint24(packed >> _BITPOS_EXTRA_DATA);
    }

    function _packOwnershipData(
        address owner,
        uint256 flags
    ) private view returns (uint256 result) {
        assembly {
            owner := and(owner, _BITMASK_ADDRESS)
            result := or(
                owner,
                or(shl(_BITPOS_START_TIMESTAMP, timestamp()), flags)
            )
        }
    }

    function _nextInitializedFlag(
        uint256 quantity
    ) private pure returns (uint256 result) {
        assembly {
            result := shl(_BITPOS_NEXT_INITIALIZED, eq(quantity, 1))
        }
    }

    function approve(
        address _spender,
        uint256 quantityOrTokenId
    ) external returns (bool) {
        uint256 max = _maxSupply() + 1;
        if (quantityOrTokenId > max && quantityOrTokenId <= max * 2) {
            _approveERC721(_spender, quantityOrTokenId);
        } else {
            _approveERC20(msg.sender, _spender, quantityOrTokenId);
        }
        return true;
    }

    function _approveERC721(address to, uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        if (_msgSender() != owner)
            if (!isApprovedForAll(owner, _msgSender())) {
                _revert(ApprovalCallerNotOwnerNorApproved.selector);
            }

        _tokenApprovals[tokenId].value = to;
        emit Approval(owner, to, tokenId);
    }

    function _approveERC20(
        address _owner,
        address _spender,
        uint256 _tokens
    ) internal {
        _userApprovals[_owner].allowance[_spender] = _tokens;
        emit ERC20Approval(
            _ERC20_APPROVAL_SIGNATURE,
            _owner,
            _spender,
            _tokens
        );
    }

    function getApproved(
        uint256 tokenId
    ) public view virtual returns (address) {
        if (!_exists(tokenId))
            _revert(ApprovalQueryForNonexistentToken.selector);

        return _tokenApprovals[tokenId].value;
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        _userApprovals[_msgSender()].approved[operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view virtual returns (bool) {
        return _userApprovals[owner].approved[operator] || _wrapper == operator;
    }

    function tokensOfOwner(
        address owner
    ) public view returns (uint256[] memory) {
        uint256 start = _startTokenId();
        uint256 stop = _nextTokenId();
        uint256[] memory tokenIds;
        if (start != stop) tokenIds = _tokensOfOwnerIn(owner, start, stop);
        return tokenIds;
    }

    function _tokensOfOwnerIn(
        address owner,
        uint256 start,
        uint256 stop
    ) private view returns (uint256[] memory) {
        unchecked {
            if (start >= stop) _revert(InvalidQueryRange.selector);
            if (start < _startTokenId()) {
                start = _startTokenId();
            }
            uint256 stopLimit = _nextTokenId();
            if (stop >= stopLimit) {
                stop = stopLimit;
            }
            uint256[] memory tokenIds;
            uint256 tokenIdsMaxLength = balanceOf(owner);
            bool startLtStop = start < stop;
            assembly {
                tokenIdsMaxLength := mul(tokenIdsMaxLength, startLtStop)
            }
            if (tokenIdsMaxLength != 0) {
                if (stop - start <= tokenIdsMaxLength) {
                    tokenIdsMaxLength = stop - start;
                }
                assembly {
                    tokenIds := mload(0x40)
                    mstore(
                        0x40,
                        add(tokenIds, shl(5, add(tokenIdsMaxLength, 1)))
                    )
                }

                TokenOwnership memory ownership = _explicitOwnershipOf(start);
                address currOwnershipAddr;

                if (!ownership.burned) {
                    currOwnershipAddr = ownership.addr;
                }
                uint256 tokenIdsIdx;
                do {
                    ownership = _ownershipAt(start);
                    assembly {
                        switch mload(add(ownership, 0x40))
                        case 0 {
                            if mload(ownership) {
                                currOwnershipAddr := mload(ownership)
                            }
                            if iszero(shl(96, xor(currOwnershipAddr, owner))) {
                                tokenIdsIdx := add(tokenIdsIdx, 1)
                                mstore(
                                    add(tokenIds, shl(5, tokenIdsIdx)),
                                    start
                                )
                            }
                        }
                        default {
                            currOwnershipAddr := 0
                        }
                        start := add(start, 1)
                    }
                } while (!(start == stop || tokenIdsIdx == tokenIdsMaxLength));
                assembly {
                    mstore(tokenIds, tokenIdsIdx)
                }
            }
            return tokenIds;
        }
    }

    function _explicitOwnershipOf(
        uint256 tokenId
    ) internal view virtual returns (TokenOwnership memory ownership) {
        unchecked {
            if (tokenId >= _startTokenId()) {
                if (tokenId < _nextTokenId()) {
                    // If the `tokenId` is within bounds,
                    // scan backwards for the initialized ownership slot.
                    while (!_ownershipIsInitialized(tokenId)) --tokenId;
                    return _ownershipAt(tokenId);
                }
            }
        }
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return
            _startTokenId() <= tokenId &&
            tokenId < _currentIndex &&
            _packedOwnerships[tokenId] & _BITMASK_BURNED == 0;
    }

    function _isSenderApprovedOrOwner(
        address approvedAddress,
        address owner,
        address msgSender
    ) internal view virtual returns (bool result) {
        assembly {
            owner := and(owner, _BITMASK_ADDRESS)
            msgSender := and(msgSender, _BITMASK_ADDRESS)
            result := or(eq(msgSender, owner), eq(msgSender, approvedAddress))
        }
    }

    function _getApprovedSlotAndAddress(
        uint256 tokenId
    )
        private
        view
        returns (uint256 approvedAddressSlot, address approvedAddress)
    {
        TokenApprovalRef storage tokenApproval = _tokenApprovals[tokenId];
        assembly {
            approvedAddressSlot := tokenApproval.slot
            approvedAddress := sload(approvedAddressSlot)
        }
    }

    function transfer(
        address to,
        uint256 quantity
    ) public payable virtual returns (bool) {
        _transfer(msg.sender, to, quantity);
        return true;
    }

    function _transfer(address from, address to, uint256 quantity) internal {
        uint256[] memory tokens = tokensOfOwner(from);

        if (tokens.length < quantity) _revert(InsufficientBalance.selector);

        batchTransfer(
            from,
            to,
            tokens.length > quantity
                ? _getLimitedArray(tokens, quantity)
                : tokens
        );
    }

    function transferFrom(
        address from,
        address to,
        uint256 quantityOrTokenId
    ) public payable virtual returns (bool) {
        uint256 max = _maxSupply();
        if (quantityOrTokenId <= max) {
            _transfer(from, to, quantityOrTokenId);
        } else if (quantityOrTokenId <= max * 2) {
            _transferFrom(from, to, quantityOrTokenId);
            emit ERC20Transfer(_ERC20_TRANSFER_SIGNATURE, from, to, 1);
        } else {
            return false;
        }

        return true;
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        if (address(uint160(prevOwnershipPacked)) != from)
            _revert(TransferFromIncorrectOwner.selector);

        (
            uint256 approvedAddressSlot,
            address approvedAddress
        ) = _getApprovedSlotAndAddress(tokenId);

        if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSender()))
            if (!isApprovedForAll(from, _msgSender()))
                if (_userApprovals[from].allowance[msg.sender] < 1)
                    _revert(TransferCallerNotOwnerNorApproved.selector);

        if (to == address(0)) _revert(TransferToZeroAddress.selector);

        _beforeTokenTransfers(from, to, tokenId, 1);

        assembly {
            if approvedAddress {
                sstore(approvedAddressSlot, 0)
            }
        }

        unchecked {
            --_packedAddressData[from];
            ++_packedAddressData[to];

            _packedOwnerships[tokenId] = _packOwnershipData(
                to,
                _BITMASK_NEXT_INITIALIZED |
                    _nextExtraData(from, to, prevOwnershipPacked)
            );

            if (prevOwnershipPacked & _BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                if (_packedOwnerships[nextTokenId] == 0) {
                    if (nextTokenId != _currentIndex) {
                        _packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        if (_userApprovals[from].allowance[msg.sender] > 0) {
            _userApprovals[from].allowance[msg.sender]--;
        }

        if (from == _wrapper) {
            emit Locked(tokenId);
            emit MetadataUpdate(tokenId);
        } else if (to == _wrapper) {
            emit Unlocked(tokenId);
            emit MetadataUpdate(tokenId);
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function batchTransfer(
        address from,
        address to,
        uint256[] memory tokenIds
    ) public {
        emit ERC20Transfer(
            _ERC20_TRANSFER_SIGNATURE,
            from,
            to,
            tokenIds.length
        );
        for (uint256 i; i < tokenIds.length; i++) {
            _transferFrom(from, to, tokenIds[i]);
        }
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public payable virtual {
        emit ERC20Transfer(_ERC20_TRANSFER_SIGNATURE, from, to, 1);
        _transferFrom(from, to, tokenId);
        if (to.code.length != 0)
            if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
                _revert(TransferToNonERC721ReceiverImplementer.selector);
            }
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try
            IERC721Receiver(to).onERC721Received(
                _msgSender(),
                from,
                tokenId,
                _data
            )
        returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                _revert(TransferToNonERC721ReceiverImplementer.selector);
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    function _mint(address to, uint256 quantity) internal virtual {
        uint256 startTokenId = _currentIndex;
        if (quantity == 0) _revert(MintZeroQuantity.selector);

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _packedAddressData[to] +=
                quantity *
                ((1 << _BITPOS_NUMBER_MINTED) | 1);

            _packedOwnerships[startTokenId] = _packOwnershipData(
                to,
                _nextInitializedFlag(quantity) |
                    _nextExtraData(address(0), to, 0)
            );

            uint256 toMasked;
            uint256 end = startTokenId + quantity;

            assembly {
                toMasked := and(to, _BITMASK_ADDRESS)
                log4(
                    0,
                    0,
                    _ERC721_TRANSFER_SIGNATURE,
                    0,
                    toMasked,
                    startTokenId
                )

                for {
                    let tokenId := add(startTokenId, 1)
                } iszero(eq(tokenId, end)) {
                    tokenId := add(tokenId, 1)
                } {
                    log4(0, 0, _ERC721_TRANSFER_SIGNATURE, 0, toMasked, tokenId)
                }
            }

            emit ERC20Transfer(
                _ERC20_TRANSFER_SIGNATURE,
                address(0),
                to,
                quantity
            );

            if (toMasked == 0) _revert(MintToZeroAddress.selector);

            _currentIndex = end;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _mintERC2309(address to, uint256 quantity) internal virtual {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) _revert(MintToZeroAddress.selector);
        if (quantity == 0) _revert(MintZeroQuantity.selector);
        if (quantity > _MAX_MINT_ERC2309_QUANTITY_LIMIT)
            _revert(MintERC2309QuantityExceedsLimit.selector);

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _packedAddressData[to] +=
                quantity *
                ((1 << _BITPOS_NUMBER_MINTED) | 1);

            _packedOwnerships[startTokenId] = _packOwnershipData(
                to,
                _nextInitializedFlag(quantity) |
                    _nextExtraData(address(0), to, 0)
            );

            emit ConsecutiveTransfer(
                startTokenId,
                startTokenId + quantity - 1,
                address(0),
                to
            );

            _currentIndex = startTokenId + quantity;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal virtual {
        _mint(to, quantity);

        unchecked {
            if (to.code.length != 0) {
                uint256 end = _currentIndex;
                uint256 index = end - quantity;
                do {
                    if (
                        !_checkContractOnERC721Received(
                            address(0),
                            to,
                            index++,
                            _data
                        )
                    ) {
                        _revert(
                            TransferToNonERC721ReceiverImplementer.selector
                        );
                    }
                } while (index < end);
                if (_currentIndex != end) revert();
            }
        }
    }

    function _safeMint(address to, uint256 quantity) internal virtual {
        _safeMint(to, quantity, "");
    }

    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
    }

    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        address from = address(uint160(prevOwnershipPacked));

        (
            uint256 approvedAddressSlot,
            address approvedAddress
        ) = _getApprovedSlotAndAddress(tokenId);

        if (approvalCheck) {
            if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSender()))
                if (!isApprovedForAll(from, _msgSender()))
                    _revert(TransferCallerNotOwnerNorApproved.selector);
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        assembly {
            if approvedAddress {
                sstore(approvedAddressSlot, 0)
            }
        }

        unchecked {
            _packedAddressData[from] += (1 << _BITPOS_NUMBER_BURNED) - 1;

            _packedOwnerships[tokenId] = _packOwnershipData(
                from,
                (_BITMASK_BURNED | _BITMASK_NEXT_INITIALIZED) |
                    _nextExtraData(from, address(0), prevOwnershipPacked)
            );

            if (prevOwnershipPacked & _BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                if (_packedOwnerships[nextTokenId] == 0) {
                    if (nextTokenId != _currentIndex) {
                        _packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        emit ERC20Transfer(_ERC20_TRANSFER_SIGNATURE, from, address(0), 1);
        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        unchecked {
            _burnCounter++;
        }
    }

    function _getLimitedArray(
        uint256[] memory originalArray,
        uint256 length
    ) internal pure returns (uint256[] memory) {
        if (length > originalArray.length)
            _revert(InvalidArrayOperation.selector);
        uint256[] memory limitedArray = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            limitedArray[i] = originalArray[i];
        }
        return limitedArray;
    }

    function _setExtraDataAt(uint256 index, uint24 extraData) internal virtual {
        uint256 packed = _packedOwnerships[index];
        if (packed == 0) _revert(OwnershipNotInitializedForExtraData.selector);
        uint256 extraDataCasted;
        assembly {
            extraDataCasted := extraData
        }
        packed =
            (packed & _BITMASK_EXTRA_DATA_COMPLEMENT) |
            (extraDataCasted << _BITPOS_EXTRA_DATA);
        _packedOwnerships[index] = packed;
    }

    function _extraData(
        address from,
        address to,
        uint24 previousExtraData
    ) internal view virtual returns (uint24) {}

    function _nextExtraData(
        address from,
        address to,
        uint256 prevOwnershipPacked
    ) private view returns (uint256) {
        uint24 extraData = uint24(prevOwnershipPacked >> _BITPOS_EXTRA_DATA);
        return uint256(_extraData(from, to, extraData)) << _BITPOS_EXTRA_DATA;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _toString(
        uint256 value
    ) internal pure virtual returns (string memory str) {
        assembly {
            let m := add(mload(0x40), 0xa0)
            mstore(0x40, m)
            str := sub(m, 0x20)
            mstore(str, 0)

            let end := str

            for {
                let temp := value
            } 1 {

            } {
                str := sub(str, 1)
                mstore8(str, add(48, mod(temp, 10)))
                temp := div(temp, 10)
                if iszero(temp) {
                    break
                }
            }

            let length := sub(end, str)
            str := sub(str, 0x20)
            mstore(str, length)
        }
    }

    function _revert(bytes4 errorSelector) internal pure {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }
}

contract ERC20721TWrapper is IERC20721TWrapper {
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    IERC20721T public immutable base;

    constructor(
        string memory name_,
        string memory symbol_,
        address _baseContract
    ) {
        _name = name_;
        _symbol = symbol_;
        base = IERC20721T(_baseContract);
    }

    function wrappedTokenPool() public view returns (uint256[] memory) {
        return base.tokensOfOwner(address(this));
    }

    function wrap(uint256 quantity) public payable virtual {
        uint256[] memory tokens = base.tokensOfOwner(msg.sender);
        if (tokens.length < quantity) _revert(InsufficientNFTBalance.selector);
        base.batchTransfer(
            msg.sender,
            address(this),
            _getLimitedArray(tokens, quantity)
        );
        _mint(msg.sender, quantity * 10 ** decimals());
        emit Wrap(msg.sender, quantity);
    }

    function wrap(uint256[] calldata tokenIds) public payable virtual {
        base.batchTransfer(msg.sender, address(this), tokenIds);
        _mint(msg.sender, tokenIds.length * 10 ** decimals());
        emit Wrap(msg.sender, tokenIds.length);
    }

    function unwrap(uint256 quantity) public payable virtual {
        base.transfer(msg.sender, quantity);
        _burn(msg.sender, quantity * 10 ** decimals());
        emit Unwrap(msg.sender, quantity);
    }

    function unwrap(uint256[] calldata tokenIds) public payable virtual {
        base.batchTransfer(address(this), msg.sender, tokenIds);
        _burn(msg.sender, tokenIds.length * 10 ** decimals());
        emit Unwrap(msg.sender, tokenIds.length);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 value
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value,
        bool emitEvent
    ) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _getLimitedArray(
        uint256[] memory originalArray,
        uint256 length
    ) internal pure returns (uint256[] memory) {
        if (length > originalArray.length)
            _revert(InvalidArrayOperation.selector);
        uint256[] memory limitedArray = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            limitedArray[i] = originalArray[i];
        }
        return limitedArray;
    }

    function _revert(bytes4 errorSelector) internal pure {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20721T {
    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
        bool burned;
        uint24 extraData;
    }

    error ApprovalCallerNotOwnerNorApproved();
    error ApprovalQueryForNonexistentToken();
    error BalanceQueryForZeroAddress();
    error MintToZeroAddress();
    error MintZeroQuantity();
    error OwnerQueryForNonexistentToken();
    error TransferCallerNotOwnerNorApproved();
    error TransferFromIncorrectOwner();
    error TransferToNonERC721ReceiverImplementer();
    error TransferToZeroAddress();
    error URIQueryForNonexistentToken();
    error MintERC2309QuantityExceedsLimit();
    error OwnershipNotInitializedForExtraData();
    error InvalidQueryRange();
    error InsufficientBalance();
    error InvalidArrayOperation();

    event ERC20Transfer(
        bytes32 indexed topic0,
        address indexed from,
        address indexed to,
        uint256 tokens
    ) anonymous;
    event ERC20Approval(
        bytes32 indexed topic0,
        address indexed owner,
        address indexed spender,
        uint256 tokens
    ) anonymous;
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    event ConsecutiveTransfer(
        uint256 indexed fromTokenId,
        uint256 toTokenId,
        address indexed from,
        address indexed to
    );
    event Locked(uint256 tokenId);
    event Unlocked(uint256 tokenId);
    event MetadataUpdate(uint256 _tokenId);

    function decimals() external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function ownerOf(uint256 tokenId) external view returns (address);

    function approve(
        address _spender,
        uint256 quantityOrTokenId
    ) external returns (bool);

    function getApproved(uint256 tokenId) external view returns (address);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);

    function tokensOfOwner(
        address owner
    ) external view returns (uint256[] memory);

    function transfer(
        address to,
        uint256 quantity
    ) external payable returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 quantityOrTokenId
    ) external payable returns (bool);

    function batchTransfer(
        address from,
        address to,
        uint256[] memory tokenIds
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) external payable;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC20721TWrapper {
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
    error InvalidArrayOperation();
    error InsufficientNFTBalance();

    event Wrap(address account, uint256 quantity);
    event Unwrap(address account, uint256 quantity);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function base() external view returns (IERC20721T);

    function wrappedTokenPool() external view returns (uint256[] memory);

    function wrap(uint256 quantity) external payable;

    function wrap(uint256[] calldata tokenIds) external payable;

    function unwrap(uint256 quantity) external payable;

    function unwrap(uint256[] calldata tokenIds) external payable;

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20721TWrapper} from "./ERC20721T.sol";

contract TekomonWrapper is ERC20721TWrapper {
    constructor(
        address base
    ) ERC20721TWrapper("Wrapped Tekomon", "wTEKOMON", base) {}
}