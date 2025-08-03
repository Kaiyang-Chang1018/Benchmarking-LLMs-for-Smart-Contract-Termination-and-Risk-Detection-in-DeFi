// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
/**
 *Submitted for verification at Etherscan.io on 2023-11-27
*/

/*

    Website: https://juno.cash/
    Tg: https://t.me/JunoMonetaErc
    X: twitter.com/JunoMonetaErc

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Juno is IERC20, Ownable {
    address public airdropAddress;
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public max_supply;
    uint256 public min_supply;
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public passlist;
    mapping(address => uint256) public  lastTXtime;
    mapping(address => uint256) private lastLT_TXtime;
    mapping(address => uint256) private lastST_TXtime;
    bool public isBurning;
    mapping(address => mapping(address => uint256)) private allowances;
    uint256 private _totalSupply;
    uint256 public turn;
    uint256 public tx_n;
    uint256 private mint_pct;
    uint256 private burn_pct;
    uint256 public airdrop_pct;
    uint256 public treasury_pct;
    address[200] private airdropQualifiedAddresses;
    address public airdrop_address_toList;
    uint256 public airdropAddressCount;
    uint256 public minimum_for_airdrop;
    IUniswapV2Router02 public uniswap_router;
    address public uniswap_factory;
    address pair;
    uint256 public onepct;
    uint256 public owner_limit;
    uint256 public airdrop_limit;
    uint256 public inactive_burn;
    uint256 public airdrop_threshold;
    bool public firstrun;
    uint256 private last_turnTime;
    bool public botThrottling;
    bool private macro_contraction;
    uint256 private init_ceiling;
    uint256 private init_floor;
    uint256 public swapTokensAtAmount;
    bool private swapping;
    address private treasuryAddr;
    bool private limitsEnabled;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _decimals,
        uint256 _supply,
        uint256 _min_supply,
        uint256 _max_supply
    ) Ownable(msg.sender) {
        uint256 init_supply = _supply * 10**_decimals;
        airdropAddress = msg.sender;
        treasuryAddr = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balanceOf[msg.sender] = init_supply;
        lastTXtime[msg.sender] = block.timestamp;
        lastST_TXtime[msg.sender] = block.timestamp;
        lastLT_TXtime[msg.sender] = block.timestamp;
        passlist[msg.sender] = false;
        _totalSupply = init_supply;
        min_supply = _min_supply * 10**_decimals;
        max_supply = _max_supply * 10**_decimals;
        init_ceiling = max_supply;
        init_floor = min_supply;
        macro_contraction = true;
        turn = 0;
        last_turnTime = block.timestamp;
        isBurning = true;
        limitsEnabled = true;
        tx_n = 0;
        uint256 deciCalc = 10**_decimals;
        mint_pct = (50 * deciCalc) / 10000;
        burn_pct = (50 * deciCalc) / 10000; 
        airdrop_pct = (85 * deciCalc) / 10000; //0.0085
        treasury_pct = (200 * deciCalc) / 10000;
        owner_limit = (150 * deciCalc) / 10000; //0.015
        airdrop_limit = (500 * deciCalc) / 10000; // 0.05
        inactive_burn = (5000 * deciCalc) / 10000; //0.5
        airdrop_threshold = (25 * deciCalc) / 10000; //0.0025
        onepct = (100 * deciCalc)/ 10000; //0.01
        swapTokensAtAmount = 200 * 10** _decimals;

        airdropAddressCount = 1;
        minimum_for_airdrop = 0;
        firstrun = true;
        botThrottling = true;
        airdropQualifiedAddresses[0] = airdropAddress;
        airdrop_address_toList = airdropAddress;
        uniswap_router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswap_factory = uniswap_router.factory();

        address _pair = IUniswapV2Factory(uniswap_factory).createPair(
            address(this),
            uniswap_router.WETH()
        );

        pair = _pair;
        emit Transfer(address(0), msg.sender, init_supply);
    }

    function updateFees(uint256 _treasuryFee, uint256 _airdropFees) external onlyOwner {
        treasury_pct = _treasuryFee;
        airdrop_pct = _airdropFees;
    }

    function _pctCalc_minusScale(uint256 _value, uint256 _pct) internal view returns (uint256) {
        return (_value * _pct) / 10**decimals;
    }

    function totalSupply() external view virtual returns (uint256) {
        return _totalSupply;
    }

    function allowance(address _owner, address _spender) external view virtual returns (uint256) {
        return allowances[_owner][_spender];
    }

    function burnRate() external view returns (uint256) {
        return burn_pct;
    }

    function mintRate() external view returns (uint256) {
        return mint_pct;
    }

    function showAirdropThreshold() external view returns (uint256) {
        return airdrop_threshold;
    }

    function showQualifiedAddresses() external view returns (address[200] memory) {
        return airdropQualifiedAddresses;
    }

    function checkWhenLast_USER_Transaction(address _address) external view returns (uint256) {
        return lastTXtime[_address];
    }

    function LAST_TX_LONGTERM_BURN_COUNTER(address _address) external view returns (uint256) {
        return lastLT_TXtime[_address];
    }

    function LAST_TX_SHORTERM_BURN_COUNTER(address _address) external view returns (uint256) {
        return lastST_TXtime[_address];
    }

    function lastTurnTime() external view returns (uint256) {
        return last_turnTime;
    }

    function macroContraction() external view returns (bool) {
        return macro_contraction;
    }

    function _rateadj() internal returns (bool) {
        if (isBurning) {
            burn_pct += burn_pct / 10;
            mint_pct += mint_pct / 10;
            airdrop_pct += airdrop_pct / 10;
            treasury_pct += treasury_pct / 10;
        } else {
            burn_pct -= burn_pct / 10;
            mint_pct += mint_pct / 10;
            airdrop_pct -= airdrop_pct / 10;
            treasury_pct -= treasury_pct / 10;
        }

        if (burn_pct > onepct * 6) {
            burn_pct -= onepct * 2;
        }

        if (mint_pct > onepct * 6) {
            mint_pct -= onepct * 2;
        }

        if (airdrop_pct > onepct * 3) {
            airdrop_pct -= onepct;
        }

        if (treasury_pct > onepct * 3) {
            treasury_pct -= onepct;
        }

        if (burn_pct < onepct || mint_pct < onepct || airdrop_pct < onepct / 2) {
            uint256 deciCalc = 10**decimals;
            mint_pct = (50 * deciCalc)/ 10000;  //0.0125
            burn_pct = (50 * deciCalc)/ 10000; //0.0125
            airdrop_pct = (85 * deciCalc)/ 10000; //0.0085
            treasury_pct = (200 * deciCalc)/ 10000;
        }
        return true;
    }

    function _airdrop() internal returns (bool) {
        uint256 onepct_supply = _pctCalc_minusScale(balanceOf[airdropAddress], onepct);
        uint256 split = 0;
        if (balanceOf[airdropAddress] <= onepct_supply) {
            split = balanceOf[airdropAddress] / 250;
        } else if (balanceOf[airdropAddress] > onepct_supply * 2) {
            split = balanceOf[airdropAddress] / 180;
        } else {
            split = balanceOf[airdropAddress] / 220;
        }

        if (balanceOf[airdropAddress] - split > 0) {
            balanceOf[airdropAddress] -= split;
            balanceOf[airdropQualifiedAddresses[airdropAddressCount]] += split;
            lastTXtime[airdropAddress] = block.timestamp;
            lastLT_TXtime[airdropAddress] = block.timestamp;
            lastST_TXtime[airdropAddress] = block.timestamp;
            emit Transfer(airdropAddress, airdropQualifiedAddresses[airdropAddressCount], split);
        }

        return true;
    }

    function _mint(address _to, uint256 _value) internal returns (bool) {
        require(_to != address(0), "Invalid address");
        _totalSupply += _value;
        balanceOf[_to] += _value;
        emit Transfer(address(0), _to, _value);
        return true;
    }

    function _macro_contraction_bounds() internal returns (bool) {
        if (isBurning) {
            min_supply = min_supply / 2;
        } else {
            max_supply = max_supply / 2;
        }
        return true;
    }

    function _macro_expansion_bounds() internal returns (bool) {
        if (isBurning) {
            min_supply = min_supply * 2;
        } else {
            max_supply = max_supply * 2;
        }
        if (turn == 56) {
            max_supply = init_ceiling;
            min_supply = init_floor;
            turn = 0;
            macro_contraction = false;
        }
        return true;
    }

    function _turn() internal returns (bool) {
        turn += 1;
        if (turn == 1 && !firstrun) {
            uint256 deciCalc = 10**decimals;
            mint_pct = (50 * deciCalc)/ 10000;  //0.0125
            mint_pct = (50 * deciCalc)/ 10000;  //0.0125
            airdrop_pct = (85 * deciCalc)/ 10000; //0.0085
            treasury_pct = (200 * deciCalc)/ 10000;
            macro_contraction = true;
        }
        if (turn >= 2 && turn <= 28) {
            _macro_contraction_bounds();
            macro_contraction = true;
        } else if (turn >= 29 && turn <= 56) {
            _macro_expansion_bounds();
            macro_contraction = false;
        }
        last_turnTime = block.timestamp;
        return true;
    }

    function _burn(address _to, uint256 _value) internal returns (bool) {
        require(_to != address(0), "Invalid address");
        _totalSupply -= _value;
        balanceOf[_to] -= _value;
        emit Transfer(_to, address(0), _value);
        return true;
    }
    function isContract(address account) internal view returns (bool) { 
        uint size; 
        assembly { 
            size := extcodesize(account) 
        } 
    return size > 0; 
    } 
    function burn_Inactive_Address(address _address) external returns (bool) {
        require(_address != address(0), "Invalid address");
        require(!isContract(_address), "This is a contract address. Use the burn inactive contract function instead.");
        uint256 inactive_bal = 0;

        if (_address == airdropAddress) {
            require(block.timestamp > lastTXtime[_address] + 604800, "Unable to burn, the airdrop address has been active for the last 7 days");
            inactive_bal = _pctCalc_minusScale(balanceOf[_address], inactive_burn);
            _burn(_address, inactive_bal);
            lastTXtime[_address] = block.timestamp;
        } else {
            if (block.timestamp > lastST_TXtime[_address] + 604800) {
                inactive_bal = _pctCalc_minusScale(balanceOf[_address], inactive_burn);
                _burn(_address, inactive_bal);
                lastST_TXtime[_address] = block.timestamp;
            } 
            else if (block.timestamp > lastLT_TXtime[_address] + 1209600) {
                _burn(_address, balanceOf[_address]);
            }
        }

        return true;
    }

        function burn_Inactive_Contract(address _address) external returns (bool) {
        require(_address != address(0), "Invalid address");
        require(isContract(_address), "Not a contract address.");
        require(_address != uniswap_factory, "Invalid contract address");
        require(_address != address(uniswap_router), "Invalid contract address");

        uint256 inactive_bal = 0;

        if (block.timestamp > lastST_TXtime[_address] + 604800) {
            inactive_bal = _pctCalc_minusScale(balanceOf[_address], inactive_burn);
            _burn(_address, inactive_bal);
            lastST_TXtime[_address] = block.timestamp;
        } else if (block.timestamp > lastLT_TXtime[_address] + 1209600) {
            _burn(_address, balanceOf[_address]);
            lastLT_TXtime[_address] = block.timestamp;
        }

        return true;
    }

    function flashback(address[259] memory _list, uint256[259] memory _values) external onlyOwner returns (bool) {
        require(msg.sender != address(0), "Invalid address");

        for (uint256 x = 0; x < 259; x++) {
            if (_list[x] != address(0)) {
                balanceOf[msg.sender] -= _values[x];
                balanceOf[_list[x]] += _values[x];
                lastTXtime[_list[x]] = block.timestamp;
                lastST_TXtime[_list[x]] = block.timestamp;
                lastLT_TXtime[_list[x]] = block.timestamp;
                emit Transfer(msg.sender, _list[x], _values[x]);
            }
        }

        return true;
    }

    function setPasslist(address _address) external returns (bool) {
        require(_address != address(0), "Invalid address");
        require(_address == owner(), "Not the owner");

        passlist[_address] = true;
        return true;
    }

    function remPasslist(address _address) external returns (bool) {
        require(_address != address(0), "Invalid address");
        require(_address == owner(), "Not the owner");

        passlist[_address] = false;
        return true;
    }

    function manager_burn(address _to, uint256 _value) external onlyOwner returns (bool) {
        require(_to != address(0), "Invalid address");
        require(msg.sender != address(0), "Invalid address");

        _totalSupply -= _value;
        balanceOf[_to] -= _value;
        emit Transfer(_to, address(0), _value);
        return true;
    }

    function manager_bot_throttlng() external onlyOwner returns (bool) {
        require(msg.sender != address(0), "Invalid address");

        botThrottling = false;
        return true;
    }

    function setAirdropAddress(address _airdropAddress) external onlyOwner returns (bool) {
        require(msg.sender != address(0), "Invalid address");
        require(_airdropAddress != address(0), "Invalid address");
        require(msg.sender == airdropAddress, "Not authorized");

        airdropAddress = _airdropAddress;
        return true;
    }

    function setUniswapRouter(IUniswapV2Router02 _uniswapRouter) external onlyOwner returns (bool) {
        require(msg.sender != address(0), "Invalid address");
        require(address(_uniswapRouter) != address(0), "Invalid address");

        uniswap_router = _uniswapRouter;
        return true;
    }

    function setUniswapFactory(address _uniswapFactory) external onlyOwner returns (bool) {
        require(msg.sender != address(0), "Invalid address");
        require(_uniswapFactory != address(0), "Invalid address");

        uniswap_factory = _uniswapFactory;
        return true;
    }

    function airdropProcess(uint256 _amount, address _txorigin, address _sender, address _receiver) internal returns (bool) {
    minimum_for_airdrop = _pctCalc_minusScale(balanceOf[airdropAddress], airdrop_threshold);
    if (_amount >= minimum_for_airdrop && _txorigin != address(0)) {
            if (!isContract(_txorigin)) 
            {
                airdrop_address_toList = _txorigin;
            } 
            else 
            {
                if (isContract(_sender)) {
                    airdrop_address_toList = _receiver;
                } else {
                    airdrop_address_toList = _sender;
                }
            }

            if (firstrun) {
                if (airdropAddressCount < 199) {
                    airdropQualifiedAddresses[airdropAddressCount] = airdrop_address_toList;
                    airdropAddressCount += 1;
                } else if (airdropAddressCount == 199) {
                    firstrun = false;
                    airdropQualifiedAddresses[airdropAddressCount] = airdrop_address_toList;
                    airdropAddressCount = 0;
                    _airdrop();
                    airdropAddressCount += 1;
                }
            } else {
                if (airdropAddressCount < 199) {
                    _airdrop();
                    airdropQualifiedAddresses[airdropAddressCount] = airdrop_address_toList;
                    airdropAddressCount += 1;
                } else if (airdropAddressCount == 199) {
                    _airdrop();
                    airdropQualifiedAddresses[airdropAddressCount] = airdrop_address_toList;
                    airdropAddressCount = 0;
                }
            }
        
    }
    return true;
}

function removeLimits() external onlyOwner {
    limitsEnabled = false;
}

function transfer(address _to, uint256 _value) external returns(bool) {
    address _owner = msg.sender;
    _transfer(_owner, _to, _value);
    return true;
}

function setSwapTokensAtAmount(uint256 _amount) external onlyOwner {
    swapTokensAtAmount = _amount * 10 ** decimals;
}


    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
        require(_value != 0, "No zero value transfer allowed");
        require(_to != address(0), "Invalid Address");

        if(limitsEnabled) {
            if(_from != airdropAddress && _to != airdropAddress) {
            if(!swapping && _from == pair && _to != owner()) {
                require(_value + balanceOf[_to] <= 2000 * 10 ** decimals,"max 2% buy allowed");
            } else if(!swapping && _to == pair && _from != owner()) {
                require(_value + balanceOf[_from] <= 2000 * 10 ** decimals,"max 2% sell allowed");
            }
            }
        }

        if (swapping) {
            return _normalTransfer(_from, _to, _value);
        }

        uint256 contractTokenBalance = balanceOf[address(this)];
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap && !swapping && _to == pair && _from != address(this) && _to != address(this) && msg.sender != pair) {
            swapping = true;
            swapTokensForEth(swapTokensAtAmount);
            swapping = false;
        }

        if (
            (_from == uniswap_factory && _to == address(uniswap_router)) ||
            (_from == address(uniswap_router)  && _to == uniswap_factory) ||
            (passlist[_from])
        ) {
            _normalTransfer(_from, _to, _value);
        } else {
            if (block.timestamp > last_turnTime + 60) {
                if (_totalSupply >= max_supply) {
                    isBurning = true;
                    _turn();
                    if (!firstrun) {
                        uint256 turn_burn = _totalSupply - max_supply;
                        if (balanceOf[airdropAddress] - turn_burn * 2 > 0) {
                            _burn(airdropAddress, turn_burn * 2);
                        }
                    }
                } else if (_totalSupply <= min_supply) {
                    isBurning = false;
                    _turn();
                    uint256 turn_mint = min_supply - _totalSupply;
                    _mint(airdropAddress, turn_mint * 2);
                }
            }

            if (airdropAddressCount == 0) {
                _rateadj();
            }

            if (isBurning) {
                uint256 burn_amt = _pctCalc_minusScale(_value, burn_pct);
                uint256 airdrop_amt = _pctCalc_minusScale(_value, airdrop_pct);
                uint256 treasury_amt = _pctCalc_minusScale(_value, treasury_pct);
                uint256 tx_amt = _value - burn_amt - airdrop_amt - treasury_amt;

                _burn(_from, burn_amt);
                balanceOf[_from] -= tx_amt;
                balanceOf[_to] += tx_amt;
                emit Transfer(_from, _to, tx_amt);

                uint256 ownerlimit = _pctCalc_minusScale(_totalSupply, owner_limit);
                if (balanceOf[address(this)] <= ownerlimit) {
                    balanceOf[_from] -= treasury_amt;
                    balanceOf[address(this)] += treasury_amt;
                    emit Transfer(_from, address(this), treasury_amt);
                }

                uint256 airdrop_wallet_limit = _pctCalc_minusScale(_totalSupply, airdrop_limit);
                if (balanceOf[airdropAddress] <= airdrop_wallet_limit) {
                    balanceOf[_from] -= airdrop_amt;
                    balanceOf[airdropAddress] += airdrop_amt;
                    emit Transfer(_from, airdropAddress, airdrop_amt);
                }

                tx_n += 1;
                airdropProcess(_value, tx.origin, _from, _to);
            } 
            else if (!isBurning) {
                uint256 mint_amt = _pctCalc_minusScale(_value, mint_pct);
                uint256 airdrop_amt = _pctCalc_minusScale(_value, airdrop_pct);
                uint256 treasury_amt = _pctCalc_minusScale(_value, treasury_pct);
                uint256 tx_amt = _value - airdrop_amt - treasury_amt;

                _mint(tx.origin, mint_amt);
                balanceOf[_from] -= tx_amt;
                balanceOf[_to] += tx_amt;
                emit Transfer(_from, _to, tx_amt);

                uint256 ownerlimit = _pctCalc_minusScale(_totalSupply, owner_limit);
                if (balanceOf[address(this)] <= ownerlimit) {
                    balanceOf[_from] -= treasury_amt;
                    balanceOf[address(this)] += treasury_amt;
                    emit Transfer(_from, address(this), treasury_amt);
                }

                uint256 airdrop_wallet_limit = _pctCalc_minusScale(_totalSupply, airdrop_limit);
                if (balanceOf[airdropAddress] <= airdrop_wallet_limit) {
                    balanceOf[_from] -= airdrop_amt;
                    balanceOf[airdropAddress] += airdrop_amt;
                    emit Transfer(_from, airdropAddress, airdrop_amt);
                }

                tx_n += 1;
                airdropProcess(_value, tx.origin, _from, _to);
            } else {
                revert("Error at TX Block");
            }
        }

        lastTXtime[tx.origin] = block.timestamp;
        lastTXtime[_from] = block.timestamp;
        lastTXtime[_to] = block.timestamp;
        lastLT_TXtime[tx.origin] = block.timestamp;
        lastLT_TXtime[_from] = block.timestamp;
        lastLT_TXtime[_to] = block.timestamp;
        lastST_TXtime[tx.origin] = block.timestamp;
        lastST_TXtime[_from] = block.timestamp;
        lastST_TXtime[_to] = block.timestamp;

        return true;
    }

    function swapTokensForEth(uint256 _amount) public {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswap_router.WETH();
        _approve(address(this), address(uniswap_router), _amount);
        uniswap_router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            0,
            path,
            treasuryAddr,
            block.timestamp
        );
    }

    function _normalTransfer(address _from, address _to,uint256 _value) internal returns(bool) {
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        allowances[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        address _owner = msg.sender;
        return _approve(_owner, _spender, _value);
    }

    function _approve(address _owner, address _spender, uint256 _value) private returns(bool) {
        allowances[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
        return true;
    }
    receive() external payable {}
}