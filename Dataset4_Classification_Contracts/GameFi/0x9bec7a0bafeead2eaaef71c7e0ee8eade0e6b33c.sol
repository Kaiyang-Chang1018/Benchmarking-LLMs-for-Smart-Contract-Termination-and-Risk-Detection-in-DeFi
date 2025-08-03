/*
    web:https://nono.finance
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) { return a + b; }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) { return a - b; }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) { return a * b; }
    function div(uint256 a, uint256 b) internal pure returns (uint256) { return a / b; }
}

library TransferHelper {
    function safeApprove(address token, address to, uint256 value) internal { (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value)); require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper::safeApprove: approve failed'); }
    function safeTransfer(address token, address to, uint256 value) internal { (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value)); require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper::safeTransfer: transfer failed'); }
    function safeTransferFrom(address token, address from, address to, uint256 value) internal { (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value)); require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper::transferFrom: transferFrom failed'); }
    function safeTransferETH(address to, uint256 value) internal { (bool success, ) = to.call{value: value}(new bytes(0)); require(success, 'TransferHelper::safeTransferETH: ETH transfer failed'); }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IRouter {
    function WETH() external view returns (address);
    function factory() external view returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IPair {
    function totalSupply() external view returns (uint256);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
    function _msgData() internal view virtual returns (bytes calldata) { return msg.data; }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() { _transferOwnership(_msgSender()); }
    modifier onlyOwner() { _checkOwner(); _; }
    function owner() public view virtual returns (address) { return _owner; }
    function _checkOwner() internal view virtual { require(owner() == _msgSender(), "Ownable: caller is not the owner"); }
    function renounceOwnership() public virtual onlyOwner { _transferOwnership(address(0)); }
    function transferOwnership(address newOwner) public virtual onlyOwner { require(newOwner != address(0), "Ownable: new owner is the zero address"); _transferOwnership(newOwner); }
    function _transferOwnership(address newOwner) internal virtual { address oldOwner = _owner; _owner = newOwner; emit OwnershipTransferred(oldOwner, newOwner); }
}

abstract contract ERC20 is Context, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) { _name = name_; _symbol = symbol_; _decimals = decimals_; }
    function name() public view virtual override returns (string memory) { return _name; }
    function symbol() public view virtual override returns (string memory) { return _symbol; }
    function decimals() public view virtual override returns (uint8) { return _decimals; }
    function totalSupply() public view virtual override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view virtual override returns (uint256) { return _balances[account]; }
    function transfer(address to, uint256 amount) public virtual override returns (bool) { address owner = _msgSender(); _transfer(owner, to, amount); return true; }
    function allowance(address owner, address spender) public view virtual override returns (uint256) { return _allowances[owner][spender]; }
    function approve(address spender, uint256 amount) public virtual override returns (bool) { address owner = _msgSender(); _approve(owner, spender, amount); return true; }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) { address spender = _msgSender(); _spendAllowance(from, spender, amount); _transfer(from, to, amount); return true; }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) { address owner = _msgSender(); _approve(owner, spender, allowance(owner, spender) + addedValue); return true; }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked { _approve(owner, spender, currentAllowance - subtractedValue); }
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked { _balances[from] = fromBalance - amount; _balances[to] += amount; }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked { _balances[account] += amount; }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked { _balances[account] = accountBalance - amount; _totalSupply -= amount; }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked { _approve(owner, spender, currentAllowance - amount); }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

abstract contract TOKEN is ERC20, Ownable {
    using SafeMath for uint256;

    address public WETH;
    address public LP;

    address public routerAddr;
    address public marketingAddr;

    bool    public launched;
    bool    private _swapping;
    uint256 public swapThreshold = 500 * (10**18);

    mapping(address => bool) public _isExcludedFromFees;
    mapping(address => bool) public _isBlacklisted;

    uint256 private offset = 0;
    uint256 public round = 1;
    uint256 public prizePoolCondition = 1 ether; // First round, prize pool need to reach 1 ETH
    uint256 public prizePoolConditionIncrease = 0.5 ether; // 0.5 ETH more than the previous round
    uint256 public holdCondition = 100 * (10**18); // First round, need to hold 100 TTT
    address[] public waitingList;
    mapping(address => uint256) public waitingIdx; // waitingList index, first index is 1
    mapping(address => bool) public _hasOut; // Any out will not be allowed to participate in the lottery.

    address[] public _winners;

    modifier lockSwap() { _swapping = true; _; _swapping = false; }

    event Winning(address indexed to, uint256 amount);

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address routerAddr_,
        address marketingAddr_
    ) ERC20(name_, symbol_, decimals_) {
        WETH = IRouter(routerAddr_).WETH();
        routerAddr = routerAddr_;
        marketingAddr = marketingAddr_;

        _isExcludedFromFees[marketingAddr] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(0xdead)] = true;

        _mint(msg.sender, totalSupply_);
        _approve(address(this), routerAddr, ~uint256(0));
    }

    receive() external payable {}

    function launch() external payable onlyOwner { 
        LP = IFactory(IRouter(routerAddr).factory()).getPair(address(this), WETH);
        launched = true;
    }

    function excludeFromFees(address[] memory accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function set_marketingAddr(address _marketingAddr) public onlyOwner {
        marketingAddr = _marketingAddr;
    }

    function set_swapThreshold(uint256 _swapThreshold) public onlyOwner {
        swapThreshold = _swapThreshold;
    }

    // For emergency
    function sweep(address token_, uint256 amount) public onlyOwner {
        if (token_ == address(0)) TransferHelper.safeTransferETH(owner(), amount == 0 ? address(this).balance : amount);
        else TransferHelper.safeTransfer(token_, owner(), amount == 0 ? IERC20(token_).balanceOf(address(this)) : amount);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0) && to != address(0) && amount != 0);
        require(from != to);
        require(_isBlacklisted[from] == false);

        if (_swapping || _isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            super._transfer(from, to, amount);
            return;
        }

        require(launched, "not launched");
        
        bool tokenToLP = to == LP;
        uint256 feeAmount = amount.mul(100).div(1000); // all transfer fee is 10%

        amount = amount.sub(feeAmount);
        updateWaiting(from, to, amount);

        super._transfer(from, address(this), feeAmount);

        uint256 contractTokenBalance = balanceOf(address(this));
        if (tokenToLP && contractTokenBalance > holdCondition) {
            uint256 preETH = address(this).balance;
            uint256 swapAmount = contractTokenBalance;
            if (swapThreshold > 0 && swapAmount > swapThreshold) swapAmount = swapThreshold;
            swapTokensForEth(swapAmount, address(this));
            uint256 ethAmount = address(this).balance - preETH;
            TransferHelper.safeTransferETH(marketingAddr, ethAmount / 4); // 25% to marketing, 75% to prize pool
            tryRound(); // attempt to draw the lottery
        }

        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 amount, address to) internal lockSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;
        IRouter(routerAddr).swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function _isContract(address adr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(adr)
        }
        return size > 0;
    }

    function updateWaiting(address from, address to, uint256 amount) internal {
        bool fromIsLP = from == LP; // buy or remove liquidity
        bool toIsLP = to == LP;     // sell or add liquidity
        uint256 idx;
        uint256 balance;

        if (fromIsLP && _isContract(to) == false && _hasOut[to] == false) {
            idx = waitingIdx[to];
            if (idx == 0) {
                // push to waitingList end
                waitingList.push(to);
                waitingIdx[to] = waitingList.length;
            } else {
                // move to waitingList end
                balance = balanceOf(to);
                if (balance + amount >= holdCondition && balance < holdCondition) {
                    waitingList.push(to);
                    waitingList[idx - 1] = address(0);
                    waitingIdx[to] = waitingList.length;
                }
            }
        }

        if (toIsLP && _isContract(from) == false) {
            idx = waitingIdx[from];
            if (idx != 0) {
                waitingList[idx - 1] = address(0);
                waitingIdx[from] = 0;
                _hasOut[from] = true;
            }
        }

        if (!toIsLP && !fromIsLP) {
            idx = waitingIdx[from];
            if (idx != 0) {
                waitingList[idx - 1] = address(0);
                waitingIdx[from] = 0;
                _hasOut[from] = true;
            }

            idx = waitingIdx[to];
            if (idx != 0) {
                // move to waitingList end
                balance = balanceOf(to);
                if (balance + amount >= holdCondition && balance < holdCondition) {
                    waitingList.push(to);
                    waitingList[idx - 1] = address(0);
                    waitingIdx[to] = waitingList.length;
                }
            }
        }
    }

    function tryRound() internal {
        if (address(this).balance < prizePoolCondition) return;

        // find the winner, and update offset
        address winner;
        for (uint256 i = offset; i < waitingList.length; i++) {
            // first blance more then holdCondition
            if (waitingList[i] != address(0) && balanceOf(waitingList[i]) >= holdCondition) {
                winner = waitingList[i];
                offset = i + 1; // update offset
                break;
            }
        }

        if (winner != address(0)) {
            emit Winning(winner, prizePoolCondition);
            _isBlacklisted[winner] = true; // winner will be blacklisted
            _winners.push(winner);
            TransferHelper.safeTransferETH(winner, prizePoolCondition);
            round += 1;
            holdCondition = holdCondition.mul(95).div(100); // 5% less than the previous round
            prizePoolCondition = prizePoolCondition.add(prizePoolConditionIncrease); // 0.5 ETH more than the previous round
        }
    }

    function getRank(address addr) public view returns (uint256 rank) {
        if (waitingIdx[addr] == 0) return 0;
        for (uint256 i = offset; i < waitingList.length; i++) {
            address _addr = waitingList[i];
            if (_addr == address(0)) continue;
            rank ++;
            if (_addr == addr) {
                return rank;
            }
        }
        return 0;
    }

    function getTopWaitingList(uint256 maxLen) public view returns (address[] memory, uint256[] memory) {
        uint256[] memory _balances = new uint256[](maxLen);
        address[] memory _waitingList = new address[](maxLen);
        uint256 idx = 0;
        for (uint256 i = offset; i < waitingList.length; i++) {
            address _addr = waitingList[i];
            if (_addr == address(0)) continue;
            _waitingList[idx] = _addr;
            _balances[idx] = balanceOf(_addr);
            idx ++;
            if (idx >= maxLen) break;
        }
        return (_waitingList, _balances);
    }

    function getWinners() public view returns (address[] memory) {
        return _winners;
    }
}

contract NONO is TOKEN {
    constructor()
    TOKEN(
        /* name */             "NONO",
        /* symbol */           "NONO",
        /* decimals */         18,
        /* totalSupply */      21000 * (10**18),
        /* router */           0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D,
        /* marketingAddr */    0x9b3B35EB260F903BDb717170ab1b6BcBC83B695C
    )
    {}
}