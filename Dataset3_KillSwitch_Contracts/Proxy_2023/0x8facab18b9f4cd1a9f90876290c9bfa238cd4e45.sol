// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC173Internal } from '../../interfaces/IERC173Internal.sol';

interface IOwnableInternal is IERC173Internal {
    error Ownable__NotOwner();
    error Ownable__NotTransitiveOwner();
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC173 } from '../../interfaces/IERC173.sol';
import { AddressUtils } from '../../utils/AddressUtils.sol';
import { IOwnableInternal } from './IOwnableInternal.sol';
import { OwnableStorage } from './OwnableStorage.sol';

abstract contract OwnableInternal is IOwnableInternal {
    using AddressUtils for address;

    modifier onlyOwner() {
        if (msg.sender != _owner()) revert Ownable__NotOwner();
        _;
    }

    modifier onlyTransitiveOwner() {
        if (msg.sender != _transitiveOwner())
            revert Ownable__NotTransitiveOwner();
        _;
    }

    function _owner() internal view virtual returns (address) {
        return OwnableStorage.layout().owner;
    }

    function _transitiveOwner() internal view virtual returns (address owner) {
        owner = _owner();

        while (owner.isContract()) {
            try IERC173(owner).owner() returns (address transitiveOwner) {
                owner = transitiveOwner;
            } catch {
                break;
            }
        }
    }

    function _transferOwnership(address account) internal virtual {
        _setOwner(account);
    }

    function _setOwner(address account) internal virtual {
        OwnableStorage.Layout storage l = OwnableStorage.layout();
        emit OwnershipTransferred(l.owner, account);
        l.owner = account;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

library OwnableStorage {
    struct Layout {
        address owner;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('solidstate.contracts.storage.Ownable');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Set implementation with enumeration functions
 * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts (MIT license)
 */
library EnumerableSet {
    error EnumerableSet__IndexOutOfBounds();

    struct Set {
        bytes32[] _values;
        // 1-indexed to allow 0 to signify nonexistence
        mapping(bytes32 => uint256) _indexes;
    }

    struct Bytes32Set {
        Set _inner;
    }

    struct AddressSet {
        Set _inner;
    }

    struct UintSet {
        Set _inner;
    }

    function at(
        Bytes32Set storage set,
        uint256 index
    ) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    function at(
        AddressSet storage set,
        uint256 index
    ) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function at(
        UintSet storage set,
        uint256 index
    ) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    function contains(
        Bytes32Set storage set,
        bytes32 value
    ) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function contains(
        AddressSet storage set,
        address value
    ) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(
        UintSet storage set,
        uint256 value
    ) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function indexOf(
        Bytes32Set storage set,
        bytes32 value
    ) internal view returns (uint256) {
        return _indexOf(set._inner, value);
    }

    function indexOf(
        AddressSet storage set,
        address value
    ) internal view returns (uint256) {
        return _indexOf(set._inner, bytes32(uint256(uint160(value))));
    }

    function indexOf(
        UintSet storage set,
        uint256 value
    ) internal view returns (uint256) {
        return _indexOf(set._inner, bytes32(value));
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function add(
        Bytes32Set storage set,
        bytes32 value
    ) internal returns (bool) {
        return _add(set._inner, value);
    }

    function add(
        AddressSet storage set,
        address value
    ) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(
        Bytes32Set storage set,
        bytes32 value
    ) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function remove(
        AddressSet storage set,
        address value
    ) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(
        UintSet storage set,
        uint256 value
    ) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function toArray(
        Bytes32Set storage set
    ) internal view returns (bytes32[] memory) {
        return set._inner._values;
    }

    function toArray(
        AddressSet storage set
    ) internal view returns (address[] memory) {
        bytes32[] storage values = set._inner._values;
        address[] storage array;

        assembly {
            array.slot := values.slot
        }

        return array;
    }

    function toArray(
        UintSet storage set
    ) internal view returns (uint256[] memory) {
        bytes32[] storage values = set._inner._values;
        uint256[] storage array;

        assembly {
            array.slot := values.slot
        }

        return array;
    }

    function _at(
        Set storage set,
        uint256 index
    ) private view returns (bytes32) {
        if (index >= set._values.length)
            revert EnumerableSet__IndexOutOfBounds();
        return set._values[index];
    }

    function _contains(
        Set storage set,
        bytes32 value
    ) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _indexOf(
        Set storage set,
        bytes32 value
    ) private view returns (uint256) {
        unchecked {
            return set._indexes[value] - 1;
        }
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _add(
        Set storage set,
        bytes32 value
    ) private returns (bool status) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            status = true;
        }
    }

    function _remove(
        Set storage set,
        bytes32 value
    ) private returns (bool status) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            unchecked {
                bytes32 last = set._values[set._values.length - 1];

                // move last value to now-vacant index

                set._values[valueIndex - 1] = last;
                set._indexes[last] = valueIndex;
            }
            // clear last index

            set._values.pop();
            delete set._indexes[value];

            status = true;
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC173Internal } from './IERC173Internal.sol';

/**
 * @title Contract ownership standard interface
 * @dev see https://eips.ethereum.org/EIPS/eip-173
 */
interface IERC173 is IERC173Internal {
    /**
     * @notice get the ERC173 contract owner
     * @return conrtact owner
     */
    function owner() external view returns (address);

    /**
     * @notice transfer contract ownership to new account
     * @param account address of new owner
     */
    function transferOwnership(address account) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Partial ERC173 interface needed by internal functions
 */
interface IERC173Internal {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface IProxy {
    error Proxy__ImplementationIsNotContract();

    fallback() external payable;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { AddressUtils } from '../utils/AddressUtils.sol';
import { IProxy } from './IProxy.sol';

/**
 * @title Base proxy contract
 */
abstract contract Proxy is IProxy {
    using AddressUtils for address;

    /**
     * @notice delegate all calls to implementation contract
     * @dev reverts if implementation address contains no code, for compatibility with metamorphic contracts
     * @dev memory location in use by assembly may be unsafe in other contexts
     */
    fallback() external payable virtual {
        address implementation = _getImplementation();

        if (!implementation.isContract())
            revert Proxy__ImplementationIsNotContract();

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @notice get logic implementation address
     * @return implementation address
     */
    function _getImplementation() internal virtual returns (address);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Diamond proxy introspection interface
 * @dev see https://eips.ethereum.org/EIPS/eip-2535
 */
interface IDiamondReadable {
    struct Facet {
        address target;
        bytes4[] selectors;
    }

    /**
     * @notice get all facets and their selectors
     * @return diamondFacets array of structured facet data
     */
    function facets() external view returns (Facet[] memory diamondFacets);

    /**
     * @notice get all selectors for given facet address
     * @param facet address of facet to query
     * @return selectors array of function selectors
     */
    function facetFunctionSelectors(
        address facet
    ) external view returns (bytes4[] memory selectors);

    /**
     * @notice get addresses of all facets used by diamond
     * @return addresses array of facet addresses
     */
    function facetAddresses()
        external
        view
        returns (address[] memory addresses);

    /**
     * @notice get the address of the facet associated with given selector
     * @param selector function selector to query
     * @return facet facet address (zero address if not found)
     */
    function facetAddress(
        bytes4 selector
    ) external view returns (address facet);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { UintUtils } from './UintUtils.sol';

library AddressUtils {
    using UintUtils for uint256;

    error AddressUtils__InsufficientBalance();
    error AddressUtils__NotContract();
    error AddressUtils__SendValueFailed();

    function toString(address account) internal pure returns (string memory) {
        return uint256(uint160(account)).toHexString(20);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable account, uint256 amount) internal {
        (bool success, ) = account.call{ value: amount }('');
        if (!success) revert AddressUtils__SendValueFailed();
    }

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionCall(target, data, 'AddressUtils: failed low-level call');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory error
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, error);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                'AddressUtils: failed low-level call with value'
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory error
    ) internal returns (bytes memory) {
        if (value > address(this).balance)
            revert AddressUtils__InsufficientBalance();
        return _functionCallWithValue(target, data, value, error);
    }

    /**
     * @notice execute arbitrary external call with limited gas usage and amount of copied return data
     * @dev derived from https://github.com/nomad-xyz/ExcessivelySafeCall (MIT License)
     * @param target recipient of call
     * @param gasAmount gas allowance for call
     * @param value native token value to include in call
     * @param maxCopy maximum number of bytes to copy from return data
     * @param data encoded call data
     * @return success whether call is successful
     * @return returnData copied return data
     */
    function excessivelySafeCall(
        address target,
        uint256 gasAmount,
        uint256 value,
        uint16 maxCopy,
        bytes memory data
    ) internal returns (bool success, bytes memory returnData) {
        returnData = new bytes(maxCopy);

        assembly {
            // execute external call via assembly to avoid automatic copying of return data
            success := call(
                gasAmount,
                target,
                value,
                add(data, 0x20),
                mload(data),
                0,
                0
            )

            // determine whether to limit amount of data to copy
            let toCopy := returndatasize()

            if gt(toCopy, maxCopy) {
                toCopy := maxCopy
            }

            // store the length of the copied bytes
            mstore(returnData, toCopy)

            // copy the bytes from returndata[0:toCopy]
            returndatacopy(add(returnData, 0x20), 0, toCopy)
        }
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory error
    ) private returns (bytes memory) {
        if (!isContract(target)) revert AddressUtils__NotContract();

        (bool success, bytes memory returnData) = target.call{ value: value }(
            data
        );

        if (success) {
            return returnData;
        } else if (returnData.length > 0) {
            assembly {
                let returnData_size := mload(returnData)
                revert(add(32, returnData), returnData_size)
            }
        } else {
            revert(error);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title utility functions for uint256 operations
 * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts/ (MIT license)
 */
library UintUtils {
    error UintUtils__InsufficientHexLength();

    bytes16 private constant HEX_SYMBOLS = '0123456789abcdef';

    function add(uint256 a, int256 b) internal pure returns (uint256) {
        return b < 0 ? sub(a, -b) : a + uint256(b);
    }

    function sub(uint256 a, int256 b) internal pure returns (uint256) {
        return b < 0 ? add(a, -b) : a - uint256(b);
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return '0';
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return '0x00';
        }

        uint256 length = 0;

        for (uint256 temp = value; temp != 0; temp >>= 8) {
            unchecked {
                length++;
            }
        }

        return toHexString(value, length);
    }

    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = '0';
        buffer[1] = 'x';

        unchecked {
            for (uint256 i = 2 * length + 1; i > 1; --i) {
                buffer[i] = HEX_SYMBOLS[value & 0xf];
                value >>= 4;
            }
        }

        if (value != 0) revert UintUtils__InsufficientHexLength();

        return string(buffer);
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;

import { ERC1155MetadataExtensionStorage } from './ERC1155MetadataExtensionStorage.sol';

abstract contract ERC1155MetadataExtensionInternal {
    /**
     * @notice sets a new name for ECR1155 collection
     * @param name name to set
     */
    function _setName(string memory name) internal {
        ERC1155MetadataExtensionStorage.layout().name = name;
    }

    /**
     * @notice sets a new symbol for ECR1155 collection
     * @param symbol symbol to set
     */
    function _setSymbol(string memory symbol) internal {
        ERC1155MetadataExtensionStorage.layout().symbol = symbol;
    }

    /**
     * @notice reads ERC1155 collcetion name
     * @return name ERC1155 collection name
     */
    function _name() internal view returns (string memory name) {
        name = ERC1155MetadataExtensionStorage.layout().name;
    }

    /**
     * @notice reads ERC1155 collcetion symbol
     * @return symbol ERC1155 collection symbol
     */
    function _symbol() internal view returns (string memory symbol) {
        symbol = ERC1155MetadataExtensionStorage.layout().symbol;
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;

library ERC1155MetadataExtensionStorage {
    struct Layout {
        string name;
        string symbol;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('insrt.contracts.storage.ERC1155MetadataExtensionStorage');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;

import { IOwnableInternal } from '@solidstate/contracts/access/ownable/IOwnableInternal.sol';

interface ISimpleVaultInternal is IOwnableInternal {
    /**
     * @notice indicates which lending adaptor is to be interacted with
     */
    enum LendingAdaptor {
        DEFAULT, //allows for passing an 'empty' adaptor argument in functions
        JPEGD
    }

    /**
     * @notice indicates which staking adaptor is to be interacted with
     */
    enum StakingAdaptor {
        DEFAULT, //allows for passing an 'empty' adaptor argument in functions
        JPEGD
    }

    /**
     * @notice encapsulates an amount of fees of a particular token
     */
    struct TokenFee {
        address token;
        uint256 fees;
    }

    /**
     * @notice encapsulates an amount of yield of a particular token
     */
    struct TokenYield {
        address token;
        uint256 yield;
    }

    /**
     * @notice encapsulates the cumulative amount of yield accrued of a paritcular token per shard
     */
    struct TokensPerShard {
        address token;
        uint256 cumulativeAmount;
    }

    /**
     * @notice thrown when function called by non-protocol owner
     */
    error SimpleVault__NotProtocolOwner();

    /**
     * @notice thrown when function called by account which is  non-authorized and non-protocol owner
     */
    error SimpleVault__NotAuthorized();

    /**
     * @notice thrown when the deposit amount is not a multiple of shardSize
     */
    error SimpleVault__InvalidDepositAmount();

    /**
     * @notice thrown when the maximum capital has been reached or vault has invested
     */
    error SimpleVault__DepositForbidden();

    /**
     * @notice thrown when attempting to call a disabled function
     */
    error SimpleVault__NotEnabled();

    /**
     * @notice thrown when user is attempting to deposit after owning (minting) max shards
     */
    error SimpleVault__MaxMintBalance();

    /**
     * @notice thrown when attempting to act without being whitelisted
     */
    error SimpleVault__NotWhitelisted();

    /**
     * @notice thrown when the maximum capital has been reached or vault has invested
     */
    error SimpleVault__WithdrawalForbidden();

    /**
     * @notice thrown when setting a basis point fee value larger than 10000
     */
    error SimpleVault__BasisExceeded();

    /**
     * @notice thrown when attempting to claim yield before yield claiming is initialized
     */
    error SimpleVault__YieldClaimingForbidden();

    /**
     * @notice thrown when attempting to set a reserved supply larger than max supply
     */
    error SimpleVault__ExceededMaxSupply();

    /**
     * @notice thrown when setting a max supply which is smaller than total supply
     */
    error SimpleVault__MaxSupplyTooSmall();

    /**
     * @notice thrown when the vault does not have enough ETH to account for an ETH transfer + respective fee
     */
    error SimpleVault__InsufficientETH();

    /**
     * @notice thrown when attempting to interact on a collection which is not part of the vault collections
     */
    error SimpleVault__NotCollectionOfVault();

    /**
     * @notice thrown when marking a token for sale which is not in ownedTokenIds
     */
    error SimpleVault__NotOwnedToken();

    /**
     * @notice thrown when attempting to sell a token  not marked for sale
     */
    error SimpleVault__TokenNotForSale();

    /**
     * @notice thrown when an incorrect ETH amount is received during token sale
     */
    error SimpleVault__IncorrectETHReceived();

    /**
     * @notice thrown when attempted to mark a token for sale whilst it is collateralized
     */
    error SimpleVault__TokenCollateralized();

    /**
     * @notice thrown when attempting to discount yield fee with a DAWN_OF_INSRT token not
     * belonging to account yield fee is being discounted for
     */
    error SimpleVault__NotDawnOfInsrtTokenOwner();

    /**
     * @notice thrown when attempting to add a token to collectionOwnedTokens without vault being the token owner
     */
    error SimpleVault__NotTokenOwner();

    /**
     * @notice thrown when attempting to remove a token from collectionOwnedTokens with vault being the token owner
     */
    error SimpleVault__TokenStillOwned();

    /**
     * @notice emitted when an ERC721 is transferred from the treasury to the vault in exchange for ETH
     * @param tokenId id of ERC721 asset
     */
    event ERC721AssetTransfered(uint256 tokenId);

    /**
     * @notice emitted when protocol fees are withdrawn
     * @param tokenFees array of TokenFee structs indicating address of fee token and amount
     */
    event FeesWithdrawn(TokenFee[3] tokenFees);

    /**
     * @notice emitted when an token is marked for sale
     * @param collection address of collection of token
     * @param tokenId id of token
     * @param price price in ETH of token
     */
    event TokenMarkedForSale(
        address collection,
        uint256 tokenId,
        uint256 price
    );

    /**
     * @notice emitted when a token is sold
     * @param collection address of token collection
     * @param tokenId id of token
     */
    event TokenSold(address collection, uint256 tokenId);

    /**
     * @notice emitted when whitelistEndsAt is set
     * @param whitelistEndsAt the new whitelistEndsAt timestamp
     */
    event WhitelistEndsAtSet(uint48 whitelistEndsAt);

    /**
     * @notice emitted when reservedSupply is set
     * @param reservedSupply the new reservedSupply
     */
    event ReservedSupplySet(uint64 reservedSupply);

    /**
     * @notice emitted when isEnabled is set
     * @param isEnabled the new isEnabled value
     */
    event IsEnabledSet(bool isEnabled);

    /**
     * @notice emitted when maxMintBalance is set
     * @param maxMintBalance the new maxMintBalance
     */
    event MaxMintBalanceSet(uint64 maxMintBalance);

    /**
     * @notice emitted when maxSupply is set
     * @param maxSupply the new maxSupply
     */
    event MaxSupplySet(uint64 maxSupply);

    /**
     * @notice emitted when sale fee is set
     * @param feeBP the new sale fee basis points
     */
    event SaleFeeSet(uint16 feeBP);

    /**
     * @notice emitted when acquisition fee is set
     * @param feeBP the new acquisition fee basis points
     */
    event AcquisitionFeeSet(uint16 feeBP);

    /**
     * @notice emitted when yield fee is set
     * @param feeBP the new yield fee basis points
     */
    event YieldFeeSet(uint16 feeBP);

    /**
     * @notice emitted when ltvBufferBP is set
     * @param bufferBP new ltvBufferBP value
     */
    event LTVBufferSet(uint16 bufferBP);

    /**
     * @notice emitted when ltvDeviationBP is set
     * @param deviationBP new ltvDeviationBP value
     */
    event LTVDeviationSet(uint16 deviationBP);

    /**
     * @notice emitted when a collection is removed from vault collections
     * @param collection address of removed collection
     */
    event CollectionRemoved(address collection);

    /**
     * @notice emitted when a collection is added to vault collections
     * @param collection address of added collection
     */
    event CollectionAdded(address collection);

    /**
     * @notice emitted when an owned token is added to a collection manually
     * @param collection collection address
     * @param tokenId tokenId
     */
    event OwnedTokenAddedToCollection(address collection, uint256 tokenId);

    /**
     * @notice emitted when an owned token is removed from a collection manually
     * @param collection collection address
     * @param tokenId tokenId
     */
    event OwnedTokenRemovedFromCollection(address collection, uint256 tokenId);

    /**
     * @notice emmitted when the 'authorized' state is granted to or revoked from an account
     * @param account address of account to grant/revoke 'authorized'
     * @param isAuthorized value of 'authorized' state
     */
    event AuthorizedSet(address account, bool isAuthorized);

    /**
     * @notice emitted when an ERC721 asset is collateralized in a lending vendor
     * @param adaptor enum indicating which lending vendor adaptor was used
     * @param collection address of ERC721 collection
     * @param tokenId id of token
     */
    event ERC721AssetCollateralized(
        LendingAdaptor adaptor,
        address collection,
        uint256 tokenId
    );

    /**
     * @notice emitted when lending vendor tokens received for collateralizing and asset
     *  are staked in a lending vendor
     * @param adaptor enum indicating which lending vendor adaptor was used
     * @param shares lending vendor shares received after staking, if any
     */
    event Staked(StakingAdaptor adaptor, uint256 shares);

    /**
     * @notice emitted when a position in a lending vendor is unstaked and converted back
     * to the tokens which were initially staked
     * @param adaptor enum indicating which lending vendor adaptor was used
     * @param tokenAmount amount of tokens received for unstaking
     */
    event Unstaked(StakingAdaptor adaptor, uint256 tokenAmount);

    /**
     * @notice emitted when a certain amount of the staked position in a lending vendor is
     * unstaked and converted to tokens to be provided as yield
     * @param adaptor enum indicating which lending vendor adaptor was used
     * @param tokenYields array of token addresses and corresponding yields provided
     */
    event YieldProvided(StakingAdaptor adaptor, TokenYield[] tokenYields);

    /**
     * @notice emitted when a loan repayment is made for a collateralized position
     * @param adaptor enum indicating which lending vendor adaptor was used
     * @param paidDebt amount of debt repaid
     */
    event LoanPaymentMade(LendingAdaptor adaptor, uint256 paidDebt);

    /**
     * @notice emitted when a loan is repaid in full and the position is closed
     * @param adaptor enum indicating which lending vendor adaptor was used
     * @param receivedETH amount of ETH received after closing position
     */
    event PositionClosed(LendingAdaptor adaptor, uint256 receivedETH);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;

import { EnumerableSet } from '@solidstate/contracts/data/EnumerableSet.sol';
import { IDiamondReadable } from '@solidstate/contracts/proxy/diamond/readable/IDiamondReadable.sol';
import { OwnableInternal } from '@solidstate/contracts/access/ownable/OwnableInternal.sol';
import { Proxy } from '@solidstate/contracts/proxy/Proxy.sol';

import { ERC1155MetadataExtensionInternal } from './ERC1155MetadataExtensionInternal.sol';
import { SimpleVaultStorage } from './SimpleVaultStorage.sol';

/**
 * @title Upgradeable proxy with externally controlled SimpleVault implementation
 */
contract SimpleVaultProxy is
    Proxy,
    OwnableInternal,
    ERC1155MetadataExtensionInternal
{
    using EnumerableSet for EnumerableSet.AddressSet;

    address private immutable SIMPLE_VAULT_DIAMOND;

    constructor(
        address simpleVaultDiamond,
        address whitelist,
        uint256 shardValue,
        uint64 maxSupply,
        uint64 maxMintBalance,
        uint16 acquisitionFeeBP,
        uint16 saleFeeBP,
        uint16 yieldFeeBP,
        uint16 ltvBufferBP,
        uint16 ltvDeviationBP,
        address[] memory collections,
        string memory name,
        string memory symbol
    ) {
        SIMPLE_VAULT_DIAMOND = simpleVaultDiamond;

        _setOwner(msg.sender);

        _setName(name);
        _setSymbol(symbol);

        SimpleVaultStorage.Layout storage l = SimpleVaultStorage.layout();

        l.whitelist = whitelist;
        l.shardValue = shardValue;
        l.maxSupply = maxSupply;
        l.maxMintBalance = maxMintBalance;

        l.acquisitionFeeBP = acquisitionFeeBP;
        l.saleFeeBP = saleFeeBP;
        l.yieldFeeBP = yieldFeeBP;
        l.ltvBufferBP = ltvBufferBP;
        l.ltvDeviationBP = ltvDeviationBP;

        for (uint256 i; i < collections.length; ++i) {
            l.vaultCollections.add(collections[i]);
        }
    }

    /**
     * @inheritdoc Proxy
     * @notice fetch logic implementation address from external diamond proxy
     */
    function _getImplementation() internal view override returns (address) {
        return IDiamondReadable(SIMPLE_VAULT_DIAMOND).facetAddress(msg.sig);
    }

    /**
     * @notice required in order to accept ETH in exchange for minting shards
     */
    receive() external payable {}
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;

import { ISimpleVaultInternal } from './ISimpleVaultInternal.sol';
import { EnumerableSet } from '@solidstate/contracts/data/EnumerableSet.sol';

library SimpleVaultStorage {
    struct Layout {
        uint256 shardValue;
        uint256 accruedFees;
        //maximum tokens of MINT_TOKEN_ID which may be minted from deposits.
        //will be set to current totalSupply of MINT_TOKEN_ID if ERC721 asset
        //is purchased by vault prior to maxSupply of shards being minted
        uint64 maxSupply;
        uint16 saleFeeBP;
        uint16 acquisitionFeeBP;
        address whitelist;
        uint64 maxMintBalance;
        uint64 reservedSupply;
        uint48 whitelistEndsAt;
        bool isEnabled;
        bool isYieldClaiming;
        EnumerableSet.AddressSet vaultCollections;
        //registered all ids of ERC721 tokens acquired by vault - was replaced with collectionOwnedTokenIds
        //in order to allow for same id from different collections to be owned
        EnumerableSet.UintSet _deprecated_ownedtokenIds;
        mapping(address collection => mapping(uint256 tokenId => uint256 price)) priceOfSale;
        mapping(address collection => EnumerableSet.UintSet ownedTokenIds) collectionOwnedTokenIds;
        uint32 ownedTokenAmount;
        uint256 cumulativeETHPerShard;
        uint16 yieldFeeBP;
        uint16 ltvBufferBP;
        uint16 ltvDeviationBP;
        mapping(address collection => EnumerableSet.UintSet tokenIds) collateralizedTokens;
        mapping(address account => uint256 amount) ethDeductionsPerShard; //total amount of ETH deducted per shard, used to account for user rewards
        mapping(address account => uint256 amount) userETHYield;
        mapping(address account => bool isAuthorized) isAuthorized;
        mapping(ISimpleVaultInternal.StakingAdaptor adaptor => bool isActivated) activatedStakingAdaptors;
        mapping(ISimpleVaultInternal.LendingAdaptor adaptor => bool isActivated) activatedLendingAdaptors;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('insrt.contracts.storage.SimpleVault');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}