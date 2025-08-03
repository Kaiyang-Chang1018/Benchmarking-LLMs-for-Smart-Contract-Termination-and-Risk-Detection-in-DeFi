// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.18;

import { IMapleTokenInitializerLike, IGlobalsLike } from "./interfaces/Interfaces.sol";
import { IMapleTokenProxy }                         from "./interfaces/IMapleTokenProxy.sol";

contract MapleTokenProxy is IMapleTokenProxy {

    bytes32 internal constant GLOBALS_SLOT        = bytes32(uint256(keccak256("eip1967.proxy.globals")) - 1);
    bytes32 internal constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    constructor(address globals_, address implementation_, address initializer_, address tokenMigrator_) {
        _setAddress(GLOBALS_SLOT, globals_);
        _setAddress(IMPLEMENTATION_SLOT, implementation_);

        ( bool success_, ) = initializer_.delegatecall(abi.encodeWithSelector(
            IMapleTokenInitializerLike(initializer_).initialize.selector,
            tokenMigrator_,
            IGlobalsLike(globals_).mapleTreasury()
        ));

        require(success_, "MTP:INIT_FAILED");
    }

    /**************************************************************************************************************************************/
    /*** Overridden Functions                                                                                                           ***/
    /**************************************************************************************************************************************/

    function setImplementation(address newImplementation_) override external {
        IGlobalsLike globals_ = IGlobalsLike(_globals());

        require(msg.sender == globals_.governor(), "MTP:SI:NOT_GOVERNOR");

        bool isScheduledCall_ = globals_.isValidScheduledCall(msg.sender, address(this), "MTP:SET_IMPLEMENTATION", msg.data);

        require(isScheduledCall_, "MTP:SI:NOT_SCHEDULED");

        globals_.unscheduleCall(msg.sender, "MTP:SET_IMPLEMENTATION", msg.data);

        _setAddress(IMPLEMENTATION_SLOT, newImplementation_);

        emit ImplementationSet(newImplementation_);
    }

    /**************************************************************************************************************************************/
    /*** View Functions                                                                                                                 ***/
    /**************************************************************************************************************************************/

    function _globals() internal view returns (address globals_) {
        globals_ = _getAddress(GLOBALS_SLOT);
    }

    function _implementation() internal view returns (address implementation_) {
        implementation_ = _getAddress(IMPLEMENTATION_SLOT);
    }

    /**************************************************************************************************************************************/
    /*** Utility Functions                                                                                                              ***/
    /**************************************************************************************************************************************/

    function _setAddress(bytes32 slot_, address value_) internal {
        assembly {
            sstore(slot_, value_)
        }
    }

    function _getAddress(bytes32 slot_) internal view returns (address value_) {
        assembly {
            value_ := sload(slot_)
        }
    }

    /**************************************************************************************************************************************/
    /*** Fallback Function                                                                                                              ***/
    /**************************************************************************************************************************************/

    fallback() external {
        address implementation_ = _implementation();

        require(implementation_.code.length != 0, "MTP:F:NO_CODE_ON_IMPLEMENTATION");

        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation_, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.18;

interface IMapleTokenProxy {

    /**
     *  @dev   Emitted when the implementation address is set.
     *  @param implementation The address of the new implementation.
     */
    event ImplementationSet(address indexed implementation);

    /**
     *  @dev   Sets the implementation address.
     *  @param newImplementation The address to set the implementation to.
     */
    function setImplementation(address newImplementation) external;

}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.18;

interface IERC20Like {

    function burn(address from, uint256 value) external;

    function mint(address to, uint256 value) external;

    function totalSupply() external view returns (uint256 totalSupply);

}

interface IGlobalsLike {

    function governor() external view returns (address governor);

    function isInstanceOf(bytes32 instanceKey, address instance) external view returns (bool isInstance);

    function isValidScheduledCall(
        address          caller,
        address          target,
        bytes32          functionId,
        bytes   calldata callData
    ) external view returns (bool isValidScheduledCall);

    function mapleTreasury() external view returns (address mapleTreasury);

    function unscheduleCall(address caller, bytes32 functionId, bytes calldata callData) external;

}

interface IMapleTokenInitializerLike {

    function initialize(address migrator, address treasury) external;

}

interface IMapleTokenLike is IERC20Like {

    function globals() external view returns (address globals);

}