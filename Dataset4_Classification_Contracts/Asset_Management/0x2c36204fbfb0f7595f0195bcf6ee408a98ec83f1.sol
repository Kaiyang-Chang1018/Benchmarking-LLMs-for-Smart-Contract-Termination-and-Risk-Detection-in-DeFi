// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./openzeppelin-contracts/contracts/access/Ownable.sol";
import "./openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

interface IRandom {
    function getRandomNumber(uint256 blockNumber,uint256 lastBlockTime) external view returns (uint256) ;
}

contract MineDog is ERC20, Ownable {
    /// @notice Maximum supply of the token
    uint256 public constant MAX_SUPPLY = 420690000000 * 1 ether;
    uint public constant MINT_AMOUNT = 1000000 * 1 ether;

    /// @notice Block interval for mining
    uint256 public BLOCK_INTERVAL = 2 minutes;

    /// @notice The cost to mine
    uint256 public constant MINE_COST = 0.001 ether;

    /// @notice The mining reward
    uint256 public miningReward = 5000000 * 1 ether; 

    /// @notice The current block number
    uint256 public blockNumber;

    /// @notice The last block time
    uint256 public lastBlockTime;

    /// @notice The halving interval
    uint256 public halvingInterval = 21000; 

    /// @notice The last halving block
    uint256 public lastHalvingBlock;

    /// @notice The fee collector address
    address public feeCollector;
    
    /// @notice The staking interest rate
    uint256 public stakingRate = 13888888888 * 3; // daily interest rate

    /// @notice The address of random
    address public random;

    struct Block {
        address[] miners;
        address selectedMiner;
    }

    /// @notice Whether it has been mint
    mapping(address => bool) public hasMinted;

    /// @notice The blocks data
    mapping(uint256 => Block) public blocks;    

    /// @notice The block of staking
    mapping (address => uint256) atBlock;

    /// @notice The amount of staking
    mapping (address => uint) public stakingAmount; 

    /// @notice Total staking rewards
    mapping (address => uint) public totalRewards; 

    event Mine(uint256 indexed blockNumber, address indexed miner, uint256 mineCounts);
    event NewBlock(uint256 indexed blockNumber, address indexed miner);
    event FeeCollectorSet(address feeCollector);
    event Mint(address indexed miner,uint256 amount);

    event Staking(address indexed sender,uint256 amount); 
    event RedeemStaking(address indexed sender,uint256 amount);
    event ReceiveInterest(address indexed sender,uint256 amount);

    constructor() ERC20("MineDog", "MineDog") Ownable(msg.sender) {
        blocks[0].miners.push(msg.sender);
        blocks[1].miners.push(msg.sender);
        lastBlockTime = block.timestamp;

        emit Mine(0, msg.sender, 1);
        emit Mine(1, msg.sender, 1);
    }

    /**
     * @notice Start mint, only once per new address.
     */
    function mint() public payable{
        if (totalSupply()>= 100000000000 * 1 ether && totalSupply() < 110000000000 * 1 ether && feeCollector != address(0)){
            _mint(feeCollector, MAX_SUPPLY / 10); //Used to add liquidity in uniswap
            return ;
        }

        require(msg.value == MINE_COST * 2, "insufficient mine cost");
        require(totalSupply() + MINT_AMOUNT <= 100000000000 * 1 ether, "Total supply exceeded");
        require(!hasMinted[msg.sender], "Address has already minted");
        require(msg.sender == tx.origin, "Contracts are not allowed to mint");

        hasMinted[msg.sender] = true;
        _mint(msg.sender, MINT_AMOUNT);
        emit Mint(msg.sender,MINT_AMOUNT);
    }

    /**
     * @notice Start mint, only once per new address.
     */
    receive() external payable {
        mint();
    }

    /**
     * @notice Get the miners for a specific block.
     * @param _blockNumber The block number
     * @return The miners
     */
    function minersOfBlock(uint256 _blockNumber) public view returns (address[] memory) {
        return blocks[_blockNumber].miners;
    }

    /**
     * @notice Get the miners for a specific block with a range.
     * @dev This function is not recommended to use for on-chain purposes.
     * @param _blockNumber The block number
     * @param _from The start index
     * @param _to The end index
     * @return The miners
     */
    function minersOfBlockWithRange(uint256 _blockNumber, uint256 _from, uint256 _to)
        public
        view
        returns (address[] memory)
    {
        uint256 count = _to - _from;
        address[] memory miners = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            miners[i] = blocks[_blockNumber].miners[_from + i];
        }
        return miners;
    }

    /**
     * @notice Get the number of miners for a specific block.
     * @param _blockNumber The block number
     * @return The number of miners
     */
    function minersOfBlockCount(uint256 _blockNumber) public view returns (uint256) {
        return blocks[_blockNumber].miners.length;
    }

    /**
     * @notice Get the selected miner for a specific block.
     * @param _blockNumber The block number
     * @return The selected miner
     */
    function selectedMinerOfBlock(uint256 _blockNumber) public view returns (address) {
        return blocks[_blockNumber].selectedMiner;
    }

    /**
     * @notice Get the next halving block.
     * @return The next halving block
     */
    function nextHalvingBlock() public view returns (uint256) {
        return lastHalvingBlock + halvingInterval;
    }

    /**
     * @notice Mines the reward multiple times in the current block.
     * @param mineCounts The number of times to mine
     */
    function mine(uint256 mineCounts) external payable {
        require(msg.value == MINE_COST * mineCounts, "insufficient mine cost");

        uint256 targetBlock = blockNumber + 1;
        for (uint256 i = 0; i < mineCounts;) {
            _mine(msg.sender, targetBlock);

            unchecked {
                i++;
            }
        }

        emit Mine(targetBlock, msg.sender, mineCounts);
    }

    /**
     * @notice Mines the reward multiple times in the future block.
     * @param mineCounts The number of times to mine per block
     * @param blockCounts The number of future blocks to mine
     */
    function futureMine(uint256 mineCounts, uint256 blockCounts) external payable {
        require(msg.value == MINE_COST * mineCounts * blockCounts, "insufficient mine cost");

        // The future mine starts with blockNumber + 2.
        uint256 targetBlock = blockNumber + 2;
        for (uint256 i = 0; i < blockCounts;) {
            for (uint256 j = 0; j < mineCounts;) {
                _mine(msg.sender, targetBlock + i);

                unchecked {
                    j++;
                }
            }

            emit Mine(targetBlock + i, msg.sender, mineCounts);

            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice Sets the fee collector address.
     * @param _feeCollector The fee collector address
     */
    function setFeeCollector(address _feeCollector) external onlyOwner {
        feeCollector = _feeCollector;

        emit FeeCollectorSet(_feeCollector);
    }

    /**
     * @notice Collects the Ether.
     * @param amount The amount of Ether to collect
     */
    function collect(uint256 amount) external {
        require(msg.sender == feeCollector, "only feeCollector can collect");

        (bool sent,) = feeCollector.call{value: amount}("");
        require(sent, "failed to send Ether");
    }

    /**
     * @dev Mines the reward.
     * @param user The user address
     * @param targetBlock The target block number to mine
     */
    function _mine(address user, uint256 targetBlock) private {
        blocks[targetBlock].miners.push(user);

        if (block.timestamp >= lastBlockTime + BLOCK_INTERVAL) {
            // Randomly select a miner to receive the reward.
            address selectedMiner = _selectRandomMiner();

            // Proceed halving check & reward only if the whole supply was not minted yet.
            if (totalSupply() + miningReward <= MAX_SUPPLY) {
                // Mint the reward to the selected miner.
                _mint(selectedMiner, miningReward);
                blocks[targetBlock + 1].miners.push(user);
                emit Mine(targetBlock + 1, msg.sender, 1);
            }

            // Record the selected miner.
            blocks[blockNumber].selectedMiner = selectedMiner;
            emit NewBlock(blockNumber, selectedMiner);

            // Proceed to the next block.
            blockNumber++;
            lastBlockTime = block.timestamp;

            // Check if it's time for halving.
            if (blockNumber >= nextHalvingBlock() && BLOCK_INTERVAL < 8 minutes) {
                BLOCK_INTERVAL = BLOCK_INTERVAL * 2;
                halvingInterval = halvingInterval / 2;
                lastHalvingBlock = blockNumber;
            }    
        }
    }

    /**
     * @dev Selects a random miner from the miners of the previous block.
     * @return The selected miner
     */
    function _selectRandomMiner() private view returns (address) {
        uint256 minerCount = minersOfBlockCount(blockNumber);
        uint256 randomIndex = IRandom(random).getRandomNumber(blockNumber,lastBlockTime) % (minerCount);
        return blocks[blockNumber].miners[randomIndex];
    }

    /**
     * @dev Set The address of random
     */
    function setRandom(address _random) external onlyOwner  {           
        random = _random;
    }

    /**
     * @dev Start staking mining.
     * @param amount Staking amount for mining
     */
    function staking(uint amount) public{
        require(amount >= 0);
        _receiveInterest();
        _transfer(msg.sender,address(this), amount);
        stakingAmount[msg.sender] = stakingAmount[msg.sender] + amount;
        emit Staking(msg.sender, amount); 
      }
      
    /**
     * @dev Redeem Staking Mining.
     * @param amount of redemption
     */
    function redeemStaking(uint amount) public{
        require (amount <= stakingAmount[msg.sender] && amount >= 0) ;
        _receiveInterest();
        stakingAmount[msg.sender] = stakingAmount[msg.sender] - amount;
        _transfer(address(this),msg.sender, amount);
        emit RedeemStaking(msg.sender, amount);
      }

    /**
     * @dev Get interest from staking mining.
     */
    function _receiveInterest() private returns (bool) {        
        if(atBlock[msg.sender]==0){
            atBlock[msg.sender] = block.number;
        }
        uint256 _stakingReward = viewStakingInterest(msg.sender);

        if(atBlock[msg.sender] < block.number && totalSupply() + _stakingReward <= MAX_SUPPLY)
        {
            _mint(msg.sender, _stakingReward);
            atBlock[msg.sender] = block.number;
            totalRewards[msg.sender] = totalRewards[msg.sender] + _stakingReward;
            emit ReceiveInterest(msg.sender, _stakingReward);
        }
        return true;
      }

    /**
     * @dev view the unclaimed interest for staking mining.
     */
    function viewStakingInterest(address _user) public view returns (uint _stakingReward) {
        _stakingReward = stakingAmount[_user] * (block.number - atBlock[_user]) * stakingRate / 10**18;
        return _stakingReward;
    }   

    /**
     * @dev view the total Rewards.
     */
    function viewTotalRewards(address _user) public view returns (uint _totalRewards) {
        return totalRewards[_user];
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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {IERC20Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

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
}