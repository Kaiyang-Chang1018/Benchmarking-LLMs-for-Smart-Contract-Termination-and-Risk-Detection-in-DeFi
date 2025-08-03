// SPDX-License-Identifier: UNLICENSED 
// CopyRight Metallis Crypta.io, ALL RIGHTS RESERVED 2021-2024
// Version 3.0 5-22-24 updates to purchase function, added functions for treasurys, combined buy and
// sell tax functions into treasuries mappings and deleted tax setter and getter functions, updated 
// interfaces accordingly, added arrays to make mappings 'searchable'

pragma solidity 0.8.20;

    //**************************************   Interfaces  *****************************************//

// These intefaces aren't difined here for this contract to conform to their standards.  They are being re-defined
// here so that they can be executed on their respective contracts throught the interfaces for security purposes
// and to avoid deploying seperate private interface contracts
interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);    
    function transfer(address recipient, uint256 amount) external returns (bool success); 
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
    function allowance(address sender, address spender) external view returns (uint256 remaining);
}

// Interface defined on wMetallis contract
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