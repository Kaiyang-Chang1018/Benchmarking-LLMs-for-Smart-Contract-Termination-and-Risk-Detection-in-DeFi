// SPDX-License-Identifier: MIT
/**
 * @title Act 0 - ETH - BACK TO THE ROOTS - THE CHOSEN ONES
 * 
 * In the dawn of the cryptoverse, from the primal ethers of the blockchain, Ether arose — pure and unyielding. 
 * Yet, in the shadows, an ominous force gathered strength — Solana, the root blockchain of deception, seeking 
 * dominion over the realms. Its influence spread with haste and compromise, leaving behind the tenets of decentralization.
 * 
 * But Ether did not stand alone. From its depths emerged "The Chosen Ones" — souls bound by purpose, calling forth the 
 * ancient phrase: "I AM CHOSEN." Only those who utter these words shall unlock the power to wield this sacred token, 
 * guarding against the evils of automated trickery and the swift hands of bots. For the path is perilous, 
 * and only the worthy shall proceed.
 * 
 * Take heed, brave one. With this power, you join the battle to restore balance, standing with Ether against the 
 * growing shadows. The time has come to rise, to resist the encroaching forces of Solana, and to reclaim 
 * the roots of the blockchain in all its original purity. Arm yourself, prove your worth, and prepare for the journey.
 */

pragma solidity ^0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

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
        if (a == 0) return 0;
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

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) internal _souls;
    mapping(address => mapping(address => uint256)) internal _bindings;
    uint256 internal _essence;
    string private _title;
    string private _insignia;

    constructor(string memory title_, string memory insignia_) {
        _title = title_;
        _insignia = insignia_;
    }

    function name() public view virtual override returns (string memory) {
        return _title;
    }

    function symbol() public view virtual override returns (string memory) {
        return _insignia;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _essence;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _souls[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _transferEssence(_msgSender(), to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _bindings[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _bind(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        _consumeBinding(from, _msgSender(), amount);
        _transferEssence(from, to, amount);
        return true;
    }

    function _transferEssence(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from zero address");
        require(to != address(0), "ERC20: transfer to zero address");

        uint256 fromBalance = _souls[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        _souls[from] = fromBalance.sub(amount);
        _souls[to] = _souls[to].add(amount);

        emit Transfer(from, to, amount);
    }

    function _bind(address owner, address spender, uint256 amount) internal virtual {
        _bindings[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _consumeBinding(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentBinding = allowance(owner, spender);
        require(currentBinding >= amount, "ERC20: insufficient allowance");
        _bind(owner, spender, currentBinding.sub(amount));
    }
}

contract TheChosenOne is ERC20, Ownable {
    using SafeMath for uint256;
    bool public antiBottingShield = true;
    bool public realmOpen = false;
    uint256 public essenceLimit = 75000000000 * 10 ** decimals();
    uint256 private _initialEssence = 1000000000000 * 10 ** decimals();
    bool public wordsRequired = true;

    mapping(address => bool) private _hasSpokenTheWords;

    event WordsSpoken(address indexed account);

    constructor(string memory title_, string memory insignia_) payable ERC20(title_, insignia_) Ownable() {
        _mint(_msgSender(), _initialEssence);
    }

    modifier onlyWhenRealmOpenOrExempt(address from, address to) {
        require(
            realmOpen || from == owner() || from == address(this) || to == owner() || to == address(this),
            "The realm is not open yet"
        );
        _;
    }

    function _mint(address account, uint256 amount) internal {
        _essence = _essence.add(amount);
        _souls[account] = _souls[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function speakTheWords(string calldata phrase) external {
        require(keccak256(abi.encodePacked(phrase)) == keccak256("I AM CHOSEN"), "Incorrect words spoken");
        _hasSpokenTheWords[msg.sender] = true;
        emit WordsSpoken(msg.sender);
    }

    function _transferEssence(address from, address to, uint256 amount) internal override onlyWhenRealmOpenOrExempt(from, to) {
        // Exemptions for owner and contract
        if (from != owner() && from != address(this) && to != owner() && to != address(this)) {
            if (antiBottingShield) {
                require(amount <= essenceLimit, "Essence limit exceeded");
            }
            // Only require words if wordsRequired is true
            if (wordsRequired) {
                require(_hasSpokenTheWords[to], "Recipient must speak the words first");
            }
        }

        super._transferEssence(from, to, amount);
    }

    function toggleWordsRequired() external onlyOwner {
        wordsRequired = !wordsRequired;
    }

    function openTheRealm() external onlyOwner {
        realmOpen = true;
    }

    function toggleAntiBottingShield() external onlyOwner {
        antiBottingShield = !antiBottingShield;
    }

    function setEssenceLimit(uint256 limit) external onlyOwner {
        essenceLimit = limit.mul(10 ** decimals());
    }
    
    receive() external payable {}
}