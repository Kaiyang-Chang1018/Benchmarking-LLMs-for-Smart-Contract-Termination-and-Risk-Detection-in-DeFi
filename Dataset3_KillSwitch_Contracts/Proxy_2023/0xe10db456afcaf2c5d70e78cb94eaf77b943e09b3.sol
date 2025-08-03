// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


interface IERC20 {
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address to, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


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



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    
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

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
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

    
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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



interface IUniswapSwapRouterV2 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    
}

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);

}


abstract contract NoDelegateCall {
    /// @dev The original address of this contract
    address private immutable original;

    constructor() {
        // Immutables are computed in the init code of the contract, and then inlined into the deployed bytecode.
        // In other words, this variable won't change when it's checked at runtime.
        original = address(this);
    }

    /// @dev Private method is used instead of inlining into modifier because modifiers are copied into each method,
    ///     and the use of immutable means the address bytes are copied in every place the modifier is used.
    function checkNotDelegateCall() private view {
        require(address(this) == original);
    }

    /// @notice Prevents delegatecall into the modified method
    modifier noDelegateCall() {
        checkNotDelegateCall();
        _;
    }
}




contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
    function transferOwnership(address newOwner) public virtual  {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract TESTToken is ERC20,Ownable,NoDelegateCall {

    address constant SWAP_ROUTER_V2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    uint256 public projectStartBlockNum=99999999999;

    uint256 public constant LOTTERY_VALUE = 0.001 ether;
    IUniswapSwapRouterV2 private constant router = IUniswapSwapRouterV2(SWAP_ROUTER_V2);


    uint256 public constant TOKEN_AMOUNT_PER_SEED=1000*1e18; 

    mapping(address => uint256) public SeedTimesOfAddress;
    uint256 public curSeedUnit=0;
    uint256 public totalUnit=100;
    uint256 private blockSendingIndex=1;
    mapping(uint256 => mapping(uint256 => Tx_Block_Unit)) public txBlockUnitPostionByBlockNum;
    uint256 private lastLotteryBlockNum=0;
    mapping(uint256 => uint256) public blockSentLength;
    mapping(address => uint256) public seedAddressByBlockNum;
    address[] public allSeedAddresses;
    bool public tradingEnabled=false;
    mapping (address => bool) private isV2Pair;

    address private uniswapV2air;
    mapping(address => bool) private _isExcluded;
    struct Tx_Block_Unit{
        bool hasSeed;
        address lotteryUserAddress;
    }

    constructor() ERC20("LUCKY STAR", "TEST") {
        _mint(owner(), 2_000_000 * 1e18);
        _isExcluded[owner()] = true;
        _isExcluded[address(this)] = true;
        uniswapV2air=IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        isV2Pair[address(uniswapV2air)] = true;
    }


    function _transfer(address from,  address to, uint256 amount) internal virtual override{
        if(!_isExcluded[from] && !_isExcluded[to] ){ //used to add initial liquidity
            if(isV2Pair[from] || isV2Pair[to]){
                require(tradingEnabled,"trading not started!!!");
            }
        }
            
        super._transfer(from,to, amount);
    }

        


    function toggleLaunchTrade() external onlyOwner{
        require(!tradingEnabled,"trading has started!!!");
        tradingEnabled=true;
    }


    function toggleLiquidity() external onlyOwner{
        IERC20(address(this)).approve(address(router), totalSupply());

        require(address(this).balance > 0, " no balance to add liquidity!!!");
        
        router.addLiquidityETH{value:address(this).balance}(address(this), totalSupply()/2, 0, 0, owner(), block.timestamp+6000);
    }


    function toggleLottory() external onlyOwner{
        projectStartBlockNum=block.number+2;
        lastLotteryBlockNum=block.number+2;

    }


    function claim() external {
        require(tradingEnabled,"claiming is available only after trading started!!!");
        require(SeedTimesOfAddress[msg.sender]>0,"None to claim for this address!");
        uint256 amountToClaimByAddress=SeedTimesOfAddress[msg.sender]*TOKEN_AMOUNT_PER_SEED;
        require(amountToClaimByAddress>balanceOf(address(this)),"not enough balance to claim!");
        IERC20(address(this)).transfer(msg.sender, amountToClaimByAddress);
    }

    




    receive() external payable noDelegateCall { 
   
        require(block.number>=projectStartBlockNum,"not lauch yet!!!");
        require(tx.origin == msg.sender,"not support send from contract.");

        require(curSeedUnit<=totalUnit,"no seed balance left!");


    
        if( block.number-lastLotteryBlockNum>=1){
            blockSentLength[lastLotteryBlockNum]=blockSendingIndex-1;
            lottery(lastLotteryBlockNum,blockSendingIndex-1);

            blockSendingIndex=1;
            lastLotteryBlockNum=block.number;
        }

        

        
        if (msg.value == LOTTERY_VALUE) {
            txBlockUnitPostionByBlockNum[block.number][blockSendingIndex]=Tx_Block_Unit(false,msg.sender);
            blockSendingIndex++;
        } 



        
    }

    
    function lottery(uint256 blockNum,uint length) internal {
        if(length==0){
            return;
        }
        if(length<=5){
            for(uint256 i=1;i<=length;i++){
                address ltAddress=txBlockUnitPostionByBlockNum[blockNum][i].lotteryUserAddress;              
                if(ltAddress==address(0)) continue;

                if(seedAddressByBlockNum[ltAddress] !=blockNum ){
                    if(curSeedUnit>=totalUnit) continue;
                    txBlockUnitPostionByBlockNum[blockNum][i].hasSeed=true;
                    curSeedUnit++;
                    seedAddressByBlockNum[ltAddress]= blockNum;
                    SeedTimesOfAddress[ltAddress]++;

                    if(SeedTimesOfAddress[ltAddress]==1){
                        allSeedAddresses.push(ltAddress);
                    }
                }    
            }

            
        }else{
            uint256 modFive=length%5;
            uint256 interval=length/5;

            uint256 factor=modFive==0?interval:interval+modFive;

            for(uint256 i=factor;i<=length;i=i+interval){
                address ltAddress=txBlockUnitPostionByBlockNum[blockNum][i].lotteryUserAddress;

                if(ltAddress==address(0)) continue;

                if(seedAddressByBlockNum[ltAddress] != blockNum){
                    if(curSeedUnit>=totalUnit) continue;
                    txBlockUnitPostionByBlockNum[blockNum][i].hasSeed=true;
                    curSeedUnit++;
                    seedAddressByBlockNum[ltAddress]= blockNum;
                    SeedTimesOfAddress[ltAddress]++;

                    if(SeedTimesOfAddress[ltAddress]==1){
                        allSeedAddresses.push(ltAddress);
                    }
                }    
            }
        }
    }
    



}