// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/// @dev all data if 0 then not set
struct GenerationData {
    uint lvl;
    uint bcground_color;
    uint body;
    uint boots;
    uint cloth;
    uint glasses;
    uint hat;
    uint pants;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./GeneratorLib.sol";
import "./RandLib.sol";
import "./Ownable.sol";
import "./GenerationData.sol";
import "./IGenerator.sol";

uint8 constant PIXELS_COUNT = 64;

contract Generator is Ownable, IGenerator {
    using PathLib for Path;
    using PathLib for Path[];
    using RandLib for Rand;

    // bcground (by files)
    Path[] head;
    // elon (lvl=>itemId=>file_paths)
    mapping(uint => mapping(uint => Path[])) body;
    mapping(uint => mapping(uint => Path[])) boots;
    mapping(uint => mapping(uint => Path[])) clothes;
    mapping(uint => mapping(uint => Path[])) glasses;
    mapping(uint => mapping(uint => Path[])) hats;
    mapping(uint => mapping(uint => Path[])) pants;
    // elon
    mapping(uint => uint8) body_count;
    mapping(uint => uint8) boots_count;
    mapping(uint => uint8) clothes_count;
    mapping(uint => uint8) glasses_count;
    mapping(uint => uint8) hats_count;
    mapping(uint => uint8) pants_count;
    string[] private colors = [
        "#ebbf89",
        "#47321c",
        "#898989",
        "#898989",
        "#898989",
        "#8089a2",
        "#4c5570",
        "#354e99",
        "#3c6cb2",
        "#a12621",
        "#842637",
        "#8a4e6a",
        "#cfd2d1",
        "#cfd2d1",
        "#6e3787",
        "#6e3787",
        "#454753",
        "#847344",
        "#614a4a",
        "#535a5d",
        "#364c52",
        "#2c2d33",
        "#b79539",
        "#b6984d",
        "#645540",
        "#6c2d27",
        "#71422c",
        "#817757",
        "#2c221f",
        "#62a75f"
    ];

    // setters for elon
    function set_head(Path[] calldata paths) external onlyOwner {
        uint i;
        for (i = 0; i < paths.length; ++i) head.push(paths[i]);
    }

    function set_body(uint lvl, FileData[] calldata files) external onlyOwner {
        FilesLib.set_files(body, body_count, lvl, files);
    }

    function set_boots(uint lvl, FileData[] calldata files) external onlyOwner {
        FilesLib.set_files(boots, boots_count, lvl, files);
    }

    function set_clothes(
        uint lvl,
        FileData[] calldata files
    ) external onlyOwner {
        FilesLib.set_files(clothes, clothes_count, lvl, files);
    }

    function set_glasses(
        uint lvl,
        FileData[] calldata files
    ) external onlyOwner {
        FilesLib.set_files(glasses, glasses_count, lvl, files);
    }

    function set_hats(uint lvl, FileData[] calldata files) external onlyOwner {
        FilesLib.set_files(hats, hats_count, lvl, files);
    }

    function set_pants(uint lvl, FileData[] calldata files) external onlyOwner {
        FilesLib.set_files(pants, pants_count, lvl, files);
    }

    // svg generation data
    function get_generation_data_internal(
        uint lvl,
        uint seed
    ) public view returns (GenerationData memory) {
        Rand memory rnd = Rand(uint(keccak256(abi.encodePacked(lvl, seed))), 0);
        GenerationData memory data = GenerationData(0, 0, 0, 0, 0, 0, 0, 0);
        data.lvl = lvl;

        data.bcground_color = 1 + (rnd.next() % colors.length);
        data.body = 1 + (rnd.next() % body_count[lvl]);
        if (rnd.next() % 2 == 1)
            data.boots = 1 + (rnd.next() % boots_count[lvl]);
        if (rnd.next() % 2 == 1)
            data.cloth = 1 + (rnd.next() % clothes_count[lvl]);
        if (rnd.next() % 2 == 1)
            data.glasses = 1 + (rnd.next() % glasses_count[lvl]);
        if (rnd.next() % 2 == 1) data.hat = 1 + (rnd.next() % hats_count[lvl]);
        if (rnd.next() % 2 == 1)
            data.pants = 1 + (rnd.next() % pants_count[lvl]);

        return data;
    }

    // generate SVG
    function svg_from_data(
        GenerationData memory data
    ) public view returns (string memory) {
        return _svg_from_data(data);
    }

    function _svg_from_data(
        GenerationData memory data
    ) private view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    abi.encodePacked(
                        "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0",
                        " ",
                        Converter.toString(PIXELS_COUNT),
                        " ",
                        Converter.toString(PIXELS_COUNT),
                        "'>"
                    ),
                    _background_svg(data),
                    _elon_svg(data),
                    "</svg>"
                )
            );
    }

    function _background_svg(
        GenerationData memory data
    ) private view returns (bytes memory) {
        return
            abi.encodePacked(
                Path(colors[data.bcground_color - 1], "M 0 0 h64 v64 h-64")
                    .toSvg()
            );
    }

    function _elon_svg(
        GenerationData memory data
    ) private view returns (bytes memory) {
        return
            abi.encodePacked(
                body[data.lvl][data.body].toSvg(),
                head.toSvg(),
                data.boots == 0 ? "" : boots[data.lvl][data.boots].toSvg(),
                data.cloth == 0 ? "" : clothes[data.lvl][data.cloth].toSvg(),
                data.glasses == 0
                    ? ""
                    : glasses[data.lvl][data.glasses].toSvg(),
                data.hat == 0 ? "" : hats[data.lvl][data.hat].toSvg(),
                data.pants == 0 ? "" : pants[data.lvl][data.pants].toSvg()
            );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./RandLib.sol";

struct Path {
    string fill;
    string data;
}

struct FileData {
    uint file;
    Path[] paths;
}

library FilesLib {
    function set_files(
        mapping(uint => mapping(uint => Path[])) storage files,
        mapping(uint => uint8) storage counts,
        uint lvl,
        FileData[] calldata input
    ) internal {
        counts[lvl] = set_files(files[lvl], counts[lvl], input);
    }

    function set_file(
        mapping(uint => Path[]) storage paths,
        uint8 count,
        FileData calldata input
    ) internal returns (uint8) {
        Path[] storage storageFile = paths[input.file];
        if (storageFile.length > 0) delete paths[input.file];
        else ++count;
        for (uint i = 0; i < input.paths.length; ++i) {
            storageFile.push(input.paths[i]);
        }
        return count;
    }

    function set_files(
        mapping(uint => Path[]) storage paths,
        uint8 count,
        FileData[] calldata input
    ) internal returns (uint8) {
        if (input.length == 0) return count;
        uint i;
        for (i = 0; i < input.length; ++i)
            count = set_file(paths, count, input[i]);
        return count;
    }
}

struct ColorsData {
    string[] lvl0;
    string[] lvl1;
    string[] lvl2;
    string[] lvl3;
    string[] lvl4;
}

library ColorConvert {
    function toSvgColor(uint24 value) internal pure returns (string memory) {
        return string(abi.encodePacked("#", toHex(value)));
    }

    function toHex(uint24 value) internal pure returns (bytes memory) {
        bytes memory buffer = new bytes(6);
        for (uint i = 0; i < 3; ++i) {
            buffer[5 - i * 2] = hexChar(uint8(value) & 0x0f);
            buffer[4 - i * 2] = hexChar((uint8(value) >> 4) & 0x0f);
            value >>= 8;
        }
        return buffer;
    }

    function hexChar(uint8 value) internal pure returns (bytes1) {
        if (value < 10) return bytes1(uint8(48 + (uint(value) % 10)));
        return bytes1(uint8(65 + uint256((value - 10) % 6)));
    }
}

library Converter {
    function toString(uint value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint temp = value;
        uint digits;
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
}

library StringLib {
    function equals(
        string memory s1,
        string memory s2
    ) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((s1))) ==
            keccak256(abi.encodePacked((s2))));
    }
}

