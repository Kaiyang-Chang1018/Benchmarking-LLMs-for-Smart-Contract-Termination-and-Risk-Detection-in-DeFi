// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}
pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

import "./interfaces/storage/IStafiStorage.sol";

abstract contract StafiBase {

    // Version of the contract
    uint8 public version;

    // The main storage contract where primary persistant storage is maintained
    IStafiStorage stafiStorage = IStafiStorage(0);


    /**
    * @dev Throws if called by any sender that doesn't match a network contract
    */
    modifier onlyLatestNetworkContract() {
        require(getBool(keccak256(abi.encodePacked("contract.exists", msg.sender))), "Invalid or outdated network contract");
        _;
    }


    /**
    * @dev Throws if called by any sender that doesn't match one of the supplied contract or is the latest version of that contract
    */
    modifier onlyLatestContract(string memory _contractName, address _contractAddress) {
        require(_contractAddress == getAddress(keccak256(abi.encodePacked("contract.address", _contractName))), "Invalid or outdated contract");
        _;
    }


    /**
    * @dev Throws if called by any sender that isn't a trusted node
    */
    modifier onlyTrustedNode(address _nodeAddress) {
        require(getBool(keccak256(abi.encodePacked("node.trusted", _nodeAddress))), "Invalid trusted node");
        _;
    }
    
    /**
    * @dev Throws if called by any sender that isn't a super node
    */
    modifier onlySuperNode(address _nodeAddress) {
        require(getBool(keccak256(abi.encodePacked("node.super", _nodeAddress))), "Invalid super node");
        _;
    }


    /**
    * @dev Throws if called by any sender that isn't a registered staking pool
    */
    modifier onlyRegisteredStakingPool(address _stakingPoolAddress) {
        require(getBool(keccak256(abi.encodePacked("stakingpool.exists", _stakingPoolAddress))), "Invalid staking pool");
        _;
    }


    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(roleHas("owner", msg.sender), "Account is not the owner");
        _;
    }


    /**
    * @dev Modifier to scope access to admins
    */
    modifier onlyAdmin() {
        require(roleHas("admin", msg.sender), "Account is not an admin");
        _;
    }


    /**
    * @dev Modifier to scope access to admins
    */
    modifier onlySuperUser() {
        require(roleHas("owner", msg.sender) || roleHas("admin", msg.sender), "Account is not a super user");
        _;
    }


    /**
    * @dev Reverts if the address doesn't have this role
    */
    modifier onlyRole(string memory _role) {
        require(roleHas(_role, msg.sender), "Account does not match the specified role");
        _;
    }


    /// @dev Set the main Storage address
    constructor(address _stafiStorageAddress) {
        // Update the contract address
        stafiStorage = IStafiStorage(_stafiStorageAddress);
    }


    /// @dev Get the address of a network contract by name
    function getContractAddress(string memory _contractName) internal view returns (address) {
        // Get the current contract address
        address contractAddress = getAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
        // Check it
        require(contractAddress != address(0x0), "Contract not found");
        // Return
        return contractAddress;
    }


    /// @dev Get the name of a network contract by address
    function getContractName(address _contractAddress) internal view returns (string memory) {
        // Get the contract name
        string memory contractName = getString(keccak256(abi.encodePacked("contract.name", _contractAddress)));
        // Check it
        require(keccak256(abi.encodePacked(contractName)) != keccak256(abi.encodePacked("")), "Contract not found");
        // Return
        return contractName;
    }


    /// @dev Storage get methods
    function getAddress(bytes32 _key) internal view returns (address) { return stafiStorage.getAddress(_key); }
    function getUint(bytes32 _key) internal view returns (uint256) { return stafiStorage.getUint(_key); }
    function getString(bytes32 _key) internal view returns (string memory) { return stafiStorage.getString(_key); }
    function getBytes(bytes32 _key) internal view returns (bytes memory) { return stafiStorage.getBytes(_key); }
    function getBool(bytes32 _key) internal view returns (bool) { return stafiStorage.getBool(_key); }
    function getInt(bytes32 _key) internal view returns (int256) { return stafiStorage.getInt(_key); }
    function getBytes32(bytes32 _key) internal view returns (bytes32) { return stafiStorage.getBytes32(_key); }
    function getAddressS(string memory _key) internal view returns (address) { return stafiStorage.getAddress(keccak256(abi.encodePacked(_key))); }
    function getUintS(string memory _key) internal view returns (uint256) { return stafiStorage.getUint(keccak256(abi.encodePacked(_key))); }
    function getStringS(string memory _key) internal view returns (string memory) { return stafiStorage.getString(keccak256(abi.encodePacked(_key))); }
    function getBytesS(string memory _key) internal view returns (bytes memory) { return stafiStorage.getBytes(keccak256(abi.encodePacked(_key))); }
    function getBoolS(string memory _key) internal view returns (bool) { return stafiStorage.getBool(keccak256(abi.encodePacked(_key))); }
    function getIntS(string memory _key) internal view returns (int256) { return stafiStorage.getInt(keccak256(abi.encodePacked(_key))); }
    function getBytes32S(string memory _key) internal view returns (bytes32) { return stafiStorage.getBytes32(keccak256(abi.encodePacked(_key))); }

    /// @dev Storage set methods
    function setAddress(bytes32 _key, address _value) internal { stafiStorage.setAddress(_key, _value); }
    function setUint(bytes32 _key, uint256 _value) internal { stafiStorage.setUint(_key, _value); }
    function setString(bytes32 _key, string memory _value) internal { stafiStorage.setString(_key, _value); }
    function setBytes(bytes32 _key, bytes memory _value) internal { stafiStorage.setBytes(_key, _value); }
    function setBool(bytes32 _key, bool _value) internal { stafiStorage.setBool(_key, _value); }
    function setInt(bytes32 _key, int256 _value) internal { stafiStorage.setInt(_key, _value); }
    function setBytes32(bytes32 _key, bytes32 _value) internal { stafiStorage.setBytes32(_key, _value); }
    function setAddressS(string memory _key, address _value) internal { stafiStorage.setAddress(keccak256(abi.encodePacked(_key)), _value); }
    function setUintS(string memory _key, uint256 _value) internal { stafiStorage.setUint(keccak256(abi.encodePacked(_key)), _value); }
    function setStringS(string memory _key, string memory _value) internal { stafiStorage.setString(keccak256(abi.encodePacked(_key)), _value); }
    function setBytesS(string memory _key, bytes memory _value) internal { stafiStorage.setBytes(keccak256(abi.encodePacked(_key)), _value); }
    function setBoolS(string memory _key, bool _value) internal { stafiStorage.setBool(keccak256(abi.encodePacked(_key)), _value); }
    function setIntS(string memory _key, int256 _value) internal { stafiStorage.setInt(keccak256(abi.encodePacked(_key)), _value); }
    function setBytes32S(string memory _key, bytes32 _value) internal { stafiStorage.setBytes32(keccak256(abi.encodePacked(_key)), _value); }

    /// @dev Storage delete methods
    function deleteAddress(bytes32 _key) internal { stafiStorage.deleteAddress(_key); }
    function deleteUint(bytes32 _key) internal { stafiStorage.deleteUint(_key); }
    function deleteString(bytes32 _key) internal { stafiStorage.deleteString(_key); }
    function deleteBytes(bytes32 _key) internal { stafiStorage.deleteBytes(_key); }
    function deleteBool(bytes32 _key) internal { stafiStorage.deleteBool(_key); }
    function deleteInt(bytes32 _key) internal { stafiStorage.deleteInt(_key); }
    function deleteBytes32(bytes32 _key) internal { stafiStorage.deleteBytes32(_key); }
    function deleteAddressS(string memory _key) internal { stafiStorage.deleteAddress(keccak256(abi.encodePacked(_key))); }
    function deleteUintS(string memory _key) internal { stafiStorage.deleteUint(keccak256(abi.encodePacked(_key))); }
    function deleteStringS(string memory _key) internal { stafiStorage.deleteString(keccak256(abi.encodePacked(_key))); }
    function deleteBytesS(string memory _key) internal { stafiStorage.deleteBytes(keccak256(abi.encodePacked(_key))); }
    function deleteBoolS(string memory _key) internal { stafiStorage.deleteBool(keccak256(abi.encodePacked(_key))); }
    function deleteIntS(string memory _key) internal { stafiStorage.deleteInt(keccak256(abi.encodePacked(_key))); }
    function deleteBytes32S(string memory _key) internal { stafiStorage.deleteBytes32(keccak256(abi.encodePacked(_key))); }


    /**
    * @dev Check if an address has this role
    */
    function roleHas(string memory _role, address _address) internal view returns (bool) {
        return getBool(keccak256(abi.encodePacked("access.role", _role, _address)));
    }

}
pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../StafiBase.sol";
import "../interfaces/IStafiEther.sol";
import "../interfaces/IStafiEtherWithdrawer.sol";
import "../interfaces/deposit/IStafiUserDeposit.sol";
import "../interfaces/pool/IStafiStakingPool.sol";
import "../interfaces/pool/IStafiStakingPoolQueue.sol";
import "../interfaces/token/IRETHToken.sol";
import "../interfaces/node/IStafiSuperNode.sol";
import "../interfaces/node/IStafiLightNode.sol";
import "../interfaces/withdraw/IStafiWithdraw.sol";

