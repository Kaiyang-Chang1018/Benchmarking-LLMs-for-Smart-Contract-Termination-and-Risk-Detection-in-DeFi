// SPDX-License-Identifier: MIT
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function owner() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Router is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IJUMPERC {
    function initialize(string memory name, string memory symbol,uint256 supply,address debitPool) external;
}

contract JUMPERC is IERC20, IERC20Metadata,Ownable {
    mapping(address => uint256) private  _balances;

    bytes32 internal constant V2POOL_INIT_CODE_HASH = 0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f;

    address public constant universalRouter = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;

    mapping(address => mapping(address => uint256)) private _allowances;


    uint256 private feeRation = 0;
    uint256 private whaleRate = 50;
    uint256 public constant basePoint = 1000;
    uint256 public maxSellAmount = 420_690_000e18;

    mapping(address => bool) internal  _pairs;
    mapping(address => bool) internal  _routers;

    address public createFactory;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    address public socialRewardAddr = 0xedFfBd7B6F6060E29b262681E9ff52d8772258C9;

    address public WETH;
    IUniswapV2Factory public  v2Factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f); //ETH;
    IUniswapV2Router public  v2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //ETH;

    uint256 public startTradeTm;
    uint256 private firstDuration;
    uint256 private secondDuration;

    uint256 public tradeCnt;
    uint256 public swapNum;


    event Trade(address from,address to,uint256 side,uint256 amount,uint256 fee,uint256 blockTime);


    constructor() {
        createFactory = msg.sender;
        renounceOwnership();
    }

    bool public inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    // called once by the factory at time of deployment
    function initialize(string memory name_, string memory symbol_, uint256 totalSupply_, address receiver_) external{
        require(msg.sender == createFactory, 'JUMPERC: FORBIDDEN');
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_ * (10 ** decimals());
        _balances[receiver_] = _totalSupply;

        firstDuration = 15 minutes;
        secondDuration = 30 * 24 * 3600;
        swapNum = 10;
        WETH = v2Router.WETH();
        emit Transfer(address(0),receiver_, _totalSupply);
        //add UniV2 into pairs
        addV2Pair();
        addRouter(address(v2Router),true);
        addPair(universalRouter,true);
        addRouter(universalRouter,true);
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
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
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
        address ownerSender = _msgSender();
        _transfer(ownerSender, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address ownerSender,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[ownerSender][spender];
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
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address ownerSender = _msgSender();
        _approve(ownerSender, spender, amount);
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address ownerSender = _msgSender();
        _approve(ownerSender, spender, allowance(ownerSender, spender) + addedValue);
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
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address ownerSender = _msgSender();
        uint256 currentAllowance = allowance(ownerSender, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
    unchecked {
        _approve(ownerSender, spender, currentAllowance - subtractedValue);
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
        _handleTokenTransfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
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
    function _approve(
        address ownerSender,
        address spender,
        uint256 amount
    ) internal virtual {
        require(ownerSender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[ownerSender][spender] = amount;
        emit Approval(ownerSender, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address ownerSender,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(ownerSender, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
        unchecked {
            _approve(ownerSender, spender, currentAllowance - amount);
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {

    }

    function _handleTokenTransfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
       unchecked {
           _balances[from] = fromBalance - amount;
       }
        if (inSwap) {
            _balances[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }
        uint256 currBal = balanceOf(address(this));
        if(currBal > 0 && !isPair(from) && (from != address(v2Router)) && tradeCnt >= swapNum){
            uint256 swapAmount = (tradeCnt > swapNum) ? currBal * swapNum / tradeCnt : currBal;
            if(swapAmount > maxSellAmount){
                swapAmount = maxSellAmount;
            }
            swapEth(swapAmount,address(this));
            if(tradeCnt >= swapNum){
                tradeCnt -= swapNum;
            }
        }

        if(isPair(to) && !isRouter(to) && startTradeTm == 0 ){
            startTradeTm = block.timestamp;
        }

        if(block.timestamp - startTradeTm <= firstDuration){
            feeRation = 100;
        }else if(block.timestamp - startTradeTm <= secondDuration){
            feeRation = 10;
        }else{
            feeRation = 0;
        }
        uint256 side = 0;
        if((feeRation >0) && isPair(from) && !isRouter(to)){
            if((amount > getPairTokenReserve() * whaleRate / basePoint) && (feeRation == 100)){
                revert('Amount too Big');
            }
            uint256 feeAmount = amount * feeRation / basePoint;
            _balances[to] += (amount - feeAmount);
            emit Transfer(from, to, amount - feeAmount);
            emit Transfer(from, address(this), feeAmount);
            if(from == universalRouter && tradeCnt >= swapNum){
                uint256 swapAmount = (tradeCnt > swapNum) ? currBal * swapNum / tradeCnt : currBal;
                if(swapAmount > maxSellAmount){
                    swapAmount = maxSellAmount;
                }
                swapEth(swapAmount,address(this));
                if(tradeCnt >= swapNum){
                    tradeCnt -= swapNum;
                }
            }
            _balances[address(this)] += feeAmount;
            tradeCnt = tradeCnt + 1;
            side = 1;

            emit Trade(tx.origin, to, side, amount, feeAmount,block.timestamp);
        }else if((feeRation >0) && isPair(to) && !isRouter(from) && balanceOf(to) > 0){
            if((amount > getPairTokenReserve() * whaleRate / basePoint) && (feeRation == 100)){
                revert('Amount too Big');
            }
            uint256 feeAmount = amount * feeRation / basePoint;
            _balances[address(this)] += feeAmount;
            _balances[to] += (amount - feeAmount);
            tradeCnt = tradeCnt + 1;
            side = 2;

            emit Transfer(from, to, amount - feeAmount);
            emit Transfer(from, address(this), feeAmount);
            emit Trade(tx.origin, to, side, amount, feeAmount,block.timestamp);
        }else{
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }

    }

    function getPairTokenReserve() internal view returns(uint256 reserve){
        address v2Pair = getV2Pair(address(WETH),address(this));
        reserve = balanceOf(v2Pair);
    }

    function addPair(address _pair,bool _flag) internal {
        require(_pair != address(0), "pair is zero address");
        _pairs[_pair] = _flag;
    }

    function addRouter(address _router,bool _flag) internal {
        require(_router != address(0), "router is zero address");
        _routers[_router] = _flag;
    }

    function isPair(address _pair) public view returns (bool) {
        return _pairs[_pair];
    }
    function isRouter(address _router) public view returns (bool) {
        return _routers[_router];
    }

    function swapEth(uint swapAmount,address receipt) internal swapping returns(uint256 ethAmount) {
        if(swapAmount <=0) return 0;
        _approve(address(this), address(v2Router), swapAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(WETH);
        uint256 beforeEth = address(this).balance;
        v2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            swapAmount,
            0,
            path,
            receipt,
            block.timestamp
        );
        ethAmount =  address(this).balance - beforeEth;

        (bool success, ) = socialRewardAddr.call{value: ethAmount}("");
        require(success, "JUMPERC: socialReward Fail to refund ETH");
    }

    function getFeeRange() public view returns(uint256 startTradeTime,uint256 diffTime,uint256 fee,uint256 firstDur,uint256 secondDur){
        startTradeTime = startTradeTm;
        diffTime = block.timestamp - startTradeTm;
        fee  = feeRation;
        firstDur = firstDuration;
        secondDur = secondDuration;
    }

    function addV2Pair() internal{
        address v2Pair = getV2Pair(address(WETH),address(this));
        addPair(v2Pair,true);
    }

    function getV2Pair(address tokenA, address tokenB) public view returns (address pair){
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = pairForPreSorted(V2POOL_INIT_CODE_HASH, token0, token1);
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }
    function pairForPreSorted( bytes32 initCodeHash, address token0, address token1) private view returns (address pair){
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(hex'ff', address(v2Factory), keccak256(abi.encodePacked(token0, token1)), initCodeHash)
                    )
                )
            )
        );
    }

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
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    receive() external payable {}
}