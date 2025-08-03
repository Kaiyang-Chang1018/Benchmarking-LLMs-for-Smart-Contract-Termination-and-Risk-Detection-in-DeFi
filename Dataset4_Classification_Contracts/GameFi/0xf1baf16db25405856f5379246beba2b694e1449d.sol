// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

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

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
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
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
import "./WhaleGame.sol";
import { SafeTransferLib } from "lib/solmate/src/utils/SafeTransferLib.sol";

error NotAuthorized();
error NotVested();

contract RewardsVesting {

    WhaleGame public whaleGame;
    uint256 public roundWon;
    address payable public winner;

    constructor(WhaleGame whaleGame_, uint256 roundWon_, address payable winner_) {
        whaleGame = whaleGame_;
        roundWon = roundWon_;
        winner = winner_;
    }

    // receives eth from the whale game
    receive() external payable {}

    function claim() external {
        // require the msg.sender is the winner
        if (msg.sender != winner) revert NotAuthorized();
        
        // require 5 rounds have passed
        if (whaleGame.round() < roundWon + 5) revert NotVested();

        // pay out the reward      
        SafeTransferLib.safeTransferETH(msg.sender, address(this).balance);  
    }


    function earlyClaim() external {
        // require the msg.sender is the winner
        if (msg.sender != winner) revert NotAuthorized();

        // There's a 20% fee per early round to claim. So if you claim 4 rounds early, 
        // you get 20% of the reward. 3 rounds early, 40% of the reward, 2 rounds -> 60%, 1 round -> 80%
        uint256 vestedRounds = (whaleGame.round() - roundWon) > 5 ? 5 : (whaleGame.round() - roundWon);
        SafeTransferLib.safeTransferETH(payable(winner), address(this).balance * vestedRounds / 5);

        // transfer the remaining balance to the whale token
        if (address(this).balance > 0) {
            SafeTransferLib.safeTransferETH(payable(address(whaleGame.whaleToken())), address(this).balance);  
        }
    }

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./WhaleToken.sol";
import "./RewardsVesting.sol";

// errors
    
    // emitted when the deposit is not the right amount
    error IncorrectDepositAmount();

    // emitted when the deposit timelock has not passed
    error DepositTimelockNotPassed();

    // emitted when the user deposits twice in the same block
    error DepositCooldown();

    // emitted when the user is already the claimer
    error AlreadyClaimer();

    // emitted when the claimer is not the sender
    error NotClaimer();

    // emitted when the claim time has not passed
    error ClaimTimeNotPassed();
    
 
contract WhaleGame {

// events

    // emitted when a user deposits
    event Deposited(address indexed user, uint256 indexed amount);

    // emitted when a user claims
    event Claim(uint256 indexed round, uint256 indexed amount, address indexed user, address vestingContract);

// deps

    // the $WHALE token
    WhaleToken public whaleToken;

// constants

    // initial deposit cost (in wei) for each round
    uint256 public constant INITIAL_DEPOSIT_COST = 5e16 wei;

    // fee charged for each deposit that goes to back the token (in percents)
    uint256 public constant FEE_RATE = 50;

    // incremental rate of growth for deposits (in tenths of percents)
    uint256 public constant GROWTH_RATE = 33; // 3.3%

    // the minimum amount of time elapsed between each deposit
    uint256 public constant BUFFER_PERIOD = 15 seconds;

    // the amount of time a user has to wait in between deposits
    uint256 public constant DEPOSIT_TIMELOCK = 12 hours;

    // the amount of time a user has to wait in before claiming
    uint256 public constant CLAIM_TIMELOCK = 1 days;

    // the decay factor on the token emissions between rounds (in percents)
    uint256 public constant DECAY_FACTOR = 85;

    // the lowest multiplier for WHALE token rewards — initial rewards are 10x this amount
    uint256 public constant MIN_TOKEN_MULTIPLIER = 1e17;

    // base number of tokens minted before mutliplier is applied
    uint256 public constant BASE_TOKENS_MINTED = 100_000;

// states

    // the current token reward multiplier
    uint256 public tokenMultiplier = 1e18; // this value decays per round until 1e17

    // the current game round
    uint256 public round;

    // the eligible claimer
    address public claimer;

    // the current deposit cost
    uint256 public depositCost;

    // the current claim time
    uint256 public claimTime;

    // the timestamp of the most recent deposit, used to create a time buffers between deposits
    uint256 public lastDepositTimestamp;

    // an arbitrary message broadcasted by the most recent depositor
    string public graffiti;

// mappings

    // deposit timelock for users
    mapping(address => uint256) public userDepositTimelock;

    // rewards vesting contract for each round
    mapping(uint256 => RewardsVesting) public vestingContractForRound;




// functions

    constructor () {
        // deploy the whale token
        whaleToken = new WhaleToken();

        // initialize the game state
        _resetGame();
    }

    function deposit(string memory graffiti_) external payable {

    // input validations
        
        // 1. check that the deposit is the right amount
        if (msg.value != depositCost) revert IncorrectDepositAmount();

        // 2. check that the current time is not before the next deposit timestamp of the msg.sender
        if (userDepositTimelock[msg.sender] != 0 && block.timestamp < userDepositTimelock[msg.sender]) revert DepositTimelockNotPassed();

        // 3. check that the current block is not the same as the previous deposit block with a 15 second time buffer
        if (block.timestamp < lastDepositTimestamp + BUFFER_PERIOD) revert DepositCooldown();

        // 4. check that the msg.sender is not already the first claimer
        if (msg.sender == claimer) revert AlreadyClaimer();

    
    // state updates

        // 1. set the next deposit timestamp of the msg.sender to 12 hours from now
        userDepositTimelock[msg.sender] = block.timestamp + DEPOSIT_TIMELOCK;

        // 2. set the last deposit timestamp to the current time
        lastDepositTimestamp = block.timestamp;

        // 3. set the claimer to the message sender
        claimer = payable(msg.sender);

        // 4. set the claim time to 1 day from now
        claimTime = block.timestamp + CLAIM_TIMELOCK;

        // 5. calculate the fee to send to the token contract
        uint256 fee = depositCost * FEE_RATE / 100;

        // 6. then increment the deposit cost by growth rate (3.3%)
        depositCost = depositCost * (1000 + GROWTH_RATE) / 1000;

        // 7. set the new message to display on the bulletin
        graffiti = graffiti_;


    // external interactions       

        // mint the multiplier adjusted token reward for this round to the depositor
        whaleToken.mint(msg.sender, BASE_TOKENS_MINTED * tokenMultiplier);

        // send fee to the token contract
        SafeTransferLib.safeTransferETH(address(whaleToken), fee);

        // emit the deposit event
        emit Deposited(msg.sender, msg.value);
    }


    function claim() external {
    
    // input validations

        // check that the claimer is the sender
        if (msg.sender != claimer) revert NotClaimer();

        // require that the claim time has passed
        if (block.timestamp < claimTime) revert ClaimTimeNotPassed();

    // state updates

        // decay the token reward multiplier by decay 85%
        tokenMultiplier = (tokenMultiplier * DECAY_FACTOR / 100); 

        // set up the Rewards Vesting contract
        RewardsVesting vestingContract = new RewardsVesting(this, round, payable(msg.sender));
        vestingContractForRound[round] = vestingContract;

        // reset the game
        _resetGame();

    // external interactions

        // send the balance to the Vesting contract 
        SafeTransferLib.safeTransferETH(address(vestingContract), address(this).balance);

        // unlock fee redemptions on the token after round 10
        if (round == 11) {
            whaleToken.unlockRedemptions();
        }

        // emit the claim event ()
        emit Claim(round - 1, address(this).balance, msg.sender, address(vestingContract));
    }   


    function _resetGame() internal {
        // set the claimer to the zero address
        claimer = payable(address(0));

        // set the deposit cost to .1 ether
        depositCost = INITIAL_DEPOSIT_COST;

        // set the new last deposit timestamp to the current time
        lastDepositTimestamp = block.timestamp;

        // set the claim time to the latest possible time
        claimTime = type(uint256).max;

        // wipe the message
        graffiti = "";

        // increment the round
        round++;
    }

}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import { ERC20 } from "lib/solmate/src/tokens/ERC20.sol";
import { SafeTransferLib } from "lib/solmate/src/utils/SafeTransferLib.sol";

// The $WHALE token contract

contract WhaleToken is ERC20 {
    
    address whaleGame;
    uint256 constant PRECISION = 1e18;
    bool public redemptionsLocked;

    // errors
    error OnlyWhaleGame();
    error RedemptionsLocked();

    // events
    event Redeemed(address indexed to, uint256 amount);
    

    constructor() ERC20("Whale Game Token", "WHALE", 18) {
        whaleGame = msg.sender;
        redemptionsLocked = true;
    }

    // check that this isn't exploitable
    receive() external payable {}


    //
    function mint(address to_, uint256 amount_) external {
        // check that the sender is the whale game
        if (msg.sender != whaleGame) revert OnlyWhaleGame();

        // mint tokens to the to_ address
        _mint(to_, amount_);
    }


    function redeem(uint256 amount_) external {
        // require redemptions to be unlocked
        if (redemptionsLocked) revert RedemptionsLocked();

        // calculate the amount of ETH to return based on the current total supply
        uint256 expectedOut = (address(this).balance * amount_) / totalSupply;

        // burn tokens from the message sender
        _burn(msg.sender, amount_);

        // transfer the ETH to the redeemer
        SafeTransferLib.safeTransferETH(msg.sender, expectedOut);

        // emit the Redeemed event
        emit Redeemed(msg.sender, amount_);
    }

    function unlockRedemptions() external {
        // check the sender is the whale game
        if (msg.sender != whaleGame) revert OnlyWhaleGame();

        // unlock redemptions
        redemptionsLocked = false;
    }
}