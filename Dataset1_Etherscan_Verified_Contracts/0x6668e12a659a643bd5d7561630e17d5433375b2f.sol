// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/**

Website: https://www.toastfu.com
Telegram: https://t.me/ToastFuPortal
Twitter: https://twitter.com/ToastFuTech
Whitepaper: https://toastfu.gitbook.io/toastfu

*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

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

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function burn(
        address to
    ) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract ToastFu is Context, IERC20, Ownable {
    using Address for address;
    //Mapping section for better tracking.
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    //Loging and Event Information for better troubleshooting.
    event Log(string, uint256);
    event AuditLog(string, address);
    event RewardLiquidityProviders(uint256 tokenAmount);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SwapTokensForETH(uint256 amountIn, address[] path);
    //Supply Definition.
    uint256 private _tTotal = 100_000_000 ether;

    //Token Definition.
    string public constant name = "ToastFu";
    string public constant symbol = "TFU";
    uint8 public constant decimals = 18;

    //Definition of Wallets for team.
    address payable public taxWallet =
        payable(0xa3A2d88B0c01F206771268d49a1bDE7EBe893934);

    //Dead Wallet for SAFU Contract
    address public constant deadWallet =
        0x000000000000000000000000000000000000dEaD;

    //Taxes Definition.
    uint256 public buyFee = 20;
    uint256 public sellFee = 20;

    uint256 public taxTokensCollected = 0;
    uint256 public totalTaxTokensCollected = 0;

    uint256 public minimumTokensBeforeSwap = 10_000 ether; // 0.01%
    uint256 public maxWallet = 3_000_000 ether; // 3%

    //Oracle Price Update, Manual Process.
    uint256 public swapOutput = 0;
    //Router and Pair Configuration.
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address private immutable WETH;
    //Tracking of Automatic Swap vs Manual Swap.
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public tradingActive = false;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _tOwned[_msgSender()] = _tTotal;
        address currentRouter;

        if (block.chainid == 11155111) {
            currentRouter = 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008; // Sepolia
        } else if (block.chainid == 1) {
            currentRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Mainnet
        } else if (block.chainid == 56) {
            currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // BSC PCS
        } else {
            revert("Invalid Chain ID");
        }

        //Create Pair in the contructor, this may fail on some blockchains and can be done in a separate line if needed.
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(currentRouter);
        WETH = _uniswapV2Router.WETH();
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), WETH);
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    //Readable Functions.
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    //ERC 20 Standard Transfer Functions
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    //ERC 20 Standard Allowance Function
    function allowance(
        address _owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    //ERC 20 Standard Approve Function
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    //ERC 20 Standard Transfer From
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    //ERC 20 Standard increase Allowance
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

    //ERC 20 Standard decrease Allowance
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    //Approve Function
    function _approve(address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    //Transfer function, validate correct wallet structure, take fees, and other custom taxes are done during the transfer.
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            _tOwned[from] >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        if (
            from != owner() &&
            to != owner() &&
            to != address(0) &&
            to != address(0xdead)
        ) {
            if (!tradingActive) {
                require(_isExcludedFromFee[from] || _isExcludedFromFee[to], "Trading is not active.");
            }

            if (
                from == uniswapV2Pair && 
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[from] && !_isExcludedFromFee[to]
            ) {
                require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
            }
        }

        //Adding logic for automatic swap.
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >=
            minimumTokensBeforeSwap;
        uint fee = 0;
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            overMinimumTokenBalance &&
            swapAndLiquifyEnabled
        ) {
            swapAndLiquify();
        }
        if (to == uniswapV2Pair && !_isExcludedFromFee[from]) {
            fee = (sellFee * amount) / 100;
        }
        if (from == uniswapV2Pair && !_isExcludedFromFee[to]) {
            fee = (buyFee * amount) / 100;
        }
        amount -= fee;

        if (fee > 0) {
            _tokenTransfer(from, address(this), fee);
            taxTokensCollected += fee;
            totalTaxTokensCollected += fee;
        }
        _tokenTransfer(from, to, amount);
    }

    function swapAndLiquify() public lockTheSwap {
        uint256 totalTokens = balanceOf(address(this));
        swapTokensForEth(totalTokens);
        uint ethBalance = address(this).balance;
        transferToAddressETH(taxWallet, ethBalance);
        taxTokensCollected = 0;
    }

    //swap for eth is to support the converstion of tokens to weth during swapandliquify this is a supporting function
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    //ERC 20 standard transfer, only added if taking fees to countup the amount of fees for better tracking and split purpose.
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _tOwned[sender] -= amount;
        _tOwned[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    //exclude wallets from fees, this is needed for launch or other contracts.
    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
        emit AuditLog(
            "We have excluded the following walled in fees:",
            account
        );
    }

    //include wallet back in fees.
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
        emit AuditLog(
            "We have including the following walled in fees:",
            account
        );
    }

    function updateFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 5, "Must keep buy fees at 5% or less");
        require(_sellFee <= 5, "Must keep sell fees at 5% or less");
        buyFee = _buyFee;
        sellFee = _sellFee;
    }

    function openTrading() external onlyOwner {
        tradingActive = true;
    }

    //Automatic Swap Configuration.
    function setTokensToSwap(
        uint256 _minimumTokensBeforeSwap
    ) external onlyOwner {
        require(
            _minimumTokensBeforeSwap >= 100 ether,
            "You need to enter more than 100 tokens."
        );
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
        emit Log(
            "We have updated minimunTokensBeforeSwap to:",
            minimumTokensBeforeSwap
        );
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        require(swapAndLiquifyEnabled != _enabled, "Value already set");
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //set a new tax wallet.
    function setTaxWallet(address _taxWallet) external {
        require(_msgSender() == taxWallet, "Invalid permission");
        require(_taxWallet != address(0), "setTaxWallet: ZERO");
        taxWallet = payable(_taxWallet);
        _isExcludedFromFee[taxWallet] = true;
        emit AuditLog("We have Updated the TaxWallet:", taxWallet);
    }

    function transferToAddressETH(
        address payable recipient,
        uint256 amount
    ) private {
        if (amount == 0) return;
        (bool succ, ) = recipient.call{value: amount}("");
        require(succ, "Transfer failed.");
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    /////---fallback--////
    //This cannot be removed as is a fallback to the swapAndLiquify
    event SwapETHForTokens(uint256 amountIn, address[] path);

    function swapETHForTokens(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(this);
        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(
            swapOutput, // accept any amount of Tokens
            path,
            deadWallet, // Burn address
            block.timestamp + 300
        );
        emit SwapETHForTokens(amount, path);
    }

    // Withdraw ETH that's potentially stuck in the Contract
    function recoverETHfromContract() external onlyOwner {
        uint ethBalance = address(this).balance;
        (bool succ, ) = payable(taxWallet).call{value: ethBalance}("");
        require(succ, "Transfer failed");
        emit AuditLog(
            "We have recover the stock eth from contract.",
            taxWallet
        );
    }

    // Withdraw ERC20 tokens that are potentially stuck in Contract
    function recoverTokensFromContract(
        address _tokenAddress,
        uint256 _amount
    ) external onlyOwner {
        require(
            _tokenAddress != address(this),
            "Owner can't claim contract's balance of its own tokens"
        );
        bool succ = IERC20(_tokenAddress).transfer(taxWallet, _amount);
        require(succ, "Transfer failed");
        emit Log("We have recovered tokens from contract:", _amount);
    }
}