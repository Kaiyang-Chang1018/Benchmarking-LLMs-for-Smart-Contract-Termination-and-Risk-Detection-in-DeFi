//SPDX-License-Identifier: UNLICENSED

/**

 _______  ______ _______           ______  __    __ __    __ 
|       \|      \       \         /      \|  \  |  \  \  |  \
| ▓▓▓▓▓▓▓\\▓▓▓▓▓▓ ▓▓▓▓▓▓▓\     __|  ▓▓▓▓▓▓\ ▓▓  | ▓▓ ▓▓  | ▓▓
| ▓▓__/ ▓▓ | ▓▓ | ▓▓  | ▓▓    |  \ ▓▓ __\▓▓\▓▓\/  ▓▓\▓▓\/  ▓▓
| ▓▓    ▓▓ | ▓▓ | ▓▓  | ▓▓     \▓▓ ▓▓|    \ >▓▓  ▓▓  >▓▓  ▓▓ 
| ▓▓▓▓▓▓▓  | ▓▓ | ▓▓  | ▓▓    _ _| ▓▓ \▓▓▓▓/  ▓▓▓▓\ /  ▓▓▓▓\ 
| ▓▓      _| ▓▓_| ▓▓__/ ▓▓    |  \ ▓▓__| ▓▓  ▓▓ \▓▓\  ▓▓ \▓▓\
| ▓▓     |   ▓▓ \ ▓▓    ▓▓     \▓▓\▓▓    ▓▓ ▓▓  | ▓▓ ▓▓  | ▓▓
 \▓▓      \▓▓▓▓▓▓\▓▓▓▓▓▓▓          \▓▓▓▓▓▓ \▓▓   \▓▓\▓▓   \▓▓
                                                             
                                                             
                                                             
                                                                         
The First GXX contract is an ERC404-compliant token contract deployed on the Ethereum blockchain.

OX404-G         : $GXX
MINT            : gxx.0x33.xyz
GXXNFT          : https://www.0x33.xyz/gxxnft

Staking Ready ∅
Deposit Functionality ∅
Auto-Burn Mechanism ∅
4444 ERC404 Compliant NFT PFP collection ∅
Monthly Rewards ∅ >> read the function Ox33 get access.

Supply : 4444


0.025e per token max 4.
Use GXX function.

**/

// ▄▀▄ ▀▄▀ █▄ █▀█ █▄    ▄▀ 
// ▀▄▀ █ █  █ █▄█  █ ▀▀ ▀▄█

pragma solidity ^0.8.0;

abstract contract Ownable {
    event OwnershipTransferred(address indexed user, address indexed newOwner);
    event TokensDeposited(address indexed from, uint256 amount);

    error Unauthorized();
    error InvalidOwner();

    address public owner;

    modifier onlyOwner() {
    if (msg.sender != owner) revert Unauthorized();

    _;
}

    constructor(address _owner) {
        if (_owner == address(0)) revert InvalidOwner();

        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    function transferOwnership(address _owner) public virtual onlyOwner {
        if (_owner == address(0)) revert InvalidOwner();

        owner = _owner;

        emit OwnershipTransferred(msg.sender, _owner);
    }

    function revokeOwnership() public virtual onlyOwner {
        owner = address(0);

        emit OwnershipTransferred(msg.sender, address(0));
    }
}

abstract contract ERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721Receiver.onERC721Received.selector;
    }
}