// Accepts user deposits and mints rETH; handles assignment of deposited ETH to pools
contract StafiUserDeposit is StafiBase, IStafiUserDeposit, IStafiEtherWithdrawer {

    // Libs
    using SafeMath for uint256;

    // Events
    event DepositReceived(address indexed from, uint256 amount, uint256 time);
    event DepositRecycled(address indexed from, uint256 amount, uint256 time);
    event DepositAssigned(address indexed stakingPool, uint256 amount, uint256 time);
    event ExcessWithdrawn(address indexed to, uint256 amount, uint256 time);

    // Construct
    constructor(address _stafiStorageAddress) StafiBase(_stafiStorageAddress) {
        version = 1;
        // Initialize settings on deployment
        if (!getBoolS("settings.user.deposit.init")) {
            // Apply settings
            setDepositEnabled(true);
            setAssignDepositsEnabled(true);
            setMinimumDeposit(0.01 ether);
            // setMaximumDepositPoolSize(100000 ether);
            setMaximumDepositAssignments(2);
            // Settings initialized
            setBoolS("settings.user.deposit.init", true);
        }
    }

    // Current deposit pool balance
    function getBalance() override public view returns (uint256) {
        IStafiEther stafiEther = IStafiEther(getContractAddress("stafiEther"));
        return stafiEther.balanceOf(address(this));
    }

    // Excess deposit pool balance (in excess of stakingPool queue capacity)
    function getExcessBalance() override public view returns (uint256) {
        // Get stakingPool queue capacity
        IStafiStakingPoolQueue stafiStakingPoolQueue = IStafiStakingPoolQueue(getContractAddress("stafiStakingPoolQueue"));
        uint256 stakingPoolCapacity = stafiStakingPoolQueue.getEffectiveCapacity();
        // Calculate and return
        uint256 balance = getBalance();
        if (stakingPoolCapacity >= balance) { return 0; }
        else { return balance.sub(stakingPoolCapacity); }
    }

    // Receive a ether withdrawal
    // Only accepts calls from the StafiEther contract
    function receiveEtherWithdrawal() override external payable onlyLatestContract("stafiUserDeposit", address(this)) onlyLatestContract("stafiEther", msg.sender) {}

    // Accept a deposit from a user
    function deposit() override external payable onlyLatestContract("stafiUserDeposit", address(this)) {
        // Check deposit settings
        require(getDepositEnabled(), "Deposits into Stafi are currently disabled");
        require(msg.value >= getMinimumDeposit(), "The deposited amount is less than the minimum deposit size");
        // Load contracts
        IRETHToken rETHToken = IRETHToken(getContractAddress("rETHToken"));
        // Mint rETH to user account
        rETHToken.userMint(msg.value, msg.sender);
        // Emit deposit received event
        emit DepositReceived(msg.sender, msg.value, block.timestamp);
        // Process deposit
        processDeposit();
    }

    // Recycle a deposit from a dissolved stakingPool
    // Only accepts calls from registered stakingPools
    function recycleDissolvedDeposit() override external payable onlyLatestContract("stafiUserDeposit", address(this)) onlyRegisteredStakingPool(msg.sender) {
        // Emit deposit recycled event
        emit DepositRecycled(msg.sender, msg.value, block.timestamp);
        // Process deposit
        processDeposit();
    }

    // Recycle a deposit from fee collector
    // Only accepts calls from registered stafiDistributor
    function recycleDistributorDeposit() override external payable onlyLatestContract("stafiUserDeposit", address(this)) onlyLatestContract("stafiDistributor", msg.sender) {
        // Emit deposit recycled event
        emit DepositRecycled(msg.sender, msg.value, block.timestamp);
        // Process deposit
        processDeposit();
    }
    
    // Recycle a deposit from withdraw pool
    // Only accepts calls from registered stafiWithdraw
    function recycleWithdrawDeposit() override external payable onlyLatestContract("stafiUserDeposit", address(this)) onlyLatestContract("stafiWithdraw", msg.sender) {
        // Emit deposit recycled event
        emit DepositRecycled(msg.sender, msg.value, block.timestamp);
        // Process deposit
        processDeposit();
    }

    // Process a deposit
    function processDeposit() private {
        // Load contracts
        IStafiEther stafiEther = IStafiEther(getContractAddress("stafiEther"));
        // Transfer ETH to stafiEther
        stafiEther.depositEther{value: msg.value}();
        // Assign deposits if enabled
        assignDeposits();
    }

    // Assign deposits to available stakingPools
    function assignDeposits() override public onlyLatestContract("stafiUserDeposit", address(this)) {
        // Check deposit settings
        if (!getAssignDepositsEnabled()) {
            return;
        }

        // Load contracts
        IStafiStakingPoolQueue stafiStakingPoolQueue = IStafiStakingPoolQueue(getContractAddress("stafiStakingPoolQueue"));
        IStafiEther stafiEther = IStafiEther(getContractAddress("stafiEther"));
        // Assign deposits
        uint256 maximumDepositAssignments = getMaximumDepositAssignments();
        for (uint256 i = 0; i < maximumDepositAssignments; ++i) {
            // Get & check next available staking pool capacity
            uint256 stakingPoolCapacity = stafiStakingPoolQueue.getNextCapacity();
            if (stakingPoolCapacity == 0 || getBalance() < stakingPoolCapacity) { break; }
            // Dequeue next available staking pool
            address stakingPoolAddress = stafiStakingPoolQueue.dequeueStakingPool();
            IStafiStakingPool stakingPool = IStafiStakingPool(stakingPoolAddress);
            // Withdraw ETH from stafiEther
            stafiEther.withdrawEther(stakingPoolCapacity);
            // Assign deposit to staking pool
            stakingPool.userDeposit{value: stakingPoolCapacity}();
            // Emit deposit assigned event
            emit DepositAssigned(stakingPoolAddress, stakingPoolCapacity, block.timestamp);
        }
    }

    // Withdraw excess deposit pool balance for rETH collateral
    function withdrawExcessBalance(uint256 _amount) override external onlyLatestContract("stafiUserDeposit", address(this)) onlyLatestContract("rETHToken", msg.sender) {
        // Load contracts
        IRETHToken rETHToken = IRETHToken(getContractAddress("rETHToken"));
        IStafiEther stafiEther = IStafiEther(getContractAddress("stafiEther"));
        // Check amount
        require(_amount <= getBalance(), "Insufficient balance for withdrawal");
        // Withdraw ETH from vault
        stafiEther.withdrawEther(_amount);
        // Transfer to rETH contract
        rETHToken.depositExcess{value: _amount}();
        // Emit excess withdrawn event
        emit ExcessWithdrawn(msg.sender, _amount, block.timestamp);
    }

    // Withdraw excess deposit pool balance for super node
    function withdrawExcessBalanceForSuperNode(uint256 _amount) override external onlyLatestContract("stafiUserDeposit", address(this)) onlyLatestContract("stafiSuperNode", msg.sender) {
        // Load contracts
        IStafiSuperNode superNode = IStafiSuperNode(getContractAddress("stafiSuperNode"));
        IStafiEther stafiEther = IStafiEther(getContractAddress("stafiEther"));
        // Check amount
        require(_amount <= getBalance(), "Insufficient balance for withdrawal");
        // Withdraw ETH from vault
        stafiEther.withdrawEther(_amount);
        // Transfer to superNode contract
        superNode.depositEth{value: _amount}();
        // Emit excess withdrawn event
        emit ExcessWithdrawn(msg.sender, _amount, block.timestamp);
    }
    
    // Withdraw excess deposit pool balance for light node
    function withdrawExcessBalanceForLightNode(uint256 _amount) override external onlyLatestContract("stafiUserDeposit", address(this)) onlyLatestContract("stafiLightNode", msg.sender) {
        // Load contracts
        IStafiLightNode lightNode = IStafiLightNode(getContractAddress("stafiLightNode"));
        IStafiEther stafiEther = IStafiEther(getContractAddress("stafiEther"));
        // Check amount
        require(_amount <= getBalance(), "Insufficient balance for withdrawal");
        // Withdraw ETH from vault
        stafiEther.withdrawEther(_amount);
        // Transfer to superNode contract
        lightNode.depositEth{value: _amount}();
        // Emit excess withdrawn event
        emit ExcessWithdrawn(msg.sender, _amount, block.timestamp);
    }
    
    // Withdraw excess deposit pool balance for light node
    function withdrawExcessBalanceForWithdraw(uint256 _amount) override external onlyLatestContract("stafiUserDeposit", address(this)) onlyLatestContract("stafiWithdraw", msg.sender) {
        // Load contracts
        IStafiWithdraw stafiWithdraw = IStafiWithdraw(getContractAddress("stafiWithdraw"));
        IStafiEther stafiEther = IStafiEther(getContractAddress("stafiEther"));
        // Check amount
        require(_amount <= getBalance(), "Insufficient balance for withdrawal");
        // Withdraw ETH from vault
        stafiEther.withdrawEther(_amount);
        // Transfer to superNode contract
        stafiWithdraw.depositEth{value: _amount}();
        // Emit excess withdrawn event
        emit ExcessWithdrawn(msg.sender, _amount, block.timestamp);
    }

    // Deposits currently enabled
    function getDepositEnabled() public view returns (bool) {
        return getBoolS("settings.deposit.enabled");
    }
    function setDepositEnabled(bool _value) public onlySuperUser {
        setBoolS("settings.deposit.enabled", _value);
    }

    // Deposit assignments currently enabled
    function getAssignDepositsEnabled() public view returns (bool) {
        return getBoolS("settings.deposit.assign.enabled");
    }
    function setAssignDepositsEnabled(bool _value) public onlySuperUser {
        setBoolS("settings.deposit.assign.enabled", _value);
    }

    // Minimum deposit size
    function getMinimumDeposit() public view returns (uint256) {
        return getUintS("settings.deposit.minimum");
    }
    function setMinimumDeposit(uint256 _value) public onlySuperUser {
        setUintS("settings.deposit.minimum", _value);
    }

    // The maximum number of deposit assignments to perform at once
    function getMaximumDepositAssignments() public view returns (uint256) {
        return getUintS("settings.deposit.assign.maximum");
    }
    function setMaximumDepositAssignments(uint256 _value) public onlySuperUser {
        setUintS("settings.deposit.assign.maximum", _value);
    }

}
pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

