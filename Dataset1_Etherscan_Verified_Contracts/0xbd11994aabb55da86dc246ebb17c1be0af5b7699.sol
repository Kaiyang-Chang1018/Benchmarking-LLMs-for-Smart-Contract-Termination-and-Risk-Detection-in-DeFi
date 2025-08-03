// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

///////////////////////////////////////////////////////////
// ░██████╗░█████╗░██████╗░██╗██████╗░████████╗██╗░░░██╗ //
// ██╔════╝██╔══██╗██╔══██╗██║██╔══██╗╚══██╔══╝╚██╗░██╔╝ //
// ╚█████╗░██║░░╚═╝██████╔╝██║██████╔╝░░░██║░░░░╚████╔╝░ //
// ░╚═══██╗██║░░██╗██╔══██╗██║██╔═══╝░░░░██║░░░░░╚██╔╝░░ //
// ██████╔╝╚█████╔╝██║░░██║██║██║░░░░░░░░██║░░░░░░██║░░░ //
// ╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝╚═╝░░░░░░░░╚═╝░░░░░░╚═╝░░░ //
///////////////////////////////////////////////////////////
//░░░░░░░░░░░░░░░░░░░░    STORAGE    ░░░░░░░░░░░░░░░░░░░░//
///////////////////////////////////////////////////////////

/**
  @title A generic data storage contract
  @author @xtremetom
  @author @0xthedude

  Built on top of FileStore from EthFS V2. Chunk pointers
  are deterministic and using the EthFS's salt.

  Special thanks to @frolic, @cxkoda and @dhof.
*/

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IFileStore} from "./dependencies/ethfs/IFileStore.sol";
import "./dependencies/ethfs/common.sol";
import {AddressChunks} from "./utils/AddressChunks.sol";

import {IScriptyStorage} from "./interfaces/IScriptyStorage.sol";
import {IScriptyContractStorage} from "./interfaces/IScriptyContractStorage.sol";

