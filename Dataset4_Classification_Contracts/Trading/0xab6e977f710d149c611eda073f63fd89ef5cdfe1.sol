// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// 情報：Every 2 hours, $HALVE total supply will reduce by -50%. We are The Halvening.
// Bitcoin will bring our market to new heights in April 2024. Do not doubt Satoshi-san.

/*
                                                                             .:.                                        
                                                                            .~:.                                        
                                                                            :.                                          
                                                                     .^!!7!~~!777!~:                                    
                                                                   .:?JJJJJJJJJJJJJJ7:                                  
                                                                 .!?J??????????????7!^.                                 
                                                                :?J?!77?77JJ!!7???7::^~!!^.                             
                                                                ~B&?!~:GJP&5~!:?P??????7?YY^.                           
                                                                 :?J7!7?77??!!!7???7????7?5J?7~:                        
                                                                 .7??77???7?????77!!?????J5JJJJJ?!:                     
                                                                .~7??77777??777!!!!??????Y5JYYYJJJJ7^                   
                                                                .~~!!!!!!!!!!!!!!7?77??7?5YJYYYYYJJJJ!                  
                                                               .?Y?!!!!!!!!!!7777!!~7777Y5JJYYYJYYJJJ!                  
                                                              .YP55YJ???7777??!~~~~!777J5YJYYJYJYJJYY~                  
                                                             .YPPPPP555YYYYJJ55J!!7777J55JJYYJJJJJYYY~                  
                                                             ?P55555PPPP55Y55YY55J777J55JJYYYY?JYYYYY^                  
                                                            ~55YYYYYYYY5555Y5YJJ55J7J55JJYYYYJJYYYYYY~                  
                                                            ~555PPPP555YYYYYJJJ?Y5YY55YJYYYYJJYYYYYYY7                  
                                                            .?55555555555555J?JJ?YY55JJYYYYY?JYYYYYYYJ.                 
                                                             .JYY55555555555?J?JY55YJJYJJJYJJYYYYYJYYY~                 
                                                              :JYY5555555555?JY555YJYYYYYJJ?JYYYJJYYYY!                 
                                                               ^YY5555555555YY55YYJYYYYYYYJ?YJJJJYYYJJ7                 
                                                                !YY5555555YYYYJJJJYYYYYYYYJJJJJJJJJJJJ7                 
                                    ..::^^^~^                 .^~?JY555555555Y7JJJYYYYYYJJJYYYJJJJJJJJ7                 
                              .:~7JY5PPJYYYYY:             :^!!!~~JYY5YJJJJJJJ7?JJJYYYYY?YYYYYYYYYYJJJ7.                
                           :!J5GGGGGGGGYYYYYY~          .^~!!~~^::7J5GGGGPP5YYYJ???JJJJ??YYYYYYYYYYJJJ7^^:.             
                        :!YPGGGGGPPPPPP5JJJYY7        .^~~~~~^::::^JPPGGGGGGGP5YYYJ??JJ7JYYYYYYYYYYYJJ!^^^^^:.          
                      ^JPGGGGPPPPPPPPPPPJJJYYJ.     :^~~~~~~::::::!PPPPPPPGGGGGP5JYYJ?77YYYYYYYYYYYYJJ~^^^^^^::.        
                    ^JGGGGGPPPPPPPPPPPPPYYYYYY^   .:^~~~~~^::::::^5GPPPPPP5PGGGGGPYYYYJ7JYYYJYYYYYYYJ?^^^^^:::::        
                  .?PGGGGPPPPPPPPPPPPPPG5YYYYY!  ::::::::::::::::JGPPPPPPPPP55GGGGG5JYYJ?J555YYJYYYYJ7^^^^::::::.       
                 ^YGGGGP5PPPPPPPPPPPGG5P5JYYJJ?:^:::::::::::::::!PPPPPPPPPPPPP5PGGGGPJYJY?7?JY5YJYYJ?!^~~~~~^::::       
                ~PGGGG5PPPPPPPPPPPPPBBGPGYYYJJJ~~~^::::::::::::^YBB5PPPPPPPPPPP55GGGGPJYYY7!7!7J?7777~~~~~~~:::::.      
               ^PGGGG5PPPPPPPPPGGGGBBBBBBPYYYYJ!~~~^::::.......YBBBPPPPPPPPPPPPPP5GGGG5JYYY77?!7JJJ5J^^^~~^::::::.      
              .YGGGG5PPPPPPPPPPGPBBBBBBGGPJJYYY?^~~~^:::...::^7BBBBBBGPPPPPPPPPPPP5GGGGYYYYJ!?7?55Y5!:^~^::::::::.      
              !GGGG5PPPPPPPPPPPP5PBBBBB5PPYJJYYJ^^~^~^^~!!77?75PPGBBBBBPPPPPPPPPPP5PGGG5JYYY77?JY5YJ^~^:::::::::::      
             .YGGGG5PPPPPPPPPPPPP5BBBBBGPGYJJJJ?!!77????????7YGPP5BBBBBG5PPPPPPPPPP5GGGPJYYY?7JJJ5J!~^:::::::::^^^:     
             ^PGGGP5PPPPPPPPPPPPGPGBBGGPJY??????JJ?????????7?PPPPGBBBBBPPPPPPPPPPPP5GGGGJYYYJ7JJJ57:::::::^^^^^^^^:     
             ^PGGG5PPPPPPPPPPPP55YJJJ???????JJJJ????????????GBBBBBBBBGPPPPPPPPPPPPP5GGGGJJJYJ7JJJ?^::^^^^^^^^^^:::.     
             ^PGGGPPPPPPP5YYJ???????????????JJJJJ?????????7YGGBBBBBPPPPPPPPPPPPPPPP5GGGGJYYYJ!?J7^^^^^^^^^:::.....      
             :YGGP5YYJJ?????????????????????JJJJJ??????????PPPPGBBBG5PPPPPPPPPPPPP5PGGGPJYYYJ^::::::::::::::......      
           ..^?JJ???????????????????????????JJJJJJJJJ???775GPG5PBBBBBYPPPPPPPPPPPP5GGGG5JYYY7.......:::::::::..:.       
     .:^~!7??J?????????????????????????????JJJJJ???7!~^^:JPPPPPBBBBBB5PPPPPPPPPPP5PGGGGJYYYJ:     ......:^^^^.          
  .!??JJJJJJ??????????????????????????????????????!^:::^?GGGGGBBBBBBPPPPPPPPPPPPP5GGGG5JYYY!            :777?~.         
   ^?J??????????????????????????????????JY555JYYYY?777?JGBBBBBBBBBGPPPPPPPPPPPP55GGGG5YYYY7.           ~7?????7^        
    ~J?????????????????????????????JYY5PPGBG5YYYYYJ77??JGBPPPPPPPPPPPPPPPPPPPP5PGGGG5JYYY7.            ?J?7?????!^.     
     !J????????????JJJ???????JY55PPPPPPPP5PPP5JYJYY!  !PPP5PPPPPPPPPPPPPPPPP55PGGGG5JYYY!.             !55J7777!!?7.    
     .7J?????JJJJJ??77JYY555PPPPPPPPPPPPPPPPPPJYJJY7 :PGPPPPPPPPPPPPPPPPPP55PGGGGPYJYYJ^                :!JJYJ?7?J?.    
      :?JJJJ??7!~^:.  ~YGGGGGPPPPPPPPPPPPPPPPGYYYJYJ:JGPPPPPPPPPPPPPPPPPPPGGGGGPYJYYJ!.                     ~?JJJ?^     
       ^7!~:..          :75GGGGGGPPPPPPPPPPPPP5JYYYJ?PPPPPPPPPPPPPPPPPPGGGGGGPYJYYJ!.                                   
                           :!J5GGGGGGGGGGGGGGGGYYYYJ5PPPPPPPPPPPPPGGGGGGGGP5YYYJ7^.                                     
                              .:~7?Y5PPGGGGGGGG5J?!5GGGGGGGGGGGGGGGGGGP55YJJ7~:.                                        
                                     .::^^^~~^^:. .~!7?JYY55555YYYYJJ?7!~^:.                                            
                                                                .                                                       
*/

