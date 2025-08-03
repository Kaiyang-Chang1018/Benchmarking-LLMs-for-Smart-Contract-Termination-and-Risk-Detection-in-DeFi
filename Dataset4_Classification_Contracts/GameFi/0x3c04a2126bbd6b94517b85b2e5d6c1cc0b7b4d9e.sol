// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Locker {
	uint256 public counter;
	address[] public tokens;
	address public usdt;

	event GameFinalized(
		uint48 indexed gameNumber, 
		address indexed looserToken, 
		address indexed winnerToken, 
		uint256 looserAmount0, 
		uint256 looserAmount1, 
		uint256 winnerAmount0, 
		uint256 winnerAmount1, 
		uint256 prize
	);
	
	event CounterUpdate(address op, uint256 oldValue, uint256 newValue, uint256 blockNumber);

	event Event1(uint256 indexed gameNumber, address indexed winner, address indexed loser, uint256 counter);
	event Event2(uint256 indexed gameNumber, address indexed winner, address indexed loser, uint256 counter);
	event Event3(uint256 indexed gameNumber, address indexed winner, address indexed loser, uint256 counter);
	 
	event TokenCreated(address launcher, address token);
	event LaunchEvent(address indexed token, uint256 usdtAmount, uint256 tokenAmount, uint256 liquidity);
	event PurchaseEvent(address indexed from, uint256 usdtAmount, uint256 tokenAmount);
	event RefundEvent(address indexed from, uint256 tokenAmount, uint256 usdtAmount);
	
	error CounterUnexpect(uint256 expected, uint256 actual);

	constructor() {
        usdt = address(0x55d398326f99059fF775485246999027B3197955);
    }

  	function initialize() public {
  	} 
  	
 	function emitGameFinalized(address looserToken, address winnerToken) public {
		counter++; 
 		emit GameFinalized(1, looserToken, winnerToken, 0, 0, 0, 0, 0);
 	}    

	function emitEvent1() public {
		counter++;
 		address high = address(0);
 		address low = address(this);
 		emit Event1(1, high, low, counter);
 	}    

	function emitEvent2And3() public {
		counter++;
 		address high = address(0);
 		address low = address(this);
 		emit Event2(2, high, low, counter);
		emit Event3(3, high, low, counter);
 	}    
 
	function setCounter(uint256 counter_) public {
		uint256 oldValue = counter;
		counter = counter_;
		emit CounterUpdate(msg.sender, oldValue, counter, block.number);
	}

	function compareAndSetCounter(uint256 oldValue, uint256 newValue) public {
		if (counter != oldValue) {
			revert CounterUnexpect(counter, oldValue);
		}
		counter = newValue;
		emit CounterUpdate(msg.sender, oldValue, counter, block.number);
	}
 
	function emitTokenCreated(address launcher, address token) public {
		emit TokenCreated(launcher, token);
	}

	function emitLaunchEvent(address token, uint256 usdtAmount, uint256 tokenAmount, uint256 liquidity) public {
		emit LaunchEvent(token, usdtAmount, tokenAmount, liquidity);
	}
	
	function emitPurchaseEvent(address from, uint256 usdtAmount, uint256 tokenAmount) public {
		emit PurchaseEvent(from, usdtAmount, tokenAmount);
	}
	
	function emitRefundEvent(address from, uint256 tokenAmount, uint256 usdtAmount) public {
		emit RefundEvent(from, tokenAmount, usdtAmount);
	}

	function addToken(address token) public {
		tokens.push(address(token));
	}

	function getTokens() external view returns (address[] memory) {
        address[] memory result = new address[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            result[i] = tokens[i];
        }
        return result;
    } 
}