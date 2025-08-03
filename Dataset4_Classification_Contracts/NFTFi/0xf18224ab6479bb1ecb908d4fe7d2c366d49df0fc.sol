// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");

        return _balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

// [MIT License]
// @author Brecht Devos <brecht@loopring.org>
// @notice Encodes some bytes to the base64 representation
library Utils {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for { let i := 0 } lt(i, len) {} {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
// SPDX-License-Identifier: MIT
// Valorem Labs Inc. (c) 2023.
pragma solidity 0.8.18;

import {ERC721} from "solmate/tokens/ERC721.sol";
import "./interfaces/IERC2981.sol";
import {Owned} from "solmate/auth/Owned.sol";
import "./Utils.sol";

/*//////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                //
//   $$$$$$$$$$                                                                                   //
//    $$$$$$$$                                  _|                                                //
//     $$$$$$ $$$$$$$$$$   _|      _|   _|_|_|  _|    _|_|    _|  _|_|   _|_|    _|_|_|  _|_|     //
//       $$    $$$$$$$$    _|      _| _|    _|  _|  _|    _|  _|_|     _|_|_|_|  _|    _|    _|   //
//   $$$$$$$$$$ $$$$$$       _|  _|   _|    _|  _|  _|    _|  _|       _|        _|    _|    _|   //
//    $$$$$$$$    $$           _|       _|_|_|  _|    _|_|    _|         _|_|_|  _|    _|    _|   //
//     $$$$$$                                                                                     //
//       $$                                                                                       //
//                                                                                                //
//////////////////////////////////////////////////////////////////////////////////////////////////*/

/**
 * @title Valorem Access Pass NFT
 * @author megsdevs
 * @author neodaoist
 * @author 0xAlcibiades
 * @notice The inaugural Valorem Access Pass NFT.
 */
contract ValoremAccessPass is ERC721, IERC2981, Owned {
    /*//////////////////////////////////////////////////////////////
    // Errors
    //////////////////////////////////////////////////////////////*/

    /// @notice Cannot mint more than the max supply.
    /// @param attemptedQuantity The amount of quantity attempting to be minted.
    /// @param maxSupply The allowed max supply that can be minted.
    error MintQuantityCannotExceedMaxSupply(uint256 attemptedQuantity, uint256 maxSupply);

    /// @notice Cannot request tokenUri for an invalid token.
    /// @param tokenId The requested tokenId.
    error InvalidToken(uint256 tokenId);

    /*//////////////////////////////////////////////////////////////
    // Immutable/Constant - Public
    //////////////////////////////////////////////////////////////*/

    /// @notice Royalty percentage, expressed in basis points.
    uint16 public constant ROYALTY_PERCENTAGE_IN_BPS = 500;

    /// @notice Maximum number of mintable passes.
    uint256 public immutable maxSupply;

    /*//////////////////////////////////////////////////////////////
    // State Variables - Public
    //////////////////////////////////////////////////////////////*/

    /// @notice Total number of minted passes.
    uint256 public totalSupply;

    /*//////////////////////////////////////////////////////////////
    // Constructor
    //////////////////////////////////////////////////////////////*/

    /// @notice Sets supply.
    /// @param _maxSupply Maximum number of mintable passes.
    constructor(address _owner, uint256 _maxSupply) ERC721("Valorem Access Pass", "VALPASS") Owned(_owner) {
        maxSupply = _maxSupply;
    }

    /*//////////////////////////////////////////////////////////////
    // Mint Logic
    //////////////////////////////////////////////////////////////*/

    /// @notice Mints access passes to N arbitrary addresses, one per supplied address.
    /// @param recipients Recipients of the minted passes.
    function airdropTo(address[] calldata recipients) external onlyOwner {
        unchecked {
            uint256 _totalSupply = totalSupply;
            uint256 _endingSupply = _totalSupply + recipients.length;

            if (_endingSupply > maxSupply) {
                revert MintQuantityCannotExceedMaxSupply(_endingSupply, maxSupply);
            }

            for (uint256 i = 0; i < recipients.length; i++) {
                _mint(recipients[i], ++_totalSupply);
            }

            totalSupply = _endingSupply;
        }
    }

    /*//////////////////////////////////////////////////////////////
    // URI Logic
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns storefront-level metadata.
    function contractURI() public pure returns (string memory) {
        /* solhint-disable quotes */
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Utils.encode(
                    bytes(
                        string(
                            abi.encodePacked(
                                '{"name": "Valorem Access Pass", ',
                                '"description": "The Valorem Access Pass NFT grants perennial early access to Valorem features.", ',
                                '"image": "ipfs://bafkreiacwd3ok66tvo5gxj24fs7tq5h5asxwb6uzqgcfd4cpjajl2v6s7e", ',
                                '"external_link": "https://valorem.xyz/"}'
                            )
                        )
                    )
                )
            )
        );
    }

    /// @notice Returns a token's URI if it has been minted.
    /// @param tokenId The ID of the token to get the URI for.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (tokenId == 0 || _ownerOf[tokenId] == address(0)) {
            revert InvalidToken(tokenId);
        }

        /* solhint-disable quotes */
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Utils.encode(
                    bytes(
                        string(
                            abi.encodePacked(
                                '{"name": "Valorem Access Pass", ',
                                '"description": "The Valorem Access Pass NFT grants perennial early access to Valorem features.", ',
                                '"image": "ipfs://bafybeig6urghfrb3be7tepd4jp44pjm6fnvnc2yeba5f46x6kcqhjvln2y", ',
                                '"animation_url": "ipfs://bafybeifd4w76c4z4o44omf5oj7fnajp36suhh3pnyplt2lhk2k576qghxa/Valorem%20Access%20Pass%20NFT%20animation%20(final).mp4", ',
                                '"external_url": "https://valorem.xyz/", ',
                                '"background_color": "#151B50", ',
                                '"content": {"mimeType": "video/mp4", '
                                '"hash": "bafybeiftiyr3tw2v256wvwu3kogjo7vr53qg7oukj4n3c2ifwo7g3zl3wq", ',
                                '"uri": "ipfs://bafybeifd4w76c4z4o44omf5oj7fnajp36suhh3pnyplt2lhk2k576qghxa/Valorem%20Access%20Pass%20NFT%20animation%20(final).mp4"}}'
                            )
                        )
                    )
                )
            )
        );
    }

    /*//////////////////////////////////////////////////////////////
    // Royalty Logic
    //////////////////////////////////////////////////////////////*/

    function royaltyInfo(uint256, /*_tokenId*/ uint256 _salePrice)
        public
        view
        virtual
        override
        returns (address, uint256)
    {
        uint256 royaltyAmount = (_salePrice * ROYALTY_PERCENTAGE_IN_BPS) / 10_000;
        return (owner, royaltyAmount);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }
}
// SPDX-License-Identifier: MIT
// Valorem Labs Inc. (c) 2023.
pragma solidity 0.8.18;

interface IERC2981 {
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}