// File: @openzeppelin/contracts@4.4.0/utils/Context.sol


// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
}

// File: @openzeppelin/contracts@4.4.0/access/Ownable.sol


// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;


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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

// File: @openzeppelin/contracts@4.4.0/token/ERC20/IERC20.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// File: @openzeppelin/contracts@4.4.0/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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

// File: @openzeppelin/contracts@4.4.0/token/ERC20/ERC20.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
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
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
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
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: BaseContract.sol


pragma solidity ^0.8.2.0;



abstract contract BaseContract is ERC20, Ownable {
    struct Member {
        uint256 lifeTimeGrant;
        uint256 remainingGrant;
        uint256 roundTarget;
        uint256 frequency;
        uint256 timestamp;
    }

    // Constants
    uint256 internal constant SECONDS_PER_DAY = 1 days;
    uint256 internal constant SECONDS_PER_YEAR = 365 days; // approx
    uint256 internal constant SECONDS_PER_MONTH = 2629746;
    uint256 internal constant MONTHS_PER_YEAR = 12;
    uint256 internal constant UNIX_START_YEAR = 1970;
    uint256 internal constant EPSILON = 1000;
    // Tokenomics
    uint256 internal constant FOUNDERS_PERC = 15;
    uint256 internal constant TEAM_PERC = 10;
    uint256 internal constant REWARDS_PERC = 30;
    uint256 internal constant ECOSYSTEM_PERC = 45;

    address internal foundersAddress;
    address internal teamAddress;
    address internal rewardsAddress;
    address internal ecosystemAddress;
    address internal stakingAddress;
    mapping(address => uint256) internal governedAccounts;

    uint256 public deployTimestamp;
    uint256 public burntTokens;
    uint256 public circulatingSupply;
    uint256 public ztc_vestingGrants;
    mapping(address => Member) internal ztc_members;

    modifier onlyAuthorized(address _address) {
        callRequire(msg.sender == _address, "Unauthorized access");
        _;
    }

    modifier ownerOnly() {
        callRequire(msg.sender == owner(), "Unauthorized access");
        _;
    }

    modifier onlyOwnerAndAuthorized(address _address) {
        callRequire(msg.sender == owner() || msg.sender == _address, "Unauthorized access");
        _;
    }

    modifier validateMemberGrant(uint256 _grant) {
        callRequire((balanceOf(teamAddress) - ztc_vestingGrants) >= _grant, "Grant exceeds funds");
        _;
    }

    modifier memberNotExists(address _memberAddress) {
        callRequire(ztc_members[_memberAddress].timestamp > 0, "Member does not exist");
        _;
    }

    modifier memberExists(address _memberAddress) {
        callRequire(ztc_members[_memberAddress].timestamp == 0, "Member exists");
        _;
    }

    modifier onlyTokenAccounts() {
        callRequire(governedAccounts[msg.sender] > 0 || msg.sender == owner(), "Unauthorized to burn tokens");
        _;
    }

    function callRequire(bool _condition, string memory _message) internal pure {
        require(_condition, _message);
    }

    function _getYear(uint256 _timestamp) internal pure returns (uint256) {
        return uint256((_timestamp / SECONDS_PER_YEAR) + UNIX_START_YEAR);
    }

    function _getMonth(uint256 _timestamp) internal pure returns (uint256) {
        // Adding 1 since January is 1, not 0
        return (_timestamp - ((_getYear(_timestamp) - UNIX_START_YEAR) * SECONDS_PER_YEAR)) / SECONDS_PER_MONTH + 1;
    }

    function _buildTimestamp(uint256 _ts) internal view returns (uint256) {
        return uint256((_getYear(block.timestamp) - UNIX_START_YEAR) * SECONDS_PER_YEAR + _ts);
    }

    function _getTimestamp(uint256 year, uint256 month) internal pure returns (uint256) {
        return uint256((year - UNIX_START_YEAR) * SECONDS_PER_YEAR + SECONDS_PER_YEAR / MONTHS_PER_YEAR * month);
    }
}

