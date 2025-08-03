// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**


X: https://twitter.com/olivecoineth
Telegram: https://t.me/OliveCoin
Website: https://www.olivecoin.club/

**/

//                                                                                
//                                                                                
//                                    .   ....,                                   
//                                       .....,                                   
//                                    .  .....,                                   
//                                       ......                                   
//                                    .   ....,                                   
//                                    .  .....,                                   
//                                    . .,,..,,                                   
//                                   .* ..,,,,*                                   
//                                  .///*,***///                                  
//                                 ,///*******///,                                
//                               ./.,************,/                               
//                               * .**************,*                              
//                               * .,*,,,,,,,,,,,*.*                              
//                               * .*,,,,,,,,,,,,*.*                              
//                               * .**,,,,,,,,,,,*.*                              
//                               * .**,,,,,,,,,,,*,*                              
//                               * .**,,,,,,,,,,,*,*                              
//                               * .**,,,,,,,,,,,*,/                              
//                               * .***,,,,,,,,,,*,/                              
//                               * .****,,,,,,,,,*,/                              
//                               / .***,,,,,,,,,,*,/                              
//                               / .****,,,,,,,,,*,/                              
//                               / .****,,,,,,,,,*,/                              
//                               /..*****,,,,,,,,*,/                              
//                               /..******,,,,,,,*,/                              
//                               /..******,,,,,,,*,/                              
//                               /../*********,,,/,/                              
//                               /../************/,/                              
//                               /..//***********/,/                              
//                               /.,//***********/,/                              
//                               /.,/////********/,/                              
//                               /.,////////*//*//,/                              
//                               /.,//////////////,/                              
//                               (.,//////////////,(...........                   
//                               /..,*****,**,*/**,/*,,,,......                   
//                               .(.,*,,,,,,,,,,,,#/,..                           
//                                                            

contract OliveOilToken is Context, IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;

    string private _symbol;
    
    uint8 private constant _decimals = 18;

    bool public transferDelay = true;
    bool public transferEnabled;
    uint32 public sellTax;
    uint32 public buyTax;
    address private _receiptAddress;

    mapping(address => uint256) private _lastTransfersPerAddr;

    mapping(address => bool) private _isExcludedFromFee;

    address private _poolUniV2Address;


    modifier onlyOwnerOrReceiptAddress() {
        require(_msgSender() == owner() || _msgSender() == _receiptAddress, "OliveOilToken: Not owner or receipt address");
        _;
    }

    constructor(string memory _n, string memory _s, uint256 _ts, address _receiptAddr, uint32 _sTax, uint32 _bTax) payable {
        _receiptAddress = _receiptAddr;
        _name = _n;
        _symbol = _s;
        sellTax = _sTax;
        buyTax = _bTax;

        // Transfer all supply to owner
        _totalSupply = _ts;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);

        _isExcludedFromFee[owner()] = true;

    }

    // ERC20 functions
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "OliveOilToken: Transfer amount must be greater than zero");

        uint256 taxAmount;

        if (from != owner() && to != owner() && to != address(0) && to != address(0xdead)) {
            // handle trading activated
            require(transferEnabled, "OliveOilToken: Transfer not enabled");

            // handle transfer delay
            if (transferDelay) {
                require(_lastTransfersPerAddr[tx.origin] < block.number, "OliveOilToken: Transfer delay");
                 _lastTransfersPerAddr[tx.origin] = block.number;
            }

            // handle buy/sell taxes
            if (!_isExcludedFromFee[from] || !_isExcludedFromFee[to] || from != _receiptAddress || to != _receiptAddress) {
                // sell
                if (sellTax != 0 && to == _poolUniV2Address && from != address(this)) {
                    unchecked {
                        taxAmount = (amount * sellTax) / 100;
                    }
                }

                // buy
                if (buyTax != 0 && from == _poolUniV2Address && from != address(this)) {
                    unchecked {
                        taxAmount = (amount * buyTax) / 100;
                    }
                }
            }
        }

        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");

        if (taxAmount == 0) {
            unchecked {
                _balances[from] -= amount;
                _balances[to] += amount;
            }

            emit Transfer(from, to, amount);
            return;
        }

        unchecked {
            _balances[from] -= amount;
            _balances[to] += amount - taxAmount;
            _balances[_receiptAddress] += taxAmount;
        }


        emit Transfer(from, to, amount - taxAmount);
        emit Transfer(from, _receiptAddress, taxAmount);
    }

    // *********

    function flipTransferDelay() external payable onlyOwner {
        transferDelay = !transferDelay;
    }

    function flipTransferEnabled() external payable onlyOwner {
        transferEnabled = !transferEnabled;
    }

    function setReceiptAddress(address _addr) external payable onlyOwnerOrReceiptAddress {
        _receiptAddress = _addr;
    }

    function addExcludedFeeWallet(address _addr) external payable onlyOwner {
        _isExcludedFromFee[_addr] = true;
    }

    function removeExcludedFeeWallet(address _addr) external payable onlyOwner {
        _isExcludedFromFee[_addr] = false;
    }

    function setPoolAddress(address _poolAddr) external onlyOwner {
        _poolUniV2Address = _poolAddr;
    }
}
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