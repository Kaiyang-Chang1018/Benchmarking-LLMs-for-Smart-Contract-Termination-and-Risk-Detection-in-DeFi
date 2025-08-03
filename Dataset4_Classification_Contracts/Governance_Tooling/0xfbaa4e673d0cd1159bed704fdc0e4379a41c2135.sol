// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;

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
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function decimals() external view returns (uint8);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract OrionToLumiaConverter is Ownable {
    bool public isConversionEnabled = false;

    IERC20 public immutable orion;
    IERC20 public immutable lumia;
    uint256 public immutable conversionScaleFactor;
    uint8 public immutable orionDecimals;
    uint8 public immutable lumiaDecimals;

    event Convert(address account, uint256 ornAmount, uint256 lumiaAmount);

    error ConversionDisabled();

    constructor(
        address _owner,
        IERC20 _orion,
        IERC20 _lumia,
        uint256 _conversionScaleFactor
    ) {
        transferOwnership(_owner);
        orion = _orion;
        lumia = _lumia;
        conversionScaleFactor = _conversionScaleFactor;

        orionDecimals = orion.decimals();
        lumiaDecimals = lumia.decimals();
    }

    function convert(uint256 ornAmount) external {
        if (!isConversionEnabled) revert ConversionDisabled();

        orion.transferFrom(msg.sender, address(this), ornAmount);

        uint256 lumiaAmount = calculateLumiaAmount(ornAmount);

        lumia.transfer(msg.sender, lumiaAmount);

        emit Convert(msg.sender, ornAmount, lumiaAmount);
    }

    function toggleIsConversionEnabled() external onlyOwner {
        isConversionEnabled = !isConversionEnabled;
    }

    function burn(address token, address burnAddress, uint256 amount) external onlyOwner {
        IERC20(token).transfer(burnAddress, amount);
    }

    function calculateLumiaAmount(
        uint256 ornAmount
    ) internal view returns (uint256) {
        return
            ((ornAmount * conversionScaleFactor) * (10 ** lumiaDecimals)) /
            (10 ** orionDecimals);
    }
}