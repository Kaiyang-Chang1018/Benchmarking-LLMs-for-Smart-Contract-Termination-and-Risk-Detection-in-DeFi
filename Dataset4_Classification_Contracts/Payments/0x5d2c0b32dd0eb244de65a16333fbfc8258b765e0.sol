// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
//submitted for verification on etherscan 6/November/2024
//telegram  https://t.me/MEGATrumpOnEth
//website https://www.megatrumpeth.com/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract Mega is IERC20, IERC20Metadata, ReentrancyGuard{
    using Address for address payable;
    address public pair;
    bool public tradingEnabled = false;
    uint256 public maxBuyLimit; //3%
    uint256 public maxSellLimit ; //1%
    uint256 public maxWalletLimit ; //3%
    uint256 public genesis_block;
    address public marketingWallet = 0xdcdcE964ACDE6644C94A23cAdD3cA03220923F76;
    address public uniswapRouterv2Address = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    uint256 public buyMarkeetingTax = 3; // 3% => taxes
    uint256 public sellMarkeetingTax = 5; // 5% => sell 
    mapping(address => bool) public isAdded;
    address[] public uniqueAddresses;
    event AddressAdded(address indexed addr);
    string public name = "MEGATRUMP";
    string public symbol = "MEGATRUMP";
    uint8 public decimals = 18;
    address private _owner;
    uint256 private _totalSupply = 47000000000 * 10**uint256(decimals);
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public exemptFee;
    constructor() {
        _balances[msg.sender] = _totalSupply;
        exemptFee[address(this)] = true;
        exemptFee[ msg.sender] = true;
        exemptFee[marketingWallet] = true;
        exemptFee[uniswapRouterv2Address] = true;
        _owner = msg.sender; 
        uniqueAddresses.push(uniswapRouterv2Address);
        isAdded[uniswapRouterv2Address] = true;
        maxBuyLimit = 47000000000 * 10**uint256(decimals); 
        maxSellLimit = 47000000000 * 10**uint256(decimals); 
        maxWalletLimit = 47000000000 * 10**uint256(decimals);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address"); 
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function setLiquidityPool(address _poolAddress) external onlyOwner {
        pair = _poolAddress;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal nonReentrant{
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        
        if (!exemptFee[sender] && !exemptFee[recipient] && isAdded[recipient] == false) {
            require(tradingEnabled, "Trading not enabled");
        }
        if (!exemptFee[recipient]) {
            require(amount <= maxBuyLimit, "You are exceeding maxBuyLimit");
            require(
                _balances[recipient] + amount <= maxWalletLimit,
                "You are exceeding maxWalletLimit"
            );
        }
        if (!exemptFee[recipient] && !exemptFee[sender]) {
            require(amount <= maxSellLimit, "You are exceeding maxSellLimit");
            if (recipient != pair) {
                require(
                    _balances[recipient] + amount <= maxWalletLimit,
                    "You are exceeding maxWalletLimit"
                );
            }
        }
        uint256 feesum;
        uint256 fee;
        if (exemptFee[sender] || exemptFee[recipient])
            fee = 0;
        else if (recipient == pair) {
            feesum = sellMarkeetingTax;
        } else if (sender == pair && recipient != address(this)) {
            feesum = buyMarkeetingTax;
        }
        fee = (amount * feesum) / 100;
        uint256 transferAmount = amount - fee;
        _balances[sender] -= amount; // This line could revert if the check is not in place
        _balances[recipient] += transferAmount;
        emit Transfer(sender, recipient, transferAmount);
        if (fee > 0) {
            if (feesum > 0) {
                _balances[marketingWallet] += fee;
                emit Transfer(sender, marketingWallet, fee);
            }
        }
    }

    function addAddress (address[] memory addresses) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            if (!isAdded[addr]) {
                uniqueAddresses.push(addr);
                isAdded[addr] = true;
                emit AddressAdded(addr);
            }
        }
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
   
    function _transferOwnership(address newOwner) public onlyOwner {
        _owner = newOwner;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) external view override returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function _approve(address tokenOwner, address spender, uint256 amount) internal{
        require(tokenOwner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }

    function _openTrading(bool status) external onlyOwner {
        tradingEnabled = status;
    }

    function updateMaxBuyTxLimit(uint256 maxBuy) external onlyOwner {
        maxBuyLimit = maxBuy * 10**decimals;
    }

    function updateMaxBuyTxLimit(uint256 maxBuy, uint256 maxSell, uint256 maxWallet) external onlyOwner {
        maxBuyLimit = maxBuy * 10**decimals;
        maxSellLimit = maxSell * 10**decimals;
        maxWalletLimit = maxWallet * 10**decimals; 
    }

    function adjustMaxBuyTxLimit() external onlyOwner {
        maxBuyLimit = 1410000000 * 10**decimals;
        maxSellLimit = 470000000 * 10**decimals;
        maxWalletLimit = 1410000000 * 10**decimals; 
    }

    function AddExemptFee(address newWallet) external onlyOwner{
        require(newWallet != address(0), "Zero address not valid!");
        exemptFee[newWallet] = true;

    }

    function renounceOwnership() public onlyOwner {
        _owner = address(0); 
    }
}