interface IStafiEther {
    function balanceOf(address _contractAddress) external view returns (uint256);
    function depositEther() external payable;
    function withdrawEther(uint256 _amount) external;
}
pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

interface IStafiEtherWithdrawer {
    function receiveEtherWithdrawal() external payable;
}
pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

interface IStafiUserDeposit {
    function getBalance() external view returns (uint256);
    function getExcessBalance() external view returns (uint256);
    function deposit() external payable;
    function recycleDissolvedDeposit() external payable;
    function recycleWithdrawDeposit() external payable;
    function recycleDistributorDeposit() external payable;
    function assignDeposits() external;
    function withdrawExcessBalance(uint256 _amount) external;
    function withdrawExcessBalanceForSuperNode(uint256 _amount) external;
    function withdrawExcessBalanceForLightNode(uint256 _amount) external;
    function withdrawExcessBalanceForWithdraw(uint256 _amount) external;
}
pragma solidity 0.7.6;
pragma abicoder v2;
// SPDX-License-Identifier: GPL-3.0-only

interface IStafiLightNode {
    function depositEth() external payable;
    function deposit(bytes[] calldata _validatorPubkeys, bytes[] calldata _validatorSignatures, bytes32[] calldata _depositDataRoots) external payable;
    function stake(bytes[] calldata _validatorPubkeys, bytes[] calldata _validatorSignatures, bytes32[] calldata _depositDataRoots) external;
    function offBoard(bytes calldata _validatorPubkey) external;
    function provideNodeDepositToken(bytes calldata _validatorPubkey) external payable;
    function withdrawNodeDepositToken(bytes calldata _validatorPubkey) external;
    function getLightNodePubkeyCount(address _nodeAddress) external view returns (uint256);
    function getLightNodePubkeyAt(address _nodeAddress, uint256 _index) external view returns (bytes memory);
    function getLightNodePubkeyStatus(bytes calldata _validatorPubkey) external view returns (uint256);
    function voteWithdrawCredentials(bytes[] calldata _pubkey, bool[] calldata _match) external;
}
pragma solidity 0.7.6;
pragma abicoder v2;
// SPDX-License-Identifier: GPL-3.0-only

