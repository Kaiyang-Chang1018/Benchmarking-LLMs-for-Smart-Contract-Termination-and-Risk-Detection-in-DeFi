pragma solidity ^0.8.19;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.19;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

// File: rabbit/ArtistRabbitBoxNFT.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


interface IERC721 {
    function mintBatch(address to, uint256[] memory ids) external;
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract ArtistRabbitBoxNft is Ownable(msg.sender) {
    constructor() {}

    event Bet(
        uint256 indexed bet,
        uint256 amount,
        address indexed account,
        uint256 rabbitboxID,
        uint256 nonce,
        address artist,
        address tokenAddress
    );
    event Claim(uint256 indexed bet, address indexed account, address artist);
    event SetNftLimit(address indexed account, uint256 limit);
    event SetAuthAddress(address indexed account, address _address);
    event SetRabbitLimit(
        address indexed account,
        uint256 rabbitBoxId,
        uint256 rabbitTokens
    );

   
    address public authAddress;

    uint256 public totalBets = 3276;
    mapping(uint256 => address) public claimedBet;
    mapping(uint256 => uint256) public claimedBetAmount;
    mapping(uint256 => uint256) public rabbitLimit;
    mapping(address => uint256) public limitPerDrop;
    mapping(address => mapping(address => uint256)) public totalPurchased;

    function submitBet(
        uint256 rabbitboxID,
        uint256 price,
        address payable artist,
        uint256 bets,
        uint256 betLimit,
        address tokenAddress,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable {
        require(bets > 0, "Must place bets");
        require(bets <= betLimit, "Invalid bet count");
        if (limitPerDrop[artist] > 0) {
            require(
                totalPurchased[artist][_msgSender()] + (bets) <=
                    limitPerDrop[artist],
                "Exceeded user limit"
            );
        }
   
        bytes32 hash = keccak256(
            abi.encodePacked(rabbitboxID, price, betLimit, tokenAddress)
        );
   
        address signer = ecrecover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            hash
                        )
                    ),
                    v,
                    r,
                    s
                );
        require(signer == artist, "Invalid Signature");

        if (tokenAddress == address(0)) {
            require(msg.value == price * (bets), "Invalid amount");
            uint256 cost = price * (bets);
            artist.transfer(cost);
        } else {
            IERC20(tokenAddress).transferFrom(
                _msgSender(),
                address(this),
                price * (bets)
            );
        }

        totalBets = totalBets + (1);
        claimedBet[totalBets] = _msgSender();
        claimedBetAmount[totalBets] = bets;
        emit Bet(
            totalBets,
            bets,
            _msgSender(),
            rabbitboxID,
            0,
            artist,
            tokenAddress
        );
        totalPurchased[artist][_msgSender()] = totalPurchased[artist][
            _msgSender()
        ] + (bets);
    }

    function redeemBulk(
        address nftAsset,
        uint256[] calldata id,
        uint256[] calldata nftAmount,
        address artist,
        uint256 bet,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(claimedBet[bet] == _msgSender(), "Invalid bet");
        bytes32 hash = keccak256(
            abi.encodePacked(nftAsset, id, nftAmount, bet, artist)
        );
        address signer = ecrecover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            hash
                        )
                    ),
                    v,
                    r,
                    s
                );
        require(signer == authAddress, "Invalid signature");
        claimedBet[bet] = address(0);
        IERC721(nftAsset).mintBatch(_msgSender(), id);
        emit Claim(bet, _msgSender(), artist);
    }

    function setAuthAddress(address _address) external onlyOwner {
        require(_address != address(0));
        authAddress = _address;
        emit SetAuthAddress(_msgSender(), _address);
    }

    function setRabbitLimit(uint256 rabbitBoxId, uint256 rabbitTokens)
        external
        onlyOwner
    {
        rabbitLimit[rabbitBoxId] = rabbitTokens;
        emit SetRabbitLimit(_msgSender(), rabbitBoxId, rabbitTokens);
    }

    function getRabbitLimit()
        external
        view
        returns (
            uint256 _rabbitboxId1,
            uint256 _rabbitboxId2,
            uint256 _rabbitboxId3,
            uint256 _rabbitboxId4
        )
    {
        return (
            rabbitLimit[1],
            rabbitLimit[2],
            rabbitLimit[3],
            rabbitLimit[4]
        );
    }

    function setNftLimit(uint256 limit) public {
        limitPerDrop[_msgSender()] = limit;
        emit SetNftLimit(_msgSender(), limit);
    }

}