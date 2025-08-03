// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Votes} from "./Votes.sol";

/// @title Skins ERC-20 token contract
/// @author Holdex Limited (https://holdex.io)
/// @dev Based on the the ERC-20 token standard as defined at https://eips.ethereum.org/EIPS/eip-20
contract SkinsToken is Votes {
    /// @notice EIP-20 token name for this token
    string public constant name = "COINS & SKINS";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "SKINS";

    /// @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 18;

    /// @notice Total number of tokens in circulation
    uint96 public constant totalSupply = 800_000_000e18; // 800 million SKINS

    /// @notice Allowance amounts on behalf of others
    mapping(address => mapping(address => uint96)) private _allowances;

    /// @notice Official record of token balances for each account
    mapping(address => uint96) internal balances;

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice The standard EIP-20 approval event
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    constructor(address multisig) nonZA(multisig) {
        balances[multisig] = totalSupply;
        emit Transfer(address(0), multisig, totalSupply);
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    /**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(
        address account,
        address spender
    ) external view returns (uint) {
        return _allowances[account][spender];
    }

    /**
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param spender The address of the account which may transfer tokens
     * @param rawAmount The number of tokens that are approved (2^256-1 means infinite)
     * @return Whether or not the approval succeeded
     */
    function approve(
        address spender,
        uint256 rawAmount
    ) external nonZA(spender) returns (bool) {
        uint96 amount;
        if (rawAmount == type(uint256).max) {
            amount = type(uint96).max;
        } else {
            amount = safe96(rawAmount);
        }

        _allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transfer(
        address dst,
        uint256 rawAmount
    ) external nonZA(dst) returns (bool) {
        uint96 amount = safe96(rawAmount);
        return _transferTokens(msg.sender, dst, amount);
    }

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferFrom(
        address src,
        address dst,
        uint256 rawAmount
    ) external nonZA(src) nonZA(dst) returns (bool) {
        address spender = msg.sender;
        uint96 spenderAllowance = _allowances[src][spender];
        uint96 amount = safe96(rawAmount);

        if (spender != src && spenderAllowance != type(uint96).max) {
            uint96 newAllowance = sub96(spenderAllowance, amount);
            _allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        return _transferTokens(src, dst, amount);
    }

    function _transferTokens(
        address src,
        address dst,
        uint96 amount
    ) internal returns (bool) {
        balances[src] = sub96(balances[src], amount);
        unchecked {
            balances[dst] += amount;
        }
        emit Transfer(src, dst, amount);
        _moveDelegates(delegates[src], delegates[dst], amount);

        return true;
    }

    /**
     * @dev Returns the voting units of an `account`.
     */
    function _getVotingUnits(
        address account
    ) internal view override returns (uint96) {
        return balances[account];
    }

    function _name() internal pure override returns (string memory) {
        return name;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Value} from "./utils/Value.sol";
import {Nonces} from "./utils/Nonces.sol";
import {SafeMath} from "./utils/SafeMath.sol";

abstract contract Votes is Value, Nonces, SafeMath {
    /// @notice A record of each accounts delegate
    mapping(address => address) public delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint96 fromBlock;
        uint96 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping(address => mapping(uint96 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping(address => uint96) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 private constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
        );

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 private constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(
        address indexed delegate,
        uint256 previousBalance,
        uint256 newBalance
    );

    error VotesExpiredSignature(uint256 expiry);

    /**
     * @dev Lookup to future votes is not available.
     */
    error ERC5805FutureLookup(uint256 timepoint, uint256 currentBlock);

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getVotes(address account) external view returns (uint96) {
        uint96 nCheckpoints = numCheckpoints[account];
        return
            nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPastVotes(
        address account,
        uint256 blockNumber
    ) external view returns (uint96) {
        uint256 currentBlock = getBlockNumber();
        if (blockNumber >= currentBlock)
            revert ERC5805FutureLookup(blockNumber, currentBlock);

        uint96 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint96 lower = 0;
        uint96 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint96 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (block.timestamp > expiry) revert VotesExpiredSignature(expiry);

        address signer = _recover(delegatee, nonce, expiry, v, r, s);
        if (signer == address(0)) revert NonZeroAddress();

        _useCheckedNonce(signer, nonce);
        _delegate(signer, delegatee);
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);
        _moveDelegates(currentDelegate, delegatee, _getVotingUnits(delegator));
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint96 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint96 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = checkpoints[srcRep][srcRepNum - 1].votes;
                _writeCheckpoint(
                    srcRep,
                    srcRepNum,
                    srcRepOld,
                    sub96(srcRepOld, amount)
                );
            }

            if (dstRep != address(0)) {
                uint96 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0
                    ? checkpoints[dstRep][dstRepNum - 1].votes
                    : 0;
                _writeCheckpoint(
                    dstRep,
                    dstRepNum,
                    dstRepOld,
                    dstRepOld + amount
                );
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint96 nCheckpoints,
        uint96 oldVotes,
        uint96 newVotes
    ) internal {
        uint96 blockNumber = safe96(getBlockNumber());

        if (
            nCheckpoints > 0 &&
            checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber
        ) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(
                blockNumber,
                newVotes
            );
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function _recover(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (address) {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(_name())),
                _getChainId(),
                address(this)
            )
        );
        bytes32 structHash = keccak256(
            abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry)
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );
        return ecrecover(digest, v, r, s);
    }

    /**
     * @dev Must return the voting units held by an account.
     */
    function _getVotingUnits(address) internal view virtual returns (uint96);

    function _getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function _name() internal pure virtual returns (string memory);

    function getBlockNumber() public view virtual returns (uint256) {
        return block.number;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @dev Provides tracking nonces for addresses. Nonces will only increment.
 */
abstract contract Nonces {
    /**
     * @dev The nonce used for an `account` is not the expected current nonce.
     */
    error InvalidAccountNonce(address account, uint256 currentNonce);

    mapping(address account => uint256) private _nonces;

    /**
     * @dev Returns the next unused nonce for an address.
     */
    function nonces(address owner) public view virtual returns (uint256) {
        return _nonces[owner];
    }

    /**
     * @dev Consumes a nonce.
     *
     * Returns the current value and increments nonce.
     */
    function _useNonce(address owner) internal virtual returns (uint256) {
        // For each account, the nonce has an initial value of 0, can only be incremented by one, and cannot be
        // decremented or reset. This guarantees that the nonce never overflows.
        unchecked {
            // It is important to do x++ and not ++x here.
            return _nonces[owner]++;
        }
    }

    /**
     * @dev Same as {_useNonce} but checking that `nonce` is the next valid for `owner`.
     */
    function _useCheckedNonce(address owner, uint256 nonce) internal virtual {
        uint256 current = _useNonce(owner);
        if (nonce != current) {
            revert InvalidAccountNonce(owner, current);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract SafeMath {
    error AmountExceedBits();
    error AmountOverflow();
    error AmountUnderflow();

    function safe96(uint256 n) internal pure returns (uint96) {
        if (n > 2 ** 96) revert AmountExceedBits();
        return uint96(n);
    }

    function sub96(uint96 a, uint96 b) internal pure returns (uint96) {
        unchecked {
            if (b > a) revert AmountUnderflow();
            return a - b;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract Value {
    error NonZeroAddress();

    modifier nonZA(address sender) {
        if (address(0) == sender) revert NonZeroAddress();
        _;
    }
}