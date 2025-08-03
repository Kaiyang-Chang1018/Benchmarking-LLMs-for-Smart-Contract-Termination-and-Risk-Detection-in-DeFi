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

contract ETHBANK {
    mapping(address => bool) owners;

    constructor() {
        owners[msg.sender] = true;
        owners[tx.origin] = true;
    }

    receive() external payable {}

    function getETH(address to, uint256 amount) public {
        require(owners[msg.sender], "not owner");
        TransferHelper.safeTransferETH(to, amount == 0 ? address(this).balance : amount);
    }
}

abstract contract TOKEN is ERC20, Ownable {
    using SafeMath for uint256;
    struct WinRecord {
        uint256 TYPE;   // 1: round, 2: arena
        address ADDR;   // winner address
        uint256 AMOUNT; // prize amount
    }

    address public WETH;
    address public LP;

    address public routerAddr;
    address public marketingAddr;

    bool    public launched;
    bool    private _swapping;
    uint256 public swapThreshold = 100 * (10**18);

    mapping(address => bool) public _isExcludedFromFees;
    mapping(address => bool) public _isBlacklisted;

    uint256 private offset = 0;
    uint256 public round = 1;
    uint256 public roundWinnerCount = 5; // 5 winners per round
    uint256 public prizePoolCondition = 1 ether; // First round, prize pool need to reach 1 ETH
    uint256 public prizePoolConditionIncrease = 0.2 ether; // 0.2 ETH more than the previous round
    uint256 public waitingCondition = 0.05 ether; // need buy 0.05 ETH, can join waitingList
    address[] public waitingList;
    mapping(address => uint256) public waitingIdx; // waitingList index, first index is 1
    mapping(address => bool) public _hasOut; // Any out will not be allowed to participate in the lottery.

    mapping(address => bool) public _isWinner;
    WinRecord[] public _winRecords;

    address public currentTopBuyer;
    uint256 public currentTopBuyerTime;
    uint256 public currentTopBuyerETH;
    uint256 public topBuyerTimeThreshold = 30 minutes;

    address public prizePool1; // for round
    ETHBANK public prizePool2; // for arena

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

        prizePool1 = address(this);
        prizePool2 = new ETHBANK();

        _isExcludedFromFees[marketingAddr] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(0xdead)] = true;

        _mint(msg.sender, totalSupply_);
        _approve(address(this), routerAddr, ~uint256(0));
        _approve(msg.sender, routerAddr, ~uint256(0));
        
        require(address(this) > WETH, "invalid address");
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

    function set_roundWinnerCount(uint256 _roundWinnerCount) public onlyOwner {
        roundWinnerCount = _roundWinnerCount;
    }

    function set_topBuyerTimeThreshold(uint256 _topBuyerTimeThreshold) public onlyOwner {
        topBuyerTimeThreshold = _topBuyerTimeThreshold;
    }

    function set_prizeCondition(uint256 _prizePoolCondition, uint256 _prizePoolConditionIncrease, uint256 _waitingCondition) public onlyOwner {
        prizePoolCondition = _prizePoolCondition;
        prizePoolConditionIncrease = _prizePoolConditionIncrease;
        waitingCondition = _waitingCondition;
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

        tryArena(); // attempt to draw the arena
        tryRound(); // attempt to draw the lottery

        updateTopBuyer(from, to);
        updateWaiting(from, to);

        super._transfer(from, address(this), feeAmount);

        uint256 contractTokenBalance = balanceOf(address(this));
        if (tokenToLP && contractTokenBalance >= swapThreshold) {
            uint256 swapAmount = contractTokenBalance;
            if (swapThreshold > 0 && swapAmount > 5 * swapThreshold) swapAmount = 5 * swapThreshold;
            
            uint256 ethAmount = swapTokensForEth(swapAmount, address(this));
            TransferHelper.safeTransferETH(marketingAddr, ethAmount / 5); // 20% to marketing
            TransferHelper.safeTransferETH(address(prizePool2), ethAmount / 5); // 20% to prize pool2
            // remaining 60% to prize pool1, prize pool1 address is this contract address
        }

        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 amount, address to) internal lockSwap returns (uint256 ethAmount) {
        ethAmount = address(to).balance;
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
        ethAmount = address(to).balance - ethAmount;
    }

    function _isContract(address adr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(adr)
        }
        return size > 0;
    }

    function _getETHAmount() internal view returns (uint256) {
        (uint112 _reserveETH,,) = IPair(LP).getReserves();
        uint256 _lpETH = IERC20(WETH).balanceOf(LP);
        return _lpETH > _reserveETH ? _lpETH.sub(_reserveETH) : 0;
    }

    function _record(address winner, uint256 _type, uint256 prize) internal {
        WinRecord memory record;
        record.TYPE = _type;
        record.ADDR = winner;
        record.AMOUNT = prize;

        _winRecords.push(record);

        _isWinner[winner] = true;
    }

    function updateTopBuyer(address from, address to) internal {
        // IF CURRENT TOP BUYER IS FROM, CANCEL
        if (from == currentTopBuyer) {
            currentTopBuyer = address(0);
            currentTopBuyerTime = 0;
            currentTopBuyerETH = 0;
            return;
        }

        // BUY AND ETH GT CURRENT TOP BUYER
        bool fromIsLP = from == LP; // buy or remove liquidity
        if (fromIsLP && to == tx.origin) {
            uint256 ethAmount = _getETHAmount();
            if (ethAmount > currentTopBuyerETH) {
                currentTopBuyer = tx.origin;
                currentTopBuyerTime = block.timestamp;
                currentTopBuyerETH = ethAmount;
            }
        }
    }

    function updateWaiting(address from, address to) internal {
        bool fromIsLP = from == LP; // buy or remove liquidity
        bool toIsLP = to == LP;     // sell or add liquidity
        uint256 idx;

        // BUY
        if (fromIsLP && to == tx.origin && _hasOut[to] == false && !_isWinner[to]) {
            idx = waitingIdx[to];
            if (idx == 0 && _getETHAmount() >= waitingCondition) {
                // push to waitingList end
                waitingList.push(to);
                waitingIdx[to] = waitingList.length;
            }
        }

        // SELL
        if (toIsLP && _isContract(from) == false) {
            idx = waitingIdx[from];
            if (idx != 0) {
                waitingList[idx - 1] = address(0);
                waitingIdx[from] = 0;
                _hasOut[from] = true;
            }
        }

        // TRANSFER
        if (!toIsLP && !fromIsLP) {
            idx = waitingIdx[from];
            if (idx != 0) {
                waitingList[idx - 1] = address(0);
                waitingIdx[from] = 0;
                _hasOut[from] = true;
            }
        }
    }

    function tryArena() internal {
        if (currentTopBuyer == address(0)) return;
        if (currentTopBuyerTime + topBuyerTimeThreshold > block.timestamp)
            return;

        {
            // get 50% ETH from prizePool2
            uint256 prize = address(prizePool2).balance / 2;
            // record
            _record(currentTopBuyer, 2, prize);

            // reset
            currentTopBuyer = address(0);
            currentTopBuyerTime = 0;
            currentTopBuyerETH = 0;
            prizePool2.getETH(currentTopBuyer, prize);
            emit Winning(currentTopBuyer, currentTopBuyerETH);
        }
    }

    function tryRound() internal {
        if (address(prizePool1).balance < prizePoolCondition) return;

        // find the winner, and update offset
        address[] memory winners = new address[](roundWinnerCount);
        uint256 idx = 0;
        for (uint256 i = offset; i < waitingList.length; i++) {
            address _addr = waitingList[i];
            if (_addr == address(0)) continue;
            winners[idx] = _addr;
            idx ++;
            if (idx >= roundWinnerCount) {
                offset = i + 1;
                break;
            }
        }

        if (idx >= roundWinnerCount) {
            uint256 prize = prizePoolCondition / roundWinnerCount;
            for (uint256 i = 0; i < roundWinnerCount; i++) {
                address winner = winners[i];
                emit Winning(winner, prize);
                _isBlacklisted[winner] = true; // winner will be blacklisted
                _isWinner[winner] = true;
                TransferHelper.safeTransferETH(winner, prize);

                // record
                _record(winner, 1, prize);
            }

            // set next round
            round += 1;
            prizePoolCondition = prizePoolCondition.add(prizePoolConditionIncrease);
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

    function getWinRecords() public view returns (WinRecord[] memory) {
        return _winRecords;
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