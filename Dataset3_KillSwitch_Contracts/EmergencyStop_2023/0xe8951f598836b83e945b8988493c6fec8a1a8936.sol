// Sources flattened with hardhat v2.22.12 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/security/Pausable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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


// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/IERC721.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
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
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

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
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}


// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}


// File contracts/FingerprintsBuyback.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;






contract FingerprintsBuyback is ReentrancyGuard, Ownable, Pausable {
    // Developer: lucaspon
    address public constant DESTINATION_ADDRESS =
        0xbC49de68bCBD164574847A7ced47e7475179C76B;

    uint256 public constant MAX_TOKENS = 5000; // Maximum tokens per wallet
    uint256 public constant MAX_NFTS = 1; // Maximum NFTs per wallet

    mapping(address => uint256) public tokensSwapped;
    mapping(address => uint256) public nftsSwapped;
    mapping(address => bool) public allowlist;

    uint256 public tokenExchangeRate; // Wei per token unit
    uint256 public nftExchangeRate; // Wei per NFT

    IERC20 public token;
    IERC721Enumerable public nft;

    uint8 public tokenDecimals;

    event Swapped(address indexed user, uint256 tokenAmount, uint256 ethAmount);
    event TokensSentToDestination(uint256 tokenAmount);
    event ETHWithdrawn(address indexed owner, uint256 amount);
    event NFTSwapped(address indexed user, uint256 tokenId, uint256 ethAmount);
    event AddressAllowlisted(address indexed user);
    event AddressRemovedFromAllowlist(address indexed user);
    event ExchangeRateUpdated(
        uint256 newTokenExchangeRate,
        uint256 newNftExchangeRate
    );
    event ETHReceived(address indexed sender, uint256 amount);
    event ContractPaused(address indexed owner);
    event ContractUnpaused(address indexed owner);

    constructor(
        address _tokenAddress,
        address _nftAddress,
        uint8 _tokenDecimals,
        address[] memory _defaultAllowlist
    ) {
        token = IERC20(_tokenAddress);
        nft = IERC721Enumerable(_nftAddress);
        tokenDecimals = _tokenDecimals;

        nftExchangeRate = 3.47 ether; // Default exchange rate for NFTs in wei
        tokenExchangeRate = nftExchangeRate / 5000; // Wei per token unit

        require(tokenExchangeRate > 0, "Token exchange rate too low");
        require(nftExchangeRate > 0, "NFT exchange rate too low");

        // Add default addresses to the allowlist
        for (uint256 i = 0; i < _defaultAllowlist.length; i++) {
            allowlist[_defaultAllowlist[i]] = true;
            emit AddressAllowlisted(_defaultAllowlist[i]);
        }
    }

    // Pause contract functions
    function pause() external onlyOwner {
        _pause();
        emit ContractPaused(msg.sender);
    }

    // Unpause contract functions
    function unpause() external onlyOwner {
        _unpause();
        emit ContractUnpaused(msg.sender);
    }

    // Set exchange rate for 1 membership
    function setExchangeRateForOneMembership(
        uint256 _nftExchangeRate
    ) external onlyOwner {
        require(
            _nftExchangeRate > 0,
            "NFT exchange rate must be greater than zero"
        );

        // check if the new exchange rate is different from the current one
        require(
            _nftExchangeRate != nftExchangeRate,
            "New exchange rates must be different from the current ones"
        );

        // cap them at 1000 ETH
        require(
            _nftExchangeRate <= 1000 ether,
            "Exchange rates must be less than or equal to 1000 ETH"
        );

        // require that the new exchange rate is at least 0.01 ETH
        require(
            _nftExchangeRate >= 0.01 ether,
            "Exchange rates must be greater than or equal to 0.01 ETH"
        );

        tokenExchangeRate = _nftExchangeRate / 5000;
        nftExchangeRate = _nftExchangeRate;
        emit ExchangeRateUpdated(tokenExchangeRate, _nftExchangeRate);
    }

    // Swap ERC20 tokens for ETH
    function swapERC20forETH(
        uint256 tokenAmount
    ) external nonReentrant whenNotPaused {
        require(allowlist[msg.sender], "Address not allowlisted");
        require(
            tokensSwapped[msg.sender] + tokenAmount <=
                MAX_TOKENS * (10 ** tokenDecimals),
            "Token swap limit exceeded"
        );
        require(
            nftsSwapped[msg.sender] == 0,
            "NFTs have already been swapped."
        );

        uint256 ethAmount = (tokenAmount * tokenExchangeRate) /
            (10 ** tokenDecimals);

        require(
            address(this).balance >= ethAmount,
            "Not enough ETH in contract"
        );

        // Transfer the tokens from the user to the contract
        bool success = token.transferFrom(
            msg.sender,
            address(this),
            tokenAmount
        );
        require(success, "Token transfer failed");

        // Update state
        tokensSwapped[msg.sender] += tokenAmount;

        // Transfer the ETH to the user
        (success, ) = payable(msg.sender).call{value: ethAmount}("");
        require(success, "ETH transfer failed");

        emit Swapped(msg.sender, tokenAmount, ethAmount);
    }

    // Swap NFT for ETH
    function swapNFTforETH(
        uint256 tokenId
    ) external nonReentrant whenNotPaused {
        require(allowlist[msg.sender], "Address not allowlisted");
        require(nftsSwapped[msg.sender] < MAX_NFTS, "NFT swap limit exceeded");
        require(
            tokensSwapped[msg.sender] == 0,
            "You've already swapped ERC20 tokens."
        );
        require(nft.ownerOf(tokenId) == msg.sender, "You do not own this NFT");

        uint256 ethAmount = nftExchangeRate;

        require(
            address(this).balance >= ethAmount,
            "Not enough ETH in contract to swap NFT."
        );

        // Transfer the NFT from the user to the contract
        nft.transferFrom(msg.sender, address(this), tokenId);

        // Update state
        nftsSwapped[msg.sender] += 1;

        // Transfer the ETH to the user
        (bool success, ) = payable(msg.sender).call{value: ethAmount}("");
        require(success, "ETH transfer failed");

        emit NFTSwapped(msg.sender, tokenId, ethAmount);
    }

    // Allow ETH deposits with event emission
    receive() external payable {
        emit ETHReceived(msg.sender, msg.value);
    }

    // Send all contract tokens and NFTs to the destination address
    function sendTokensToDestination() external nonReentrant {
        uint256 contractTokenBalance = token.balanceOf(address(this));
        // require a balance of either tokens or NFTs to send
        require(
            contractTokenBalance > 0 || nft.balanceOf(address(this)) > 0,
            "No tokens or NFTs to send"
        );

        // Transfer all tokens to the destination address
        token.transfer(DESTINATION_ADDRESS, contractTokenBalance);

        // Transfer all NFTs to the destination address
        uint256 nftBalance = nft.balanceOf(address(this));

        if (nftBalance == 0) {
            emit TokensSentToDestination(contractTokenBalance);
            return;
        } else if (nftBalance >= 1) {
            for (uint256 i = 0; i < nftBalance; i++) {
                uint256 tokenId = nft.tokenOfOwnerByIndex(address(this), 0);
                nft.transferFrom(address(this), DESTINATION_ADDRESS, tokenId);
            }
        }
    }

    // Withdraw ETH from the contract to the owner's address
    function withdrawETH(uint256 amount) external onlyOwner nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        require(address(this).balance >= amount, "Not enough ETH in contract");

        // if amount provided is zero or null, withdraw the entire balance
        if (amount == 0) {
            amount = address(this).balance;
        }

        // Transfer the ETH to the owner
        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "ETH transfer failed");

        emit ETHWithdrawn(owner(), amount);
    }

    // Add an address to the allowlist
    function addToAllowlist(address _address) external onlyOwner {
        require(_address != address(0), "Invalid address");
        require(!allowlist[_address], "Address already allowlisted");

        allowlist[_address] = true;
        emit AddressAllowlisted(_address);
    }

    // Remove an address from the allowlist
    function removeFromAllowlist(address _address) external onlyOwner {
        require(allowlist[_address], "Address not in allowlist");

        allowlist[_address] = false;
        emit AddressRemovedFromAllowlist(_address);
    }

    // Set multiple addresses in the allowlist
    function setAllowlist(address[] calldata _addresses) external onlyOwner {
        require(_addresses.length > 0, "No addresses provided");

        // Note: This approach does not delete previous mappings but updates the allowlist efficiently
        for (uint256 i = 0; i < _addresses.length; i++) {
            if (_addresses[i] != address(0)) {
                allowlist[_addresses[i]] = true;
                emit AddressAllowlisted(_addresses[i]);
            }
        }
    }

    // Return whether an address is allowlisted
    function isAllowlisted(address _address) external view returns (bool) {
        return allowlist[_address];
    }

    // Refuse to receive NFTs sent directly to the contract
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        revert("NFTs not accepted without a swap");
    }

    //  Recover ERC20 tokens sent directly to the contract
    function recoverERC20Tokens(
        address tokenAddress,
        uint256 tokenAmount
    ) external onlyOwner {
        // Require the contract to own the tokens
        require(
            IERC20(tokenAddress).balanceOf(address(this)) >= tokenAmount,
            "Contract does not own the tokens you want to recover"
        );
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }

    // Recover ERC721 tokens sent directly to the contract
    function recoverERC721Tokens(
        address tokenAddress,
        uint256 tokenId
    ) external onlyOwner {
        IERC721(tokenAddress).safeTransferFrom(address(this), owner(), tokenId);
    }
}