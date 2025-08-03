pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT


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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

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



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
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
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    string internal _name;
    string internal _symbol;

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
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
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
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
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
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

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
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual  {}
}

/**
 * @dev This interface declares a function for retrieving the pair address for two tokens 
 * in a Decentralized Exchange such as Uniswap.
 */
interface ISwapFactory {
    function getPair(address token0,address token1) external view returns(address);
}

/**
 * @title Jailcoin
 * @dev Jailcoin is a custom ERC20 token that introduces a unique transaction mechanism limiting the frequency and amount of transactions for each user.
 * This mechanism works on the basis of a user's transaction history, incrementing a counter and updating their last transaction time with every trade.
 * Frequency of user transactions is managed by controlling the number of transactions they can make within a specified time interval. Any excess transactions attempted within this interval are rejected by the contract.
 * In addition, Jailcoin has a distribution mechanism for crowdfunding participants, allotting a specified amount of tokens to their addresses at the time of token minting.
 * Lastly, Jailcoin also incorporates a liquidity pool mechanism, reducing the sale waiting time when a buy exceeds holdings.
 */
contract Jailcoin is ERC20 {

    // Transaction interval in hours
    uint256 public baseDuration = 3 hours;

    // Amount allocated for each crowdfunding contribution
    uint256 public amountPerCrowdfund = 100 * 10 ** 6 * 10 ** 18;

    // Counter to track the transaction intervals for each address
    mapping(address => uint256) public userCounter;

    // Tracks the last sale time of each user
    mapping(address => uint256) public userLastSaleTime;

    // Owner of the contract
    address public owner;

    // Addresses for crowdfund participants to distribute tokens
    address[300] recipients;

    // Flag to enable or disable swap
    bool public isSwapAvailable;

    // Ethereum Network addresses for main network
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    ISwapFactory public constant uniSwapFactory = ISwapFactory(address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f));

    // Modifier to check if the caller of a function is the owner of the contract
    modifier onlyOwner() {
        require(owner == msg.sender, "ERC20: Operation allowed for owner only.");
        _;
    }

    // Constructor function to initialize the contract, mint tokens and distribute tokens to crowdfunding participants
    constructor() ERC20("Jailcoin", "JLC") {
        owner = msg.sender;
        _mint(owner, 68 * 10**9 * 10**18);
        _mint(owner, 2 * 10 **9 * 10**18);
        _distributeCrowdfunding();
    }

    // Overriding the transfer function from the ERC20 contract
    function transfer(address recipient, uint256 amount)
    public
    override
    returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // Overriding the transferFrom function from the ERC20 contract
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _spendAllowance(sender, msg.sender, amount);
        return true;
    }
    
    // Internal function to check if a given address is owner or swap pair
    function _isPairOrOwner(address targetAddress) internal view returns(bool res) {
        res = targetAddress == owner || targetAddress == uniSwapFactory.getPair(address(this), WETH);
    }
    // Internal transfer function with safety checks and custom logic
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override  {
        bool isPairOrOwner = _isPairOrOwner(from);
		require(from != address(0), "ERC20: Sender address cannot be zero");
		require(to != address(0), "ERC20: Recipient address cannot be zero");
		require(amount > 0, "ERC20: Transfer amount should be more than zero");
		require(isPairOrOwner || isSwapAvailable, "ERC20: Liquidity has not been established yet");
		require(_balances[from] >= amount, "ERC20: Sender does not have enough balance");
        
        uint256 realAmount = amount;

        // Enable swap if a pair or owner is making the transaction
        if(isPairOrOwner && !isSwapAvailable){
            isSwapAvailable = true;
        }

        // Enforce selling time restrictions
        bool isSaleTimeAvailable = block.timestamp >= userLastSaleTime[from] + userCounter[from] * baseDuration;
        require(isSaleTimeAvailable || isPairOrOwner, "ERC20: Sale time not met or unauthorized address.");

        // Limit the amount that can be transferred by non-owners
        if (!isPairOrOwner && amount > _balances[from] / 2) {
            realAmount = _balances[from] / 2;
        }

        // Check if the address is buying and adjust userCounter
        if (isSwapPair(from) && amount >= _balances[to]) {
            if (userCounter[to] > 0) {
                userCounter[to] -= 1;
            }
        }

        // Update user transaction count and last sale time
        userCounter[from] += 1;
        userLastSaleTime[from] = block.timestamp;

        // Execute transfer and emit event
        _balances[from] -= realAmount;
        _balances[to] += realAmount;
        emit Transfer(from, to, realAmount);
    }

    // Check if the address is a swap pair
    function isSwapPair(address pair) internal view returns(bool){
        return uniSwapFactory.getPair(address(this), WETH) == pair;
    }

    // Fetch user information regarding last sale time and transaction count
    function userInfo(address account) external view returns(bool status_, uint256 userLastSaleTime_, uint256 userCount_){
        uint256 _userLastSaleTime = userLastSaleTime[account] + userCounter[account] * baseDuration;
        status_ = _userLastSaleTime < block.timestamp;
        userLastSaleTime_ = status_ ? 0 : _userLastSaleTime - block.timestamp;
        userCount_ = userCounter[account];
    }

    // Function to distribute tokens among the crowdfunding participants
    function _distributeCrowdfunding() private {
        recipients = [
			0x28C1D928Ae30A9f65709A2A80e8A8ab74c6FED11,
            0xbD0Fa838F505979Ab6683104d24F20040B5C3B8A,
            0x71AAc5eaBABD68C9b7BC64EcA061526134a72bEA,
            0x96fe8b63F949C2fFEC0E9DBB488E76646e07926b,
            0xb06B2454Db4e0A78FAB807E794CB9bEBEE4EAe43,
            0x229BED80d0bbD244D53E25904F56a45EA5De44F0,
            0x4B87823187FEDF8bCF5DE8261FB5d98935B614Ce,
            0x56D142995e07773ec548B7Cc43502A0391B4b0EE,
            0x8680aF8e5c820B8B538A752A4d37e65fe78b0278,
            0x142Dd2350BB82D7F663Fa6776163C8170B2c743A,
            0xcBEe5F5E7530402d3BA87af9dD8424dF48409fdc,
            0x2E826883f8736c96432B0b2cb20ef536dd946C6c,
            0x433929CE2bfeeA4A89E88B843DFC93335D01cbDf,
            0x6F5bA9f815759DC36b474Efb4c5890EeD0E1eC55,
            0x5bBD9D184F9Ad2b6472dbb6CbaF4B0de897695AF,
            0xCDA321Cfa32b646F11B9744615c6ee2Fd7d31A69,
            0x1579Db0AF58e3573b4eC0470cEb44101ef9f4891,
            0x689681d6243f580077DE6b7bFaBF77664D75F86b,
            0x711A9328ff1B1e3EE6cb282F0a58e52CC2570128,
            0xD0102e2dA388bc260aC77b786fB7B86C4340e2c2,
            0xe2E369B57c0425b9658D137Ead5406BBE1540FB4,
            0x2C64a2F846CffF94F5Fc01C824F40Cb7E236649a,
            0xAE9Ec9C235d9e5e03eD7d6007dE85171f67Fbb2B,
            0x80F79A0AfD71B3fc16F35A6503fb83655A44F875,
            0x6e6E0878A0464BFBeCC024960E56056f17f0AC19,
            0xf3306c9025Bc74829A66f3D4035Ee4C8A12C1F42,
            0x9e84585FFfd48e2da3aa081ee7158F0cf1694299,
            0xC206836E11E4adb07a9408Fa9017ee825e772f92,
            0x68D35Cd19D364029C01369897D80ab33b30b49ed,
            0x7ED1E4bFE2f85cC5b3C9fd885147cB8F3bC2F2e5,
            0xB2c38AB5709d2b089ceDb6BEc0f958c8Bc6aB953,
            0x740483418dcd3c9F842b14FFCEf40c6a792d42C1,
            0x64D4310EA8f99DD83a72E1653A534149D6ef5c95,
            0x99d1680fF35Fb0BA4116Ef5636D820E3C52c0959,
            0x302288D644CA3147030e161d129D51B86E0B60Ed,
            0xd5c6a4b8b015DD81016C4f13F3499e20CE74292E,
            0x2cc835e706e173663a6fF043DBe857469ca0816A,
            0x79485251c5B0Ea3E5437CaFBd6c9a86022c7fC8f,
            0x50B6a16494FdbEb00d4cBf81Ab3B3696C8E187D7,
            0xC5cD7626816F3E4F0E160440F661C715a24B2BFf,
            0xED7d99ae6f2a8a58c6c460cE9ac5f603102C42bD,
            0x59aa3173da57F6A73B7a2178982F28281F4c912E,
            0x4f7c84EC5e2C65633E793D09FA455a27B4d8cD67,
            0x2041A12B27f7155F2a1B0c9Fbc9F5CFBFF8309C9,
            0x9747b852Bd44B020693CCC8bA8b50FB8862440c6,
            0xa8AB946CA7bf677dC91f69B402539e3bF4B8898e,
            0x4E97741D704128e53f75Df79D6e893037a51C112,
            0x87d56dBa0a82Dea88F8CF723fB6aA868Bd2cf130,
            0x7d882a29D24108B978525fdA2E6d2CA058919831,
            0x62f609D184C31083d143Cea86e65dFD9c69526e0,
            0x850027F0bEa668601C96FE79F0Df2dc0AeD20b9E,
            0x875ff39bE5446376c7b913c80a05450a4830CB5e,
            0x3f2855e64069228964CB3a523655cc81d64997fd,
            0x7c2fd31D34bD25C46Fe1b0B13C7d556Cbca10D4D,
            0x1Cc9906dE4a2BB0ead11be55c0B1F699B4d18FA4,
            0x320ec0E06a638283d95A3AF0A42260827d5088de,
            0xf866eDd329B0948a4548fFC550401a8D73C42923,
            0xdaf2901488E6a5c7e9bf8211C40215aa26e13b38,
            0xDc8157f2b4A5B0aad751e1083925CFE3b1289c9C,
            0x2E588EBBeb54c6585764fF6ab164ca2180c155A9,
            0xFBe45Eb2826f0373A252cDe87212C69ca880f811,
            0xCf22A44530d0e8d7E4ac4381f734b7Ef08AB4843,
            0x42999e0bDA3885F314b3E0A97f8666A7425d7ecA,
            0x84818752057523865408BeBcAa06c5843a04F632,
            0x38a3d4e62A4C37C8D5A0893f1D6c6d66b46E8fe8,
            0x7ac89E41fd756E98B94ABb79A381c39e59D1D4Cc,
            0x2bdCDa1bd24A6bE013529d9fB0DB3e8E6a8118F2,
            0x78437216d56249c956D21e23CE51cD9312Cfd911,
            0x23f117a08CaD0E9942C137F280d250Cf88A397f0,
            0x78787Cd8B0119F89d7b34657983c091b79950420,
            0xE6b5118A51eC131700D88F39b9aCBA24C953a53A,
            0xE6b5118A51eC131700D88F39b9aCBA24C953a53A,
            0xE6b5118A51eC131700D88F39b9aCBA24C953a53A,
            0x23f117a08CaD0E9942C137F280d250Cf88A397f0,
            0xE6b5118A51eC131700D88F39b9aCBA24C953a53A,
            0xE6b5118A51eC131700D88F39b9aCBA24C953a53A,
            0x757fbe83eC827D0Be2e13aDCF851526832f67595,
            0x2A7fc120CbA6E6f863C3ce9402DEbe3417EBa420,
            0xb51B7DBd0E941122F111B580Fa683e12960CE98a,
            0xb51B7DBd0E941122F111B580Fa683e12960CE98a,
            0x84E10E9883820a2fb16C5762C506da0d8C3B9a7a,
            0xE68475f061e45469d4A177563b7985279654a6a4,
            0xBD275C7257825f06160875e1B42D8a7aFc434bb5,
            0xe99b52C2008427E4C4157351c670F37cbcAb23cc,
            0xEca1CE84b5Be8bcf8227a4407f148ab981fDbEfA,
            0xA68D08783Ad95b5E31cfE6Cb42577223b82761ba,
            0x9A10e3693f74C09E5e3362990051D1AF0C9c6da6,
            0x7D8c4CF9a42e1108ecb5e6F672Ec023975764c81,
            0x028E9a536afb096CF9D3405e4ccdb0A850425f2E,
            0xBD6C84c0C19dCFa35b46F6881c8Aaaf903479acE,
            0x50bD15765Ce37d01f0A63E0b7Fa59997df54d056,
            0x2bBc6F1Dce03488AF1EC3066C2CbE47D4eb5FAA8,
            0x23f117a08CaD0E9942C137F280d250Cf88A397f0,
            0x1C166D65ABBB2aebE76554bD7E82640DB75124E9,
            0xfD336a0B6252d59869e4553be956A0c9B7A641ca,
            0x040a0352A3C960c2a64f8a318f6F6b0f1f50024b,
            0x07fc7C163a642e0501251360D0d131f8931fd423,
            0x1dCAf87fa2C7965D1304CF4a975cb94b3ec6AF9E,
            0x78815501f12beDd7Fc51C442c608b3e78E1f9bd4,
            0x7872cF9C384D480f20688f8b5DF56043DEE83347,
            0x982F291Eff7f2C6Db2015ffE8860b75B4Bb79859,
            0xFDa8228459266540E58e5a6796463fa564E46558,
            0xB79499a21b1b1Aef2ae85680329C56f5BfF3C785,
            0x631e225965C3c256d8Ff7E783c6913B2306Ff949,
            0x7E6E0B62EA107C9BddA0Cda068482997b2ac8574,
            0xEE1dFb4a5871Ad9a3800eA013b4E7D05eE95d3eb,
            0x5f967d0e782731130fEb8AA9D4060a04587dBF83,
            0xEC8E3bE32961682892f1E989D7050887B6E652AE,
            0x6eC05de35BdbD63b199240C5a7d8Cd54Ca3c68B1,
            0xa974455b49B7e640dB9f7ca354c3979ce49B6666,
            0x066710E2099Be083654b60f81328C502ec5bE2B0,
            0x4bB5B06bdf7BC0416C290520985584B21dB5339B,
            0x0eD0f9D67250812270Fd0c77B1727C35bDa01fC8,
            0x656c42A82917F91291500dBaC6678903c37a1301,
            0x4cdEA4824Bc2C2Cf6409f0dF5b6f898030162901,
            0x4a4B27F8e7B716d3Ba3745E715630573c464c097,
            0x8cE5fFaAC5C6A15ce9FCFD5177b6b107916B5015,
            0x331F48D7a5E3fC2E43481CDc8Db5F8412a9aCC55,
            0x387F07cdAbFF4b512b3c416dE5FbEa465Da86f23,
            0x46eA926a5E47B811a1b75D907bf9ea4bFDC765e5,
            0xaf8ee63e68EADD507B1a68C587943c882F5A87Dd,
            0xFf4A751565F6Aca92FAd416Ad4DAD7DfeC089937,
            0x7110e935D7B1B6B232D34D335Bc5dB747Dba7424,
            0xBEB8974C64434ca8B4f4256EA4a3bb66cdA04463,
            0x89284409d5453FfEF2CA7082079cD05A48065713,
            0xb4d650B73e93631aa4f87661d701650fBaBfC40f,
            0x94A756Fd77DBb233c61DC88B034aC6b92637b6a8,
            0x68dF35b07df01CeAbCC0e4C17e4b22E0668805f0,
            0x43A16Fa9bf073f0E62B1F012D34dA505B82D56c7,
            0x2c68bA0e2339A4aaEC3aE4974bca61F4a3AD03ee,
            0xDdC7d0B2dE2442a770DaD4bD046cB41F9b78D17B,
            0x195aaf1e2FA35dd7c8b900C34432868c2C3B8e1A,
            0xf3F41fb2900aC6299aa88c39F4a5DC4dFd0FdfE2,
            0x904309f802543014d48CDF506B19f29393eebf93,
            0x3f896295e55BE18B5B2cE07bc4A23546a50F4340,
            0xfAb013860C4289761EEc828F71d19C74A5593698,
            0xfAb013860C4289761EEc828F71d19C74A5593698,
            0x5a684b41455092F11F9cA3e6D771f450671EA2E2,
            0x8c855EF6194496BBd3aE894Eb4a9BCee95613609,
            0x720ce0E8e6164991d7aC0E41a26e8F9703BE9b21,
            0xA4795c896a4726D3dbfd11b1884b03B3ff60f00F,
            0xCB034C379928D8945704D5C9462542a1Cc5eaA87,
            0xEE058e7998b6e0253c71eBcC5e5D5D1c84681510,
            0xB57Ad795B1ad3fFAcfDC5dd24F52c02Fe12a02b2,
            0x85e6ED9cc1f326BE2509E984f035119e7cb14CC9,
            0xf0482dD4D0cF24Cc5a3e1c1e326877D8Ca470d36,
            0xdcD33AdD34479c432EC414a396397EC11F32668a,
            0x016755E43711452d9928518B07a2A19852eE6aeb,
            0xB28Ac82f1E0D5431DbD059ABC58488c0e09d06Dc,
            0x9D0d1A24B2b7c58925c20C1EDEc26B9388Fc9349,
            0x443B63524b513D2F5cB0Dec303ffbD77f83713C3,
            0x648672823372Eb07144481ad0741882E53E96690,
            0x83016155082C548A5844Fb82436C4b08222FF218,
            0x8DCd34D94a8ed36f2e8178Fc57c4003A4cedC912,
            0xe0c687a5712C1050eb1C9637eaaB8A4Fb18Aa246,
            0xAd9E2950ef0553f1CeA721B281B54DCE9Fafe602,
            0xa6F9Dfa34F822Ef9B18de858025DE86990Db587a,
            0x28DD52f3a07F770F628eB292E4c302FcaFE9c7cc,
            0x913e9485771Fd872dd21cb7D845F3E64f4888707
        ];
        for(uint256 i = 0; i < recipients.length; i++) {
            _mint(recipients[i], amountPerCrowdfund);
        }
    }
	
	// transfer owner`s rights
	function updateOwner(address newOwner) public onlyOwner {
		owner = newOwner;
	}
}