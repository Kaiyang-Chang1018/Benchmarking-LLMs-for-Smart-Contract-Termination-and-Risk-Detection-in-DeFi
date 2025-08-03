// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// LooksRare unopinionated libraries
import {LowLevelERC20Transfer} from "@looksrare/contracts-libs/contracts/lowLevelCallers/LowLevelERC20Transfer.sol";
import {IWETH} from "@looksrare/contracts-libs/contracts/interfaces/generic/IWETH.sol";
import {IERC20} from "@looksrare/contracts-libs/contracts/interfaces/generic/IERC20.sol";

/**
 * @title ProtocolFeeRecipient
 * @notice This contract is used to receive protocol fees and transfer them to the fee sharing setter.
 *         Fee sharing setter cannot receive ETH directly, so we need to use this contract as a middleman
 *         to convert ETH into WETH before sending it.
 * @author LooksRare protocol team (?,?)
 */
contract ProtocolFeeRecipient is LowLevelERC20Transfer {
    address public immutable FEE_SHARING_SETTER;
    IWETH public immutable WETH;

    error NothingToTransfer();

    constructor(address _feeSharingSetter, address _weth) {
        FEE_SHARING_SETTER = _feeSharingSetter;
        WETH = IWETH(_weth);
    }

    function transferETH() external {
        uint256 ethBalance = address(this).balance;

        if (ethBalance != 0) {
            WETH.deposit{value: ethBalance}();
        }

        uint256 wethBalance = IERC20(address(WETH)).balanceOf(address(this));

        if (wethBalance == 0) {
            revert NothingToTransfer();
        }
        _executeERC20DirectTransfer(address(WETH), FEE_SHARING_SETTER, wethBalance);
    }

    /**
     * @param currency ERC20 currency address
     */
    function transferERC20(address currency) external {
        uint256 balance = IERC20(currency).balanceOf(address(this));
        if (balance == 0) {
            revert NothingToTransfer();
        }
        _executeERC20DirectTransfer(currency, FEE_SHARING_SETTER, balance);
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @notice It is emitted if the call recipient is not a contract.
 */
error NotAContract();
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @notice It is emitted if the ETH transfer fails.
 */
error ETHTransferFail();

/**
 * @notice It is emitted if the ERC20 approval fails.
 */
error ERC20ApprovalFail();

/**
 * @notice It is emitted if the ERC20 transfer fails.
 */
error ERC20TransferFail();

/**
 * @notice It is emitted if the ERC20 transferFrom fails.
 */
error ERC20TransferFromFail();

/**
 * @notice It is emitted if the ERC721 transferFrom fails.
 */
error ERC721TransferFromFail();

/**
 * @notice It is emitted if the ERC1155 safeTransferFrom fails.
 */
error ERC1155SafeTransferFromFail();

/**
 * @notice It is emitted if the ERC1155 safeBatchTransferFrom fails.
 */
error ERC1155SafeBatchTransferFromFail();
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address dst, uint256 wad) external returns (bool);

    function withdraw(uint256 wad) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interfaces
import {IERC20} from "../interfaces/generic/IERC20.sol";

// Errors
import {ERC20TransferFail, ERC20TransferFromFail} from "../errors/LowLevelErrors.sol";
import {NotAContract} from "../errors/GenericErrors.sol";

/**
 * @title LowLevelERC20Transfer
 * @notice This contract contains low-level calls to transfer ERC20 tokens.
 * @author LooksRare protocol team (?,?)
 */
contract LowLevelERC20Transfer {
    /**
     * @notice Execute ERC20 transferFrom
     * @param currency Currency address
     * @param from Sender address
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function _executeERC20TransferFrom(address currency, address from, address to, uint256 amount) internal {
        if (currency.code.length == 0) {
            revert NotAContract();
        }

        (bool status, bytes memory data) = currency.call(abi.encodeCall(IERC20.transferFrom, (from, to, amount)));

        if (!status) {
            revert ERC20TransferFromFail();
        }

        if (data.length > 0) {
            if (!abi.decode(data, (bool))) {
                revert ERC20TransferFromFail();
            }
        }
    }

    /**
     * @notice Execute ERC20 (direct) transfer
     * @param currency Currency address
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function _executeERC20DirectTransfer(address currency, address to, uint256 amount) internal {
        if (currency.code.length == 0) {
            revert NotAContract();
        }

        (bool status, bytes memory data) = currency.call(abi.encodeCall(IERC20.transfer, (to, amount)));

        if (!status) {
            revert ERC20TransferFail();
        }

        if (data.length > 0) {
            if (!abi.decode(data, (bool))) {
                revert ERC20TransferFail();
            }
        }
    }
}