// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;
 
abstract contract NonERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);
 
    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
   

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals; 
    }
   
    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/IMint.sol";
import "./NonERC20.sol";

/**
 * @title Zenith ETH
 */
contract ESZTH is NonERC20("Zenith Escrowed Token", "esZTH", 18) {
    uint256 private constant _SLEEP_TIMES = 3 days;
    uint256 private constant _MAX_LOCK_TIMES = 14 days;
    address private constant _DEAD = 0x000000000000000000000000000000000000dEaD;

    address public immutable MASTERCHEF;
    address public immutable TREASURY;
    address public immutable ZTHTOKEN;

    LockInfo[] private _lockPositions;

    struct LockInfo {
        address holder;
        uint256 amount;
        uint256 unlockTime;
    }

    constructor(address masterChef, address treasury, address zthToken) {
        if (masterChef == address(0)) revert AddressIsZero();
        if (treasury == address(0)) revert AddressIsZero();
        if (zthToken == address(0)) revert AddressIsZero();

        MASTERCHEF = masterChef;
        TREASURY = treasury;
        ZTHTOKEN = zthToken;
    }

    function mint(address to, uint256 amount) external onlyMasterChef {
        _mint(to, amount);
    }

    /**
     * @notice Swap ESZTH to ZTH
     * @dev Early redemption will result in the loss of the corresponding ZTH share,
     *  which 50% will be burned and other 50% belonging to the team treasury.
     */
    function swap(uint256 amount, uint256 lockTimes) external {
        _burn(msg.sender, amount);

        uint256 amountOut = getAmountOut(amount, lockTimes);

        uint256 loss;
        unchecked {
            loss = amount - amountOut;
        }
        // mint ZTH to treasury
        if (loss > 0) {
            IMint(ZTHTOKEN).mint(_DEAD, loss / 2);
            IMint(ZTHTOKEN).mint(TREASURY, loss / 2);
        }

        uint256 lid = _lockPositions.length;
        unchecked {
            _lockPositions.push(LockInfo(msg.sender, amountOut, block.timestamp + lockTimes));
        }
        emit Swap(msg.sender, lid, amount, lockTimes, amountOut);
    }

    function redeem(uint256 lockId) public {
        LockInfo storage lockInfo = _lockPositions[lockId];
        if (lockInfo.unlockTime > block.timestamp) revert UnlockTimeNotArrived();
        uint256 amount = lockInfo.amount;

        if (amount == 0) revert LockedAmountIsZero();

        // update state
        lockInfo.amount = 0;
        // mint ZTH to holder
        IMint(ZTHTOKEN).mint(lockInfo.holder, amount);

        emit Redeem(lockInfo.holder, lockId, amount);
    }

    function batchRedeem(uint256[] calldata lockIds) external {
        for (uint256 i = 0; i < lockIds.length; i++) {
            redeem(lockIds[i]);
        }
    }

    function getAmountOut(uint256 amount, uint256 lockTimes) public pure returns (uint256) {
        if (lockTimes < _SLEEP_TIMES || lockTimes > _MAX_LOCK_TIMES) revert InvalidLockTimes();
        // 20% of the amount will be locked for 3 days
        // 100% of the amount will be locked for 14 days
        // amount= 20%+ 80%*(lockTimes-3days)/(14days-3days)
        unchecked {
            return (amount * 2 + amount * 8 * (lockTimes - _SLEEP_TIMES) / (_MAX_LOCK_TIMES - _SLEEP_TIMES)) / 10;
        }
    }

    function getLockPosition(uint256 lockId) external view returns (LockInfo memory) {
        return _lockPositions[lockId];
    }
 
    modifier onlyMasterChef() {
        if (msg.sender != MASTERCHEF) revert OnlyCallByMasterChef();

        _;
    }

    event Swap(address indexed holder, uint256 lockId, uint256 amount, uint256 lockTimes, uint256 amountOut);
    event Redeem(address indexed holder, uint256 lockId, uint256 amount);

    error AddressIsZero();
    error OnlyCallByMasterChef();
    error InvalidLockTimes();
    error LockedAmountIsZero();
    error UnlockTimeNotArrived(); 
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
 
interface IMint {
    function mint(address to, uint256 amount) external;
}