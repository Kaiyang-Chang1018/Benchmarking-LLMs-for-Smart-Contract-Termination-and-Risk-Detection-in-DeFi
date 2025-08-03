// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Token_TEX is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 private _totalSupply;
    address public owner;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => bool) private frozenWallets;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        _totalSupply = initialSupply * 10 ** uint256(decimals);
        owner = msg.sender;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return balances[account];
    }

    function isFrozenWallet(address account) external view returns (bool) {
        return frozenWallets[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(!frozenWallets[msg.sender], "ERC20: sender is frozen");
        require(!frozenWallets[recipient], "ERC20: recipient is frozen");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balances[msg.sender] >= amount, "ERC20: insufficient balance");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner_,
        address spender
    ) external view override returns (uint256) {
        return allowances[owner_][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        require(!frozenWallets[msg.sender], "ERC20: approver is frozen");

        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(!frozenWallets[sender], "ERC20: sender is frozen");
        require(!frozenWallets[recipient], "ERC20: recipient is frozen");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            allowances[sender][msg.sender] >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        require(balances[sender] >= amount, "ERC20: insufficient balance");

        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burn(uint256 amount) external returns (bool) {
        require(amount > 0, "ERC20: amount must be greater than zero");
        require(balances[msg.sender] >= amount, "ERC20: insufficient balance");

        balances[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    function freezeWallet(address account) external onlyOwner {
        require(!frozenWallets[account], "ERC20: account is already frozen");
        frozenWallets[account] = true;
    }

    function unFreezeWallet(address account) external onlyOwner {
        require(frozenWallets[account], "ERC20: account is not frozen");
        frozenWallets[account] = false;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "ERC20: new owner is the zero address");
        owner = newOwner;
    }

    function mint(uint256 amount) external onlyOwner returns (bool) {
        uint256 mintAmount = amount * 10 ** uint256(decimals);
        _totalSupply += mintAmount;
        balances[owner] += mintAmount;
        emit Transfer(address(0), owner, mintAmount);
        return true;
    }
}