interface IStafiSuperNode {
    function depositEth() external payable;
    function deposit(bytes[] calldata _validatorPubkeys, bytes[] calldata _validatorSignatures, bytes32[] calldata _depositDataRoots) external;
    function stake(bytes[] calldata _validatorPubkeys, bytes[] calldata _validatorSignatures, bytes32[] calldata _depositDataRoots) external;
    function getSuperNodePubkeyCount(address _nodeAddress) external view returns (uint256);
    function getSuperNodePubkeyAt(address _nodeAddress, uint256 _index) external view returns (bytes memory);
    function getSuperNodePubkeyStatus(bytes calldata _validatorPubkey) external view returns (uint256);
    function voteWithdrawCredentials(bytes[] calldata _pubkey, bool[] calldata _match) external;
}
pragma solidity 0.7.6;
// SPDX-License-Identifier: GPL-3.0-only

import "../../types/DepositType.sol";
import "../../types/StakingPoolStatus.sol";

interface IStafiStakingPool {
    function initialise(address _nodeAddress, DepositType _depositType) external;
    function getStatus() external view returns (StakingPoolStatus);
    function getStatusBlock() external view returns (uint256);
    function getStatusTime() external view returns (uint256);
    function getWithdrawalCredentialsMatch() external view returns (bool);
    function getDepositType() external view returns (DepositType);
    function getNodeAddress() external view returns (address);
    function getNodeFee() external view returns (uint256);
    function getNodeDepositBalance() external view returns (uint256);
    function getNodeRefundBalance() external view returns (uint256);
    function getNodeDepositAssigned() external view returns (bool);
    function getNodeCommonlyRefunded() external view returns (bool);
    function getNodeTrustedRefunded() external view returns (bool);
    function getUserDepositBalance() external view returns (uint256);
    function getUserDepositAssigned() external view returns (bool);
    function getUserDepositAssignedTime() external view returns (uint256);
    function getPlatformDepositBalance() external view returns (uint256);
    function nodeDeposit(bytes calldata _validatorPubkey, bytes calldata _validatorSignature, bytes32 _depositDataRoot) external payable;
    function userDeposit() external payable;
    function stake(bytes calldata _validatorSignature, bytes32 _depositDataRoot)  external;
    function refund() external;
    function dissolve() external;
    function close() external;
    function voteWithdrawCredentials() external;
}
pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