// File: Governance.sol


pragma solidity ^0.8.2.0;

abstract contract Governance is BaseContract {
    enum ProposalStatus { Pending, Approved, Rejected, QuorumNotMet }
    enum ProposalCategory { Rewards, Ecosystem, Founders, Team }

    struct DAOGeneralConfig {
        uint256 minProposerStake;
        uint256 minVoterStake;
        uint256 minStakingDuration;
        uint256 maxActiveProposals;
        uint256 stakingBaseDuration;
        uint256 durationCapFactor;
        uint256 launchTimestamp;
    }

    struct CategoryConfig {
        uint256 minVotingDuration;
        uint256 maxVotingDuration;
        uint256 quorum;
    }

    struct Proposal {
        uint256 id;
        uint256 creationTime;
        uint256 votingEndTime;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 concluded;
        string description;
        ProposalStatus status;
        ProposalCategory category;
        mapping(address => uint256) voted;
        uint256[] parameters;
    }

    struct Stake {
        uint256 timestamp;
        uint256 balance;
    }

    uint256 internal constant QUORUM_DIVISION_FACTOR = 1000;
    uint256 internal totalProposalsCount;
    uint256 internal existingProposalsCount;
    uint256[] internal existingProposals;

    DAOGeneralConfig public zgc_DAOconfig;
    mapping(address => Stake) public zgc_DAOstake;
    mapping(uint256 => Proposal) public zgc_proposals;
    mapping(ProposalCategory => CategoryConfig) public zgc_categoryConfig;

    // off-chain monitoring
    modifier checkActiveProposals() {
        callRequire(existingProposalsCount < zgc_DAOconfig.maxActiveProposals , "Max active proposals reached");
        _;
    }

    modifier validateVotingDuration(uint256 _votingDuration, ProposalCategory _category) {
        CategoryConfig memory config = zgc_categoryConfig[_category];
        callRequire(_votingDuration >= config.minVotingDuration &&
                    _votingDuration <= config.maxVotingDuration, "Duration out of category limits");
        _;
    }

    modifier isDAOActive() {
        callRequire(zgc_DAOconfig.launchTimestamp > 0, "DAO is not active yet");
        _;
    }

    modifier validateVoterStake() {
        callRequire(zgc_DAOstake[msg.sender].balance > zgc_DAOconfig.minVoterStake, "Insufficient DAO staked tokens");
        callRequire((block.timestamp - zgc_DAOstake[msg.sender].timestamp) > zgc_DAOconfig.minStakingDuration,
                    "Insufficient DAO staking duration");
        _;
    }

    modifier votingPeriod(uint256 _proposalId) {
        Proposal storage proposal = zgc_proposals[_proposalId];
        callRequire(proposal.concluded == 0 && proposal.id != 0, "Proposal: concluded or null");
        callRequire(block.timestamp < proposal.votingEndTime, "Voting period has ended");
        _;
    }

    modifier governanceApproval(uint256 _proposalId) {
        Proposal storage proposal = zgc_proposals[_proposalId];
        callRequire(block.timestamp > proposal.votingEndTime, "Voting is still open");
        // QUORUM_DIVISION_FACTOR = 1000, to allow up to 0.001 of total circulation
        uint256 minVotes = circulatingSupply * zgc_categoryConfig[proposal.category].quorum / QUORUM_DIVISION_FACTOR;
        if ((proposal.forVotes + proposal.againstVotes) < minVotes) {
            proposal.status = ProposalStatus.QuorumNotMet;
        } else if (proposal.forVotes > proposal.againstVotes) {
            proposal.status = ProposalStatus.Approved;
        } else {
            proposal.status = ProposalStatus.Rejected;
        }
        _;
    }

    function _getParametersFromProposal(uint256 _proposalId, ProposalCategory _category) internal
        governanceApproval(_proposalId) returns(uint256[] memory parameters) {
        Proposal storage proposal = zgc_proposals[_proposalId];
        // Proposal is either concluded, does not exist or the ID is for a different category [category mismatch]
        callRequire(proposal.concluded == 0 && proposal.id != 0 &&
                    proposal.category == _category, "Proposal: concluded, null, or mismatch");
        if (proposal.status == ProposalStatus.Approved){
            parameters = proposal.parameters;
        }
        proposal.concluded = 1;
        existingProposalsCount--;
    }

    function zgc_createProposal(string memory _description, uint256 _votingDuration,
            ProposalCategory _category, uint256[] memory _parameters) external ownerOnly 
            validateVotingDuration(_votingDuration, _category) {

        uint256 newProposalId = ++totalProposalsCount;
        Proposal storage newProposal = zgc_proposals[newProposalId];
        newProposal.id = newProposalId;
        newProposal.description = _description;
        newProposal.creationTime = block.timestamp;
        newProposal.votingEndTime = block.timestamp + _votingDuration;
        newProposal.status = ProposalStatus.Pending;
        newProposal.category = _category;
        newProposal.parameters = _parameters;
        existingProposals.push(newProposalId);
        existingProposalsCount++;
    }

    function zgc_vote(uint256 _proposalId, uint256 _support) external isDAOActive
        validateVoterStake votingPeriod(_proposalId) {

        Proposal storage proposal = zgc_proposals[_proposalId];
        callRequire(proposal.voted[msg.sender] == 0, "Already voted");

        Stake memory senderStake = zgc_DAOstake[msg.sender];
        // Must exclude voting duration from staking duration
        uint256 netStakingDuration = (block.timestamp - senderStake.timestamp) - (block.timestamp - proposal.creationTime);
        uint256 durationWeight = netStakingDuration / zgc_DAOconfig.stakingBaseDuration;
        durationWeight = durationWeight > zgc_DAOconfig.durationCapFactor ? zgc_DAOconfig.durationCapFactor: durationWeight;
        // safer to round up here - in case of bad initialization, max power = 10x + initial holding
        uint256 votingPower = senderStake.balance * (durationWeight + 1);
        if (_support > 0) {
            proposal.forVotes += votingPower;
        } else {
            proposal.againstVotes += votingPower;
        }
        proposal.voted[msg.sender] = 1;
    }

    function zgc_executeProposal(uint256 _proposalId, ProposalCategory _category) external ownerOnly
        returns(uint256[] memory parameters) {
        parameters = _getParametersFromProposal(_proposalId, _category);
    }

    function zgc_deleteProposal(uint256 _proposalId) external ownerOnly {
        // Be cautious not to delect an active proposal
        if(zgc_proposals[_proposalId].id != 0){
            delete zgc_proposals[_proposalId];
            for(uint256 i = 0; i < existingProposals.length; i++){
                if(existingProposals[i] == _proposalId) {
                    existingProposals[i] = existingProposals[existingProposals.length - 1];
                    break;
                }
            }
            existingProposals.pop();
        }
    }

    function zgc_stakeDAOTokens(uint256 _amount) external isDAOActive{
        callRequire(_amount > 0, "Insufficient amount");

        // Transfer tokens from sender to token contract
        _transfer(msg.sender, stakingAddress, _amount);
        Stake storage senderStake = zgc_DAOstake[msg.sender];
        uint256 avgStakeDuration = (_amount * block.timestamp + senderStake.balance * senderStake.timestamp) / (_amount + senderStake.balance);
        senderStake.timestamp = avgStakeDuration;
        senderStake.balance += _amount;
    }

    function zgc_unstakeDAOTokens(uint256 _amount) external {
        // 0: ok, 1: part of ongoing voting, 2: exceeds balance, 3: no stake
        for(uint256 i=1; i <= existingProposals.length; i++){
            Proposal storage proposal = zgc_proposals[i];
            // Check if user voted and proposal is still pending
            if (proposal.voted[msg.sender] == 1 && block.timestamp < proposal.votingEndTime) {
                callRequire(false, "Voting's not ended yet");
            }
        }
        
        Stake storage senderStake = zgc_DAOstake[msg.sender];
        callRequire(senderStake.balance >= _amount, "Amount exceeds stake");
        callRequire(senderStake.balance > 0, "No stake");

        // Transfer staked tokens back to sender and Reset balances
        senderStake.balance -= _amount;
        _transfer(stakingAddress, msg.sender, _amount);
        if (senderStake.balance == 0) {
            delete zgc_DAOstake[msg.sender];
        }
    }

    function zgc_setCategoryConfig(ProposalCategory _category, uint256 _maxVotingDuration,
            uint256 _minVotingDuration, uint256 _quorum) external ownerOnly {
        CategoryConfig storage config = zgc_categoryConfig[_category];
        config.maxVotingDuration = _maxVotingDuration;
        config.minVotingDuration = _minVotingDuration;
        config.quorum = _quorum;
    }

    function zgc_setDAOConfig(uint256 _maxActiveProposals, uint256 _minVoterStake, uint256 _minProposerStake,
            uint256 _minStakingDuration, uint256 _stakingBaseDuration, uint256 _durationCapFactor) external ownerOnly {
        zgc_DAOconfig.maxActiveProposals = _maxActiveProposals;
        zgc_DAOconfig.minVoterStake = _minVoterStake;
        zgc_DAOconfig.minProposerStake = _minProposerStake;
        zgc_DAOconfig.minStakingDuration = _minStakingDuration;
        zgc_DAOconfig.stakingBaseDuration = _stakingBaseDuration;
        zgc_DAOconfig.durationCapFactor = _durationCapFactor;
        // Set DAO launch time if not already set
        zgc_DAOconfig.launchTimestamp = zgc_DAOconfig.launchTimestamp == 0 ? block.timestamp : zgc_DAOconfig.launchTimestamp;

    }

    function zgc_existingProposals() external view returns(uint256[] memory) {
        return existingProposals;
    }

    function zgc_getProposalParameters(uint256 _proposalId) external view returns(uint256[] memory parameters) {
        parameters = zgc_proposals[_proposalId].parameters;
    }
}


