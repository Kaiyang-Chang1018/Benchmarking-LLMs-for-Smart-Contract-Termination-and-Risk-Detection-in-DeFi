// SPDX-License-Identifier: GPL-3.0-or-later
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./utils/TokenSalePurchase.sol";
import "./utils/RecoverableFunds.sol";

/**
 * @title TokenSale
 * @dev Main contract for managing token sales, including deposit, payment, withdraw, vesting, and fund recovery.
 * Inherits from Ownable2Step, RecoverableFunds and TokenSalePurchase.
 */
contract TokenSale is Ownable2Step, RecoverableFunds, TokenSalePurchase {
    /**
     * @dev Constructor to initialize the TokenSale contract with initial configurations.
     * @param sellableToken The address of the token that will be sold.
     * @param sellableTokenDecimals The number of decimals of the sellable token.
     *
     * Ownable(address initialOwner)
     * TeamWallet(address teamWallet)
     * RaisedFunds(bool autoWithdrawnRaisedFunds)
     * SellableToken(address sellableToken, uint8 sellableTokenDecimals)
     * PaymentToken(address[] memory tokens)
     * PaymentTokenDeposit(bool depositsEnabled)
     * Whitelist(bool whitelistingByDeposit, bytes32 merkleRoot)
     * Signature(address signer)
     * TokenSaleVesting(tokenVesting)
     * TokenSalePurchase(isReleaseAllowed, isBuyAllowed, isBuyWithProofAllowed, isBuyWithPriceAllowed)
     */
    constructor(
        address sellableToken,
        uint8 sellableTokenDecimals
    )
        Ownable(_msgSender())
        TeamWallet(address(0))
        RaisedFunds(false)
        SellableToken(sellableToken, sellableTokenDecimals)
        PaymentToken(new address[](0))
        PaymentTokenDeposit(false)
        Whitelist(false, bytes32(0))
        Signature(address(0))
        TokenSaleVesting(address(0))
        TokenSalePurchase(false, false, false, false)
    {}

    /**
     * @notice Returns the type of the token sale.
     * @return A string representing the type of the token sale.
     */
    function tokenSaleType() external pure returns (string memory) {
        return "full";
    }

    /**
     * @notice Returns the version of the token sale contract.
     * @return A string representing the version of the token sale contract.
     */
    function tokenSaleVersion() external pure returns (string memory) {
        return "1";
    }

    /**
     * @notice Pauses or unpauses the contract.
     * @dev Can only be called by the contract owner.
     * @param status A boolean indicating whether to pause (true) or unpause (false) the contract.
     */
    function setPause(bool status) external onlyOwner {
        if (status) {
            _pause();
        } else {
            _unpause();
        }
    }

    /**
     * @notice Returns the recoverable funds for a specific token.
     * @dev Overrides the getRecoverableFunds function from the RecoverableFunds contract.
     * Calculates the recoverable balance by excluding deposits and unclaimed raised funds for payment tokens.
     * @param token The address of the token.
     * @return The amount of recoverable funds.
     */
    function getRecoverableFunds(
        address token
    ) public view override returns (uint256) {
        uint256 accountedFunds = _getTotalTokenDeposit(token) +
            _getRaisedUnclaimed(token);
        if (accountedFunds > 0) {
            if (token == address(0)) {
                return address(this).balance - accountedFunds;
            } else {
                return IERC20(token).balanceOf(address(this)) - accountedFunds;
            }
        } else {
            return super.getRecoverableFunds(token);
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

interface ITokenVesting {
    /**
     * @notice Handles the purchase of tokens for a specific user during a token sale stage.
     * @dev This function is called by the TokenSale contract when tokens are purchased.
     * It verifies the allocation exists and increases the vested amount for the user.
     * @param user The address of the user purchasing tokens.
     * @param stageId The ID of the sale stage.
     * @param tokensToBuy The amount of tokens being purchased.
     * @return bool Returns true if the purchase is successfully processed.
     */
    function onTokensPurchase(
        address user,
        uint256 stageId,
        uint256 tokensToBuy
    ) external returns (bool);
}
// SPDX-License-Identifier: GPL-3.0-or-later
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title PaymentToken
 * @dev Abstract contract to manage a list of payment token addresses with add and remove functionalities.
 * Inherits from Ownable2Step.
 */
abstract contract PaymentToken is Ownable2Step {
    /// @dev List of allowed payment tokens.
    address[] private _tokens;

    /// @dev Mapping to check if a token exists in the allowed payment tokens list.
    mapping(address token => bool) private _tokenExist;

    /// @dev Event emitted when a new payment token is added.
    event PaymentTokenAdded(address token);

    /// @dev Event emitted when a payment token is removed.
    event PaymentTokenRemoved(address token);

    /// @dev Error thrown when a payment token is not found.
    error PaymentTokenNotFound(address token);

    /**
     * @dev Constructor to initialize the list of allowed payment tokens.
     * @param tokens The addresses of the tokens to add.
     */
    constructor(address[] memory tokens) {
        _addPaymentTokens(tokens);
    }

    /**
     * @dev Modifier to check if the token is allowed for payment.
     * Reverts with PaymentTokenNotFound error if the token is not allowed.
     * @param token The address of the token to check.
     */
    modifier onlyPaymentToken(address token) {
        _checkPaymentToken(token);
        _;
    }

    /**
     * @notice Verifies if a token is allowed for payment.
     * @param token The address of the token to verify.
     * @return bool True if the token is allowed, false otherwise.
     */
    function isPaymentToken(address token) external view returns (bool) {
        return _isPaymentToken(token);
    }

    /**
     * @notice Retrieves the list of all allowed payment tokens.
     * @return address[] List of allowed payment token addresses.
     */
    function getPaymentTokens() external view returns (address[] memory) {
        return _getPaymentTokens();
    }

    /**
     * @notice Adds new tokens to the list of allowed payment tokens.
     * @dev Can only be called by the contract owner.
     * Emits a PaymentTokenAdded event on successful addition.
     * @param tokens The addresses of the tokens to add.
     */
    function addPaymentTokens(address[] memory tokens) external onlyOwner {
        _addPaymentTokens(tokens);
    }

    /**
     * @notice Removes tokens from the list of allowed payment tokens.
     * @dev Can only be called by the contract owner.
     * Emits a PaymentTokenRemoved event on successful removal.
     * @param tokens The addresses of the tokens to remove.
     */
    function removePaymentTokens(address[] memory tokens) external onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            if (_isPaymentToken(token)) {
                _removeToken(token);
                emit PaymentTokenRemoved(token);
            }
        }
    }

    /**
     * @dev Internal function to check if a token is allowed for payment.
     * @param token The address of the token to check.
     * @return bool True if the token is allowed, false otherwise.
     */
    function _isPaymentToken(address token) internal view returns (bool) {
        return _tokenExist[token];
    }

    /**
     * @dev Internal function to check if a token is a valid payment token.
     * Reverts with PaymentTokenNotFound error if the token is not valid.
     * @param token The address of the token to check.
     */
    function _checkPaymentToken(address token) internal view {
        if (!_isPaymentToken(token)) {
            revert PaymentTokenNotFound(token);
        }
    }

    /**
     * @dev Internal function to get the list of all allowed payment tokens.
     * @return address[] List of allowed payment token addresses.
     */
    function _getPaymentTokens() internal view returns (address[] memory) {
        return _tokens;
    }

    /**
     * @dev Checks if the token list is empty and sets it to the default payment tokens list if true.
     * @param tokens The list of tokens to check.
     * @return The validated list of tokens.
     */
    function _getDefaultPaymentTokensIfEmpty(
        address[] memory tokens
    ) internal view returns (address[] memory) {
        if (tokens.length == 0) {
            return _getPaymentTokens();
        }
        return tokens;
    }

    /**
     * @dev Private function to add new payment tokens.
     * Adds new tokens to the list of accepted payment tokens if they are not already included.
     * Emits a PaymentTokenAdded event for each token added.
     * @param tokens The addresses of the tokens to add.
     */
    function _addPaymentTokens(address[] memory tokens) private {
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            if (!_isPaymentToken(token)) {
                _tokens.push(token);
                _tokenExist[token] = true;
                emit PaymentTokenAdded(token);
            }
        }
    }

    /**
     * @dev Private function to remove a token from the list.
     * @param token The address of the token to remove.
     */
    function _removeToken(address token) private {
        uint256 index = _findTokenIndex(token, _getPaymentTokens());
        uint256 lastIndex = _tokens.length - 1;
        address lastToken = _tokens[lastIndex];

        _tokens[index] = lastToken; // Move the last token to the index being removed.
        _tokens.pop(); // Remove the last element.

        delete _tokenExist[token];
    }

    /**
     * @dev Private function to find the index of a token in a given list.
     * Throws a PaymentTokenNotFound error if the token is not found in the list.
     * @param token The address of the token to find.
     * @param tokens The list of token addresses to search through.
     * @return uint256 The index of the token in the list.
     */
    function _findTokenIndex(
        address token,
        address[] memory tokens
    ) private pure returns (uint256) {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == token) {
                return i;
            }
        }
        revert PaymentTokenNotFound(token);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "../utils/SafePermit.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

import "./PaymentToken.sol";

/**
 * @title PaymentTokenDeposit
 * @dev Abstract contract to manage the deposit and withdrawal of payment tokens and native coin.
 * Allows users to deposit and withdraw tokens, supports permit for deposit,
 * and allows the owner to force the return of tokens to users.
 * Inherits from Ownable2Step, ReentrancyGuard, Pausable and PaymentToken.
 */
