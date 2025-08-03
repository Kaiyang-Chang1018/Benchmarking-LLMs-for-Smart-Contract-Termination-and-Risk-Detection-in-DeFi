// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

import { ERC20Helper } from "../modules/erc20-helper/src/ERC20Helper.sol";

import { IERC20Like, IGlobalsLike } from "./interfaces/Interfaces.sol";

import { IMigrator } from "./interfaces/IMigrator.sol";

contract Migrator is IMigrator {

    address public immutable override globals;
    address public immutable override newToken;
    address public immutable override oldToken;

    uint256 public immutable override tokenSplitScalar;

    bool public override active;

    constructor(address globals_, address oldToken_, address newToken_, uint256 scalar_) {
        require(scalar_ > 0, "M:C:ZERO_SCALAR");

        require(IERC20Like(newToken_).decimals() == IERC20Like(oldToken_).decimals(), "M:C:DECIMAL_MISMATCH");

        globals  = globals_;
        oldToken = oldToken_;
        newToken = newToken_;

        tokenSplitScalar = scalar_;
    }

    function migrate(uint256 oldTokenAmount_) external override returns (uint256 newTokenAmount_) {
        newTokenAmount_ = migrate(msg.sender, oldTokenAmount_);
    }

    function migrate(address recipient_, uint256 oldTokenAmount_) public override returns (uint256 newTokenAmount_) {
        require(active,                        "M:M:INACTIVE");
        require(oldTokenAmount_ != uint256(0), "M:M:ZERO_AMOUNT");

        newTokenAmount_ = oldTokenAmount_ * tokenSplitScalar;

        require(ERC20Helper.transferFrom(oldToken, msg.sender, address(this), oldTokenAmount_), "M:M:TRANSFER_FROM_FAILED");
        require(ERC20Helper.transfer(newToken, recipient_, newTokenAmount_),                    "M:M:TRANSFER_FAILED");
    }

    function setActive(bool active_) external override {
        require(
            msg.sender == IGlobalsLike(globals).governor() ||
            msg.sender == IGlobalsLike(globals).operationalAdmin(),
            "M:SA:NOT_PROTOCOL_ADMIN"
        );

        active = active_;
    }

}
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.7;

interface IMigrator {

    /**
     *  @dev    Get the status of the migrator.
     *  @return active_ True if migrations are active.
     */
    function active() external view returns (bool active_);

    /**
     *  @dev   Gets the Maple Globals address.
     *  @param globals_ The address of the Maple globals.
     */
    function globals() external view returns (address globals_);

    /**
     *  @dev    Get address of newToken.
     *  @return newToken_ The address of new token.
     */
    function newToken() external view returns (address newToken_);

    /**
     *  @dev    Get address of oldToken.
     *  @return oldToken_ The address of new token.
     */
    function oldToken() external view returns (address oldToken_);

    /**
     *  @dev    Exchange the oldToken for the same amount of newToken.
     *  @param  oldTokenAmount_ The amount of oldToken to swap for newToken.
     *  @return newTokenAmount_ The amount of newToken received.
     */
    function migrate(uint256 oldTokenAmount_) external returns (uint256 newTokenAmount_);

    /**
     *  @dev    Exchange the oldToken for the same amount of newToken.
     *  @param  recipient_      The address of the recipient of the newToken.
     *  @param  oldTokenAmount_ The amount of oldToken to swap for newToken.
     *  @return newTokenAmount_ The amount of newToken received.
     */
    function migrate(address recipient_, uint256 oldTokenAmount_) external returns (uint256 newTokenAmount_);

    /**
     *  @dev   Set the migrator to active or inactive.
     *  @param active_ True if migrations are active.
     */
    function setActive(bool active_) external;

    /**
     *  @dev    Get the scalar value for token split.
     *  @return tokenSplitScalar_ The scalar value for token split.
     */
    function tokenSplitScalar() external view returns (uint256 tokenSplitScalar_);

}
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

interface IERC20Like {

    function decimals() external view returns (uint8 decimals_);

}

interface IGlobalsLike {

    function governor() external view returns (address governor_);

    function operationalAdmin() external view returns (address operationalAdmin_);

}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

import { IERC20Like } from "./interfaces/IERC20Like.sol";

/**
 * @title Small Library to standardize erc20 token interactions.
 */
library ERC20Helper {

    /**************************/
    /*** Internal Functions ***/
    /**************************/

    function transfer(address token_, address to_, uint256 amount_) internal returns (bool success_) {
        return _call(token_, abi.encodeWithSelector(IERC20Like.transfer.selector, to_, amount_));
    }

    function transferFrom(address token_, address from_, address to_, uint256 amount_) internal returns (bool success_) {
        return _call(token_, abi.encodeWithSelector(IERC20Like.transferFrom.selector, from_, to_, amount_));
    }

    function approve(address token_, address spender_, uint256 amount_) internal returns (bool success_) {
        // If setting approval to zero fails, return false.
        if (!_call(token_, abi.encodeWithSelector(IERC20Like.approve.selector, spender_, uint256(0)))) return false;

        // If `amount_` is zero, return true as the previous step already did this.
        if (amount_ == uint256(0)) return true;

        // Return the result of setting the approval to `amount_`.
        return _call(token_, abi.encodeWithSelector(IERC20Like.approve.selector, spender_, amount_));
    }

    function _call(address token_, bytes memory data_) private returns (bool success_) {
        if (token_.code.length == uint256(0)) return false;

        bytes memory returnData;
        ( success_, returnData ) = token_.call(data_);

        return success_ && (returnData.length == uint256(0) || abi.decode(returnData, (bool)));
    }

}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

/// @title Interface of the ERC20 standard as needed by ERC20Helper.
interface IERC20Like {

    function approve(address spender_, uint256 amount_) external returns (bool success_);

    function transfer(address recipient_, uint256 amount_) external returns (bool success_);

    function transferFrom(address owner_, address recipient_, uint256 amount_) external returns (bool success_);

}