abstract contract ERC404 is Ownable {
    event ERC20Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );
    event ERC721Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    error NotFound();
    error AlreadyExists();
    error InvalidRecipient();
    error InvalidSender();
    error UnsafeRecipient();

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    uint256 public immutable totalSupply;

    uint256 public minted;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256[]) internal _owned;

    mapping(uint256 => uint256) internal _ownedIndex;

    mapping(address => bool) public whitelist;

    address public stakingContract;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalNativeSupply,
        address _owner
    ) Ownable(_owner) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalNativeSupply * (10 ** decimals);
    }

    function setWhitelist(address target, bool state) public onlyOwner {
        whitelist[target] = state;
    }

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        owner = _ownerOf[id];

        if (owner == address(0)) {
            revert NotFound();
        }
    }

    function withdrawAll() public onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "Contract balance is zero");
    
    payable(owner).transfer(balance);
    }

    function depositTokens(uint256 amount) public onlyOwner {
    _transfer(msg.sender, address(this), amount);
    
    emit TokensDeposited(msg.sender, amount);
}

    function tokenURI(uint256 id) public view virtual returns (string memory);

    function approve(
    address spender,
    uint256 amountOrId
) public virtual returns (bool) {
    if (amountOrId <= minted && amountOrId > 0) {
        address owner = _ownerOf[amountOrId];

        if (msg.sender != owner && !isApprovedForAll[owner][msg.sender]) {
            revert Unauthorized();
        }

        getApproved[amountOrId] = spender;

        emit Approval(owner, spender, amountOrId);
    } else {
        allowance[msg.sender][spender] = amountOrId;

        emit Approval(msg.sender, spender, amountOrId);
    }

    return true;
}

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
    address from,
    address to,
    uint256 amountOrId
) public virtual {
    if (amountOrId <= minted) {
        if (from != _ownerOf[amountOrId]) {
            revert InvalidSender();
        }

        if (to == address(0)) {
            revert InvalidRecipient();
        }

        if (
            msg.sender != from &&
            !isApprovedForAll[from][msg.sender] &&
            msg.sender != getApproved[amountOrId] &&
            msg.sender != stakingContract 
        ) {
            revert Unauthorized();
        }

        balanceOf[from] -= _getUnit();

        unchecked {
            balanceOf[to] += _getUnit();
        }

        _ownerOf[amountOrId] = to;
        delete getApproved[amountOrId];

        uint256 updatedId = _owned[from][_owned[from].length - 1];
        _owned[from][_ownedIndex[amountOrId]] = updatedId;
        _owned[from].pop();
        _ownedIndex[updatedId] = _ownedIndex[amountOrId];
        _owned[to].push(amountOrId);
        _ownedIndex[amountOrId] = _owned[to].length - 1;

        emit Transfer(from, to, amountOrId);
        emit ERC20Transfer(from, to, _getUnit());
    } else {
        uint256 allowed = allowance[from][msg.sender];

        if (allowed != type(uint256).max)
            allowance[from][msg.sender] = allowed - amountOrId;

        _transfer(from, to, amountOrId);
    }
}

    function transfer(
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        return _transfer(msg.sender, to, amount);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        if (
            to.code.length != 0 &&
            ERC721Receiver(to).onERC721Received(msg.sender, from, id, "") !=
            ERC721Receiver.onERC721Received.selector
        ) {
            revert UnsafeRecipient();
        }
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        if (
            to.code.length != 0 &&
            ERC721Receiver(to).onERC721Received(msg.sender, from, id, data) !=
            ERC721Receiver.onERC721Received.selector
        ) {
            revert UnsafeRecipient();
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 unit = _getUnit();
        uint256 balanceBeforeSender = balanceOf[from];
        uint256 balanceBeforeReceiver = balanceOf[to];

        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        if (!whitelist[from]) {
            uint256 tokens_to_burn = (balanceBeforeSender / unit) -
                (balanceOf[from] / unit);
            for (uint256 i = 0; i < tokens_to_burn; i++) {
                _burn(from);
            }
        }

        if (!whitelist[to]) {
            uint256 tokens_to_mint = (balanceOf[to] / unit) -
                (balanceBeforeReceiver / unit);
            for (uint256 i = 0; i < tokens_to_mint; i++) {
                _mint(to);
            }
        }

        emit ERC20Transfer(from, to, amount);
        return true;
    }

    function _getUnit() internal view returns (uint256) {
        return 10 ** decimals;
    }

    function _mint(address to) internal virtual {
        if (to == address(0)) {
            revert InvalidRecipient();
        }

        unchecked {
            minted++;
        }

        uint256 id = minted;

        if (_ownerOf[id] != address(0)) {
            revert AlreadyExists();
        }

        _ownerOf[id] = to;
        _owned[to].push(id);
        _ownedIndex[id] = _owned[to].length - 1;

        emit Transfer(address(0), to, id);
    }

    function _burn(address from) internal virtual {
        if (from == address(0)) {
            revert InvalidSender();
        }

        uint256 id = _owned[from][_owned[from].length - 1];
        _owned[from].pop();
        delete _ownedIndex[id];
        delete _ownerOf[id];
        delete getApproved[id];

        emit Transfer(from, address(0), id);
    }

    function _setNameSymbol(
        string memory _name,
        string memory _symbol
    ) internal {
        name = _name;
        symbol = _symbol;
    }
}

pragma solidity ^0.8.20;

library Math {
    
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, 
        Ceil, 
        Trunc, 
        Expand 
    }

