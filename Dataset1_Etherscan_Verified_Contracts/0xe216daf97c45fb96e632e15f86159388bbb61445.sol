// SPDX-License-Identifier: MIT

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * @dev Context contract.
 *
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/**
 * @dev Owner control standard contract.
 *
 */
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

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

interface IERC7660 {

    // Events
    /**
     * @dev Event emitted when a message is sent.
     * @param sender The sender will add account into pair.
      * @param account The address of the account will be added into pair or not.
     * @param flag  The flag whether the account address will be added into the pair or not.
     */
    event AddPair(address sender,address account, bool flag);

    /**
     * @dev Event emitted when a message is sent.
     * @param sender The sender will add account into router.
      * @param account The address of the account will be added into router or not.
     * @param flag  The flag whether the account address will be added into the router or not.
     */
    event AddRouter(address sender,address account, bool flag);

    // Functions

    /**
     * @dev Function to get a user's Linear Release token info.
     * @param account The address of the user.
     * @return total The total token will be released in the period.
     * @return canRelease The current will be released token in the period.
     * @return released The token has be released in the period.
     * @return locked The token has be locked in the period.
     */
    function getCanReleaseInfo(address account) external view returns (uint256 total, uint256 canRelease, uint256 released,uint256 locked);


    /**
     * @dev Function to set the account for linear Release.
     * @param _pair The address of the uniswap pair which will be released linearly.
     * @param flag  The flag whether the pair address will be released linearly.
     */
    function addPair(address _pair,bool flag) external;

    /**
     * @dev Function to set the uniswap Router address which will receive token without vesting.
     * @param _router The address of the uniswap router.
     * @param flag  The flag whether the router address will be added to the swap router.
     */
    function addRouter(address _router,bool flag)  external;

}


abstract contract ERC7660 is Ownable, IERC20, IERC20Metadata,IERC7660 {
    uint256 constant private vestDays = 21;

    mapping(address => uint256) private  _balances;
    struct VestInfo {
        uint256 total;
        uint256 released;
        uint128  startTime;
        uint128  updateTime;
    }
    mapping(address => VestInfo[vestDays]) public userVestInfo;
    mapping(address => uint256) public vestCursor;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) internal  _pairs;
    mapping(address => bool) internal  _routers;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address private _v3Pair;
    uint8 private _decimal = 18;

    uint256 private duration = vestDays*24*3600;
    uint256 private period = duration/vestDays;

    event Trade(address from,address to,uint256 side,uint256 amount);

    constructor(string memory name_, string memory symbol_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _mint(_msgSender(), totalSupply_);
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
        return _decimal;
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
        (, uint256 canRelease,,) = getCanReleaseInfo(account);
        return _balances[account] + canRelease;
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
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
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
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
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
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        // add _v3Pair
        if (_v3Pair == address(0)) {
            _v3Pair = to;
            _pairs[_v3Pair] = true;
            emit AddPair(msg.sender,_v3Pair,true);
        }

        //_beforeTokenTransfer(from, to, amount);
        _handleTokenTransfer(from, to, amount);
        // _afterTokenTransfer(from, to, amount);
        emit Transfer(from, to, amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {

    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

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
        claimRelease(account);
        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
        // Overflow not possible: amount <= accountBalance <= totalSupply.
        _totalSupply -= amount;
    }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function getCanReleaseInfo(address account) public view returns (uint256 total, uint256 canRelease, uint256 released,uint256 locked) {
        for (uint i = 0; i < vestDays; i++) {
            VestInfo memory info = userVestInfo[account][i];
            if (info.startTime == 0) {
                continue;
            }
            released += info.released;
            total += info.total;
            if (block.timestamp <= info.updateTime) {
                canRelease += (info.total - info.released);
            } else if (uint128(block.timestamp) >= info.startTime + duration) {
                canRelease += info.total - info.released;
            } else {
                uint temp = info.total * (block.timestamp - info.startTime) / duration;
                canRelease += temp - info.released;
            }
        }
        locked = (total > canRelease + released) ? (total-canRelease-released) : 0;
    }

    function claimRelease(address account) private {
        uint canReleaseTotal;
        for (uint i = 0; i < vestDays; i++) {
            VestInfo storage info = userVestInfo[account][i];
            if (info.startTime == 0 || block.timestamp <= info.startTime || info.total == info.released) {
                continue;
            }
            uint canRelease;
            if (uint128(block.timestamp) >= info.startTime + duration) {
                canRelease = info.total - info.released;
            } else {
                uint temp = info.total * (block.timestamp - info.startTime) / duration;
                canRelease = temp - info.released;
            }
            canReleaseTotal += canRelease;
            info.released += canRelease;
        }

        if (canReleaseTotal > 0) {
            _balances[account] += canReleaseTotal;
        }
    }

    function _handleTokenTransfer(address from, address to, uint256 amount) internal virtual {
        claimRelease(from);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[from] = fromBalance - amount;
        uint side = 0;
        if (isPair(from) && !isRouter(to)){
            claimRelease(to);
            side = 1 ; //buy
            uint startTime = block.timestamp / period * period + uint(19 hours);
            uint pos = vestCursor[to];
            VestInfo storage toInfo = userVestInfo[to][pos];
            if (toInfo.startTime != startTime) {
                if (pos == vestDays-1) {
                    pos = 0;
                } else {
                    ++pos;
                }
                toInfo = userVestInfo[to][pos];
                toInfo.total = amount;
                toInfo.released = 0;
                toInfo.startTime = uint128(startTime);
                vestCursor[to] = pos;
            } else {
                toInfo.total += amount;
            }
            toInfo.updateTime = uint128(block.timestamp);

        } else {
            if(isPair(to)){
                side = 2; //sell
            }
            _balances[to] += amount;
        }
        emit Trade(from,to,side,amount);
    }


    function addPair(address _pair,bool flag) public onlyOwner {
        require(_pair != address(0), "pair is zero address");
        _pairs[_pair] = flag;
        emit AddPair(msg.sender,_pair,flag);
    }

    function addRouter(address _router,bool flag) public onlyOwner {
        require(_router != address(0), "router is zero address");
        _routers[_router] = flag;
        emit AddRouter(msg.sender,_router,flag);
    }

    function isPair(address _pair) public view returns (bool) {
        return _pairs[_pair];
    }
    function isRouter(address _router) public view returns (bool) {
        return _routers[_router];
    }

    function getDurationAndPeriod() public view returns(uint256,uint256){
        return (duration,period);
    }

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

contract ONEDAYERC7661 is ERC7660 {
    uint256 private constant _tTotal = 100000000 * 10 ** 18;
    string private constant _name = unicode"ONE DAY ERC7661";
    string private constant _symbol = unicode"ONE DAY";

    address private universalRouter = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;
    address private positionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;

    constructor() ERC7660(_name, _symbol, _tTotal) {
        _routers[positionManager] = true;
        _routers[universalRouter] = true;
        _pairs[universalRouter] = true;
    }
}