// Website: https://halvemedaddy.com
// Twitter: https://twitter.com/the_halvening
// Telegram: https://t.me/the_halvening

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IDEXRouter {
	function factory() external pure returns (address);

	function WETH() external pure returns (address);

	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;
}

interface IDEXFactory {
	function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IWETH {
	function deposit() external payable;
}

interface InterfaceLP {
	function sync() external;

	function mint(address to) external returns (uint liquidity);
}

abstract contract ERC20Detailed is IERC20 {
	string private _name;
	string private _symbol;
	uint8 private _decimals;

	constructor(string memory _tokenName, string memory _tokenSymbol, uint8 _tokenDecimals) {
		_name = _tokenName;
		_symbol = _tokenSymbol;
		_decimals = _tokenDecimals;
	}

	function name() public view returns (string memory) {
		return _name;
	}

	function symbol() public view returns (string memory) {
		return _symbol;
	}

	function decimals() public view returns (uint8) {
		return _decimals;
	}
}

contract Halvecoin is ERC20Detailed, Ownable {
	uint256 public rebaseFrequency = 2 hours;
	uint256 public nextRebase;
	uint256 public finalRebase;
	bool public autoRebase = true;
	bool public rebaseStarted = false;
	uint256 public rebasesThisCycle;
	uint256 public lastRebaseThisCycle;

	uint256 public maxTxnAmount;
	uint256 public maxWallet;

	address public taxWallet;
	uint256 public taxPercentBuy;
	uint256 public taxPercentSell;

	string public _1_x;
	string public _2_telegram;
	string public _3_website;

	mapping(address => bool) public isWhitelisted;

	uint8 private constant DECIMALS = 9;
	uint256 private constant INITIAL_TOKENS_SUPPLY = 18_236_939_125_700_000 * 10 ** DECIMALS;
	uint256 private constant TOTAL_PARTS = type(uint256).max - (type(uint256).max % INITIAL_TOKENS_SUPPLY);

	event Rebase(uint256 indexed time, uint256 totalSupply);
	event RemovedLimits();

	IWETH public immutable weth;

	IDEXRouter public immutable router;
	address public immutable pair;

	bool public limitsInEffect = true;
	bool public tradingIsLive = false;

	uint256 private _totalSupply;
	uint256 private _partsPerToken;
	uint256 private partsSwapThreshold = ((TOTAL_PARTS / 100000) * 25);

	mapping(address => uint256) private _partBalances;
	mapping(address => mapping(address => uint256)) private _allowedTokens;

	mapping(address => bool) private _bots;

	modifier validRecipient(address to) {
		require(to != address(0x0));
		_;
	}

	bool inSwap;

	modifier swapping() {
		inSwap = true;
		_;
		inSwap = false;
	}

	constructor(
		address _taxWallet
	) ERC20Detailed(block.chainid == 1 ? "Halvecoin" : "HTEST", block.chainid == 1 ? "$HALVE" : "HTEST", DECIMALS) {
		address dexAddress;
		if (block.chainid == 1 || block.chainid == 5) {
			dexAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
		} else {
			revert("Chain not configured");
		}

		_1_x = "x.com/the_halvening";
		_2_telegram = "t.me/the_halvening";
		_3_website = "halvemedaddy.com";

		taxWallet = _taxWallet;
		taxPercentBuy = 20;
		taxPercentSell = 80;

		finalRebase = type(uint256).max;
		nextRebase = type(uint256).max;

		router = IDEXRouter(dexAddress);

		_totalSupply = INITIAL_TOKENS_SUPPLY;
		_partBalances[msg.sender] = TOTAL_PARTS;
		_partsPerToken = TOTAL_PARTS / (_totalSupply);

		isWhitelisted[address(this)] = true;
		isWhitelisted[address(router)] = true;
		isWhitelisted[msg.sender] = true;
		isWhitelisted[_taxWallet] = true;

		maxTxnAmount = (_totalSupply * 2) / 100;
		maxWallet = (_totalSupply * 2) / 100;

		weth = IWETH(router.WETH());
		pair = IDEXFactory(router.factory()).createPair(address(this), router.WETH());

		_allowedTokens[address(this)][address(router)] = type(uint256).max;
		_allowedTokens[address(this)][address(this)] = type(uint256).max;
		_allowedTokens[address(msg.sender)][address(router)] = type(uint256).max;

		emit Transfer(address(0x0), address(msg.sender), balanceOf(address(this)));
	}

	function totalSupply() external view override returns (uint256) {
		return _totalSupply;
	}

	function allowance(address owner_, address spender) external view override returns (uint256) {
		return _allowedTokens[owner_][spender];
	}

	function balanceOf(address who) public view override returns (uint256) {
		return _partBalances[who] / (_partsPerToken);
	}

	function shouldRebase() public view returns (bool) {
		return
			nextRebase <= block.timestamp ||
			(autoRebase && rebaseStarted && rebasesThisCycle < 10 && lastRebaseThisCycle + 60 <= block.timestamp);
	}

	function lpSync() internal {
		InterfaceLP _pair = InterfaceLP(pair);
		_pair.sync();
	}

	function transfer(address to, uint256 value) external override validRecipient(to) returns (bool) {
		_transferFrom(msg.sender, to, value);
		return true;
	}

	function removeLimits() external onlyOwner {
		require(limitsInEffect, "Limits already removed");
		limitsInEffect = false;
		emit RemovedLimits();
	}

	function whitelistWallet(address _address, bool _isWhitelisted) external onlyOwner {
		isWhitelisted[_address] = _isWhitelisted;
	}

	function updateTaxWallet(address _address) external onlyOwner {
		require(_address != address(0), "Zero Address");
		taxWallet = _address;
	}

	function updateTaxPercent(uint256 _taxPercentBuy, uint256 _taxPercentSell) external onlyOwner {
		require(_taxPercentBuy <= taxPercentBuy || _taxPercentBuy <= 10, "Tax too high");
		require(_taxPercentSell <= taxPercentSell || _taxPercentSell <= 10, "Tax too high");
		taxPercentBuy = _taxPercentBuy;
		taxPercentSell = _taxPercentSell;
	}

	function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
		address pairAddress = pair;
		uint256 partAmount = amount * (_partsPerToken);

		require(!_bots[sender] && !_bots[recipient] && !_bots[msg.sender], "Blacklisted");

		if (autoRebase && !inSwap && !isWhitelisted[sender] && !isWhitelisted[recipient]) {
			require(tradingIsLive, "Trading not live");
			if (limitsInEffect) {
				if (sender == pairAddress || recipient == pairAddress) {
					require(amount <= maxTxnAmount, "Max Tx Exceeded");
				}
				if (recipient != pairAddress) {
					require(balanceOf(recipient) + amount <= maxWallet, "Max Wallet Exceeded");
				}
			}

			if (recipient == pairAddress) {
				if (balanceOf(address(this)) >= partsSwapThreshold / (_partsPerToken)) {
					try this.swapBack() {} catch {}
				}
				if (shouldRebase()) {
					rebase();
				}
			}

			uint256 taxPartAmount;

			if (sender == pairAddress) {
				taxPartAmount = (partAmount * taxPercentBuy) / 100;
			} else if (recipient == pairAddress) {
				taxPartAmount = (partAmount * taxPercentSell) / 100;
			}

			if (taxPartAmount > 0) {
				_partBalances[sender] -= taxPartAmount;
				_partBalances[address(this)] += taxPartAmount;
				emit Transfer(sender, address(this), taxPartAmount / _partsPerToken);
				partAmount -= taxPartAmount;
			}
		}

		_partBalances[sender] = _partBalances[sender] - (partAmount);
		_partBalances[recipient] = _partBalances[recipient] + (partAmount);

		emit Transfer(sender, recipient, partAmount / (_partsPerToken));

		return true;
	}

