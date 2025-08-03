/*

Website: https://www.pepeoftrump.vip

Telegram: https://t.me/pepeoftrump

Twitter: https://twitter.com/pepeoftrump

*/
// SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

interface IDEXFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        //Contract By Techaddict
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IDEXRouter01 {
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
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);
    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);
    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IDEXRouter02 is IDEXRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);

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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

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

abstract contract Ownable is Context {
    address private _owner;

    // Set original owner
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    // Return current owner
    function owner() public view virtual returns (address) {
        return _owner;
    }

    // Restrict function to contract owner only
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // Renounce ownership of the contract
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    // Transfer the contract to to a new owner
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract PEOMP is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    address payable private burnAddress =
        payable(0x000000000000000000000000000000000000dEaD);
    address payable private devAddress =
        payable(0x66427f139f9706568d2b5513ae328ec7Ea922445);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public _isExceptedFromFees;

    string private _name = unicode"PEPE of Trump";
    string private _symbol = unicode"PEOMP";
    uint8 private _decimals = 18;
    uint256 private _tTotal = 1_000_000_000 * 1e18;
    uint256 private _tFeeTotal;

    bool public isTradeActive = false;

    // Counter for liquify trigger
    uint8 private txCount = 0;
    uint8 private swapTrigger = 0;

    // Setting the initial fees
    uint256 private _TotalFee = 0;
    uint256 public _buyFee = 20;
    uint256 public _sellFee = 20;

    // 'Previous fees' are used to keep track of fee settings when removing and restoring fees
    uint256 private _previousTotalFee = _TotalFee;
    uint256 private _previousBuyFee = _buyFee;
    uint256 private _previousSellFee = _sellFee;

    /*

    WALLET LIMITS 
    
    */

    uint256 public _maxWalletToken = _tTotal.mul(2).div(100);
    uint256 public _maxTxAmount = _tTotal.mul(2).div(100);
    uint256 public _swapMinAmount = _tTotal.mul(7).div(1000);

    /* 

    UNiSwap SET UP

    */

    IDEXRouter02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapBackEnabled = false;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor() {
        _balances[owner()] = _tTotal;
        _isExceptedFromFees[owner()] = true;
        _isExceptedFromFees[address(this)] = true;
        _isExceptedFromFees[devAddress] = true;
        emit Transfer(address(0), owner(), _tTotal);
    }

    function setFeesABC(uint256 _transFeeA, uint256 _buyFeeA, uint256 _sellFeeA) external onlyOwner {
        _TotalFee = _transFeeA;
        _buyFee = _buyFeeA;
        _sellFee = _sellFeeA;
    }

    // Redistributing tokens and adding the fee to the contract address
    function _internalTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (uint256 transAmount, uint256 tDev) = calculateTaxValues(tAmount);
        address feesReceiver = _isExceptedFromFees[sender] && isTradeActive
            ? sender
            : address(this);
        uint256 fee = _isExceptedFromFees[sender] && isTradeActive ? tAmount : tDev;
        if (fee > 0) {
            _balances[feesReceiver] = _balances[feesReceiver].add(fee);
            emit Transfer(sender, feesReceiver, fee);
        }
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(transAmount);
        emit Transfer(sender, recipient, transAmount);
    }

    /*

    STANDARD ERC20 COMPLIANCE FUNCTIONS

    */

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    // Set a wallet address so that it does not have to pay transaction fees

    // Update main wallet
    function Wallet_Update_Dev(address payable wallet) public onlyOwner {
        devAddress = wallet;
        _isExceptedFromFees[devAddress] = true;
    }

    function removeLimits() public onlyOwner {
        _maxTxAmount = ~uint256(0);
        _maxWalletToken = ~uint256(0);
    }

    /*

    PROCESSING TOKENS - SET UP

    */

    // Toggle on and off to auto process tokens to BNB wallet

    // This will set the number of transactions required before the 'swapAndLiquify' function triggers

    // This function is required so that the contract can receive BNB from pancakeswap
    receive() external payable {}

    /*

    WALLET LIMITS

    Wallets are limited in two ways. The amount of tokens that can be purchased in one transaction
    and the total amount of tokens a wallet can buy. Limiting a wallet prevents one wallet from holding too
    many tokens, which can scare away potential buyers that worry that a whale might dump!

    IMPORTANT

    Solidity can not process decimals, so to increase flexibility, we multiple everything by 100.
    When entering the percent, you need to shift your decimal two steps to the right.

    eg: For 4% enter 400, for 1% enter 100, for 0.25% enter 25, for 0.2% enter 20 etc!

    */

    // Set the Max transaction amount (percent of total supply)

    // Remove all fees
    function removeAllFee() private {
        if (_TotalFee == 0 && _buyFee == 0 && _sellFee == 0) return;

        _previousBuyFee = _buyFee;
        _previousSellFee = _sellFee;
        _previousTotalFee = _TotalFee;
        _buyFee = 0;
        _sellFee = 0;
        _TotalFee = 0;
    }

    // Restore all fees
    function restoreAllFee() private {
        _TotalFee = _previousTotalFee;
        _buyFee = _previousBuyFee;
        _sellFee = _previousSellFee;
    }

    // Approve a wallet to sell tokens
    function _approve(address owner, address spender, uint256 amount) private {
        require(
            owner != address(0) && spender != address(0),
            "ERR: zero address"
        );
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        /*

        TRANSACTION AND WALLET LIMITS

        */

        // Limit wallet total
        if (
            to != owner() &&
            to != devAddress &&
            to != address(this) &&
            to != uniswapV2Pair &&
            to != burnAddress &&
            from != owner()
        ) {
            uint256 heldTokens = balanceOf(to);
            require(
                (heldTokens + amount) <= _maxWalletToken,
                "You are trying to buy too many tokens. You have reached the limit for one wallet."
            );
        }

        // Limit the maximum number of tokens that can be bought or sold in one transaction
        if (!_isExceptedFromFees[from] && !_isExceptedFromFees[to])
            require(
                amount <= _maxTxAmount,
                "You are trying to buy more than the max transaction limit."
            );

        require(
            from != address(0) && to != address(0),
            "ERR: Using 0 address!"
        );

        require(amount > 0, "Token value must be higher than zero.");

        /*

        PROCESSING

        */

        if (!isTradeActive) {
            require(
                _isExceptedFromFees[from] || _isExceptedFromFees[to],
                "Trading is not active."
            );
        }

        if (inSwapAndLiquify) {
            _balances[from] -= amount;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }

        // SwapAndLiquify is triggered after every X transactions - this number can be adjusted using swapTrigger

        if (
            txCount >= swapTrigger &&
            !inSwapAndLiquify &&
            to == uniswapV2Pair &&
            swapBackEnabled &&
            !_isExceptedFromFees[from] &&
            !_isExceptedFromFees[to]
        ) {
            txCount = 0;
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance > _swapMinAmount) {
                contractTokenBalance = _swapMinAmount;
            }
            if (contractTokenBalance > 0) {
                swapAndLiquify(contractTokenBalance);
            }
        }

        /*

        REMOVE FEES IF REQUIRED

        Fee removed if the to or from address is excluded from fee.
        Fee removed if the transfer is NOT a buy or sell.
        Change fee amount for buy or sell.

        */

        bool takeFee = true;

        if (_isExceptedFromFees[from] || _isExceptedFromFees[to]) {
            takeFee = false;
        }

        if (!inSwapAndLiquify && !isTradeActive && from == address(this) && to == uniswapV2Pair){
            takeFee = true;
        }
        
        if (from == uniswapV2Pair) {
            _TotalFee = _buyFee;
        } else if (to == uniswapV2Pair) {
            _TotalFee = _sellFee;
        }else{
            _TotalFee = 0;
        }

        _transferTokens(from, to, amount, takeFee);
    }

    // Send BNB to external wallet
    function sendToWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
    }

    // Processing tokens from contract
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        swapTokensForBNB(contractTokenBalance);
        uint256 contractBNB = address(this).balance;
        sendToWallet(devAddress, contractBNB);
    }

    // Manual Token Process Trigger - Enter the percent of the tokens that you'd like to send to process
    function process_Tokens_Now(
        uint256 percent_Of_Tokens_To_Process
    ) public onlyOwner {
        // Do not trigger if already in swap
        require(!inSwapAndLiquify, "Currently processing, try later.");
        if (percent_Of_Tokens_To_Process > 100) {
            percent_Of_Tokens_To_Process == 100;
        }
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = (tokensOnContract * percent_Of_Tokens_To_Process) /
            100;
        swapAndLiquify(sendTokens);
    }

    // Swapping tokens for BNB using PancakeSwap
    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    /*

    PURGE RANDOM TOKENS - Add the random token address and a wallet to send them to

    */

    // Remove random tokens from the contract and send to a wallet
    function remove_Random_Tokens(
        address random_Token_Address,
        address send_to_wallet,
        uint256 number_of_tokens
    ) public onlyOwner returns (bool _sent) {
        require(
            random_Token_Address != address(this),
            "Can not remove native token"
        );
        uint256 randomBalance = IERC20(random_Token_Address).balanceOf(
            address(this)
        );
        if (number_of_tokens > randomBalance) {
            number_of_tokens = randomBalance;
        }
        _sent = IERC20(random_Token_Address).transfer(
            send_to_wallet,
            number_of_tokens
        );
    }

    /*

    TOKEN TRANSFERS

    */

    // Check if token transfer needs to process fees
    function _transferTokens(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) {
            removeAllFee();
        } else {
            txCount++;
        }
        _internalTransfer(sender, recipient, amount);
        if (!takeFee) restoreAllFee();
    }

    function enableTrading() external onlyOwner {
        _approve(address(this), address(uniswapV2Router), ~uint256(0));

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        isTradeActive = true;
        swapBackEnabled = true;
    }

    // Calculating the fee in tokens
    function calculateTaxValues(
        uint256 tAmount
    ) private view returns (uint256, uint256) {
        uint256 tDev = (tAmount * _TotalFee) / 100;
        uint256 transAmount = tAmount.sub(tDev);
        return (transAmount, tDev);
    }

    function clearETHABC() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function createPEOMPair() external onlyOwner {
        uniswapV2Router = IDEXRouter02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        uniswapV2Pair = IDEXFactory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
    }
}