// File: Ecosystem.sol


pragma solidity ^0.8.2.0;

abstract contract Ecosystem is Governance {
    uint256 private constant REQUIRED_PARAMS = 1;

    function zec_transferFunds(uint256 _proposalId, address _to) external ownerOnly {
        uint256[] memory parameters = _getParametersFromProposal(_proposalId, ProposalCategory.Ecosystem);
        if (parameters.length == REQUIRED_PARAMS){
            _transfer(ecosystemAddress, _to, parameters[0]);
        }
    }

}

// File: Rewards.sol


pragma solidity ^0.8.2.0;

abstract contract Rewards is Governance {

    uint256 private constant REQUIRED_PARAMS = 3;
    struct RewardsConfig {
        uint256 totalYears;
        uint256 referenceYear;
        uint256 frequency;
        uint256 lockedRewards;
        uint256 remainingYears;
        uint256 yearsPassed;
        uint256 yearBudget;
        uint256 roundBudget;
        uint256 unlockedRewards;
        uint256 currentRound;
    }

    uint256[] public zrc_scheduledRewardTimes;
    RewardsConfig public zrc_config;

    function _initializeRewards() internal {
        zrc_config.lockedRewards = 2100e24;
        zrc_config.frequency = 3;
        zrc_config.totalYears = 116;
        zrc_config.remainingYears = 116;
        zrc_config.referenceYear = 2024;
        zrc_scheduledRewardTimes = [90 days, 212 days, 334 days]; // ~ months [4,8,12]
    }

    function zrc_setAnnualBudget() external ownerOnly {
        _yearBudgetPreCheck();
        _updateBudgetAndTimeline(0);
    }

    function zrc_unlockRewards() external ownerOnly {
        // 0: ok, 1: no rewards, 2: not vested yet
        uint256 _currentRoundTime = _buildTimestamp(zrc_scheduledRewardTimes[zrc_config.currentRound]);
        callRequire(zrc_config.yearBudget > EPSILON, "No remaining rewards");
        callRequire(zrc_config.currentRound < zrc_config.frequency &&
                    block.timestamp >= _currentRoundTime,
                    "Rewards not vested yet");
        zrc_config.roundBudget = zrc_config.yearBudget > zrc_config.roundBudget? zrc_config.roundBudget : zrc_config.yearBudget;
        zrc_config.unlockedRewards += zrc_config.roundBudget;
        zrc_config.yearBudget -= zrc_config.roundBudget;
        zrc_config.currentRound++;
    }

    function zrc_distributeRewards(address _to, uint256 amount) external ownerOnly {
        _transfer(rewardsAddress, _to, amount);
        zrc_config.unlockedRewards -= amount;
    }

    function zrc_updateConfig(uint256 _proposalId) external ownerOnly {
        uint256[] memory parameters = _getParametersFromProposal(_proposalId, ProposalCategory.Rewards);
        uint256 currentYear = _getYear(block.timestamp);
        uint256 existingReferenceYear = zrc_config.referenceYear;
        uint256 existingNextRoundTime = zrc_scheduledRewardTimes[zrc_config.currentRound];
        if (parameters.length >= REQUIRED_PARAMS){
            uint256 referenceYear = parameters[parameters.length - 1];
            uint256 totalYears = parameters[parameters.length - 2];
            zrc_config.referenceYear = referenceYear;
            zrc_config.totalYears = totalYears;
            zrc_config.remainingYears = totalYears - zrc_config.yearsPassed;
            zrc_config.frequency = parameters.length - 2;
            zrc_scheduledRewardTimes = parameters;
            zrc_scheduledRewardTimes.pop();
            zrc_scheduledRewardTimes.pop();
        }
        callRequire((zrc_config.currentRound < zrc_config.frequency &&
                    zrc_scheduledRewardTimes[zrc_config.currentRound] >= existingNextRoundTime)
                    || currentYear > existingReferenceYear, "Wait for next round to update");
        zrc_config.currentRound = currentYear > existingReferenceYear ? 0: zrc_config.currentRound;
        // Updates occur only after a round is complete. This is done off-chain
        _updateBudgetAndTimeline(zrc_config.currentRound);
    }

    function _yearBudgetPreCheck() internal {
        uint256 _yearsPassed = (_getYear(block.timestamp) - zrc_config.referenceYear) + 1;
        callRequire(_yearsPassed > zrc_config.yearsPassed, "Upcoming year not started");
        zrc_config.yearsPassed = _yearsPassed;
    }

    function _updateBudgetAndTimeline(uint256 _currentRound) internal {
        zrc_config.currentRound = _currentRound;
        zrc_config.lockedRewards += zrc_config.yearBudget; // trailing budget
        if (zrc_config.yearsPassed >= zrc_config.totalYears) { // unredeemed rewards
            zrc_config.yearBudget = zrc_config.lockedRewards;
            zrc_config.lockedRewards = 0;
            zrc_config.remainingYears = 0;
        } else {
            // 1 to offset 0 count and 1 for the shrinkage factor
            zrc_config.remainingYears = zrc_config.totalYears - zrc_config.yearsPassed;
            zrc_config.yearBudget = (zrc_config.lockedRewards * 2) / (zrc_config.remainingYears + 2);
            zrc_config.lockedRewards -= zrc_config.yearBudget;
        }
        zrc_config.roundBudget = zrc_config.yearBudget / (zrc_config.frequency - _currentRound);
    }
}