abstract contract PaymentTokenDeposit is
    Ownable2Step,
    ReentrancyGuard,
    Pausable,
    PaymentToken
{
    using SafeERC20 for IERC20;
    using SafePermit for IERC20Permit;
    using Address for address payable;

    /// @dev Mapping to store total deposits per token.
    mapping(address token => uint256) private _totalDeposits;

    /// @dev Mapping to store user deposits per token.
    mapping(address user => mapping(address token => uint256))
        private _userDeposits;

    /// @dev Flag to enable or disable deposits.
    bool private _depositsEnabled;

    /**
     * @dev Emitted when a user deposits tokens or native coin.
     * @param user The address of the user who made the deposit.
     * @param token The address of the token that was deposited (zero address for native coin).
     * @param amount The amount of tokens or native coin that were deposited.
     */
    event UserFundsDeposited(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    /**
     * @dev Emitted when a user withdraws tokens or native coin.
     * @param user The address of the user who made the withdrawal.
     * @param token The address of the token that was withdrawn (zero address for native coin).
     * @param amount The amount of tokens or native coin that were withdrawn.
     */
    event UserFundsWithdrawn(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    /**
     * @dev Emitted when the deposit status is updated.
     * @param status The new status of deposits.
     */
    event UpdatedDepositsEnabled(bool status);

    /// @dev Error indicating an invalid token amount.
    error InvalidTokenAmount();

    /// @dev Error indicating that the deposit balance is insufficient.
    error InsufficientDepositBalance();

    /// @dev Error indicating that deposits are currently disabled.
    error DepositsDisabled();

    /**
     * @dev Constructor to initialize the deposit status.
     * @param depositsEnabled Initial status of deposits.
     */
    constructor(bool depositsEnabled) {
        _setDepositsEnabled(depositsEnabled);
    }

    /**
     * @notice Returns the current status of deposits.
     * @return A boolean indicating whether deposits are enabled.
     */
    function isDepositsEnabled() external view returns (bool) {
        return _depositsEnabled;
    }

    /**
     * @notice Returns the total deposits for the specified tokens.
     * @dev If the input array of tokens is empty, it defaults to the predefined payment tokens.
     * @param tokens_ The list of token addresses.
     * @return tokens The list of token addresses.
     * @return deposits The list of corresponding deposit amounts.
     */
    function getTotalDeposits(
        address[] memory tokens_
    )
        external
        view
        returns (address[] memory tokens, uint256[] memory deposits)
    {
        tokens = _getDefaultPaymentTokensIfEmpty(tokens_);
        deposits = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            deposits[i] = _getTotalTokenDeposit(tokens[i]);
        }
    }

    /**
     * @notice Returns the user's deposits for the specified tokens.
     * @dev If the input array of tokens is empty, it defaults to the predefined payment tokens.
     * @param user The address of the user.
     * @param tokens_ The list of token addresses.
     * @return tokens The list of token addresses.
     * @return deposits The list of corresponding deposit amounts.
     */
    function getUserDeposits(
        address user,
        address[] memory tokens_
    )
        external
        view
        returns (address[] memory tokens, uint256[] memory deposits)
    {
        tokens = _getDefaultPaymentTokensIfEmpty(tokens_);
        deposits = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            deposits[i] = _getUserTokenDeposit(user, tokens[i]);
        }
    }

    /**
     * @notice Allows users to deposit allowed payment tokens or native coin.
     * @param token The address of the token to deposit (use zero address for native coin).
     * @param amount The amount of the token or native coin to deposit.
     */
    function deposit(address token, uint256 amount) external payable {
        _deposit(_msgSender(), token, amount);
    }

    /**
     * @notice Allows users to deposit payment tokens using a permit.
     * @param token The address of the payment token to deposit.
     * @param amount The amount of the token to deposit.
     * @param deadline The deadline for the permit.
     * @param v The v component of the permit signature.
     * @param r The r component of the permit signature.
     * @param s The s component of the permit signature.
     */
    function depositWithPermit(
        address token,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        address user = _msgSender();
        IERC20Permit(token).safePermit(
            user,
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );
        _deposit(user, token, amount);
    }

    /**
     * @notice Allows users to withdraw their deposited tokens or native coin without restrictions.
     * @dev If the input array of tokens is empty, it defaults to the predefined payment tokens.
     * @param tokens The list of token addresses to withdraw (use zero address for native coin).
     */
    function cancelDeposit(address[] memory tokens) external nonReentrant {
        tokens = _getDefaultPaymentTokensIfEmpty(tokens);
        _cancelDeposit(_msgSender(), tokens);
    }

    /**
     * @notice Allows the owner to force the return of tokens to users.
     * @dev Can only be called by the contract owner.
     * If the input array of tokens is empty, it defaults to the predefined payment tokens.
     * @param users The list of user addresses to return tokens or native coin to.
     * @param tokens The list of token addresses to return (use zero address for native coin).
     */
    function cancelDepositForced(
        address[] memory users,
        address[] memory tokens
    ) external onlyOwner nonReentrant {
        tokens = _getDefaultPaymentTokensIfEmpty(tokens);
        for (uint256 i = 0; i < users.length; i++) {
            _cancelDeposit(users[i], tokens);
        }
    }

    /**
     * @notice Allows the owner to enable/disable deposits.
     * @dev Can only be called by the contract owner.
     * @param status The new status of deposits.
     */
    function setDepositsEnabled(bool status) external onlyOwner {
        _setDepositsEnabled(status);
    }

    /**
     * @dev Internal function to get the total deposit for a specific token.
     * @param token The address of the token.
     * @return The total deposit amount for the specified token.
     */
    function _getTotalTokenDeposit(
        address token
    ) internal view returns (uint256) {
        return _totalDeposits[token];
    }

    /**
     * @dev Internal function to get the user's deposit for a specific token.
     * @param user The address of the user.
     * @param token The address of the token.
     * @return The user's deposit amount for the specified token.
     */
    function _getUserTokenDeposit(
        address user,
        address token
    ) internal view returns (uint256) {
        return _userDeposits[user][token];
    }

    /**
     * @dev Internal function to reduce the user's deposit balance.
     * @param user The address of the user.
     * @param token The address of the token.
     * @param amount The amount to reduce.
     */
    function _reduceDeposit(
        address user,
        address token,
        uint256 amount
    ) internal {
        if (amount > _getUserTokenDeposit(user, token)) {
            revert InsufficientDepositBalance();
        }
        _totalDeposits[token] -= amount;
        _userDeposits[user][token] -= amount;
    }

    /**
     * @dev Internal function to handle deposits of tokens or native coin.
     * Emits a UserFundsDeposited event upon successful deposit.
     * @param user The address of the user making the deposit.
     * @param token The address of the token being deposited.
     * @param amount The amount of the token being deposited.
     */
    function _deposit(
        address user,
        address token,
        uint256 amount
    ) internal virtual onlyPaymentToken(token) whenNotPaused {
        if (!_depositsEnabled) {
            revert DepositsDisabled();
        }

        if (amount == 0) {
            revert InvalidTokenAmount();
        }

        if (token == address(0)) {
            // Handle native coin deposit.
            if (msg.value != amount) {
                // If msg.value is not equal to amount.
                revert InvalidTokenAmount();
            }
        } else if (msg.value != 0) {
            // Reject non-zero msg.value for ERC20 token deposit.
            revert InvalidTokenAmount();
        } else {
            // Handle ERC20 token deposit.
            IERC20 _token = IERC20(token);
            uint256 before = _token.balanceOf(address(this));
            _token.safeTransferFrom(user, address(this), amount);

            uint256 delta = _token.balanceOf(address(this)) - before;
            // Check and prohibition of tax tokens.
            if (delta != amount) {
                revert InvalidTokenAmount();
            }
        }

        _totalDeposits[token] += amount;
        _userDeposits[user][token] += amount;
        emit UserFundsDeposited(user, token, amount);
    }

    /**
     * @dev Internal function to handle the cancellation of deposits.
     * Emits a UserFundsWithdrawn event upon successful withdrawal.
     * @param user The address of the user whose deposits are being canceled.
     * @param tokens The list of token addresses to withdraw.
     */
    function _cancelDeposit(
        address user,
        address[] memory tokens
    ) internal virtual {
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 deposited = _getUserTokenDeposit(user, token);

            if (deposited > 0) {
                _reduceDeposit(user, token, deposited);
                _transferDepositTo(user, token, deposited);
                emit UserFundsWithdrawn(user, token, deposited);
            }
        }
    }

    /**
     * @dev Private function to transfer tokens or native coin to a user.
     * @param user The address of the user.
     * @param token The address of the token to transfer (use zero address for native coin).
     * @param amount The amount of tokens or native coin to transfer.
     */
    function _transferDepositTo(
        address user,
        address token,
        uint256 amount
    ) private {
        if (token == address(0)) {
            payable(user).sendValue(amount);
        } else {
            IERC20(token).safeTransfer(user, amount);
        }
    }

    /**
     * @dev Private function to set the deposit status.
     * Emits an {UpdatedDepositsEnabled} event upon changing the deposit status.
     * @param status The new status of deposits (true to enable, false to disable).
     */
    function _setDepositsEnabled(bool status) private {
        _depositsEnabled = status;
        emit UpdatedDepositsEnabled(status);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./TeamWallet.sol";
import "./PaymentToken.sol";

/**
 * @title RaisedFunds
 * @dev Abstract contract to manage raised funds in different tokens, with auto-withdrawal functionality to the team wallet.
 * Inherits from Ownable2Step, ReentrancyGuard, TeamWallet and PaymentToken.
 */
abstract contract RaisedFunds is
    Ownable2Step,
    ReentrancyGuard,
    TeamWallet,
    PaymentToken
{
    using SafeERC20 for IERC20;
    using Address for address payable;

    /// @dev Mapping to track unclaimed raised funds for each token.
    mapping(address token => uint256) private _raisedUnclaimed;

    /// @dev Flag to enable auto-withdrawal of funds to the team wallet.
    bool private _autoWithdrawnRaisedFunds;

    /// @dev Event emitted when the auto-withdrawal funds status is updated.
    event AutoWithdrawnRaisedFundsUpdated(bool status);

    /// @dev Event emitted when funds are deposited.
    event RaisedFundsDeposited(address indexed token, uint256 amount);

    /// @dev Event emitted when funds are withdrawn.
    event RaisedFundsWithdrawn(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    /**
     * @dev Constructor to initialize the contract with the auto-withdraw funds status.
     * @param autoWithdrawnRaisedFunds Initial status of auto-withdraw funds.
     */
    constructor(bool autoWithdrawnRaisedFunds) {
        _setAutoWithdrawRaisedFunds(autoWithdrawnRaisedFunds);
    }

    /**
     * @notice Returns the current status of auto-withdraw funds.
     * @return The status of auto-withdraw funds.
     */
    function getAutoWithdrawRaisedFunds() external view returns (bool) {
        return _autoWithdrawnRaisedFunds;
    }

    /**
     * @notice Returns the amount of unclaimed raised funds for the specified tokens.
     * @dev If the input array of tokens is empty, it defaults to the predefined payment tokens.
     * @param tokens_ An array of token addresses to query for unclaimed raised funds.
     * @return tokens An array of token addresses to query for unclaimed raised funds.
     * @return funds An array containing the amount of unclaimed raised funds for each specified token.
     */
    function getRaisedUnclaimedFunds(
        address[] memory tokens_
    ) external view returns (address[] memory tokens, uint256[] memory funds) {
        tokens = _getDefaultPaymentTokensIfEmpty(tokens_);
        funds = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            funds[i] = _getRaisedUnclaimed(tokens[i]);
        }
    }

    /**
     * @notice Allows the owner to withdraw raised funds for the specified tokens.
     * @dev Can only be called by the contract owner.
     * If the input array of tokens is empty, it defaults to the predefined payment tokens.
     * @param tokens The list of token addresses to withdraw.
     */
    function withdrawRaisedFunds(
        address[] memory tokens
    ) external whenTeamWalletIsNotZero onlyOwner nonReentrant {
        tokens = _getDefaultPaymentTokensIfEmpty(tokens);
        for (uint256 i = 0; i < tokens.length; i++) {
            _withdrawRaisedFunds(tokens[i]);
        }
    }

    /**
     * @notice Allows the owner to set the auto-withdraw funds status.
     * @dev Can only be called by the contract owner.
     * @param status The new status of auto-withdraw funds.
     */
    function setAutoWithdrawRaisedFunds(bool status) external onlyOwner {
        _setAutoWithdrawRaisedFunds(status);
    }

    /**
     * @dev Internal function to get the unclaimed raised funds for a specific token.
     * @param token The address of the token.
     * @return The unclaimed raised funds amount.
     */
    function _getRaisedUnclaimed(
        address token
    ) internal view returns (uint256) {
        return _raisedUnclaimed[token];
    }

    /**
     * @dev Internal function to increase the raised funds for a specific token.
     * If auto-withdrawal is enabled and the team wallet is set, transfers the funds to the team wallet.
     * Emits a RaisedFundsDeposited event upon increasing the funds.
     * @param token The address of the token.
     * @param amount The amount to increase.
     */
    function _increaseRaisedFunds(address token, uint256 amount) internal {
        emit RaisedFundsDeposited(token, amount);
        if (_autoWithdrawnRaisedFunds && !_isTeamWalletZero()) {
            _transferRaisedFundsTo(_getTeamWallet(), token, amount);
        } else {
            _raisedUnclaimed[token] += amount;
        }
    }

    /**
     * @dev Private function to decrease the raised funds for a specific token.
     * @param token The address of the token.
     * @param amount The amount to decrease.
     */
    function _decreaseRaisedFunds(address token, uint256 amount) private {
        _raisedUnclaimed[token] -= amount;
    }

    /**
     * @dev Private function to withdraw raised funds for a specific token.
     * @param token The address of the token to withdraw.
     */
    function _withdrawRaisedFunds(address token) private {
        uint256 amount = _getRaisedUnclaimed(token);
        if (amount > 0) {
            _decreaseRaisedFunds(token, amount);
            _transferRaisedFundsTo(_getTeamWallet(), token, amount);
        }
    }

    /**
     * @dev Private function to transfer tokens or ETH to a specified address.
     * Emits a RaisedFundsWithdrawn event upon successful transfer.
     * @param user The address to transfer the funds to.
     * @param token The address of the token to transfer, or address(0) for ETH.
     * @param amount The amount to transfer.
     */
    function _transferRaisedFundsTo(
        address user,
        address token,
        uint256 amount
    ) private {
        if (token == address(0)) {
            payable(user).sendValue(amount);
        } else {
            IERC20(token).safeTransfer(user, amount);
        }
        emit RaisedFundsWithdrawn(user, token, amount);
    }

    /**
     * @dev Private function to set the auto-withdraw funds status.
     * Emits an AutoWithdrawnRaisedFundsUpdated event upon updating the status.
     * @param status The new status of auto-withdraw funds.
     */
    function _setAutoWithdrawRaisedFunds(bool status) private {
        _autoWithdrawnRaisedFunds = status;
        emit AutoWithdrawnRaisedFundsUpdated(status);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title RecoverableFunds
 * @dev Abstract contract that allows the owner to recover accidentally sent ERC20 tokens
 * and native coins (ETH) that are not part of the project's tracked funds.
 * Ensures the amount to be recovered does not exceed the recoverable balance.
 * Inherits from Ownable2Step and ReentrancyGuard.
 */
abstract contract RecoverableFunds is Ownable2Step, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address payable;

    /**
     * @dev Emitted when funds are recovered.
     * @param user The address that received the recovered funds.
     * @param token The address of the recovered ERC20 token or address(0) for ETH.
     * @param amount The amount of ERC20 tokens or ETH recovered.
     */
    event FundsRecovered(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    /// @dev Error to indicate that the amount to be recovered exceeds the recoverable balance.
    error AmountExceedsRecoverableFunds();

    /// @dev Error to indicate that the recipient address is zero.
    error RecipientIsZeroAddress();

    /**
     * @notice Returns the recoverable amount of a specific token or ETH.
     * @dev If the `token` is the zero address, it returns the balance of the contract in ETH.
     * Otherwise, it returns the balance of the specified ERC20 token held by the contract.
     * This function is designed to be overridden in derived contracts if needed.
     * @param token The address of the ERC20 token or the zero address for ETH.
     * @return The recoverable amount of the specified token or ETH.
     */
    function getRecoverableFunds(
        address token
    ) public view virtual returns (uint256) {
        if (token == address(0)) return address(this).balance;
        else return IERC20(token).balanceOf(address(this));
    }

    /**
     * @notice Allows the owner to recover ERC20 tokens and native coins (ETH) accidentally sent to the contract.
     * @dev Can only be called by the contract owner.
     * Ensures the amount to be recovered does not exceed the recoverable balance.
     * Emits a FundsRecovered event.
     * @param user The address to receive recovered funds from the contract.
     * @param token The address of the ERC20 token to recover or address(0) to recover ETH.
     * @param amount The amount of ERC20 tokens or ETH to recover.
     * @return Returns true if the recovery was successful.
     */
    function recoverFunds(
        address user,
        address token,
        uint256 amount
    ) external onlyOwner nonReentrant returns (bool) {
        if (user == address(0)) {
            revert RecipientIsZeroAddress();
        }

        uint256 recoverableAmount = getRecoverableFunds(token);
        if (amount > recoverableAmount) {
            revert AmountExceedsRecoverableFunds();
        }

        _transferRecoverableFundsTo(user, token, amount);
        emit FundsRecovered(user, token, amount);
        return true;
    }

    /**
     * @dev Private function to handle the transfer of recovered funds.
     * @param user The address to receive the recovered funds.
     * @param token The address of the ERC20 token to recover or address(0) to recover ETH.
     * @param amount The amount of ERC20 tokens or ETH to recover.
     */
    function _transferRecoverableFundsTo(
        address user,
        address token,
        uint256 amount
    ) private {
        if (token == address(0)) {
            payable(user).sendValue(amount);
        } else {
            IERC20(token).safeTransfer(user, amount);
        }
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

/**
 * @title SafePermit
 * @dev Library to safely handle ERC-2612 permits for ERC-20 tokens.
 * Provides a function to securely grant approvals using off-chain signatures.
 */
library SafePermit {
    /**
     * @dev Error indicating that the permit operation did not succeed.
     * @param token The address of the token for which the permit operation failed.
     */
    error SafeERC20PermitDidNotSucceed(address token);

    /**
     * @dev Uses an ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Reverts on invalid signature or unsuccessful permit operation.
     * @param token The token contract supporting the ERC-2612 interface.
     * @param owner The address of the token owner.
     * @param spender The address to receive the approval.
     * @param value The amount of tokens to be approved.
     * @param deadline The deadline timestamp by which the permit must be mined.
     * @param v The recovery byte of the signature.
     * @param r Half of the ECDSA signature pair.
     * @param s Half of the ECDSA signature pair.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        if (nonceAfter != nonceBefore + 1) {
            revert SafeERC20PermitDidNotSucceed(address(token));
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title SellableToken
 * @dev Abstract contract to manage a sellable token address and its decimals. Allows setting and freezing the sellable token.
 * Inherits from Ownable2Step.
 */
abstract contract SellableToken is Ownable2Step {
    /// @dev Indicates whether the sellable token is frozen.
    bool private _sellableTokenFrozen;

    /// @dev Address of the sellable token.
    address private _sellableToken;

    /// @dev Number of decimals of the sellable token.
    uint8 private _sellableTokenDecimals;

    /// @dev Event emitted when the sellable token is updated.
    event SellableTokenUpdated(address token, uint8 decimals);

    /// @dev Event emitted when the sellable token is frozen.
    event SellableTokenFrozen();

    /// @dev Error thrown when the sellable token address is zero.
    error SellableTokenIsZero();

    /// @dev Error thrown when the sellable token decimals is zero.
    error SellableTokenDecimalsIsZero();

    /// @dev Error thrown when the sellable token is frozen.
    error SellableTokenIsFrozen();

    /**
     * @dev Sets the initial values for the sellable token and its decimals.
     * @param token The address of the sellable token.
     * @param decimals The number of decimals of the sellable token. Must be greater than 0.
     */
    constructor(address token, uint8 decimals) {
        _setSellableToken(token, decimals);
    }

    /// @dev Modifier to check if the sellable token address is not zero.
    modifier whenSellableTokenIsNotZero() {
        if (_getSellableToken() == address(0)) {
            revert SellableTokenIsZero();
        }
        _;
    }

    /**
     * @notice Gets the sellable token details.
     * @return isFrozen Boolean indicating if the sellable token is frozen.
     * @return token The address of the sellable token.
     * @return decimals The number of decimals of the sellable token.
     */
    function getSellableToken()
        external
        view
        returns (bool isFrozen, address token, uint8 decimals)
    {
        isFrozen = _isSellableTokenFrozen();
        token = _getSellableToken();
        decimals = _getSellableTokenDecimals();
    }

    /**
     * @notice Sets the sellable token and its decimals.
     * @dev Can only be called by the contract owner and if the sellable token is not frozen.
     * @param token The address of the sellable token.
     * @param decimals The number of decimals of the sellable token. Must be greater than 0.
     */
    function setSellableToken(
        address token,
        uint8 decimals
    ) external onlyOwner {
        if (_isSellableTokenFrozen()) {
            revert SellableTokenIsFrozen();
        }
        _setSellableToken(token, decimals);
    }

    /**
     * @notice Freezes the sellable token, preventing further changes to its address or decimals.
     * @dev Can only be called by the contract owner and only if the sellable token is not already frozen.
     * This action is irreversible. Once the sellable token is frozen, it cannot be unfrozen.
     * Emits a SellableTokenFrozen event upon successful freezing of the sellable token.
     */
    function freezeSellableToken()
        external
        whenSellableTokenIsNotZero
        onlyOwner
    {
        if (_sellableTokenFrozen) {
            revert SellableTokenIsFrozen();
        }

        _sellableTokenFrozen = true;
        emit SellableTokenFrozen();
    }

    /**
     * @dev Internal function to get the address of the sellable token.
     * @return The address of the sellable token.
     */
    function _getSellableToken() internal view returns (address) {
        return _sellableToken;
    }

    /**
     * @dev Internal function to get the number of decimals of the sellable token.
     * @return The number of decimals of the sellable token.
     */
    function _getSellableTokenDecimals() internal view returns (uint8) {
        return _sellableTokenDecimals;
    }

    /**
     * @dev Private function to check if the sellable token is frozen.
     * @return Boolean indicating if the sellable token is frozen.
     */
    function _isSellableTokenFrozen() private view returns (bool) {
        return _sellableTokenFrozen;
    }

    /**
     * @dev Private function to set the sellable token and its decimals.
     * Emits a SellableTokenUpdated event.
     * @param token The address of the sellable token.
     * @param decimals The number of decimals of the sellable token. Must be greater than 0.
     */
    function _setSellableToken(address token, uint8 decimals) private {
        if (decimals == 0) {
            revert SellableTokenDecimalsIsZero();
        }

        _sellableToken = token;
        _sellableTokenDecimals = decimals;
        emit SellableTokenUpdated(token, decimals);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title Signature
 * @dev Abstract contract to authorize token purchases using signatures provided by a server.
 * The contract checks the validity of signatures to ensure authorized transactions.
 * Inherits from Ownable2Step.
 */
abstract contract Signature is Ownable2Step {
    /// @dev The chain ID of the network.
    uint256 private immutable _chainId;

    /// @dev The address of the authorized signer.
    address private _signer;

    /// @dev Nonce to track signatures per user.
    mapping(address user => uint256) private _userNonce;

    /// @dev Event emitted when the signer address is updated.
    event SignerUpdated(address signer);

    /// @dev Event emitted when the user used nonce.
    event UserSignatureNonceUsed(address indexed user, uint256 nonce);

    /// @dev Error thrown when the signer address is zero.
    error SignerIsZeroAddress();

    /// @dev Error thrown when an unauthorized action is attempted.
    error NotAuthorized();

    /**
     * @dev Initializes the contract with the provided signer address and sets the chain ID.
     * @param signer The address of the initial signer.
     */
    constructor(address signer) {
        _chainId = block.chainid;
        _setSigner(signer);
    }

    /**
     * @notice Returns the current nonce for the given user address.
     * @param user The address of the user.
     * @return The current nonce for the user.
     */
    function getUserSignatureNonce(
        address user
    ) external view returns (uint256) {
        return _userNonce[user];
    }

    /**
     * @notice Returns the chain ID of the network.
     * @return The chain ID.
     */
    function getChainId() external view returns (uint256) {
        return _chainId;
    }

    /**
     * @notice Returns the address of the current signer.
     * @return The address of the signer.
     */
    function getSigner() external view returns (address) {
        return _signer;
    }

    /**
     * @notice Checks the validity of a provided signature for the given parameters without incrementing the nonce.
     * @dev This function can be called externally to verify the signature without affecting the state.
     * @param user The address of the user.
     * @param stageId The ID of the purchase stage.
     * @param token The address of the payment token used for the purchase.
     * @param price The price of the tokens.
     * @param tokensToPay The amount of payment tokens to pay.
     * @param signature The signature provided by the server.
     * @return bool Returns true if the signature is valid, otherwise false.
     */
    function checkSignatureBuyWithPrice(
        address user,
        uint256 stageId,
        address token,
        uint256 price,
        uint256 tokensToPay,
        bytes memory signature
    ) external view returns (bool) {
        if (
            _signatureBuyWithPriceWallet(
                _chainId,
                user,
                _userNonce[user],
                stageId,
                token,
                price,
                tokensToPay,
                signature
            ) != _signer
        ) {
            return false;
        }
        return true;
    }

    /**
     * @notice Checks the validity of a provided signature for the given parameters without incrementing the nonce.
     * @dev This function can be called externally to verify the signature without affecting the state.
     * @param user The address of the user.
     * @param stageId The ID of the purchase stage.
     * @param tokensToBuy The amount of tokens to purchase.
     * @param signature The signature provided by the server.
     * @return bool Returns true if the signature is valid, otherwise false.
     */
    function checkSignatureRelease(
        address user,
        uint256 stageId,
        uint256 tokensToBuy,
        bytes memory signature
    ) external view returns (bool) {
        if (
            _signatureReleaseWallet(
                _chainId,
                user,
                _userNonce[user],
                stageId,
                tokensToBuy,
                signature
            ) != _signer
        ) {
            return false;
        }
        return true;
    }

    /**
     * @notice Sets a new signer address. Can only be called by the owner.
     * @dev Can only be called by the contract owner.
     * @param newSigner The address of the new signer.
     */
    function setSigner(address newSigner) external onlyOwner {
        _setSigner(newSigner);
    }

    /**
     * @dev Checks the validity of the provided signature for the given parameters.
     * Increments the user's nonce if the signature is valid.
     * Reverts with NotAuthorized error if the signature is invalid.
     * @param user The address of the user.
     * @param stageId The ID of the purchase stage.
     * @param token The address of the payment token used for the purchase.
     * @param price The price of the tokens.
     * @param tokensToPay The amount of payment tokens to pay.
     * @param signature The signature provided by the server.
     */
    function _checkSignatureBuyWithPrice(
        address user,
        uint256 stageId,
        address token,
        uint256 price,
        uint256 tokensToPay,
        bytes memory signature
    ) internal {
        _ensureSignerIsNotZeroAddress();

        uint256 userNonce = _userNonce[user];
        if (
            _signatureBuyWithPriceWallet(
                _chainId,
                user,
                userNonce,
                stageId,
                token,
                price,
                tokensToPay,
                signature
            ) != _signer
        ) {
            revert NotAuthorized();
        }
        _userNonce[user] += 1;
        emit UserSignatureNonceUsed(user, userNonce);
    }

    /**
     * @dev Checks the validity of the provided signature for the given parameters.
     * Increments the user's nonce if the signature is valid.
     * Reverts with NotAuthorized error if the signature is invalid.
     * @param user The address of the user.
     * @param stageId The ID of the purchase stage.
     * @param tokensToBuy The amount of tokens to purchase.
     * @param signature The signature provided by the server.
     */
    function _checkSignatureRelease(
        address user,
        uint256 stageId,
        uint256 tokensToBuy,
        bytes memory signature
    ) internal {
        _ensureSignerIsNotZeroAddress();

        uint256 userNonce = _userNonce[user];
        if (
            _signatureReleaseWallet(
                _chainId,
                user,
                userNonce,
                stageId,
                tokensToBuy,
                signature
            ) != _signer
        ) {
            revert NotAuthorized();
        }
        _userNonce[user] += 1;
        emit UserSignatureNonceUsed(user, userNonce);
    }

    /**
     * @dev Recovers the address that signed the message given the provided parameters.
     * @param chainId The chain ID.
     * @param user The address of the user.
     * @param userNonce The user's current nonce.
     * @param stageId The ID of the purchase stage.
     * @param token The address of the payment token used for the purchase.
     * @param price The price of the tokens.
     * @param tokensToPay The amount of payment tokens to pay.
     * @param signature The signature to recover the address from.
     * @return The address that signed the message.
     */
    function _signatureBuyWithPriceWallet(
        uint256 chainId,
        address user,
        uint256 userNonce,
        uint256 stageId,
        address token,
        uint256 price,
        uint256 tokensToPay,
        bytes memory signature
    ) private pure returns (address) {
        return
            ECDSA.recover(
                keccak256(
                    abi.encode(
                        chainId,
                        user,
                        userNonce,
                        stageId,
                        token,
                        price,
                        tokensToPay
                    )
                ),
                signature
            );
    }

    /**
     * @dev Recovers the address that signed the message given the provided parameters.
     * @param chainId The chain ID.
     * @param user The address of the user.
     * @param userNonce The user's current nonce.
     * @param stageId The ID of the purchase stage.
     * @param tokensToBuy The amount of tokens to purchase.
     * @param signature The signature to recover the address from.
     * @return The address that signed the message.
     */
    function _signatureReleaseWallet(
        uint256 chainId,
        address user,
        uint256 userNonce,
        uint256 stageId,
        uint256 tokensToBuy,
        bytes memory signature
    ) private pure returns (address) {
        return
            ECDSA.recover(
                keccak256(
                    abi.encode(chainId, user, userNonce, stageId, tokensToBuy)
                ),
                signature
            );
    }

    /**
     * @dev Private function to ensure the signer address is not zero.
     * @dev Reverts with `SignerIsZeroAddress` if the signer address is zero.
     */
    function _ensureSignerIsNotZeroAddress() private view {
        if (_signer == address(0)) {
            revert SignerIsZeroAddress();
        }
    }

    /**
     * @dev Private function to set the signer address.
     * Emits a SignerUpdated event.
     * @param newSigner The address of the new signer.
     */
    function _setSigner(address newSigner) private {
        _signer = newSigner;
        emit SignerUpdated(newSigner);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title TeamWallet
 * @dev Abstract contract for managing the team wallet address.
 * The team wallet can be set and changed by the contract owner.
 * Inherits from Ownable2Step.
 */
abstract contract TeamWallet is Ownable2Step {
    /// @dev Address of the team wallet.
    address private _teamWallet;

    /// @dev Flag indicating if the team wallet is frozen.
    bool private _teamWalletFrozen;

    /**
     * @dev Emitted when the team wallet address is changed.
     * @param teamWallet The new team wallet address.
     */
    event TeamWalletUpdated(address teamWallet);

    /// @dev Emitted when the team wallet is frozen.
    event TeamWalletFrozen();

    /// @dev Error thrown when the team wallet address is zero.
    error TeamWalletIsZero();

    /// @dev Error thrown when the team wallet is frozen and an update is attempted.
    error TeamWalletIsFrozen();

    /**
     * @dev Constructor to initialize the team wallet.
     * @param teamWallet The address of the initial team wallet.
     */
    constructor(address teamWallet) {
        _setTeamWallet(teamWallet);
    }

    /// @dev Modifier to check that the team wallet address is not zero.
    modifier whenTeamWalletIsNotZero() {
        if (_isTeamWalletZero()) {
            revert TeamWalletIsZero();
        }
        _;
    }

    /**
     * @notice Returns the current team wallet address and its frozen status.
     * @return isFrozen Indicates if the team wallet is frozen.
     * @return teamWallet The address of the team wallet.
     */
    function getTeamWallet()
        external
        view
        returns (bool isFrozen, address teamWallet)
    {
        isFrozen = _teamWalletFrozen;
        teamWallet = _getTeamWallet();
    }

    /**
     * @notice Sets a new team wallet address.
     * @dev Can only be called by the contract owner.
     * Emits a TeamWalletUpdated event.
     * @param teamWallet The address of the new team wallet.
     */
    function setTeamWallet(address teamWallet) external onlyOwner {
        if (_teamWalletFrozen) {
            revert TeamWalletIsFrozen();
        }
        _setTeamWallet(teamWallet);
    }

    /**
     * @notice Freezes the team wallet, preventing further changes.
     * @dev Can only be called by the contract owner.
     * Emits a TeamWalletFrozen event.
     */
    function freezeTeamWallet() external whenTeamWalletIsNotZero onlyOwner {
        if (_teamWalletFrozen) {
            revert TeamWalletIsFrozen();
        }

        _teamWalletFrozen = true;
        emit TeamWalletFrozen();
    }

    /**
     * @dev Internal function to get the team wallet address.
     * @return The address of the team wallet.
     */
    function _getTeamWallet() internal view returns (address) {
        return _teamWallet;
    }

    /**
     * @dev Internal function to check if the team wallet address is zero.
     * @return True if the team wallet address is zero, false otherwise.
     */
    function _isTeamWalletZero() internal view returns (bool) {
        return _getTeamWallet() == address(0);
    }

    /**
     * @dev Private function to set a new team wallet address and emit an event.
     * Emits a TeamWalletUpdated event.
     * @param teamWallet The address of the new team wallet.
     */
    function _setTeamWallet(address teamWallet) private {
        _teamWallet = teamWallet;
        emit TeamWalletUpdated(teamWallet);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "../utils/SafePermit.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

import "./Signature.sol";
import "./PaymentToken.sol";
import "./TokenSaleStages.sol";
import "./RaisedFunds.sol";
import "./TokenSaleVesting.sol";

import "../interface/ITokenVesting.sol";

/**
 * @title TokenSalePurchase
 * @dev This abstract contract manages purchase settings.
 * It allows buying tokens directly, with permits, or with signatures.
 * The contract owner can update purchase settings and control token sales.
 * Inherits from Ownable2Step, ReentrancyGuard, Pausable, PaymentToken, TokenSaleStages, RaisedFunds, TokenSaleVesting, and Signature.
 */
abstract contract TokenSalePurchase is
    Ownable2Step,
    ReentrancyGuard,
    Pausable,
    PaymentToken,
    TokenSaleStages,
    RaisedFunds,
    Signature,
    TokenSaleVesting
{
    using SafeERC20 for IERC20;
    using SafePermit for IERC20Permit;
    using Address for address payable;

    /**
     * @dev Struct to store purchase settings.
     * @param isReleaseAllowed Indicates if the release tokens with signature method is allowed.
     * @param isBuyAllowed Indicates if the direct buy method is allowed.
     * @param isBuyWithProofAllowed Indicates if the buy with Merkle Proof method is allowed.
     * @param isBuyWithPriceAllowed Indicates if the buy with signature and dinamic price method is allowed.
     */
    struct PurchaseSettings {
        bool isReleaseAllowed;
        bool isBuyAllowed;
        bool isBuyWithProofAllowed;
        bool isBuyWithPriceAllowed;
    }

    /// @dev Stores the current purchase settings.
    PurchaseSettings private _purchaseSettings;

    /**
     * @dev Emitted when the purchase settings are updated.
     * @param isReleaseAllowed The new status of the release tokens with signature method.
     * @param isBuyAllowed The new status of the direct buy method.
     * @param isBuyWithProofAllowed Indicates if the buy with Merkle Proof is allowed.
     * @param isBuyWithPriceAllowed The new status of the buy with signature and dinamic price method.
     */
    event PurchaseSettingsUpdated(
        bool isReleaseAllowed,
        bool isBuyAllowed,
        bool isBuyWithProofAllowed,
        bool isBuyWithPriceAllowed
    );

    /**
     * @dev Emitted when tokens are released.
     * For cases where payment has been received off-chain,
     * @param user The address of the user who bought the tokens.
     * @param stageId The ID of the sale stage.
     * @param amount The amount of tokens bought.
     */
    event TokensReleased(
        address indexed user,
        uint256 indexed stageId,
        uint256 amount
    );

    /**
     * @dev Emitted when tokens are bought directly.
     * @param user The address of the user who bought the tokens.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used.
     * @param price The price of the tokens.
     * @param amount The amount of tokens bought.
     */
    event TokensBought(
        address indexed user,
        uint256 indexed stageId,
        address indexed token,
        uint256 price,
        uint256 amount
    );

    /// @dev Error thrown when a disabled purchase method is attempted.
    error ThisPurchaseMethodIsDisabled();

    /// @dev Error thrown when there are insufficient funds for the purchase.
    error InsufficientFunds();

    /**
     * @dev Constructor to initialize the purchase settings.
     * @param isReleaseAllowed Indicates if the release tokens with signature method is allowed.
     * @param isBuyAllowed Indicates if the direct buy method is allowed.
     * @param isBuyWithProofAllowed Indicates if the buy with Merkle Proof is allowed.
     * @param isBuyWithPriceAllowed Indicates if the buy with signature and dinamic price method is allowed.
     */
    constructor(
        bool isReleaseAllowed,
        bool isBuyAllowed,
        bool isBuyWithProofAllowed,
        bool isBuyWithPriceAllowed
    ) {
        _setPurchaseSettings(
            isReleaseAllowed,
            isBuyAllowed,
            isBuyWithProofAllowed,
            isBuyWithPriceAllowed
        );
    }

    /**
     * @notice Returns the current purchase settings.
     * @dev This function returns the status of various purchase methods.
     * @return isReleaseAllowed Indicates if the release tokens with signature method is allowed.
     * @return isBuyAllowed Indicates if the direct buy method is allowed.
     * @return isBuyWithProofAllowed Indicates if the buy with Merkle Proof is allowed.
     * @return isBuyWithPriceAllowed Indicates if the buy with signature and dinamic price method is allowed.
     */
    function getPurchaseSettings()
        external
        view
        returns (
            bool isReleaseAllowed,
            bool isBuyAllowed,
            bool isBuyWithProofAllowed,
            bool isBuyWithPriceAllowed
        )
    {
        return (
            _purchaseSettings.isReleaseAllowed,
            _purchaseSettings.isBuyAllowed,
            _purchaseSettings.isBuyWithProofAllowed,
            _purchaseSettings.isBuyWithPriceAllowed
        );
    }

    /**
     * @notice Allows users to release tokens using a signature issued by the server.
     * @dev This function is intended for cases where payment has been received off-chain,
     * and the function only release tokens the corresponding amount of tokens.
     * @param stageId The ID of the sale stage.
     * @param tokensToBuy The amount of tokens to be released.
     * @param signature The signature issued by the server to authorize the release tokens.
     */
    function release(
        uint256 stageId,
        uint256 tokensToBuy,
        bytes memory signature
    ) external thenStageIsActive(stageId) whenNotPaused {
        address user = _msgSender();

        _checkSignatureRelease(user, stageId, tokensToBuy, signature);

        tokensToBuy = _fixTokensToBuy(stageId, tokensToBuy);
        _increaseSoldAndVested(user, stageId, tokensToBuy);
        emit TokensReleased(user, stageId, tokensToBuy);
    }

    /**
     * @notice Allows users to buy tokens with dinamic price using a signature issued by the server.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used for the purchase.
     * @param price The price of the tokens.
     * @param tokensToPay The amount of payment tokens to pay.
     * @param signature The signature issued by the server to authorize the purchase tokens.
     */
    function buyWithPrice(
        uint256 stageId,
        address token,
        uint256 price,
        uint256 tokensToPay,
        bytes memory signature
    ) external payable nonReentrant {
        address user = _msgSender();
        if (!_purchaseSettings.isBuyWithPriceAllowed) {
            revert ThisPurchaseMethodIsDisabled();
        }

        _checkSignatureBuyWithPrice(
            user,
            stageId,
            token,
            price,
            tokensToPay,
            signature
        );

        _processingWithPrice(user, stageId, token, price, tokensToPay);
    }

    /**
     * @notice Allows users to buy tokens with dinamic price using a signature issued by the server and a permit (EIP-2612).
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used for the purchase.
     * @param price The price of the tokens.
     * @param tokensToPay The amount of payment tokens to pay.
     * @param deadline The permit deadline.
     * @param v The recovery id.
     * @param r The r value of the signature.
     * @param s The s value of the signature.
     * @param signature The signature issued by the server to authorize the purchase tokens.
     */
    function buyWithPricePermit(
        uint256 stageId,
        address token,
        uint256 price,
        uint256 tokensToPay,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes memory signature
    ) external {
        address user = _msgSender();
        if (!_purchaseSettings.isBuyWithPriceAllowed) {
            revert ThisPurchaseMethodIsDisabled();
        }

        _checkSignatureBuyWithPrice(
            user,
            stageId,
            token,
            price,
            tokensToPay,
            signature
        );

        _processingWithPricePermit(
            user,
            stageId,
            token,
            price,
            tokensToPay,
            deadline,
            v,
            r,
            s
        );
    }

    /**
     * @notice Allows users to buy tokens directly with a specified payment token.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used for the purchase.
     * @param tokensToPay The amount of payment tokens to pay.
     */
    function buy(
        uint256 stageId,
        address token,
        uint256 tokensToPay
    ) external payable whenWhitelisted(stageId) nonReentrant {
        if (!_purchaseSettings.isBuyAllowed) {
            revert ThisPurchaseMethodIsDisabled();
        }
        _buyProcessing(_msgSender(), stageId, token, tokensToPay);
    }

    /**
     * @notice Allows users to buy tokens with a permit (EIP-2612).
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used for the purchase.
     * @param tokensToPay The amount of payment tokens to pay.
     * @param deadline The permit deadline.
     * @param v The recovery id.
     * @param r The r value of the signature.
     * @param s The s value of the signature.
     */
    function buyWithPermit(
        uint256 stageId,
        address token,
        uint256 tokensToPay,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external whenWhitelisted(stageId) {
        if (!_purchaseSettings.isBuyAllowed) {
            revert ThisPurchaseMethodIsDisabled();
        }

        _buyWithPermitProcessing(
            _msgSender(),
            stageId,
            token,
            tokensToPay,
            deadline,
            v,
            r,
            s
        );
    }

    /**
     * @notice Allows users to buy tokens directly with a specified payment token and Merkle proof.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used for the purchase.
     * @param tokensToPay The amount of payment tokens to pay.
     * @param merkleProof The Merkle proof for whitelisting.
     */
    function buyWithProof(
        uint256 stageId,
        address token,
        uint256 tokensToPay,
        bytes32[] calldata merkleProof
    )
        external
        payable
        whenWhitelistedByProof(stageId, merkleProof)
        nonReentrant
    {
        if (!_purchaseSettings.isBuyWithProofAllowed) {
            revert ThisPurchaseMethodIsDisabled();
        }
        _buyProcessing(_msgSender(), stageId, token, tokensToPay);
    }

    /**
     * @notice Allows users to buy tokens with a permit (EIP-2612) and Merkle proof.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used for the purchase.
     * @param tokensToPay The amount of payment tokens to pay.
     * @param deadline The permit deadline.
     * @param v The recovery id.
     * @param r The r value of the signature.
     * @param s The s value of the signature.
     * @param merkleProof The Merkle proof for whitelisting.
     */
    function buyWithProofPermit(
        uint256 stageId,
        address token,
        uint256 tokensToPay,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32[] calldata merkleProof
    ) external whenWhitelistedByProof(stageId, merkleProof) {
        if (!_purchaseSettings.isBuyWithProofAllowed) {
            revert ThisPurchaseMethodIsDisabled();
        }

        _buyWithPermitProcessing(
            _msgSender(),
            stageId,
            token,
            tokensToPay,
            deadline,
            v,
            r,
            s
        );
    }

    /**
     * @notice Updates the purchase settings.
     * @dev Can only be called by the contract owner.
     * Emits a PurchaseSettingsUpdated event.
     * @param isReleaseAllowed Indicates if the release tokens with signature method is allowed.
     * @param isBuyAllowed Indicates if the direct buy method is allowed.
     * @param isBuyWithProofAllowed Indicates if the buy with Merkle Proof is allowed.
     * @param isBuyWithPriceAllowed Indicates if the buy with signature and dinamic price method is allowed.
     */
    function setPurchaseSettings(
        bool isReleaseAllowed,
        bool isBuyAllowed,
        bool isBuyWithProofAllowed,
        bool isBuyWithPriceAllowed
    ) external onlyOwner {
        _setPurchaseSettings(
            isReleaseAllowed,
            isBuyAllowed,
            isBuyWithProofAllowed,
            isBuyWithPriceAllowed
        );
    }

    /**
     * @dev Private function to set the purchase settings.
     * Emits a PurchaseSettingsUpdated event.
     * @param isReleaseAllowed Indicates if the release tokens with signature method is allowed.
     * @param isBuyAllowed Indicates if the direct buy method is allowed.
     * @param isBuyWithProofAllowed Indicates if the buy with Merkle Proof is allowed.
     * @param isBuyWithPriceAllowed Indicates if the buy with signature and dinamic price method is allowed.
     */
    function _setPurchaseSettings(
        bool isReleaseAllowed,
        bool isBuyAllowed,
        bool isBuyWithProofAllowed,
        bool isBuyWithPriceAllowed
    ) private {
        _purchaseSettings.isReleaseAllowed = isReleaseAllowed;
        _purchaseSettings.isBuyAllowed = isBuyAllowed;
        _purchaseSettings.isBuyWithProofAllowed = isBuyWithProofAllowed;
        _purchaseSettings.isBuyWithPriceAllowed = isBuyWithPriceAllowed;
        emit PurchaseSettingsUpdated(
            isReleaseAllowed,
            isBuyAllowed,
            isBuyWithProofAllowed,
            isBuyWithPriceAllowed
        );
    }

    /**
     * @dev Private function to process a purchase with a specified price using permit for token approval.
     * @param user The address of the user making the purchase.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used for the purchase.
     * @param price The price of the tokens.
     * @param tokensToPay The amount of payment tokens to pay.
     * @param deadline The deadline for the permit signature.
     * @param v The v component of the permit signature.
     * @param r The r component of the permit signature.
     * @param s The s component of the permit signature.
     */
    function _processingWithPricePermit(
        address user,
        uint256 stageId,
        address token,
        uint256 price,
        uint256 tokensToPay,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private {
        IERC20Permit(token).safePermit(
            user,
            address(this),
            tokensToPay,
            deadline,
            v,
            r,
            s
        );

        _processingWithPrice(user, stageId, token, price, tokensToPay);
    }

    /**
     * @dev Private function to process a purchase with a specified price.
     * @param user The address of the user making the purchase.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used for the purchase.
     * @param price The price of the tokens.
     * @param tokensToPay The amount of payment tokens to pay.
     */
    function _processingWithPrice(
        address user,
        uint256 stageId,
        address token,
        uint256 price,
        uint256 tokensToPay
    ) private onlyPaymentToken(token) thenStageIsActive(stageId) whenNotPaused {
        (uint256 tokensToBuy, uint256 tokensToPay_) = _calculateWithPrice(
            stageId,
            price,
            tokensToPay
        );
        _raiseFunds(user, token, tokensToPay_);
        _increaseRaisedAndSoldAndVested(
            user,
            stageId,
            token,
            tokensToBuy,
            tokensToPay_,
            price
        );
    }

    /**
     * @dev Private function to process the purchase with direct buy method.
     * @param user The address of the user making the purchase.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used for the purchase.
     * @param tokensToPay The amount of payment tokens to pay.
     */
    function _buyProcessing(
        address user,
        uint256 stageId,
        address token,
        uint256 tokensToPay
    ) private {
        _processing(user, stageId, token, tokensToPay);
    }

    /**
     * @dev Private function to process the purchase with permit method.
     * @param user The address of the user making the purchase.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used for the purchase.
     * @param tokensToPay The amount of payment tokens to pay.
     * @param deadline The permit deadline.
     * @param v The recovery id.
     * @param r The r value of the signature.
     * @param s The s value of the signature.
     */
    function _buyWithPermitProcessing(
        address user,
        uint256 stageId,
        address token,
        uint256 tokensToPay,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private {
        IERC20Permit(token).safePermit(
            user,
            address(this),
            tokensToPay,
            deadline,
            v,
            r,
            s
        );

        _processing(user, stageId, token, tokensToPay);
    }

    /**
     * @dev Private function to handle the process of buying tokens.
     * @param user The address of the user.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used.
     * @param tokensToPay The amount of payment tokens to pay.
     */
    function _processing(
        address user,
        uint256 stageId,
        address token,
        uint256 tokensToPay
    ) private onlyPaymentToken(token) thenStageIsActive(stageId) whenNotPaused {
        (uint256 tokensToBuy, uint256 tokensToPay_, uint256 price) = _calculate(
            stageId,
            token,
            tokensToPay
        );
        _raiseFunds(user, token, tokensToPay_);
        _increaseRaisedAndSoldAndVested(
            user,
            stageId,
            token,
            tokensToBuy,
            tokensToPay_,
            price
        );
    }

    /**
     * @dev Private function to calculate the number of tokens to buy and the amount to pay.
     * @param stageId The ID of the sale stage.
     * @param price The price of the tokens.
     * @param tokensToPay_ The amount of payment tokens to pay.
     * @return tokensToBuy The number of tokens to buy.
     * @return tokensToPay The adjusted amount of payment tokens to pay.
     */
    function _calculateWithPrice(
        uint256 stageId,
        uint256 price,
        uint256 tokensToPay_
    ) private view returns (uint256 tokensToBuy, uint256 tokensToPay) {
        tokensToPay = tokensToPay_;
        tokensToBuy = _calculateTokensToBuyWithPrice(price, tokensToPay);

        uint256 reserve = _getStageReserve(stageId);
        if (tokensToBuy > reserve) {
            tokensToBuy = reserve;
            tokensToPay = _calculateTokensToPayWithPrice(price, tokensToBuy);
        }
    }

    /**
     * @dev Private function to calculate the number of tokens to buy and the amount to pay.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used.
     * @param tokensToPay_ The amount of payment tokens to pay.
     * @return tokensToBuy The number of tokens to buy.
     * @return tokensToPay The adjusted amount of payment tokens to pay.
     * @return price The price of the token.
     */
    function _calculate(
        uint256 stageId,
        address token,
        uint256 tokensToPay_
    )
        private
        view
        returns (uint256 tokensToBuy, uint256 tokensToPay, uint256 price)
    {
        tokensToPay = tokensToPay_;
        (tokensToBuy, price) = _calculateTokensToBuyAtStage(
            stageId,
            token,
            tokensToPay
        );

        uint256 reserve = _getStageReserve(stageId);
        if (tokensToBuy > reserve) {
            tokensToBuy = reserve;
            (tokensToPay, ) = _calculateTokensToPayAtStage(
                stageId,
                token,
                tokensToBuy
            );
        }
    }

    /**
     * @dev Private function to handle the raising of funds.
     * @param user The address of the user.
     * @param token The address of the payment token used.
     * @param tokensToPay The amount of payment tokens to pay.
     */
    function _raiseFunds(
        address user,
        address token,
        uint256 tokensToPay
    ) private {
        uint256 restToPay = tokensToPay;
        uint256 deposit = _getUserTokenDeposit(user, token);
        if (deposit > 0) {
            uint256 toDepositReduce;
            if (deposit >= tokensToPay) {
                restToPay = 0;
                toDepositReduce = tokensToPay;
            } else {
                restToPay = tokensToPay - deposit;
                toDepositReduce = deposit;
            }
            _reduceDeposit(user, token, toDepositReduce);
        }

        if (restToPay > 0) {
            if (token == address(0)) {
                // Take the restToPay of ETH from msg.value, return the rest to the user.
                if (msg.value < restToPay) {
                    revert InsufficientFunds();
                } else if (msg.value > restToPay) {
                    payable(user).sendValue(msg.value - restToPay);
                }
            } else {
                // Take the restToPay of ERC20 tokens from the user’s balance.
                IERC20 _token = IERC20(token);
                uint256 before = _token.balanceOf(address(this));
                _token.safeTransferFrom(user, address(this), restToPay);

                uint256 delta = _token.balanceOf(address(this)) - before;
                // Check and prohibition of tax tokens.
                if (delta != restToPay) {
                    revert InvalidTokenAmount();
                }
            }
        }
    }

    /**
     * @dev Private function to increase raised funds, sold tokens, and vesting for a user.
     * @param user The address of the user.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token used.
     * @param tokensToBuy The amount of tokens to buy.
     * @param tokensToPay The amount of payment tokens to pay.
     * @param price The price of the token.
     */
    function _increaseRaisedAndSoldAndVested(
        address user,
        uint256 stageId,
        address token,
        uint256 tokensToBuy,
        uint256 tokensToPay,
        uint256 price
    ) private {
        _increaseRaisedFunds(token, tokensToPay);
        _increaseSoldAndVested(user, stageId, tokensToBuy);
        emit TokensBought(user, stageId, token, price, tokensToBuy);
    }

    /**
     * @dev Private function to increase the sold tokens and vesting for a user.
     * @param user The address of the user.
     * @param stageId The ID of the sale stage.
     * @param tokensToBuy The amount of tokens to buy.
     */
    function _increaseSoldAndVested(
        address user,
        uint256 stageId,
        uint256 tokensToBuy
    ) private {
        _increaseStageSold(stageId, tokensToBuy);
        ITokenVesting(_getTokenVesting()).onTokensPurchase(
            user,
            stageId,
            tokensToBuy
        );
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

import "./SellableToken.sol";
import "./PaymentToken.sol";
import "./PaymentTokenDeposit.sol";
import "./Whitelist.sol";

/**
 * @title TokenSaleStages
 * @dev Abstract contract for managing stages of a token sale.
 * Inherits functionalities from Ownable2Step, SellableToken, PaymentToken, PaymentTokenDeposit, and Whitelist contracts.
 */
abstract contract TokenSaleStages is
    Ownable2Step,
    SellableToken,
    PaymentToken,
    PaymentTokenDeposit,
    Whitelist
{
    /**
     * @dev Struct to provide a view of the sale stage data.
     * @param whitelist Indicates if whitelist is enabled for this sale stage.
     * @param startAt The start time of the token sale stage. If set to 0, it means the stage will start automatically after the previous stage ends.
     * @param duration The duration of the token sale stage in seconds.
     * @param cap The maximum number of tokens that can be sold in this stage.
     * @param sold The total number of tokens sold in this stage.
     * @param tokens An array of token addresses available for sale in this stage.
     * @param prices An array of prices corresponding to the token addresses available for sale in this stage.
     */
    struct SaleStageDataView {
        bool whitelist; // If true, only addresses on the whitelist can participate in the token sale.
        uint256 startAt; // Token sale start time (0 means auto start  after the previous stage).
        uint256 duration; // Duration of the token sale stage.
        uint256 cap; // Maximum amount of tokens to be sold in this stage.
        uint256 sold; // Total tokens sold in this stage.
        address[] tokens; // Array of token addresses available for sale.
        uint256[] prices; // Array of prices corresponding to the token addresses.
    }

    /**
     * @dev Struct to store the schedule of a sale stage.
     * @param stageId The ID of the sale stage.
     * @param whitelist Indicates if whitelist is enabled for this sale stage.
     * @param startAt The start time of the token sale stage.
     * @param duration The duration of the token sale stage in seconds.
     * @param cap The maximum number of tokens that can be sold in this stage.
     * @param tokens An array of token addresses available for sale in this stage.
     * @param prices An array of prices corresponding to the token addresses available for sale in this stage.
     */
    struct SaleStageSchedule {
        uint256 stageId; // ID of the sale stage.
        bool whitelist; // If true, only addresses on the whitelist can participate in the token sale.
        uint256 startAt; // Token sale start time.
        uint256 duration; // Duration of the token sale stage in seconds.
        uint256 cap; // Maximum amount of tokens to be sold in this stage.
        address[] tokens; // Array of token addresses available for sale.
        uint256[] prices; // Array of prices corresponding to the token addresses.
    }

    /**
     * @dev Struct to store data for each token sale stage.
     * @param whitelist Indicates if whitelist is enabled for this sale stage.
     * @param startAt The start time of the token sale stage. If set to 0, it means the stage will start automatically after the previous stage ends.
     * @param duration The duration of the token sale stage in seconds.
     * @param cap The maximum number of tokens that can be sold in this stage.
     * @param sold The total number of tokens sold in this stage.
     */
    struct SaleStageData {
        bool whitelist; // If true, only addresses on the whitelist can participate in the token sale.
        uint256 startAt; // Token sale start time (0 means auto start  after the previous stage).
        uint256 duration; // Duration of the token sale stage.
        uint256 cap; // Maximum amount of tokens to be sold in this stage.
        uint256 sold; // Total tokens sold in this stage.
    }

    /**
     * @dev Mapping to store sale stage data for each stage ID.
     * param stageId The ID of the sale stage.
     * return The SaleStageData struct containing the details of the sale stage.
     */
    mapping(uint256 stageId => SaleStageData) private _stageSale;

    /**
     * @dev Mapping to store token prices for each sale stage.
     * param stageId The ID of the sale stage.
     * param token The address of the token.
     * return The price of the token in the specified sale stage.
     */
    mapping(uint256 stageId => mapping(address token => uint256))
        private _stagePrice;

    /// @dev The total number of stages.
    uint256 private _totalStages;

    /// @dev The total number of tokens sold across all stages.
    uint256 private _totalSold;

    /**
     * @dev The ID of the current sale stage.
     * WARNING: may point to a non-existent stage ID if the stages have not been set up correctly.
     */
    uint256 private _currentStageId;

    /**
     * @dev Emitted when a stage is updated.
     * @param stageId The ID of the updated stage.
     * @param whitelist Indicates if whitelist is enabled for this sale stage.
     * @param startAt The start time of the stage.
     * @param duration The duration of the stage.
     * @param cap The maximum amount of tokens to be sold in the stage.
     */
    event SaleStageUpdated(
        uint256 stageId,
        bool whitelist,
        uint256 startAt,
        uint256 duration,
        uint256 cap
    );

    /**
     * @dev Emitted when a stage is deleted.
     * @param stageId The ID of the deleted stage.
     */
    event SaleStageDeleted(uint256 stageId);

    /**
     * @dev Emitted when the price of a token is updated for a stage.
     * @param stageId The ID of the stage.
     * @param token The address of the token.
     * @param price The new price of the token.
     */
    event SaleStagePriceUpdated(uint256 stageId, address token, uint256 price);

    /**
     * @dev Emitted when the current stage ID is updated.
     * @param currentStageId The new current stage ID.
     */
    event CurrentStageIdUpdated(uint256 currentStageId);

    /// @dev Error indicating that the specified stage does not exist.
    error StageNotExists();

    /// @dev Error thrown when a stage is not active.
    error StageIsNotActive();

    /// @dev Error indicating that the provided stage ID is incorrect.
    error WrongStageId();

    /// @dev Error indicating that the stage has already been used.
    error StageAlreadyUsed();

    /// @dev Error indicating that there is a mismatch between the provided parameters.
    error ParametersMismatch();

    /// @dev Error indicating that the price of the payment token is zero.
    error PaymentTokenPriceIsZero();

    /// @dev Error indicating that the cap of the stage cannot be less than the amount of tokens sold.
    error CapCannotBeLessThanSold();

    /// @dev Error thrown when the start time of a stage is invalid.
    error WrongStartTime();

    /// @dev Error indicating that the purchase amount is too small.
    error TooSmallPurchaseAmount();

    /**
     * @dev Modifier to check if the stage exists.
     * Reverts with StageNotExists error if the stage ID does not exist.
     * @param stageId The ID of the stage to check.
     */
    modifier stageExists(uint256 stageId) {
        if (_isStageNotExists(stageId)) {
            revert StageNotExists();
        }
        _;
    }

    /**
     * @dev Modifier to check if a stage is currently active.
     * Reverts with `StageIsNotActive` if the stage ID does not match the current stage ID,
     * if the stage is sold out, if the stage has not started, or if the current time is not within the stage duration.
     * @param stageId The ID of the stage to check.
     */
    modifier thenStageIsActive(uint256 stageId) {
        _fixExpiredStage();

        if (stageId != _getCurrentStageIdRaw()) {
            revert StageIsNotActive();
        }

        SaleStageData memory stage = _getSaleStage(stageId);
        if (stage.sold >= stage.cap) {
            revert StageIsNotActive();
        }

        if (stage.startAt == 0) {
            revert StageIsNotActive();
        }

        if (
            block.timestamp < stage.startAt ||
            block.timestamp >= (stage.startAt + stage.duration)
        ) {
            revert StageIsNotActive();
        }

        _;
    }

    /// @dev Modifier to check if the user is whitelisted for the current stage.
    /// @param stageId The ID of the sale stage to check.
    modifier whenWhitelisted(uint256 stageId) {
        SaleStageData memory stage = _getSaleStage(stageId);
        if (stage.whitelist && !_isWhitelisted(_msgSender())) {
            revert NotWhitelisted();
        }
        _;
    }

    /// @dev Modifier to check if the user is whitelisted for the current stage using Merkle proof.
    /// @param stageId The ID of the sale stage to check.
    /// @param merkleProof The Merkle proof to verify the user's whitelist status.
    modifier whenWhitelistedByProof(
        uint256 stageId,
        bytes32[] calldata merkleProof
    ) {
        address user = _msgSender();
        SaleStageData memory stage = _getSaleStage(stageId);
        if (stage.whitelist) {
            _checkWhitelistProof(user, merkleProof);
            if (!_isWhitelisted(user)) {
                _grantWhitelist(user);
            }
        }
        _;
    }

    /**
     * @notice Returns the current state of the sale.
     * @return stages The total number of stages.
     * @return currentStageId The ID of the current stage. WARNING: may point to a non-existent stage ID if the stages have not been set up correctly.
     * @return sold The total number of tokens sold across all stages.
     */
    function getSaleState()
        external
        view
        returns (uint256 stages, uint256 currentStageId, uint256 sold)
    {
        stages = _getTotalStages();
        currentStageId = _getCurrentStageId();
        sold = _totalSold;
    }

    /**
     * @notice Returns the details of a specific sale stage.
     * @dev This function returns the start time, duration, cap, sold amount, and token prices for the specified sale stage.
     * It defaults to the predefined payment tokens.
     * @param stageId The ID of the sale stage to retrieve.
     * @return whitelist Indicates if whitelist is enabled for this sale stage.
     * @return startAt The start time of the sale stage.
     * @return duration The duration of the sale stage.
     * @return cap The maximum amount of tokens to be sold in the sale stage.
     * @return sold The total amount of tokens sold in the sale stage.
     * @return tokens The list of token addresses used in the sale stage.
     * @return prices The list of prices for each token in the sale stage.
     */
    function getSaleStage(
        uint256 stageId
    )
        external
        view
        stageExists(stageId)
        returns (
            bool whitelist,
            uint256 startAt,
            uint256 duration,
            uint256 cap,
            uint256 sold,
            address[] memory tokens,
            uint256[] memory prices
        )
    {
        SaleStageData memory stage = _getSaleStage(stageId);

        whitelist = stage.whitelist;
        startAt = stage.startAt;
        duration = stage.duration;
        cap = stage.cap;
        sold = stage.sold;

        tokens = _getDefaultPaymentTokensIfEmpty(tokens);
        prices = new uint256[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            prices[i] = _getTokenPrice(stageId, tokens[i]);
        }
    }

    /**
     * @notice Returns the data for all sale stages.
     * @dev This function creates an array of SaleStageDataView structs representing all sale stages
     * and populates it with data from the _stageSale mapping.
     * @return stages An array of SaleStageDataView structs containing the data for all sale stages.
     */
    function getSaleStages()
        external
        view
        returns (SaleStageDataView[] memory stages)
    {
        uint256 totalStages = _getTotalStages();
        stages = new SaleStageDataView[](totalStages);
        address[] memory tokens = _getPaymentTokens();

        for (uint256 stageId = 0; stageId < totalStages; stageId++) {
            SaleStageData memory stage = _getSaleStage(stageId);

            uint256[] memory prices = new uint256[](tokens.length);
            for (uint256 i = 0; i < tokens.length; i++) {
                prices[i] = _getTokenPrice(stageId, tokens[i]);
            }

            stages[stageId] = SaleStageDataView({
                whitelist: stage.whitelist,
                startAt: stage.startAt,
                duration: stage.duration,
                cap: stage.cap,
                sold: stage.sold,
                tokens: tokens,
                prices: prices
            });
        }
    }

    /**
     * @notice Calculates the number of tokens to be bought given a payment amount and token price.
     * @param price The price of the token in the specified payment token.
     * @param tokensToPay The amount of the payment token being used to buy tokens.
     * @return tokensToBuy The number of tokens to be bought.
     */
    function calculateTokensToBuy(
        uint256 price,
        uint256 tokensToPay
    ) external view returns (uint256 tokensToBuy) {
        return _calculateTokensToBuyWithPrice(price, tokensToPay);
    }

    /**
     * @notice Calculates the amount of payment tokens needed to buy a specific number of tokens.
     * @param price The price of the token in the specified payment token.
     * @param tokensToBuy The number of tokens to buy.
     * @return tokensToPay The amount of payment tokens needed.
     */
    function calculateTokensToPay(
        uint256 price,
        uint256 tokensToBuy
    ) external view returns (uint256 tokensToPay) {
        return _calculateTokensToPayWithPrice(price, tokensToBuy);
    }

    /**
     * @notice Calculates the number of tokens to be bought given a payment amount and token price for a specified stage.
     * @dev This function is external and can be called with a valid payment token.
     * It calls the internal function to perform the calculation.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token.
     * @param tokensToPay The amount of the payment token being used to buy tokens.
     * @return tokensToBuy The number of tokens to be bought.
     * @return price The price of the token in the specified payment token.
     */
    function calculateTokensToBuyAtStage(
        uint256 stageId,
        address token,
        uint256 tokensToPay
    )
        external
        view
        onlyPaymentToken(token)
        returns (uint256 tokensToBuy, uint256 price)
    {
        return _calculateTokensToBuyAtStage(stageId, token, tokensToPay);
    }

    /**
     * @notice Calculates the amount of payment tokens needed to buy a specific number of tokens for a specified stage.
     * @dev This function is external and can be called with a valid payment token.
     * It calls the internal function to perform the calculation.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token.
     * @param tokensToBuy The number of tokens to buy.
     * @return tokensToPay The amount of payment tokens needed.
     * @return price The price of the token in the specified payment token.
     */
    function calculateTokensToPayAtStage(
        uint256 stageId,
        address token,
        uint256 tokensToBuy
    )
        external
        view
        onlyPaymentToken(token)
        returns (uint256 tokensToPay, uint256 price)
    {
        return _calculateTokensToPayAtStage(stageId, token, tokensToBuy);
    }

    /**
     * @notice Creates a new stage with the specified parameters and sets its prices.
     * @dev Can only be called by the contract owner.
     * The stage ID must be equal to the current total stages.
     * @param stageId The ID of the new stage.
     * @param whitelist Indicates if whitelist is enabled for this sale stage.
     * @param startAt The start timestamp of the stage.
     * @param duration The duration of the stage.
     * @param cap The token cap for the stage.
     * @param tokens An array of token addresses for which prices are being set.
     * @param prices An array of prices corresponding to the tokens.
     */
    function createNextSaleStage(
        uint256 stageId,
        bool whitelist,
        uint256 startAt,
        uint256 duration,
        uint256 cap,
        address[] calldata tokens,
        uint256[] calldata prices
    ) external onlyOwner {
        if (stageId != _getTotalStages()) {
            revert WrongStageId();
        }

        _totalStages++;
        _updateSaleStage(stageId, whitelist, startAt, duration, cap);
        _updateSaleStagePrices(stageId, tokens, prices);
    }

    /**
     * @notice Creates new sale stages with the specified parameters.
     * @dev Can only be called by the contract owner.
     * The stage ID must be equal to the current total stages.
     * @param schedules An array of SaleStageSchedule structs containing the parameters for each sale stage.
     */
    function createNextSaleStagesBatch(
        SaleStageSchedule[] calldata schedules
    ) external onlyOwner {
        uint256 total = schedules.length;
        for (uint256 i = 0; i < total; total++) {
            uint256 stageId = schedules[i].stageId;
            if (stageId != _getTotalStages()) {
                revert WrongStageId();
            }

            _totalStages++;
            _updateSaleStage(
                schedules[i].stageId,
                schedules[i].whitelist,
                schedules[i].startAt,
                schedules[i].duration,
                schedules[i].cap
            );
            _updateSaleStagePrices(
                schedules[i].stageId,
                schedules[i].tokens,
                schedules[i].prices
            );
        }
    }

    /**
     * @notice Updates the parameters and prices of an existing stage.
     * @dev Can only be called by the contract owner.
     * The stage must exist.
     * @param stageId The ID of the stage to update.
     * @param whitelist Indicates if whitelist is enabled for this sale stage.
     * @param startAt The new start timestamp of the stage.
     * @param duration The new duration of the stage.
     * @param cap The new token cap for the stage.
     * @param tokens An array of token addresses for which prices are being set.
     * @param prices An array of prices corresponding to the tokens.
     */
    function updateSaleStage(
        uint256 stageId,
        bool whitelist,
        uint256 startAt,
        uint256 duration,
        uint256 cap,
        address[] memory tokens,
        uint256[] memory prices
    ) external stageExists(stageId) onlyOwner {
        _updateSaleStage(stageId, whitelist, startAt, duration, cap);
        _updateSaleStagePrices(stageId, tokens, prices);
    }

    /**
     * @notice Updates the prices for the specified stage and payment tokens.
     * @dev Can only be called by the contract owner and for an existing stage.
     * @param stageId The ID of the stage to update prices for.
     * @param tokens An array of token addresses for which prices are being set.
     * @param prices An array of prices corresponding to the tokens.
     */
    function updateSaleStagePrices(
        uint256 stageId,
        address[] memory tokens,
        uint256[] memory prices
    ) external stageExists(stageId) onlyOwner {
        _updateSaleStagePrices(stageId, tokens, prices);
    }

    /**
     * @notice Deletes the prices for the specified stage and payment tokens.
     * @dev Can only be called by the contract owner and for an existing stage.
     * If the input array of tokens is empty, it defaults to the predefined payment tokens.
     * @param stageId The ID of the stage to delete prices for.
     * @param tokens An array of token addresses for which prices are being deleted (use zero address for native coin).
     */
    function deleteSaleStagePrices(
        uint256 stageId,
        address[] memory tokens
    ) external stageExists(stageId) onlyOwner {
        _deleteSaleStagePrices(stageId, tokens);
    }

    /**
     * @notice Deletes the last stage.
     * @dev Can only be called by the contract owner.
     * It defaults to the predefined payment tokens.
     * WARNING: The stage must exist and must not have any tokens sold in it.
     */
    function deleteLastSaleStage() external onlyOwner {
        uint256 totalStages = _getTotalStages();
        if (totalStages == 0) {
            revert StageNotExists();
        }

        uint256 stageId = totalStages - 1;
        SaleStageData memory stage = _getSaleStage(stageId);
        if (stage.sold > 0 || stageId < _getCurrentStageIdRaw()) {
            revert StageAlreadyUsed();
        }

        _totalStages--;
        delete _stageSale[stageId];
        emit SaleStageDeleted(stageId);

        _deleteSaleStagePrices(stageId, new address[](0));
    }

    /**
     * @notice Sets the current stage ID.
     * @dev Can only be called by the contract owner.
     * Reverts if the new stage ID is not greater than the current stage ID.
     * Emits a CurrentStageIdUpdated event.
     * @param newCurrentStageId The new stage ID to set.
     */
    function setCurrentStageId(uint256 newCurrentStageId) external onlyOwner {
        if (
            newCurrentStageId < _getCurrentStageId() ||
            newCurrentStageId > _getTotalStages()
        ) {
            revert WrongStageId();
        }
        _setCurrentStageId(newCurrentStageId);
    }

    /**
     * @dev Private function to handle deposits of tokens or native coin.
     * Emits a UserFundsDeposited event upon successful deposit.
     * @param user The address of the user making the deposit.
     * @param token The address of the token being deposited.
     * @param amount The amount of the token being deposited.
     */
    function _deposit(
        address user,
        address token,
        uint256 amount
    ) internal override {
        super._deposit(user, token, amount);

        // If before sale starts, grant whitelist access.
        if (
            !_isSaleStarted() &&
            _isWhitelistingByDepositEnabled() &&
            !_isWhitelisted(user)
        ) {
            _grantWhitelist(user);
        }
    }

    /**
     * @dev Private function to handle the cancellation of deposits.
     * Emits a UserFundsWithdrawn event upon successful withdrawal.
     * @param user The address of the user whose deposits are being canceled.
     * @param tokens The list of token addresses to withdraw.
     */
    function _cancelDeposit(
        address user,
        address[] memory tokens
    ) internal override {
        super._cancelDeposit(user, tokens);

        // If before sale starts, revoke whitelist access.
        if (
            !_isSaleStarted() &&
            _isWhitelistingByDepositEnabled() &&
            _isWhitelisted(user)
        ) {
            _revokeWhitelist(user);
        }
    }

    /**
     * @dev Internal function to get the total number of token sale stages.
     * @return The total number of token sale stages.
     */
    function _getTotalStages() internal view virtual returns (uint256) {
        return _totalStages;
    }

    /**
     * @dev Private function to get the current sale stage ID.
     * WARNING: The returned stage ID may point to a non-existent stage if the stages have not been set up correctly.
     * @return The current sale stage ID.
     */
    function _getCurrentStageIdRaw() private view returns (uint256) {
        return _currentStageId;
    }

    /**
     * @dev Private function to get the current active sale stage ID.
     * Calculates the current stage based on the total number of stages, the raw current stage ID,
     * and the start time and duration of the current stage.
     * @return The ID of the current active sale stage.
     */
    function _getCurrentStageId() private view returns (uint256) {
        uint256 currentStageIdRaw = _getCurrentStageIdRaw();
        uint256 totalStages = _getTotalStages();
        if (totalStages == 0) {
            return 0;
        }

        if (currentStageIdRaw >= totalStages) {
            return totalStages;
        }

        SaleStageData memory stage = _getSaleStage(currentStageIdRaw);
        if (stage.startAt == 0) {
            return currentStageIdRaw;
        }

        if (block.timestamp >= (stage.startAt + stage.duration)) {
            return currentStageIdRaw + 1;
        }

        if (stage.sold >= stage.cap) {
            return currentStageIdRaw + 1;
        }

        return currentStageIdRaw;
    }

    /**
     * @dev Private function to fix the expired stage and update the current stage ID if necessary.
     * If the current stage ID is different from the raw current stage ID, it updates the current stage ID
     * and sets the start time for the new current stage.
     */
    function _fixExpiredStage() private {
        uint256 curIdRaw = _getCurrentStageIdRaw();
        uint256 curId = _getCurrentStageId();
        if (curId > curIdRaw) {
            _setCurrentStageId(curId);

            SaleStageData storage curStage = _getSaleStageStorage(curId);
            if (curStage.startAt == 0) {
                SaleStageData memory prevStage = _getSaleStage(curId - 1);
                if (prevStage.sold >= prevStage.cap) {
                    curStage.startAt = block.timestamp;
                    _emitSaleStageUpdated(curId, curStage);
                } else if (prevStage.startAt != 0) {
                    curStage.startAt = prevStage.startAt + prevStage.duration;
                    _emitSaleStageUpdated(curId, curStage);
                }
            }
        }
    }

    /**
     * @dev Private function to set the current stage ID.
     * Updates the current stage ID.
     * Emits a CurrentStageIdUpdated event.
     * @param newCurrentStageId The new current stage ID.
     */
    function _setCurrentStageId(uint256 newCurrentStageId) private {
        _currentStageId = newCurrentStageId;
        emit CurrentStageIdUpdated(newCurrentStageId);
    }

    /**
     * @dev Private function to check if the token sale has started.
     * This function checks if there are any stages defined and if the start time of the first stage has been reached.
     * @return True if the sale has started, false otherwise.
     */
    function _isSaleStarted() private view returns (bool) {
        if (_getTotalStages() > 0) {
            SaleStageData memory stage = _getSaleStage(0);
            if (stage.startAt > 0 && block.timestamp >= stage.startAt) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Internal function to get the remaining token reserve for a specific stage.
     * This function calculates the difference between the stage's cap and the number of tokens sold.
     * @param stageId The ID of the stage to query.
     * @return The number of tokens remaining in the reserve for the specified stage.
     */
    function _getStageReserve(uint256 stageId) internal view returns (uint256) {
        SaleStageData memory stage = _getSaleStage(stageId);
        return stage.cap - stage.sold;
    }

    /**
     * @dev Internal function to adjust the number of tokens to be bought based on the remaining tokens available for sale in the specified stage.
     * If the requested number of tokens exceeds the remaining tokens, it reduces the amount to the available tokens.
     * @param stageId The ID of the sale stage.
     * @param tokensToBuy The number of tokens the user wants to buy.
     * @return The adjusted number of tokens to buy.
     */
    function _fixTokensToBuy(
        uint256 stageId,
        uint256 tokensToBuy
    ) internal view returns (uint256) {
        uint256 restTokensForSale = _getStageReserve(stageId);
        if (tokensToBuy > restTokensForSale) {
            // Fix for the case when there are fewer tokens left than they want to buy.
            tokensToBuy = restTokensForSale;
        }
        return tokensToBuy;
    }

    /**
     * @dev Internal function to increase the number of tokens sold in a specific sale stage.
     * Updates the total tokens sold and the tokens sold in the stage.
     * Emits a CurrentStageIdUpdated event if the stage is sold out.
     * Switches to the next stage if the current stage is completed, and updates its start time if not set.
     * @param stageId The ID of the stage.
     * @param tokensToBuy The number of tokens to be added to the sold amount.
     */
    function _increaseStageSold(uint256 stageId, uint256 tokensToBuy) internal {
        SaleStageData storage stage = _getSaleStageStorage(stageId);

        _totalSold += tokensToBuy;
        stage.sold += tokensToBuy;

        if (stage.sold >= stage.cap) {
            // Switch to the next stage.
            uint256 nextStageId = _currentStageId + 1;
            _setCurrentStageId(nextStageId);

            SaleStageData storage nextStage = _getSaleStageStorage(nextStageId);
            if (nextStage.startAt == 0) {
                nextStage.startAt = block.timestamp;
                _emitSaleStageUpdated(nextStageId, nextStage);
            }
        }
    }

    /**
     * @dev Internal function to calculate the number of tokens to be bought given a payment amount and token price for a specified stage.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token.
     * @param tokensToPay The amount of the payment token being used to buy tokens.
     * @return tokensToBuy The number of tokens to be bought.
     * @return price The price of the token in the specified payment token.
     */
    function _calculateTokensToBuyAtStage(
        uint256 stageId,
        address token,
        uint256 tokensToPay
    ) internal view returns (uint256 tokensToBuy, uint256 price) {
        price = _getTokenPrice(stageId, token);
        tokensToBuy = _calculateTokensToBuyWithPrice(price, tokensToPay);
    }

    /**
     * @dev Internal function to calculate the amount of payment tokens needed to buy a specific number of tokens for a specified stage.
     * @param stageId The ID of the sale stage.
     * @param token The address of the payment token.
     * @param tokensToBuy The number of tokens to buy.
     * @return tokensToPay The amount of payment tokens needed.
     * @return price The price of the token in the specified payment token.
     */
    function _calculateTokensToPayAtStage(
        uint256 stageId,
        address token,
        uint256 tokensToBuy
    ) internal view returns (uint256 tokensToPay, uint256 price) {
        price = _getTokenPrice(stageId, token);
        tokensToPay = _calculateTokensToPayWithPrice(price, tokensToBuy);
    }

    /**
     * @dev Internal function to calculate the number of tokens to be bought given a payment amount and token price.
     * @param price The price of the token in the specified payment token.
     * @param tokensToPay The amount of the payment token being used to buy tokens.
     * @return tokensToBuy The number of tokens to be bought.
     */
    function _calculateTokensToBuyWithPrice(
        uint256 price,
        uint256 tokensToPay
    ) internal view returns (uint256 tokensToBuy) {
        _checkTokenPrice(price);

        tokensToBuy = _calculateTokensToBuyPure(
            tokensToPay,
            price,
            _getSellableTokenDecimals()
        );
        _checkPurchaseAmount(tokensToBuy);
    }

    /**
     * @dev Internal function to calculate the amount of payment tokens needed to buy a specific number of tokens.
     * @param price The price of the token in the specified payment token.
     * @param tokensToBuy The number of tokens to buy.
     * @return tokensToPay The amount of payment tokens needed.
     */
    function _calculateTokensToPayWithPrice(
        uint256 price,
        uint256 tokensToBuy
    ) internal view returns (uint256 tokensToPay) {
        _checkTokenPrice(price);

        tokensToPay = _calculateTokensToPayPure(
            tokensToBuy,
            price,
            _getSellableTokenDecimals()
        );
        _checkPurchaseAmount(tokensToPay);
    }

    /**
     * @dev Calculates the number of tokens to buy based on the amount of payment tokens provided, the price, and the number of decimals.
     * @param tokensToPay The amount of payment tokens provided.
     * @param price The price of the payment token.
     * @param decimals The number of decimals of the token being sold.
     * @return tokensToBuy The number of tokens to buy.
     */
    function _calculateTokensToBuyPure(
        uint256 tokensToPay,
        uint256 price,
        uint8 decimals
    ) private pure returns (uint256 tokensToBuy) {
        tokensToBuy = (tokensToPay * 10 ** decimals) / price;
    }

    /**
     * @dev Calculates the amount of payment tokens needed to buy a specific number of tokens, based on the price and number of decimals.
     * @param tokensToBuy The number of tokens to buy.
     * @param price The price of the payment token.
     * @param decimals The number of decimals of the token being sold.
     * @return tokensToPay The amount of payment tokens needed.
     */
    function _calculateTokensToPayPure(
        uint256 tokensToBuy,
        uint256 price,
        uint8 decimals
    ) private pure returns (uint256 tokensToPay) {
        tokensToPay = (tokensToBuy * price) / 10 ** decimals;
    }

    /**
     * @dev Private function to check if the token price is zero and revert if true.
     * Reverts with `PaymentTokenPriceIsZero` if the price is zero.
     * @param price The price of the payment token.
     */
    function _checkTokenPrice(uint256 price) private pure {
        if (price == 0) {
            revert PaymentTokenPriceIsZero();
        }
    }

    /**
     * @dev Internal function to check if the calculated tokens to pay or buy is zero and revert if true.
     * This function ensures that the purchase amount is not zero to prevent invalid transactions.
     * @param tokensToPayOrToBuy The amount of payment tokens or tokens to buy.
     * Reverts with a `TooSmallPurchaseAmount` error if the amount is zero.
     */
    function _checkPurchaseAmount(uint256 tokensToPayOrToBuy) internal pure {
        if (tokensToPayOrToBuy == 0) {
            revert TooSmallPurchaseAmount();
        }
    }

    /**
     * @dev Private function to get the price of a token for a specific stage.
     * @param stageId The ID of the stage.
     * @param token The address of the token.
     * @return price The price of the token for the specified stage.
     */
    function _getTokenPrice(
        uint256 stageId,
        address token
    ) private view returns (uint256 price) {
        price = _stagePrice[stageId][token];
    }

    /**
     * @dev Private function to get the data of a specific sale stage.
     * This function returns a copy of the stage data and does not allow modifications.
     * @param stageId The ID of the stage to retrieve.
     * @return stage The data of the specified sale stage as a copy.
     */
    function _getSaleStage(
        uint256 stageId
    ) private view returns (SaleStageData memory stage) {
        stage = _stageSale[stageId];
    }

    /**
     * @dev Private function to get the data of a specific sale stage.
     * This function returns a storage reference to the stage data, allowing modifications.
     * @param stageId The ID of the stage to retrieve.
     * @return stage The storage reference to the data of the specified sale stage.
     */
    function _getSaleStageStorage(
        uint256 stageId
    ) private view returns (SaleStageData storage stage) {
        stage = _stageSale[stageId];
    }

    /**
     * @dev Private function to check if a stage does not exist.
     * Returns true if the stage ID does not exist, false otherwise.
     * @param stageId The ID of the stage to check.
     * @return bool True if the stage ID does not exist, false otherwise.
     */
    function _isStageNotExists(uint256 stageId) private view returns (bool) {
        return stageId >= _getTotalStages();
    }

    /**
     * @dev Private function to update the parameters of a stage.
     * Emits a SaleStageUpdated event.
     * @param stageId The ID of the stage to update.
     * @param whitelist Indicates if whitelist is enabled for this sale stage.
     * @param startAt The new start timestamp of the stage.
     * @param duration The new duration of the stage.
     * @param cap The new token cap for the stage.
     */
    function _updateSaleStage(
        uint256 stageId,
        bool whitelist,
        uint256 startAt,
        uint256 duration,
        uint256 cap
    ) private {
        SaleStageData storage stage = _getSaleStageStorage(stageId);

        stage.whitelist = whitelist;

        if (
            stageId == _getCurrentStageIdRaw() &&
            stage.startAt > 0 &&
            block.timestamp >= stage.startAt
        ) {
            // If the stage has already started, then the startAt parameter cannot be decreased.
            revert WrongStartTime();
        }

        if (stageId > 0 && startAt > 0) {
            SaleStageData memory previousStage = _getSaleStage(stageId - 1);
            if (startAt < (previousStage.startAt + previousStage.duration)) {
                revert WrongStartTime();
            }
        }
        stage.startAt = startAt;
        stage.duration = duration;

        if (stage.sold > cap) {
            revert CapCannotBeLessThanSold();
        }
        stage.cap = cap;

        _emitSaleStageUpdated(stageId, stage);
    }

    /**
     * @dev Private function to emit the SaleStageUpdated event.
     * This function is used to notify about the update of a sale stage.
     * @param stageId The ID of the stage.
     * @param stage The data of the sale stage.
     */
    function _emitSaleStageUpdated(
        uint256 stageId,
        SaleStageData memory stage
    ) private {
        emit SaleStageUpdated(
            stageId,
            stage.whitelist,
            stage.startAt,
            stage.duration,
            stage.cap
        );
    }

    /**
     * @notice Private function to update the prices for the specified stage and payment tokens.
     * WARNING: If a price was previously set for a token that is not included in the current `tokens` array,
     * its price will remain in memory. To remove its price, pass the token's address and set its price to 0.
     * @param stageId The ID of the stage to update prices for.
     * Emits a SaleStagePriceUpdated event.
     * @param tokens An array of token addresses for which prices are being set.
     * @param prices An array of prices corresponding to the tokens.
     */
    function _updateSaleStagePrices(
        uint256 stageId,
        address[] memory tokens,
        uint256[] memory prices
    ) private {
        if (tokens.length != prices.length) {
            revert ParametersMismatch();
        }

        for (uint256 i = 0; i < tokens.length; i++) {
            _checkPaymentToken(tokens[i]);
            _stagePrice[stageId][tokens[i]] = prices[i];
            emit SaleStagePriceUpdated(stageId, tokens[i], prices[i]);
        }
    }

    /**
     * @dev Private function to delete the prices for the specified stage and payment tokens.
     * If the input array of tokens is empty, it defaults to the predefined payment tokens.
     * Emits a SaleStagePriceUpdated event.
     * @param stageId The ID of the stage to delete prices for.
     * @param tokens An array of token addresses for which prices are being deleted (use zero address for native coin).
     */
    function _deleteSaleStagePrices(
        uint256 stageId,
        address[] memory tokens
    ) private {
        tokens = _getDefaultPaymentTokensIfEmpty(tokens);

        for (uint256 i = 0; i < tokens.length; i++) {
            delete _stagePrice[stageId][tokens[i]];
            emit SaleStagePriceUpdated(stageId, tokens[i], 0);
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title TokenSaleVesting
 * @dev Abstract contract to manage the TokenVesting contract address and its state.
 * Inherits from Ownable2Step to provide ownership control.
 */
abstract contract TokenSaleVesting is Ownable2Step {
    /// @dev Address of the TokenVesting contract.
    address private _tokenVesting;

    /// @dev Flag indicating if the TokenVesting address is frozen.
    bool private _tokenVestingFrozen;

    /**
     * @dev Emitted when the TokenVesting address is changed.
     * @param tokenVesting The new TokenVesting address.
     */
    event TokenVestingUpdated(address tokenVesting);

    /// @dev Emitted when the TokenVesting is frozen.
    event TokenVestingFrozen();

    /// @dev Error thrown when the TokenVesting address is zero.
    error TokenVestingIsZero();

    /// @dev Error thrown when the TokenVesting is frozen and an update is attempted.
    error TokenVestingIsFrozen();

    /**
     * @dev Constructor to initialize the TokenVesting.
     * @param tokenVesting The address of the initial TokenVesting.
     */
    constructor(address tokenVesting) {
        _setTokenVesting(tokenVesting);
    }

    /**
     * @notice Returns the current TokenVesting address and its frozen status.
     * @return tokenVesting The current TokenVesting address.
     * @return tokenVestingFrozen The frozen status of the TokenVesting address.
     */
    function getTokenVesting()
        external
        view
        returns (address tokenVesting, bool tokenVestingFrozen)
    {
        return (_tokenVesting, _tokenVestingFrozen);
    }

    /**
     * @notice Sets a new TokenVesting address.
     * @dev Can only be called by the contract owner.
     * Emits a TokenVestingUpdated event.
     * @param tokenVesting The address of the TokenVesting.
     */
    function setTokenVesting(address tokenVesting) external onlyOwner {
        if (_tokenVestingFrozen) {
            revert TokenVestingIsFrozen();
        }
        _setTokenVesting(tokenVesting);
    }

    /**
     * @notice Freezes the TokenVesting, preventing further changes.
     * @dev Can only be called by the contract owner.
     * Emits a TokenVestingFrozen event.
     */
    function freezeTokenVesting() external onlyOwner {
        if (_tokenVesting == address(0)) {
            revert TokenVestingIsZero();
        }
        if (_tokenVestingFrozen) {
            revert TokenVestingIsFrozen();
        }

        _tokenVestingFrozen = true;
        emit TokenVestingFrozen();
    }

    /**
     * @dev Internal function to get the current TokenVesting address.
     * @return The current TokenVesting address.
     */
    function _getTokenVesting() internal view returns (address) {
        if (_tokenVesting == address(0)) {
            revert TokenVestingIsZero();
        }
        return _tokenVesting;
    }

    /**
     * @dev Private function to set a new TokenVesting address and emit an event.
     * Emits a TokenVestingUpdated event.
     * @param tokenVesting The address of the new TokenVesting.
     */
    function _setTokenVesting(address tokenVesting) private {
        _tokenVesting = tokenVesting;
        emit TokenVestingUpdated(tokenVesting);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title Whitelist
 * @dev This abstract contract manages a whitelist for accessing token sales.
 * The owner can add or remove addresses to the whitelist and set a Merkle root for Merkle Tree based verification.
 * Inherits from Ownable2Step.
 */
abstract contract Whitelist is Ownable2Step {
    /// @dev Mapping to store whitelist status of addresses.
    mapping(address user => bool) private _whitelist;

    /// @dev Merkle root for verifying Merkle Proofs.
    bytes32 private _merkleRoot;

    /**
     * @dev Flag indicating if whitelisting by deposit is enabled.
     * If true, users can be whitelisted by making a deposit.
     */
    bool private _whitelistingByDeposit;

    /**
     * @dev Emitted when the whitelisting by deposit status is updated.
     * @param status The new status of whitelisting by deposit.
     */
    event WhitelistingByDepositUpdated(bool status);

    /**
     * @dev Emitted when the Merkle root is updated.
     * @param merkleRoot The new Merkle root.
     */
    event MerkleRootUpdated(bytes32 indexed merkleRoot);

    /**
     * @dev Emitted when an address is added to the whitelist.
     * @param user The address that was added.
     */
    event WhitelistGranted(address indexed user);

    /**
     * @dev Emitted when an address is removed from the whitelist.
     * @param user The address that was removed.
     */
    event WhitelistRevoked(address indexed user);

    /// @dev Error thrown when the address is not whitelisted.
    error NotWhitelisted();

    /**
     * @dev Constructor to initialize the contract with a Merkle root.
     * @param whitelistingByDeposit The new status of whitelisting by deposit. If true, users can be whitelisted by making a deposit.
     * @param merkleRoot The initial Merkle root for verifying proofs.
     */
    constructor(bool whitelistingByDeposit, bytes32 merkleRoot) {
        _setWhitelistingByDeposit(whitelistingByDeposit);
        _setMerkleRoot(merkleRoot);
    }

    /**
     * @notice Returns the current Merkle root.
     * @return The current Merkle root.
     */
    function getMerkleRoot() external view returns (bytes32) {
        return _merkleRoot;
    }

    /**
     * @notice Verifies if an address is whitelisted using a Merkle proof.
     * @param user The address to verify.
     * @param merkleProof The Merkle proof.
     * @return True if the address is verified, false otherwise.
     */
    function verifyWhitelistProof(
        address user,
        bytes32[] calldata merkleProof
    ) external view returns (bool) {
        return _verifyWhitelistProof(user, merkleProof);
    }

    /**
     * @notice Returns the current status of whitelisting by deposit.
     * @return The current status of whitelisting by deposit.
     */
    function isWhitelistingByDepositEnabled() external view returns (bool) {
        return _isWhitelistingByDepositEnabled();
    }

    /**
     * @notice Checks if an address is whitelisted.
     * @param user The address to check.
     * @return True if the address is whitelisted, false otherwise.
     */
    function isWhitelisted(address user) external view returns (bool) {
        return _isWhitelisted(user);
    }

    /**
     * @notice Adds addresses to the whitelist.
     * @dev Can only be called by the contract owner.
     * @param users The addresses to be added to the whitelist.
     */
    function grantWhitelist(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            _grantWhitelist(users[i]);
        }
    }

    /**
     * @notice Removes addresses from the whitelist.
     * @dev Can only be called by the contract owner.
     * @param users The addresses to be removed from the whitelist.
     */
    function revokeWhitelist(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            _revokeWhitelist(users[i]);
        }
    }

    /**
     * @notice Sets the Merkle root for verifying Merkle proofs.
     * @dev Can only be called by the contract owner.
     * @param merkleRoot The new Merkle root.
     */
    function setMerkleRoot(bytes32 merkleRoot) external onlyOwner {
        _setMerkleRoot(merkleRoot);
    }

    /**
     * @notice Sets the status of whitelisting by deposit.
     * @dev Can only be called by the contract owner.
     * @param status The new status of whitelisting by deposit. If true, users can be whitelisted by making a deposit.
     */
    function setWhitelistingByDeposit(bool status) external onlyOwner {
        _setWhitelistingByDeposit(status);
    }

    /**
     * @dev Internal function to check if an address is whitelisted.
     * @param user The address to check.
     * @return True if the address is whitelisted, false otherwise.
     */
    function _isWhitelisted(address user) internal view returns (bool) {
        return _whitelist[user];
    }

    /**
     * @dev Internal function to get the status of whitelisting by deposit.
     * @return The current status of whitelisting by deposit.
     */
    function _isWhitelistingByDepositEnabled() internal view returns (bool) {
        return _whitelistingByDeposit;
    }

    /**
     * @dev Internal function to add an address to the whitelist.
     * Emits a WhitelistGranted event.
     * @param user The address to add.
     */
    function _grantWhitelist(address user) internal {
        _whitelist[user] = true;
        emit WhitelistGranted(user);
    }

    /**
     * @dev Internal function to remove an address from the whitelist.
     * Emits a WhitelistRevoked event.
     * @param user The address to remove.
     */
    function _revokeWhitelist(address user) internal {
        _whitelist[user] = false;
        emit WhitelistRevoked(user);
    }

    /**
     * @dev Internal function to check if an address has a valid Merkle proof.
     * Reverts with NotWhitelisted if neither is true.
     * @param user The address to check.
     * @param merkleProof The Merkle proof.
     */
    function _checkWhitelistProof(
        address user,
        bytes32[] calldata merkleProof
    ) internal view {
        if (!_verifyWhitelistProof(user, merkleProof)) {
            revert NotWhitelisted();
        }
    }

    /**
     * @dev private function to verify if an address is whitelisted using a Merkle proof.
     * @param user The address to verify.
     * @param merkleProof The Merkle proof.
     * @return True if the address is verified, false otherwise.
     */
    function _verifyWhitelistProof(
        address user,
        bytes32[] calldata merkleProof
    ) private view returns (bool) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(user))));
        return MerkleProof.verify(merkleProof, _merkleRoot, leaf);
    }

    /**
     * @dev Private function to set the Merkle root.
     * Emits a MerkleRootUpdated event.
     * @param merkleRoot The new Merkle root.
     */
    function _setMerkleRoot(bytes32 merkleRoot) private {
        _merkleRoot = merkleRoot;
        emit MerkleRootUpdated(merkleRoot);
    }

    /**
     * @dev Private function to set the status of whitelisting by deposit.
     * Emits a WhitelistingByDepositUpdated event.
     * @param status The new status of whitelisting by deposit.
     */
    function _setWhitelistingByDeposit(bool status) private {
        _whitelistingByDeposit = status;
        emit WhitelistingByDepositUpdated(status);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC20Permit} from "../extensions/IERC20Permit.sol";
import {Address} from "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

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
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

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
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.20;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the Merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates Merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     *@dev The multiproof provided is not valid.
     */
    error MerkleProofInvalidMultiproof();

    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Sorts the pair (a, b) and hashes the result.
     */
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    /**
     * @dev Implementation of keccak256(abi.encode(a, b)) that doesn't allocate or expand memory.
     */
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}