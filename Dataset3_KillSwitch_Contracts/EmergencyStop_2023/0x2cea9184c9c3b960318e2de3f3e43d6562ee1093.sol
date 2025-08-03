/* SPDX-License-Identifier: Custom-License
*This contract is property of Destrier LLC. You are granted permission to use all functions of this contract intended for users. 
*However, copying, modifying, or distributing the code is strictly prohibited without explicit permission from the author.
*All rights reserved. Destrier LLC, registration number 20241316871 , Colorado , USA.*/

// File: contracts/IAdminControl.sol


pragma solidity ^0.8.0;

interface IAdminControl {
    function matchOrders() external;
    function adminControl(address _user) external;
    function userRemoveOrder(address sender, uint256 orderID) external; 
    function pause() external ;
    function unpause() external;
    function setContracts( address _escrowHandler, address _USDTAddress, address _nickeliumAddress, address _multisig, address _facade ) external;

}
// File: contracts/SharedStructs.sol

pragma solidity ^0.8.0;
library SharedStructs {
    enum AssetType { Nickelium }
    enum PaymentMethod { Ether, USDT, USDC }

    struct Order {
        uint256 orderID;
        address payable user;
        uint256 price;
        uint256 amount;
        uint256 fulfilledAmount;
        AssetType assetType;
        PaymentMethod priceCurrency;
        bool authorizedBuyersOnly;
    }
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

// File: @openzeppelin/contracts/security/Pausable.sol


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

// File: contracts/INickelium.sol

pragma solidity ^0.8.0;

interface INickelium {
    function decimals() external view returns (uint8);

    function setAuthorizedAddress(address _address, bool _status) external;

    function setContracts(
        address _centralAddress,
        address _escrowHandlerAddress,
        address _adminControlAddress,
        address _usdtAddress,
        address _usdcAddress,
        address _usdcOrdersAddress,
        address _balancesContract,
        address _adminMultisig
    ) external;

    function addNickeliumToStock(uint256 amountGrams) external;

    function mint(address account, uint256 TokenUnits) external;

    function burn(address user, uint256 amount) external;

    function getAvailableNickeliumStock() external view returns (uint256);

    function checkNickeliumBalance(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function approveToken(address user, address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address _to, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function transferFromContract(address recipient, uint256 amount) external;

    function getContractBalanceEther() external view returns (uint256);

    function placeBuyOrderEther(uint256 _price, uint256 _amount) external payable;

    function placeBuyOrderUSDT(uint256 _price, uint256 _amount) external;

    function placeBuyOrderUSDC(uint256 _price, uint256 _amount) external;

    function placeSellOrderEther(uint256 _price, uint256 _amount) external;

    function placeSellOrderUSDT(uint256 _price, uint256 _amount) external;

    function placeSellOrderUSDC(uint256 _price, uint256 _amount) external;

    function RemoveOrder(uint256 orderID) external;

    function changeBuyOrderPriceEther(uint256 orderID, uint256 newPrice) external payable;

    function changeBuyOrderPriceUSDT(uint256 orderID, uint256 newPrice) external;

    function changeBuyOrderPriceUSDC(uint256 orderID, uint256 newPrice) external;

    function changeSellOrderPriceEther(uint256 orderID, uint256 newPrice) external;

    function changeSellOrderPriceUSDT(uint256 orderID, uint256 newPrice) external;

    function changeSellOrderPriceUSDC(uint256 orderID, uint256 newPrice) external;

    function getNickeliumBalance(address account) external view returns (uint256);

    function removeAllOrders() external;

    function totalSupply() external view returns (uint256);

    function pause() external;

    function unpause() external;
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: contracts/ICentral.sol

pragma solidity ^0.8.0;


interface ICentral is IERC20 {
  function approveToken(address user, address spender, uint256 amount) external returns (bool);
  function setAuthorizedBuyer(address buyer, bool _status) external;
  function isAuthorizedBuyer(address buyer) external view returns (bool);
  function transferFromUser(address from, address to, uint256 amount) external returns (bool);
  function sendEther(address payable recipient) external payable;
  function releaseEther(address payable seller, uint amount) external;
  function revertEther(address sender, uint amount) external;
  function transfer(address _to, uint256 _value) external override returns (bool);
  function getNextOrderID() external returns (uint256);
  function setContracts( address _USDTAddress, address _escrowHandler, address _adminControl, address _balancesContract, address _multisig) external;
   function decimals() external view returns (uint8);
    function addNickeliumToStock(uint256 amountGrams) external;
    function getAvailableNickeliumStock() external returns(uint);
    function getContractBalanceEther() external view returns (uint);
    function placeBuyOrderEther(address buyer, uint256 _price, uint256 _amount) external payable ;
    function placeBuyOrderUSDT(address buyer, uint256 _price, uint256 _amount)  external ;
    function placeBuyOrderUSDC(address buyer, uint256 _price, uint256 _amount) external;
    function placeSellOrderEther(address seller, uint256 _price, uint256 _amount) external ;
    function placeSellOrderUSDT(address seller, uint256 _price, uint256 _amount) external ;
    function placeSellOrderUSDC(address seller, uint256 _price, uint256 _amount) external;
    function getEtherBalance(address account) external view returns (uint);
    function checkNickeliumBalance(address account) external view returns (uint256);
    function transferFromContract(address recipient, uint256 amount) external;
    function totalNickeliumInStock() external view returns (uint256);
        
}

// File: contracts/EscrowHandler.sol

pragma solidity ^0.8.0;


//import "./ICustomMultisig.sol";





contract EscrowHandler is Pausable, ReentrancyGuard{
    
    // State variables and mappings related to escrows
    mapping(address => mapping(SharedStructs.AssetType => uint256)) public assetBalances;
    mapping(address => mapping(SharedStructs.PaymentMethod => uint256)) public escrowBalances;
    mapping(address => bool) public authorizedAddresses;

    // Buy orders separate queues for Ether and USDT
    SharedStructs.Order[] public buyOrdersEther;
    SharedStructs.Order[] public buyOrdersUSDT;
    // Sell orders separate queues for Ether and USDT
    SharedStructs.Order[] public sellOrdersEther;
    SharedStructs.Order[] public sellOrdersUSDT;
    
    // Reference to Nickelium and USDT contracts
    
    IERC20 public USDTContract;
    INickelium public nickeliumContract;
    IERC20 public USDCContract;
    address public usdcContractAddress;
    //ICustomMultisig public customMultisig; // Store the CustomMultisig contract address
    IAdminControl public adminControl; // Use the interface
    ICentral public centralContract;

    constructor() payable {
        authorizedAddresses[msg.sender] = true;
    }

    modifier onlyAuthorized() {
        require(authorizedAddresses[msg.sender], "Not authorized");
        _;
    }

    function setAuthorizedAddress(address _address, bool _status) public onlyAuthorized nonReentrant whenNotPaused {
        authorizedAddresses[_address] = _status;
    }

    address public owner;
    function setOwner(address newOwner) public onlyAuthorized {
        owner = newOwner;
    }

    function setContracts(
        address _centralAddress,
        address _USDTAddress,
        address _usdcAddress,
        address _nickeliumAddress,
        address _adminControl
        
    ) public onlyAuthorized nonReentrant whenNotPaused {
        _USDTAddress = _USDTAddress;
        USDTContract = IERC20(_USDTAddress);
        USDCContract = IERC20(_usdcAddress);  
        usdcContractAddress = _usdcAddress;   
        nickeliumContract = INickelium(_nickeliumAddress);
        adminControl = IAdminControl(_adminControl);
        centralContract = ICentral(_centralAddress);
    }

   

    function approveUSDT(address adminControlAddress, uint256 transferAmount) external onlyAuthorized whenNotPaused {
    USDTContract.approve(adminControlAddress, transferAmount);
}
    function approveUSDC(address adminControlAddress, uint256 transferAmount) external onlyAuthorized whenNotPaused {
    USDCContract.approve(adminControlAddress, transferAmount);
}


// Add a new parameter to indicate if we want to increase or decrease the balance
function updateEscrowBalance (address user, SharedStructs.PaymentMethod method, uint256 cost, bool increase) external onlyAuthorized whenNotPaused {
  
    if (increase) {
        escrowBalances[user][method] += cost;
    } else {
        require(escrowBalances[user][method] >= cost, "Insufficient balance");
        escrowBalances[user][method] -= cost;
    }
}

function getEscrowBalance(address user, SharedStructs.PaymentMethod method) public view returns (uint256) {
    return escrowBalances[user][method];
}

   function getBuyOrdersEther() public view returns (SharedStructs.Order[] memory) {
    return buyOrdersEther;
}

  function getBuyOrdersUSDT() external view returns (SharedStructs.Order[] memory) {
    return buyOrdersUSDT;
}
  function getSellOrdersEther() external view returns (SharedStructs.Order[] memory) {
    return sellOrdersEther;
}

  function getSellOrdersUSDT() external view returns (SharedStructs.Order[] memory) {
    return sellOrdersUSDT;
}
    function getAssetBalance(address user, SharedStructs.AssetType assetType) public view returns (uint256) {
    return assetBalances[user][assetType];
}
   function setAssetBalance(address _user, SharedStructs.AssetType _assetType, uint256 _amount) public onlyAuthorized nonReentrant whenNotPaused {
       
        assetBalances[_user][_assetType] = _amount;
    }

    function setEscrowBalance(address _user, SharedStructs.PaymentMethod _paymentMethod, uint256 _amount) public onlyAuthorized nonReentrant whenNotPaused {
       
        escrowBalances[_user][_paymentMethod] = _amount;
    }

    // Getter functions for the lengths of the orders arrays
    function sellOrdersEtherLength() public view returns (uint) {
        return sellOrdersEther.length;
    }

    function sellOrdersUSDTLength() public view returns (uint) {
        return sellOrdersUSDT.length;
    }

    function buyOrdersEtherLength() public view returns (uint) {
        return buyOrdersEther.length;
    }

    function buyOrdersUSDTLength() public view returns (uint) {
        return buyOrdersUSDT.length;
    }

    // Getter functions for the orders
    function getSellOrdersEther(uint index) public view returns (SharedStructs.Order memory) {
        return sellOrdersEther[index];
    }

    function getSellOrdersUSDT(uint index) public view returns (SharedStructs.Order memory) {
        return sellOrdersUSDT[index];
    }

    function getBuyOrdersEther(uint index) public view returns (SharedStructs.Order memory) {
        return buyOrdersEther[index];
    }
    
  
    function getBuyOrdersUSDT(uint index) public view returns (SharedStructs.Order memory) {
        return buyOrdersUSDT[index];
    }
    
    function getHighestBuyOrderEther() public view returns (SharedStructs.Order memory) {
        return buyOrdersEther[0];
    }

    function getLowestSellOrderEther() public view returns (SharedStructs.Order memory) {
        return sellOrdersEther[0];
    }

    function getHighestBuyOrderUSDT() public view returns (SharedStructs.Order memory) {
        return buyOrdersUSDT[0];
    }

    function getLowestSellOrderUSDT() public view returns (SharedStructs.Order memory) {
        return sellOrdersUSDT[0];
    }
    function removeBuyOrderEther(uint256 index) public onlyAuthorized {
        require(index < buyOrdersEther.length, "Index out of bounds");

        for (uint256 i = index; i < buyOrdersEther.length - 1; i++) {
            buyOrdersEther[i] = buyOrdersEther[i + 1];
        }
        buyOrdersEther.pop();
    }

    function removeSellOrderEther(uint256 index) public onlyAuthorized {
        require(index < sellOrdersEther.length, "Index out of bounds");

        for (uint256 i = index; i < sellOrdersEther.length - 1; i++) {
            sellOrdersEther[i] = sellOrdersEther[i + 1];
        }
        sellOrdersEther.pop();
    }
    function removeBuyOrderUSDT(uint256 index) public onlyAuthorized {
        require(index < buyOrdersUSDT.length, "Index out of bounds");

        for (uint256 i = index; i < buyOrdersUSDT.length - 1; i++) {
            buyOrdersUSDT[i] = buyOrdersUSDT[i + 1];
        }
        buyOrdersUSDT.pop();
    }

    function removeSellOrderUSDT(uint256 index) public onlyAuthorized {
        require(index < sellOrdersUSDT.length, "Index out of bounds");

        for (uint256 i = index; i < sellOrdersUSDT.length - 1; i++) {
            sellOrdersUSDT[i] = sellOrdersUSDT[i + 1];
        }
        sellOrdersUSDT.pop();
    }
    
    
     function addBuyOrder(uint256 _orderID, address buyer, uint256 _price, uint256 _amount, SharedStructs.AssetType _assetType, SharedStructs.PaymentMethod _priceCurrency, bool authorizedBuyersOnly) external onlyAuthorized nonReentrant whenNotPaused {
  
    SharedStructs.Order memory newOrder = SharedStructs.Order({
        orderID: _orderID,
        user: payable (buyer),
        price: _price,
        amount: _amount,
        fulfilledAmount: 0,
        assetType: _assetType,
        priceCurrency: _priceCurrency,
        authorizedBuyersOnly: authorizedBuyersOnly
    });

    if (_priceCurrency == SharedStructs.PaymentMethod.Ether) {
        buyOrdersEther.push(newOrder);
        int i = int(buyOrdersEther.length) - 1;
    while (i > 0 && buyOrdersEther[uint(i)].price > buyOrdersEther[uint(i - 1)].price) {
        SharedStructs.Order memory temp = buyOrdersEther[uint(i)];
        buyOrdersEther[uint(i)] = buyOrdersEther[uint(i - 1)];
        buyOrdersEther[uint(i - 1)] = temp;
        i--;
    }

    // If the queue is full, remove the order with the lowest price
    if (buyOrdersEther.length > 20) {
        // The order with the lowest price is at the end of the sorted array
        buyOrdersEther.pop();
    }
    } else if (_priceCurrency == SharedStructs.PaymentMethod.USDT) {
        
        buyOrdersUSDT.push(newOrder);
        int i = int(buyOrdersUSDT.length) - 1;
    while (i > 0 && buyOrdersUSDT[uint(i)].price > buyOrdersUSDT[uint(i - 1)].price) {
        SharedStructs.Order memory temp = buyOrdersUSDT[uint(i)];
        buyOrdersUSDT[uint(i)] = buyOrdersUSDT[uint(i - 1)];
        buyOrdersUSDT[uint(i - 1)] = temp;
        i--;

    }

    // If the queue is full, remove the order with the lowest price
    if (buyOrdersUSDT.length > 20) {
        // The order with the lowest price is at the end of the sorted array
        buyOrdersUSDT.pop();
    }
    }
   adminControl.matchOrders();
    }

    
      function addSellOrder(uint256 _orderID, address seller, uint256 _price, uint256 _amount, SharedStructs.AssetType _assetType, SharedStructs.PaymentMethod _priceCurrency, bool authorizedBuyersOnly) external onlyAuthorized nonReentrant whenNotPaused {
   
    // Update the asset balance in escrow
    assetBalances[seller][SharedStructs.AssetType.Nickelium] += _amount;
    SharedStructs.Order memory newOrder = SharedStructs.Order({
        orderID: _orderID,
        user: payable (seller),
        price: _price,
        amount: _amount,
        fulfilledAmount: 0,
        assetType: _assetType,
        priceCurrency: _priceCurrency,
        authorizedBuyersOnly: authorizedBuyersOnly
    
    });

    if (_priceCurrency == SharedStructs.PaymentMethod.Ether) {
        sellOrdersEther.push(newOrder);
        int i = int(sellOrdersEther.length) - 1;
    while (i > 0 && sellOrdersEther[uint(i)].price < sellOrdersEther[uint(i - 1)].price) {
        SharedStructs.Order memory temp = sellOrdersEther[uint(i)];
        sellOrdersEther[uint(i)] = sellOrdersEther[uint(i - 1)];
        sellOrdersEther[uint(i - 1)] = temp;
        i--;
    }

    // If the queue is full, remove the order with the highest price
    if (sellOrdersEther.length > 20) {
        // The order with the highest price is at the end of the sorted array
        sellOrdersEther.pop();
    }
    } else if (_priceCurrency == SharedStructs.PaymentMethod.USDT) {
        sellOrdersUSDT.push(newOrder);
        int i = int(sellOrdersUSDT.length) - 1;
    while (i > 0 && sellOrdersUSDT[uint(i)].price < sellOrdersUSDT[uint(i - 1)].price) {
        SharedStructs.Order memory temp = sellOrdersUSDT[uint(i)];
        sellOrdersUSDT[uint(i)] = sellOrdersUSDT[uint(i - 1)];
        sellOrdersUSDT[uint(i - 1)] = temp;
        i--;
    }

    // If the queue is full, remove the order with the highest price
    if (sellOrdersUSDT.length > 20) {
        // The order with the highest price is at the end of the sorted array
        sellOrdersUSDT.pop();
    }
    }
    adminControl.matchOrders();
}

      
function transferFromAsset (address seller, address payable buyer, uint256 amount) external onlyAuthorized whenNotPaused {
   
    // Decrease the seller's escrow balance
    assetBalances[seller][SharedStructs.AssetType.Nickelium] -= amount;

    // Transfer tokens from this contract to the buyer
   
    nickeliumContract.transferFromContract(buyer, amount);

}
       
       function repositionOrder(SharedStructs.Order[] storage orders, uint256 index, bool isAscending) internal {
    uint256 j = index;

    // Handle ascending order (used for sell orders)
    if (isAscending) {
        // Move up if the new price is lower
        while (j > 0 && orders[j].price < orders[j - 1].price) {
            SharedStructs.Order memory temp = orders[j];
            orders[j] = orders[j - 1];
            orders[j - 1] = temp;
            j--;
        }
        // Move down if the new price is higher
        while (j < orders.length - 1 && orders[j].price > orders[j + 1].price) {
            SharedStructs.Order memory temp = orders[j];
            orders[j] = orders[j + 1];
            orders[j + 1] = temp;
            j++;
        }
    } else { // Handle descending order (used for buy orders)
        // Move up if the new price is higher
        while (j > 0 && orders[j].price > orders[j - 1].price) {
            SharedStructs.Order memory temp = orders[j];
            orders[j] = orders[j - 1];
            orders[j - 1] = temp;
            j--;
        }
        // Move down if the new price is lower
        while (j < orders.length - 1 && orders[j].price < orders[j + 1].price) {
            SharedStructs.Order memory temp = orders[j];
            orders[j] = orders[j + 1];
            orders[j + 1] = temp;
            j++;
        }
    }
}


function changeBuyOrderPriceEther(address buyer, uint256 orderID, uint256 newPrice) external payable onlyAuthorized nonReentrant whenNotPaused {
    for (uint256 i = 0; i < buyOrdersEther.length; i++) {
        if (buyOrdersEther[i].orderID == orderID) {
            SharedStructs.Order storage order = buyOrdersEther[i];
            require(order.user == buyer, "Only the owner can change the price");

            uint256 remainingAmount = order.amount - order.fulfilledAmount;
            uint256 oldCost = order.price * (remainingAmount / 1000);
            uint256 newCost = newPrice * (remainingAmount / 1000);

            if (newCost > oldCost) {
                uint256 additionalCost = newCost - oldCost;
                require(msg.value >= additionalCost, "Insufficient Ether for price change");
                uint256 excessAmount = msg.value - additionalCost;
                if (excessAmount > 0) {
                    payable(buyer).transfer(excessAmount);
                }
                payable(address(centralContract)).transfer(additionalCost);
                escrowBalances[order.user][SharedStructs.PaymentMethod.Ether] += additionalCost;
            } else {
                uint256 refund = oldCost - newCost;
                require(escrowBalances[buyer][SharedStructs.PaymentMethod.Ether] >= refund, "Insufficient escrow balance");
                centralContract.revertEther(order.user, refund);
                escrowBalances[order.user][SharedStructs.PaymentMethod.Ether] -= refund;
            }

            // Update the price of the order
            order.price = newPrice;

            // Reposition the order
            repositionOrder(buyOrdersEther, i, false); // false for descending order

            // Match orders again
            adminControl.matchOrders();
            return;
        }
    }
    revert("Order not found");
}

function changeBuyOrderPriceUSDT(address buyer, uint256 orderID, uint256 newPrice) external onlyAuthorized nonReentrant whenNotPaused {
    for (uint256 i = 0; i < buyOrdersUSDT.length; i++) {
        if (buyOrdersUSDT[i].orderID == orderID) {
            SharedStructs.Order storage order = buyOrdersUSDT[i];
            require(order.user == buyer, "Only the owner can change the price");

            uint256 remainingAmount = order.amount - order.fulfilledAmount;
            uint256 oldCost = order.price * (remainingAmount / 1000);
            uint256 newCost = newPrice * (remainingAmount / 1000);

            if (newCost > oldCost) {
                uint256 additionalCost = newCost - oldCost;
                escrowBalances[order.user][SharedStructs.PaymentMethod.USDT] += additionalCost;
            } else {
                uint256 refund = oldCost - newCost;
                require(escrowBalances[order.user][SharedStructs.PaymentMethod.USDT] >= refund, "Insufficient escrow balance for refund");
                USDTContract.transfer(order.user, refund);
                escrowBalances[order.user][SharedStructs.PaymentMethod.USDT] -= refund;
            }

            // Update the price of the order
            order.price = newPrice;

            // Reposition the order
            repositionOrder(buyOrdersUSDT, i, false); // false for descending order

            // Match orders again
            adminControl.matchOrders();
            return;
        }
    }
    revert("Order not found");
}

function changeSellOrderPriceEther(address seller, uint256 orderID, uint256 newPrice) external onlyAuthorized nonReentrant whenNotPaused {
    for (uint256 i = 0; i < sellOrdersEther.length; i++) {
        if (sellOrdersEther[i].orderID == orderID) {
            SharedStructs.Order storage order = sellOrdersEther[i];
            require(order.user == seller, "Only the owner can change the price");

            // Update the price of the order
            order.price = newPrice;

            // Reposition the order
            repositionOrder(sellOrdersEther, i, true); // true for ascending order

            // Match orders again
            adminControl.matchOrders();
            return;
        }
    }
    revert("Order not found");
}

function changeSellOrderPriceUSDT(address seller, uint256 orderID, uint256 newPrice) external onlyAuthorized nonReentrant whenNotPaused {
    for (uint256 i = 0; i < sellOrdersUSDT.length; i++) {
        if (sellOrdersUSDT[i].orderID == orderID) {
            SharedStructs.Order storage order = sellOrdersUSDT[i];
            require(order.user == seller, "Only the owner can change the price");

            // Update the price of the order
            order.price = newPrice;

            // Reposition the order
            repositionOrder(sellOrdersUSDT, i, true); // true for ascending order

            // Match orders again
            adminControl.matchOrders();
            return;
        }
    }
    revert("Order not found");
}


    function pause() external onlyAuthorized nonReentrant whenNotPaused {
        _pause();
    }

    function unpause() external onlyAuthorized nonReentrant {
        _unpause();
    }

    function updateOrderAmount(uint256 index, uint256 newAmount, bool isBuyOrder, bool isEther) external onlyAuthorized {
    if (isEther) {
        if (isBuyOrder) {
            require(index < buyOrdersEther.length, "Index out of bounds");
            buyOrdersEther[index].amount = newAmount;
        } else {
            require(index < sellOrdersEther.length, "Index out of bounds");
            sellOrdersEther[index].amount = newAmount;
        }
    } else { // USDT
        if (isBuyOrder) {
            require(index < buyOrdersUSDT.length, "Index out of bounds");
            buyOrdersUSDT[index].amount = newAmount;
        } else {
            require(index < sellOrdersUSDT.length, "Index out of bounds");
            sellOrdersUSDT[index].amount = newAmount;
        }
    }
}


}