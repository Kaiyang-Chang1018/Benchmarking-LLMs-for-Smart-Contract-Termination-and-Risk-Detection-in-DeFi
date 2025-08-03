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
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Base64.sol";

library art {
    function uint2str(
        uint _i
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function metadata(uint tokenId) internal pure returns (string memory) {
        string memory image ='data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNjQiIGhlaWdodD0iMjY0IiBmaWxsPSJub25lIj48cGF0aCBmaWxsPSIjRUJFQkVCIiBkPSJNMCAwaDI2NHYyNjRIMHoiLz48cGF0aCBmaWxsPSIjZmZmIiBkPSJNNjQgNDhoMTM2djE2OEg2NHoiLz48cGF0aCBmaWxsPSIjRjVCNDM0IiBkPSJNODkgODYuMjE0M1Y4Ny43NWgxMC43NXYtNC42MDcyaC0xLjUzNTd2LTEuNTM1N2gtMS41MzU3di0xLjUzNTdoLTEuNTM1N3YxLjUzNTdoLTEuNTM1OHYxLjUzNTdoLTEuNTM1N3YxLjUzNThoLTEuNTM1N3YxLjUzNTdIODlaIi8+PHBhdGggZmlsbD0iI0I5NTMwOSIgZD0iTTk1LjE0MjkgODAuMDcxNHYtMS41MzU3aDMuMDcxNHYxLjUzNTdIOTkuNzV2MS41MzU3aDEuNTM2Vjg3Ljc1SDk5Ljc1di00LjYwNzJoLTEuNTM1N3YtMS41MzU3aC0xLjUzNTd2LTEuNTM1N2gtMS41MzU3WiIvPjxwYXRoIGZpbGw9IiNFOTIxMjEiIGQ9Ik05MC41MzU3IDg2LjIxNDNoMS41MzU3Vjg3Ljc1aC0xLjUzNTd2LTEuNTM1N1oiLz48cGF0aCBmaWxsPSIjRTNBMTIwIiBkPSJNOTUuMTQyOSA4Ni4yMTQzSDk5Ljc1Vjg3Ljc1aC00LjYwNzF2LTEuNTM1N1oiLz48cGF0aCBmaWxsPSIjQjk1MzA5IiBkPSJNOTkuNzUgODMuMTQyOGgxLjUzNnYxLjUzNThIOTkuNzV2LTEuNTM1OFoiLz48cGF0aCBmaWxsPSIjRTkyMTIxIiBkPSJNOTMuNjA3MSA4My4xNDI4aDEuNTM1OHYxLjUzNThoLTEuNTM1OHYtMS41MzU4Wm0zLjA3MTUgMS41MzU4aDEuNTM1N3YxLjUzNTdoLTEuNTM1N3YtMS41MzU3WiIvPjxwYXRoIGZpbGw9IiNENUY2RjQiIGQ9Ik05OS43NSAxMTAuNzg2di0zLjA3MmgtOS4yMTQzdjMuMDcyaDEuNTM1N3YxLjUzNWg2LjE0Mjl2LTEuNTM1SDk5Ljc1WiIvPjxwYXRoIGZpbGw9IiM3MEFDMjQiIGQ9Ik05Mi4wNzE0IDEwNy43MTRoNi4xNDI5djEuNTM2aC02LjE0Mjl2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiM1NTgzMUIiIGQ9Ik05My42MDcxIDEwOS4yNWgzLjA3MTV2MS41MzZoLTMuMDcxNXYtMS41MzZaIi8+PHBhdGggZmlsbD0iI0Y1QjQzNCIgZD0iTTk2LjY3ODYgMTA2LjE3OWgxLjUzNTd2MS41MzVoLTEuNTM1N3YtMS41MzVabS0xLjUzNTcgMGgxLjUzNTd2MS41MzVoLTEuNTM1N3YtMS41MzVabTAtMS41MzZoMS41MzU3djEuNTM2aC0xLjUzNTd2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNCOTUzMDkiIGQ9Ik05Mi4wNzE0IDEzMi4yODZ2My4wNzFoNC42MDcydi0xLjUzNmgxLjUzNTd2LTEuNTM1SDk5Ljc1di00LjYwOGgtMS41MzU3di0xLjUzNWgtMS41MzU3djEuNTM1aC0xLjUzNTd2MS41MzZoLTEuNTM1OHYzLjA3MmgtMS41MzU3WiIvPjxwYXRoIGZpbGw9IiNFOUNEQjkiIGQ9Ik05MC41MzU3IDEzNS4zNTdoMS41MzU3djEuNTM2aC0xLjUzNTd2LTEuNTM2Wm0xLjUzNTctMS41MzZoMS41MzU3djEuNTM2aC0xLjUzNTd2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiM5QzQ2MDciIGQ9Ik05My42MDcxIDEzMy44MjFoMy4wNzE1djEuNTM2aC0zLjA3MTV2LTEuNTM2Wm0zLjA3MTUtMS41MzVoMS41MzU3djEuNTM1aC0xLjUzNTd2LTEuNTM1WiIvPjxwYXRoIGZpbGw9IiNFQ0IyN0QiIGQ9Ik05MC41MzU3IDE1My43ODZWMTYzSDk5Ljc1di05LjIxNGgtMS41MzU3di0xLjUzNmgtNi4xNDI5djEuNTM2aC0xLjUzNTdaIi8+PHBhdGggZmlsbD0iIzVFMzAwRSIgZD0iTTkwLjUzNTcgMTU4LjM5M0g5OS43NXYxLjUzNWgtOS4yMTQzdi0xLjUzNVoiLz48cGF0aCBmaWxsPSIjNEIyNjBDIiBkPSJNOTAuNTM1NyAxNTkuOTI4SDk5Ljc1djEuNTM2aC05LjIxNDN2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNFOTIxMjEiIGQ9Ik05MC41MzU3IDE1NS4zMjFIOTkuNzV2MS41MzZoLTkuMjE0M3YtMS41MzZaIi8+PHBhdGggZmlsbD0iIzcwQUMyNCIgZD0iTTkwLjUzNTcgMTU2Ljg1N0g5OS43NXYxLjUzNmgtOS4yMTQzdi0xLjUzNloiLz48cGF0aCBmaWxsPSIjRjVCNDM0IiBkPSJNODkgMTgxLjQyOHYzLjA3MmgxMi4yODZ2LTMuMDcySDk5Ljc1di0xLjUzNWgtMS41MzU3di0xLjUzNmgtNi4xNDI5djEuNTM2aC0xLjUzNTd2MS41MzVIODlaIi8+PHBhdGggZmlsbD0iI0UzQTEyMCIgZD0iTTg5IDE4Mi45NjRoMTIuMjg2djEuNTM2SDg5di0xLjUzNloiLz48cGF0aCBmaWxsPSIjRTkyMTIxIiBkPSJNOTYuNjc4NiAxNzguMzU3aDEuNTM1N3YxLjUzNmgtMS41MzU3di0xLjUzNloiLz48cGF0aCBmaWxsPSIjNzBBQzI0IiBkPSJNOTIuMDcxNCAxNzguMzU3aDEuNTM1N3YxLjUzNmgtMS41MzU3di0xLjUzNloiLz48cGF0aCBmaWxsPSIjRTkyMTIxIiBkPSJNOTMuNjA3MSAxNzguMzU3aDEuNTM1OHYxLjUzNmgtMS41MzU4di0xLjUzNloiLz48cGF0aCBmaWxsPSIjNzBBQzI0IiBkPSJNOTUuMTQyOSAxNzguMzU3aDEuNTM1N3YxLjUzNmgtMS41MzU3di0xLjUzNloiLz48cGF0aCBmaWxsPSIjQjk1MzA5IiBkPSJNMTE2LjY0MyA4My4xNDI4djMuMDcxNWg0LjYwN3YtMS41MzU3aDEuNTM2di0xLjUzNThoMS41MzV2LTQuNjA3MWgtMS41MzVWNzdoLTEuNTM2djEuNTM1N2gtMS41MzZ2MS41MzU3aC0xLjUzNXYzLjA3MTRoLTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNFOUNEQjkiIGQ9Ik0xMTUuMTA3IDg2LjIxNDNoMS41MzZWODcuNzVoLTEuNTM2di0xLjUzNTdabTEuNTM2LTEuNTM1N2gxLjUzNnYxLjUzNTdoLTEuNTM2di0xLjUzNTdaIi8+PHBhdGggZmlsbD0iIzlDNDYwNyIgZD0iTTExOC4xNzkgODQuNjc4NmgzLjA3MXYxLjUzNTdoLTMuMDcxdi0xLjUzNTdabTMuMDcxLTEuNTM1OGgxLjUzNnYxLjUzNThoLTEuNTM2di0xLjUzNThaIi8+PHBhdGggZmlsbD0iI0VDQjI3RCIgZD0iTTExNS4xMDcgMTA0LjY0M3Y5LjIxNGg5LjIxNHYtOS4yMTRoLTEuNTM1di0xLjUzNmgtNi4xNDN2MS41MzZoLTEuNTM2WiIvPjxwYXRoIGZpbGw9IiM1RTMwMEUiIGQ9Ik0xMTUuMTA3IDEwOS4yNWg5LjIxNHYxLjUzNmgtOS4yMTR2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiM0QjI2MEMiIGQ9Ik0xMTUuMTA3IDExMC43ODZoOS4yMTR2MS41MzVoLTkuMjE0di0xLjUzNVoiLz48cGF0aCBmaWxsPSIjRTkyMTIxIiBkPSJNMTE1LjEwNyAxMDYuMTc5aDkuMjE0djEuNTM1aC05LjIxNHYtMS41MzVaIi8+PHBhdGggZmlsbD0iIzcwQUMyNCIgZD0iTTExNS4xMDcgMTA3LjcxNGg5LjIxNHYxLjUzNmgtOS4yMTR2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNGNUI0MzQiIGQ9Ik0xMTMuNTcxIDEzMi4yODZ2My4wNzFoMTIuMjg2di0zLjA3MWgtMS41MzZ2LTEuNTM2aC0xLjUzNXYtMS41MzZoLTYuMTQzdjEuNTM2aC0xLjUzNnYxLjUzNmgtMS41MzZaIi8+PHBhdGggZmlsbD0iI0UzQTEyMCIgZD0iTTExMy41NzEgMTMzLjgyMWgxMi4yODZ2MS41MzZoLTEyLjI4NnYtMS41MzZaIi8+PHBhdGggZmlsbD0iI0U5MjEyMSIgZD0iTTEyMS4yNSAxMjkuMjE0aDEuNTM2djEuNTM2aC0xLjUzNnYtMS41MzZaIi8+PHBhdGggZmlsbD0iIzcwQUMyNCIgZD0iTTExNi42NDMgMTI5LjIxNGgxLjUzNnYxLjUzNmgtMS41MzZ2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNFOTIxMjEiIGQ9Ik0xMTguMTc5IDEyOS4yMTRoMS41MzV2MS41MzZoLTEuNTM1di0xLjUzNloiLz48cGF0aCBmaWxsPSIjNzBBQzI0IiBkPSJNMTE5LjcxNCAxMjkuMjE0aDEuNTM2djEuNTM2aC0xLjUzNnYtMS41MzZaIi8+PHBhdGggZmlsbD0iI0VDQjI3RCIgZD0iTTExNS4xMDcgMTUzLjc4Nmg5LjIxNHY2LjE0MmgtOS4yMTR2LTYuMTQyWiIvPjxwYXRoIGZpbGw9IiNFOTY3NkYiIGQ9Ik0xMTMuNTcxIDE1NS4zMjFoMS41MzZ2My4wNzJoLTEuNTM2di0zLjA3MloiLz48cGF0aCBmaWxsPSIjRTkyMTIxIiBkPSJNMTE1LjEwNyAxNTUuMzIxaDkuMjE0djEuNTM2aC05LjIxNHYtMS41MzZaIi8+PHBhdGggZmlsbD0iI0Y1QjQzNCIgZD0iTTExNS4xMDcgMTU2Ljg1N2g5LjIxNHYxLjUzNmgtOS4yMTR2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNFOTY3NkYiIGQ9Ik0xMjQuMzIxIDE1NS4zMjFoMS41MzZ2My4wNzJoLTEuNTM2di0zLjA3MloiLz48cGF0aCBmaWxsPSIjRjVBODM0IiBkPSJNMTI0LjMyMSAxNzYuODIxaC0xLjUzNXYxLjUzNmgtMS41MzZ2MS41MzZoLTEuNTM2djEuNTM1aC0xLjUzNXYxLjUzNmgtMS41MzZ2MS41MzZoLTEuNTM2djEuNTM2aDkuMjE0di05LjIxNVoiLz48cGF0aCBmaWxsPSIjRjU5MTM0IiBkPSJNMTE1LjEwNyAxODQuNWgxLjUzNnYxLjUzNmgtMS41MzZWMTg0LjVaIi8+PHBhdGggZmlsbD0iI0UyOTUyMSIgZD0iTTExNi42NDMgMTg0LjVoMS41MzZ2MS41MzZoLTEuNTM2VjE4NC41WiIvPjxwYXRoIGZpbGw9IiNGNTkxMzQiIGQ9Ik0xMjEuMjUgMTg0LjVoMS41MzZ2MS41MzZoLTEuNTM2VjE4NC41WiIvPjxwYXRoIGZpbGw9IiNFMjk1MjEiIGQ9Ik0xMjIuNzg2IDE4NC41aDEuNTM1djEuNTM2aC0xLjUzNVYxODQuNVoiLz48cGF0aCBmaWxsPSIjRjU5MTM0IiBkPSJNMTIyLjc4NiAxNzguMzU3aDEuNTM1djEuNTM2aC0xLjUzNXYtMS41MzZaIi8+PHBhdGggZmlsbD0iI0UyOTUyMSIgZD0iTTEyMS4yNSAxNzguMzU3aDEuNTM2djEuNTM2aC0xLjUzNnYtMS41MzZaIi8+PHBhdGggZmlsbD0iI0Y1OTEzNCIgZD0iTTEyMS4yNSAxNzkuODkzaDEuNTM2djEuNTM1aC0xLjUzNnYtMS41MzVaIi8+PHBhdGggZmlsbD0iI0UyOTUyMSIgZD0iTTExOS43MTQgMTgyLjk2NGgxLjUzNnYxLjUzNmgtMS41MzZ2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNGNTkxMzQiIGQ9Ik0xMTguMTc5IDE4MS40MjhoMS41MzV2MS41MzZoLTEuNTM1di0xLjUzNloiLz48cGF0aCBmaWxsPSIjRjVCNDM0IiBkPSJNMTM4LjE0MyA4My4xNDI4djMuMDcxNWgxMi4yODZ2LTMuMDcxNWgtMS41MzZ2LTEuNTM1N2gtMS41MzZ2LTEuNTM1N2gtNi4xNDN2MS41MzU3aC0xLjUzNXYxLjUzNTdoLTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNFM0ExMjAiIGQ9Ik0xMzguMTQzIDg0LjY3ODZoMTIuMjg2djEuNTM1N2gtMTIuMjg2di0xLjUzNTdaIi8+PHBhdGggZmlsbD0iI0U5MjEyMSIgZD0iTTE0NS44MjEgODAuMDcxNGgxLjUzNnYxLjUzNTdoLTEuNTM2di0xLjUzNTdaIi8+PHBhdGggZmlsbD0iIzcwQUMyNCIgZD0iTTE0MS4yMTQgODAuMDcxNGgxLjUzNnYxLjUzNTdoLTEuNTM2di0xLjUzNTdaIi8+PHBhdGggZmlsbD0iI0U5MjEyMSIgZD0iTTE0Mi43NSA4MC4wNzE0aDEuNTM2djEuNTM1N2gtMS41MzZ2LTEuNTM1N1oiLz48cGF0aCBmaWxsPSIjNzBBQzI0IiBkPSJNMTQ0LjI4NiA4MC4wNzE0aDEuNTM1djEuNTM1N2gtMS41MzV2LTEuNTM1N1oiLz48cGF0aCBmaWxsPSIjRUNCMjdEIiBkPSJNMTM5LjY3OSAxMDQuNjQzaDkuMjE0djYuMTQzaC05LjIxNHYtNi4xNDNaIi8+PHBhdGggZmlsbD0iI0U5Njc2RiIgZD0iTTEzOC4xNDMgMTA2LjE3OWgxLjUzNnYzLjA3MWgtMS41MzZ2LTMuMDcxWiIvPjxwYXRoIGZpbGw9IiNFOTIxMjEiIGQ9Ik0xMzkuNjc5IDEwNi4xNzloOS4yMTR2MS41MzVoLTkuMjE0di0xLjUzNVoiLz48cGF0aCBmaWxsPSIjRjVCNDM0IiBkPSJNMTM5LjY3OSAxMDcuNzE0aDkuMjE0djEuNTM2aC05LjIxNHYtMS41MzZaIi8+PHBhdGggZmlsbD0iI0U5Njc2RiIgZD0iTTE0OC44OTMgMTA2LjE3OWgxLjUzNnYzLjA3MWgtMS41MzZ2LTMuMDcxWiIvPjxwYXRoIGZpbGw9IiNGNUE4MzQiIGQ9Ik0xNDguODkzIDEyNy42NzhoLTEuNTM2djEuNTM2aC0xLjUzNnYxLjUzNmgtMS41MzV2MS41MzZoLTEuNTM2djEuNTM1aC0xLjUzNnYxLjUzNmgtMS41MzV2MS41MzZoOS4yMTR2LTkuMjE1WiIvPjxwYXRoIGZpbGw9IiNGNTkxMzQiIGQ9Ik0xMzkuNjc5IDEzNS4zNTdoMS41MzV2MS41MzZoLTEuNTM1di0xLjUzNloiLz48cGF0aCBmaWxsPSIjRTI5NTIxIiBkPSJNMTQxLjIxNCAxMzUuMzU3aDEuNTM2djEuNTM2aC0xLjUzNnYtMS41MzZaIi8+PHBhdGggZmlsbD0iI0Y1OTEzNCIgZD0iTTE0NS44MjEgMTM1LjM1N2gxLjUzNnYxLjUzNmgtMS41MzZ2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNFMjk1MjEiIGQ9Ik0xNDcuMzU3IDEzNS4zNTdoMS41MzZ2MS41MzZoLTEuNTM2di0xLjUzNloiLz48cGF0aCBmaWxsPSIjRjU5MTM0IiBkPSJNMTQ3LjM1NyAxMjkuMjE0aDEuNTM2djEuNTM2aC0xLjUzNnYtMS41MzZaIi8+PHBhdGggZmlsbD0iI0UyOTUyMSIgZD0iTTE0NS44MjEgMTI5LjIxNGgxLjUzNnYxLjUzNmgtMS41MzZ2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNGNTkxMzQiIGQ9Ik0xNDUuODIxIDEzMC43NWgxLjUzNnYxLjUzNmgtMS41MzZ2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNFMjk1MjEiIGQ9Ik0xNDQuMjg2IDEzMy44MjFoMS41MzV2MS41MzZoLTEuNTM1di0xLjUzNloiLz48cGF0aCBmaWxsPSIjRjU5MTM0IiBkPSJNMTQyLjc1IDEzMi4yODZoMS41MzZ2MS41MzVoLTEuNTM2di0xLjUzNVoiLz48cGF0aCBmaWxsPSIjRjVCNDM0IiBkPSJNMTM4LjE0MyAxNTkuOTI4djEuNTM2aDEwLjc1di00LjYwN2gtMS41MzZ2LTEuNTM2aC0xLjUzNnYtMS41MzVoLTEuNTM1djEuNTM1aC0xLjUzNnYxLjUzNmgtMS41MzZ2MS41MzZoLTEuNTM1djEuNTM1aC0xLjUzNloiLz48cGF0aCBmaWxsPSIjQjk1MzA5IiBkPSJNMTQ0LjI4NiAxNTMuNzg2di0xLjUzNmgzLjA3MXYxLjUzNmgxLjUzNnYxLjUzNWgxLjUzNnY2LjE0M2gtMS41MzZ2LTQuNjA3aC0xLjUzNnYtMS41MzZoLTEuNTM2di0xLjUzNWgtMS41MzVaIi8+PHBhdGggZmlsbD0iI0U5MjEyMSIgZD0iTTEzOS42NzkgMTU5LjkyOGgxLjUzNXYxLjUzNmgtMS41MzV2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNFM0ExMjAiIGQ9Ik0xNDQuMjg2IDE1OS45MjhoNC42MDd2MS41MzZoLTQuNjA3di0xLjUzNloiLz48cGF0aCBmaWxsPSIjQjk1MzA5IiBkPSJNMTQ4Ljg5MyAxNTYuODU3aDEuNTM2djEuNTM2aC0xLjUzNnYtMS41MzZaIi8+PHBhdGggZmlsbD0iI0U5MjEyMSIgZD0iTTE0Mi43NSAxNTYuODU3aDEuNTM2djEuNTM2aC0xLjUzNnYtMS41MzZabTMuMDcxIDEuNTM2aDEuNTM2djEuNTM1aC0xLjUzNnYtMS41MzVaIi8+PHBhdGggZmlsbD0iI0Q1RjZGNCIgZD0iTTE0OC44OTMgMTg0LjV2LTMuMDcyaC05LjIxNHYzLjA3MmgxLjUzNXYxLjUzNmg2LjE0M1YxODQuNWgxLjUzNloiLz48cGF0aCBmaWxsPSIjNzBBQzI0IiBkPSJNMTQxLjIxNCAxODEuNDI4aDYuMTQzdjEuNTM2aC02LjE0M3YtMS41MzZaIi8+PHBhdGggZmlsbD0iIzU1ODMxQiIgZD0iTTE0Mi43NSAxODIuOTY0aDMuMDcxdjEuNTM2aC0zLjA3MXYtMS41MzZaIi8+PHBhdGggZmlsbD0iI0Y1QjQzNCIgZD0iTTE0NS44MjEgMTc5Ljg5M2gxLjUzNnYxLjUzNWgtMS41MzZ2LTEuNTM1Wm0tMS41MzUgMGgxLjUzNXYxLjUzNWgtMS41MzV2LTEuNTM1Wm0wLTEuNTM2aDEuNTM1djEuNTM2aC0xLjUzNXYtMS41MzZaIi8+PHBhdGggZmlsbD0iI0Y1QTgzNCIgZD0iTTE3My40NjQgNzguNTM1N2gtMS41MzV2MS41MzU3aC0xLjUzNnYxLjUzNTdoLTEuNTM2djEuNTM1N2gtMS41MzZ2MS41MzU4aC0xLjUzNXYxLjUzNTdoLTEuNTM2Vjg3Ljc1aDkuMjE0di05LjIxNDNaIi8+PHBhdGggZmlsbD0iI0Y1OTEzNCIgZD0iTTE2NC4yNSA4Ni4yMTQzaDEuNTM2Vjg3Ljc1aC0xLjUzNnYtMS41MzU3WiIvPjxwYXRoIGZpbGw9IiNFMjk1MjEiIGQ9Ik0xNjUuNzg2IDg2LjIxNDNoMS41MzVWODcuNzVoLTEuNTM1di0xLjUzNTdaIi8+PHBhdGggZmlsbD0iI0Y1OTEzNCIgZD0iTTE3MC4zOTMgODYuMjE0M2gxLjUzNlY4Ny43NWgtMS41MzZ2LTEuNTM1N1oiLz48cGF0aCBmaWxsPSIjRTI5NTIxIiBkPSJNMTcxLjkyOSA4Ni4yMTQzaDEuNTM1Vjg3Ljc1aC0xLjUzNXYtMS41MzU3WiIvPjxwYXRoIGZpbGw9IiNGNTkxMzQiIGQ9Ik0xNzEuOTI5IDgwLjA3MTRoMS41MzV2MS41MzU3aC0xLjUzNXYtMS41MzU3WiIvPjxwYXRoIGZpbGw9IiNFMjk1MjEiIGQ9Ik0xNzAuMzkzIDgwLjA3MTRoMS41MzZ2MS41MzU3aC0xLjUzNnYtMS41MzU3WiIvPjxwYXRoIGZpbGw9IiNGNTkxMzQiIGQ9Ik0xNzAuMzkzIDgxLjYwNzFoMS41MzZ2MS41MzU3aC0xLjUzNnYtMS41MzU3WiIvPjxwYXRoIGZpbGw9IiNFMjk1MjEiIGQ9Ik0xNjguODU3IDg0LjY3ODZoMS41MzZ2MS41MzU3aC0xLjUzNnYtMS41MzU3WiIvPjxwYXRoIGZpbGw9IiNGNTkxMzQiIGQ9Ik0xNjcuMzIxIDgzLjE0MjhoMS41MzZ2MS41MzU4aC0xLjUzNnYtMS41MzU4WiIvPjxwYXRoIGZpbGw9IiNGNUI0MzQiIGQ9Ik0xNjIuNzE0IDExMC43ODZ2MS41MzVoMTAuNzV2LTQuNjA3aC0xLjUzNXYtMS41MzVoLTEuNTM2di0xLjUzNmgtMS41MzZ2MS41MzZoLTEuNTM2djEuNTM1aC0xLjUzNXYxLjUzNmgtMS41MzZ2MS41MzZoLTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNCOTUzMDkiIGQ9Ik0xNjguODU3IDEwNC42NDN2LTEuNTM2aDMuMDcydjEuNTM2aDEuNTM1djEuNTM2SDE3NXY2LjE0MmgtMS41MzZ2LTQuNjA3aC0xLjUzNXYtMS41MzVoLTEuNTM2di0xLjUzNmgtMS41MzZaIi8+PHBhdGggZmlsbD0iI0U5MjEyMSIgZD0iTTE2NC4yNSAxMTAuNzg2aDEuNTM2djEuNTM1aC0xLjUzNnYtMS41MzVaIi8+PHBhdGggZmlsbD0iI0UzQTEyMCIgZD0iTTE2OC44NTcgMTEwLjc4Nmg0LjYwN3YxLjUzNWgtNC42MDd2LTEuNTM1WiIvPjxwYXRoIGZpbGw9IiNCOTUzMDkiIGQ9Ik0xNzMuNDY0IDEwNy43MTRIMTc1djEuNTM2aC0xLjUzNnYtMS41MzZaIi8+PHBhdGggZmlsbD0iI0U5MjEyMSIgZD0iTTE2Ny4zMjEgMTA3LjcxNGgxLjUzNnYxLjUzNmgtMS41MzZ2LTEuNTM2Wm0zLjA3MiAxLjUzNmgxLjUzNnYxLjUzNmgtMS41MzZ2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNENUY2RjQiIGQ9Ik0xNzMuNDY0IDEzNS4zNTd2LTMuMDcxaC05LjIxNHYzLjA3MWgxLjUzNnYxLjUzNmg2LjE0M3YtMS41MzZoMS41MzVaIi8+PHBhdGggZmlsbD0iIzcwQUMyNCIgZD0iTTE2NS43ODYgMTMyLjI4Nmg2LjE0M3YxLjUzNWgtNi4xNDN2LTEuNTM1WiIvPjxwYXRoIGZpbGw9IiM1NTgzMUIiIGQ9Ik0xNjcuMzIxIDEzMy44MjFoMy4wNzJ2MS41MzZoLTMuMDcydi0xLjUzNloiLz48cGF0aCBmaWxsPSIjRjVCNDM0IiBkPSJNMTcwLjM5MyAxMzAuNzVoMS41MzZ2MS41MzZoLTEuNTM2di0xLjUzNlptLTEuNTM2IDBoMS41MzZ2MS41MzZoLTEuNTM2di0xLjUzNlptMC0xLjUzNmgxLjUzNnYxLjUzNmgtMS41MzZ2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiNCOTUzMDkiIGQ9Ik0xNjUuNzg2IDE1Ni44NTd2My4wNzFoNC42MDd2LTEuNTM1aDEuNTM2di0xLjUzNmgxLjUzNXYtNC42MDdoLTEuNTM1di0xLjUzNmgtMS41MzZ2MS41MzZoLTEuNTM2djEuNTM2aC0xLjUzNnYzLjA3MWgtMS41MzVaIi8+PHBhdGggZmlsbD0iI0U5Q0RCOSIgZD0iTTE2NC4yNSAxNTkuOTI4aDEuNTM2djEuNTM2aC0xLjUzNnYtMS41MzZabTEuNTM2LTEuNTM1aDEuNTM1djEuNTM1aC0xLjUzNXYtMS41MzVaIi8+PHBhdGggZmlsbD0iIzlDNDYwNyIgZD0iTTE2Ny4zMjEgMTU4LjM5M2gzLjA3MnYxLjUzNWgtMy4wNzJ2LTEuNTM1Wm0zLjA3Mi0xLjUzNmgxLjUzNnYxLjUzNmgtMS41MzZ2LTEuNTM2WiIvPjxwYXRoIGZpbGw9IiMxREExRjIiIGZpbGwtcnVsZT0iZXZlbm9kZCIgZD0iTTE3MS45MjkgMTczLjc1aC02LjE0M3YxLjUzNmgtMS41MzZ2MS41MzVoLTEuNTM2djYuMTQzaDEuNTM2djEuNTM2aDEuNTM2djEuNTM2aDYuMTQzVjE4NC41aDEuNTM1di0xLjUzNkgxNzV2LTYuMTQzaC0xLjUzNnYtMS41MzVoLTEuNTM1di0xLjUzNlptLTYuMTQzIDYuMTQzaDEuNTM1djEuNTM1aC0xLjUzNXYtMS41MzVabTMuMDcxIDEuNTM1djEuNTM2aC0xLjUzNnYtMS41MzZoMS41MzZabTEuNTM2LTEuNTM1aC0xLjUzNnYxLjUzNWgxLjUzNnYtMS41MzVabTAgMHYtMS41MzZoMS41MzZ2MS41MzZoLTEuNTM2WiIgY2xpcC1ydWxlPSJldmVub2RkIi8+PC9zdmc+';
        string memory json = string(
            abi.encodePacked(
                '{"name": "Snacks ',
                uint2str(tokenId),
                '", "description": "Here for the snacks, preferably not burned.", "image": "',
                image,
                '"}'
            )
        );

        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(bytes(json))
            )
        );
    }
}
/*

███████ ██    ██ ██████  ███████ ██████  ██████  ██    ██ ██████  ███    ██ 
██      ██    ██ ██   ██ ██      ██   ██ ██   ██ ██    ██ ██   ██ ████   ██ 
███████ ██    ██ ██████  █████   ██████  ██████  ██    ██ ██████  ██ ██  ██ 
     ██ ██    ██ ██      ██      ██   ██ ██   ██ ██    ██ ██   ██ ██  ██ ██ 
███████  ██████  ██      ███████ ██   ██ ██████   ██████  ██   ██ ██   ████ 
                                                                            
                                                                            
███████ ███    ██  █████   ██████ ██   ██ ███████                           
██      ████   ██ ██   ██ ██      ██  ██  ██                                
███████ ██ ██  ██ ███████ ██      █████   ███████                           
     ██ ██  ██ ██ ██   ██ ██      ██  ██       ██                           
███████ ██   ████ ██   ██  ██████ ██   ██ ███████                           

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./Art.sol";

contract SuperburnSnacks is ERC721A, Ownable {
    uint mintEndTime = 1676246400; // Monday, February 13th, 12am (00:00) UTC
    constructor() ERC721A("Superburn Snacks", "SNACKS") {}

    // starts the token number at 1 vs the default of 0
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    // sets a variable price throughout mint
    // tokens 1 - 100 ~~~~~~~~~~ free
    // tokens 101 - 1000 ~~~~~~~ .001 eth
    // tokens 1001 - 5000 ~~~~~~ .005 eth
    // tokens 5000+ ~~~~~~~~~~~~ .01 eth
    function getPrice(uint quantity) public view returns(uint) {
        uint cost = 0;
        for (uint i = 0; i < quantity; i++) {
            if (i + _nextTokenId() > 100 && i + _nextTokenId() < 1001) {
                cost += 1000000000000000; // .001 eth
            } else if (i + _nextTokenId() > 1000 && i + _nextTokenId() < 5001) {
                cost += 5000000000000000; // .005 eth
            } else if (i + _nextTokenId() > 5000) {
                cost += 10000000000000000; // .01 eth
            }
        }
        return cost;
    }

    function mint(uint quantity) public payable {
        require(msg.value >= getPrice(quantity), 'not enough eth');
        require(quantity <= 20,'max 20 per tx');
        require(block.timestamp <= mintEndTime, 'mint is closed');
        _mint(msg.sender, quantity);
    }

    // gets the seconds until a block timestamp
    function secondsRemaining(uint end) public view returns (uint) {
        if (block.timestamp <= end) {
            return end - block.timestamp;
        } else {
            return 0;
        }
    }

    // gets the minutes until a block timestamp
    function minutesRemaining(uint end) public view returns (uint) {
        if (secondsRemaining(end) >= 60) {
            return (end - block.timestamp) / 60;
        } else {
            return 0;
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return art.metadata(tokenId);
    }

    function withdraw() external onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.3
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import './IERC721A.sol';

/**
 * @dev Interface of ERC721 token receiver.
 */
