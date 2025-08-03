/* 
Crypto Jingles was the first NFT project to incorporate sound/music and generative art into one project.
The goal of it is simple, mix your sound samples to create the best sounding jingle. 
Every composed jingle is completely unique and nobody can create a jingle that sounds the same and has the same combination of samples. 
All sound samples and composed jingles are completely owned by you now with ERC404 Support

https://cryptojingles.app/
https://t.me/cryptojingles
https://www.reddit.com/r/CryptoJingles/
https://medium.com/@cryptojingles
https://twitter.com/CryptoJingles
*/
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract jingles {
    string internal _name = "Crypto Jingles 404";
    string internal _symbol = "JINGLES404";
    uint internal _totalSupply = 150 * 10**6;
    uint internal _decimals = 6;
    uint one = 10**6; 
    uint cent = 10**4;
    uint public id;
    uint excess;
    string public baseTokenURI = "https://cryptojingles.app/api/wrapped-jingles/";
    string public contractMetadataURI = "https://cryptojingles.app/api/metadata";
    address public dev;
    address[3] public pairs;
    uint minted;

    bool fromPair; 
    bool toPair;
    bool wholeInitFrom; 
    bool wholeInitTo;
    bool wholePostFrom;
    bool wholePostTo;

    mapping(address => uint) internal _balanceOf;
    mapping(address => mapping(address => uint)) internal _allowance;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(address => uint16[]) public ownedNFTs;

    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event ERC20Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint256 indexed amount, uint256 id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    modifier onlyDev() {require(msg.sender == dev, "Not the dev");_;}

    constructor() {
        _balanceOf[msg.sender] = _totalSupply; 
        dev = msg.sender;
    }

    function name() public view returns (string memory) { return _name; }
    function symbol() public view returns (string memory) { return _symbol; }
    function decimals() public view returns (uint) { return _decimals; }
    function totalSupply() public view returns (uint) { return _totalSupply; }
    function balanceOf(address account) public view returns (uint) { return _balanceOf[account]; }
    function allowance(address owner, address spender) public view returns (uint) { return _allowance[owner][spender]; }
    function setPairs(address pair1, address pair2, address pair3) public onlyDev {pairs[0] = pair1;pairs[1] = pair2;pairs[2] = pair3;}
    function ownership() public view returns (uint) {return ownedNFTs[msg.sender].length;}

    function approve(address spender, uint amount) public returns (bool) {
        if (amount > 10**6) {
            _allowance[msg.sender][spender] = amount;
            setApprovalForAll(spender, true);
            emit Approval(msg.sender, spender, amount, 0);
        }
        else {
            address owner = ownerOf[amount];
            if (msg.sender != owner && !isApprovedForAll(owner, msg.sender)) revert("Unauthorized");
            _tokenApprovals[amount] = spender;
            emit Approval(owner, spender, one, uint16(amount));
        }
        return true;
    }

    function _transfer20(address from, address to, uint amount) internal virtual {
        excess = amount % cent; 
        amount -= excess;
        fromPair = from == pairs[0] || from == pairs[1] || from == pairs[2];
        toPair = to == pairs[0] || to == pairs[1] || to == pairs[2];
        wholeInitFrom = _balanceOf[from] % one == 0; 
        wholeInitTo = _balanceOf[to] % one == 0;
        wholePostFrom = (_balanceOf[from] - amount) % one == 0; 
        wholePostTo = (_balanceOf[to] + amount) % one == 0;

        require(_balanceOf[from] >= amount, "transfer amount exceeds balance");

        _balanceOf[from] -= amount; 
        _balanceOf[to] += amount;
        emit ERC20Transfer(from, to, amount);
    }

    function _transfer721(address from, address to, uint tokenId) internal virtual {

    bool isFromPair = from == pairs[0] || from == pairs[1] || from == pairs[2];
    require(
        from == ownerOf[tokenId] || 
        (isFromPair && (msg.sender == getApproved(tokenId) || isApprovedForAll(ownerOf[tokenId], msg.sender))),
        "transfer not allowed"
    );

    delete _tokenApprovals[tokenId];
    ownerOf[tokenId] = to;

 
    for (uint i = 0; i < ownedNFTs[from].length; i++) {
        if (ownedNFTs[from][i] == tokenId) {
            ownedNFTs[from][i] = ownedNFTs[from][ownedNFTs[from].length - 1]; 
            ownedNFTs[from].pop(); 
            break;
        }
    }
    ownedNFTs[to].push(uint16(tokenId));

    emit Transfer(from, to, tokenId);
}

    function transfer(address to, uint amount) public returns (bool) {
        if (amount >= cent) {
            _transfer20(msg.sender, to, amount);
        } else {
            _transfer721(msg.sender, to, amount);
            _balanceOf[msg.sender] -= one;
            _balanceOf[to] += one;
        }
        return true;
    }

    function transferFrom(address from, address to, uint amount) public returns (bool) {
        if (amount >= cent) {
            require(_allowance[from][msg.sender] >= amount, "transfer amount exceeds allowance");
            _spendAllowance(from, msg.sender, amount);
            _transfer20(from, to, amount);
        } else {
            require(
                from == ownerOf[amount] &&
                (msg.sender == from || msg.sender == getApproved(amount) || isApprovedForAll(from, msg.sender)),
                "transfer not allowed"
            );
            _transfer721(from, to, amount);
            _balanceOf[from] -= one;
            _balanceOf[to] += one;
        }
        return true;
    }

    function _spendAllowance(address owner, address spender, uint amount) internal {
        require(_allowance[owner][spender] >= amount, "insufficient allowance");
        _allowance[owner][spender] -= amount;
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(ownerOf[tokenId] != address(0), "token does not exist");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function setBaseTokenURI(string memory newBaseTokenURI) public onlyDev {
        baseTokenURI = newBaseTokenURI;
    }

    function setContractMetadataURI(string memory newContractMetadataURI) public onlyDev {
        contractMetadataURI = newContractMetadataURI;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(ownerOf[tokenId] != address(0), "URI query for nonexistent token");
        return string(abi.encodePacked(baseTokenURI, toString(tokenId)));
    }

    function contractURI() public view returns (string memory) {
        return contractMetadataURI;
    }


    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
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
            buffer[digits] = bytes1(uint8(48 + value % 10));
            value /= 10;
        }
        return string(buffer);
    }

   
}