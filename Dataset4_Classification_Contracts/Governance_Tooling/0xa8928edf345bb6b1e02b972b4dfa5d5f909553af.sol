// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

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

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {    
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

// Petition contract inheriting from ReentrancyGuard to prevent reentrant calls
contract Petition is ReentrancyGuard {
    // Events for logging various state changes in the contract
    event PetitionInfoSet(uint256 indexed slot, string value);
    event PetitionGoalSet(uint256 value);
    event PetitionActiveSet(bool flag);
    event PetitionSigned(address indexed signer);
    event TokenRequireBalanceUpdated(uint256 requiredBalance);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ERC721Transferred(address indexed tokenContract, address indexed to, uint256 indexed tokenId);
    event PetitionInitialized(address indexed owner, uint256 requiredSigningTokenBalance, address signingToken, string title, string subtitle, string to, string petition, uint256 goalSignature);
    
    // State variables
    bool public active = false; // Indicates if the petition is active
    address public contractOwner; // Owner of the contract
    string public title; // Title of the petition
    string public subtitle; // Subtitle of the petition
    uint256 public started; // Timestamp of when the petition started
    string public to; // Intended recipient of the petition
    string public petition; // Content of the petition
    uint256 public requiredSigningTokenBalance; // Token balance required to sign the petition
    address public signingToken; // Address of the token used for signing
    uint256 public goalSignature; // Number of signatures required to achieve the goal
    mapping(address => bool) public hasSigned; // Tracks whether an address has signed the petition
    
    // Modifier to restrict function access to the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only contract owner can call this function");
        _;
    }
    
    // Constructor to initialize the contract with given parameters
    constructor(
        uint256 _requiredSigningTokenBalance,
        address _signingToken,
        string memory _title,
        string memory _subtitle,
        string memory _to,
        string memory _petition,
        uint256 _goalSignature
    ) {
        contractOwner = msg.sender; // Set the contract creator as the owner
        started = block.timestamp; // Set the start time to the current block timestamp
        signingToken = _signingToken; // Set the token used for signing
        requiredSigningTokenBalance = _requiredSigningTokenBalance; // Set the required token balance for signing
        title = _title; // Set the petition title
        subtitle = _subtitle; // Set the petition subtitle
        to = _to; // Set the petition recipient (comma separate multiple recipients)
        petition = _petition; // Set the petition content
        goalSignature = _goalSignature; // Set the signature goal
        emit PetitionInitialized(msg.sender, _requiredSigningTokenBalance, _signingToken, _title, _subtitle, _to, _petition, _goalSignature);
    }
    
    // Function to update petition information, restricted to the owner
    function setPetitionInfo(uint256 _slot, string memory _value) external onlyOwner {
        require(_slot < 4, "Unknown Slot"); // Ensure slot is valid
        if (_slot == 0) {
            title = _value; // Update title
        } else if (_slot == 1) {
            subtitle = _value; // Update subtitle
        } else if (_slot == 2) {
            to = _value; // Update recipient
        } else if (_slot == 3) {
            petition = _value; // Update petition content
        }
        emit PetitionInfoSet(_slot, _value); // Log the update
    }
    
    // Function to set the petition goal, restricted to the owner
    function setPetitionGoal(uint256 _value) external onlyOwner {
        goalSignature = _value; // Update the signature goal
        emit PetitionGoalSet(_value); // Log the update
    }
    
    // Function to activate or deactivate the petition, restricted to the owner
    function setPetitionActive(bool _active) external onlyOwner {
        require(active != _active, "Already Updated"); // Check if the status is actually changing
        active = _active; // Update the active status
        emit PetitionActiveSet(_active); // Log the update
    }
    
    // Function to sign the petition, ensuring the signer has sufficient token balance
    function signPetition() external nonReentrant {
        require(active, "Petition is not active"); // Ensure the petition is active
        require(!hasSigned[msg.sender], "Already signed"); // Check if the signer hasn't already signed
        bool hasSufficientBalance = IERC20(signingToken).balanceOf(msg.sender) >= requiredSigningTokenBalance;
        require(hasSufficientBalance, "Insufficient token balance"); // Ensure signer has sufficient tokens
        hasSigned[msg.sender] = true; // Mark as signed
        emit PetitionSigned(msg.sender); // Log the signing
    }
    
    // Function to update the required token balance for signing, restricted to the owner
    function updateTokenRequireBalance(uint256 _requiredBalance) external onlyOwner {
        requiredSigningTokenBalance = _requiredBalance; // Update the required balance
        emit TokenRequireBalanceUpdated(_requiredBalance); // Log the update
    }
    
    // Function to transfer ownership of the contract, restricted to the owner
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner address"); // Ensure the new owner address is valid
        address previousOwner = contractOwner; // Store the current owner
        contractOwner = newOwner; // Update the owner
        emit OwnershipTransferred(previousOwner, newOwner); // Log the transfer
    }
    
    // Function to transfer an ERC721 token owned by the contract, restricted to the owner
    function transferERC721(address _tokenContract, address _to, uint256 _tokenId) external onlyOwner {
        require(IERC721(_tokenContract).ownerOf(_tokenId) == address(this), "Contract does not own the token");
        IERC721(_tokenContract).safeTransferFrom(address(this), _to, _tokenId); // Transfer the token
        emit ERC721Transferred(_tokenContract, _to, _tokenId); // Log the transfer
    }
}