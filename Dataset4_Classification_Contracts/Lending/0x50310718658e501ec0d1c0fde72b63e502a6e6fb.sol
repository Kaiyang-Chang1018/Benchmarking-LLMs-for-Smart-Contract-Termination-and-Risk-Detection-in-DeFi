// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LGCYX {
    string public name = "LGCYX";
    string public symbol = "LGCYX";
    uint8 public decimals = 18;
    uint256 public totalSupply = 100000000000 * 10 ** uint256(decimals); // 100 billion tokens with 18 decimals

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => bool) private blacklisted;

    address public owner;
    bool public paused = false;

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    mapping(address => uint256) public nonces;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Paused(address account);
    event Unpaused(address account);
    event Burn(address indexed burner, uint256 value);
    event Blacklisted(address indexed account);
    event Unblacklisted(address indexed account);

    modifier onlyOwner() {
        require(msg.sender == owner, "LGCYX: caller is not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "LGCYX: paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "LGCYX: not paused");
        _;
    }

    modifier notBlacklisted(address account) {
        require(!blacklisted[account], "LGCYX: account is blacklisted");
        _;
    }

    constructor() {
        owner = msg.sender;
        balances[owner] = totalSupply;

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes("1")),
            chainId,
            address(this)
        ));

        emit Transfer(address(0), owner, totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public whenNotPaused notBlacklisted(msg.sender) notBlacklisted(recipient) returns (bool) {
        require(recipient != address(0), "LGCYX: transfer to the zero address");
        require(balances[msg.sender] >= amount, "LGCYX: transfer amount exceeds balance");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public whenNotPaused notBlacklisted(msg.sender) notBlacklisted(spender) returns (bool) {
        require(spender != address(0), "LGCYX: approve to the zero address");

        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint256) {
        return allowances[tokenOwner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public whenNotPaused notBlacklisted(sender) notBlacklisted(recipient) returns (bool) {
        require(recipient != address(0), "LGCYX: transfer to the zero address");
        require(balances[sender] >= amount, "LGCYX: transfer amount exceeds balance");
        require(allowances[sender][msg.sender] >= amount, "LGCYX: transfer amount exceeds allowance");

        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burn(uint256 amount) public whenNotPaused notBlacklisted(msg.sender) {
        require(balances[msg.sender] >= amount, "LGCYX: burn amount exceeds balance");

        balances[msg.sender] -= amount;
        totalSupply -= amount;

        emit Burn(msg.sender, amount);
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }

    function blacklist(address account) public onlyOwner {
        blacklisted[account] = true;
        emit Blacklisted(account);
    }

    function unblacklist(address account) public onlyOwner {
        blacklisted[account] = false;
        emit Unblacklisted(account);
    }

    function permit(
        address owner_,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(deadline >= block.timestamp, "LGCYX: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner_,
                spender,
                value,
                nonces[owner_],
                deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                structHash
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner_, "LGCYX: invalid signature");

        nonces[owner_] += 1;
        allowances[owner_][spender] = value;

        emit Approval(owner_, spender, value);
    }
}