// SPDX-License-Identifier: Unliscense
pragma solidity ^0.8.26;

/*

This is a meme coin I'm creating just for lulz and experimentation with creating tokens, seeing what works and what doesn't,
mostly for learning, man.  There is no promise or expectation of this coin to go up in value.

This contract doesn't actually *do* anything, other than provide you with the option to swap into Lyra.  It's literally just a token called 'Jonald Brump',
so named as a confusion/combination of the names 'Joe Biden' and 'Donald Trump', with heavier emphasis on the latter name.

I've created a few other tokens:
- OpenRugPull V1 (0x871401E1126fFcd6DF23E42714Cc5B4b033Bd2F7)
- Malvan Lyra (0xc84f5F6f915EE476bB6D937dC849bf6237769baC, migrated holders from original contract 0x6985f4bedc0789a17f00638c1c0eb37e76d6350e)

Idk man, if this seems like a scam to you then don't buy.  Also, if you can hack the contract please do, so I learn where the vulnerabilities are.
I wrote these contracts myself, based on some really old tokens I made in like 2017 or something.  So if I made a mistake I'd like to know!!

*/

abstract contract ERC20Interface {
	function totalSupply() public virtual view returns (uint);
	function balanceOf(address tokenOwner) public virtual view returns (uint balance);
	function allowance(address tokenOwner, address spender) public virtual view returns (uint remaining);
	function transfer(address to, uint tokens) public virtual returns (bool success);
	function approve(address spender, uint tokens) public virtual returns (bool success);
	function transferFrom(address from, address to, uint tokens) public virtual returns (bool success);

	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract MemeCoin is ERC20Interface {

	string public symbol;
	string public  name;
	uint8 public decimals;
	uint64 public decimalFactor;
	ERC20Interface public lyra;
	uint64 internal _totalSupply;

    // I like to use the smallest type, so uint64 is plenty for what we're doing.  Why use up 4x as much memory for the same thing?
    // Maybe I'm too used to potato computers.
	mapping(address => uint64) public balances;
	mapping(address => mapping(address => uint64)) public allowed;

	constructor() {
		symbol = "JJB";
		name = "Jonald J. Brump";
		decimals = 8;
		decimalFactor = uint64(10**uint(decimals));
		_totalSupply = 0;
	}

	function initialize(address lyraAddress, uint64 tokens) public {
		require(address(lyra) == address(0x0), "The contract has already been initialized.");
        require(tokens >= decimalFactor, "You can't send less than one Lyra.");
		lyra = ERC20Interface(lyraAddress);

        // Fund this contract from the given token
        lyra.transferFrom(msg.sender, address(this), tokens);

        // Set up the supply counter
        _totalSupply = uint64(tokens);

        // Set up balances
        _transfer(msg.sender, address(0x0), tokens);
	}


    // CLAIM LYRAS

    function claimLyra(uint64 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance.");

        // Give them their Lyras
        lyra.transfer(msg.sender, amount);

        // Burn the Jonald Brump tokens
        _transfer(address(0x0), msg.sender, amount);
    }


	// THE ACTUAL METHODS

	function totalSupply() public override view returns (uint) {
		return _totalSupply;
	}

	function balanceOf(address tokenOwner) public override view returns (uint balance) {
		return balances[tokenOwner];
	}

	function transfer(address to, uint tokens) public override returns (bool success) {
		require(to!=address(0), "Invalid address");
		require(tokens<=balances[msg.sender], "Insufficient funds");

		_transfer(to, msg.sender, uint64(tokens));

		return true;
	}

	function approve(address spender, uint tokens) public override returns (bool success) {
		allowed[msg.sender][spender] = uint64(tokens);
		emit Approval(msg.sender, spender, tokens);
		return true;
	}

	function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
		require(to != address(0), "Invalid address");
		require(tokens <= balances[from], "Insufficient funds");
		require(tokens <= allowed[from][msg.sender], "Allowance exceeded");
		allowed[from][msg.sender] = allowed[from][msg.sender] - uint64(tokens);
		_transfer(to, from, uint64(tokens));

		return true;
	}

    // I use the order 'to, from' because I'm used to memcpy, strcpy, x86 assembly, etc.  It feels more natural to me.
	function _transfer(address to, address from, uint64 tokens) internal {
		require(to != address(this) || balances[address(this)] == 0);

        // Check if this is a token burn
        if (to != address(0x0))
            balances[to] += tokens;
        else 
            _totalSupply -= tokens;

        // Check if this is a token mint
        if (from != address(0x0))
    		balances[from] -= tokens;

		emit Transfer(from, to, uint(tokens));
	}

	function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
		return allowed[tokenOwner][spender];
	}
}