import "../../types/DepositType.sol";

interface IStafiStakingPoolQueue {
    function getTotalLength() external view returns (uint256);
    function getLength(DepositType _depositType) external view returns (uint256);
    function getTotalCapacity() external view returns (uint256);
    function getEffectiveCapacity() external view returns (uint256);
    function getNextCapacity() external view returns (uint256);
    function enqueueStakingPool(DepositType _depositType, address _stakingPool) external;
    function dequeueStakingPool() external returns (address);
    function removeStakingPool() external;
}
pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

interface IStafiStorage {

    // Getters
    function getAddress(bytes32 _key) external view returns (address);
    function getUint(bytes32 _key) external view returns (uint);
    function getString(bytes32 _key) external view returns (string memory);
    function getBytes(bytes32 _key) external view returns (bytes memory);
    function getBool(bytes32 _key) external view returns (bool);
    function getInt(bytes32 _key) external view returns (int);
    function getBytes32(bytes32 _key) external view returns (bytes32);

    // Setters
    function setAddress(bytes32 _key, address _value) external;
    function setUint(bytes32 _key, uint _value) external;
    function setString(bytes32 _key, string calldata _value) external;
    function setBytes(bytes32 _key, bytes calldata _value) external;
    function setBool(bytes32 _key, bool _value) external;
    function setInt(bytes32 _key, int _value) external;
    function setBytes32(bytes32 _key, bytes32 _value) external;

