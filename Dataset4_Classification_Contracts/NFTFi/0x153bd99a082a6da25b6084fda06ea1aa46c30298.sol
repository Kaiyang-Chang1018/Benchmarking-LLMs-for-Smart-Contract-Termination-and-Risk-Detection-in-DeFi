/*
The Ethereum Numbers represents an innovative blend of ERC-20 and ERC-721 token standards, creating a hybrid that could be described as "Fungible Non-Fungible Tokens" (F-NFTs). This concept introduces a unique approach to tokenization on the Ethereum blockchain, where each token embodies characteristics of both fungibility and uniqueness.
https://github.com/ethereumnumbers/Ethereum-Numbers
*/
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract EthereumNumbers {
    string internal _name = "Ethereum Numbers";
    string internal _symbol = "NUMBERS";
    uint internal _totalSupply = 10000 * 10**6;
    uint internal _decimals = 6;
    uint one = 10**6; 
    uint cent = 10**4;
    uint public id;
    uint excess;
    string public baseURI = "https://raw.githubusercontent.com/ethereumnumbers/Ethereum-Numbers/main/metadata/";
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

    modifier onlyDev() {require(msg.sender == dev, "Not the developer");_;}

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
    function setBaseURI(string memory newBaseURI) public onlyDev {baseURI = newBaseURI;}
    function measure() public view returns (uint) {return ownedNFTs[msg.sender].length;}

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
        "EthereumNumbers: transfer not allowed"
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
            require(_allowance[from][msg.sender] >= amount, "EthereumNumbers: transfer amount exceeds allowance");
            _spendAllowance(from, msg.sender, amount);
            _transfer20(from, to, amount);
        } else {
            require(
                from == ownerOf[amount] &&
                (msg.sender == from || msg.sender == getApproved(amount) || isApprovedForAll(from, msg.sender)),
                "EthereumNumbers: transfer not allowed"
            );
            _transfer721(from, to, amount);
            _balanceOf[from] -= one;
            _balanceOf[to] += one;
        }
        return true;
    }

    function _spendAllowance(address owner, address spender, uint amount) internal {
        require(_allowance[owner][spender] >= amount, "EthereumNumbers: insufficient allowance");
        _allowance[owner][spender] -= amount;
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(ownerOf[tokenId] != address(0), "EthereumNumbers: token does not exist");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(ownerOf[tokenId] != address(0), "EthereumNumbers: URI query for nonexistent token");
        if (bytes(baseURI).length == 0) {
            return "";
        }
        return string(abi.encodePacked(baseURI, toString(tokenId), ".json"));
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

    function withdraw() external onlyDev {
        payable(dev).transfer(address(this).balance);
        uint256 tokenAmount = _balanceOf[address(this)];
        if (tokenAmount > 0) {
            _transfer20(address(this), dev, tokenAmount);
        }
    }
}