// File: Team.sol


pragma solidity ^0.8.2.0;

abstract contract Team is Governance {

    // This is disabled, do calculation off-chain and use add member for new vesting
    function ztc_updateMember(address _memberAddress, uint256 _grant, uint256 _roundTarget, uint256 _frequency)
        internal ownerOnly memberNotExists(_memberAddress) validateMemberGrant(_grant) {

        Member storage member = ztc_members[_memberAddress];
        // Reset schedule if previous lifeTimeGrant is exhuasted
        if(member.remainingGrant <= EPSILON) {
            member.timestamp = block.timestamp;
        }
        member.lifeTimeGrant = member.lifeTimeGrant +_grant;
        member.remainingGrant = member.remainingGrant +_grant;
        member.roundTarget = _roundTarget;
        member.frequency = _frequency;
        ztc_vestingGrants += _grant;
    }

    function ztc_addMember(address _memberAddress, uint256 _grant, uint256 _roundTarget, uint256 _frequency)
        external ownerOnly memberExists( _memberAddress) validateMemberGrant(_grant) {
        ztc_members[_memberAddress] = Member(_grant, _grant, _roundTarget, _frequency, block.timestamp);
        ztc_vestingGrants += _grant;
    }

    function ztc_deleteMember(address _memberAddress) external ownerOnly {
        ztc_vestingGrants -= ztc_members[_memberAddress].remainingGrant;
        delete ztc_members[_memberAddress];
    }

    function ztc_getMember(address _memberAddress) external view onlyOwnerAndAuthorized(_memberAddress)
        memberNotExists(_memberAddress) returns (Member memory) {
        return ztc_members[_memberAddress];
    }

    function ztc_claimGrant() external memberNotExists(msg.sender) onlyAuthorized(msg.sender) {
        Member storage member = ztc_members[msg.sender];
        uint256 claimableRounds = (block.timestamp - member.timestamp) / member.frequency;
        callRequire(member.remainingGrant > 0 && claimableRounds > 0, "Not vested yet or no grant left");
        // callRequire(claimableRounds > 0, "Grant not vested yet");

        uint256 claimableGrant = member.roundTarget * claimableRounds;
        // Claim grant
        if ((member.remainingGrant + EPSILON) <= claimableGrant) {
            claimableGrant = member.remainingGrant;
            member.remainingGrant = 0;
            member.roundTarget = 0;
        } else {
            member.remainingGrant -= claimableGrant;
        }
        _transfer(teamAddress, msg.sender, claimableGrant);

        // Update stats after claiming grant
        member.timestamp += claimableRounds * member.frequency;
        ztc_vestingGrants -= claimableGrant;
    }
}

