//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17; 

interface ERC20Essential {

    function balanceOf(address user) external view returns(uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);       
    function transferOwnership(address newOwner) external;
    function owner() external returns(address);
}


//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
contract owned
{
    address public owner;
    address internal newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);    

    constructor() {
        owner = msg.sender;
        //owner does not become signer automatically.
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }    

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}



    
//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//
    
contract SETMembership is owned {
    
    uint256 public orderID;       
    mapping(address => bool) public whitelisted;     
    address public tokenAddress = 0x4c5d8D027E97b52542dC66399752c76E017Dc6E9;
   struct SETpackage
    {     
        uint256 pkgamount;       
    }
    mapping(uint => SETpackage) public SETpackages;   
    mapping(address => mapping(uint => uint256)) public userStakeBypkg;    
    mapping(address => mapping(uint => bool)) public userPackage;
    
    event StakeEV(uint256 indexed orderID, address indexed tokenAddress, address indexed user, uint256 value, uint256 chainID, address outputCurrency, uint pkgIndex);
    event WhitelistUpdated(address[] indexed user, bool status); 
    event updatePackage(uint indexed pkgIndex, uint256 oldAmount, uint256 newAmount);    
    
    //_pkgAmount - [25000000000000000000000, 25000000000000000000000]       
    constructor (uint256[] memory _pkgAmount)
    {
        require(_pkgAmount.length == 2, "Package details incorrect");
        for(uint i = 0 ; i < _pkgAmount.length; i++)
        {            
            SETpackages[i].pkgamount =_pkgAmount[i];            
        }        
        whitelisted[owner] = true;           
    }
    
     // Whitelist management
    function updateWhitelist(address[] memory users, bool status) external onlyOwner {
        for(uint i=0;i<users.length;i++){
            whitelisted[users[i]] = status;       
        }
         emit WhitelistUpdated(users, status);
    }
   
    function Stake(uint pkgIndex, uint256 tokenAmount, uint256 chainID, address outputCurrency) external returns(bool){
        require(whitelisted[msg.sender],"Only whitelisted users can stake");        
        require(SETpackages[pkgIndex].pkgamount == tokenAmount, "Invalid amount");        
        require(!userPackage[msg.sender][pkgIndex], "Already purchased");
        userPackage[msg.sender][pkgIndex] = true;
        userStakeBypkg[msg.sender][pkgIndex] = tokenAmount;       
        orderID++;        
        ERC20Essential(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount);                   
        emit StakeEV(orderID, tokenAddress, msg.sender, tokenAmount, chainID, outputCurrency, pkgIndex);
        return true;
    }

    /* Change owner of the given token contract*/
    function transferTokenOwnership(address ofTokenAddress, address toAddress) external onlyOwner returns(address oldOwner, address newOwner){
        require(ofTokenAddress != address(0) && toAddress != address(0), "zero address not allowed");
        oldOwner = ERC20Essential(ofTokenAddress).owner();
        ERC20Essential(ofTokenAddress).transferOwnership(toAddress);
        newOwner = ERC20Essential(ofTokenAddress).owner();
    }

    /* Change token contract*/
    function updateTokenAddress(address _TokenAddress) external onlyOwner {
        require(_TokenAddress != address(0) && _TokenAddress != tokenAddress, "Invalid token");
        tokenAddress = _TokenAddress;
    }
 
    function updatePkgAmount(uint index, uint256 amount) external  onlyOwner
    {
        require(index < 2 , "Invalid package");
        uint256 oldAmount = SETpackages[index].pkgamount;
        SETpackages[index].pkgamount = amount;        
        emit updatePackage(index, oldAmount, amount);
    }

    function rescuTokens(uint256 amount) external onlyOwner
    {
        require(ERC20Essential(tokenAddress).balanceOf(address(this)) >= amount, "Insufficient token balance");
        ERC20Essential(tokenAddress).transfer(msg.sender, amount);
    }  


}