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
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IERC20Extended is IERC20 {
    function decimals() external view returns (uint8);
}

contract MetacadeTournament is Ownable(msg.sender), ReentrancyGuard {
    address public updater;
    uint256 private constant CBR_SCALE_FACTOR = 10 ** 6;

    constructor(address _updater) {
        updater = _updater;
    }

    struct Tournament {
        IERC20 paymentToken;
        bool isActive;
        uint256 gameId;
        uint256 startedAtBlock;
        uint256 creditBurnRate;
        uint256 baseCreditCost;
        Shareholder[] shareholders;
        CreditPackageType creditPackages;
    }

    mapping(uint256 => Tournament) public tournaments;
    mapping(address => mapping(uint256 => uint256))
        public claimablePrizesForTournament;
    mapping(uint256 => uint256) public prizePools;
    mapping(uint256 => WinnerInfo[]) public tournamentWinners;

    struct WinnerInfo {
        address winner;
        uint256 amount;
    }
    struct Shareholder {
        address wallet;
        uint256 share;
    }
    struct CreditPackageType {
        uint256 tier1;
        uint256 tier2;
        uint256 tier3;
    }

    event TournamentCreated(
        uint256 indexed tournamentId,
        address paymentToken,
        uint256 creditBurnRate,
        uint256 baseCreditCost,
        uint256 gameId
    );
    event PrizePoolFunded(
        uint256 indexed tournamentId,
        address funder,
        uint256 amount
    );
    event TournamentStarted(uint256 indexed tournamentId, uint256 timestamp);
    event TournamentEnded(uint256 indexed tournamentId, uint256 timestamp);
    event CreditPurchased(
        uint256 indexed tournamentId,
        uint256 gameId,
        address buyer,
        address paymentToken,
        uint256 amount
    );
    event Claimed(
        uint256 indexed tournamentId,
        address claimer,
        uint256 amount,
        address paymentToken
    );
    event WinnersUpdated(uint256 indexed tournamentId);

    modifier onlyUpdater() {
        require(msg.sender == updater, "Not authorized");
        _;
    }

    function updateUpdater(address _updater) external onlyOwner {
        updater = _updater;
    }

    function getTournamentWinners(
        uint256 tournamentId
    ) external view returns (WinnerInfo[] memory) {
        return tournamentWinners[tournamentId];
    }

    function getTournamentShareholder(
        uint256 tournamentId,
        uint256 shareholderIndex
    ) external view returns (address, uint256) {
        Shareholder memory shareholder = tournaments[tournamentId].shareholders[
            shareholderIndex
        ];
        return (shareholder.wallet, shareholder.share);
    }

    function getTournamentCreditPackageType(
        uint256 tournamentId
    ) external view returns (CreditPackageType memory) {
        CreditPackageType memory creditPackages = tournaments[tournamentId]
            .creditPackages;
        return creditPackages;
    }

    function createTournament(
        uint256 tournamentId,
        uint256 gameId,
        uint256 creditBurnRate,
        uint256 baseCreditCost,
        address paymentTokenAddress,
        Shareholder[] memory _shareholders,
        CreditPackageType memory _creditPackages
    ) external onlyOwner {
        require(
            tournaments[tournamentId].paymentToken == IERC20(address(0)),
            "Tournament already exists"
        );
        require(
            creditBurnRate >= 0,
            "Credit Burn Rate should be greater than or equal to 0"
        );
        require(
            baseCreditCost >= 0,
            "Base Credit Cost should be greater than or equal to 0"
        );
        require(
            gameId > 0,
            "Tournament must be associated with a certain game identifier"
        );

        uint256 totalShare = 0;
        for (uint256 i = 0; i < _shareholders.length; i++) {
            require(_shareholders[i].share > 0, "Share must be greater than 0");
            totalShare += _shareholders[i].share;
        }
        require(totalShare == 100, "Total share must be exactly 100");

        Shareholder[] storage allShareholders = tournaments[tournamentId]
            .shareholders;
        for (uint256 i = 0; i < _shareholders.length; i++) {
            allShareholders.push(_shareholders[i]);
        }
        uint256 scaledCBR = creditBurnRate * CBR_SCALE_FACTOR;

        IERC20 paymentToken = IERC20(paymentTokenAddress);
        Tournament storage tournament = tournaments[tournamentId];
        tournament.paymentToken = paymentToken;
        tournament.baseCreditCost = baseCreditCost;
        tournament.gameId = gameId;
        tournament.isActive = false;
        tournament.creditBurnRate = scaledCBR;
        tournament.startedAtBlock = 0;
        tournament.creditPackages = _creditPackages;

        emit TournamentCreated(
            tournamentId,
            paymentTokenAddress,
            creditBurnRate,
            baseCreditCost,
            gameId
        );
    }

    function startTournament(uint256 tournamentId) external onlyOwner {
        Tournament storage tournament = tournaments[tournamentId];
        require(!tournament.isActive, "Tournament already active");
        require(tournament.gameId > 0, "Tournament does not exist");

        tournament.isActive = true;
        tournament.startedAtBlock = block.number;

        emit TournamentStarted(tournamentId, block.timestamp);
    }

    function fundPrizePool(
        uint256 tournamentId,
        uint256 tokenAmount
    ) external payable {
        Tournament storage tournament = tournaments[tournamentId];
        require(tournament.isActive, "Tournament is not active.");

        uint256 fundedAmount;

        if (tournament.paymentToken == IERC20(address(0))) {
            require(msg.value > 0, "Ether amount must be greater than 0");
            prizePools[tournamentId] += msg.value;
            fundedAmount = msg.value;
        } else {
            require(tokenAmount > 0, "Token amount must be greater than 0");
            require(msg.value == 0, "Do not send Ether for ERC20 funding");
            require(
                tournament.paymentToken.transferFrom(
                    msg.sender,
                    address(this),
                    tokenAmount
                ),
                "Token transfer to contract failed"
            );
            prizePools[tournamentId] += tokenAmount;
            fundedAmount = tokenAmount;
        }

        emit PrizePoolFunded(tournamentId, msg.sender, fundedAmount);
    }

    function swapForCredits(
        uint256 tournamentId,
        uint256 gameId,
        uint256 creditTier,
        address beneficiary
    ) external payable nonReentrant {
        require(beneficiary != address(0), "Invalid beneficiary address");
        Tournament storage tournament = tournaments[tournamentId];
        require(tournament.isActive, "Tournament is paused");
        require(gameId == tournament.gameId, "Invalid game id");

        uint256 tokenAmount;
        if (creditTier == 1) {
            tokenAmount = tournament.creditPackages.tier1;
        } else if (creditTier == 2) {
            tokenAmount = tournament.creditPackages.tier2;
        } else if (creditTier == 3) {
            tokenAmount = tournament.creditPackages.tier3;
        } else {
            revert("Invalid credit tier");
        }

        if (tournament.paymentToken == IERC20(address(0))) {
            require(msg.value == tokenAmount, "Incorrect Ether amount");
        } else {
            require(msg.value == 0, "This tournament does not accept Ether");
            require(
                tournament.paymentToken.transferFrom(
                    msg.sender,
                    address(this),
                    tokenAmount
                ),
                "ERC20 token transfer failed"
            );
        }

        distributeTokens(tournamentId, tokenAmount);

        emit CreditPurchased(
            tournamentId,
            gameId,
            beneficiary,
            address(tournament.paymentToken),
            tokenAmount
        );
    }

    function distributeTokens(
        uint256 tournamentId,
        uint256 tokenAmount
    ) internal {
        Tournament storage tournament = tournaments[tournamentId];

        for (uint256 i = 0; i < tournament.shareholders.length; i++) {
            Shareholder memory shareholder = tournament.shareholders[i];
            uint256 shareholderAmount = (tokenAmount * shareholder.share) / 100;

            if (tournament.paymentToken == IERC20(address(0))) {
                if (shareholder.wallet == address(this)) {
                    prizePools[tournamentId] += shareholderAmount;
                } else {
                    (bool sent, ) = shareholder.wallet.call{
                        value: shareholderAmount
                    }("");
                    require(sent, "Failed to send Ether");
                }
            } else {
                if (shareholder.wallet == address(this)) {
                    require(
                        tournament.paymentToken.transfer(
                            address(this),
                            shareholderAmount
                        ),
                        "Token transfer to contract failed"
                    );
                    prizePools[tournamentId] += shareholderAmount;
                } else {
                    require(
                        tournament.paymentToken.transfer(
                            shareholder.wallet,
                            shareholderAmount
                        ),
                        "Token transfer to shareholder failed"
                    );
                }
            }
        }
    }

    function updateWinners(
        uint256 tournamentId,
        address[] calldata winnerAddresses,
        uint256[] calldata amountsInWei
    ) external onlyUpdater {
        require(
            winnerAddresses.length == amountsInWei.length,
            "Address and amount arrays must match"
        );

        Tournament storage tournament = tournaments[tournamentId];
        require(!tournament.isActive, "Tournament must be ended first");

        delete tournamentWinners[tournamentId];
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < winnerAddresses.length; i++) {
            tournamentWinners[tournamentId].push(
                WinnerInfo({
                    winner: winnerAddresses[i],
                    amount: amountsInWei[i]
                })
            );
            claimablePrizesForTournament[winnerAddresses[i]][
                tournamentId
            ] += amountsInWei[i];
            totalAmount += amountsInWei[i];
        }

        // Ensure the total amount being claimed does not exceed the prize pool
        require(
            totalAmount <= prizePools[tournamentId],
            "Total amount exceeds prize pool"
        );

        emit WinnersUpdated(tournamentId);
    }

    function endTournament(uint256 tournamentId) external onlyOwner {
        Tournament storage tournament = tournaments[tournamentId];
        require(tournament.isActive, "Tournament has not started");

        tournament.isActive = false;
        emit TournamentEnded(tournamentId, block.timestamp);
    }

    function withdrawToken(
        address tokenAddress,
        uint256 amount
    ) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");

        if (tokenAddress == address(0)) {
            require(
                address(this).balance >= amount,
                "Insufficient Ether balance"
            );
            (bool sent, ) = msg.sender.call{value: amount}("");
            require(sent, "Failed to send Ether");
        } else {
            // Withdrawal request for an ERC20 token
            IERC20 token = IERC20(tokenAddress);
            uint256 contractBalance = token.balanceOf(address(this));
            require(contractBalance >= amount, "Insufficient token balance");
            require(
                token.transfer(msg.sender, amount),
                "Token transfer failed"
            );
        }
    }

    function claim(uint256 tournamentId) external nonReentrant {
        uint256 claimAmount = claimablePrizesForTournament[msg.sender][
            tournamentId
        ];

        require(claimAmount > 0, "No claimable amount");
        claimablePrizesForTournament[msg.sender][tournamentId] = 0;
        Tournament storage tournament = tournaments[tournamentId];

        if (address(tournament.paymentToken) == address(0)) {
            (bool sent, ) = msg.sender.call{value: claimAmount}("");
            require(sent, "Failed to send Ether");
        } else {
            require(
                tournament.paymentToken.transfer(msg.sender, claimAmount),
                "Token transfer failed"
            );
        }

        emit Claimed(
            tournamentId,
            msg.sender,
            claimAmount,
            address(tournament.paymentToken)
        );
    }
}