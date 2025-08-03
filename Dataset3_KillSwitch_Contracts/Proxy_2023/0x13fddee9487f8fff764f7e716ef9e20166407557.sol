// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


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

// File: mindx.sol


pragma solidity ^0.8.0;



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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(
        address payable recipient,
        uint256 amount
    ) internal returns (bool) {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        return success;
    }

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(
        bytes memory returndata,
        string memory errorMessage
    ) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
contract Mindx is ERC20, Ownable {
    using Address for address payable;

    mapping(address => bool) public _isExcludedMaxTransactionAmount;
    mapping(address => bool) public _automatedMarketMaker;

    uint256 public liquidityFeeOnBuy;
    uint256 public liquidityFeeOnSell;
    uint256 public RevenueShare;
    uint256 public OwnerShare;
    bool private swapping;
    bool public tradingEnabled;
 
    address immutable public TechTeam =  0x1Ee17f87Bb1f871191094e68E5ca5F988B94091c;
    address public TreasuryRevenue =     0xD8a8b4Ab4Fc7073eb06B3339e0f3E9295429eAB6;
    address public TreasuryOwner =       0xA5b1231CF3463C7DE2d9ee743bf830D592775Be0;
    address immutable public Marketing = 0x15a8eDD2817B0dF8E1534c90Ec0cfEe4B778fC13;
    address immutable public CEX      =  0xD567fBF48257347921B95575F617383Ff8ceE976;
    address immutable public PreSale  =  0xE0a0Ac1C94c9A9aCE952b40CFe8E973C3E3a7773;
    address immutable public CReward  =  0x95f84eBf88f760D421c5e0858918970091f3900a;



    mapping (address => uint256) public _tierTimestamp;


    event ExcludeFromFees(address indexed account, bool isExcluded);
    event UpdateWalletToWalletTransferFee(uint256 walletToWalletTransferFee);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiqudity
    );
    event SwapAndSendMarketing(uint256 tokensSwapped, uint256 bnbSend);
    event adding_isExcluded(address _address);
    event removing_isExcluded(address _address);
    event adding_automated(address _address);
    event removing_automated(address _address);
    event enable_trading(bool _status);
    event tax_change(uint _b, uint _s);
    event tax_Treasury(address _b, address _s);
    event tax_fee(uint _b, uint _s);

    constructor() ERC20("Mindx", "MDX") Ownable(msg.sender) {
        _automatedMarketMaker[msg.sender] = true;
        _automatedMarketMaker[TechTeam] = true;
        _automatedMarketMaker[TreasuryRevenue] = true;
        _automatedMarketMaker[TreasuryOwner] = true;
        _automatedMarketMaker[Marketing] = true;
        _automatedMarketMaker[CEX] = true;
        _automatedMarketMaker[PreSale] = true;
        _automatedMarketMaker[CReward] = true;


        tradingEnabled = true;
        liquidityFeeOnBuy = 5;
        liquidityFeeOnSell = 5;


        _mint(owner(), 240 * 1e24); //240M
        uint total_Supply = balanceOf(owner());

        uint techTeam_share = (total_Supply / 100) * 5; 
        transfer(TechTeam, techTeam_share);

        uint Marketing_share = (total_Supply / 100) * 15; 
        transfer(Marketing, Marketing_share);


        uint CEX_share = (total_Supply / 100) * 10; 
        transfer(CEX,CEX_share);

  
        transfer(PreSale,63_370_000_000_000_000_000_000_000);

        uint CReward_share = (total_Supply / 100) * 10; 
        transfer(CReward,CReward_share);

      
    }

    receive() external payable {}

    function enableTrading(bool _status) external onlyOwner {

        tradingEnabled = _status;
        emit enable_trading(_status);
    }

    function taxChange(uint _b, uint _s) external onlyOwner {
        if(_b > 20){
            revert("The wrong number inputed");
        }
        if(_b < 0){
           revert("The wrong number inputed");
        }
        if(_s > 20){
            revert("The wrong number inputed");
        }
        if(_s < 0){
           revert("The wrong number inputed");
        }

        liquidityFeeOnBuy = _b;
        liquidityFeeOnSell = _s;

        emit tax_change(_b, _s);
    }


    function divAdress(address _tr, address _to) external onlyOwner {
        if(_tr == address(0)){
            revert("zero address");
        }
           if(_to == address(0)){
            revert("zero address");
        }
        TreasuryRevenue = _tr;
        TreasuryOwner = _to;

        emit tax_Treasury(_tr, _to);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(tradingEnabled == false){
            revert("ERC20: trade is not available");
        }
        uint Taxation = 0;
        if (_automatedMarketMaker[from] || _automatedMarketMaker[to]) {
            Taxation = 0;
        } else {
            if (_isExcludedMaxTransactionAmount[from]) {
                //buy
                Taxation = liquidityFeeOnBuy;
            } else if (_isExcludedMaxTransactionAmount[to]) {
                //sell
                Taxation = liquidityFeeOnSell;
            }
        }

        Taxation = (amount / 100) * Taxation;

        if (Taxation > 0) {
            uint _owner_share = (Taxation / 100) * OwnerShare;
            uint _revenue_share = Taxation - _owner_share;
            super._transfer(from, TreasuryRevenue, _revenue_share);
            super._transfer(from, TreasuryOwner, _owner_share);
        }
        _tierTimestamp[to] = block.timestamp;
        _tierTimestamp[from] = block.timestamp;

        super._transfer(from, to, amount - Taxation);
    }

    function adding_isExcludedMaxTransactionAmount(address _a) public onlyOwner{
        _isExcludedMaxTransactionAmount[_a] = true;
        emit adding_isExcluded(_a);
    }

    function removing_isExcludedMaxTransactionAmount(address _a) public onlyOwner{
        delete _isExcludedMaxTransactionAmount[_a];
        emit removing_isExcluded(_a);
    }

    function adding_automatedMarketMakerPairs(address _a) public onlyOwner {
        _automatedMarketMaker[_a] = true;
        emit adding_automated(_a);
    }

    function removing_automatedMarketMakerPairs(address _a) public onlyOwner{
        delete _automatedMarketMaker[_a];
        emit removing_automated(_a);
    }
   
    function getTier(address account) public view returns (uint ) {
        return _tierTimestamp[account];
    }
}