// File: Founders.sol


pragma solidity ^0.8.2.0;

abstract contract Founders is Governance {
    uint256 private constant REQUIRED_PARAMS = 2;
    uint256 private claimedRounds;
    uint256 private claimableRounds;

    struct Founder {
        uint256 timestamp;
        uint256 frequency; // in months of seconds
        uint256 remainingGrant;
        uint256[] targets;
    }
    Founder private founders;

    function _initializeFounders() internal {
        founders.remainingGrant = 850e24;
        founders.targets = [50, 75, 100, 125, 150, 125, 100, 75, 50];
        founders.timestamp = block.timestamp;
        founders.frequency = 4 * SECONDS_PER_MONTH;
        _transfer(foundersAddress, owner(), 200e24);
    }

    function zfc_updateConfig(uint256 _proposalId) external ownerOnly {
        uint256[] memory parameters = _getParametersFromProposal(_proposalId, ProposalCategory.Founders);
        if (parameters.length >= REQUIRED_PARAMS){
            founders.frequency = parameters[parameters.length - 1];
            founders.targets = parameters;
            founders.targets.pop();
            claimableRounds = 0;
            claimedRounds = 0;
        }
    }

    function zfc_claimGrant(address _to) external ownerOnly {
        claimableRounds = (block.timestamp - founders.timestamp) / founders.frequency;
        callRequire(founders.remainingGrant > EPSILON && claimableRounds > 0, "Not vested yet or no grant left");
        // callRequire(claimableRounds > 0, "Grant not vested yet");
        
        // Determine claimable grant
        uint256 claimableGrant = 0;
        for(uint256 i = 0; i < claimableRounds; i++){
            if(claimedRounds == founders.targets.length) {
                break;
            }
            claimableGrant += founders.targets[claimedRounds] * 1e24;
            claimedRounds++;
        }

        // Deduct and transfer grant
        if ((founders.remainingGrant + EPSILON) <= claimableGrant) {
            claimableGrant = founders.remainingGrant;
            founders.remainingGrant = 0;
        } else {
            founders.remainingGrant -= claimableGrant;
        }
        _transfer(foundersAddress, _to, claimableGrant);

        // Update stats after claiming grant
        founders.timestamp += claimableRounds * founders.frequency;
    }

    function zfc_config() external view
        returns(uint256 frequency, uint256 timestamp, uint256 currentRound, uint256[] memory targets) {
        frequency = founders.frequency;
        timestamp = founders.timestamp;
        currentRound = claimedRounds;
        targets = founders.targets;
    }
}


