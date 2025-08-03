//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

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

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
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
}

library Address {

    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

}

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

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

contract DiamondBoardingPass is Context, ERC165, IERC721, IERC721Metadata, Ownable, ReentrancyGuard {

    using Address for address;

    // Token name
    string private constant _name = "Diamond Boarding Pass";

    // Token symbol
    string private constant _symbol = "DIAMOND";

    // Precision Value For Rewards
    uint256 private constant precision = 10**6;

    // total number of NFTs Minted
    uint256 private _totalSupply;

    // NFT Structure
    struct Token {
        address owner;
        uint256 membershipExpirationDate;
        uint256 stakeBountyAmount;
        bool isStaked;
        uint256 totalExcluded;
        bool isWavedFromFee;
    }

    // Mapping from token ID to owner address
    mapping(uint256 => Token) public tokens;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping owner address to their specific tokenId
    mapping(address => uint256) private IDForOwner;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Mapping for whitelist
    mapping ( address => bool ) public isWhitelisted;

    // Whitelist enabled toggle
    bool public whitelistEnabled;

    // base URI
    string private baseURI = "";
    string private ending = ".json";

    // Enable Trading
    uint256 public mintCap;

    // membership activation cost
    uint256 public membershipCost;

    // Duration of Membership
    uint256 public membershipDuration = 30 days;

    // Membership Token
    address public membershipToken;

    // Membership Payment Recipient
    address public membershipRecipient;

    // Security Deposit Cost
    uint256 public securityDepositCost;

    // Total Number Of NFTs In the Contract
    uint256 public totalStaked;

    // dividends per staked nft
    uint256 public dividendsPerNFT;

    // reward token
    address public immutable rewardToken;

    // total rewards paid out in `rewardToken`
    uint256 public totalRewards;

    constructor(
        address membershipRecipient_,
        address membershipToken_,
        address rewardToken_,
        uint256 membershipCost_,
        uint256 securityDepositCost_
    ) { 
        require(
            membershipRecipient_ != address(0),
            'Cannot Have No Recipient'
        );
        require(
            membershipCost_ > 0,
            'Cannot Have No Cost'
        );
        require(
            rewardToken_ != address(0),
            'Zero Reward Token'
        );
        membershipRecipient = membershipRecipient_;
        membershipToken = membershipToken_;
        membershipCost = membershipCost_;
        rewardToken = rewardToken_;
        securityDepositCost = securityDepositCost_;
    }

    ////////////////////////////////////////////////
    ///////////   RESTRICTED FUNCTIONS   ///////////
    ////////////////////////////////////////////////

    function setMintCap(uint newCap) external onlyOwner {
        mintCap = newCap;
    }

    function setWhitelistEnabled(bool enabled) external onlyOwner {
        whitelistEnabled = enabled;
    }

    function setWaiveFromFee(uint256 tokenId, bool isWaived) external onlyOwner {
        tokens[tokenId].isWavedFromFee = isWaived;
    }

    function setIsWhitelisted(address[] calldata users, bool isWhitelisted_) external onlyOwner {
        uint len = users.length;
        for (uint i = 0; i < len;) {
            isWhitelisted[users[i]] = isWhitelisted_;
            unchecked { ++i; }
        }
    }

    function withdrawNative(uint256 amount) external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: amount}("");
        require(s);
    }

    function withdrawToken(address token_, uint256 amount) external onlyOwner {
        require(token_ != address(0), 'Zero Address');
        IERC20(token_).transfer(msg.sender, amount);
    }

    function setMembershipCost(uint256 newCost) external onlyOwner {
        require(
            newCost > 0,
            'Cannot Have No Cost'
        );
        membershipCost = newCost;
    }

    function setBaseURI(string calldata newURI) external onlyOwner {
        baseURI = newURI;
    }

    function setURIExtention(string calldata newExtention) external onlyOwner {
        ending = newExtention;
    }

    function setMembershipDuration(uint numDays) external onlyOwner {
        require(
            numDays > 0,
            'Cannot Have Zero Day Stake Time'
        );
        membershipDuration = numDays * 1 days;
    }

    /**
        Setting `token` to address(0) will turn it into native ETH for payments instead of an ERC20
     */
    function setMembershipToken(address token) external onlyOwner {
        membershipToken = token;
    }

    function setSecurityDepositCost(uint256 newCost) external onlyOwner {
        securityDepositCost = newCost;
    }

    function claimFor(address user) external onlyOwner {
        _claim(user);
    }

    ////////////////////////////////////////////////
    ///////////     PUBLIC FUNCTIONS     ///////////
    ////////////////////////////////////////////////

    /**
        Stakes the Membership NFT associated with `msg.sender`
     */
    function stake() external payable nonReentrant {
        require(
            hasMembershipNFT(msg.sender),
            'Must Own Membership NFT'
        );
        require(
            msg.value >= securityDepositCost,
            'Insufficient Cost Supplied'
        );
        uint256 tokenId = getTokenIDForOwner(msg.sender);
        require(
            tokenId < ~uint256(0),
            'ID Out Of Bounds'
        );
        require(
            !tokens[tokenId].isStaked,
            'Already Staked'
        );
        require(
            isMembershipActive(tokenId),
            'Membership Not Activated'
        );

        // set stake bounty amount
        tokens[tokenId].stakeBountyAmount = securityDepositCost;

        // set is staked
        tokens[tokenId].isStaked = true;

        // increase total number of NFTs staked
        unchecked {
            ++totalStaked;
        }

        // set their total excluded
        tokens[tokenId].totalExcluded = getTotalExcluded();
    }

    function claim() external nonReentrant {
        _claim(msg.sender);
    }

    function unstake() external nonReentrant {
        require(
            hasMembershipNFT(msg.sender),
            'No Membership NFT'
        );
        uint256 tokenId = getTokenIDForOwner(msg.sender);
        require(
            tokenId < _totalSupply,
            'ID Out Of Bounds'
        );
        require(
            tokens[tokenId].isStaked,
            'Not Staked'
        );
        
        // fetch bounty
        uint256 bounty = tokens[tokenId].stakeBountyAmount;

        // remove bounty to protect against reentrancy
        delete tokens[tokenId].stakeBountyAmount;

        // unstake user's token Id
        _unstake(tokenId);

        // send bounty to caller
        if (bounty > 0) {
            (bool s,) = payable(msg.sender).call{value: bounty}("");
            require(s, 'Transfer Failed');
        }
    }

    function kickOutForBounty(uint256 tokenId) external nonReentrant {

        // ensure tokenId is active
        require(
            tokenId < _totalSupply,
            'ID Out Of Bounds'
        );
        require(
            isMembershipActive(tokenId) == false,
            'Membership Is Still Active'
        );
        require(
            tokens[tokenId].isStaked,
            'User Not Staked'
        );

        // fetch bounty
        uint256 bounty = tokens[tokenId].stakeBountyAmount;

        // remove bounty to protect against reentrancy
        delete tokens[tokenId].stakeBountyAmount;

        // unstake user's token Id
        _unstake(tokenId);

        // send bounty to caller
        if (bounty > 0) {
            (bool s,) = payable(msg.sender).call{value: bounty}("");
            require(s, 'Transfer Failed');
        }
    }

    function addRewards(uint256 amount) external nonReentrant {
        require(
            totalStaked > 0,
            'Zero Rewards To Give Out'
        );
        uint256 received = _transferIn(rewardToken, amount);
        unchecked {
            dividendsPerNFT += (received * precision) / totalStaked;
            totalRewards += received;
        }
    }

    /** 
     * Mints `numberOfMints` NFTs To Caller
     */
    function mint() external nonReentrant {
        if (whitelistEnabled) {
            require(
                isWhitelisted[msg.sender],
                'User Not Whitelisted'
            );
        }
        require(
            _totalSupply < mintCap,
            'Trading Not Enabled'
        );
        require(
            balanceOf(msg.sender) == 0, 
            'Cannot Own More Than 1'
        );
        _safeMint(msg.sender, _totalSupply);
    }

    /**
        Allows user to pay membership
     */
    function payMembership(uint256 tokenId, uint256 nMonths) external payable nonReentrant {
        require(
            nMonths > 0,
            'Cannot Pay Zero Months'
        );

        // ensure tokenId is valid
        require(
            tokenId < _totalSupply, 
            'Invalid Id'
        );

        // save gas, define cost
        uint256 cost = nMonths * membershipCost;

        if (membershipToken == address(0)) {
            require(
                msg.value >= cost,
                'Incorrect Amount'
            );
            (bool s,) = payable(membershipRecipient).call{value: msg.value}("");
            require(s);
        } else {
            require(
                msg.value == 0,
                'Zero Cost'
            );

            // ensure the user has enough tokens for the membership
            require(
                IERC20(membershipToken).balanceOf(msg.sender) >= cost,
                'Insufficient Balance'
            );
            require(
                IERC20(membershipToken).allowance(msg.sender, address(this)) >= cost,
                'Insufficient Allowance'
            );

            // burn the necessary amount of tokens
            require(
                IERC20(membershipToken).transferFrom(msg.sender, membershipRecipient, cost),
                'Failure to burn tokens'
            );
        }

        // update state
        tokens[tokenId].membershipExpirationDate = block.timestamp + ( nMonths * membershipDuration );
    }


    receive() external payable {}



    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public override {
        address wpowner = ownerOf(tokenId);
        require(to != wpowner, "ERC721: approval to current owner");

        require(
            _msgSender() == wpowner || isApprovedForAll(wpowner, _msgSender()),
            "ERC721: not approved or owner"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address _operator, bool approved) public override {
        _setApprovalForAll(_msgSender(), _operator, approved);
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "caller not owner nor approved");
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "caller not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }


    ////////////////////////////////////////////////
    ///////////     READ FUNCTIONS       ///////////
    ////////////////////////////////////////////////

    function canKickOutId(uint256 tokenId) public view returns (bool) {
        return tokens[tokenId].isStaked && isMembershipActive(tokenId) == false && tokenId < _totalSupply;
    }

    function canKickOutUser(address user) public view returns (bool) {
        return canKickOutId(getTokenIDForOwner(user));
    }

    function listOfUsersToKick() external view returns (address[] memory) {
        // get length of array
        uint lengthOfList;
        for (uint i = 0; i < _totalSupply;) {
            if (tokens[i].isStaked && isMembershipActive(i) == false) {
                unchecked {
                    ++lengthOfList;
                }
            }
            unchecked { ++i; }
        }

        // instantiate array
        address[] memory list = new address[](lengthOfList);
        uint count;
        for (uint i = 0; i < _totalSupply;) {
            if (tokens[i].isStaked && isMembershipActive(i) == false) {
                list[count] = tokens[i].owner;
                unchecked { ++count; }
            }
            unchecked { ++i; }
        }

        // return list
        return list;
    }

    function listOfIDsToKick() external view returns (uint256[] memory) {

        // get length of array
        uint lengthOfList;
        for (uint i = 0; i < _totalSupply;) {
            if (tokens[i].isStaked && isMembershipActive(i) == false) {
                unchecked {
                    ++lengthOfList;
                }
            }
            unchecked { ++i; }
        }

        // instantiate array
        uint256[] memory list = new uint256[](lengthOfList);
        uint count;
        for (uint i = 0; i < _totalSupply;) {
            if (tokens[i].isStaked && isMembershipActive(i) == false) {
                list[count] = i;
                unchecked { ++count; }
            }
            unchecked { ++i; }
        }

        // return list
        return list;
    }

    function paginatedListOfIDsToKick(uint256 startIndex, uint256 endIndex) external view returns (uint256[] memory) {

        // get length of array
        uint lengthOfList;
        for (uint i = startIndex; i < endIndex;) {
            if (canKickOutId(i)) {
                unchecked {
                    ++lengthOfList;
                }
            }
            unchecked { ++i; }
        }

        // instantiate array
        uint256[] memory list = new uint256[](lengthOfList);
        uint count;
        for (uint i = startIndex; i < endIndex;) {
            if (canKickOutId(i)) {
                list[count] = i;
                unchecked { ++count; }
            }
            unchecked { ++i; }
        }

        // return list
        return list;
    }

    function paginatedListOfUsersToKick(uint256 startIndex, uint256 endIndex) external view returns (address[] memory) {

        // get length of array
        uint lengthOfList;
        for (uint i = startIndex; i < endIndex;) {
            if (canKickOutId(i)) {
                unchecked {
                    ++lengthOfList;
                }
            }
            unchecked { ++i; }
        }

        // instantiate array
        address[] memory list = new address[](lengthOfList);
        uint count;
        for (uint i = startIndex; i < endIndex;) {
            if (canKickOutId(i)) {
                list[count] = tokens[i].owner;
                unchecked { ++count; }
            }
            unchecked { ++i; }
        }

        // return list
        return list;
    }

    function pendingRewards(uint256 tokenId) public view returns (uint256) {
        if (tokens[tokenId].isStaked == false) {
            return 0;
        }
        uint256 tExcluded = getTotalExcluded();
        uint256 userExcluded = tokens[tokenId].totalExcluded;
        return tExcluded > userExcluded ? tExcluded - userExcluded : 0;
    }

    function getTotalExcluded() public view returns (uint256) {
        return dividendsPerNFT / precision;
    }

    function isUserMembershipActive(address user) public view returns (bool) {
        if (!hasMembershipNFT(user)) {
            return false;
        }
        return isMembershipActive(IDForOwner[user]);
    }

    function isMembershipActive(uint256 tokenId) public view returns (bool) {
        return tokens[tokenId].membershipExpirationDate >= block.timestamp || tokens[tokenId].isWavedFromFee;
    }

    function timeUntilMembershipExpires(uint256 tokenId) external view returns (uint256) {
        uint expiration = tokens[tokenId].membershipExpirationDate;
        return expiration > block.timestamp ? expiration - block.timestamp : 0;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function getTokenIDForOwner(address user) public view returns (uint256) {
        return hasMembershipNFT(user) ? IDForOwner[user] : ~uint256(0);
    }

    function hasMembershipNFT(address user) public view returns (bool) {
        return tokens[IDForOwner[user]].owner == user && user != address(0);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address wpowner) public view override returns (uint256) {
        require(wpowner != address(0), "query for the zero address");
        return _balances[wpowner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address wpowner = tokens[tokenId].owner;
        require(wpowner != address(0), "query for nonexistent token");
        return wpowner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public pure override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "nonexistent token");

        string memory fHalf = string.concat(baseURI,
            isMembershipActive(tokenId) ? '1' : '0'
        );
        return string.concat(fHalf, ending);
    }

    /**
        Converts A Uint Into a String
    */
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
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
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address wpowner, address _operator) public view override returns (bool) {
        return _operatorApprovals[wpowner][_operator];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return tokens[tokenId].owner != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: nonexistent token");
        address wpowner = ownerOf(tokenId);
        return (spender == wpowner || getApproved(tokenId) == spender || isApprovedForAll(wpowner, spender));
    }

    ////////////////////////////////////////////////
    ///////////    INTERNAL FUNCTIONS    ///////////
    ////////////////////////////////////////////////

    function _claim(address user) internal {
        require(
            hasMembershipNFT(user),
            'Must Own Membership NFT'
        );

        // fetch token id for caller
        uint256 tokenId = getTokenIDForOwner(user);
        require(
            tokenId < _totalSupply,
            'ID Out Of Bounds'
        );
        require(
            tokens[tokenId].isStaked,
            'Not Staked'
        );

        // fetch pending rewards
        uint256 pending = pendingRewards(tokenId);
        require(
            pending > 0,
            'Zero Rewards'
        );

        // reset reward value
        tokens[tokenId].totalExcluded = getTotalExcluded();

        // send pending reward to user
        _sendRewards(user, pending);
    }

    function _sendRewards(address to, uint256 amount) internal {
        uint bal = IERC20(rewardToken).balanceOf(address(this));
        if (amount > bal) {
            amount = bal;
        }
        if (amount == 0) {
            return;
        }
        IERC20(rewardToken).transfer(to, amount);
    }

    function _unstake(uint256 tokenId) internal {

        // claim all pending rewards
        uint256 pending = pendingRewards(tokenId);
        require(
            pending > 0,
            'Zero Rewards'
        );

        // set is staked to false
        delete tokens[tokenId].isStaked;

        // decrease total number of NFTs staked
        unchecked {
            --totalStaked;
        }

        // send pending reward to user
        _sendRewards(tokens[tokenId].owner, pending);
    }

    function _transferIn(address token, uint256 amount) internal returns (uint256) {
        // ensure the user has enough tokens to transfer
        require(
            IERC20(token).balanceOf(msg.sender) >= amount,
            'Insufficient Balance'
        );
        require(
            IERC20(token).allowance(msg.sender, address(this)) >= amount,
            'Insufficient Allowance'
        );

        // note the balance before
        uint256 before = IERC20(token).balanceOf(address(this));
        // transfer the necessary amount of tokens
        require(
            IERC20(token).transferFrom(msg.sender, address(this), amount),
            'Failure to burn tokens'
        );
        return IERC20(token).balanceOf(address(this)) - before;
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId
    ) internal {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, ""),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal {
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            _balances[to]++;
            _totalSupply++;
        }
        tokens[tokenId].owner = to;
        IDForOwner[to] = tokenId;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: non ERC721Receiver implementer");
    }


    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(ownerOf(tokenId) == from, "Incorrect owner");
        require(to != address(0), "zero address");
        require(balanceOf(from) > 0, 'Zero Balance');
        require(balanceOf(to) == 0, 'Cannot Own More Than 1');

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        // Allocate balances
        unchecked {
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        tokens[tokenId].owner = to;

        // remap address to id mapping
        delete IDForOwner[from];
        IDForOwner[to] = tokenId;

        // emit transfer
        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address wpowner,
        address _operator,
        bool approved
    ) internal {
        require(wpowner != _operator, "ERC721: approve to caller");
        _operatorApprovals[wpowner][_operator] = approved;
        emit ApprovalForAll(wpowner, _operator, approved);
    }

    function onReceivedRetval() public pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}