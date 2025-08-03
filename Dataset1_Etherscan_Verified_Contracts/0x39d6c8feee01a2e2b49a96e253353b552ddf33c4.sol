//SPDX-License-Identifier: NONE
pragma solidity 0.8.17; 

interface ERC20Essential 
{
    function balanceOf(address user) external view returns(uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function mint(address account, uint256 value) external;
    function burn(address account, uint256 value) external;
    function transferOwnership(address newOwner) external;
    function owner() external returns(address);

}

//USDT contract in Ethereum does not follow ERC20 standard so it needs different interface
interface usdtContract
{
    function transferFrom(address _from, address _to, uint256 _amount) external;
    function transfer(address _to, uint256 _amount) external;
    function mint(address account, uint256 value) external;
    function burn(address account, uint256 value) external;
    function balanceOf(address user) external view returns(uint256);
}

contract Ownable{
    address public owner;
    address internal newOwner;
    mapping(address => bool) public signer;

    event OwnershipTransferred(address indexed _from, address indexed _to);
    event SignerUpdated(address indexed signer, bool indexed status);

    constructor() {
        owner = msg.sender;
        //owner does not become signer automatically.
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlySigner {
        require(signer[msg.sender], 'caller must be signer');
        _;
    }

    function changeSigner(address _signer, bool _status) public onlyOwner {
        signer[_signer] = _status;
        emit SignerUpdated(_signer, _status);
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

contract Bridge is Ownable, ReentrancyGuard{
    uint256 public orderID;
    address public feeWallet;
    address public reserveWallet;
    address public usdtAddress = 0xb5b5158B0A8AAe70D3c0cF091a91faFFB808CBE0;
    uint256 public reserveFundThreshold = 10e18;
    uint256 private transferTax = 1;
    uint256 private minTx = 1000000000000000;
    uint256 private maxTx = 5_000_000 * 1e18;
    mapping(address => uint256) public claimableAmount;
    bool public releasedLock;

    /* This mapping contains the status of tokenAddresses who are not under our control like those which we cannot burn or mint*/
    mapping(address=>bool) public noControl;
    mapping(address=>uint256) public tokenFundThreshold;

    mapping(address => bool) public whitelisted; 
    mapping(address => uint256) public lastClaimTime; 
    uint256 constant sixMonths = 180 days;
    uint256 constant oneYear = 365 days;

    event CoinIn(uint256 indexed orderID, address indexed user, uint256 value, address outputCurrency);
    event CoinOut(uint256 indexed orderID, address indexed user, uint256 value);
    event CoinOutFailed(uint256 indexed orderID, address indexed user, uint256 value);
    event TokenIn(uint256 indexed orderID, address indexed tokenAddress, address indexed user, uint256 value, uint256 chainID, address outputCurrency);
    event TokenOut(uint256 indexed orderID, address indexed tokenAddress, address indexed user, uint256 value, uint256 chainID);
    event TokenOutFailed(uint256 indexed orderID, address indexed tokenAddress, address indexed user, uint256 value, uint256 chainID);
    event minMaxTxUpdated(uint256 minTx, uint256 maxTx);
    event transferTaxUpdated(uint256 transferTax);
    event Claim(address indexed claimant, uint256 totalAmount, uint256 baseAmount, uint256 bonusAmount, uint256 timeElapsed);
    event WhitelistUpdated(address indexed user, bool status); 

    receive() external payable{}

    constructor(){
        whitelisted[owner] = true; 
        noControl[0xdAC17F958D2ee523a2206206994597C13D831ec7] = true; /*USDT Ethereum*/
        noControl[0x55d398326f99059fF775485246999027B3197955] = true; /*USDT Binance*/
        noControl[0xc2132D05D31c914a87C6611C10748AEb04B58e8F] = true; /*USDT Matic*/

        tokenFundThreshold[0xdAC17F958D2ee523a2206206994597C13D831ec7] = 100e6; /*USDT Ethereum*/
        tokenFundThreshold[0x55d398326f99059fF775485246999027B3197955] = 100e18; /*USDT Binance*/
        tokenFundThreshold[0xc2132D05D31c914a87C6611C10748AEb04B58e8F] = 100e6; /*USDT Matic*/
    }
    
    function updateWhitelist(address user, bool status) external onlyOwner {
        whitelisted[user] = status;
        emit WhitelistUpdated(user, status);
    }

    function coinIn(address outputCurrency) external payable returns (bool) {
        require(whitelisted[msg.sender], "User not whitelisted"); 
        orderID++;
        uint256 amount = msg.value;
        uint256 afterTax;
        uint256 tax;

        (afterTax, tax) = processTax(amount);
        payable(feeWallet).transfer(tax);

        if (address(this).balance >= reserveFundThreshold) {
            payable(reserveWallet).transfer(afterTax);
        }

        emit CoinIn(orderID, msg.sender, afterTax, outputCurrency);
        return true;
    }

    function coinOut(address user, uint256 amount, uint256 _orderID) external onlySigner returns (bool) {
        if (!releasedLock) {
            claimableAmount[user] += amount;
        } else {
            payable(user).transfer(amount);
        }
        emit CoinOut(_orderID, user, amount);
        return true;
    }

    function ClaimCoin() external nonReentrant {
        require(releasedLock, "Claim has not been released");
        require(whitelisted[msg.sender], "User not whitelisted"); 
        uint256 amount = claimableAmount[msg.sender];
        require(amount > 0, "No claimable amount");

        uint256 timeElapsed = block.timestamp - lastClaimTime[msg.sender];
        uint256 bonusAmount = 0;

        if (timeElapsed >= oneYear) {
            bonusAmount = (amount * 5) / 100; 
        } else if (timeElapsed >= sixMonths) {
            bonusAmount = (amount * 25) / 1000; 
        }
        uint256 totalAmount = amount + bonusAmount;
        require(address(this).balance >= totalAmount, "Insufficient contract balance");
        claimableAmount[msg.sender] = 0;
        lastClaimTime[msg.sender] = block.timestamp; 
        payable(msg.sender).transfer(totalAmount);
        emit Claim(msg.sender, totalAmount, amount, bonusAmount, timeElapsed);
    }
    
    function tokenIn(address tokenAddress, uint256 tokenAmount, uint256 chainID, address outputCurrency) external returns(bool){
        orderID++;
        uint256 burnt;
        uint256 tax;
        uint256 afterTax;
        (afterTax, tax) = processTax(tokenAmount);

        if(noControl[tokenAddress]){
            if(tokenAddress == usdtAddress){
                usdtContract(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount);
                usdtContract(tokenAddress).transfer(feeWallet, tax);
                if(usdtContract(tokenAddress).balanceOf(address(this)) >= tokenFundThreshold[tokenAddress]){
                    usdtContract(tokenAddress).transfer(owner, afterTax);
                }
                
            }else{
                ERC20Essential(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount);
                ERC20Essential(tokenAddress).transfer(feeWallet, tax);
                if(usdtContract(tokenAddress).balanceOf(address(this)) >= tokenFundThreshold[tokenAddress]){
                    ERC20Essential(tokenAddress).transfer(owner, afterTax);
                }
            }
        }else{
            require(afterTax >= minTx, "Minimum amount is required");
            require(afterTax <= maxTx, "Exceeds max amount");
            ERC20Essential(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount);
            ERC20Essential(tokenAddress).transfer(feeWallet, tax);
            burnt = burnTokens(tokenAddress, afterTax);
        }

        emit TokenIn(orderID, tokenAddress, msg.sender, afterTax, chainID, outputCurrency);
        return true;
    }
    
    function tokenOut(address tokenAddress, address user, uint256 tokenAmount, uint256 _orderID, uint256 chainID) external onlySigner returns(bool){
        uint256 minted = tokenAmount;
            if(noControl[tokenAddress]){
                if(tokenAddress == usdtAddress){
                    usdtContract(tokenAddress).transfer(user, tokenAmount);
                }else{
                    ERC20Essential(tokenAddress).transfer(user, tokenAmount);
                }
                
            }else{
                (minted,) = mintTokens(tokenAddress, user, tokenAmount);
            }
            
            emit TokenOut(_orderID, tokenAddress, user, minted, chainID);
        
        return true;
    }

    /* Process Tax*/
    function processTax(uint256 amount) public view returns(uint256 afterTax, uint256 deductedTax){
        deductedTax = (transferTax * amount)/1e5;   /* 0% of amount*/
        afterTax = amount - deductedTax;
    }

    /*
    * Mint token
    */
    function mintTokens(address tokenAddress, address userAddress, uint256 amountToMint) internal returns(uint256 minted, address toAddress){
        ERC20Essential(tokenAddress).mint(userAddress, amountToMint);
        minted = amountToMint;
        toAddress = userAddress;
    }

    /*
    * Burn Tokens
    */
    function burnTokens(address tokenAddress, uint256 amount) internal returns(uint256 burnt){
        ERC20Essential(tokenAddress).burn(address(this), amount);
        burnt = amount;
    }

    /*Change feeWallet*/
    function setFeeWallet(address _feeWallet) external onlyOwner returns(address oldWallet, address newWallet){
        oldWallet = feeWallet;
        feeWallet = _feeWallet;
        newWallet = feeWallet;
    }

    /*Change reserveWallet*/
    function setReserveWallet(address _reserveWallet) external onlyOwner returns(address oldWallet, address newWallet){
        oldWallet = reserveWallet;
        reserveWallet = _reserveWallet;
        newWallet = reserveWallet;
    }

    /* set usdt token address*/
    function setUSDTAddress(address _tokenAddress) external onlyOwner returns(address newAddress){
        require(_tokenAddress != address(0), "zero address not allowed");
        require(_tokenAddress != usdtAddress, "same as old address");
        usdtAddress = _tokenAddress;
        newAddress = usdtAddress;
    }

    /* set Threshold*/
    function setFundThreshold(uint256 _amount) external onlyOwner returns(uint256 oldAmount, uint256 newAmount){
        oldAmount = reserveFundThreshold;
        reserveFundThreshold = _amount;
        newAmount = _amount;
    }

    /* Change owner of the given token contract*/
    function transferTokenOwnership(address ofTokenAddress, address toAddress) external onlyOwner returns(address oldOwner, address newOwner){
        require(ofTokenAddress != address(0) && toAddress != address(0), "zero address not allowed");
        oldOwner = ERC20Essential(ofTokenAddress).owner();
        ERC20Essential(ofTokenAddress).transferOwnership(toAddress);
        newOwner = ERC20Essential(ofTokenAddress).owner();
    }

    /*Add noControl tokens i.e, the token on which you dont have burning and minting capabilities
    * Set the status to true if you cannot mint or burn 
    * Set the status to false if you can mint or burn*/
    function setNoControl(address tokenAddress, bool status) external onlyOwner{
        require(tokenAddress != address(0), "cannot set zero address");
        noControl[tokenAddress] = status;
    }

    /* Modify the token reserve threshold values
    */
    function setTokenReserveThreshold(address forToken, uint256 threshold) external onlyOwner{
        tokenFundThreshold[forToken] = threshold;
    }

     /* Modify the transfer tax
    */
    function setTransferTax(uint256 _transferTax) external onlyOwner{
        require(_transferTax <= 50000, "Cannot set transfer tax to more then 50%");
        transferTax = _transferTax;
        emit transferTaxUpdated(transferTax);
    }

    /**
     * @notice Changes the minimum and maximum amount of tokens that can be bridge in a single transaction
     * @dev onlyOwner.
     * Emits an {minMaxTxUpdated} event
     * @param newMinTx, newMaxTx Base 1000,
     */
    function updateMinMaxTx(uint256 newMinTx, uint256 newMaxTx) external onlyOwner {
        minTx = newMinTx;
        maxTx = newMaxTx;
        emit minMaxTxUpdated(minTx, maxTx);
    }

    /** 
    * @notice disable/enable the lock to cashout
    * @dev onlyOwner
    * param status
    */
    function updateReleasedLock(bool status) external onlyOwner{
        releasedLock = status;
    }

    /**
     * @notice  Information about the minimun and maximum transaction values
     * @return  _minTx  The minimum amount of tokens that can be bridge
     * @return  _maxTx  The maximum amount of tokens that can be bridge
     */
    function getMinMaxTxValues() external view returns (uint256 _minTx, uint256 _maxTx){
        _minTx = minTx;
        _maxTx = maxTx;
    }

    /**
     * @notice  Information about the transfer tax
     * @return  _transferTax  The transfer tax
     */
    function getTransferTax() external view returns(uint256 _transferTax){
        _transferTax = transferTax;
    }
}