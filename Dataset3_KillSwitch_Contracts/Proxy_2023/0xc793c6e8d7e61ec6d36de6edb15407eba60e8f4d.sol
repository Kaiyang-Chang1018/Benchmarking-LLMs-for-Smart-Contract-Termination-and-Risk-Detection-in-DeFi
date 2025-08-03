/* SPDX-License-Identifier: Custom-License
*This contract is property of Destrier LLC. You are granted permission to use all functions of this contract intended for users. 
*However, copying, modifying, or distributing the code is strictly prohibited without explicit permission from the author.
*All rights reserved. Destrier LLC, registration number 20241316871 , Colorado , USA.*/

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

// File: contracts/IEscrowHandler.sol


pragma solidity ^0.8.0;

interface IEscrowHandler {
    function escrowBalances(address user, SharedStructs.PaymentMethod paymentMethod) external view returns (uint256);
    function assetBalances(address user, uint256 assetType) external view returns (uint256);
    function updateEscrowBalance(address user, SharedStructs.PaymentMethod method, uint256 cost, bool increase) external payable;
    function getEscrowBalance(address user, SharedStructs.PaymentMethod method) external view returns (uint256) ;
    function getBuyOrdersEther() external view returns (SharedStructs.Order[] memory);
    function getBuyOrdersUSDT() external view returns (SharedStructs.Order[] memory);
    function getSellOrdersEther() external view returns (SharedStructs.Order[] memory);
    function getSellOrdersUSDT() external view returns (SharedStructs.Order[] memory);
    function getAssetBalance(address user, SharedStructs.AssetType assetType) external view returns (uint256);
    function setAssetBalance(address _user, SharedStructs.AssetType _assetType, uint256 _amount) external;
    function setEscrowBalance(address _user, SharedStructs.PaymentMethod _paymentMethod, uint256 _amount) external;
    function sellOrdersEtherLength() external view returns (uint);
    function sellOrdersUSDTLength() external view returns (uint);
    function buyOrdersEtherLength() external view returns (uint);
    function buyOrdersUSDTLength() external view returns (uint);
    function getSellOrdersEther(uint index) external view returns (SharedStructs.Order memory);
    function getSellOrdersUSDT(uint index) external view returns (SharedStructs.Order memory);
    function getBuyOrdersEther(uint index) external view returns (SharedStructs.Order memory);
    function getBuyOrdersUSDT(uint index) external view returns (SharedStructs.Order memory);
    function getHighestBuyOrderEther() external view returns (SharedStructs.Order memory);
    function getLowestSellOrderEther() external view returns (SharedStructs.Order memory);
    function getHighestBuyOrderUSDT() external view returns (SharedStructs.Order memory);
    function getLowestSellOrderUSDT() external view returns (SharedStructs.Order memory);
    function removeBuyOrderEther(uint256 index) external;
    function removeSellOrderEther(uint256 index) external;
    function removeBuyOrderUSDT(uint256 index) external;
    function removeSellOrderUSDT(uint256 index) external;
    function userRemoveOrder(uint256 orderID) external;
    function addBuyOrder(uint256 _orderID, address buyer, uint256 _price, uint256 _amount, SharedStructs.AssetType _assetType, SharedStructs.PaymentMethod _priceCurrency, bool authorizedBuyersOnly) external;
    function addSellOrder(uint256 _orderID, address seller, uint256 _price, uint256 _amount, SharedStructs.AssetType _assetType, SharedStructs.PaymentMethod _priceCurrency, bool authorizedBuyersOnly) external;
    function transferFromAsset(address seller, address payable buyer, uint256 amount) external;
    function changeBuyOrderPriceEther(address buyer, uint256 orderID, uint256 newPrice) external payable;
    function changeBuyOrderPriceUSDT(address buyer, uint256 orderID, uint256 newPrice) external;
    function changeSellOrderPriceEther(address seller, uint256 orderID, uint256 newPrice) external;
    function changeSellOrderPriceUSDT(address seller, uint256 orderID, uint256 newPrice) external;
    function setContracts( address _USDTAddress, address _nickeliumAddress, address _adminControl, address _customMultisig, address _facade) external;
    function approveUSDT(address adminControlAddress, uint256 transferAmount) external;
    function approveUSDC(address adminControlAddress, uint256 transferAmount) external;
    function updateOrderAmount(uint256 index, uint256 newAmount, bool isBuyOrder, bool isEther) external;
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

// File: contracts/CustomMultisig.sol


pragma solidity ^0.8.0;

contract CustomMultisig is Pausable, ReentrancyGuard {
         address public owner1;
    address public owner2;
    bool public isConfirmedByOwner1;
    bool public isConfirmedByOwner2;
     IERC20 public USDTContract;
     IERC20 public USDCContract;
     INickelium public nickelium;
    INickelium public nickeliumContract;
    IEscrowHandler public escrowHandler;
    IAdminControl public adminControlContract;
    ICentral public centralContract;
    uint256 public defaultIndex = 0;

    // Import AssetType and PaymentMethod from SharedStructs
    using SharedStructs for SharedStructs.AssetType;
    using SharedStructs for SharedStructs.PaymentMethod;

    /*address public owner;
    function setOwner(address newOwner) public onlyAuthorized {
        owner = newOwner;
    }*/

    // Store pending order details
    struct PendingOrder {
        uint256 orderID;
        address payable user;
        uint256 price;
        uint256 amount;
        SharedStructs.AssetType assetType;
        SharedStructs.PaymentMethod priceCurrency;
        bool isConfirmedByOwner1;
        bool isConfirmedByOwner2;
        string orderType;
        bool authorizedBuyersOnly;
    }

   struct TransferStatus {
        bool isConfirmedByOwner1;
        bool isConfirmedByOwner2;
        uint256 amount;
        address recipientAddress;
        SharedStructs.PaymentMethod paymentMethod;
        uint256 orderID;
    }

    struct TransferStatusNickelium {
        bool isConfirmedByOwner1;
        bool isConfirmedByOwner2;
        uint256 amount;
        address recipientAddress;
        SharedStructs.AssetType assetType;
        uint256 orderID;
    }


// State variables for multi-signature actions
    enum ActionType { AddNickeliumToStock, Mint, Burn }
    struct Action {
        ActionType actionType;
        uint256 amountGrams; // Used for AddNickeliumToStock
        address account; // Used for Mint
        uint256 tokenUnits; // Used for Mint
        uint256 burnAmount; // Used for Burn
        address tokenOwner; // used for burn
        bool isConfirmedByOwner1;
        bool isConfirmedByOwner2;
    }
    
    mapping(uint256 => Action) public actions;
    uint256 public nextActionId;
    mapping(uint256 => PendingOrder) public pendingOrders;
    mapping(uint256 => TransferStatus) public transferStatus;
    mapping(uint256 => TransferStatusNickelium) public transferStatusNickelium;
    uint256[] public indexes; // Auxiliary array to store order IDs
    mapping(address => bool) public authorizedAddresses;

    constructor() {
               authorizedAddresses[msg.sender] = true;
    }
function setOwners(address _owner1, address _owner2) external onlyAuthorized nonReentrant whenNotPaused{
        owner1 = _owner1;
        owner2 = _owner2;
    }

    modifier onlyAuthorized() {
        require(authorizedAddresses[msg.sender], "Not authorized");
        _;
    }

    function setAuthorizedAddress(address _address, bool _status) public onlyAuthorized nonReentrant whenNotPaused{
        authorizedAddresses[_address] = _status;
    }

    function setContracts(
        address payable _nickeliumAddress,
        address _centralAddress,
        address _USDTAddress,
        address _usdcAddress,
        address _escrowHandler,
        address _adminControlAddress
    ) external onlyAuthorized nonReentrant whenNotPaused {
        // Set Nickelium and its interface
        nickeliumContract = INickelium(_nickeliumAddress);
        nickelium = INickelium(_nickeliumAddress);

        centralContract = ICentral(_centralAddress);

        // Set USDTContract
        USDTContract = IERC20(_USDTAddress);

        // Set USDCContract and address
    USDCContract = IERC20(_usdcAddress); 

        // Set EscrowHandler
        escrowHandler = IEscrowHandler(_escrowHandler);

        // Set AdminControl
        adminControlContract = IAdminControl(_adminControlAddress);
    }
    
// Fallback function to handle incoming Ether
    fallback() external payable {
        // Log an event or update state as needed
        emit EtherReceived(msg.sender, msg.value);
    }
    event EtherReceived(address indexed sender, uint256 amount);

    modifier actionExists(uint256 actionId) {
    require(actions[actionId].actionType == ActionType.AddNickeliumToStock || actions[actionId].actionType == ActionType.Mint || actions[actionId].actionType == ActionType.Burn, "Action does not exist");
    _;
}

    modifier notAlreadyConfirmed(uint256 actionId) {
        Action memory action = actions[actionId];
        require(msg.sender == owner1 && !action.isConfirmedByOwner1 || msg.sender == owner2 && !action.isConfirmedByOwner2, "Action already confirmed by this owner");
        _;
    }
    
    modifier onlyOwners() {
        require(msg.sender == owner1 || msg.sender == owner2, "Not an owner");
        _;
    }
    modifier onlyEscrowHandler() {
    require(msg.sender == address(escrowHandler), "Unauthorized caller");
    _;
}
    
    function addNickeliumToStock(uint256 amountGrams) internal {
        nickelium.addNickeliumToStock(amountGrams);
    }

function RemoveAllOrders (address _user) public onlyOwners nonReentrant whenNotPaused {
        adminControlContract.adminControl(_user);
    }

    function proposeAddNickeliumToStock(uint256 amountGrams) public onlyOwners nonReentrant whenNotPaused {
        uint256 actionId = nextActionId++;
        actions[actionId] = Action({
            actionType: ActionType.AddNickeliumToStock,
            amountGrams: amountGrams,
            account: address(0), // Not used for AddNickeliumToStock
            tokenUnits: 0, // Not used for AddNickeliumToStock
            burnAmount: 0, // Not used for AddNickeliumToStock
            tokenOwner: address(0),
            isConfirmedByOwner1: false,
            isConfirmedByOwner2: false
        });
    }

    function proposeMint(address account, uint256 tokenUnits) public onlyOwners nonReentrant whenNotPaused {
        uint256 actionId = nextActionId++;
        actions[actionId] = Action({
            actionType: ActionType.Mint,
            amountGrams: 0, // Not used for Mint
            account: account,
            tokenUnits: tokenUnits,
            burnAmount: 0, // Not used for Mint
            tokenOwner: address(0),
            isConfirmedByOwner1: false,
            isConfirmedByOwner2: false
        });
    }

    function proposeBurn(uint256 amount) public onlyOwners nonReentrant whenNotPaused {
        uint256 actionId = nextActionId++;
        actions[actionId] = Action({
            actionType: ActionType.Burn,
            amountGrams: 0, // Not used for burn action
            account: address(0), // Not used for burn action
            tokenUnits: 0, // Not used for burn action
            burnAmount: amount,
            tokenOwner: address(this), // i burn only this contract tokens
            isConfirmedByOwner1: false,
            isConfirmedByOwner2: false
        });
    }
    
    function confirmAction(uint256 actionId) public onlyOwners actionExists(actionId) notAlreadyConfirmed(actionId) nonReentrant whenNotPaused{
        Action storage action = actions[actionId];
        
        if (msg.sender == owner1) {
            action.isConfirmedByOwner1 = true;
        } else if ( msg.sender == owner2) {
            action.isConfirmedByOwner2 = true;
        }

        if (action.isConfirmedByOwner1 && action.isConfirmedByOwner2) {
            executeAction(actionId);
        }
    }

    function executeAction(uint256 actionId) internal {
        Action memory action = actions[actionId];

        if (action.actionType == ActionType.AddNickeliumToStock) {
            nickelium.addNickeliumToStock(action.amountGrams);
        } else if (action.actionType == ActionType.Mint) {
            nickelium.mint(action.account, action.tokenUnits);
        } else if (action.actionType == ActionType.Burn) {
            nickelium.burn(action.tokenOwner, action.burnAmount);
        }

        delete actions[actionId]; // Remove the action once executed
        // Remove the action ID from the indexes array
    for (uint256 i = 0; i < indexes.length; i++) {
        if (indexes[i] == actionId) {
            indexes[i] = indexes[indexes.length - 1];
            indexes.pop();
            break;
        }
    }
    }

    function transferEtherToCentral(uint256 amount) internal {
        //require(msg.sender == owner1 || msg.sender == owner2, "Unauthorized");
        require(address(this).balance >= amount, "Insufficient contract balance");
        //nickeliumContract.transfer(address(this), amount);
        payable(address(centralContract)).transfer(amount);
    }
    
   
     function CreateBuyOrderEther (
       //uint256 _orderID,
        uint256 _price,
        uint256 _amount
        
    ) external onlyOwners nonReentrant whenNotPaused {
        require(_price * _amount / _price == _amount, "Potential overflow");
        // Create a pending order
        // Get the next order ID from the Nickelium contract
        uint256 _orderID = centralContract.getNextOrderID();
        //uint256 index = indexes.length; // Use the array length as the order ID
        pendingOrders[_orderID] = PendingOrder({
            orderID: _orderID,
            user: payable(address(this)),
           // owner: payable(msg.sender),
            price: _price,
            amount: _amount,
            assetType: SharedStructs.AssetType.Nickelium, 
            priceCurrency: SharedStructs.PaymentMethod.Ether,
            isConfirmedByOwner1: false,
            isConfirmedByOwner2: false,
            orderType: "Buy",
            authorizedBuyersOnly: false
        });
        indexes.push(_orderID); // Add the order ID to the auxiliary array
    }
    function CreateBuyOrderUSDT(
        //uint256 _orderID,
        uint256 _price,
        uint256 _amount
         
     ) external onlyOwners nonReentrant whenNotPaused {
        require(_price * _amount / _price == _amount, "Potential overflow");
         // Create a pending order
         // Get the next order ID from the Nickelium contract
        uint256 _orderID = centralContract.getNextOrderID();
         //*uint256 index = indexes.length; // Use the array length as the order ID*/
        pendingOrders[_orderID] = PendingOrder({
            orderID: _orderID,
            user: payable(address(this)),
           // owner: payable(msg.sender),
            price: _price,
            amount: _amount,
            assetType: SharedStructs.AssetType.Nickelium, 
            priceCurrency: SharedStructs.PaymentMethod.USDT,
            isConfirmedByOwner1: false,
            isConfirmedByOwner2: false,
            orderType: "Buy",
            authorizedBuyersOnly: false
         });
        indexes.push(_orderID); // Add the order ID to the auxiliary array
     }

     function CreateBuyOrderUSDC(
        //uint256 _orderID,
        uint256 _price,
        uint256 _amount
         
     ) external onlyOwners nonReentrant whenNotPaused {
        require(_price * _amount / _price == _amount, "Potential overflow");
         // Create a pending order
         // Get the next order ID from the Nickelium contract
        uint256 _orderID = centralContract.getNextOrderID();
         //*uint256 index = indexes.length; // Use the array length as the order ID*/
        pendingOrders[_orderID] = PendingOrder({
            orderID: _orderID,
            user: payable(address(this)),
           // owner: payable(msg.sender),
            price: _price,
            amount: _amount,
            assetType: SharedStructs.AssetType.Nickelium, 
            priceCurrency: SharedStructs.PaymentMethod.USDC,
            isConfirmedByOwner1: false,
            isConfirmedByOwner2: false,
            orderType: "Buy",
            authorizedBuyersOnly: false
         });
        indexes.push(_orderID); // Add the order ID to the auxiliary array
     }

    function CreateSellOrderEther(
       //uint256 _orderID,
        uint256 _price,
        uint256 _amount,
        bool _authorizedBuyersOnly
        
    ) external onlyOwners nonReentrant whenNotPaused {
        require(_price * _amount / _price == _amount, "Potential overflow");
        // Create a pending order
        // Get the next order ID from the Nickelium contract
        uint256 _orderID = centralContract.getNextOrderID();
        //uint256 index = indexes.length; // Use the array length as the order ID
        pendingOrders[_orderID] = PendingOrder({
            orderID: _orderID,
            user: payable(address(this)),
         //   owner: payable(msg.sender),
            price: _price,
            amount: _amount,
            assetType: SharedStructs.AssetType.Nickelium, 
            priceCurrency: SharedStructs.PaymentMethod.Ether,
            isConfirmedByOwner1: false,
            isConfirmedByOwner2: false,
            orderType: "Sell",
            authorizedBuyersOnly: _authorizedBuyersOnly 
        });
        indexes.push(_orderID); // Add the order ID to the auxiliary array
    }

    function CreateSellOrderUSDT(
       //uint256 _orderID,
        uint256 _price,
        uint256 _amount,
        bool _authorizedBuyersOnly
        
    ) external onlyOwners nonReentrant whenNotPaused {
        require(_price * _amount / _price == _amount, "Potential overflow");
        // Create a pending order
        // Get the next order ID from the Nickelium contract
        uint256 _orderID = centralContract.getNextOrderID();
        //uint256 index = indexes.length; // Use the array length as the order ID
        pendingOrders[_orderID] = PendingOrder({
            orderID: _orderID,
            user: payable(address(this)),
         //   owner: payable(msg.sender),
            price: _price,
            amount: _amount,
            assetType: SharedStructs.AssetType.Nickelium, 
            priceCurrency: SharedStructs.PaymentMethod.USDT,
            //assetType: _assetType,
            //priceCurrency: _priceCurrency,
            isConfirmedByOwner1: false,
            isConfirmedByOwner2: false,
            orderType: "Sell",
            authorizedBuyersOnly: _authorizedBuyersOnly
        });
        indexes.push(_orderID); 
    }

    function CreateSellOrderUSDC(
       //uint256 _orderID,
        uint256 _price,
        uint256 _amount,
        bool _authorizedBuyersOnly
        
    ) external onlyOwners nonReentrant whenNotPaused {
        require(_price * _amount / _price == _amount, "Potential overflow");
        // Create a pending order
        // Get the next order ID from the Nickelium contract
        uint256 _orderID = centralContract.getNextOrderID();
        //uint256 index = indexes.length; // Use the array length as the order ID
        pendingOrders[_orderID] = PendingOrder({
            orderID: _orderID,
            user: payable(address(this)),
         //   owner: payable(msg.sender),
            price: _price,
            amount: _amount,
            assetType: SharedStructs.AssetType.Nickelium, 
            priceCurrency: SharedStructs.PaymentMethod.USDC,
            isConfirmedByOwner1: false,
            isConfirmedByOwner2: false,
            orderType: "Sell",
            authorizedBuyersOnly: _authorizedBuyersOnly
        });
        indexes.push(_orderID); // Add the order ID to the auxiliary array
    }

    
    function confirmOrder(uint256 _orderID) external onlyOwners nonReentrant whenNotPaused {
    PendingOrder storage order = pendingOrders[_orderID];
    if (msg.sender == owner1) {
        order.isConfirmedByOwner1 = true;
    } else if (msg.sender == owner2) {
        order.isConfirmedByOwner2 = true;
    }
}
    
     function confirmTransfer(uint256 _orderID) external onlyOwners nonReentrant whenNotPaused {
    if (_orderID >= indexes.length) {
        revert("Invalid order ID");
    }

    if (transferStatus[_orderID].orderID == _orderID) {
        TransferStatus storage order = transferStatus[_orderID];
        if (msg.sender == owner1) {
            order.isConfirmedByOwner1 = true;
        } else if (msg.sender == owner2) {
            order.isConfirmedByOwner2 = true;
        }
    } else if (transferStatusNickelium[_orderID].orderID == _orderID) {
        TransferStatusNickelium storage order = transferStatusNickelium[_orderID];
        if (msg.sender == owner1) {
            order.isConfirmedByOwner1 = true;
        } else if (msg.sender == owner2) {
            order.isConfirmedByOwner2 = true;
        }
    }
}

function CancelConfirmTransfer(uint256 _orderID) external onlyOwners nonReentrant whenNotPaused {
    TransferStatus storage order = transferStatus[_orderID]; // Retrieve struct by ID
    if (msg.sender == owner1) {
        order.isConfirmedByOwner1 = false; // Modify field within retrieved struct
    } else if (msg.sender == owner2) {
        order.isConfirmedByOwner2 = false;
    }
}

    
    function createTransferEther(
    address _recipientAddress,
    uint256 _amount
) public onlyOwners nonReentrant whenNotPaused {
    uint256 orderID = indexes.length;
    transferStatus[orderID] = TransferStatus(
        false, // isConfirmedByOwner1
        false, // isConfirmedByOwner2
        _amount,
        _recipientAddress,
        SharedStructs.PaymentMethod.Ether, // Payment method for Ether
        orderID
    );
    indexes.push(orderID);
}

function createTransferUSDT(
    address _recipientAddress,
    uint256 _amount
) public onlyOwners nonReentrant whenNotPaused {
    uint256 orderID = indexes.length;
    transferStatus[orderID] = TransferStatus(
        false, // isConfirmedByOwner1
        false, // isConfirmedByOwner2
        _amount,
        _recipientAddress,
        SharedStructs.PaymentMethod.USDT, // Payment method for USDT
        orderID
    );
    indexes.push(orderID);
}

function createTransferUSDC(
    address _recipientAddress,
    uint256 _amount
) public onlyOwners nonReentrant whenNotPaused {
    uint256 orderID = indexes.length;
    transferStatus[orderID] = TransferStatus(
        false, // isConfirmedByOwner1
        false, // isConfirmedByOwner2
        _amount,
        _recipientAddress,
        SharedStructs.PaymentMethod.USDC, // Payment method for USDC
        orderID
    );
    indexes.push(orderID);
}

function createTransferNickelium(
    address _recipientAddress,
    uint256 _amount
) public onlyOwners nonReentrant whenNotPaused {
    uint256 orderID = indexes.length;
    transferStatusNickelium[orderID] = TransferStatusNickelium(
        false, // isConfirmedByOwner1
        false, // isConfirmedByOwner2
        _amount,
        _recipientAddress,
        SharedStructs.AssetType.Nickelium, // Only for Nickelium transfers
        orderID
    );
    indexes.push(orderID);
}

    function executeTransfer(uint256 _orderID) public onlyOwners nonReentrant whenNotPaused {
    // Check for a payment transfer in transferStatus
    if (transferStatus[_orderID].recipientAddress != address(0)) { // Check if the orderID exists
        TransferStatus storage transfer = transferStatus[_orderID];
        require(transfer.isConfirmedByOwner1 && transfer.isConfirmedByOwner2, "Both confirmations required");

        if (transfer.paymentMethod == SharedStructs.PaymentMethod.Ether) {
            // Handle Ether transfer
            require(address(this).balance >= transfer.amount, "Insufficient Ether balance");
            payable(transfer.recipientAddress).transfer(transfer.amount);

        } else if (transfer.paymentMethod == SharedStructs.PaymentMethod.USDT) {
            // Handle USDT transfer
            require(USDTContract.balanceOf(address(this)) >= transfer.amount, "Insufficient USDT balance");
            require(USDTContract.transfer(transfer.recipientAddress, transfer.amount), "USDT transfer failed");

        } else if (transfer.paymentMethod == SharedStructs.PaymentMethod.USDC) {
            // Handle USDC transfer
            require(USDCContract.balanceOf(address(this)) >= transfer.amount, "Insufficient USDC balance");
            require(USDCContract.transfer(transfer.recipientAddress, transfer.amount), "USDC transfer failed");
        }

        // Delete the order after successful execution
        delete transferStatus[_orderID];
    } else {
        // Now check for Nickelium transfers in transferStatusNickelium
        TransferStatusNickelium storage nickeliumTransfer = transferStatusNickelium[_orderID];
        require(nickeliumTransfer.recipientAddress != address(0), "No Nickelium transfer with this orderID"); // Check if it exists
        require(nickeliumTransfer.isConfirmedByOwner1 && nickeliumTransfer.isConfirmedByOwner2, "Both confirmations required");
        require(nickeliumContract.balanceOf(address(this)) >= nickeliumTransfer.amount, "Insufficient Nickelium balance");
        require(nickeliumContract.transfer(nickeliumTransfer.recipientAddress, nickeliumTransfer.amount), "Nickelium transfer failed");

        // Delete the order after successful execution
        delete transferStatusNickelium[_orderID];
    }
}

     function DisplayTransferDetails(uint256 _orderID) external view returns (
    bool ConfirmedByOwner1,
    bool ConfirmedByOwner2,
    uint256 amount,
    address recipientAddress,
    uint256 orderID
) {
    if (_orderID >= indexes.length) {
        revert("Invalid order ID");
    }

    if (transferStatus[_orderID].orderID == _orderID) {
        TransferStatus memory order = transferStatus[_orderID];
        return (
            order.isConfirmedByOwner1,
            order.isConfirmedByOwner2,
            order.amount,
            order.recipientAddress,
            order.orderID
        );
    } else if (transferStatusNickelium[_orderID].orderID == _orderID) {
        TransferStatusNickelium memory order = transferStatusNickelium[_orderID];
        return (
            order.isConfirmedByOwner1,
            order.isConfirmedByOwner2,
            order.amount,
            order.recipientAddress,
            order.orderID
        );
    } else {
        revert("Order not found");
    }
}
    
         function DisplayAllTransfers() external view returns (TransferStatus[] memory, TransferStatusNickelium[] memory) {
    uint256[] storage storageIndexes = indexes;
    
    TransferStatus[] memory allTransfers = new TransferStatus[](storageIndexes.length);
    TransferStatusNickelium[] memory allTransfersNickelium = new TransferStatusNickelium[](storageIndexes.length);
    
    for (uint256 i = 0; i < storageIndexes.length; i++) {
        if (transferStatus[storageIndexes[i]].orderID == storageIndexes[i]) {
            allTransfers[i] = transferStatus[storageIndexes[i]];
        } else if (transferStatusNickelium[storageIndexes[i]].orderID == storageIndexes[i]) {
            allTransfersNickelium[i] = transferStatusNickelium[storageIndexes[i]];
        }
    }
    return (allTransfers, allTransfersNickelium);
   }

     function deleteTransfer(uint256 _orderID) public onlyOwners whenNotPaused {
    uint256 indexToDelete = 0;
    bool found = false;

    for (uint256 i = 0; i < indexes.length; i++) {
        if (indexes[i] == _orderID) {
            indexToDelete = i;
            found = true;
            break;
        }
    }
    require(found, "Order not found in the list");

    delete transferStatus[_orderID];
    delete transferStatusNickelium[_orderID];

    for (uint256 i = indexToDelete; i < indexes.length - 1; i++) {
        indexes[i] = indexes[i + 1];
    }
    indexes.pop();
}


    function cancelConfirmOrder(uint256 _orderID) external onlyOwners nonReentrant whenNotPaused {
        PendingOrder storage order = pendingOrders[_orderID];
    if (msg.sender == owner1) {
               order.isConfirmedByOwner1 = false;
    } else if (msg.sender == owner2) {
              order.isConfirmedByOwner2 = false;
    }
}
       function executeOrder(uint256 _orderID) external payable onlyOwners nonReentrant whenNotPaused {
        PendingOrder storage order = pendingOrders[_orderID];
        require(order.isConfirmedByOwner1 && order.isConfirmedByOwner2, "Both parties must confirm");

        if (keccak256(bytes(order.orderType)) == keccak256("Buy")) {
            executeBuyOrder(_orderID);
        } else if (keccak256(bytes(order.orderType)) == keccak256("Sell")) {
            executeSellOrder(_orderID);
        }
    }

 function executeBuyOrder(uint256 _orderID) internal {
        PendingOrder storage order = pendingOrders[_orderID];
        require(order.isConfirmedByOwner1 == true && order.isConfirmedByOwner2 == true, "Both parties must confirm");
                // Retrieve the amount from the order
    uint256 _amount = order.amount;
    uint256 _price = order.price;
    //require(nickeliumContract.balanceOf(address(this)) >= _amount, "Insufficient balance for the operation");
    require(order.price > 0, "This order is not exist");
    address buyer = payable (address(this)); // Capture user address
   // require(msg.value >= _price * _amount, "Insufficient Ether for buy order");
    uint256 cost = _price * (_amount / 1000);
if (order.priceCurrency == SharedStructs.PaymentMethod.Ether) {
// Move Ethereum into escrow
      escrowHandler.updateEscrowBalance(buyer, SharedStructs.PaymentMethod.Ether, cost, true);
      // Transfer Ether to the nickelium contract's escrow
                transferEtherToCentral(cost);
}
else if (order.priceCurrency == SharedStructs.PaymentMethod.USDT) {
     USDTContract.approve(address(this), cost);
  USDTContract.transferFrom(buyer, address(escrowHandler), cost);
    escrowHandler.updateEscrowBalance(buyer, SharedStructs.PaymentMethod.USDT, cost, true);
}
else if (order.priceCurrency == SharedStructs.PaymentMethod.USDC) {
     USDCContract.approve(address(this), cost);
  USDCContract.transferFrom(buyer, address(escrowHandler), cost);
    escrowHandler.updateEscrowBalance(buyer, SharedStructs.PaymentMethod.USDC, cost, true);
}
        escrowHandler.addBuyOrder(
        order.orderID,
        order.user,      
        order.price,
        order.amount,
        order.assetType,
        order.priceCurrency,
        false
    );
        // Reset confirmation status after execution
        isConfirmedByOwner1 = false;
        isConfirmedByOwner2 = false;
        // Remove the order by resetting its details
    delete pendingOrders[_orderID];
    // Remove the order ID from the auxiliary array (indexes)
    for (uint256 i = 0; i < indexes.length; i++) {
        if (indexes[i] == _orderID) {
            indexes[i] = indexes[indexes.length - 1];
            indexes.pop();
            break;
        }
    }
    }


    function executeSellOrder(uint256 _orderID) internal {
        PendingOrder storage order = pendingOrders[_orderID];
        require(order.isConfirmedByOwner1 == true && order.isConfirmedByOwner2 == true, "Both parties must confirm");
                // Retrieve the amount from the order
    uint256 _amount = order.amount;
    require(nickeliumContract.balanceOf(address(this)) >= _amount, "Insufficient balance for the operation");
    require(order.price > 0, "This order is not exist");
         nickeliumContract.approve(address(this), _amount);
         nickeliumContract.approve(address(escrowHandler), _amount);
    // Transfer tokens from the multisig contract to the Nickelium contract
    require(nickeliumContract.transferFrom(address(this), address(nickeliumContract), _amount), "Token transfer failed");
        escrowHandler.addSellOrder(
        order.orderID,
        order.user,
        order.price,
        _amount,
        order.assetType,
        order.priceCurrency,
        order.authorizedBuyersOnly
    );
        // Reset confirmation status after execution
        isConfirmedByOwner1 = false;
        isConfirmedByOwner2 = false;
        // Remove the order by resetting its details
    delete pendingOrders[_orderID];
    // Remove the order ID from the auxiliary array (indexes)
    for (uint256 i = 0; i < indexes.length; i++) {
        if (indexes[i] == _orderID) {
            indexes[i] = indexes[indexes.length - 1];
            indexes.pop();
            break;
        }
    }
    }
      
      function DisplayNextOrder() external view returns (PendingOrder memory) {
    uint256 orderID = indexes[defaultIndex];
    return pendingOrders[orderID];
}
function DisplayAllOrders() external view returns (PendingOrder[] memory orders) {
    uint256 count = 0;
    for (uint256 i = 0; i < 11 && i < indexes.length; i++) {
        uint256 orderID = indexes[i];
        PendingOrder memory order = pendingOrders[orderID];
        if (order.price != 0) {
            count++;
        }
    }

    // Create a dynamic array with the correct size
    orders = new PendingOrder[](count);

    count = 0;
    for (uint256 i = 0; i < 11 && i < indexes.length; i++) {
        uint256 orderID = indexes[i];
        PendingOrder memory order = pendingOrders[orderID];
        if (order.price != 0) {
            orders[count] = order;
            count++;
        }
    }

    return orders;
}

    function ShowOrderByID(uint256 _index) external view returns (PendingOrder memory) {
        return pendingOrders[_index];
    }
    function ShowOrderByIndex2(uint256 _index) external view returns (PendingOrder memory) {
    require(_index < indexes.length, "Index out of bounds"); // Ensure index is within bounds

    uint256 orderID = indexes[_index];
    return pendingOrders[orderID];
}

function deletePendingOrder(uint256 _orderID) public onlyOwners nonReentrant whenNotPaused {
  
  // Delete the order from pendingOrders mapping
  delete pendingOrders[_orderID];

  // Remove the order ID from the indexes array
  for (uint256 i = 0; i < indexes.length; i++) {
    if (indexes[i] == _orderID) {
      indexes[i] = indexes[indexes.length - 1];
      indexes.pop();
      break;
    }
  }
}

function removeOrder(uint256 orderID) public onlyOwners nonReentrant whenNotPaused {
                adminControlContract.userRemoveOrder(address(this), orderID);
    }

       function getPendingActions() public view returns (uint256[] memory) {
    // First pass: count the number of pending actions
    uint256 count = 0;
    for (uint256 i = 0; i < nextActionId; i++) {
        if (!actions[i].isConfirmedByOwner1 || !actions[i].isConfirmedByOwner2) {
            count++;
        }
    }

    // Create an array of the appropriate size
    uint256[] memory pending = new uint256[](count);
    
    // Second pass: populate the array with pending action IDs
    uint256 index = 0;
    for (uint256 i = 0; i < nextActionId; i++) {
        if (!actions[i].isConfirmedByOwner1 || !actions[i].isConfirmedByOwner2) {
            pending[index] = i;
            index++;
        }
    }

    return pending;
}
function getActionDetails(uint256 actionId) public view actionExists(actionId) returns (Action memory) {
    return actions[actionId];
}

function emergencyStop() public onlyOwners nonReentrant whenNotPaused {
           _pause();
    }

    function resume() public onlyOwners nonReentrant {
               _unpause();
    }
    

}