contract ScriptyStorageV2 is Ownable, IScriptyStorage, IScriptyContractStorage {
    IFileStore public immutable ethfsFileStore;
    mapping(string => Content) public contents;

    constructor(IFileStore ethfsFileStore_) {
        ethfsFileStore = IFileStore(ethfsFileStore_);
    }

    // =============================================================
    //                           MODIFIERS
    // =============================================================

    /**
     * @notice Check if the msg.sender is the owner of the content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     */
    modifier isContentOwner(string calldata name) {
        if (msg.sender != contents[name].owner) revert NotContentOwner();
        _;
    }

    /**
     * @notice Check if a content can be created by checking if it already exists
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     */
    modifier canCreate(string calldata name) {
        if (contents[name].owner != address(0)) revert ContentExists();
        _;
    }

    /**
     * @notice Check if a content is frozen
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     */
    modifier isFrozen(string calldata name) {
        if (contents[name].isFrozen) revert ContentIsFrozen(name);
        _;
    }

    // =============================================================
    //                      MANAGEMENT OPERATIONS
    // =============================================================

    /**
     * @notice Create a new content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param details - Any details the owner wishes to store about the content
     *
     * Emits an {ContentCreated} event.
     */
    function createContent(
        string calldata name,
        bytes calldata details
    ) public canCreate(name) {
        contents[name] = Content(
            false,
            msg.sender,
            0,
            details,
            new address[](0)
        );
        emit ContentCreated(name, details);
    }

    /**
     * @notice Add a code chunk to the content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param chunk - Next sequential code chunk
     *
     * Emits an {ChunkStored} event.
     */
    function addChunkToContent(
        string calldata name,
        bytes calldata chunk
    ) public isFrozen(name) isContentOwner(name) {
        address pointer = addContent(ethfsFileStore.deployer(), chunk);
        contents[name].chunks.push(pointer);
        contents[name].size += chunk.length;
        emit ChunkStored(name, chunk.length);
    }

    /**
     * @notice Edit the content details
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param details - Any details the owner wishes to store about the content
     *
     * Emits an {ContentDetailsUpdated} event.
     */
    function updateDetails(
        string calldata name,
        bytes calldata details
    ) public isFrozen(name) isContentOwner(name) {
        contents[name].details = details;
        emit ContentDetailsUpdated(name, details);
    }

    /**
     * @notice Update the frozen status of the content
     * @dev [WARNING] Once a content it frozen is can no longer be edited
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     *
     * Emits an {ContentFrozen} event.
     */
    function freezeContent(
        string calldata name
    ) public isFrozen(name) isContentOwner(name) {
        contents[name].isFrozen = true;
        emit ContentFrozen(name);
    }

    /**
     * @notice Submit content to EthFS V2 FileStore
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param metadata - metadata for EthFS V2 File
     *
     * Uses name as file name.
     * Emits an {ContentSubmittedToFileStore} event.
     */
    function submitToEthFSFileStore(
        string calldata name,
        bytes memory metadata
    ) public isContentOwner(name) {
        Content memory content = contents[name];
        ethfsFileStore.createFileFromPointers(
            name,
            content.chunks,
            metadata
        );
        contents[name].isFrozen = true;
        emit ContentSubmittedToEthFSFileStore(name, name);
    }

    /**
     * @notice Submit content to EthFS V2 FileStore
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param fileName - Name given to the File in FileStore
     * @param metadata - metadata for EthFS V2 File
     *
     * Emits an {ContentSubmittedToFileStore} event.
     */
    function submitToEthFSFileStoreWithFileName(
        string calldata name,
        string calldata fileName,
        bytes memory metadata
    ) public isContentOwner(name) {
        Content memory content = contents[name];
        ethfsFileStore.createFileFromPointers(
            fileName,
            content.chunks,
            metadata
        );
        contents[name].isFrozen = true;
        emit ContentSubmittedToEthFSFileStore(name, fileName);
    }

    // =============================================================
    //                            GETTERS
    // =============================================================

    /**
     * @notice Get the full content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param data - Arbitrary data. Not used by this contract.
     * @return content - Full content from merged chunks
     */
    function getContent(
        string memory name,
        bytes memory data
    ) public view returns (bytes memory content) {
        return AddressChunks.mergeChunks(contents[name].chunks);
    }

    /**
     * @notice Get content's chunk pointer list
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @return pointers - List of pointers
     */
    function getContentChunkPointers(
        string memory name
    ) public view returns (address[] memory pointers) {
        return contents[name].chunks;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/**
 * @title EthFS File
 * @notice A representation of an onchain file, composed of slices of contract bytecode and utilities to construct the file contents from those slices.
 * @dev For best gas efficiency, it's recommended using `File.read()` as close to the output returned by the contract call as possible. Lots of gas is consumed every time a large data blob is passed between functions.
 */

/**
 * @dev Represents a reference to a slice of bytecode in a contract
 */
struct BytecodeSlice {
    address pointer;
    uint32 start;
    uint32 end;
}

/**
 * @dev Represents a file composed of one or more bytecode slices
 */
struct File {
    // Total length of file contents (sum of all slice sizes). Useful when you want to use DynamicBuffer to build the file contents from the slices.
    uint256 size;
    BytecodeSlice[] slices;
}
// extend File struct with read functions
using {read} for File global;
using {readUnchecked} for File global;

/**
 * @dev Error thrown when a slice is out of the bounds of the contract's bytecode
 */
error SliceOutOfBounds(
    address pointer,
    uint32 codeSize,
    uint32 sliceStart,
    uint32 sliceEnd
);

/**
 * @notice Reads the contents of a file by concatenating its slices
 * @param file The file to read
 * @return contents The concatenated contents of the file
 */
function read(File memory file) view returns (string memory contents) {
    BytecodeSlice[] memory slices = file.slices;
    bytes4 sliceOutOfBoundsSelector = SliceOutOfBounds.selector;

    assembly {
        let len := mload(slices)
        let size := 0x20
        contents := mload(0x40)
        let slice
        let pointer
        let start
        let end
        let codeSize

        for {
            let i := 0
        } lt(i, len) {
            i := add(i, 1)
        } {
            slice := mload(add(slices, add(0x20, mul(i, 0x20))))
            pointer := mload(slice)
            start := mload(add(slice, 0x20))
            end := mload(add(slice, 0x40))

            codeSize := extcodesize(pointer)
            if gt(end, codeSize) {
                mstore(0x00, sliceOutOfBoundsSelector)
                mstore(0x04, pointer)
                mstore(0x24, codeSize)
                mstore(0x44, start)
                mstore(0x64, end)
                revert(0x00, 0x84)
            }

            extcodecopy(pointer, add(contents, size), start, sub(end, start))
            size := add(size, sub(end, start))
        }

        // update contents size
        mstore(contents, sub(size, 0x20))
        // store contents
        mstore(0x40, add(contents, and(add(size, 0x1f), not(0x1f))))
    }
}

/**
 * @notice Reads the contents of a file without reverting on unreadable/invalid slices. Skips any slices that are out of bounds or invalid. Useful if you are composing contract bytecode where a contract can still selfdestruct (which would result in an invalid slice) and want to avoid reverts but still output potentially "corrupted" file contents (due to missing data).
 * @param file The file to read
 * @return contents The concatenated contents of the file, skipping invalid slices
 */
function readUnchecked(File memory file) view returns (string memory contents) {
    BytecodeSlice[] memory slices = file.slices;

    assembly {
        let len := mload(slices)
        let size := 0x20
        contents := mload(0x40)
        let slice
        let pointer
        let start
        let end
        let codeSize

        for {
            let i := 0
        } lt(i, len) {
            i := add(i, 1)
        } {
            slice := mload(add(slices, add(0x20, mul(i, 0x20))))
            pointer := mload(slice)
            start := mload(add(slice, 0x20))
            end := mload(add(slice, 0x40))

            codeSize := extcodesize(pointer)
            if lt(end, codeSize) {
                extcodecopy(
                    pointer,
                    add(contents, size),
                    start,
                    sub(end, start)
                )
                size := add(size, sub(end, start))
            }
        }

        // update contents size
        mstore(contents, sub(size, 0x20))
        // store contents
        mstore(0x40, add(contents, and(add(size, 0x1f), not(0x1f))))
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {File, BytecodeSlice} from "./File.sol";

/// @title EthFS FileStore interface
/// @notice Specifies a content-addressable onchain file store
interface IFileStore {
    event Deployed();

    /**
     * @dev Emitted when a new file is created
     * @param indexedFilename The indexed filename for easier finding by filename in logs
     * @param pointer The pointer address of the file
     * @param filename The name of the file
     * @param size The total size of the file
     * @param metadata Additional metadata of the file, only emitted for use in offchain indexers
     */
    event FileCreated(
        string indexed indexedFilename,
        address indexed pointer,
        string filename,
        uint256 size,
        bytes metadata
    );

    /**
     * @dev Error thrown when a requested file is not found
     * @param filename The name of the file requested
     */
    error FileNotFound(string filename);

    /**
     * @dev Error thrown when a filename already exists
     * @param filename The name of the file attempted to be created
     */
    error FilenameExists(string filename);

    /**
     * @dev Error thrown when attempting to create an empty file
     */
    error FileEmpty();

    /**
     * @dev Error thrown when a provided slice for a file is empty
     * @param pointer The contract address where the bytecode lives
     * @param start The byte offset to start the slice (inclusive)
     * @param end The byte offset to end the slice (exclusive)
     */
    error SliceEmpty(address pointer, uint32 start, uint32 end);

    /**
     * @dev Error thrown when the provided pointer's bytecode does not have the expected STOP opcode prefix from SSTORE2
     * @param pointer The SSTORE2 pointer address
     */
    error InvalidPointer(address pointer);

    /**
     * @notice Returns the address of the CREATE2 deterministic deployer used by this FileStore
     * @return The address of the CREATE2 deterministic deployer
     */
    function deployer() external view returns (address);

    /**
     * @notice Retrieves the pointer address of a file by its filename
     * @param filename The name of the file
     * @return pointer The pointer address of the file
     */
    function files(
        string memory filename
    ) external view returns (address pointer);

    /**
     * @notice Checks if a file exists for a given filename
     * @param filename The name of the file to check
     * @return True if the file exists, false otherwise
     */
    function fileExists(string memory filename) external view returns (bool);

    /**
     * @notice Retrieves the pointer address for a given filename
     * @param filename The name of the file
     * @return pointer The pointer address of the file
     */
    function getPointer(
        string memory filename
    ) external view returns (address pointer);

    /**
     * @notice Retrieves a file by its filename
     * @param filename The name of the file
     * @return file The file associated with the filename
     */
    function getFile(
        string memory filename
    ) external view returns (File memory file);

    /**
     * @notice Creates a new file with the provided file contents
     * @dev This is a convenience method to simplify small file uploads. It's recommended to use `createFileFromPointers` or `createFileFromSlices` for larger files. This particular method splits `contents` into 24575-byte chunks before storing them via SSTORE2.
     * @param filename The name of the new file
     * @param contents The contents of the file
     * @return pointer The pointer address of the new file
     * @return file The newly created file
     */
    function createFile(
        string memory filename,
        string memory contents
    ) external returns (address pointer, File memory file);

    /**
     * @notice Creates a new file with the provided file contents and file metadata
     * @dev This is a convenience method to simplify small file uploads. It's recommended to use `createFileFromPointers` or `createFileFromSlices` for larger files. This particular method splits `contents` into 24575-byte chunks before storing them via SSTORE2.
     * @param filename The name of the new file
     * @param contents The contents of the file
     * @param metadata Additional file metadata, usually a JSON-encoded string, for offchain indexers
     * @return pointer The pointer address of the new file
     * @return file The newly created file
     */
    function createFile(
        string memory filename,
        string memory contents,
        bytes memory metadata
    ) external returns (address pointer, File memory file);

    /**
     * @notice Creates a new file where its content is composed of the provided string chunks
     * @dev This is a convenience method to simplify small and nuanced file uploads. It's recommended to use `createFileFromPointers` or `createFileFromSlices` for larger files. This particular will store each chunk separately via SSTORE2. For best gas efficiency, each chunk should be as large as possible (up to the contract size limit) and at least 32 bytes.
     * @param filename The name of the new file
     * @param chunks The string chunks composing the file
     * @return pointer The pointer address of the new file
     * @return file The newly created file
     */
    function createFileFromChunks(
        string memory filename,
        string[] memory chunks
    ) external returns (address pointer, File memory file);

    /**
     * @notice Creates a new file with the provided string chunks and file metadata
     * @dev This is a convenience method to simplify small and nuanced file uploads. It's recommended to use `createFileFromPointers` or `createFileFromSlices` for larger files. This particular will store each chunk separately via SSTORE2. For best gas efficiency, each chunk should be as large as possible (up to the contract size limit) and at least 32 bytes.
     * @param filename The name of the new file
     * @param chunks The string chunks composing the file
     * @param metadata Additional file metadata, usually a JSON-encoded string, for offchain indexers
     * @return pointer The pointer address of the new file
     * @return file The newly created file
     */
    function createFileFromChunks(
        string memory filename,
        string[] memory chunks,
        bytes memory metadata
    ) external returns (address pointer, File memory file);

    /**
     * @notice Creates a new file where its content is composed of the provided SSTORE2 pointers
     * @param filename The name of the new file
     * @param pointers The SSTORE2 pointers composing the file
     * @return pointer The pointer address of the new file
     * @return file The newly created file
     */
    function createFileFromPointers(
        string memory filename,
        address[] memory pointers
    ) external returns (address pointer, File memory file);

    /**
     * @notice Creates a new file with the provided SSTORE2 pointers and file metadata
     * @param filename The name of the new file
     * @param pointers The SSTORE2 pointers composing the file
     * @param metadata Additional file metadata, usually a JSON-encoded string, for offchain indexers
     * @return pointer The pointer address of the new file
     * @return file The newly created file
     */
    function createFileFromPointers(
        string memory filename,
        address[] memory pointers,
        bytes memory metadata
    ) external returns (address pointer, File memory file);

    /**
     * @notice Creates a new file where its content is composed of the provided bytecode slices
     * @param filename The name of the new file
     * @param slices The bytecode slices composing the file
     * @return pointer The pointer address of the new file
     * @return file The newly created file
     */
    function createFileFromSlices(
        string memory filename,
        BytecodeSlice[] memory slices
    ) external returns (address pointer, File memory file);

    /**
     * @notice Creates a new file with the provided bytecode slices and file metadata
     * @param filename The name of the new file
     * @param slices The bytecode slices composing the file
     * @param metadata Additional file metadata, usually a JSON-encoded string, for offchain indexers
     * @return pointer The pointer address of the new file
     * @return file The newly created file
     */
    function createFileFromSlices(
        string memory filename,
        BytecodeSlice[] memory slices,
        bytes memory metadata
    ) external returns (address pointer, File memory file);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {SSTORE2} from "solady/src/utils/SSTORE2.sol";

bytes32 constant SALT = bytes32("EthFS");

/**
 * @dev Error thrown when the pointer of the content added does not match the one we compute from the content, signaling something weird going on with the deployer
 * @param expectedPointer The expected address of the content
 * @param actualPointer The actual address of the content
 */
error UnexpectedPointer(address expectedPointer, address actualPointer);

/**
 * @dev Converts data into creation code for an SSTORE2 data contract
 * @param content The bytes content to be converted
 * @return creationCode The creation code for the data contract
 */
function contentToInitCode(
    bytes memory content
) pure returns (bytes memory creationCode) {
    // Use the same strategy as Solady's SSTORE2 to write a data contract, but do this via the deployer for a constant address
    // https://github.com/Vectorized/solady/blob/cb801a60f8319a148697b09d19b748d04e3d65c4/src/utils/SSTORE2.sol#L44-L59
    // TODO: convert this to assembly?
    return
        abi.encodePacked(
            bytes11(0x61000080600a3d393df300) |
                // Overlay content size (plus offset for STOP opcode) into second and third bytes
                bytes11(bytes3(uint24(content.length + 1))),
            content
        );
}

/**
 * @dev Predicts the address of a data contract based on its content
 * @param deployer The deployer's address
 * @param content The content of the data contract
 * @return pointer The predicted address of the data contract
 */
function getPointer(
    address deployer,
    bytes memory content
) pure returns (address pointer) {
    return SSTORE2.predictDeterministicAddress(content, SALT, deployer);
}

/**
 * @dev Checks if a pointer (data contract address) already exists
 * @param pointer The data contract address to check
 * @return true if the data contract exists, false otherwise
 */
function pointerExists(address pointer) view returns (bool) {
    return pointer.code.length > 0;
}

/**
 * @dev Adds content as a data contract using a deterministic deployer
 * @param deployer The deployer's address
 * @param content The content to be added as a data contract
 * @return pointer The address of the data contract
 */
function addContent(
    address deployer,
    bytes memory content
) returns (address pointer) {
    address expectedPointer = getPointer(deployer, content);
    if (pointerExists(expectedPointer)) {
        return expectedPointer;
    }

    (bool success, bytes memory data) = deployer.call(
        abi.encodePacked(SALT, contentToInitCode(content))
    );
    if (!success) revertWithBytes(data);

    pointer = address(uint160(bytes20(data)));
    if (pointer != expectedPointer) {
        revert UnexpectedPointer(expectedPointer, pointer);
    }
}

/**
 * @notice Reverts the transaction using the provided raw bytes as the revert reason
 * @dev Uses assembly to perform the revert operation with the raw bytes
 * @param reason The raw bytes revert reason
 */
function revertWithBytes(bytes memory reason) pure {
    assembly {
        // reason+32 is a pointer to the error message, mload(reason) is the length of the error message
        revert(add(reason, 0x20), mload(reason))
    }
}

/**
 * @dev Checks if the given address points to a valid SSTORE2 data contract (i.e. starts with STOP opcode)
 * @param pointer The address to be checked
 * @return isValid true if the address points to a valid contract (bytecode starts with a STOP opcode), false otherwise
 */
function isValidPointer(address pointer) view returns (bool isValid) {
    // The assembly below is equivalent to
    //
    //   pointer.code.length >= 1 && pointer.code[0] == 0x00;
    //
    // but less gas because it doesn't have to load all the pointer's bytecode

    assembly {
        // Get the size of the bytecode at pointer
        let size := extcodesize(pointer)

        // Initialize first byte with INVALID opcode
        let firstByte := 0xfe

        // If there's at least one byte of code, copy the first byte
        if gt(size, 0) {
            // Allocate memory for the first byte
            let code := mload(0x40)

            // Copy the first byte of the code
            extcodecopy(pointer, code, 0, 1)

            // Retrieve the first byte, ensuring it's a single byte
            firstByte := and(mload(sub(code, 31)), 0xff)
        }

        // Check if the first byte is 0x00 (STOP opcode)
        isValid := eq(firstByte, 0x00)
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

///////////////////////////////////////////////////////////
// ░██████╗░█████╗░██████╗░██╗██████╗░████████╗██╗░░░██╗ //
// ██╔════╝██╔══██╗██╔══██╗██║██╔══██╗╚══██╔══╝╚██╗░██╔╝ //
// ╚█████╗░██║░░╚═╝██████╔╝██║██████╔╝░░░██║░░░░╚████╔╝░ //
// ░╚═══██╗██║░░██╗██╔══██╗██║██╔═══╝░░░░██║░░░░░╚██╔╝░░ //
// ██████╔╝╚█████╔╝██║░░██║██║██║░░░░░░░░██║░░░░░░██║░░░ //
// ╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝╚═╝░░░░░░░░╚═╝░░░░░░╚═╝░░░ //
///////////////////////////////////////////////////////////

interface IScriptyContractStorage {
    // =============================================================
    //                            GETTERS
    // =============================================================

    /**
     * @notice Get the full content
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param data - Arbitrary data to be passed to storage
     * @return script - Full script from merged chunks
     */
    function getContent(string calldata name, bytes memory data)
        external
        view
        returns (bytes memory script);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

///////////////////////////////////////////////////////////
// ░██████╗░█████╗░██████╗░██╗██████╗░████████╗██╗░░░██╗ //
// ██╔════╝██╔══██╗██╔══██╗██║██╔══██╗╚══██╔══╝╚██╗░██╔╝ //
// ╚█████╗░██║░░╚═╝██████╔╝██║██████╔╝░░░██║░░░░╚████╔╝░ //
// ░╚═══██╗██║░░██╗██╔══██╗██║██╔═══╝░░░░██║░░░░░╚██╔╝░░ //
// ██████╔╝╚█████╔╝██║░░██║██║██║░░░░░░░░██║░░░░░░██║░░░ //
// ╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝╚═╝░░░░░░░░╚═╝░░░░░░╚═╝░░░ //
///////////////////////////////////////////////////////////

interface IScriptyStorage {
    // =============================================================
    //                            STRUCTS
    // =============================================================

    struct Content {
        bool isFrozen;
        address owner;
        uint256 size;
        bytes details;
        address[] chunks;
    }

    // =============================================================
    //                            ERRORS
    // =============================================================

    /**
     * @notice Error for, The content you are trying to create already exists
     */
    error ContentExists();

    /**
     * @notice Error for, You dont have permissions to perform this action
     */
    error NotContentOwner();

    /**
     * @notice Error for, The content you are trying to edit is frozen
     */
    error ContentIsFrozen(string name);

    // =============================================================
    //                            EVENTS
    // =============================================================

    /**
     * @notice Event for, Successful freezing of a content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     */
    event ContentFrozen(string indexed name);

    /**
     * @notice Event for, Successful creation of a content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param details - Custom details of the content
     */
    event ContentCreated(string indexed name, bytes details);

    /**
     * @notice Event for, Successful addition of content chunk
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param size - Bytes size of the chunk
     */
    event ChunkStored(string indexed name, uint256 size);

    /**
     * @notice Event for, Successful update of custom details
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param details - Custom details of the content
     */
    event ContentDetailsUpdated(string indexed name, bytes details);

    /**
     * @notice Event for, submitting content to EthFS FileStore
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param fileName - Name given to the file in File Store.
     */
    event ContentSubmittedToEthFSFileStore(string indexed name, string indexed fileName);

    // =============================================================
    //                      MANAGEMENT OPERATIONS
    // =============================================================

    /**
     * @notice Create a new content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param details - Any details the owner wishes to store about the content
     *
     * Emits an {ContentCreated} event.
     */
    function createContent(
        string calldata name,
        bytes calldata details
    ) external;

    /**
     * @notice Add a content chunk to the content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param chunk - Next sequential content chunk
     *
     * Emits an {ChunkStored} event.
     */
    function addChunkToContent(
        string calldata name,
        bytes calldata chunk
    ) external;

    /**
     * @notice Submit content to EthFS V2 FileStore
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param metadata - metadata for EthFS V2 File
     *
     * Uses name as file name.
     * Emits an {ContentSubmittedToFileStore} event.
     */
    function submitToEthFSFileStore(
        string calldata name,
        bytes memory metadata
    ) external;

    /**
     * @notice Submit content to EthFS V2 FileStore
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param fileName - Name given to the File in FileStore
     * @param metadata - metadata for EthFS V2 File
     *
     * Emits an {ContentSubmittedToFileStore} event.
     */
    function submitToEthFSFileStoreWithFileName(
        string calldata name,
        string calldata fileName,
        bytes memory metadata
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/**
 * @title AddressChunks
 * @author @xtremetom
 * @notice Reads chunk pointers and merges their values
 */
library AddressChunks {
    function mergeChunks(address[] memory chunks)
        internal
        view
        returns (bytes memory o_code)
    {
        unchecked {
            assembly {
                let len := mload(chunks)
                let totalSize := 0x20
                let size := 0
                o_code := mload(0x40)

                // loop through all chunk addresses
                // - get address
                // - get data size
                // - get code and add to o_code
                // - update total size
                let targetChunk := 0
                for {
                    let i := 0
                } lt(i, len) {
                    i := add(i, 1)
                } {
                    targetChunk := mload(add(chunks, add(0x20, mul(i, 0x20))))
                    size := sub(extcodesize(targetChunk), 1)
                    extcodecopy(targetChunk, add(o_code, totalSize), 1, size)
                    totalSize := add(totalSize, size)
                }

                // update o_code size
                mstore(o_code, sub(totalSize, 0x20))
                // store o_code
                mstore(0x40, add(o_code, and(add(totalSize, 0x1f), not(0x1f))))
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Read and write to persistent storage at a fraction of the cost.
/// @author Solady (https://github.com/vectorized/solmady/blob/main/src/utils/SSTORE2.sol)
/// @author Saw-mon-and-Natalie (https://github.com/Saw-mon-and-Natalie)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SSTORE2.sol)
/// @author Modified from 0xSequence (https://github.com/0xSequence/sstore2/blob/master/contracts/SSTORE2.sol)
library SSTORE2 {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev We skip the first byte as it's a STOP opcode,
    /// which ensures the contract can't be called.
    uint256 internal constant DATA_OFFSET = 1;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Unable to deploy the storage contract.
    error DeploymentFailed();

    /// @dev The storage contract address is invalid.
    error InvalidPointer();

    /// @dev Attempt to read outside of the storage contract's bytecode bounds.
    error ReadOutOfBounds();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         WRITE LOGIC                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Writes `data` into the bytecode of a storage contract and returns its address.
    function write(bytes memory data) internal returns (address pointer) {
        /// @solidity memory-safe-assembly
        assembly {
            let originalDataLength := mload(data)

            // Add 1 to data size since we are prefixing it with a STOP opcode.
            let dataSize := add(originalDataLength, DATA_OFFSET)

            /**
             * ------------------------------------------------------------------------------+
             * Opcode      | Mnemonic        | Stack                   | Memory              |
             * ------------------------------------------------------------------------------|
             * 61 dataSize | PUSH2 dataSize  | dataSize                |                     |
             * 80          | DUP1            | dataSize dataSize       |                     |
             * 60 0xa      | PUSH1 0xa       | 0xa dataSize dataSize   |                     |
             * 3D          | RETURNDATASIZE  | 0 0xa dataSize dataSize |                     |
             * 39          | CODECOPY        | dataSize                | [0..dataSize): code |
             * 3D          | RETURNDATASIZE  | 0 dataSize              | [0..dataSize): code |
             * F3          | RETURN          |                         | [0..dataSize): code |
             * 00          | STOP            |                         |                     |
             * ------------------------------------------------------------------------------+
             * @dev Prefix the bytecode with a STOP opcode to ensure it cannot be called.
             * Also PUSH2 is used since max contract size cap is 24,576 bytes which is less than 2 ** 16.
             */
            mstore(
                // Do a out-of-gas revert if `dataSize` is more than 2 bytes.
                // The actual EVM limit may be smaller and may change over time.
                add(data, gt(dataSize, 0xffff)),
                // Left shift `dataSize` by 64 so that it lines up with the 0000 after PUSH2.
                or(0xfd61000080600a3d393df300, shl(0x40, dataSize))
            )

            // Deploy a new contract with the generated creation code.
            pointer := create(0, add(data, 0x15), add(dataSize, 0xa))

            // If `pointer` is zero, revert.
            if iszero(pointer) {
                // Store the function selector of `DeploymentFailed()`.
                mstore(0x00, 0x30116425)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Restore original length of the variable size `data`.
            mstore(data, originalDataLength)
        }
    }

    /// @dev Writes `data` into the bytecode of a storage contract with `salt`
    /// and returns its deterministic address.
    function writeDeterministic(bytes memory data, bytes32 salt)
        internal
        returns (address pointer)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let originalDataLength := mload(data)
            let dataSize := add(originalDataLength, DATA_OFFSET)

            mstore(
                // Do a out-of-gas revert if `dataSize` is more than 2 bytes.
                // The actual EVM limit may be smaller and may change over time.
                add(data, gt(dataSize, 0xffff)),
                // Left shift `dataSize` by 64 so that it lines up with the 0000 after PUSH2.
                or(0xfd61000080600a3d393df300, shl(0x40, dataSize))
            )

            // Deploy a new contract with the generated creation code.
            pointer := create2(0, add(data, 0x15), add(dataSize, 0xa), salt)

            // If `pointer` is zero, revert.
            if iszero(pointer) {
                // Store the function selector of `DeploymentFailed()`.
                mstore(0x00, 0x30116425)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Restore original length of the variable size `data`.
            mstore(data, originalDataLength)
        }
    }

    /// @dev Returns the initialization code hash of the storage contract for `data`.
    /// Used for mining vanity addresses with create2crunch.
    function initCodeHash(bytes memory data) internal pure returns (bytes32 hash) {
        /// @solidity memory-safe-assembly
        assembly {
            let originalDataLength := mload(data)
            let dataSize := add(originalDataLength, DATA_OFFSET)

            // Do a out-of-gas revert if `dataSize` is more than 2 bytes.
            // The actual EVM limit may be smaller and may change over time.
            returndatacopy(returndatasize(), returndatasize(), shr(16, dataSize))

            mstore(data, or(0x61000080600a3d393df300, shl(0x40, dataSize)))

            hash := keccak256(add(data, 0x15), add(dataSize, 0xa))

            // Restore original length of the variable size `data`.
            mstore(data, originalDataLength)
        }
    }

    /// @dev Returns the address of the storage contract for `data`
    /// deployed with `salt` by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddress(bytes memory data, bytes32 salt, address deployer)
        internal
        pure
        returns (address predicted)
    {
        bytes32 hash = initCodeHash(data);
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and store the bytecode hash.
            mstore8(0x00, 0xff) // Write the prefix.
            mstore(0x35, hash)
            mstore(0x01, shl(96, deployer))
            mstore(0x15, salt)
            predicted := keccak256(0x00, 0x55)
            // Restore the part of the free memory pointer that has been overwritten.
            mstore(0x35, 0)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         READ LOGIC                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns all the `data` from the bytecode of the storage contract at `pointer`.
    function read(address pointer) internal view returns (bytes memory data) {
        /// @solidity memory-safe-assembly
        assembly {
            let pointerCodesize := extcodesize(pointer)
            if iszero(pointerCodesize) {
                // Store the function selector of `InvalidPointer()`.
                mstore(0x00, 0x11052bb4)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Offset all indices by 1 to skip the STOP opcode.
            let size := sub(pointerCodesize, DATA_OFFSET)

            // Get the pointer to the free memory and allocate
            // enough 32-byte words for the data and the length of the data,
            // then copy the code to the allocated memory.
            // Masking with 0xffe0 will suffice, since contract size is less than 16 bits.
            data := mload(0x40)
            mstore(0x40, add(data, and(add(size, 0x3f), 0xffe0)))
            mstore(data, size)
            mstore(add(add(data, 0x20), size), 0) // Zeroize the last slot.
            extcodecopy(pointer, add(data, 0x20), DATA_OFFSET, size)
        }
    }

    /// @dev Returns the `data` from the bytecode of the storage contract at `pointer`,
    /// from the byte at `start`, to the end of the data stored.
    function read(address pointer, uint256 start) internal view returns (bytes memory data) {
        /// @solidity memory-safe-assembly
        assembly {
            let pointerCodesize := extcodesize(pointer)
            if iszero(pointerCodesize) {
                // Store the function selector of `InvalidPointer()`.
                mstore(0x00, 0x11052bb4)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // If `!(pointer.code.size > start)`, reverts.
            // This also handles the case where `start + DATA_OFFSET` overflows.
            if iszero(gt(pointerCodesize, start)) {
                // Store the function selector of `ReadOutOfBounds()`.
                mstore(0x00, 0x84eb0dd1)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            let size := sub(pointerCodesize, add(start, DATA_OFFSET))

            // Get the pointer to the free memory and allocate
            // enough 32-byte words for the data and the length of the data,
            // then copy the code to the allocated memory.
            // Masking with 0xffe0 will suffice, since contract size is less than 16 bits.
            data := mload(0x40)
            mstore(0x40, add(data, and(add(size, 0x3f), 0xffe0)))
            mstore(data, size)
            mstore(add(add(data, 0x20), size), 0) // Zeroize the last slot.
            extcodecopy(pointer, add(data, 0x20), add(start, DATA_OFFSET), size)
        }
    }

    /// @dev Returns the `data` from the bytecode of the storage contract at `pointer`,
    /// from the byte at `start`, to the byte at `end` (exclusive) of the data stored.
    function read(address pointer, uint256 start, uint256 end)
        internal
        view
        returns (bytes memory data)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let pointerCodesize := extcodesize(pointer)
            if iszero(pointerCodesize) {
                // Store the function selector of `InvalidPointer()`.
                mstore(0x00, 0x11052bb4)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // If `!(pointer.code.size > end) || (start > end)`, revert.
            // This also handles the cases where
            // `end + DATA_OFFSET` or `start + DATA_OFFSET` overflows.
            if iszero(
                and(
                    gt(pointerCodesize, end), // Within bounds.
                    iszero(gt(start, end)) // Valid range.
                )
            ) {
                // Store the function selector of `ReadOutOfBounds()`.
                mstore(0x00, 0x84eb0dd1)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            let size := sub(end, start)

            // Get the pointer to the free memory and allocate
            // enough 32-byte words for the data and the length of the data,
            // then copy the code to the allocated memory.
            // Masking with 0xffe0 will suffice, since contract size is less than 16 bits.
            data := mload(0x40)
            mstore(0x40, add(data, and(add(size, 0x3f), 0xffe0)))
            mstore(data, size)
            mstore(add(add(data, 0x20), size), 0) // Zeroize the last slot.
            extcodecopy(pointer, add(data, 0x20), add(start, DATA_OFFSET), size)
        }
    }
}