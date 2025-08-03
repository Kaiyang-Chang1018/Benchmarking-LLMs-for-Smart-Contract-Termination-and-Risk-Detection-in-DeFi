// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract PepeMaximusNFT {
    string public name = "Pepe Maximus";
    string public symbol = "PEPEMAX";
    uint256 public constant totalSupply = 600;

    address public owner; // Wallet, die die NFTs erhält
    address public gasPayer; // Wallet, die die Gas-Gebühren für das Minting zahlt

    string public constant CID1 = "bafybeidvjal4msvc4plhvdcz4gncgvgbt37qtinu7ysntrkty4a5olh7ra";
    string public constant CID2 = "bafybeidxnvwgqjtxbarbvm72dvwkkh6gsep74y2f6pdrtjrdyhywlvn2q4";
    string public constant CID3 = "bafybeiaoidjubc67dz57pge4qlte2spaz3gk2uaginpmbzycfuyvwtqnuy";

    struct Token {
        uint256 id;
        string metadataURI;
        address owner;
    }

    mapping(uint256 => Token) public tokens;
    mapping(uint256 => address) public tokenApprovals;
    mapping(address => uint256[]) public ownerTokens;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event CIDUpdated(uint256 batchId, string newCID);

    bool private reentrancyGuard;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier onlyGasPayer() {
        require(msg.sender == gasPayer, "Only the gas payer can perform this action");
        _;
    }

    modifier nonReentrant() {
        require(!reentrancyGuard, "Reentrant call detected");
        reentrancyGuard = true;
        _;
        reentrancyGuard = false;
    }

    constructor(address _owner, address _gasPayer) {
        owner = _owner;
        gasPayer = _gasPayer;
    }

    function mint(uint256 tokenId) public onlyGasPayer {
        require(tokenId > 0 && tokenId <= totalSupply, "Token ID invalid");
        require(tokens[tokenId].owner == address(0), "Token already minted");

        string memory metadataURI = getMetadataURI(tokenId);

        tokens[tokenId] = Token({
            id: tokenId,
            metadataURI: metadataURI,
            owner: owner
        });

        ownerTokens[owner].push(tokenId);

        emit Transfer(address(0), owner, tokenId);
    }

    function batchMint(uint256[] memory tokenIds) public onlyGasPayer {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] > 0 && tokenIds[i] <= totalSupply, "Invalid token ID in batch");
            mint(tokenIds[i]);
        }
    }

    function transferFrom(address from, address to, uint256 tokenId) public nonReentrant {
        require(tokens[tokenId].owner == from, "Not the token owner");
        require(
            msg.sender == from || msg.sender == tokenApprovals[tokenId],
            "Not authorized to transfer"
        );

        tokens[tokenId].owner = to;

        // Entferne Token aus der Liste des aktuellen Besitzers
        uint256 index = findTokenIndex(from, tokenId);
        ownerTokens[from][index] = ownerTokens[from][ownerTokens[from].length - 1];
        ownerTokens[from].pop();

        // Füge Token zur Liste des neuen Besitzers hinzu
        ownerTokens[to].push(tokenId);

        emit Transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) public {
        require(tokens[tokenId].owner == msg.sender, "Not the token owner");

        tokenApprovals[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(tokens[tokenId].owner != address(0), "Token does not exist");
        return tokens[tokenId].metadataURI;
    }

    function getMetadataURI(uint256 tokenId) internal pure returns (string memory) {
        if (tokenId >= 1 && tokenId <= 200) {
            return string(abi.encodePacked("https://ipfs.io/ipfs/", CID1, "/Pepe_Maximus_", padTokenId(tokenId), ".json"));
        } else if (tokenId >= 201 && tokenId <= 400) {
            return string(abi.encodePacked("https://ipfs.io/ipfs/", CID2, "/Pepe_Maximus_", padTokenId(tokenId), ".json"));
        } else if (tokenId >= 401 && tokenId <= 600) {
            return string(abi.encodePacked("https://ipfs.io/ipfs/", CID3, "/Pepe_Maximus_", padTokenId(tokenId), ".json"));
        } else {
            revert("Invalid token ID");
        }
    }

    function padTokenId(uint256 tokenId) internal pure returns (string memory) {
        if (tokenId < 10) {
            return string(abi.encodePacked("000", uint2str(tokenId)));
        } else if (tokenId < 100) {
            return string(abi.encodePacked("00", uint2str(tokenId)));
        } else if (tokenId < 1000) {
            return string(abi.encodePacked("0", uint2str(tokenId)));
        } else {
            return uint2str(tokenId);
        }
    }

    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function findTokenIndex(address ownerAddr, uint256 tokenId) internal view returns (uint256) {
        for (uint256 i = 0; i < ownerTokens[ownerAddr].length; i++) {
            if (ownerTokens[ownerAddr][i] == tokenId) {
                return i;
            }
        }
        revert("Token not found");
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}