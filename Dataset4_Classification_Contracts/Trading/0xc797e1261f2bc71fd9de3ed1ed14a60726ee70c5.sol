/**
    Website: https://www.avernus.tech/
    Telegram: https://t.me/AvernusCoin
    X: https://twitter.com/AvernusOfficial
    Medium: https://medium.com/@avernusofficial
**/

pragma solidity 0.8.19;
// SPDX-License-Identifier: MIT

library SafeMath {
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     * @param a The first integer to add.
     * @param b The second integer to add.
     * @return The sum of the two integers.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow.
     * @param a The integer to subtract from (minuend).
     * @param b The integer to subtract (subtrahend).
     * @return The difference of the two integers.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Subtracts two unsigned integers, reverts with custom message on overflow.
     * @param a The integer to subtract from (minuend).
     * @param b The integer to subtract (subtrahend).
     * @param errorMessage The error message to revert with.
     * @return The difference of the two integers.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     * @param a The first integer to multiply.
     * @param b The second integer to multiply.
     * @return The product of the two integers.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Divides two unsigned integers, reverts on division by zero.
     * @param a The dividend.
     * @param b The divisor.
     * @return The quotient of the division.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Divides two unsigned integers, reverts with custom message on division by zero.
     * @param a The dividend.
     * @param b The divisor.
     * @param errorMessage The error message to revert with.
     * @return The quotient of the division.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    /**
     * @dev Returns the total supply of tokens.
     * @return The total supply of tokens.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the balance of a specific account.
     * @param account The address of the account to check the balance for.
     * @return The balance of the specified account.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Transfers tokens to a recipient.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to be transferred.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining allowance for a spender.
     * @param owner The address of the token owner.
     * @param spender The address of the spender.
     * @return The remaining allowance for the specified owner and spender.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Approves a spender to spend a certain amount of tokens on behalf of the owner.
     * @param spender The address which will spend the funds.
     * @param amount The amount of tokens to be spent.
     * @return A boolean indicating whether the approval was successful or not.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Transfers tokens from one account to another.
     * @param sender The address from which the tokens will be transferred.
     * @param recipient The address to which the tokens will be transferred.
     * @param amount The amount of tokens to be transferred.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when tokens are transferred from one address to another.
     * @param from The address from which the tokens are transferred.
     * @param to The address to which the tokens are transferred.
     * @param value The amount of tokens being transferred.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the approval of a spender is updated.
     * @param owner The address that approves the spender.
     * @param spender The address that is approved.
     * @param value The new approved amount.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    /// @dev Emitted when ownership is transferred.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract, setting the original owner to the sender account.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     * @return The address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Renounces ownership, leaving the contract without an owner.
     * @notice Renouncing ownership will leave the contract without an owner,
     * which means it will not be possible to call onlyOwner functions anymore.
     */
    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }
}

