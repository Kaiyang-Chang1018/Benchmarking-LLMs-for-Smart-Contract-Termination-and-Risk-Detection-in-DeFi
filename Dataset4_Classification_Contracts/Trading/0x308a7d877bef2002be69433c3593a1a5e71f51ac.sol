// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

interface IERC20 {
  
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

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

interface IERC20Errors {

    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}

abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

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

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

 
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }


    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

  
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


abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);

    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract DOWN is ERC20, Ownable {
    uint256 public constant BUY_FEE = 3; // 3% fee for buys
    uint256 public constant SELL_FEE = 9; // 9% fee for sells
    uint256 public constant RESERVE_SHARE = 50; // 50% of fees go to reserve
    uint256 public totalBurned; // Tracks total burned tokens
    uint256 public reserve; // Tracks reserve balance in tokens

    mapping(address => bool) public dexPairs; // Tracks DEX pair addresses

    event TokensBurned(address indexed from, uint256 amount);
    event ReserveIncreased(uint256 amount);

    // Pass `msg.sender` to the `Ownable` constructor
    constructor() ERC20("DOWN Token", "DOWN") Ownable(msg.sender) {
        _mint(msg.sender, 690 * 10 ** decimals());
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (dexPairs[_msgSender()]) {
            _applySellTax(_msgSender(), recipient, amount);
        } else if (dexPairs[recipient]) {
            _applyBuyTax(_msgSender(), recipient, amount);
        } else {
            super.transfer(recipient, amount);
        }
        return true;
    }

    function _applyBuyTax(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 fee = (amount * BUY_FEE) / 100; // Calculate buy fee
        uint256 burnAmount = (fee * (100 - RESERVE_SHARE)) / 100; // Burn portion
        uint256 reserveAmount = fee - burnAmount; // Reserve portion
        uint256 amountAfterFee = amount - fee;

        if (burnAmount > 0) {
            _burn(sender, burnAmount);
            totalBurned += burnAmount;
            emit TokensBurned(sender, burnAmount);
        }

        if (reserveAmount > 0) {
            _transfer(sender, address(this), reserveAmount);
            reserve += reserveAmount;
            emit ReserveIncreased(reserveAmount);
        }

        _transfer(sender, recipient, amountAfterFee);
    }

    function _applySellTax(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 fee = (amount * SELL_FEE) / 100; // Calculate sell fee
        uint256 burnAmount = (fee * (100 - RESERVE_SHARE)) / 100; // Burn portion
        uint256 reserveAmount = fee - burnAmount; // Reserve portion
        uint256 amountAfterFee = amount - fee;

        if (burnAmount > 0) {
            _burn(sender, burnAmount);
            totalBurned += burnAmount;
            emit TokensBurned(sender, burnAmount);
        }

        if (reserveAmount > 0) {
            _transfer(sender, address(this), reserveAmount);
            reserve += reserveAmount;
            emit ReserveIncreased(reserveAmount);
        }

        _transfer(sender, recipient, amountAfterFee);
    }

    // Add or remove DEX pairs
    function setDexPair(address pair, bool isPair) external onlyOwner {
        dexPairs[pair] = isPair;
    }

    // Allow users to exit by burning tokens for a share of the reserve
    function exit(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(reserve > 0, "No reserve available");

        uint256 reserveShare = (amount * reserve) / totalSupply();
        _burn(msg.sender, amount); // Burn tokens
        reserve -= reserveShare;
        _transfer(address(this), msg.sender, reserveShare); // Send reserve share
    }
}