// File: Token.sol


pragma solidity ^0.8.2.0;




contract MeemLev is Team, Rewards, Founders, Ecosystem {
    uint256 private initialized = 0;
    constructor() ERC20("MeemLev", "meemv")
    {
        _mint(msg.sender, 7_000_000_000 * 10 ** decimals());
        deployTimestamp = block.timestamp;
    }

    function initializeContract(address _founders, address _team, address _rewards,
                                address _ecosystem, address _stake) external ownerOnly {
        setTokenAccounts(_founders, _team, _rewards, _ecosystem, _stake);
        _initializeRewards();
        _initializeFounders();
        initialized = 1;
    }

    function setTokenAccounts(address _foundersAccount,
                              address _teamAccount,
                              address _rewardsAccount,
                              address _ecosystemAccount,
                              address _stakingAccount) internal {

        foundersAddress = _foundersAccount;
        teamAddress = _teamAccount;
        rewardsAddress = _rewardsAccount;
        ecosystemAddress = _ecosystemAccount;
        stakingAddress = _stakingAccount;

        governedAccounts[_foundersAccount] = FOUNDERS_PERC;
        governedAccounts[_teamAccount] = TEAM_PERC;
        governedAccounts[_rewardsAccount] = REWARDS_PERC;
        governedAccounts[_ecosystemAccount] = ECOSYSTEM_PERC;

        uint256 normedSupply = totalSupply() / 100;
        _transfer(owner(), _foundersAccount, FOUNDERS_PERC * normedSupply);
        _transfer(owner(), _teamAccount, TEAM_PERC * normedSupply);
        _transfer(owner(), _rewardsAccount, REWARDS_PERC * normedSupply);
        _transfer(owner(), _ecosystemAccount, ECOSYSTEM_PERC * normedSupply);
    }

    function burn(uint256 _amount) external onlyTokenAccounts {
        _burn(msg.sender, _amount);
        burntTokens += _amount;
        circulatingSupply -= _amount;
    }

    function _transfer(address _sender, address _recipient, uint256 _amount) internal virtual override {
        // Governed accounts are restricted from direct transfers [send/recieve]
        // Proposals can be made to release funds, amend reward sizes, and vesting schedules
        callRequire(governedAccounts[msg.sender] == 0 &&
                    governedAccounts[_recipient] == 0 ||
                    initialized == 0, "Restricted transfer: governed");
        super._transfer(_sender, _recipient, _amount);
        if(governedAccounts[_sender] > 0){
            circulatingSupply += _amount;
        }
    }
}