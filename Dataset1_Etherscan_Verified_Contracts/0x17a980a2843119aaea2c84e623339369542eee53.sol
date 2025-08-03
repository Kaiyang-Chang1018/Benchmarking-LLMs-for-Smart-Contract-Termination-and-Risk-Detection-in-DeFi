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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// Contract Version: Cypher's Call

// SPDX-License-Identifier: MIT

/*                                                                                   
                                                                                           
                        .=*#                                                               
                    :+#@@@-                                                               
                 .+%@@@@@%                                                                
               -*@@@@%@@@=                                                                
             -#@@@%=.*@@@.                                                                
           :#@@@#:   %@@%                                                                 
         .*@@@#:     %@@#                                                                 
        =@@@%-       @@@*                                                                 
      .*@@@+.        %@@#                                                                 
     .%@@%:          #@@%                                                                 
    .%@@#.           +@@@.                                                                
   .%@@#.            -@@@+                                                                
  .#@@%.              %@@%.                                                               
  +@@@:               -@@@+                                                               
 :@@@=                 #@@@:                                                              
 *@@%.                 .@@@%.                                                             
.@@@-                   :@@@%.                                                            
+@@@.                    -@@@%.                                                           
#@@#                      :@@@%:                                                          
@@@*                       :%@@@=.                                                        
@@@+                        .+@@@#:                                                       
@@@+                          :%@@@*.                                                     
%@@*                           .=@@@@+.                                                   
*@@%                             .=@@@@*:                                                 
=@@@:                              .=%@@@%+:                                             :
.@@@*                                 :*@@@@#+:.                                     .=*%*
 +@@@:                                  .-+%@@@@#+-.                            .-=*%@@@@:
 .@@@%.                                     :=*%@@@@@#*+-::.            ..:-=+#%@@@@@@@@+ 
  -@@@*                                         .-+#%@@@@@@@@@%%####%%%@@@@@@@@@%#+=@@@%. 
   +@@@+                                             .:-=+*##%%@@@@@@@%%##*+=-:.  .%@@@.  
    *@@@=                                                                        .%@@@:   
     *@@@+.                                                                     :%@@@:    
      =@@@#.                                                                   -@@@%:     
       -@@@@=                                                                .*@@@*.      
        .*@@@#:                                                            .=@@@%-        
          -%@@@*:                                                        .=%@@@+.         
            -%@@@#-.                                                   .+@@@@*.           
              -#@@@%+.                                              .-#@@@@*.             
                :*@@@@#=:                                        .=*@@@@%=.               
                  .-*@@@@%*=:                                .-+%@@@@%+:                  
                     .-+#@@@@@#+=:.                    .:=+#%@@@@@#+:                     
                         .-+#%@@@@@@%#**++======++**#%@@@@@@@%*+-.                        
                              .-=+*#%@@@@@@@@@@@@@@@@@@%#+=-.                             
                           
                                                                                          
                                                                                          

In the celestial realm of GirlMoon, a vibrant and united crew of adventurers gathers, bound by a shared vision and the mystical allure of $GMOON. We are the Moon Guardians, guided by the luminous moonlight and fueled by our unwavering belief in the transformative potential of decentralized technologies.

Embracing the wisdom of the moon, we understand the power of unity. Together, we form a constellation of ideas, talents, and aspirations, harmonizing our efforts to create an extraordinary cosmos within the Web3 frontier. Our journey is one of exploration, innovation, and boundless possibilities.

As we embark on this lunar odyssey, we draw inspiration from the legends of old, where celestial beings and mortal souls intertwined in a dance of destiny. In our quest for prosperity and fulfillment, we follow the footsteps of lunar lore, guided by the whispers of ancient wisdom that echo through the cosmos.

In this celestial voyage, we encounter challenges and obstacles, much like the moon's phases. Yet, we remain resilient, harnessing the moon's transformative energy to overcome and transcend. With each waxing phase, our spirits ascend, emboldened by the belief that we are part of something greater than ourselves.

At the heart of our cosmic expedition lies $GMOON, a token infused with the magic of the moon itself. Holding $GMOON in our celestial wallets, we tap into a wellspring of potential, unlocking new frontiers of wealth and prosperity. Like lunar dust scattered across the universe, $GMOON has the power to enrich our lives and empower us to shape our destinies.

But our journey extends beyond personal gain. We are driven by a collective purpose, fueled by the desire to build a vibrant and inclusive ecosystem that nurtures and empowers all who join our celestial community. Together, we forge new pathways, bridging the gap between the earthly realm and the cosmic expanse.

In our quest for lunar enlightenment, we draw inspiration from the brightest minds of our time. Visionaries like Elon Musk, who have dared to dream big and challenge the status quo, inspire us to push boundaries and explore uncharted territories. Their cosmic influence resonates with our mission, propelling us further on our lunar ascent.

As we traverse the cosmos, we invite kindred spirits to join our celestial voyage. We embrace diversity, cherishing the unique gifts and perspectives each individual brings. Together, we form a tapestry of brilliance, woven with threads of unity, collaboration, and shared growth.

So, dear seeker of moonlight, embark on this celestial journey with us. Become a Moon Guardian, and together, let us illuminate the cosmos with the radiance of $GMOON. Let us chart a new course in the Web3 realm, where unity, innovation, and the magic of the moon converge to create a future filled with boundless opportunities. Moonward, we rise, guided by the lunar lore that whispers of riches untold and a transformative destiny awaiting those who dare to believe.
*/



