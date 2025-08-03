// SPDX-License-Identifier: UNLICENSED 
// CopyRight MetallisCrypta.io, ALL RIGHTS RESERVED 2021-2024
pragma solidity 0.8.20;


// Flattened wMetallis Contract

//**************************************   Interfaces  *****************************************//


interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);    
    function transfer(address recipient, uint256 amount) external returns (bool success); 
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
    function allowance(address sender, address spender) external view returns (uint256 remaining);
}

interface Imultisig {
    function pause() external returns (bool);
    function unPause() external returns (bool);
    function authorizeContract(address _contract) external;
    function revokeContract(address _contract) external;
    function addMultisigWallet(address _wallet) external;
    function removeMultisigWallet(address _wallet) external;
    function initiateProposal(
        string memory _proposalName, 
        bytes memory _proposalFunction, 
        address _proposalContract,
        uint _requiredVotes, 
        uint _duration
        ) external returns (uint proposalId);
    function voteOnProposal(uint _proposalId, bool _vote) external;
  
}

interface ImetallisMain {
    function purchasewMetallis(address _buyer, string memory _tokenName, uint256 _tokenAmount) external returns (bool);
    function setMultisigContract(address _multisigContract) external returns (address);
    function addToWhitelist(address _address) external;
    function updatePurchaseTokens(string memory _tokenName, ERC20 _tokenAddress, uint _decimals, uint _weiDiff, bool _active) external;
    function updatewMetallisPrice(string memory _tokenName, ERC20 _tokenAddress, uint256 _wMetallisPrice) external;
    function pauseContract(bool _status) external returns (bool);
    function getMultisigContract() external view returns (Imultisig, address);
    function getwMetallisContract() external view returns(IwMetallis, address);
    function getwMetallisPrice(string memory _tokenName) external view returns (uint256);
    function isWhitelisted() external view returns (bool);
    function isAddressWhitelisted(address _whitelistAddress) external  view returns (bool);
    function isPurchaseTokenActive(string memory tokenName) external view returns (bool);
    function contractTokenBalances(string memory _tokenName) external view returns (uint256, uint256);
    function wMetallisMintedBalance() external view returns(uint256);
    function withdrawFunds(address tokenAddress, uint256 amount) external payable returns (bool success);
    function transferOwnership(address newOwner) external returns (address);
    function setTreasuries(string memory _treasuryName, address _treasuryAddress, uint _rate) external;

}

interface IwMetallis {
    // Custom functions specific to the wMetallis contract
    function distributeTokens(address buyer, uint256 wMetallisAmount) external returns (bool);
    function pause() external;
    function unPause() external;
    function pauseStatus() external view returns (bool);
    function setMultisigContract(address _multisigContract) external returns(address multisig);
    function contractBalances(string memory _tokenName) external view returns (uint256); 
    function addTokens(string memory _tokenName, ERC20 _tokenAddress, uint _decimals, bool _active) external;
    function removeTokens(string memory _tokenName) external;
    function isTokenActive(string memory tokenName) external view returns (bool);
    function mintwMetallis(uint256 _mintAmount) external returns (string memory, uint256);
    function burnwMetallis(uint256 _burnAmount) external returns (string memory, uint256);
    function withdrawFunds(address tokenAddress, uint256 amount) external payable;
    function manualTokenTransfer(address tokenAddress, address to, uint256 amount) external returns(bool);
    function authorizeContract(address _contract) external returns (address);
    function revokeContractAuthorization(address _contract) external returns (address);
    function transferOwnership(address newOwner) external;
    function wMetallisBalance() external view returns (uint);
    function setMetallisMainContract(address _metallisMainAddress) external  returns (address);
    function getMultisigAddress() external view returns (Imultisig _multisigContract, address _multisig);
}