contract Avernus is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    bool public isTransferDelay = true;
    address payable private _taxWallet;
    address private constant _deadAddress = address(0xdead);

    uint256 private constant _initBuyTax = 25;
    uint256 private constant _initSellTax = 30;
    uint256 private constant _lastBuyTax=5;
    uint256 private constant _lastSellTax=5;
    
    uint256 private _decreaseBuyTaxAt;
    uint256 private _decreaseSellTaxAt;
    uint256 private _preventSwapBefore;
    uint256 private _buyCount = 0;

    string private _name;
    string private _symbol;
    uint8 private constant _decimals = 9;
    uint256 private constant _tSupply = 100000000 * 10**_decimals;

    uint256 public _maxTxAmount = _tSupply / 100; // 2% of the supply
    uint256 public _maxWalletSize = _tSupply / 100; // 2% of the supply
    uint256 public _taxSwapThreshold = 3500000 * 10**_decimals;
    uint256 public _maxTaxSwap = 10900000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    bool private isTradingOpen;
    bool private inSwap = false;    
    bool private isSwapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event MaxWalletSizeUpdated(uint256 maxWalletSize);
    event TransferDelayUpdated(bool isTransferDelayEnabled);
    event ExcludeFromFee(address indexed account, bool isExcluded);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _name = unicode"AVERNUS";
        _symbol = unicode"AVR";

        _decreaseBuyTaxAt=25;
        _decreaseSellTaxAt=31;
        _preventSwapBefore=28;

        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _tSupply;
        excludeFromFee(owner(), true);
        excludeFromFee(_deadAddress, true);
        excludeFromFee(address(this), true);

        emit Transfer(address(0), _msgSender(), _tSupply);
    }

    /**
     * @dev Gets the name of the AVERNUS token.
     * @return The name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the symbol of the AVERNUS token.
     * @return The symbol of the token.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Gets the number of decimals used for the AVERNUS token.
     * @return The number of decimals.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Gets the total supply of the AVERNUS token.
     * @return The total supply.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _tSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param account The address to query the balance of.
     * @return The balance of the specified address.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Transfers tokens from the sender to the recipient.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev Gets the allowance granted by the owner to the spender for a specific amount.
     * @param owner The address granting the allowance.
     * @param spender The address receiving the allowance.
     * @return The remaining allowance for the spender.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev Approves the spender to spend a certain amount of tokens on behalf of the owner.
     * @param spender The address to be approved.
     * @param amount The amount of tokens to approve.
     * @return A boolean indicating whether the approval was successful or not.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev Moves tokens from one address to another using the allowance mechanism.
     * @param sender The address to send tokens from.
     * @param recipient The address to receive tokens.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function excludeFromFee(address account, bool excluded) public onlyOwner {
        _isExcludedFromFee[account] = excluded;
        emit ExcludeFromFee(account, excluded);
    }

    function openTrading() external onlyOwner() {
        require(!isTradingOpen, "openTrading: Trading is already open");

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tSupply);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);

        isSwapEnabled = true;
        isTradingOpen = true;
    }

    function removeAllLimits() external onlyOwner{
        _maxTxAmount = _tSupply;
        _maxWalletSize = _tSupply;
        isTransferDelay = false;

        emit MaxTxAmountUpdated(_tSupply);
        emit MaxWalletSizeUpdated(_tSupply);
        emit TransferDelayUpdated(false);
    }

    function disableTransferDelay() external onlyOwner {
        isTransferDelay = false;
        emit TransferDelayUpdated(false);
    }

    function removeStuckETH(uint256 gweiAmount) external onlyOwner {
        uint256 ethBalance = address(this).balance;
        if (ethBalance > gweiAmount) {
            payable(_msgSender()).transfer(gweiAmount);
        }
    }

    function removeStuckToken(address tokenAddress, uint256 tokenAmount) external onlyOwner returns (bool) {
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
        if (tokenBalance > tokenAmount) {
            IERC20(tokenAddress).transfer(_taxWallet, tokenAmount);
        }
        return true;
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function _approve(address _ownerAddress, address _spenderAddress, uint256 _amount) private {
        require(_ownerAddress != address(0), "ERC20: approve from the zero address");
        require(_spenderAddress != address(0), "ERC20: approve to the zero address");

        _allowances[_ownerAddress][_spenderAddress] = _amount;
        emit Approval(_ownerAddress, _spenderAddress, _amount);
    }

    function _transfer(address _from, address _to, uint256 _amount) private {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(_amount > 0, "_transfer: Transfer amount must be greater than zero");

        uint256 taxAmount = 0;
        if (_from != owner() && _to != owner() && _from != address(this)) {
            if (isTransferDelay) {
                if (_to != address(uniswapV2Router) && _to != address(uniswapV2Pair)) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] <
                            block.number,
                        "_transfer: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (_from == uniswapV2Pair && _to != address(uniswapV2Router) && !_isExcludedFromFee[_to] ) {
                require(_amount <= _maxTxAmount, "_transfer: Exceeds the _maxTxAmount.");
                taxAmount = _amount.mul
                ((_buyCount>_decreaseBuyTaxAt)
                    ?_lastBuyTax:_initBuyTax).div(100
                );
                require(balanceOf(_to) + _amount <= _maxWalletSize, "_transfer: Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if ( _to == uniswapV2Pair && _from != address(this) ){
                taxAmount = _amount.mul 
                ((_buyCount>_decreaseSellTaxAt)
                    ?_lastSellTax:_initSellTax).div(100
                );
            } 
            
            uint256 thisContractTokenBalance = balanceOf(address(this));
            if (
                !inSwap && 
                _to == uniswapV2Pair && 
                isSwapEnabled && 
                thisContractTokenBalance > _taxSwapThreshold && 
                _buyCount > _preventSwapBefore
            ) {
                if (_amount >= _maxTaxSwap) {
                    swapTokensForEth(_maxTaxSwap);
                } else {
                    swapTokensForEth(_amount);
                }

                uint256 ethContractBalance = address(this).balance;
                if(ethContractBalance > 50000000000000000) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount > 0){
          _balances[address(this)] = _balances[address(this)].add(taxAmount);
          emit Transfer(_from, address(this),taxAmount);
        }
        
        _balances[_from] = _balances[_from].sub(_amount);
        _balances[_to] = _balances[_to].add(_amount.sub(taxAmount));
        emit Transfer(_from, _to, _amount.sub(taxAmount));
    }

    function swapTokensForEth(uint256 _tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), _tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    /**
     * @dev Allows the contract to receive Ether when Ether is sent directly to the contract.
     */
    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _taxWallet);

        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance > 0){
          swapTokensForEth(tokenBalance);
        }

        uint256 ethBalance = address(this).balance;
        if(ethBalance > 0){
          sendETHToFee(ethBalance);
        }
    }
}