interface ERC721A__IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
        return 0;
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
        return
            interfaceId == 0x01ffc9a7 || // ERC165 interface ID for ERC165.
            interfaceId == 0x80ac58cd || // ERC165 interface ID for ERC721.
            interfaceId == 0x5b5e139f; // ERC165 interface ID for ERC721Metadata.
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
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, it can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return '';
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
            if (_startTokenId() <= curr)
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

        if (_msgSenderERC721A() != owner)
            if (!isApprovedForAll(owner, _msgSenderERC721A())) {
                revert ApprovalCallerNotOwnerNorApproved();
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
        return
            _startTokenId() <= tokenId &&
            tokenId < _currentIndex && // If within bounds,
            _packedOwnerships[tokenId] & _BITMASK_BURNED == 0; // and not burned.
    }

    /**
     * @dev Returns whether `msgSender` is equal to `approvedAddress` or `owner`.
     */
    function _isSenderApprovedOrOwner(
        address approvedAddress,
        address owner,
        address msgSender
    ) private pure returns (bool result) {
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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        if (address(uint160(prevOwnershipPacked)) != from) revert TransferFromIncorrectOwner();

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

        // The nested ifs save around 20+ gas over a compound boolean condition.
        if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSenderERC721A()))
            if (!isApprovedForAll(from, _msgSenderERC721A())) revert TransferCallerNotOwnerNorApproved();

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
            _packedOwnerships[tokenId] = _packOwnershipData(
                to,
                _BITMASK_NEXT_INITIALIZED | _nextExtraData(from, to, prevOwnershipPacked)
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

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev Equivalent to `safeTransferFrom(from, to, tokenId, '')`.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override {
        safeTransferFrom(from, to, tokenId, '');
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
    ) public payable virtual override {
        transferFrom(from, to, tokenId);
        if (to.code.length != 0)
            if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
                revert TransferToNonERC721ReceiverImplementer();
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
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

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
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

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
    ) private returns (bool) {
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
            _packedOwnerships[startTokenId] = _packOwnershipData(
                to,
                _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0)
            );

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
                for {
                    let tokenId := add(startTokenId, 1)
                } iszero(eq(tokenId, end)) {
                    tokenId := add(tokenId, 1)
                } {
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
            _packedOwnerships[startTokenId] = _packOwnershipData(
                to,
                _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0)
            );

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
        _safeMint(to, quantity, '');
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
            if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSenderERC721A()))
                if (!isApprovedForAll(from, _msgSenderERC721A())) revert TransferCallerNotOwnerNorApproved();
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
    function _extraData(
        address from,
        address to,
        uint24 previousExtraData
    ) internal view virtual returns (uint24) {}

    /**
     * @dev Returns the next extra data for the packed ownership data.
     * The returned result is shifted into position.
     */
    function _nextExtraData(
        address from,
        address to,
        uint256 prevOwnershipPacked
    ) private view returns (uint256) {
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