library PathLib {
    string constant CONTOUR_COLOR = "#000000";
    using PathLib for Path;
    using RandLib for Rand;
    using RandLib for string[];
    using Converter for uint8;
    using ColorConvert for uint24;
    using StringLib for string;

    function toSvg(Path memory p) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked("<path fill='", p.fill, "' d='", p.data, "'/>")
            );
    }

    function toSvg(
        Path[] storage paths,
        string[] storage colors,
        uint color_id
    ) internal view returns (string memory) {
        return
            color_id == 0 || color_id > colors.length
                ? toSvg(paths)
                : toSvg(paths, colors[color_id - 1]);
    }

    function toSvg(
        Path memory p,
        string[] storage colors,
        Rand memory rnd
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<path fill='",
                    (
                        p.fill.equals(CONTOUR_COLOR)
                            ? p.fill
                            : (colors.random(rnd))
                    ),
                    "' d='",
                    p.data,
                    "'/>"
                )
            );
    }

    function toSvg(
        Path memory p,
        string memory color
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<path fill='",
                    color,
                    "' d='",
                    p.data,
                    color,
                    "'/>"
                )
            );
    }

    function toSvg(
        Path[] storage paths,
        string[] storage colors,
        Rand memory rnd
    ) internal view returns (string memory) {
        string memory res;
        for (uint i = 0; i < paths.length; ++i) {
            res = string(abi.encodePacked(res, paths[i].toSvg(colors, rnd)));
        }
        return res;
    }

    function toSvg(
        Path[] storage paths,
        string memory color
    ) internal view returns (string memory) {
        string memory res;
        for (uint i = 0; i < paths.length; ++i) {
            Path memory p = paths[i];
            res = string(
                abi.encodePacked(
                    res,
                    p.toSvg(p.fill.equals(CONTOUR_COLOR) ? p.fill : color)
                )
            );
        }
        return res;
    }

    function toSvg(Path[] storage paths) internal view returns (string memory) {
        string memory res;
        for (uint i = 0; i < paths.length; ++i) {
            res = string(abi.encodePacked(res, paths[i].toSvg()));
        }
        return res;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./GenerationData.sol";

interface IGenerator {
    function get_generation_data_internal(
        uint lvl,
        uint seed
    ) external view returns (GenerationData memory);

    function svg_from_data(
        GenerationData memory data
    ) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Ownable {
    address _owner;

    event RenounceOwnership();

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "only owner");
        _;
    }

    function owner() external view virtual returns (address) {
        return _owner;
    }

    function ownerRenounce() public onlyOwner {
        _owner = address(0);
        emit RenounceOwnership();
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

struct Rand {
    uint seed;
    uint nonce;
}

library RandLib {
    function next(Rand memory rnd) internal pure returns (uint) {
        return
            uint(
                keccak256(
                    abi.encodePacked(rnd.seed, ++rnd.nonce)
                )
            );
    }

    function random_value(uint nonce) internal view returns (uint) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        msg.sender,
                        nonce,
                        block.number
                    )
                )
            );
    }

    function random(
        string[] memory data,
        Rand memory rnd
    ) internal pure returns (string memory) {
        return data[randomIndex(data, rnd)];
    }

    function randomIndex(
        string[] memory data,
        Rand memory rnd
    ) internal pure returns (uint) {
        return next(rnd) % data.length;
    }
}
/*
This token was made by humans for humans. No AI was involved at any stage of the development. All code, all arts and idea was created by hands, brain and soul.
(C) Elon Muscle team 2024
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "./Token.sol";

contract ELON_MUSCLE is Token {
    uint public constant max_lvl = 11;
    uint[] lvl_pool_share = [
        7000,
        3000,
        2000,
        1500,
        1100,
        800,
        600,
        400,
        200,
        42
    ];
    uint constant precesion = 10000;

    constructor() Token("ELON MUSCLE", "MUSC") {}

    function get_lvl() public view returns (uint) {
        if (!this.is_token_started()) return 1;
        return get_lvl_internal(balanceOf(_pair));
    }

    function get_lvl_internal(uint pair_balance) internal view returns (uint) {
        uint i;
        for (i = 0; i < lvl_pool_share.length; ++i) {
            if (
                pair_balance >
                (_startTotalSupply * lvl_pool_share[i]) / precesion
            ) return i + 1;
        }
        return max_lvl;
    }

    function get_generation_data() public view returns (GenerationData memory) {
        return get_generation_data_internal(get_lvl(), balanceOf(_pair));
    }

    function musk_svg() external view returns (string memory) {
        return svg_from_data(get_generation_data());
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20TokenBase is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 9;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
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

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ERC20TokenBase.sol";
import "../generator/Generator.sol";

address constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

contract Token is ERC20TokenBase, Generator {
    uint8 internal constant DECIMALS = 9;

    uint256 constant _startTotalSupply = 1e4 * (10 ** DECIMALS);
    uint256 constant _startMaxBuyCount = (_startTotalSupply * 5) / 10000;
    uint256 constant _addMaxBuyPercentPerSec = 1; // 100%=_addMaxBuyPrecesion add 0.005%/second
    uint256 constant _addMaxBuyPrecesion = 10000;
    uint256 constant _taxPrecesion = 1000;
    uint256 constant _transferZeroTaxSeconds = 1000; // zero tax transfer time
    address internal _pair;
    address immutable _deployer;
    bool internal _feeLocked;
    uint256 internal _startTime;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20TokenBase(name_, symbol_) {
        _deployer = msg.sender;
        _mint(msg.sender, _startTotalSupply);
    }

    modifier maxBuyLimit(uint256 amount) {
        require(amount <= maxBuy(), "max buy");
        _;
    }
    modifier lockFee() {
        _feeLocked = true;
        _;
        _feeLocked = false;
    }

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }

    function start_token(address pair_address) external onlyOwner {
        _startTime = block.timestamp;
        _pair = pair_address;
    }

    function is_token_started() public view returns (bool) {
        return _startTime != 0;
    }

    function maxBuy() public view returns (uint256) {
        if (!is_token_started()) return _startTotalSupply;
        uint256 count = _startMaxBuyCount +
            (_startTotalSupply *
                (block.timestamp - _startTime) *
                _addMaxBuyPercentPerSec) /
            _addMaxBuyPrecesion;
        if (count > _startTotalSupply) count = _startTotalSupply;
        return count;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        // allow burning
        if (to == address(0) || to == DEAD_ADDRESS) {
            transfer_internal(from, to, amount);
            return;
        }

        // system transfers
        if (
            !is_token_started() &&
            (from == address(0) ||
                from == address(this) ||
                from == _deployer ||
                to == _deployer)
        ) {
            super._transfer(from, to, amount);
            return;
        }

        require(is_token_started(), "token not started");

        // transfers with fee
        if (_feeLocked) {
            super._transfer(from, to, amount);
            return;
        } else {
            if (from == _pair) {
                buy(to, amount);
                return;
            } else if (to == _pair) {
                sell(from, amount);
                return;
            } else transfer_internal(from, to, amount);
        }
    }

    function buy(
        address to,
        uint256 amount
    ) internal virtual maxBuyLimit(amount) lockFee {
        super._transfer(_pair, to, amount);
    }

    function sell(address from, uint256 amount) internal virtual lockFee {
        super._transfer(from, _pair, amount);
    }

    function transfer_internal(
        address from,
        address to,
        uint256 amount
    ) internal virtual lockFee {
        if (to == address(0) || to == DEAD_ADDRESS) {
            _burn(from, amount);
            return;
        }
        super._transfer(from, to, amount);
    }
}