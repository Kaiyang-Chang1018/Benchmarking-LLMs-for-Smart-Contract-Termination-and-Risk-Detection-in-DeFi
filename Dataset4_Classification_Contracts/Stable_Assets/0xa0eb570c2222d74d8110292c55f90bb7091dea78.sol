// SPDX-License-Identifier: MIT
// Copyright 2023 PROOF Holdings Inc
pragma solidity ^0.8.0;

import {IRedeemableToken} from "./interfaces/IRedeemableToken.sol";

interface RankingRedeemerEvents {
    /**
     * @notice Emitted on redemption.
     */
    event VoucherRedeemedAndRankingCommited(
        address indexed sender, IRedeemableToken indexed voucher, uint256 indexed tokenId, uint8[] ranking
    );
}

/**
 * @notice Redeemes a token with a submitted ranking of choices, emitting an event containing the ranking as proof.
 * @dev The choices are numbered from 0 to `numChoices - 1`.
 */
contract RankingRedeemer is RankingRedeemerEvents {
    /**
     * @notice Thrown when the ranking length is not equal to the number of choices.
     */
    error InvalidRankingLength(Redemption, uint256 actual, uint256 expected);

    /**
     * @notice Thrown if not all choices were included in a given ranking.
     */
    error InvalidRanking(Redemption, uint256 choicesBitmask);

    /**
     * @notice The number of choices.
     */
    uint8 internal immutable _numChoices;

    /**
     * @notice The bitmask containing all choices.
     */
    uint256 internal immutable _happyBitmask;

    constructor(uint8 numChoices) {
        _numChoices = numChoices;
        _happyBitmask = (1 << numChoices) - 1;
    }

    /**
     * @notice Redeems a redeemable voucher and emits an event containing the ranking of choices as proof.
     * @dev The ranking must contain all choices exactly once, reverts otherwise.
     */
    function _redeem(Redemption calldata r) internal virtual {
        if (r.ranking.length != _numChoices) {
            revert InvalidRankingLength(r, r.ranking.length, _numChoices);
        }

        uint256 choicesBitmask;
        for (uint256 i; i < r.ranking.length; ++i) {
            choicesBitmask |= 1 << r.ranking[i];
        }

        if (choicesBitmask != _happyBitmask) {
            revert InvalidRanking(r, choicesBitmask);
        }

        emit VoucherRedeemedAndRankingCommited(msg.sender, r.redeemable, r.tokenId, r.ranking);
        r.redeemable.redeem(msg.sender, r.tokenId);
    }

    struct Redemption {
        IRedeemableToken redeemable;
        uint256 tokenId;
        uint8[] ranking;
    }

    /**
     * @notice Redeems multiple vouchers and emits events containing the rankings as proof.
     */
    function redeem(Redemption[] calldata redemptions) public virtual {
        for (uint256 i; i < redemptions.length; ++i) {
            _redeem(redemptions[i]);
        }
    }
}
// SPDX-License-Identifier: MIT
// Copyright 2023 PROOF Holdings Inc
pragma solidity ^0.8.0;

/**
 * @notice Interface for a redeemable Voucher token preventing double spending
 * through internal book-keeping (e.g. burning the token, token property, etc.).
 * @dev Voucher tokens are intendent to be redeemed through a redeemer contract.
 */
interface IRedeemableToken {
    /**
     * @notice Thrown if the redemption caller is not allowed to spend a given
     * voucher.
     */
    error RedeemerCallerNotAllowedToSpendVoucher(address sender, uint256 tokenId);

    /**
     * @notice Interface through which a `IRedeemer` contract informs the
     * voucher about its redemption.
     * @param sender The address that initiate the redemption on the
     * redeemer contract.
     * @param tokenId The voucher token to be redeemed.
     * @dev This function MUST be called by redeemer contracts.
     * @dev MUST revert with `RedeemerNotApproved` if the calling redeemer
     * contract is not approved to spend this voucher.
     * @dev MUST revert with `RedeemerCallerNotAllowedToSpendVoucher` if
     * sender is not allowed to spend tokenId.
     */
    function redeem(address sender, uint256 tokenId) external;
}