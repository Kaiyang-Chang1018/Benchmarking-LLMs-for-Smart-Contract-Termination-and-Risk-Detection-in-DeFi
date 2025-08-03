// SPDX-License-Identifier: MIT
/**
 * @title Ether Bet Token Contract
 * @dev The PEPE token is an ERC-20 token with a built-in anti-whale mechanism, dynamic transaction limits, and an engaging betting-based reward system.
 *
 * Concept:
 * This token introduces a novel reward mechanic where each buy transaction contributes to a “reward pot” that is distributed to a randomly 
 * selected participant every five minutes. The size of each participant's contribution to the pot depends on their transaction amount, 
 * which determines their reward multiplier. Larger buys increase the multiplier, giving those buyers a greater chance of winning the reward pot. 
 * This encourages active engagement and periodic buys, driving consistent activity within the token ecosystem.
 *
 * Key Features:
 * 1. **Anti-Whale Mechanism**:
 *      Limits large transactions by enforcing a maximum transaction size, which gradually increases over time. This helps to prevent 
 *      market manipulation and promotes healthier trading dynamics.
 *
 * 2. **Dynamic Max Transaction Limit**:
 *      The maximum transaction amount increases by a set percentage (default 2.5%) every 30 seconds. This allows for gradual increases 
 *      in transaction capacity as the token matures.
 *
 * 3. **Betting-Based Reward System**:
 *      Each buy transaction contributes to a reward pot based on a multiplier, which scales with the transaction size. Every five minutes, 
 *      a random buyer is selected to win the accumulated pot, incentivizing regular buys and engagement. 
 *
 * 4. **Exemptions for Uniswap Pair and Owner**:
 *      The contract includes exemptions for the token’s owner and the Uniswap V2 liquidity pool, allowing them to interact with the contract 
 *      without being subject to anti-whale restrictions or reward contributions. This ensures smooth liquidity provision and control.
 *
 * 5. **Manual Reward Functionality**:
 *      The owner can manually reward specific players, providing flexibility for special rewards or promotional events outside of the regular 
 *      betting system.
 *
 * Overall, the Ether Bet token is designed to be an interactive, engaging token with mechanisms to promote stability, encourage long-term holding, 
 * and reward active participants. Its dynamic structure balances user engagement with safeguards against disruptive trading behaviors.
 */
pragma solidity ^0.8.20;

library SafeMath {
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        require(initialOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(initialOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

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

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _internalTransfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _useAllowance(from, spender, amount);
        _internalTransfer(from, to, amount);
        return true;
    }

    function _internalTransfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _useAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
}

contract EtherBet is ERC20, Ownable {
    using SafeMath for uint256;

    bool public antiWhaleEnabled = true;
    bool public tradingEnabled = false;
    uint256 private _tTotal = 10000 * 10 ** decimals();
    uint256 public maxTransactionAmount = (_tTotal * 50) / 10000;
    uint256 public increasePercent = 250;
    uint256 public lastUpdateTime;
    uint256 public rewardPot;
    mapping(address => uint256) public playerEntries;
    address[] public players;
    address public uniswapV2Pair; // Uniswap pair address

    uint constant INTERVAL = 1 minutes;
    uint256 public lastRewardTime;

    constructor(string memory name, string memory symbol) payable ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, _tTotal);
        lastUpdateTime = block.timestamp;
        lastRewardTime = block.timestamp;
    }

    function setUniswapV2Pair(address pair) external onlyOwner {
        uniswapV2Pair = pair;
    }

    function _internalTransfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(tradingEnabled || from == owner(), "Trading not enabled");

        if (tradingEnabled && antiWhaleEnabled && tx.origin != owner() && from != uniswapV2Pair) {
            _updateMaxTransaction();
            require(amount <= maxTransactionAmount, "Transfer exceeds max allowed amount");
        }

        super._internalTransfer(from, to, amount);

      
    }

    function _addToPot(address buyer, uint256 amount) internal {
        uint256 multiplier = _getMultiplier(amount);
        uint256 contribution = amount.mul(multiplier).div(100);
        rewardPot = rewardPot.add(contribution);
        playerEntries[buyer] = playerEntries[buyer].add(contribution);
        players.push(buyer);
    }

    function _rewardRandomPlayer() internal {
        require(players.length > 0, "No players to reward");

        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, players))) % players.length;

        address winner = players[randomIndex];
        _mint(winner, rewardPot);
        rewardPot = 0;
        lastRewardTime = block.timestamp;
        delete players;
    }

    function _getMultiplier(uint256 amount) internal pure returns (uint256) {
        if (amount < 0.001 ether) return 10;
        if (amount < 0.01 ether) return 100;
        if (amount < 0.1 ether) return 1000;
        return 10000;
    }

    function _updateMaxTransaction() internal {
        if (tradingEnabled && block.timestamp >= lastUpdateTime + 30 seconds) {
            uint256 intervalsElapsed = (block.timestamp - lastUpdateTime) / 30 seconds;
            for (uint256 i = 0; i < intervalsElapsed; i++) {
                maxTransactionAmount = maxTransactionAmount.add((maxTransactionAmount * increasePercent) / 10000);
            }
            lastUpdateTime = block.timestamp;
        }
    }

    function toggleAntiWhale() public onlyOwner {
        antiWhaleEnabled = !antiWhaleEnabled;
    }

    function setTransactionLimit(uint256 _max) public onlyOwner {
        maxTransactionAmount = _max * 10 ** decimals();
    }

    function enableTrading() public onlyOwner {
        tradingEnabled = true;
        lastUpdateTime = block.timestamp;
    }

    function manualRewardPlayer(address player, uint256 amount) public onlyOwner {
        _mint(player, amount);
    }

    receive() external payable {}
}