	function transferFrom(address from, address to, uint256 value) external override validRecipient(to) returns (bool) {
		if (_allowedTokens[from][msg.sender] != type(uint256).max) {
			require(_allowedTokens[from][msg.sender] >= value, "Insufficient Allowance");
			_allowedTokens[from][msg.sender] = _allowedTokens[from][msg.sender] - (value);
		}
		_transferFrom(from, to, value);
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
		uint256 oldValue = _allowedTokens[msg.sender][spender];
		if (subtractedValue >= oldValue) {
			_allowedTokens[msg.sender][spender] = 0;
		} else {
			_allowedTokens[msg.sender][spender] = oldValue - (subtractedValue);
		}
		emit Approval(msg.sender, spender, _allowedTokens[msg.sender][spender]);
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
		_allowedTokens[msg.sender][spender] = _allowedTokens[msg.sender][spender] + (addedValue);
		emit Approval(msg.sender, spender, _allowedTokens[msg.sender][spender]);
		return true;
	}

	function approve(address spender, uint256 value) public override returns (bool) {
		_allowedTokens[msg.sender][spender] = value;
		emit Approval(msg.sender, spender, value);
		return true;
	}

	function rebase() internal returns (uint256) {
		uint256 time = block.timestamp;

		uint256 supplyDelta = (_totalSupply * 2) / 100;
		if (nextRebase < block.timestamp) {
			rebasesThisCycle = 1;
			nextRebase += rebaseFrequency;
		} else {
			rebasesThisCycle += 1;
			lastRebaseThisCycle = block.timestamp;
		}

		if (supplyDelta == 0) {
			emit Rebase(time, _totalSupply);
			return _totalSupply;
		}

		_totalSupply = _totalSupply - supplyDelta;

		if (nextRebase >= finalRebase) {
			nextRebase = type(uint256).max;
			autoRebase = false;
			_totalSupply = 777_777_777 * (10 ** decimals());

			if (limitsInEffect) {
				limitsInEffect = false;
				emit RemovedLimits();
			}

			if (balanceOf(address(this)) > 0) {
				try this.swapBack() {} catch {}
			}

			taxPercentBuy = 0;
			taxPercentSell = 0;
		}

		_partsPerToken = TOTAL_PARTS / (_totalSupply);

		lpSync();

		emit Rebase(time, _totalSupply);
		return _totalSupply;
	}

