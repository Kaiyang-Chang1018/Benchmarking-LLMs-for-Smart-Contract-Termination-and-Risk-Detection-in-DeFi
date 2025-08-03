// SPDX-License-Identifier: MIT

/**
     

Initializing OBELISK Protocol: A digital labyrinth where code is your compass and puzzles are your path. Engage in decryption sequences, trace hidden data trails, and compile clues to unlock ETH rewards. Only the most adept coders and cryptic solvers will conquer the system. Are you ready to debug, decipher, and deploy victory? Welcome to the OBELISK — the challenge starts now.

>GREEN11NEPHEWRED6RAWORANGE8BUS

Find us - https://obelisk10283.xyz/


                 .:~!7?JJJJ?7!~:.                 
             :!YG#&@@@@@@@@@@@@&#GY!:             
          ^JG&@@@@@@@@@@@@@@@@@@@@@@&GJ^          
        !G@@@@@@@@@@@@@@##@@@@@@@@@@@@@@G!        
      !B@@@@@@@@@@@@@&P7..?P&@@@@@@@@@@@@@B!      
    .5@@@@@@@@@@@@@GJ75^??~57JB@@@@@@@@@@@@@5.    
   ^B@@@@@@@@@@@#Y7JG@5~@@~5@GJ75#@@@@@@@@@@@B^   
  :#@@@@@@@@@&P??P&@@B:#@@B:B@@&P??P@@@@@@@@@@#:  
  G@@@@@@@@&J!Y#@@@@&^P@@@@5^&@@@@#Y!J&@@@@@@@@G  
 7@@@@@@@@@5.?J5#@@@7?@@@@@@?7@@@B5J?.5@@@@@@@@@! 
 P@@@@@@@@@Y~@#PJ?YJ:B######B:JY?JP#@~5@@@@@@@@@P 
.#@@@@@@@@@Y~@@@@&G.?5YYYYYY57.G&@@@@~5@@@@@@@@@B.
.B@@@@@@@@@Y~@@@@@@^G@@@@@@@@G^@@@@@@~5@@@@@@@@@B.
 P@@@@@@@@@Y~@@@@@@:G@@@@@@@@P^@@@@@@~5@@@@@@@@@P 
 !@@@@@@@@@Y~@@@@@@:G@@@@@@@@P^@@@@@@~5@@@@@@@@@! 
  G@@@@@@@@Y~@@@@@@:G@@@@@@@@P^@@@@@@~5@@@@@@@@G  
  :#@@@@@@@Y~@@@@@@:G@@@@@@@@P^@@@@@@~5@@@@@@@#:  
   ^B@@@@@@P^G&@@@@:G@@@@@@@@P^@@@@&P^P@@@@@@B^   
    .5@@@@@@BY??5#@^G@@@@@@@@G^@#5??5#@@@@@@5.    
      !B@@@@@@@#PJ?.JPPPPPPPPJ.?JP#@@@@@@@B!      
        !G@@@@@@@@&BGGGGGGGGGGB&@@@@@@@@G!.       
          ^JG&@@@@@@@@@@@@@@@@@@@@@@&GJ^          
             :!YG#&@@@@@@@@@@@@&#PJ!:             
                 .:~!7?JJJJ?7!~:.            

*/

pragma solidity ^0.8.19;

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract OBELISKOS is IERC20, Ownable {
    
    string private _name = "OBELISK OS";
    string private _symbol = "OBLSK";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1000000 * (10 ** decimals());

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor () {
        _balances[owner()] = _totalSupply;
	    emit Transfer(address(0), owner(), _totalSupply);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }               

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}