    // Deleters
    function deleteAddress(bytes32 _key) external;
    function deleteUint(bytes32 _key) external;
    function deleteString(bytes32 _key) external;
    function deleteBytes(bytes32 _key) external;
    function deleteBool(bytes32 _key) external;
    function deleteInt(bytes32 _key) external;
    function deleteBytes32(bytes32 _key) external;

}
pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

interface IRETHToken {
    function getEthValue(uint256 _rethAmount) external view returns (uint256);
    function getRethValue(uint256 _ethAmount) external view returns (uint256);
    function getExchangeRate() external view returns (uint256);
    function getTotalCollateral() external view returns (uint256);
    function getCollateralRate() external view returns (uint256);
    function depositRewards() external payable;
    function depositExcess() external payable;
    function userMint(uint256 _ethAmount, address _to) external;
    function userBurn(uint256 _rethAmount) external;
}
pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

interface IStafiWithdraw {
    // user

    function unstake(uint256 _rEthAmount) external;

    function withdraw(uint256[] calldata _withdrawIndexList) external;

    // ejector
    function notifyValidatorExit(
        uint256 _withdrawCycle,
        uint256 _ejectedStartWithdrawCycle,
        uint256[] calldata _validatorIndex
    ) external;

    // voter
    function distributeWithdrawals(
        uint256 _dealedHeight,
        uint256 _userAmount,
        uint256 _nodeAmount,
        uint256 _platformAmount,
        uint256 _maxClaimableWithdrawIndex
    ) external;