// ▄▀▄ ▀▄▀ █▄ █▀█ █▄    ▄▀ 
// ▀▄▀ █ █  █ █▄█  █ ▀▀ ▀▄█
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
 
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            return a / b;
        }

        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0 = x * y; 
            uint256 prod1; 
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            if (prod1 == 0) {
                return prod0 / denominator;
            }

            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)

                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }


            uint256 twos = denominator & (0 - denominator);
            assembly {
                denominator := div(denominator, twos)

                prod0 := div(prod0, twos)

                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            uint256 inverse = (3 * denominator) ^ 2;

            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 

            result = prod0 * inverse;
            return result;
        }
    }

// ▄▀▄ ▀▄▀ █▄ █▀█ █▄    ▄▀ 
// ▀▄▀ █ █  █ █▄█  █ ▀▀ ▀▄█


    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 result = 1 << (log2(a) >> 1);

        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

pragma solidity ^0.8.20;

library SignedMath {
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    function average(int256 a, int256 b) internal pure returns (int256) {
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            return uint256(n >= 0 ? n : -n);
        }
    }
}

library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    error StringsInsufficientHexLength(uint256 value, uint256 length);

    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

contract ProcessID is ERC404 {
    uint256 public totalBurned;
    uint256 public lastBurnTime;
    uint256 public burnInterval = 1 days;
    uint256 public burnAmount = 50 * 10**16; 
    string public dataURI;
    string public baseTokenURI;
    string private constant REWARD_URL = "https://www.0x33.xyz/rewards";
    bool public isGXXEnabled;

// ▄▀▄ ▀▄▀ █▄ █▀█ █▄    ▄▀ 
// ▀▄▀ █ █  █ █▄█  █ ▀▀ ▀▄█

    constructor(address _owner)
        ERC404("ProcessID", "GXX", 18, 4444, _owner)
    {
        balanceOf[address(this)] = 2222 * 10**18; // Allocate 1700 tokens to the contract
        balanceOf[_owner] = 2222 * 10**18;
        stakingContract = address(0); // Initialize with address(0) or any default address
        setWhitelist(address(this), true); // Whitelist the contract address
        setWhitelist(_owner, true); // Whitelist the deployer
        setWhitelist(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, true); // WETH
        setWhitelist(0x1F98431c8aD98523631AE4a59f267346ea31F984, true); // Univ3
        isGXXEnabled = false; // Enable GXX by default
        lastBurnTime = block.timestamp;
    }

    function setDataURI(string memory _dataURI) public onlyOwner {
        dataURI = _dataURI;
    }

    function setStakingContract(address _stakingContract) external onlyOwner {
        stakingContract = _stakingContract;
    }

    function withdrawTokens(uint256 amount) public onlyOwner {
    require(balanceOf[address(this)] >= amount, "Insufficient balance");
    
    _transfer(address(this), owner, amount);
    
    emit ERC20Transfer(address(this), owner, amount);
}

    function Ox33(uint256 input) public pure returns (string memory) {
        require(input == 10000000101, "Invalid input");
        return REWARD_URL;
    }

    function toggleGXX() public onlyOwner {
        isGXXEnabled = !isGXXEnabled;
    }

    function setTokenURI(string memory _tokenURI) public onlyOwner {
        baseTokenURI = _tokenURI;
    }

    function autoBurn() external onlyOwner {
    uint256 elapsedTime = block.timestamp - lastBurnTime;
    uint256 intervals = elapsedTime / burnInterval;
    if (intervals > 0) {
        uint256 amountToBurn = intervals * burnAmount;
        balanceOf[address(this)] -= amountToBurn;
        totalBurned += amountToBurn;
        lastBurnTime = block.timestamp;
        emit Transfer(address(this), address(0), amountToBurn);
    }
}

    function GXX(uint256 tokenAmount) public payable {
    require(isGXXEnabled, "GXX function is disabled");
    require(tokenAmount >= 1 && tokenAmount <= 4, "Invalid token amount");
    
    uint256 etherAmount;
    
    if (tokenAmount == 1) {
        etherAmount = 0.025 ether;
    } else if (tokenAmount == 2) {
        etherAmount = 0.05 ether;
    } else if (tokenAmount == 3) {
        etherAmount = 0.075 ether;
    } else if (tokenAmount == 4) {
        etherAmount = 0.1 ether;
    } else {
        revert("Invalid token amount");
    }

    require(msg.value == etherAmount, "Incorrect ether amount for token purchase");

    _transfer(address(this), msg.sender, tokenAmount * _getUnit());

    // Transfer the received ether to the owner of the contract
    payable(owner).transfer(etherAmount);
}

    function tokenURI(uint256 id) public view override returns (string memory) {
    return bytes(baseTokenURI).length > 0 ? string.concat(baseTokenURI, Strings.toString(id), ".json") : "";
}

}