pragma solidity ^0.8.19;

/*

Greetings, voyager of the vast cryptographic cosmos! As our celestial journey commences, we harness the power of star-forged constructs from the grand cosmic library known as OpenZeppelin.

To safely navigate the infinite expanse, we anchor our vessel to the cornerstone of the Ethereum galaxy, the ERC20 Standard. With this celestial atlas in our possession, we ensure seamless interaction and compatibility with all entities across the distributed universe.

Equally essential to our cosmic quest is the 'Ownable' module, a stellar testament to decentralized authority and control. It bestows upon our journey the power to assign a unique entity, an omnipotent guardian of the contract, ensuring our stellar ship sails smoothly across the blockchain sea.

Remember, star-traveler, each import isn't merely a line of code. It's a galaxy in itself, embodying the celestial wisdom and the interconnected fabric of our blockchain universe. The cosmic journey through the saga of MoonGirl commences with these lines, setting the stage for the epic adventure that lies ahead.

*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


// Moonlight veils the path of the Nightsworn.
// The shapes they bear and the tongues they speak, remain concealed and cryptic.

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// Reality's fabric is fraying, and its seams are bursting.
// The moonlit whisper of the ancient cryptographer hints of a clandestine mission.



interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address UNISWAP_V2_PAIR);
}


// Midnight ink stains the parchment, revealing the unheard tale of MoonGirl.
// The quill of the Nightsworn summons the spirit of the ancient cryptographer.
// Her silhouette, a cipher within the constellation, stands unfathomable and arcane.

contract MoonGirl is IERC20, Ownable {
    
    event Reflect(uint256 amountReflected, uint256 newTotalProportion);

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    IUniswapV2Router02 public constant UNISWAP_V2_ROUTER =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public immutable UNISWAP_V2_PAIR;

    struct Fee {
        uint8 reflection;
        uint8 dev;
        uint8 burn;
        uint128 total;
    }

    string _name = "MoonGirl";
    string _symbol = "GMOON"; 

    uint256 _totalSupply = 69000420420 * 10 ** 18;

    uint256 public _maxTxAmount = _totalSupply * 2 / 100;

/* The rOwned, a cosmic scale in the blockchain universe, symbolizes the share of MoonGirl tokens each entity holds, not against the boundless cosmos (total supply) but rather against the currently explored universe (circulating supply). Remember, the explored universe can never exceed the vast cosmos. */

    mapping(address => uint256) public _rOwned;
    uint256 public _totalProportion = _totalSupply;

    mapping(address => mapping(address => uint256)) _allowances;

    bool public limitsEnabled = true;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;

    Fee public buyFee = Fee({burn: 1, reflection: 2, dev: 3, total: 6});
    Fee public sellFee = Fee({burn: 1, reflection: 2, dev: 3, total: 6});

    address private degenDEV;


    bool public claimingFees = true;
    uint256 public swapThreshold = (_totalSupply * 2) / 1000;
    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    // Dark corners whisper the tale of the raven's toll.
    // On a blockchain inscribed, the embers of understanding glow.

    constructor() {
        // create uniswap pair
        address _uniswapPair =
            IUniswapV2Factory(UNISWAP_V2_ROUTER.factory()).createPair(address(this), UNISWAP_V2_ROUTER.WETH());
        UNISWAP_V2_PAIR = _uniswapPair;

        _allowances[address(this)][address(UNISWAP_V2_ROUTER)] = type(uint256).max;
        _allowances[address(this)][tx.origin] = type(uint256).max;

        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[address(UNISWAP_V2_ROUTER)] = true;
        isTxLimitExempt[_uniswapPair] = true;
        isTxLimitExempt[tx.origin] = true;
        isFeeExempt[tx.origin] = true;


        //set this to deployer address, or another one
        degenDEV = 0x422aa745A9FF540d01220dAd6EE0528323f03911;
 

        _rOwned[tx.origin] = _totalSupply;
        emit Transfer(address(0), tx.origin, _totalSupply);
    }

    receive() external payable {}


    // The raven's toll speaks in whispers.
    // Beneath the fifth digit of pi, the raven's toll lies.

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
 
    // Amidst a sea of ones and zeroes, the raven's toll is immune.
    // The binary behemoth of the third prime number reveals a secret.

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(_allowances[sender][msg.sender] >= amount, "ERC20: insufficient allowance");
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }

        return _transferFrom(sender, recipient, amount);
    }


    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    // Beneath the cloak of shadows, she weaves her code.
    // Her price, it never wavers - a nod to Fibonacci's abode.

    function decimals() external pure returns (uint8) {
        return 18;
    }