    function reserveEthForWithdraw(uint256 _withdrawCycle) external;

    function depositEth() external payable;

    function getUnclaimedWithdrawalsOfUser(address user) external view returns (uint256[] memory);

    function getEjectedValidatorsAtCycle(uint256 cycle) external view returns (uint256[] memory);
}
pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

// Represents the type of deposits
enum DepositType {
    None,    // Marks an invalid deposit type
    FOUR,    // Require 4 ETH from the node operator to be matched with 28 ETH from user deposits
    EIGHT,   // Require 8 ETH from the node operator to be matched with 24 ETH from user deposits
    TWELVE,  // Require 12 ETH from the node operator to be matched with 20 ETH from user deposits
    SIXTEEN,  // Require 16 ETH from the node operator to be matched with 16 ETH from user deposits
    Empty    // Require 0 ETH from the node operator to be matched with 32 ETH from user deposits (trusted nodes only)
}
pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

// Represents a stakingpool's status within the network
enum StakingPoolStatus {
    Initialized,    // The stakingpool has been initialized and is awaiting a deposit of user ETH
    Prelaunch,      // The stakingpool has enough ETH to begin staking and is awaiting launch by the node
    Staking,        // The stakingpool is currently staking
    Withdrawn,   // The stakingpool has been withdrawn from by the node
    Dissolved       // The stakingpool has been dissolved and its user deposited ETH has been returned to the deposit pool
}