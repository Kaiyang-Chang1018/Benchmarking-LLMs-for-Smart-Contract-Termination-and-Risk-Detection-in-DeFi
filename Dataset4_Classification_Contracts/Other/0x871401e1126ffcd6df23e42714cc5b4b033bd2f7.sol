// SPDX-License-Identifier: Unliscense
pragma solidity ^0.8.26;

/*

ATTENTION:  THIS COIN IS A RUGPULL!  BUT WHO WILL PULL THE RUG?

HOW IT WORKS:

1. I create the contract, granting me 80% of the supply and granting the contract 20%
2. I offer my entire holding as locked liquidity
3. People buy their share of the meme, to participate in the joke, and NOT as an investment
4. After 30 days, the contract enables the 'rugpull' function - except absolutely anyone can execute the function (not just me)
5. Somebody calls 'rugpull', costing them some ethereum, but granting them 20% of the entire coin supply (which the contract was holding)
6. This function also distributes my main token, the Malvan Lyra, to all who bought this coin (0xc84f5f6f915ee476bb6d937dc849bf6237769bac)

At this point, whoever rugpulled may sell their coins, or just hold them as a souvenir.  Up to them.

Now, there are some catches to the 'rugpull' function:
1. The gas fee increases in proportion to the number of people who bought the coin, so if too many people bought the coin, then nobody can pull the rug!
2. There is an additional fee, in Ethereum, which must be paid to pull the rug, proportional to the sqrt of the number of holders:
     fee = sqrt(n) * 0.00506 ETH
3. The rugpuller must hold some nonzero amount of OpenRugPull.

NOTES:
1. The rugpull function DOES NOT distribute Lyra to contract addresses.
2. Testnet contract: https://sepolia.etherscan.io/address/0x7fa746fbc9c407d57102c48d339e56d6c2106570
3. This meme coin was made by the Nuclear Man.  Hopefully more to come, if I have time...

It should be obvious that buying this coin is very likely a bad financial decision.  This coin is not intended as an investment,
but as an elaborate joke.  I, the creator of the coin, disclaim all liability, and disclaim any intent of making this a good investment.

LEGAL DISCLAIMER:

**NO INVESTMENT VALUE – FOR ENTERTAINMENT PURPOSES ONLY**  

The OpenRugPull (ORP) token is explicitly designed as a joke and not as a financial investment. By acquiring ORP, you acknowledge and agree to the following:  

1. **This Token is a Gimmick** – ORP is structured as an experimental meme token where the primary function is an open and unpredictable "rugpull" event. This token has no inherent value, utility, or future promise.  
2. **Financial Risk** – Purchasing ORP carries a high probability of total financial loss. The creator makes no assurances regarding liquidity, price stability, or any potential return.  
3. **Decentralized Rugpull** – The smart contract includes a rugpull function, which can be executed by anyone who meets the conditions. The outcome of this function is not controlled by the creator, nor is it guaranteed to be fair or beneficial to any participant.  
4. **No Liability** – The creator of ORP disclaims all liability arising from the token, its smart contract, and any losses incurred by participants. This project is provided “as-is” without warranties of any kind.  
5. **Regulatory Compliance** – ORP is not a registered security, currency, or financial product. Participants are solely responsible for understanding and complying with applicable laws and regulations in their jurisdiction.  
6. **No Guarantees of Execution** – Due to Ethereum network congestion, gas fee volatility, or other unforeseen factors, the rugpull function may become impractical or impossible to execute.  

By interacting with the OpenRugPull contract, you affirm that you understand these terms and accept full responsibility for any consequences. If you do not agree, do not buy, sell, or engage with this token in any way.  
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

contract OpenRugPull is ERC20Interface {

	string public symbol;
	string public  name;
	uint8 public decimals;
	uint64 public decimalFactor;
	ERC20Interface public lyra;
	uint64 internal _totalSupply;
    uint64 public numCirculating;
    address payable public creator;

    address[] internal hodlers;

    uint public rugpullBlock;

	mapping(address => uint64) public balances;
	mapping(address => mapping(address => uint64)) public allowed;

	constructor() {
		symbol = "RUGPULLv1";
		name = "OpenRugPull (DO NOT BUY)";
		decimals = 8;
		decimalFactor = uint64(10**uint(decimals));
		_totalSupply = 0;
        creator = payable(msg.sender);
	}

	function initialize(address lyraAddress, uint64 tokens) public {
		require(address(lyra) == address(0x0), "The contract has already been initialized.");
        require(tokens >= decimalFactor, "You can't send less than one Lyra.");
		lyra = ERC20Interface(lyraAddress);

        // Fund this contract from the given token
        lyra.transferFrom(msg.sender, address(this), tokens);

        _totalSupply = uint64(tokens);

        // Set up balances
        uint64 oneFifth = _totalSupply / 5;
        _transfer(msg.sender, address(0x0), tokens - oneFifth);
        _transfer(address(this), address(0x0), oneFifth);

        // Set the countdown!
        rugpullBlock = block.number + uint(30 * 86400) / 13;
	}


    // THE BIG FUNNY

    function rugpull() public payable {
        // If someone uses the constructor hack here, that would be dumb, because they'd just be wasting gas.
        require(msg.sender.code.length == 0, "Contracts cannot call this function.");
        require(rugpullBlock != 0, "Rug has already been pulled!!!");
        require(rugpullBlock <= block.number, "You can't rugpull yet, be patient!");
        require(balances[msg.sender] > 0, "You must hold some OpenRugPull to rugpull!");

        uint hodlerCount = hodlers.length;
        uint requiredFee = (sqrt(hodlerCount) * 256 ether) / 100000;

        require(msg.value >= requiredFee, "Insufficient ETH sent for rugpull!");

        // Pay a fee to the creator
        // Usually this should be worth doing.  Comparison of scenarios:
        //   1000 hodlers, $15 invested each (a low estimate), total value in the token is $15000.  The fee would be ~0.081 eth, or about 250$.
        //   100 hodlers, $15 invested each, total value in the token is $1500.  The fee would be ~0.0256 eth, or about 82$.
        //   10 hodlers, $15 invested each, total value in the token is $150.  The fee would be ~0.0081 eth, or about 25$.
        // This assumes VERY low values for people investing; I always invest at least 20-30 in meme coins if I do.  Some will invest more.
        // If we count by market cap, which would be around 100k to start, it's basically 20k$ for hundreds of dollars in investment.  Really good return.
        // This makes a lot of assumptions but you get the idea.  $250 isn't that much money, and I did invest time to build this, however monkey it may be.
        creator.transfer(requiredFee);

        // Refund any extra eth
        payable(msg.sender).transfer(msg.value - requiredFee);

        // Distribute Malvan Lyra tokens to all hodlers
        for (uint i = 0; i < hodlerCount; i++) {
            address hodler = hodlers[i];
            uint64 bal = balances[hodler];
            if (bal > 0)
                lyra.transfer(hodler, bal);
        }

        // Transfer 20% of OpenRugPull tokens from contract to msg.sender
        _transfer(msg.sender, address(this), balances[address(this)]);

        // Donate any extra/unclaimed tokens to the Lyra contract
        lyra.transfer(address(lyra), lyra.balanceOf(address(this)));

        // Can only rugpull once
        rugpullBlock = 0;
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

	function _transfer(address to, address from, uint64 tokens) internal {
        require(to != address(0x0));
		require(to != address(this) || balances[address(this)] == 0);

        if (tokens != 0 && to.code.length == 0 && to != address(0x0)) {
            uint q = 30;
            if (hodlers.length < 1970)
                q = (2000 - hodlers.length);
            if (balances[to] == 0 && tokens > (_totalSupply / q))
                hodlers.push(to);
            numCirculating += tokens;
        }
        if (from != address(0x0) && from.code.length == 0)
            numCirculating -= tokens;

        balances[to] += tokens;
        if (from != address(0x0))
    		balances[from] -= tokens;

		emit Transfer(from, to, uint(tokens));
	}

	function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
		return allowed[tokenOwner][spender];
	}

	// https://ethereum-magicians.org/t/eip-7054-gas-efficient-square-root-calculation-with-binary-search-approach/14539
	function sqrt(uint x) public pure returns (uint128) {
		if (x == 0) return 0;
		else{
			uint xx = x;
			uint r = 1;
			if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
			if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
			if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
			if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
			if (xx >= 0x100) { xx >>= 8; r <<= 4; }
			if (xx >= 0x10) { xx >>= 4; r <<= 2; }
			if (xx >= 0x8) { r <<= 1; }
			r = (r + x / r) >> 1;
			r = (r + x / r) >> 1;
			r = (r + x / r) >> 1;
			r = (r + x / r) >> 1;
			r = (r + x / r) >> 1;
			r = (r + x / r) >> 1;
			r = (r + x / r) >> 1;
			uint r1 = x / r;
			return uint128 (r < r1 ? r : r1);
		}
	}
}