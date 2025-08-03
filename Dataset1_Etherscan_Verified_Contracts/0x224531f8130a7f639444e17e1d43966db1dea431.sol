// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

pragma solidity ^0.8.0;

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
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
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
    function _transfer(address from, address to, uint256 amount) internal virtual {
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library SafeERC20 {
    using Address for address;
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}

library Clones {
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.6.2;

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
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
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

pragma solidity 0.8.19;

interface IUniswapV2Caller {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        address router,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external;
}
interface IFee {
    function payFee(
        uint256 _tokenType,
        address creator,
        bool isAntibot,
        address referrer
    ) external payable;
}
interface IGemAntiBot {
    function setTokenOwner(address owner) external;

    function onPreTransferCheck(
        address from,
        address to,
        uint256 amount
    ) external;
}
interface DividendTokenDividendTrackerInterface {
    function initialize(
        address rewardToken_,
        uint256 minimumTokenBalanceForDividends_
    ) external;
    function excludeFromDividends(address account) external;
    function isExcludedFromDividends(address account)
        external
        view
        returns (bool);
    function owner() external view returns (address);
    function updateClaimWait(uint256 newClaimWait) external;
    function claimWait() external view returns (uint256);
    function updateMinimumTokenBalanceForDividends(uint256 amount)
        external;
    function minimumTokenBalanceForDividends() external view returns (uint256);
    function totalDividendsDistributed() external view returns (uint256);
    function withdrawableDividendOf(address _owner)
        external
        view
        returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function getAccount(address _account)
        external
        view
        returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable
        );
    function getAccountAtIndex(uint256 index)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );
    function process(uint256 gas)
        external
        returns (
            uint256,
            uint256,
            uint256
        );
    function processAccount(address payable account, bool automatic)
        external
        returns (bool);
    function getLastProcessedIndex() external view returns (uint256);
    function getNumberOfTokenHolders() external view returns (uint256);
    function setBalance(address payable account, uint256 newBalance)
        external;
    function distributeCAKEDividends(uint256 amount) external;
}
contract DividendTokenWithAntibot is ERC20, Ownable {
    using SafeERC20 for IERC20;
    struct Args {
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256 maxWallet;
        uint256 maxTransactionAmount;
        address rewardToken;
        address mainRouter;
        address marketingWallet;
        address dividendTracker;
        address baseTokenForMarket;        
        uint24 sellLiquidityFee;
        uint24 buyLiquidityFee;
        uint24 sellMarketingFee;
        uint24 buyMarketingFee;
        uint24 sellRewardFee;
        uint24 buyRewardFee;
        uint256 minimumTokenBalanceForDividends;
        address tokenForMarketingFee;
        address feeContract;
        address uniswapV2Caller;
    }
    uint256 private constant MAX = ~uint256(0);
    IUniswapV2Caller public uniswapV2Caller;

    address public tokenForMarketingFee;
    uint8 private _decimals;
    address public baseTokenForMarket;
    address public mainRouter;
    address public mainPair;

    bool private swapping;

    address public dividendTracker;

    address public rewardToken;

    uint256 public swapTokensAtAmount;

    uint24 public sellRewardFee;
    uint24 public buyRewardFee;

    uint24 public sellLiquidityFee;
    uint24 public buyLiquidityFee;

    uint24 public sellMarketingFee;
    uint24 public buyMarketingFee;

    address public marketingWallet;
    uint256 public gasForProcessing;
    uint256 public maxWallet;
    uint256 public maxTransactionAmount;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public isExcludedFromMaxTransactionAmount;
    uint256 private _liquidityFeeTokens;
    uint256 private _marketingFeeTokens;
    address public gemAntiBot;
    bool public antiBotEnabled;
    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(
        address indexed newAddress,
        address indexed oldAddress
    );

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event UpdateSwapTokensAtAmount(uint256 newSwapTokensAtAmount, uint256 oldSwapTokensAtAmount);
    event SetAutomatedMarketMakerPair(address indexed pair, bool value);
    event UpdateMaxWallet(uint256 newMaxWallet, uint256 oldMaxWallet);
    event UpdateMaxTransactionAmount(uint256 newMaxTransactionAmount, uint256 oldMaxTransactionAmount);

    event MarketingWalletUpdated(
        address indexed newMarketingWallet,
        address indexed oldMarketingWallet
    );
    event TokenForMarketingFeeUpdated(
        address indexed newTokenForMarketingFee,
        address indexed oldTokenForMarketingFee);
    event ExcludedFromMaxTransactionAmount(address indexed account, bool isExcluded);

    event MainRouterUpdated(address mainRouter, address mainPair, address baseTokenForMarket);
    event GasForProcessingUpdated(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends(uint256 tokensSwapped, uint256 amount);

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    event UpdateLiquidityFee(
        uint24 newSellLiquidityFee,
        uint24 newBuyLiquidityFee,
        uint24 oldSellLiquidityFee,
        uint24 oldBuyLiquidityFee
    );
    event UpdateMarketingFee(
        uint24 newSellMarketingFee,
        uint24 newBuyMarketingFee,
        uint24 oldSellMarketingFee,
        uint24 oldBuyMarketingFee
    );
    event UpdateRewardFee(
        uint24 newSellRewardFee,
        uint24 newBuyRewardFee,
        uint24 oldSellRewardFee,
        uint24 oldBuyRewardFee
    );  

    constructor(
        Args memory args,
        address[] memory autoApproveAddressList,
        address _gemAntiBot,
        address referrer
    ) payable ERC20(args.name, args.symbol) {
        IFee(args.feeContract).payFee{value: msg.value}(3, _msgSender(), true, referrer);   
        uniswapV2Caller = IUniswapV2Caller(args.uniswapV2Caller);
        gemAntiBot = _gemAntiBot;
        IGemAntiBot(gemAntiBot).setTokenOwner(_msgSender());
        antiBotEnabled = true;
        _decimals = args.decimals;
        rewardToken = args.rewardToken;
        marketingWallet = args.marketingWallet;
        emit MarketingWalletUpdated(marketingWallet, address(0));
        baseTokenForMarket=args.baseTokenForMarket;
        sellLiquidityFee = args.sellLiquidityFee;
        buyLiquidityFee = args.buyLiquidityFee;
        emit UpdateLiquidityFee(
            sellLiquidityFee,
            buyLiquidityFee,
            0,
            0
        );
        sellMarketingFee = args.sellMarketingFee;
        buyMarketingFee = args.buyMarketingFee;
        emit UpdateMarketingFee(
            sellMarketingFee,
            buyMarketingFee,
            0,
            0
        );
        sellRewardFee = args.sellRewardFee;
        buyRewardFee = args.buyRewardFee;
        emit UpdateRewardFee(
            sellRewardFee,
            buyRewardFee,
            0,
            0
        );  
        require(sellLiquidityFee+sellMarketingFee+sellRewardFee <= 200000, "sell fee <= 20%");
        require(buyLiquidityFee+buyMarketingFee+buyRewardFee <= 200000, "buy fee <= 20%");
        if(args.tokenForMarketingFee!=args.rewardToken && args.tokenForMarketingFee!=args.baseTokenForMarket){
            tokenForMarketingFee=address(this);
        }else {
            tokenForMarketingFee=args.tokenForMarketingFee;
        }
        emit TokenForMarketingFeeUpdated(tokenForMarketingFee, address(0));
        swapTokensAtAmount = args.totalSupply/10000;
        emit UpdateSwapTokensAtAmount(swapTokensAtAmount, 0);
        gasForProcessing = 300000;
        emit GasForProcessingUpdated(gasForProcessing, 0);

        dividendTracker = payable(Clones.clone(args.dividendTracker));
        emit UpdateDividendTracker(
            dividendTracker,
            address(0)
        );
        DividendTokenDividendTrackerInterface(dividendTracker).initialize(
            rewardToken,
            args.minimumTokenBalanceForDividends
        );
        require(args.maxTransactionAmount>=args.totalSupply / 10000, "maxTransactionAmount >= totalSupply / 10000");
        require(args.maxWallet>=args.totalSupply / 10000, "maxWallet >= totalSupply / 10000");
        maxWallet=args.maxWallet;
        emit UpdateMaxWallet(maxWallet, 0);
        maxTransactionAmount=args.maxTransactionAmount;
        emit UpdateMaxTransactionAmount(maxTransactionAmount, 0);
        mainRouter = args.mainRouter;
        if(baseTokenForMarket != IUniswapV2Router02(mainRouter).WETH()){            
            IERC20(baseTokenForMarket).safeApprove(mainRouter, MAX);            
        }
        _approve(address(this), address(uniswapV2Caller), MAX);
        _approve(address(this), mainRouter, MAX);
        for(uint256 i=0;i<autoApproveAddressList.length;i++){
            _approve(_msgSender(), autoApproveAddressList[i], MAX);
            _isExcludedFromFees[autoApproveAddressList[i]] = true; 
            isExcludedFromMaxTransactionAmount[autoApproveAddressList[i]]=true;
        }
        mainPair = IUniswapV2Factory(IUniswapV2Router02(mainRouter).factory())
            .createPair(address(this), baseTokenForMarket);
        _setAutomatedMarketMakerPair(mainPair, true);
        emit MainRouterUpdated(mainRouter, mainPair, baseTokenForMarket);
        DividendTokenDividendTrackerInterface(dividendTracker).excludeFromDividends(dividendTracker);
        DividendTokenDividendTrackerInterface(dividendTracker).excludeFromDividends(address(this));
        DividendTokenDividendTrackerInterface(dividendTracker).excludeFromDividends(owner());
        DividendTokenDividendTrackerInterface(dividendTracker).excludeFromDividends(address(0xdead));
        DividendTokenDividendTrackerInterface(dividendTracker).excludeFromDividends(mainRouter);

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[marketingWallet] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(0xdead)] = true; 
        isExcludedFromMaxTransactionAmount[address(0xdead)]=true;
        isExcludedFromMaxTransactionAmount[address(this)]=true;
        isExcludedFromMaxTransactionAmount[marketingWallet]=true;
        isExcludedFromMaxTransactionAmount[owner()]=true;     
        _mint(owner(), args.totalSupply);
    }

    function enableAntibot(bool enabled_) external onlyOwner {
        antiBotEnabled = enabled_;
    }
    receive() external payable {}

    function updateMainPair(
        address _mainRouter,
        address _baseTokenForMarket
    ) external onlyOwner
    {
        baseTokenForMarket = _baseTokenForMarket;
        if(mainRouter != _mainRouter){
            _approve(address(this), _mainRouter, MAX);
            if (!DividendTokenDividendTrackerInterface(dividendTracker).isExcludedFromDividends(_mainRouter))
                DividendTokenDividendTrackerInterface(dividendTracker).excludeFromDividends(_mainRouter);
            mainRouter = _mainRouter;
        } 
        mainPair = IUniswapV2Factory(IUniswapV2Router02(mainRouter).factory()).createPair(
            address(this),
            baseTokenForMarket
        );
        if(baseTokenForMarket != IUniswapV2Router02(mainRouter).WETH()){            
            IERC20(baseTokenForMarket).safeApprove(mainRouter, MAX);
        }
        
        emit MainRouterUpdated(mainRouter, mainPair, baseTokenForMarket);
        _setAutomatedMarketMakerPair(mainPair, true);

    }

    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
        require(amount > 0, "swapTokensAtAmount > 0");
        emit UpdateSwapTokensAtAmount(amount, swapTokensAtAmount);
        swapTokensAtAmount = amount;        
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(
            newAddress != dividendTracker,
            "The dividend tracker already has that address"
        );

        address newDividendTracker =payable(newAddress);

        require(
            DividendTokenDividendTrackerInterface(newDividendTracker).owner() == address(this),
            "The new dividend tracker must be owned by the DIVIDENEDTOKEN token contract"
        );

        DividendTokenDividendTrackerInterface(newDividendTracker).excludeFromDividends(newDividendTracker);
        DividendTokenDividendTrackerInterface(newDividendTracker).excludeFromDividends(address(this));
        DividendTokenDividendTrackerInterface(newDividendTracker).excludeFromDividends(owner());
        DividendTokenDividendTrackerInterface(newDividendTracker).excludeFromDividends(mainRouter);
        DividendTokenDividendTrackerInterface(newDividendTracker).excludeFromDividends(mainPair);

        emit UpdateDividendTracker(newAddress, dividendTracker);

        dividendTracker = newDividendTracker;
    }

    function updateMaxWallet(uint256 _maxWallet) external onlyOwner {
        require(_maxWallet>=totalSupply() / 10000, "maxWallet >= total supply / 10000");
        emit UpdateMaxWallet(_maxWallet, maxWallet);
        maxWallet = _maxWallet;        
    }

    function updateMaxTransactionAmount(uint256 _maxTransactionAmount)
        external
        onlyOwner
    {
        require(_maxTransactionAmount>=totalSupply() / 10000, "maxTransactionAmount >= total supply / 10000");
        emit UpdateMaxTransactionAmount(_maxTransactionAmount, maxTransactionAmount);
        maxTransactionAmount = _maxTransactionAmount;        
    }   

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "already");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function setMarketingWallet(address payable wallet) external onlyOwner {
        require(marketingWallet!=wallet, "already");
        emit MarketingWalletUpdated(marketingWallet, wallet);
        marketingWallet = wallet;        
    }

    function updateTokenForMarketingFee(address _tokenForMarketingFee) external onlyOwner {        
        if(_tokenForMarketingFee!=rewardToken && _tokenForMarketingFee!=baseTokenForMarket){
            _tokenForMarketingFee=address(this);
        }
        require(tokenForMarketingFee!=_tokenForMarketingFee, "already");
        emit TokenForMarketingFeeUpdated(_tokenForMarketingFee, tokenForMarketingFee);
        tokenForMarketingFee = _tokenForMarketingFee; 
    }

    function updateLiquidityFee(
        uint24 _sellLiquidityFee,
        uint24 _buyLiquidityFee
    ) external onlyOwner {
        require(
            _sellLiquidityFee+sellMarketingFee+sellRewardFee <= 200000,
            "sell fee <= 20%"
        );
        require(
            _buyLiquidityFee+buyMarketingFee+buyRewardFee <= 200000,
            "buy fee <= 20%"
        );
        emit UpdateLiquidityFee(
            _sellLiquidityFee,
            _buyLiquidityFee,
            sellLiquidityFee,
            buyLiquidityFee
        );
        sellLiquidityFee = _sellLiquidityFee;
        buyLiquidityFee = _buyLiquidityFee;   
    }

    function updateMarketingFee(
        uint24 _sellMarketingFee,
        uint24 _buyMarketingFee
    ) external onlyOwner {
        require(
            _sellMarketingFee+sellLiquidityFee+sellRewardFee <= 200000,
            "sell fee <= 20%"
        );
        require(
            _buyMarketingFee+buyLiquidityFee+buyRewardFee <= 200000,
            "buy fee <= 20%"
        );       
        emit UpdateMarketingFee(
            _sellMarketingFee,
            _buyMarketingFee,
            sellMarketingFee,
            buyMarketingFee
        );  
        sellMarketingFee = _sellMarketingFee;
        buyMarketingFee = _buyMarketingFee;        
    }

    function updateRewardFee(
        uint24 _sellRewardFee,
        uint24 _buyRewardFee
    ) external onlyOwner {
        require(
            _sellRewardFee+sellLiquidityFee+sellMarketingFee <= 200000,
            "sell fee <= 20%"
        );
        require(
            _buyRewardFee+buyLiquidityFee+buyMarketingFee <= 200000,
            "buy fee <= 20%"
        );
        emit UpdateRewardFee(
            _sellRewardFee, 
            _buyRewardFee,
            sellRewardFee, 
            buyRewardFee);
        sellRewardFee = _sellRewardFee;
        buyRewardFee = _buyRewardFee;        
    }


    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != mainPair,
            "The main pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {        
        automatedMarketMakerPairs[pair] = value;
        isExcludedFromMaxTransactionAmount[pair] = value;
        if (value && !DividendTokenDividendTrackerInterface(dividendTracker).isExcludedFromDividends(pair)) {
            DividendTokenDividendTrackerInterface(dividendTracker).excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromMaxTransactionAmount(address account, bool isEx)
        external
        onlyOwner
    {
        require(isExcludedFromMaxTransactionAmount[account]!=isEx, "already");
        isExcludedFromMaxTransactionAmount[account] = isEx;
        emit ExcludedFromMaxTransactionAmount(account, isEx);
    }
    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(
            newValue >= 200000 && newValue <= 500000,
            "gasForProcessing must be between 200,000 and 500,000"
        );
        require(
            newValue != gasForProcessing,
            "Cannot update gasForProcessing to same value"
        );
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        DividendTokenDividendTrackerInterface(dividendTracker).updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns (uint256) {
        return DividendTokenDividendTrackerInterface(dividendTracker).claimWait();
    }

    function updateMinimumTokenBalanceForDividends(uint256 amount)
        external
        onlyOwner
    {
        DividendTokenDividendTrackerInterface(dividendTracker).updateMinimumTokenBalanceForDividends(amount);
    }

    function getMinimumTokenBalanceForDividends()
        external
        view
        returns (uint256)
    {
        return DividendTokenDividendTrackerInterface(dividendTracker).minimumTokenBalanceForDividends();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return DividendTokenDividendTrackerInterface(dividendTracker).totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account)
        public
        view
        returns (uint256)
    {
        return DividendTokenDividendTrackerInterface(dividendTracker).withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account)
        public
        view
        returns (uint256)
    {
        return DividendTokenDividendTrackerInterface(dividendTracker).balanceOf(account);
    }

    function excludeFromDividends(address account) external onlyOwner {
        DividendTokenDividendTrackerInterface(dividendTracker).excludeFromDividends(account);
    }

    function isExcludedFromDividends(address account)
        public
        view
        returns (bool)
    {
        return DividendTokenDividendTrackerInterface(dividendTracker).isExcludedFromDividends(account);
    }

    function getAccountDividendsInfo(address account)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return DividendTokenDividendTrackerInterface(dividendTracker).getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return DividendTokenDividendTrackerInterface(dividendTracker).getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        ) = DividendTokenDividendTrackerInterface(dividendTracker).process(gas);
        emit ProcessedDividendTracker(
            iterations,
            claims,
            lastProcessedIndex,
            false,
            gas,
            msg.sender
        );
    }

    function claim() external {
        DividendTokenDividendTrackerInterface(dividendTracker).processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return DividendTokenDividendTrackerInterface(dividendTracker).getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return DividendTokenDividendTrackerInterface(dividendTracker).getNumberOfTokenHolders();
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount>0, "ERC20: transfer zero amount");
        if (antiBotEnabled) {
            IGemAntiBot(gemAntiBot).onPreTransferCheck(from, to, amount);
        }
        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;
            if(_marketingFeeTokens>0)
                swapAndSendToFee(_marketingFeeTokens);
            if(_liquidityFeeTokens>0)
                swapAndLiquify(_liquidityFeeTokens);

            uint256 sellTokens = balanceOf(address(this));
            if(sellTokens>0)
                swapAndSendDividends(sellTokens);
            _marketingFeeTokens=0;
            _liquidityFeeTokens=0;
            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        uint256 _liquidityFee;
        uint256 _marketingFee;
        uint256 _rewardFee;
        if (takeFee) {
            if (automatedMarketMakerPairs[from]) {
                _rewardFee = amount*buyRewardFee/1000000;
                _liquidityFee = amount*buyLiquidityFee/1000000;
                _marketingFee = amount*buyMarketingFee/1000000;
            }
            else if (automatedMarketMakerPairs[to]) {
                _rewardFee = amount*sellRewardFee/1000000;
                _liquidityFee = amount*sellLiquidityFee/1000000;
                _marketingFee = amount*sellMarketingFee/1000000;
            }
            _liquidityFeeTokens = _liquidityFeeTokens+_liquidityFee;
            _marketingFeeTokens = _marketingFeeTokens+_marketingFee;
            uint256 _feeTotal=_rewardFee+_liquidityFee+_marketingFee;
            amount=amount-_feeTotal;
            if(_feeTotal>0)
                super._transfer(from, address(this), _feeTotal);
        }
        
        super._transfer(from, to, amount);

        try
            DividendTokenDividendTrackerInterface(dividendTracker).setBalance(payable(from), balanceOf(from))
        {} catch {}
        try DividendTokenDividendTrackerInterface(dividendTracker).setBalance(payable(to), balanceOf(to)) {} catch {}

        if (!swapping) {
            if (!isExcludedFromMaxTransactionAmount[from]) {
                require(
                    amount <= maxTransactionAmount,
                    "ERC20: exceeds transfer limit"
                );
            }
            if (!isExcludedFromMaxTransactionAmount[to]) {
                require(
                    balanceOf(to) <= maxWallet,
                    "ERC20: exceeds max wallet limit"
                );
            }
            uint256 gas = gasForProcessing;

            try DividendTokenDividendTrackerInterface(dividendTracker).process(gas) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcessedIndex
            ) {
                emit ProcessedDividendTracker(
                    iterations,
                    claims,
                    lastProcessedIndex,
                    true,
                    gas,
                    msg.sender
                );
            } catch {}
        }
    }

    function swapAndSendToFee(uint256 tokens) private {
        if(tokenForMarketingFee==rewardToken){
            uint256 initialCAKEBalance = IERC20(rewardToken).balanceOf(
                address(this)
            );
            swapTokensForCake(tokens);
            uint256 newBalance = (IERC20(rewardToken).balanceOf(address(this)))-(
                initialCAKEBalance
            );
            IERC20(rewardToken).safeTransfer(marketingWallet, newBalance);
        }else if(tokenForMarketingFee==baseTokenForMarket){
            uint256 initialBalance = baseTokenForMarket==IUniswapV2Router02(mainRouter).WETH() ? address(this).balance 
                : IERC20(baseTokenForMarket).balanceOf(address(this));
            swapTokensForBaseToken(tokens);
            uint256 newBalance = baseTokenForMarket==IUniswapV2Router02(mainRouter).WETH() ? address(this).balance-initialBalance
                : IERC20(baseTokenForMarket).balanceOf(address(this))-initialBalance;
            if(baseTokenForMarket==IUniswapV2Router02(mainRouter).WETH()){
                (bool success, )=address(marketingWallet).call{value: newBalance}("");              
            }else{
                IERC20(baseTokenForMarket).safeTransfer(marketingWallet, newBalance);
            } 
        }else{
            _transfer(address(this), marketingWallet, tokens);
        }
        
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens/(2);
        uint256 otherHalf = tokens-(half);

        uint256 initialBalance = baseTokenForMarket==IUniswapV2Router02(mainRouter).WETH() ? address(this).balance 
            : IERC20(baseTokenForMarket).balanceOf(address(this));

        swapTokensForBaseToken(half); 
        uint256 newBalance = baseTokenForMarket==IUniswapV2Router02(mainRouter).WETH() ? address(this).balance-initialBalance
            : IERC20(baseTokenForMarket).balanceOf(address(this))-initialBalance;

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForBaseToken(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = baseTokenForMarket;

        if (path[1] == IUniswapV2Router02(mainRouter).WETH()){
            IUniswapV2Router02(mainRouter).swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of BaseToken
                path,
                address(this),
                block.timestamp
            );
        }else{
            uniswapV2Caller.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    mainRouter,
                    tokenAmount,
                    0, // accept any amount of BaseToken
                    path,
                    block.timestamp
                );
        }
    }

    function swapTokensForCake(uint256 tokenAmount) private {
        if(baseTokenForMarket!=rewardToken){
            address[] memory path = new address[](3);
            path[0] = address(this);
            path[1] = baseTokenForMarket;
            path[2] = rewardToken;
            IUniswapV2Router02(mainRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }else{
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = rewardToken;
            uniswapV2Caller.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                mainRouter,
                tokenAmount,
                0, // accept any amount of BaseToken
                path,
                block.timestamp
            );            
        }
        
    }

    function addLiquidity(uint256 tokenAmount, uint256 baseTokenAmount) private {
        if (baseTokenForMarket == IUniswapV2Router02(mainRouter).WETH()) 
            IUniswapV2Router02(mainRouter).addLiquidityETH{value: baseTokenAmount}(
                address(this),
                tokenAmount,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                address(0xdead),
                block.timestamp
            );
        else{
            IUniswapV2Router02(mainRouter).addLiquidity(
                address(this),
                baseTokenForMarket,
                tokenAmount,
                baseTokenAmount,
                0,
                0,
                address(0xdead),
                block.timestamp
            );    
        }
                
    }

    function swapAndSendDividends(uint256 tokens) private {
        swapTokensForCake(tokens);
        uint256 dividends = IERC20(rewardToken).balanceOf(address(this));
        IERC20(rewardToken).safeTransfer(
            dividendTracker,
            dividends
        );
        DividendTokenDividendTrackerInterface(dividendTracker).distributeCAKEDividends(dividends);
        emit SendDividends(tokens, dividends);
    }
    function withdrawETH() external onlyOwner {
        (bool success, )=address(owner()).call{value: address(this).balance}("");
        require(success, "Failed in withdrawal");
    }
    function withdrawToken(address token) external onlyOwner{
        require(address(this) != token, "Not allowed");
        IERC20(token).safeTransfer(owner(), IERC20(token).balanceOf(address(this)));
    }
}