// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

interface IERC721A {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function burn(uint256) external;
    function ownershipOf(uint256) external view returns (TokenOwnership memory);
}

interface IMeteorium {
    function mint(address, uint256) external;
    function burn(uint256 tokenId, bytes calldata signature) external;
}

struct TokenOwnership {
    address addr;
    uint64 startTimestamp;
    bool burned;
    uint24 extraData;
}

/**
 * Burn, burn, burn, BUUUUUURN!
 */
contract MeteoriumFoundry is Ownable {
    error TransferFailed();
    error ForgingDisabledForType();
    error NotEnoughTokenIdsGiven();
    error IncorrectTokenIdsAmountGiven();
    error NotTokenOwner();
    error IncorrectETHValue();
    error TokenIdNotInBounds();
    error NotHoldingForLongEnough();

    struct FoundryRequirements {
        bool enabled;
        uint32 mtoHoldTime;
        uint8 reqMto;
        bool isMtoTribute;
        uint16 minMtoId;
        uint16 maxMtoId;
        uint32 mtomHoldTime;
        uint8 reqMtom;
        bool isMtomTribute;
        uint16 minMtomId;
        uint16 maxMtomId;
        uint64 price;
    }

    mapping(uint256 => FoundryRequirements) public forgeRequirements;

    address private immutable _MTO;
    address private immutable _MTOM;

    event MeteoriumForgeRequirementsUpdated(
        uint256 mtomType,
        FoundryRequirements req
    );
    event ForgedMeteoriums(uint256 meteoriumtype, uint256 forged);

    constructor(address mto, address mtom) {
        _MTO = mto;
        _MTOM = mtom;
    }

    function updateForgeRequirements(
        uint256 meteoriumType,
        FoundryRequirements calldata req
    ) external onlyOwner {
        forgeRequirements[meteoriumType] = req;

        emit MeteoriumForgeRequirementsUpdated(meteoriumType, req);
    }

    function withdraw(address _address, uint256 _amount) external onlyOwner {
        (bool success, ) = _address.call{value: _amount}("");

        if (!success) revert TransferFailed();
    }

    function burnBatch(
        uint256[] calldata tokenIds,
        bytes[] calldata sigs
    ) external onlyOwner {
        unchecked {
            for (uint256 i; i < tokenIds.length; ++i) {
                IMeteorium(_MTOM).burn(tokenIds[i], sigs[i]);
            }
        }
    }

    function forgeMeteorium(
        uint256 mtomType,
        uint256[] calldata mtoIds,
        uint256[] calldata mtomIds
    ) external payable {
        FoundryRequirements memory req = forgeRequirements[mtomType];

        // Automatically define as disabled any non initialized struct
        if (!req.enabled) revert ForgingDisabledForType();

        uint256 toForge;

        unchecked {
            uint256 reqMto = req.reqMto;
            uint256 mtoHoldTime = req.mtoHoldTime;

            if (mtoHoldTime + reqMto > 0) {
                uint256 mtoCount = mtoIds.length;

                if (reqMto > mtoCount)
                    revert NotEnoughTokenIdsGiven();
                if (mtoCount % reqMto > 0)
                    revert IncorrectTokenIdsAmountGiven();

                toForge = mtoCount / reqMto;

                uint256 startId = req.minMtoId;
                uint256 endId = req.maxMtoId;
                bool isTribute = req.isMtoTribute;

                // Dirty duplicating blocks => reduce gas cost => avoid
                // performing ops on each loops or pushing internal calls
                if (startId + endId > 2) {
                    for (uint256 i; i < mtoCount; ++i) {
                        uint256 id = mtoIds[i];

                        if (id < startId || id > endId)
                            revert TokenIdNotInBounds();

                        TokenOwnership memory tokenOwnership =
                            IERC721A(_MTO).ownershipOf(id);

                        if (block.timestamp - tokenOwnership.startTimestamp < mtoHoldTime)
                            revert NotHoldingForLongEnough();

                        if (isTribute) {
                            if (tokenOwnership.addr != msg.sender)
                                revert NotTokenOwner();

                            IERC721A(_MTO).burn(id);
                        } else {
                            // No ownership check needed => TransferFromIncorrectOwner
                            // Trick to update the last hold since time
                            IERC721A(_MTO).transferFrom(
                                msg.sender,
                                msg.sender,
                                id
                            );
                        }
                    }
                } else {
                    for (uint256 i; i < mtoCount; ++i) {
                        uint256 id = mtoIds[i];

                        TokenOwnership memory tokenOwnership =
                            IERC721A(_MTO).ownershipOf(id);

                        if (block.timestamp - tokenOwnership.startTimestamp < mtoHoldTime)
                            revert NotHoldingForLongEnough();

                        if (isTribute) {
                            if (tokenOwnership.addr != msg.sender)
                                revert NotTokenOwner();

                            IERC721A(_MTO).burn(id);
                        } else {
                            // Trick to update the last hold since time
                            IERC721A(_MTO).transferFrom(
                                msg.sender,
                                msg.sender,
                                id
                            );
                        }
                    }
                }
            }
        }

        // Duplicating here allows us to use only one fn to combinate all kind
        // of requirement or only the one configured. splitting it into 3 fn
        // would cost much in deployment for a gas saving of only 2xx on 2 calls
        unchecked {
            uint256 reqMtom = req.reqMtom;
            uint256 mtomHoldTime = req.mtomHoldTime;

            if (mtomHoldTime + reqMtom > 0) {
                uint256 mtomCount = mtomIds.length;

                if (reqMtom > mtomCount)
                    revert NotEnoughTokenIdsGiven();
                if (mtomCount % reqMtom > 0)
                    revert IncorrectTokenIdsAmountGiven();

                toForge = mtomCount / reqMtom;

                uint256 startId = req.minMtomId;
                uint256 endId = req.maxMtomId;

                // Dirty duplicating blocks => reduce gas cost => avoid
                // performing ops on each loops or pusing internal calls
                if (startId + endId > 2) {
                    for (uint256 i; i < mtomCount; ++i) {
                        uint256 id = mtomIds[i];

                        if (id < startId || id > endId)
                            revert TokenIdNotInBounds();

                        TokenOwnership memory tokenOwnership =
                            IERC721A(_MTOM).ownershipOf(id);

                        if (block.timestamp - tokenOwnership.startTimestamp < mtomHoldTime)
                            revert NotHoldingForLongEnough();

                        // No ownership checks here either as transfered to
                        // the contract (due to sig system)
                        if (req.isMtomTribute) {
                            IERC721A(_MTOM).transferFrom(
                                msg.sender,
                                address(this),
                                id
                            );
                        } else {
                            // Trick to update the last hold since time
                            IERC721A(_MTOM).transferFrom(
                                msg.sender,
                                msg.sender,
                                id
                            );
                        }
                    }
                } else {
                    for (uint256 i; i < mtomCount; ++i) {
                        uint256 id = mtomIds[i];

                        TokenOwnership memory tokenOwnership =
                            IERC721A(_MTOM).ownershipOf(id);

                        if (block.timestamp - tokenOwnership.startTimestamp < mtomHoldTime)
                            revert NotHoldingForLongEnough();

                        if (req.isMtomTribute) {
                            IERC721A(_MTOM).transferFrom(
                                msg.sender,
                                address(this),
                                id
                            );
                        } else {
                            // Trick to update the last hold since time
                            IERC721A(_MTOM).transferFrom(
                                msg.sender,
                                msg.sender,
                                id
                            );
                        }
                    }
                }
            }
        }

        if (msg.value != toForge * req.price) revert IncorrectETHValue();

        IMeteorium(_MTOM).mint(msg.sender, toForge);

        emit ForgedMeteoriums(mtomType, toForge);
    }
}