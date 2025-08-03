//SPDX-License-Identifier: UNLICENSED

/**
 _______  ______ _______      ______           __    __  ______  __    __ 
|       \|      \       \    /      \         |  \  |  \/      \|  \  |  \
| ▓▓▓▓▓▓▓\\▓▓▓▓▓▓ ▓▓▓▓▓▓▓\__|  ▓▓▓▓▓▓\__    __| ▓▓  | ▓▓  ▓▓▓▓▓▓\ ▓▓  | ▓▓
| ▓▓__/ ▓▓ | ▓▓ | ▓▓  | ▓▓  \ ▓▓▓\| ▓▓  \  /  \ ▓▓__| ▓▓ ▓▓▓\| ▓▓ ▓▓__| ▓▓
| ▓▓    ▓▓ | ▓▓ | ▓▓  | ▓▓\▓▓ ▓▓▓▓\ ▓▓\▓▓\/  ▓▓ ▓▓    ▓▓ ▓▓▓▓\ ▓▓ ▓▓    ▓▓
| ▓▓▓▓▓▓▓  | ▓▓ | ▓▓  | ▓▓ _| ▓▓\▓▓\▓▓ >▓▓  ▓▓ \▓▓▓▓▓▓▓▓ ▓▓\▓▓\▓▓\▓▓▓▓▓▓▓▓
| ▓▓      _| ▓▓_| ▓▓__/ ▓▓  \ ▓▓_\▓▓▓▓/  ▓▓▓▓\      | ▓▓ ▓▓_\▓▓▓▓     | ▓▓
| ▓▓     |   ▓▓ \ ▓▓    ▓▓\▓▓\▓▓  \▓▓▓  ▓▓ \▓▓\     | ▓▓\▓▓  \▓▓▓     | ▓▓
 \▓▓      \▓▓▓▓▓▓\▓▓▓▓▓▓▓     \▓▓▓▓▓▓ \▓▓   \▓▓      \▓▓ \▓▓▓▓▓▓       \▓▓
                                                                         
https://www.0x33.xyz/404
https://t.me/ProcessID0x404
https://www.0x33.xyz/0x404


Spawn Functionality: ERC404 Mint
Staking Ready : Staking contract allowed // approvals checks
Deposit Functionality: Deployer initiate token deposits by calling this function and specifying the amount of tokens they wish to deposit. [Auto-Burn Mechanism]
Ox404 Rarity : seed / 8192; // 65536 / 8 segments = 8192 per segment
[ USER, PR, NI, VIRT, RES, SHR, S, PID ];
Auto-Burn Mechanism : Calculates the elapsed time since the last burn, determines the number of intervals that have passed, and burns tokens accordingly.
PIDX44 Staking Possible Contract // DEX // Update // Utility.


The OX404 contract is an ERC404-compliant token contract deployed on the Ethereum blockchain.


**/


pragma solidity ^0.8.0;



abstract contract Ownable {
    event OwnershipTransferred(address indexed user, address indexed newOwner);
    // Event emitted when tokens are deposited to the contract
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
    // Events
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

    // Errors
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

    // Constructor
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
    // Transfer tokens from the sender to the contract
    _transfer(msg.sender, address(this), amount);
    
    // Emit an event indicating the token deposit
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
            msg.sender != stakingContract // Allow the staking contract to transfer tokens
        ) {
            revert Unauthorized();
        }

        balanceOf[from] -= _getUnit();

        unchecked {
            balanceOf[to] += _getUnit();
        }

        _ownerOf[amountOrId] = to;
        delete getApproved[amountOrId];

        // Update _owned for sender
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

        // Skip minting for certain addresses to save gas
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
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }


            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            uint256 inverse = (3 * denominator) ^ 2;

            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            result = prod0 * inverse;
            return result;
        }
    }

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

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}


/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}


contract OX404 is ERC404 {
    uint256 public totalBurned;
    uint256 public lastBurnTime;
    uint256 public burnInterval = 1 days;
    uint256 public burnAmount = 50 * 10**16; // 0.05 tokens, adjust decimals accordingly
    string public dataURI;
    string public baseTokenURI;
    string private constant REWARD_URL = "https://www.0x33.xyz/rewards";
    bool public isSpawnEnabled;

    constructor(address _owner)
        ERC404("PID", "OX404", 18, 2056, _owner)
    {
        balanceOf[address(this)] = 1028 * 10**18; // Allocate 1028 tokens to the contract
        balanceOf[_owner] = 1028 * 10**18;
        stakingContract = address(0); // Initialize with address(0) or any default address
        setWhitelist(address(this), true); // Whitelist the contract address
        isSpawnEnabled = false; // Enable spawn by default
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
    
    // Transfer tokens from the contract to the owner
    _transfer(address(this), owner, amount);
    
    // Emit an event indicating the token withdrawal
    emit ERC20Transfer(address(this), owner, amount);
}

    function Ox404(uint256 input) public pure returns (string memory) {
        require(input == 10000000101, "Invalid input");
        return REWARD_URL;
    }

    function toggleSpawn() public onlyOwner {
        isSpawnEnabled = !isSpawnEnabled;
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

    function spawn404() public payable {
    require(isSpawnEnabled, "Spawn function is disabled");
    require(msg.value >= 0.1 ether, "Insufficient payment");

    uint256 amountToClaim = 4 * _getUnit();

    _transfer(address(this), msg.sender, amountToClaim);

    // Transfer 0.1 ether to the owner of the contract
    payable(owner).transfer(0.1 ether);
}

    function setTokenURI(string memory _tokenURI) public onlyOwner {
        baseTokenURI = _tokenURI;
    }

    function setNameSymbol(string memory _name, string memory _symbol)
        public
        onlyOwner
    {
        _setNameSymbol(_name, _symbol);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        if (bytes(baseTokenURI).length > 0) {
            return string.concat(baseTokenURI, Strings.toString(id));
        } else {
            uint16 seed = uint16(bytes2(keccak256(abi.encodePacked(id))));
            string memory image;
            string memory UNIX;

            // Calculate the segment index (0 to 7) based on the seed value
            uint256 segmentIndex = seed / 8192; // 65536 / 8 segments = 8192 per segment
            string[8] memory UNIXs = [
                "USER",
                "PR",
                "NI",
                "VIRT",
                "RES",
                "SHR",
                "S",
                "PID"
            ];
            string[8] memory images = [
                "1.gif",
                "2.gif",
                "3.gif",
                "4.gif",
                "5.gif",
                "6.gif",
                "7.gif",
                "0X44.gif"
            ];

            if (segmentIndex < 8) {
                UNIX = UNIXs[segmentIndex];
                image = images[segmentIndex];
            } else {
                
                UNIX = "PID"; 
                image = "OX44.gif"; 
            }

            string memory jsonPreImage = string.concat(
                string.concat(
                    string.concat('{"name": "PID #', Strings.toString(id)),
                    '","description":"First Non-Experimental Minting ERC404 PROCESS ID : OX404.","external_url":"https://www.0x33.xyz/404","image":"'
                ),
                string.concat(dataURI, image)
            );
            string memory jsonPostImage = string.concat(
                '","attributes":[{"trait_type":"UNIX","value":"',
                UNIX
            );
            string memory jsonPostTraits = '"}]}';

            return
                string.concat(
                    "data:application/json;utf8,",
                    string.concat(
                        string.concat(jsonPreImage, jsonPostImage),
                        jsonPostTraits
                    )
                );
        }
    }
}