contract wMetallis is ERC20, IwMetallis {

    //************************************** State Variables *****************************************//


    address internal multisigAddress;
    address internal adminAddress;
    address internal metallisMainAddress;
    address public owner;
    bool internal functionLocked;
    bool public paused;
    Imultisig internal multisigContract;
    ImetallisMain internal metallisMainContract;
    string public name = 'wMetallis';
    string public symbol = 'wMTLIS';
    string public logoUrl = "https://metalliscrypta.io/symbollogo.png";
    string public _websiteUrl = "https://metalliscrypta.io";
    uint public decimals = 18;
    uint256 public totalSupply; 
    uint256 public maxTotalSupply;

  
    //**************************************    Mappings    *****************************************//


    // Mappings for balances and allowances
    mapping(address => uint256) private _balances; // Map user balances
    mapping(address => mapping(address => uint256)) private _allowances;  // Map user allowances
    mapping(address => bool) internal authorizedContracts; // Mapping of authorized contract addresses
    mapping(address => uint256) internal deposits; // Mapping to keep track of all Ether deposits
    mapping(string => TokenInfo) internal erc20Tokens;  // Sets ERC20 Token id of Proposal Struct and maps to proposals array
    mapping(address => mapping (address => uint)) public distributedTokens; // Mapping of calling contract, buyer address, and amount distributed
    mapping(address => uint) internal mints; // Log and map all token mints
    mapping(address => uint) internal burns; // Log all token burns

    //**************************************       Structs      *****************************************//
   
    struct TokenInfo {
        ERC20 tokenAddress;
        uint decimals;
        bool active;
    }

    //**************************************       Events      *****************************************//


    event InternalTransfer(address indexed from, address indexed to, uint256 value); //Emit on successful transfer
    event Approval(address indexed owner, address indexed spender, uint256 value); //Emit on successful approval
    event AuthorizationChanged(address indexed contractAddress, bool isAuthorized); //Emit on any change
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); //Emit on any change to ownership
    event EtherReceived(address sender, uint256 amount); //Emit when Ether is received and by which address
    event MintSuccess(uint256 mintAmount, uint256 newSupply); //Emit when new mint is made
    event BurnSuccess(address sender, address zeroAddress, uint256 burnAmount); //Emit when tokens are burned
    event MultisigChanged(address indexed _multisigContract); //Emit if multisig contract is changed
    event TokenInfoUpdated(string tokenName, address tokenAddress, bool active); // Emit when updating token info
    event TokenRemoved(string tokenName, ERC20 tokenAddress); // Emit if token is removed from the contract
    
    //**************************************      Modifiers      *****************************************//


    // Modifier restricting function access to the owner of the contract only
    modifier onlyOwner () {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    // Modifier restricting access to the multisig wallet address only
    modifier onlyMultisig() {
        require(msg.sender == multisigAddress, "Caller is not the multisig contract");
        _;
    }

    // Modifier restricting access to the multisig wallet address only
    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Caller is not the multisig contract");
        _;
    }

    // Modifier to restrict function calls to authorized contracts
    modifier onlyAuthorizedContracts() {
        require(authorizedContracts[msg.sender], "Caller is not authorized");
        _;
    }

    // Modifier to lock a function while it is being exectued until it has finished 
    modifier functionLock() {
        require(!functionLocked, "Reentrant call detected");
        functionLocked = true;
        _;
        functionLocked = false;
    }



    //**************************************    Constructor     *****************************************//


    constructor(
        address _multisigAddress,
        address _metallisMainAddress,
        address _adminAddress
    ) {
        multisigContract = Imultisig(_multisigAddress); // Initialize instances of the contract interfaces
        metallisMainContract = ImetallisMain(_metallisMainAddress); // Initialize instances of the contract interfaces
        adminAddress = _adminAddress; // Define Admin Address upon deployment
        paused = false; // Set initial emergency paused state to false
        functionLocked = false; // Set initial function lock state to false
        maxTotalSupply = 5000000 * (10 ** 18); //5M coins in wei
        owner = msg.sender; // Set the owner of the contract to the deployer address
        uint256 firstMintAmount = 483000 * (10 ** 18); // first mint amount
        _balances[address(this)] = firstMintAmount; // Assigning first minted tokens to the contract itself
        totalSupply = firstMintAmount; // Update the total supply

    }

    //************************************** Core ERC20 Functions *****************************************//


    // Returns the account balance of another account with address `tokenOwner`.
    function balanceOf(address tokenOwner) external view returns (uint256 balance) {
        return _balances[tokenOwner];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require (!paused, "Contract is currently paused");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");
        _balances[msg.sender] = _balances[msg.sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        return true;
    }

    // Approves the `spender` to withdraw from user account multiple times, up to the `tokens` amount.
    function approve(address spender, uint256 tokens) external returns (bool success) {
        require (!paused, "Contract is currently paused");
        require(spender != address(0), "Approve to the zero address");
        _allowances[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // Transfers `tokens` amount of tokens from address `from` to address `to`.
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success) {
        require (!paused, "Contract is currently paused");
        require(tokens <= _balances[from], "Insufficient balance");
        require(tokens <= _allowances[from][msg.sender], "Insufficient allowance");
        require(to != address(0), "Transfer to the zero address");
        _balances[from] -= tokens;
        _balances[to] += tokens;
        _allowances[from][msg.sender] -= tokens;
        return true;
    }

    // Returns the amount of tokens approved by the owner that can be transferred to the spender's account.
    function allowance(address sender, address spender) external view returns (uint256 remaining) {
        return _allowances[sender][spender];
    }

    //************************************** Getter Functions *****************************************//

    //Function to allow checks of authorized contracts
    function isContractAuthorized(address _contract) external view returns (string memory) {
        if (authorizedContracts[_contract]) {
            return "Contract is authorized";
        } else {
            return "Contract is not authorized";
        }
    }

    // Function to check the contract's balance of erc20 Tokens
    function contractBalances(string memory _tokenName) external view onlyOwner returns (uint256) {
        bool _token = erc20Tokens [_tokenName].active;
        require(_token == true, "No active token by that name");
        uint256 balance = erc20Tokens [_tokenName].tokenAddress.balanceOf(address(this));
        return balance / (10**erc20Tokens[_tokenName].decimals); // Fetch the balance and truncate decimals
    }

    // Get wMetallis balance of contract
    function wMetallisBalance() external view onlyAuthorizedContracts returns (uint){
        return totalSupply;
    }

    function isTokenActive(string memory tokenName) external view returns (bool) {
        return erc20Tokens[tokenName].active;
    }

    function getMultisigAddress() external view onlyAuthorizedContracts returns (Imultisig, address) {
        return (multisigContract, multisigAddress);
    }


    //************************************** Setter Functions *****************************************//

    // Function to pause the contract
    function pause() external onlyOwner {
        paused = true;
    }

    // Function to unpause the contract
    function unPause() external onlyOwner {
        paused = false;
    }

    // Function to check the contract's paused status
    function pauseStatus() public view returns (bool) {
        return paused;
    }

    // Set the multisig contract address
    function setMultisigContract(address _multisigAddress) external onlyOwner returns(address){
        multisigContract = Imultisig(_multisigAddress); // Update Multisig Address
        multisigAddress = _multisigAddress; // Set the multisigAddress variable 
        emit MultisigChanged(multisigAddress); // Emit the updated address
        return multisigAddress; //return the updated multisig address
    }
    
    // Set metallisMain Contract address
    function setMetallisMainContract(address _metallisMainAddress) external onlyOwner returns (address){
        metallisMainContract = ImetallisMain(_metallisMainAddress);
        metallisMainAddress = _metallisMainAddress;
        return metallisMainAddress;
    }

    // Set admin address
    function setAdminAddress(address _newAdminAddress) external onlyAdmin returns (address){
        adminAddress = _newAdminAddress;
        return adminAddress;
    }

    // Set token addresses that the contract will accept
    function addTokens(
        string memory _tokenName, 
        ERC20 _tokenAddress, 
        uint _decimals, 
        bool _active) external onlyOwner {
            erc20Tokens[_tokenName] = TokenInfo(_tokenAddress, _decimals, _active);
            emit TokenInfoUpdated(_tokenName, address(_tokenAddress), _active);
    }

    // Remove tokens from the approved tokens array
    function removeTokens(string memory _tokenName) external onlyOwner {
        emit TokenRemoved(_tokenName, erc20Tokens[_tokenName].tokenAddress);
        delete erc20Tokens[_tokenName];
    }

    // Function to authorize a contract address
    function authorizeContract(address _contract) external onlyOwner returns (address) {
        authorizedContracts[_contract] = true;
        emit AuthorizationChanged(_contract, true);
        return _contract;
    }

    // Function to revoke authorization of a contract address
    function revokeContractAuthorization(address _contract) external onlyOwner returns (address) {
        authorizedContracts[_contract] = false;
        emit AuthorizationChanged(_contract, false);
        return _contract;
    }


    //************************************** Internal Functions *****************************************//

    // Custom ERC20 internal transfer function
    function _transfer(address sender, address recipient, uint256 amount) private returns (bool){
        require (!paused, "Contract is currently paused");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit InternalTransfer(sender, recipient, amount);
        return true;
    }

    // Function to receive Ether. msg.value is the amount of Ether sent mapped to address making deposit
    receive() external payable {
        deposits[msg.sender] += msg.value;
        emit EtherReceived(msg.sender, msg.value);
    }

    // Fallback function to accept ETH sent to the contract and map deposit to sender address
    fallback() external payable {
        deposits[msg.sender] += msg.value;
        emit EtherReceived(msg.sender, msg.value);
    }

    // Function to allow the owner to mint more wMetallis tokens
    // pass "abi.encodeWithSignature("mintwMetallis(uint256)", mintAmount);" to proposal for vote
    function mintwMetallis(uint256 _mintAmount) external onlyMultisig returns (string memory, uint256) {
        require(!paused, "Contract is paused");
        // Make sure that the mint cannot exceed the total supply
        require(totalSupply + _mintAmount <= maxTotalSupply, "Mint exceeds max supply");
        // Add the newly minted tokens tot he total supply
        totalSupply += _mintAmount;
        mints [address(this)] += _mintAmount;
        emit MintSuccess(_mintAmount, totalSupply);
        return ("Mint Successful. Tokens Minted: ",_mintAmount);
    }

    // Function to allow the owner to burn wMetallis tokens
    function burnwMetallis(uint256 _burnAmount) external onlyMultisig returns (string memory, uint256) {
        require(!paused, "Contract is paused");
        // Make sure that the burn amount cannot exceed the total supply
        require(totalSupply - _burnAmount >= 0, "Burn exceeds total supply");
        // Subtract the burned tokens from the total supply
        totalSupply -= _burnAmount;
        burns [address(this)] += _burnAmount;
        emit BurnSuccess(msg.sender, address(0), _burnAmount);
        return ("Burn Successful. Tokens Burned: ", _burnAmount);
    }

    // Function to allow owner to withraw funds from the contract
    function withdrawFunds(address tokenAddress, uint256 amount) external onlyAdmin functionLock payable {
        require (!paused, "Contract is currently paused");
        // Handling Ether withdrawal
        if (tokenAddress == address(0)) {
            require(address(this).balance >= amount, "Insufficient ETH balance");
            (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "ETH transfer failed");
        } else {
            // Handling ERC20 token withdrawal
            require(tokenAddress != address(0), "Invalid token address");
            uint256 balance = ERC20(tokenAddress).balanceOf(address(this));
            require(balance >= amount, "Insufficient token balance");
            require(ERC20(tokenAddress).transfer(msg.sender, amount), "Token transfer failed");
        }
    }

    // Function to manually transfer ERC20 tokens from contract
        function manualTokenTransfer(address tokenAddress, address to, uint256 amount) external onlyAdmin functionLock returns(bool){
        require (!paused, "Contract is currently paused");
        ERC20 tokenContract = ERC20(tokenAddress);
        bool success = tokenContract.transfer(to, amount);
        require(success, "Token transfer failed");
        return success;
    }

    // Distribute purchased wMetallis Tokens when purchased and called by the Main Contract
    function distributeTokens(address _buyer, uint256 wMetallisAmount) external onlyAuthorizedContracts functionLock returns (bool) {
        require (!paused, "Contract is currently paused");
        require(_balances[address(this)] >= wMetallisAmount, "Insufficient wMetallis balance in contract"); // Make sure the contract has enough minted tokens to complete the transaction
        bool success =_transfer(address(this), _buyer, wMetallisAmount); // Call the internal _transfer function to send wMetalllis to buyer
        require(success, "Distribute tokens failed"); // if transfer fails, revert and throw error
        distributedTokens[msg.sender][_buyer] += wMetallisAmount; // Map the caller,buyer, and wMetallis amount transfered
        return true; // Tell the main contract that the distribution was completed ok
    }

    function transferOwnership(address newOwner) external onlyAdmin {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}
    

    // Flattened Main Contract

contract metallisMain is ImetallisMain {

    //************************************** State Variables *****************************************//


    address public owner;
    address internal multisigAddress;
    address internal wMetallisAddress;
    address internal adminAddress;
    bool internal functionLocked = false;
    bool internal paused = false;
    IwMetallis internal wMetallisContract;
    Imultisig internal multisigContract;
    string public name = 'metallisMain';
    string public logoUrl = "https://metalliscrypta.io/symbollogo.png";
    string public _websiteUrl = "https://metalliscrypta.io";
    uint256 public wMetallisAmount;
    uint256 public convertedToken;
    uint256 public totalSlots = 2000;
    uint256 public treasuryCount;  

    
  
    //**************************************    Mappings    *****************************************//


    // Mappings for balances and allowances
    mapping(address => uint256) private _balances; // Map user balances
    mapping(address => mapping(address => uint256)) private _allowances;  // Map user allowances
    mapping(address => bool) internal authorizedContracts; // Mapping of authorized contract addresses
    mapping(address => uint256) internal deposits; // Mapping to keep track of all Ether deposits
    mapping(address => bool) internal whitelisted; // Mapping of whitelisted addresses
    mapping(string => TokenInfo) internal erc20Tokens;  // Sets ERC20 Token id of Proposal Struct and maps to proposals array
    mapping(string => PurchasePrices) internal purchasePrice; // Map the wMetallis purchase price to the erc20 token 
    mapping(string => Treasuries) internal treasuries; // Map the treasuries struct
    mapping(uint => Treasuries) internal treasuryIds; // Map the treasuries by ID
    
    //**************************************       Structs      *****************************************//
    
    struct TokenInfo {string tokenName; ERC20 tokenAddress; uint decimals; uint weiDiff; bool active;}
    struct PurchasePrices {string tokenName; ERC20 tokenAddress; uint256 wMetallisPrice;} //set price for 1 wMetallis
    struct Treasuries {uint treasuryId; string treasuryName; address treasuryAddress; uint rate;} // set Treasury Addresses and Rates
    struct TreasuryAmounts {
        uint256 leverageAmount;
        uint256 aquisitionAmount;
        uint256 maintenanceAmount;
        uint256 reserveAmount;
        uint256 buyTaxAmount;
        uint256 netAmount;
        uint256 sellTaxAmount;
    } // Store treasury deopsit amounts

    //**************************************    Arrays    *****************************************//

    string[] private treasuryNames; // Array to hold treasury names

    //**************************************       Events      *****************************************//


    event Transfer(address indexed from, address indexed to, uint256 value); //Emit on successful transfer
    event Approval(address indexed owner, address indexed spender, uint256 value); //Emit on successful approval
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); //Emit on any change to ownership
    event EtherReceived(address indexed sender, uint256 amount); // Emit if ether is received
    event MultisigChanged(address indexed multisigContract); //Emit if multisig contract is changed
    event TokenInfoUpdated(string tokenName, address tokenAddress, bool active); // Emit when updating token info
    event PriceUpdated (string tokenName, ERC20 tokenAddress, uint256 wMetallisPrice); // Emit Price set
    event WhitelistAdded(address _address); // Emit when new address is whitelisted
    event TreasuryUpdated(uint treasuryId, string treasuryName, address treasuryAddress, uint rate); // Emit Treasury updates


    //**************************************      Modifiers      *****************************************//

    // Modifier to restrict function calls to only the contract owner
    modifier onlyOwner () {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    // Modifier to restrict function calls to only the contract owner
    modifier onlyAdmin () {
        require(msg.sender == adminAddress, "You are not the owner");
        _;
    }

    // Modifier to restrict function calls to Multisig contract only
    modifier onlyMultisig() {
        require(msg.sender == multisigAddress, "Caller is not the multisig contract");
        _;
    }

    // Modifier to restrict function calls to authorized contracts
    modifier onlyAuthorizedContracts() {
        require(authorizedContracts[msg.sender], "Caller is not authorized");
        _;
    }

    // Modifier to lock a function while it is being exectued until it has finished to prevent Reentrancy attacks
    modifier functionLock() {
        require(!functionLocked, "Reentrant call detected");
        functionLocked = true;
        _;
        functionLocked = false;
    }

    // Modifier to restrict calls only to wallet addresses
    modifier userOnly() {
        require (tx.origin == msg.sender, "Only EOAs can purchase wMetallis");
        _;
    }

    //**************************************    Constructor     *****************************************//

    constructor(
        address _wMetallisAddress,
        address _multisigAddress,
        address _adminAddress
    ) {
        wMetallisContract = IwMetallis(_wMetallisAddress); // Initialize instances of the contract interfaces
        multisigContract = Imultisig(_multisigAddress); // Initialize instances of the contract interfaces
        owner = msg.sender;
        adminAddress = _adminAddress;
    }

    //************************************** Public Functions *****************************************//

    // Convert Token to wMetallis wei
    function setwMetallisAmount(string memory _tokenName, uint _netAmount) internal {
        if(erc20Tokens[_tokenName].decimals != 18){
            convertedToken = _netAmount * (10 ** erc20Tokens[_tokenName].weiDiff);
            wMetallisAmount = convertedToken / purchasePrice[_tokenName].wMetallisPrice;
        } else {
            wMetallisAmount = _netAmount / purchasePrice[_tokenName].wMetallisPrice;
        }
    }

    // Function for user to purchase wMetallis using supported erc20 tokens from their wallet
    function purchasewMetallis(address _buyer, string memory _tokenName, uint256 _tokenAmount) external userOnly returns (bool) {
        isContractPaused(); // Make sure the contract is not paused
        require(_tokenAmount > 0, "Amount must be greater than 0"); // Verify that the purchase amount is greater than 0
        require(erc20Tokens[_tokenName].active, "Unsupported purchase token"); // Verify that the purchase token is accepted
        require(purchasePrice[_tokenName].wMetallisPrice != 0,"No purchase price set for token"); // check that purchasePrice is set
        if (!whitelisted[_buyer]) {
            require(_tokenAmount / purchasePrice[_tokenName].wMetallisPrice >= 3 , "Minimum purchase is 3 wMetallis");
            require(totalSlots > 0, "No more available whitelist slots"); // Make sure there are available whitelist slots
            whitelisted[_buyer] = true;  // Auto whitelist the user
            totalSlots--; // Decrement the User's slot from the total supply of remaining whitelist slots
        } 
        uint256 tokenInWei = _tokenAmount * (10 ** erc20Tokens[_tokenName].decimals); // Convert tokenAmount to wei
        require(erc20Tokens[_tokenName].tokenAddress.allowance(_buyer, address(this)) >= tokenInWei, "Insufficient token allowance"); // verify the buyer has approved a sufficient allowance for token
        
        TreasuryAmounts memory amounts = calculateTreasuryAmounts(tokenInWei); // Calculate amounts to deposit to treasuries
        setwMetallisAmount(_tokenName, amounts.netAmount); // Set wMetallis amount to send to buyer less buyTax
        transferToTreasuries(_buyer, _tokenName, amounts); // Transfer amounts to treasuries

        //Distribute Tokens to buyer
        bool distributeSuccess = wMetallisContract.distributeTokens(_buyer, wMetallisAmount);// Call wMetallis Contract to distribute wMetallis Tokens
        require(distributeSuccess, "wMetallis distribution failed"); // Make sure wMetallis contract transfered tokens to buyer or revert
        return distributeSuccess; // also return the purchase function status when function completes
    }

    // Function to receive Ether. msg.value is the amount of Ether sent mapped to address making deposit
    receive() external payable {
        deposits[msg.sender] += msg.value;
        emit EtherReceived(msg.sender, msg.value);
    }

    // Fallback function to accept ETH sent to the contract and map deposit to sender address
    fallback() external payable {
        deposits[msg.sender] += msg.value;
        emit EtherReceived(msg.sender, msg.value);
    }



    //************************************** Revert Functions *****************************************//
    
    // Revert if Contract is paused
    function isContractPaused() internal view {
        require(!paused, "Contract is Paused");
    }

    //************************************** Setter Functions *****************************************//

    // Set the multisig contract address 
    function setMultisigContract(address _multisigContract) external onlyOwner returns (address){
        multisigContract = Imultisig (_multisigContract); // Assign Multisig address to global interface instance
        multisigAddress = _multisigContract; // Update multisig address
        emit MultisigChanged(_multisigContract); // Emit the updated address
        return multisigAddress; //return the updated multisig address
    }

    // Change Admin Address
    function setAdminAddress(address _newAdminAddress) external onlyAdmin returns (address){
        adminAddress = (_newAdminAddress);
        return adminAddress;
    }

    // Set wMetallisContract Address
    function setwMetallisContract(address _wMetallisAddress) external onlyOwner returns(address){
        wMetallisContract = IwMetallis(_wMetallisAddress);
        wMetallisAddress = _wMetallisAddress;
        return wMetallisAddress;
    }

    // function to add address to whitelist
    function addToWhitelist(address _address) external onlyOwner {
        isContractPaused(); // Make sure the contract is not paused
        require(!whitelisted[_address],"Address already on whitelist"); // Check that the address is not already whitelisted
        whitelisted[_address] = true;
        emit WhitelistAdded (_address);
    }

    // Set token addresses that the contract will accept
    function updatePurchaseTokens(
        string memory _tokenName, 
        ERC20 _tokenAddress, 
        uint _decimals, 
        uint _weiDiff,
        bool _active) external onlyAdmin {
            erc20Tokens[_tokenName] = TokenInfo(_tokenName,_tokenAddress, _decimals, _weiDiff, _active);
            emit TokenInfoUpdated(_tokenName, address(_tokenAddress), _active);
    }

    // Function to allow the admin to update the Treasuries, addresses and rates
    function setTreasuries(
        string memory _treasuryName, 
        address _treasuryAddress, 
        uint _rate) external onlyAdmin{
        isContractPaused();
            uint treasuryID = ++treasuryCount;
            Treasuries storage id = treasuryIds[treasuryID];
            Treasuries storage treasury = treasuries[_treasuryName];
            // Check if it's a new treasury in the treasuries array
            if (bytes(treasury.treasuryName).length == 0) {
                treasuryNames.push(_treasuryName); // Add treasury name to treasuryNames array
                treasury.treasuryName = _treasuryName; // Initialize the token name in the struct
            }
            treasury.treasuryId = treasuryID;
            treasury.treasuryAddress = _treasuryAddress;
            treasury.rate = _rate;
            id.treasuryId = treasuryID;
            id.treasuryName = _treasuryName;
            id.treasuryAddress = _treasuryAddress;
            id.rate = _rate;
            emit TreasuryUpdated(treasuryID, _treasuryName, _treasuryAddress, _rate);
    }

    // Set the purchase price for respective tokens used to purchase wMetallis
    function updatewMetallisPrice(string memory _tokenName, ERC20 _tokenAddress, uint256 _wMetallisPrice) external onlyAdmin {
        purchasePrice [_tokenName] = PurchasePrices(_tokenName, _tokenAddress, _wMetallisPrice); // 
        emit PriceUpdated (_tokenName, _tokenAddress, _wMetallisPrice); // Emit Price update
    }

    // Function to pause the contract
    function pauseContract(bool _status) external onlyOwner returns (bool) {
        paused = _status;
        return paused;
    }

    //************************************** Getter Functions *****************************************//

    // Getter function to retrieve an array of TokenInfo structs
    function getTreasuryInfo() public view returns (Treasuries[] memory) {
        Treasuries[] memory treasuryInfo = new Treasuries[](treasuryNames.length);
        for (uint i = 0; i < treasuryNames.length; i++) {
            treasuryInfo[i] = treasuries[treasuryNames[i]];
        }
        return (treasuryInfo);
    }
    
    function isAdmin(address _adminAddress) external view returns (bool){
        bool admin = adminAddress == _adminAddress;
        return admin;
    }

    // Call Multisig Address
    function getMultisigContract() external view onlyOwner returns (Imultisig, address){
        return (multisigContract, multisigAddress);
    }

    // Call IwMetallis Contract instance
    function getwMetallisContract() external view onlyOwner returns(IwMetallis, address){
        return (wMetallisContract, wMetallisAddress);
    }

    // Getter function to allow reading the private price variable
    function getwMetallisPrice(string memory _tokenName) external view returns (uint256) {
        uint256 price = purchasePrice[_tokenName].wMetallisPrice; // Look up the price for the token in the purchasePrice array
        return price; // Return the token price per wMetallis token
    }

    // Check if address is whitelisted
    function isWhitelisted() external view returns (bool){
        bool onWhitelist = whitelisted[msg.sender];
        return onWhitelist;
    }

    // Check if address is whitelisted
    function isAddressWhitelisted(address _whitelistAddress) external onlyOwner view returns (bool){
        bool onWhitelist = whitelisted[_whitelistAddress];
        return onWhitelist;
    }

    // check if token is authorized purchase token
    function isPurchaseTokenActive(string memory tokenName) external view returns (bool) {
        return erc20Tokens[tokenName].active;
    }

    // Function to check the contract's balance of erc20 Tokens
    function contractTokenBalances(string memory _tokenName) external view onlyAdmin returns (uint256, uint256) {
        bool _token = erc20Tokens [_tokenName].active;
        require(_token == true, "No active token by that name");
        uint256 balance = erc20Tokens [_tokenName].tokenAddress.balanceOf(address(this));
        uint256 ethbalance = address(this).balance;
        return (balance / 10**erc20Tokens[_tokenName].decimals, ethbalance); // Fetch the balance and truncate decimals
    }

    // Check mint balance on wMetallis contract
    function wMetallisMintedBalance() external view onlyOwner returns(uint256){
        return wMetallisContract.wMetallisBalance();
    }

   //************************************** Internal Functions *****************************************//
    
     // Calculate the treasury amounts        
    function calculateTreasuryAmounts(uint256 tokenInWei) internal view returns (TreasuryAmounts memory) {
        
        TreasuryAmounts memory amounts;
        
        Treasuries memory buyTaxTreasury = treasuries["buyTax"];
        require(buyTaxTreasury.treasuryAddress != address(0), "BuyTax treasury not found");
        amounts.buyTaxAmount = tokenInWei * buyTaxTreasury.rate / 100;

        amounts.netAmount = tokenInWei - amounts.buyTaxAmount;

        Treasuries memory leverageTreasury = treasuries["leverage"];
        require(leverageTreasury.treasuryAddress != address(0), "Leverage treasury not found");
        amounts.leverageAmount = amounts.netAmount * leverageTreasury.rate / 100;

        Treasuries memory aquisitionTreasury = treasuries["aquisition"];
        require(aquisitionTreasury.treasuryAddress != address(0), "Aquisition treasury not found");
        amounts.aquisitionAmount = amounts.netAmount * aquisitionTreasury.rate / 100;

        Treasuries memory maintenanceTreasury = treasuries["maintenance"];
        require(maintenanceTreasury.treasuryAddress != address(0), "Maintenance treasury not found");
        amounts.maintenanceAmount = amounts.netAmount * maintenanceTreasury.rate / 100;

        Treasuries memory reserveTreasury = treasuries["reserve"];
        require(reserveTreasury.treasuryAddress != address(0), "Reserve treasury not found");
        amounts.reserveAmount = amounts.netAmount * reserveTreasury.rate / 100;

        return amounts;
}

    // Function to transfer deposits to respective treasuries
    function transferToTreasuries(address _buyer, string memory _tokenName, TreasuryAmounts memory amounts) internal {
        ERC20 token = erc20Tokens[_tokenName].tokenAddress;

        Treasuries memory leverageTreasury = treasuries["leverage"];
        Treasuries memory aquisitionTreasury = treasuries["aquisition"];
        Treasuries memory maintenanceTreasury = treasuries["maintenance"];
        Treasuries memory reserveTreasury = treasuries["reserve"];
        Treasuries memory buyTaxTreasury = treasuries["buyTax"];

        require(token.transferFrom(_buyer, leverageTreasury.treasuryAddress, amounts.leverageAmount), "Leverage transfer failed");
        require(token.transferFrom(_buyer, aquisitionTreasury.treasuryAddress, amounts.aquisitionAmount), "Acquisition transfer failed");
        require(token.transferFrom(_buyer, maintenanceTreasury.treasuryAddress, amounts.maintenanceAmount), "Maintenance transfer failed");
        require(token.transferFrom(_buyer, reserveTreasury.treasuryAddress, amounts.reserveAmount), "Reserve transfer failed");
        require(token.transferFrom(_buyer, buyTaxTreasury.treasuryAddress, amounts.buyTaxAmount), "Buy tax transfer failed");
    }

    // Function to allow owner to withraw funds from the contract
    function withdrawFunds(address tokenAddress, uint256 amount) external onlyAdmin payable returns (bool success){

        // Handling Ether withdrawal
        if (tokenAddress == address(0)) {
            require(address(this).balance >= amount, "Insufficient ETH balance");
            (success, ) = msg.sender.call{value: amount}("");
            require(success, "ETH transfer failed");
            
        } else {
            // Handling ERC20 token withdrawal
            require(tokenAddress != address(0), "Invalid token address");
            uint256 balance = ERC20(tokenAddress).balanceOf(address(this));
            require(balance >= amount, "Insufficient token balance");
            require(ERC20(tokenAddress).transfer(adminAddress, amount), "Token transfer failed");
            return true;
        }
    }   

    function transferOwnership(address newOwner) external onlyAdmin returns (address) {
        require(newOwner != address(0), "Address must not be zero");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        return owner;
    }
    
}


contract MetallisAirdrop {

    //**************************************      State Variables      *****************************************//

    IwMetallis internal wMetallisContract;
    ImetallisMain internal metallisMainContract;
    string public name = "MetallisAirdrop";
    bool public paused;
    address internal adminAddress;
    address internal wMetallisAddress;
    address internal metallisMainAddress;
    address public owner;
    uint256 public totalSlots = 2000;
    uint internal minPurchaseAmount = 1;
    uint internal campaignId;
    uint internal salt;    



    //**************************************      Arrays      *****************************************//

    address[] internal whitelistedAddressesArray; // Array to store all whitelisted addresses
    address[] internal airdropRecipientsArray; // Array to store Airdrops
    address[] internal blacklistArray; // Array of blacklist addresses
    address[] internal authorizedContractsArray; // Array of authorized contracts
    address[] internal marketingAddressesArray; // Array of marketing addresses
    uint[] internal campaignsArray; // Array of all campaigns

    //**************************************      Structs      *****************************************//

    struct AirdropRecipient{
        address recipientAddress;
        uint airdropAmount;
        uint date;
        uint campaignId;
        bytes32 verificationCode;
        bool complete;
    }

    struct AirdropClaims{
        uint date;
        uint timesClaimed;
        uint verificationCode;
    }

    struct CampaignId{
        uint campaignId;
        bytes32 verificationCode;
        bool active;
        uint airdropAmount;
        uint maxUses;
        uint timestamp;
        uint saltValue;
        uint last5;
    }

    struct WhiteList{
        address whitelistedAddress;
        uint date;
        uint airdropAmount;
    }

    //**************************************      Mappings      *****************************************//

    mapping(address => AirdropRecipient) internal recipients; // Map the airdrops to the recipients
    mapping(bytes32 => CampaignId) internal campaignCodes; // Map active campaignCodes
    mapping(uint => CampaignId) internal campaignIds;
    mapping(address => WhiteList) internal whitelist; // Map whitelist
    mapping(address => bool) internal whitelisted; // Mapping of whitelisted addresses
    mapping(address => bool) internal blacklist; // Mapping of all blacklisted addresses
    mapping(address => bool) internal authorizedContracts; // Mapping of authorized contracts
    mapping(address => bool) internal marketingAddresses; // Mapping of the Marketing Addresses

    //**************************************      Events      *****************************************//

    event EtherReceived(address sender, uint256 amount); // Emit when Ether is received and by which address
    event CampaignCreated(uint campaignId, bytes32 verificationCode); // Emit when a new campaign is created
    event DebugClaimAirdrop(bytes32 verificationCode, bool activeBefore, bool activeAfter, uint maxUsesBefore, uint maxUsesAfter);
    event DebugCampaignState(uint campaignId, bool active, uint maxUses);
    event CampaignIdsUpdate(uint campaignId, bool active, uint maxUses);

    //**************************************      Constructor      *****************************************//


    constructor() {
        paused = false;
        owner = msg.sender;
        adminAddress = 0xa45570bBE3aA2B313E9c2e2b89738b7f04F9Da54;
        wMetallisContract = IwMetallis(payable (0xe358f9571a2c83702DA7D53f1dfD1Ffd01d91cE2));
        metallisMainContract = ImetallisMain(payable (0x707A8D0fBA270416bE0B14727a6Ac5F735B590e9));
        salt = 3597;
        campaignId = 1;
    }

    //**************************************      Modifiers      *****************************************//

    // Modifier to restrict function calls to only the contract owner
    modifier onlyOwner () {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    // Modifier to restrict function calls to only the contract owner
    modifier onlyAdmin () {
        require(msg.sender == adminAddress, "You are not the admin");
        _;
    }

    // Modifier to restrict access to functions
    modifier onlyAuthorizedContracts () {
        require (authorizedContracts[msg.sender], "Contract not authorized");
        _;
    }

    // Modifier to restrict access to functions
    modifier onlyMarketing () {
        require (marketingAddresses[msg.sender], "Address not Marketing");
        _;
    }

    // Modifier to restrict calls only to wallet addresses
    modifier onlyUser() {
        require (tx.origin == msg.sender, "Only EOAs can purchase wMetallis");
        _;
    }

    // Modifier to check if contract is paused
    modifier contractNotPaused() {
        require (paused == false, "Contract is paused");
        _;
    }


    //**************************************     Setter Functions      *****************************************//

    // Change Admin Address
    function setAdminAddress(address _newAdminAddress) external onlyAdmin returns (address){
        adminAddress = (_newAdminAddress);
        return adminAddress;
    }

    // Update Authorized contract addresses
    function updateAuthorizedContracts(address _contractAddress, bool _status) external onlyAdmin contractNotPaused {
        if (_status) {
            if (!authorizedContracts[_contractAddress]) {
                // Add the contract address to the mapping
                authorizedContracts[_contractAddress] = true;
                // Add the address to the array
                authorizedContractsArray.push(_contractAddress);
            }
        } else {
            if (authorizedContracts[_contractAddress]) {
                // Remove the contract address from the mapping
                authorizedContracts[_contractAddress] = false;
                // Find and remove the address from the array
                for (uint i = 0; i < authorizedContractsArray.length; i++) {
                    if (authorizedContractsArray[i] == _contractAddress) {
                        authorizedContractsArray[i] = authorizedContractsArray[authorizedContractsArray.length - 1];
                        authorizedContractsArray.pop();
                        break;
                    }
                }
            }
        }
    }

    // Update marketing addresses
    function updateMarketingAddresses(address _marketingAddress, bool _status) external onlyOwner contractNotPaused {
        if (_status) {
            if (!marketingAddresses[_marketingAddress]) {
                // Add the marketing address to the mapping
                marketingAddresses[_marketingAddress] = true;
                // Add the address to the array
                marketingAddressesArray.push(_marketingAddress);
            }
        } else {
            if (marketingAddresses[_marketingAddress]) {
                // Remove the marketing address from the mapping
                marketingAddresses[_marketingAddress] = false;
                // Find and remove the address from the array
                for (uint i = 0; i < marketingAddressesArray.length; i++) {
                    if (marketingAddressesArray[i] == _marketingAddress) {
                        marketingAddressesArray[i] = marketingAddressesArray[marketingAddressesArray.length - 1];
                        marketingAddressesArray.pop();
                        break;
                    }
                }
            }
        }
    }


    // Set MultisigcAddress
    function updatewMAddress(address _wMetallisAddress) external onlyAdmin contractNotPaused returns (address){
        wMetallisAddress = _wMetallisAddress;
        wMetallisContract = IwMetallis(payable (_wMetallisAddress));
        return wMetallisAddress;
    }

    // Set MultisigcAddress
    function updatemMAddress(address _MetallisMainAddress) external onlyAdmin contractNotPaused returns (address){
        metallisMainAddress = _MetallisMainAddress;
        metallisMainContract = ImetallisMain(payable (_MetallisMainAddress));
        return metallisMainAddress;
    }    

    function addAddressToWhitelist (address _address) external onlyAdmin returns (bool){
        isBlacklisted(_address) == false;
        require (totalSlots > 0, "No whitelist slots remaining");
        require (!whitelisted[_address], "Address is whitelisted");
        WhiteList storage newWL = whitelist[_address];
        whitelistedAddressesArray.push(_address); // Add address to whitelistedAddresses Arrary
        newWL.whitelistedAddress = _address; // Add address to whitelist mapping
        whitelisted[_address] = true; // Add whitelist address to whitelisted mapping and set to true
        totalSlots --; // decrement total slots
        if (metallisMainContract.isAddressWhitelisted(_address) == true){
            return true;
        } else   
            metallisMainContract.addToWhitelist(_address);
        return true;
    }

    function addToWhitelist (uint _purchaseAmount) external contractNotPaused returns (bool){
        address _address = msg.sender;
        require(isBlacklisted(_address) == false, "Address is Blacklisted");
        require (_purchaseAmount >= minPurchaseAmount, "Purchase Minimum not met");
        require (totalSlots > 0, "No whitelist slots remaining");
        require (!whitelisted[_address], "Address is whitelisted");
        WhiteList storage newWL = whitelist[_address];
        whitelistedAddressesArray.push(_address); // Add address to whitelistedAddresses Arrary
        newWL.whitelistedAddress = _address; // Add address to whitelist mapping
        whitelisted[_address] = true; // Add whitelist address to whitelisted mapping and set to true
        totalSlots --; // decrement total slots
        if (metallisMainContract.isAddressWhitelisted(_address) == true){
            return true;
        } else   
            metallisMainContract.addToWhitelist(_address);
        return true;
    }

    function removeAddressFromWL(address _address) external onlyAdmin returns (bool){
        totalSlots++;
        whitelisted[_address] = false;
        whitelist[_address].whitelistedAddress = address(0);
        whitelist[_address].date = 0;
        whitelist[_address].airdropAmount = 0;
        uint length = whitelistedAddressesArray.length;
        for (uint i = 0; i < length; i++) {
            if (whitelistedAddressesArray[i] == _address) {
                whitelistedAddressesArray[i] = whitelistedAddressesArray[length - 1];
                whitelistedAddressesArray.pop();
                break;
            }
        }
        return true;
    }

    //**************************************     Getter Functions      *****************************************//

    function isAdmin() external view returns (bool) {
        bool check = msg.sender == adminAddress;
        return check;
    }

    function isMarketing() external view returns (bool) {
        bool check = marketingAddresses[msg.sender];
        return check;
    }

    function isOwner() external view returns (bool) {
        bool check = msg.sender == owner;
        return check;
    }

    function isAuthorizedContract() external view returns (bool) {
        bool check = authorizedContracts[msg.sender];
        return check;
    }

    // Check if address is whitelisted
    function isWhitelisted() external view returns (bool){
        bool onWhitelist = whitelisted[msg.sender];
        return onWhitelist;
    }

    // Check if address is whitelisted
    function isAddressWhitelisted(address _whitelistAddress) external onlyAdmin view returns (bool){
        bool onWhitelist = false;
        if(whitelisted[_whitelistAddress]){
            onWhitelist = true;
        }
        return onWhitelist;
    }

    function getWhitelistedAddresses() external onlyAuthorizedContracts view returns (address[] memory) {
        return whitelistedAddressesArray;
    }

    function getBlacklist() external onlyAuthorizedContracts view returns (address[] memory) {
        return blacklistArray;
    }

    function isBlacklisted(address _address) internal view returns(bool) {
        require (!blacklist[_address], "Address is blacklisted"); // Require Address not in blacklist mapping
        return false;
    }

    function getAllAuthorizedContracts() external onlyAdmin view returns (address[] memory){
        return authorizedContractsArray;
    }

    function getAllMarketingAddresses() external onlyAuthorizedContracts view returns (address[] memory) {
        return marketingAddressesArray;
    }

    //**************************************     Marketing Functions      *****************************************//


    function createNewCampaign(uint _airdropAmount, uint _quantity, uint _maxUses) internal {
    uint160 sender = uint160(msg.sender);
    uint160 last5Digits = sender % 100000;
    for (uint i = 0; i < _quantity; i++) {
        bytes32 _verificationCode = generateOneTimeCode(salt);
        salt++;

        CampaignId memory newCampaign = CampaignId({
            campaignId: campaignId,
            verificationCode: _verificationCode,
            active: true,
            airdropAmount: _airdropAmount,
            maxUses: _maxUses,
            timestamp: block.timestamp,
            saltValue: salt,
            last5: last5Digits

        });
        campaignsArray.push(newCampaign.campaignId);
        campaignCodes[_verificationCode] = newCampaign;
        campaignIds[campaignId] = newCampaign;

        emit CampaignCreated(campaignId, _verificationCode);
        campaignId++; // Increment the campaignId for the next campaign
        }
    }


    function generateOneTimeCode(uint _salt) internal view returns (bytes32) {
        // Extract the last 5 digits of the msg.sender address
        uint160 sender = uint160(msg.sender);
        uint160 last5Digits = sender % 100000;
        // Combine block.timestamp + delay, last 5 digits of msg.sender, and salt
        bytes memory input = abi.encodePacked(block.timestamp, last5Digits, _salt);
        // Generate the SHA256 hash
        bytes32 oneTimeCode = sha256(input);
        return oneTimeCode;
    }

    function createNewCampaignPool(uint _airdropAmount, uint _quantity, uint _maxUses) external onlyMarketing contractNotPaused{
        createNewCampaign(_airdropAmount, _quantity, _maxUses);
    }

    function getAllCampaigns() external onlyMarketing view returns (CampaignId[] memory) {
        CampaignId[] memory allCampaigns = new CampaignId[](campaignsArray.length);
        for (uint i = 0; i < campaignsArray.length; i++) {
            uint id = campaignsArray[i];
            allCampaigns[i] = campaignIds[id];
        }
        return allCampaigns;
    }

    function getCampaignById (uint _campaignId) external onlyMarketing view returns (CampaignId memory) {
        return campaignIds[_campaignId];
    }

    function getVerificationCodeById (uint _campaignId) external onlyMarketing view returns (bytes32) {
        require(_campaignId <= campaignId, "No campaign created with that Id");
        return campaignIds[_campaignId].verificationCode;    
    }

    function getCampaignIdVar () external onlyMarketing view returns (uint) {
        return campaignId;
    }
    //**************************************     General Functions      *****************************************//

    function claimAirdrop(bytes32 _verificationCode) external onlyUser contractNotPaused returns (bool) {
        require(checkAirdrop(_verificationCode), "Airdrop failed");
        address recipAddress = msg.sender;
        require(!isBlacklisted(recipAddress), "Address is blacklisted");
        AirdropRecipient storage recipient = recipients[recipAddress];
        CampaignId storage redeem = campaignCodes[_verificationCode];
        CampaignId storage update = campaignIds[redeem.campaignId];
        bool activeBefore = redeem.active;
        uint maxUsesBefore = redeem.maxUses;
        airdropRecipientsArray.push(recipAddress);
        recipient.recipientAddress = recipAddress;
        recipient.complete = true; 
        recipient.airdropAmount = redeem.airdropAmount;
        recipient.date = block.timestamp;
        recipient.verificationCode = _verificationCode;
        uint amount = redeem.airdropAmount;       
        redeem.maxUses--;
        if (redeem.maxUses < 1) {
            redeem.active = false;
        } 
        update.active = redeem.active;
        update.maxUses = redeem.maxUses;
        emit DebugClaimAirdrop(_verificationCode, activeBefore, redeem.active, maxUsesBefore, redeem.maxUses);
        emit DebugCampaignState(redeem.campaignId, redeem.active, redeem.maxUses);
        emit CampaignIdsUpdate(update.campaignId, update.active, update.maxUses);
        createNewCampaign(amount, 1, 1);
        // Distribute Airdrop Tokens
        bool distributeSuccess = wMetallisContract.distributeTokens(recipient.recipientAddress, recipient.airdropAmount); // Call wMetallis Contract to distribute wMetallis Tokens
        require(distributeSuccess, "Airdrop failed"); // Make sure wMetallis contract transferred tokens to buyer or revert
        return distributeSuccess; // Also return the purchase function status when function completes
    }

    function checkAirdrop(bytes32 _verificationCode) internal view returns(bool){
        bool activeCode = campaignCodes[_verificationCode].active;  
        require(campaignCodes[_verificationCode].maxUses >= 1, "Verification code has been redeemed"); 
        require (activeCode, "Verification code is expired"); // Require an active verification code
        return activeCode;
    }

    //**************************************     Admin Functions      *****************************************//

    function airdropToWhitelisted(uint _amount) external onlyAdmin {
        for (uint i = 0; i < whitelistedAddressesArray.length; i++) {
            bool success = wMetallisContract.distributeTokens(whitelistedAddressesArray[i], _amount);
            require(success, "Airdrop failed for address");
        }
    }

    function changeMinPurchaseAmount(uint _newMin) external onlyAdmin returns (uint){
        minPurchaseAmount = _newMin;
        return minPurchaseAmount;
    }

    function addSlots(uint _addSlots) external onlyAdmin returns (uint){
        uint remainingSlots = totalSlots;
        totalSlots = remainingSlots + _addSlots;
        return totalSlots;
    }

    function removeSlots(uint _removeSlots) external onlyAdmin returns (uint){
        uint remainingSlots = totalSlots;
        totalSlots = remainingSlots - _removeSlots;
        return totalSlots;
    }
   
   function pauseContract(bool _paused) external onlyAdmin returns(bool){
    paused = _paused;
    return paused;
   }

    function updateBlacklist(address _address, bool _status) external onlyAuthorizedContracts contractNotPaused returns (bool) {
        if (_status) {
            if (!blacklist[_address]) {
                blacklistArray.push(_address);
                blacklist[_address] = true;
            }
        } else {
            if (blacklist[_address]) {
                blacklist[_address] = false;
                for (uint i = 0; i < blacklistArray.length; i++) {
                    if (blacklistArray[i] == _address) {
                        blacklistArray[i] = blacklistArray[blacklistArray.length - 1];
                        blacklistArray.pop();
                        break;
                    }
                }
            }
        }
        return true;
    }



    //************************************** Revert Functions *****************************************//
    
    
}