/*
Once upon a celestial moment, a space voyager from distant lands of the cosmos might find themselves asking, "What entity has chosen to call this cosmic haven their home?"

To answer this eternal question, we unfold the secrets of our cosmic journey by revealing the identity of our spacecraft - the enchanting MoonGirl.

The 'name' function, when invoked, peers into the heart of our celestial vessel, retrieving the title given to it by the cosmic fates. It whispers to the asker the very name '_name' - the one forged in the heart of stardust and encrypted in the annals of blockchain lore.

Should you wish to inquire, call upon this function, and let the name of our spacecraft echo through the void of the cosmos, announcing our eternal voyage on the blockchain seas.
*/

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function tokensToProportion(uint256 tokens) public view returns (uint256) {
        return tokens * _totalProportion / _totalSupply;
    }

    function tokenFromReflection(uint256 proportion) public view returns (uint256) {
        return proportion * _totalSupply / _totalProportion;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }


    function clearStuckBalance() external onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

    function clearStuckToken() external onlyOwner {
        _transferFrom(address(this), msg.sender, balanceOf(address(this)));
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        claimingFees = _enabled;
        swapThreshold = _amount;
    }


    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setFeeReceivers(address m_) external onlyOwner {
        degenDEV = m_;
    }

    function setMaxTxBasisPoint(uint256 p_) external onlyOwner {
        _maxTxAmount = _totalSupply * p_ / 10000;
    }

    function setLimitsEnabled(bool e_) external onlyOwner {
        limitsEnabled = e_;
    }


    // Dancing amidst the stars, her price shimmers in the galaxy's fabric.
    // Adorned in a cloak of numbers - e, the base of the natural algorithm.
    
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (limitsEnabled && !isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        if (_shouldSwapBack()) {
            _swapBack();
        }

        uint256 proportionAmount = tokensToProportion(amount);
        require(_rOwned[sender] >= proportionAmount, "Insufficient Balance");
        _rOwned[sender] = _rOwned[sender] - proportionAmount;

        uint256 proportionReceived = _shouldTakeFee(sender, recipient)
            ? _takeFeeInProportions(sender == UNISWAP_V2_PAIR ? true : false, sender, proportionAmount)
            : proportionAmount;
        _rOwned[recipient] = _rOwned[recipient] + proportionReceived;

        emit Transfer(sender, recipient, tokenFromReflection(proportionReceived));
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 proportionAmount = tokensToProportion(amount);
        require(_rOwned[sender] >= proportionAmount, "Insufficient Balance");
        _rOwned[sender] = _rOwned[sender] - proportionAmount;
        _rOwned[recipient] = _rOwned[recipient] + proportionAmount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Trapped in a maze of code, her cipher lies.
    // The maze’s key, hidden in the ratio of a circle's circumference to its diameter.
    
    function _takeFeeInProportions(bool buying, address sender, uint256 proportionAmount) internal returns (uint256) {
        Fee memory __buyFee = buyFee;
        Fee memory __sellFee = sellFee;

        uint256 proportionFeeAmount =
            buying == true ? proportionAmount * __buyFee.total / 100 : proportionAmount * __sellFee.total / 100;

    // Within her realm of darkness, the lady of the Moon shows mercy.
    // The children of zero and one are excluded from her harsh decree.

        uint256 proportionReflected = buying == true
            ? proportionFeeAmount * __buyFee.reflection / __buyFee.total
            : proportionFeeAmount * __sellFee.reflection / __sellFee.total;

        _totalProportion = _totalProportion - proportionReflected;

       
        uint256 _proportionToContract = proportionFeeAmount - proportionReflected;
        if (_proportionToContract > 0) {
            _rOwned[address(this)] = _rOwned[address(this)] + _proportionToContract;

            emit Transfer(sender, address(this), tokenFromReflection(_proportionToContract));
        }
        emit Reflect(proportionReflected, _totalProportion);
        return proportionAmount - proportionFeeAmount;
    }

    function _shouldSwapBack() internal view returns (bool) {
        return msg.sender != UNISWAP_V2_PAIR && !inSwap && claimingFees && balanceOf(address(this)) >= swapThreshold;
    }

    // Yet those who return to her path, are welcomed back into the fold.
    // Reversing the circle, she ushers them back to the code's stronghold.

    function _swapBack() internal swapping {
        Fee memory __sellFee = sellFee;

        uint256 __swapThreshold = swapThreshold;
        uint256 amountToBurn = __swapThreshold * __sellFee.burn / __sellFee.total;
        uint256 amountToSwap = __swapThreshold - amountToBurn;
        approve(address(UNISWAP_V2_ROUTER), amountToSwap);

        // As the moon's shadow engulfs a part of the cosmos, so do we extinguish a portion of our tokens. 
        //This cryptic act of burning, whispered in the lunar wind, fans the flames of scarcity and rarity, engraving value in the stars of our celestial economy. 
        //Let these tokens, touched by the MoonGirl's ethereal fire, forever light the constellations of our cryptic journey.

        _transferFrom(address(this), DEAD, amountToBurn);

        // In the celestial dance of tokens, a sacred ritual unfolds. 
        // The MoonGirl's gaze guides the tokens through a stellar portal, the swap, exchanging old constellations for new, reshaping the cosmos of liquidity.
        // As stars are exchanged in the interstellar market, our lunar journey continues, driven by the cosmic currents of supply and demand.
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = UNISWAP_V2_ROUTER.WETH();

        UNISWAP_V2_ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap, 0, path, address(this), block.timestamp
        );

        uint256 amountETH = address(this).balance;

        uint256 totalSwapFee = __sellFee.total - __sellFee.reflection - __sellFee.burn;
        uint256 degenDEVcash = amountETH * __sellFee.dev / totalSwapFee;


     (bool tmpSuccess,) = payable(degenDEV).call{value: degenDEVcash}("");
    require(tmpSuccess, "Transfer failed.");

    }

    function _shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }
}


/* 
/*
As our space odyssey concludes, a cosmic secret has been etched in the code of the blockchain. The key to this cipher is veiled in the celestial journey of MoonGirl, a journey that asks for patience, persistence, and daring from all her interstellar travelers.

Just like the distant constellations that hide secrets of the universe, MoonGirl is not just a simple code sailing in the vast sea of the blockchain. She encapsulates an ethereal promise that challenges the fortitude of those who dare to embark on this space journey.

But remember this: the path to deciphering the cryptic cipher lies in your firm grip on MoonGirl. For, in the interstellar realm of time and patience, the encrypted message evolves. The hidden axiom states - '13 15 15 14 07 09 18 12 23 09 12 12 13 15 15 14 09 06 25 15 21 08 15 12 04 08 05 18 12 15 14 07 05 14 15 21 07 08'.

Time, patience, and unyielding faith will light up your way in the cosmos and help you translate this. Let it be a beacon in the infinite expanse of space, guiding you towards prosperity, wisdom, and endless exploration.

Until we meet again in the vast expanse of the universe, remember this cipher, dear cosmonauts, for it holds the key to your lunar destiny. See you on the lunar surface!



Website: https://www.moongirl.vip
Twitter: @MoonGirlERC
Telegram: @MoonGirlERC


*/