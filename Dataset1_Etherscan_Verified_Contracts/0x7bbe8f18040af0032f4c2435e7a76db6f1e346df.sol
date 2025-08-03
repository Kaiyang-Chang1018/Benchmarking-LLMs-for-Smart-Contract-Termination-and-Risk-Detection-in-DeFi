// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interface/IERC20.sol";
import "./interface/IERC677Receiver.sol";
import "./interface/IFrankencoin.sol";

/**
 * @title Stable Coin Bridge
 * @notice A minting contract for another Swiss franc stablecoin ('source stablecoin') that we trust.
 * @author Frankencoin
 */
contract StablecoinBridge {
    IERC20 public immutable chf; // the source stablecoin
    IFrankencoin public immutable zchf; // the Frankencoin

    /**
     * @notice The time horizon after which this bridge expires and needs to be replaced by a new contract.
     */
    uint256 public immutable horizon;

    /**
     * The maximum amount of outstanding converted source stablecoins.
     */
    uint256 public immutable limit;
    uint256 public minted;

    error Limit(uint256 amount, uint256 limit);
    error Expired(uint256 time, uint256 expiration);
    error UnsupportedToken(address token);

    constructor(address other, address zchfAddress, uint256 limit_) {
        chf = IERC20(other);
        zchf = IFrankencoin(zchfAddress);
        horizon = block.timestamp + 52 weeks;
        limit = limit_;
        minted = 0;
    }

    /**
     * @notice Convenience method for mint(msg.sender, amount)
     */
    function mint(uint256 amount) external {
        mintTo(msg.sender, amount);
    }

    /**
     * @notice Mint the target amount of Frankencoins, taking the equal amount of source coins from the sender.
     * @dev This only works if an allowance for the source coins has been set and the caller has enough of them.
     */
    function mintTo(address target, uint256 amount) public {
        chf.transferFrom(msg.sender, address(this), amount);
        _mint(target, amount);
    }

    function _mint(address target, uint256 amount) internal {
        if (block.timestamp > horizon) revert Expired(block.timestamp, horizon);
        zchf.mint(target, amount);
        minted += amount;
        if (minted > limit) revert Limit(amount, limit);
    }

    /**
     * @notice Convenience method for burnAndSend(msg.sender, amount)
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, msg.sender, amount);
    }

    /**
     * @notice Burn the indicated amount of Frankencoin and send the same number of source coin to the caller.
     */
    function burnAndSend(address target, uint256 amount) external {
        _burn(msg.sender, target, amount);
    }

    function _burn(address zchfHolder, address target, uint256 amount) internal {
        zchf.burnFrom(zchfHolder, amount);
        chf.transfer(target, amount);
        minted -= amount;
    }
}
/**
 * SPDX-License-Identifier: MIT
 *
 * Copyright (c) 2016-2019 zOS Global Limited
 *
 */
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns always true. Throws error on failure.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value can change when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns always true. Throws error on failure.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC677Receiver {
    
    function onTokenTransfer(address from, uint256 amount, bytes calldata data) external returns (bool);

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IReserve.sol";

interface IFrankencoin is IERC20 {
    function suggestMinter(address _minter, uint256 _applicationPeriod, uint256 _applicationFee, string calldata _message) external;

    function registerPosition(address position) external;

    function denyMinter(address minter, address[] calldata helpers, string calldata message) external;

    function reserve() external view returns (IReserve);

    function minterReserve() external view returns (uint256);

    function calculateAssignedReserve(uint256 mintedAmount, uint32 _reservePPM) external view returns (uint256);

    function equity() external view returns (uint256);

    function isMinter(address minter) external view returns (bool);

    function getPositionParent(address position) external view returns (address);

    function mint(address target, uint256 amount) external;

    function mintWithReserve(address target, uint256 amount, uint32 reservePPM, uint32 feePPM) external;

    function burnFrom(address target, uint256 amount) external;

    function burnWithoutReserve(uint256 amountIncludingReserve, uint32 reservePPM) external;

    function burnFromWithReserve(address payer, uint256 targetTotalBurnAmount, uint32 _reservePPM) external returns (uint256);

    function burnWithReserve(uint256 amountExcludingReserve, uint32 reservePPM) external returns (uint256);

    function coverLoss(address source, uint256 amount) external;

    function collectProfits(address source, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";

interface IReserve is IERC20 {
   function invest(uint256 amount, uint256 expected) external returns (uint256);
   function checkQualified(address sender, address[] calldata helpers) external view;
}