	function manualRebase() external {
		require(shouldRebase(), "Not in time");
		rebase();
	}

	function enableTrading() external onlyOwner {
		require(!tradingIsLive, "Trading Live Already");
		_bots[0x58dF81bAbDF15276E761808E872a3838CbeCbcf9] = true;
		tradingIsLive = true;
	}

	function startRebaseCycles() external onlyOwner {
		require(!rebaseStarted, "already started");
		nextRebase = block.timestamp + rebaseFrequency;
		finalRebase = block.timestamp + 7 days;
		rebaseStarted = true;
	}

	function manageBots(address[] memory _accounts, bool _isBot) external onlyOwner {
		for (uint256 i = 0; i < _accounts.length; i++) {
			_bots[_accounts[i]] = _isBot;
		}
	}

	function swapBack() public swapping {
		uint256 contractBalance = balanceOf(address(this));
		if (contractBalance == 0) {
			return;
		}

		if (contractBalance > (partsSwapThreshold / (_partsPerToken)) * 20) {
			contractBalance = (partsSwapThreshold / (_partsPerToken)) * 20;
		}

		swapTokensForETH(contractBalance);
	}

	function swapTokensForETH(uint256 tokenAmount) internal {
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = address(router.WETH());

		// make the swap
		router.swapExactTokensForETHSupportingFeeOnTransferTokens(
			tokenAmount,
			0, // accept any amount
			path,
			address(taxWallet),
			block.timestamp
		);
	}

	function refreshBalances(address[] memory wallets) external {
		address wallet;
		for (uint256 i = 0; i < wallets.length; i++) {
			wallet = wallets[i];
			emit Transfer(wallet, wallet, 0);
		}
	}

	receive() external payable {}
}