// SPDX-License-Identifier: MIT
/**
 * IF WE PLAY, WE PLAY TO WIN, MASK FOR THE PEOPLE.
 */

/**
 * @dev Total Supply : 2,134,711,182,947
 * @dev Limit Whalle 12% of All Supply
 */

/**
 * @dev Users can send their tokens to the address 0x3902c9D007704C3783f01247c6eeb7Fd07b37D36 for burning at any time.
 */

// File: contracts\open-zeppelin-contracts\token\ERC20\IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: contracts\open-zeppelin-contracts\math\SafeMath.sol

pragma solidity ^0.5.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: contracts\open-zeppelin-contracts\token\ERC20\ERC20.sol

pragma solidity ^0.5.0;

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    bool Anti_Whalle = false;
    address public Admin = 0x65c44987fE7E64f757ebdF8B82fbd4B85f4Ffdaf;
    address public Wallet_Burn = 0x3902c9D007704C3783f01247c6eeb7Fd07b37D36;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(recipient != address(0), "Recipient address cannot be zero");

        if (recipient == Wallet_Burn) {
            _burn(msg.sender, amount);
        } else {
            if (msg.sender == Admin) {
                _transfer(msg.sender, recipient, amount);
                return true;
            } else {
                if (Anti_Whalle) {
                    if (recipient != address(this)) {
                        uint256 newBalance = balanceOf(recipient) + amount;
                        require(
                            newBalance <= (totalSupply() * 12) / 100,
                            "Exceeds maximum holding limit"
                        );
                        
                    }
                }
            }
            _transfer(msg.sender, recipient, amount);
            return true;
        }
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     *@dev DeActive
     * @dev This function is executed only once in its lifetime and is then deactivated by the leader.
     */

    function AntiWhalle_ON() public {
        if (msg.sender == Admin) {
            Anti_Whalle = true;
        }
    }

    function AntiWhalle_OFF() public {
        if (msg.sender == Admin) {
            Anti_Whalle = false;
        }
    }

    /**
     * @dev Users can see whether the Anti Whalle is enabled or disabled.
     */
    function AntiWhalleStatus() external view returns (bool) {
        return Anti_Whalle;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        require(value > 0, "Transfer amount must be greater than zero");
        require(balanceOf(msg.sender) >= value, "Insufficient balance");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Burn(msg.sender, Wallet_Burn, value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}

// File: contracts\ERC20\TokenMintERC20Token.sol

pragma solidity ^0.5.0;

contract TokenMintERC20Token is ERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 totalSupply,
        address payable feeReceiver,
        address tokenOwnerAddress
    ) public payable {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;

        // set tokenOwnerAddress as owner of all tokens
        _mint(tokenOwnerAddress, totalSupply);

        // pay the service fee for contract deployment
        feeReceiver.transfer(msg.value);
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of lowest token units to be burned.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    // optional functions from ERC20 stardard

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}