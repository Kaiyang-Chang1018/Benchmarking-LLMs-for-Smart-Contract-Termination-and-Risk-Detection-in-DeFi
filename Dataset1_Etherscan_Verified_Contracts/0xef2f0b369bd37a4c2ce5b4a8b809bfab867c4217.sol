// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IAxelarGateway } from '../interfaces/IAxelarGateway.sol';
import { IAxelarExecutable } from '../interfaces/IAxelarExecutable.sol';

contract AxelarExecutable is IAxelarExecutable {
    IAxelarGateway public immutable gateway;

    constructor(address gateway_) {
        if (gateway_ == address(0)) revert InvalidAddress();

        gateway = IAxelarGateway(gateway_);
    }

    function execute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external {
        bytes32 payloadHash = keccak256(payload);

        if (!gateway.validateContractCall(commandId, sourceChain, sourceAddress, payloadHash))
            revert NotApprovedByGateway();

        _execute(sourceChain, sourceAddress, payload);
    }

    function executeWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) external {
        bytes32 payloadHash = keccak256(payload);

        if (
            !gateway.validateContractCallAndMint(
                commandId,
                sourceChain,
                sourceAddress,
                payloadHash,
                tokenSymbol,
                amount
            )
        ) revert NotApprovedByGateway();

        _executeWithToken(sourceChain, sourceAddress, payload, tokenSymbol, amount);
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal virtual {}

    function _executeWithToken(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IAxelarGateway } from './IAxelarGateway.sol';

interface IAxelarExecutable {
    error InvalidAddress();
    error NotApprovedByGateway();

    function gateway() external view returns (IAxelarGateway);

    function execute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external;

    function executeWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// This should be owned by the microservice that is paying for gas.
interface IAxelarGasService {
    error NothingReceived();
    error InvalidAddress();
    error NotCollector();
    error InvalidAmounts();

    event GasPaidForContractCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasPaidForContractCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForContractCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForContractCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasPaidForExpressCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForExpressCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasAdded(
        bytes32 indexed txHash,
        uint256 indexed logIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasAdded(bytes32 indexed txHash, uint256 indexed logIndex, uint256 gasFeeAmount, address refundAddress);

    event ExpressGasAdded(
        bytes32 indexed txHash,
        uint256 indexed logIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeExpressGasAdded(
        bytes32 indexed txHash,
        uint256 indexed logIndex,
        uint256 gasFeeAmount,
        address refundAddress
    );

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payNativeGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable;

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payNativeGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable;

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payGasForExpressCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payNativeGasForExpressCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable;

    function addGas(
        bytes32 txHash,
        uint256 txIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    function addNativeGas(
        bytes32 txHash,
        uint256 logIndex,
        address refundAddress
    ) external payable;

    function addExpressGas(
        bytes32 txHash,
        uint256 txIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    function addNativeExpressGas(
        bytes32 txHash,
        uint256 logIndex,
        address refundAddress
    ) external payable;

    function collectFees(
        address payable receiver,
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external;

    function refund(
        address payable receiver,
        address token,
        uint256 amount
    ) external;

    function gasCollector() external returns (address);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IAxelarGateway {
    /**********\
    |* Errors *|
    \**********/

    error NotSelf();
    error NotProxy();
    error InvalidCodeHash();
    error SetupFailed();
    error InvalidAuthModule();
    error InvalidTokenDeployer();
    error InvalidAmount();
    error InvalidChainId();
    error InvalidCommands();
    error TokenDoesNotExist(string symbol);
    error TokenAlreadyExists(string symbol);
    error TokenDeployFailed(string symbol);
    error TokenContractDoesNotExist(address token);
    error BurnFailed(string symbol);
    error MintFailed(string symbol);
    error InvalidSetMintLimitsParams();
    error ExceedMintLimit(string symbol);

    /**********\
    |* Events *|
    \**********/

    event TokenSent(
        address indexed sender,
        string destinationChain,
        string destinationAddress,
        string symbol,
        uint256 amount
    );

    event ContractCall(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload
    );

    event ContractCallWithToken(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload,
        string symbol,
        uint256 amount
    );

    event Executed(bytes32 indexed commandId);

    event TokenDeployed(string symbol, address tokenAddresses);

    event ContractCallApproved(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event ContractCallApprovedWithMint(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event TokenMintLimitUpdated(string symbol, uint256 limit);

    event OperatorshipTransferred(bytes newOperatorsData);

    event Upgraded(address indexed implementation);

    /********************\
    |* Public Functions *|
    \********************/

    function sendToken(
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata symbol,
        uint256 amount
    ) external;

    function callContract(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload
    ) external;

    function callContractWithToken(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount
    ) external;

    function isContractCallApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash
    ) external view returns (bool);

    function isContractCallAndMintApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external view returns (bool);

    function validateContractCall(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash
    ) external returns (bool);

    function validateContractCallAndMint(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external returns (bool);

    /***********\
    |* Getters *|
    \***********/

    function authModule() external view returns (address);

    function tokenDeployer() external view returns (address);

    function tokenMintLimit(string memory symbol) external view returns (uint256);

    function tokenMintAmount(string memory symbol) external view returns (uint256);

    function allTokensFrozen() external view returns (bool);

    function implementation() external view returns (address);

    function tokenAddresses(string memory symbol) external view returns (address);

    function tokenFrozen(string memory symbol) external view returns (bool);

    function isCommandExecuted(bytes32 commandId) external view returns (bool);

    function adminEpoch() external view returns (uint256);

    function adminThreshold(uint256 epoch) external view returns (uint256);

    function admins(uint256 epoch) external view returns (address[] memory);

    /*******************\
    |* Admin Functions *|
    \*******************/

    function setTokenMintLimits(string[] calldata symbols, uint256[] calldata limits) external;

    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata setupParams
    ) external;

    /**********************\
    |* External Functions *|
    \**********************/

    function setup(bytes calldata params) external;

    function execute(bytes calldata input) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library StringToAddress {
    error InvalidAddressString();

    function toAddress(string memory addressString) internal pure returns (address) {
        bytes memory stringBytes = bytes(addressString);
        uint160 addressNumber = 0;
        uint8 stringByte;

        if (stringBytes.length != 42 || stringBytes[0] != '0' || stringBytes[1] != 'x') revert InvalidAddressString();

        for (uint256 i = 2; i < 42; ++i) {
            stringByte = uint8(stringBytes[i]);

            if ((stringByte >= 97) && (stringByte <= 102)) stringByte -= 87;
            else if ((stringByte >= 65) && (stringByte <= 70)) stringByte -= 55;
            else if ((stringByte >= 48) && (stringByte <= 57)) stringByte -= 48;
            else revert InvalidAddressString();

            addressNumber |= uint160(uint256(stringByte) << ((41 - i) << 2));
        }
        return address(addressNumber);
    }
}

library AddressToString {
    function toString(address addr) internal pure returns (string memory) {
        bytes memory addressBytes = abi.encodePacked(addr);
        uint256 length = addressBytes.length;
        bytes memory characters = '0123456789abcdef';
        bytes memory stringBytes = new bytes(2 + addressBytes.length * 2);

        stringBytes[0] = '0';
        stringBytes[1] = 'x';

        for (uint256 i; i < length; ++i) {
            stringBytes[2 + i * 2] = characters[uint8(addressBytes[i] >> 4)];
            stringBytes[3 + i * 2] = characters[uint8(addressBytes[i] & 0x0f)];
        }
        return string(stringBytes);
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.5.0;

import "./ILayerZeroUserApplicationConfig.sol";

interface ILayerZeroEndpoint is ILayerZeroUserApplicationConfig {
    // @notice send a LayerZero message to the specified address at a LayerZero endpoint.
    // @param _dstChainId - the destination chain identifier
    // @param _destination - the address on destination chain (in bytes). address length/format may vary by chains
    // @param _payload - a custom bytes payload to send to the destination contract
    // @param _refundAddress - if the source transaction is cheaper than the amount of value passed, refund the additional amount to this address
    // @param _zroPaymentAddress - the address of the ZRO token holder who would pay for the transaction
    // @param _adapterParams - parameters for custom functionality. e.g. receive airdropped native gas from the relayer on destination
    function send(
        uint16 _dstChainId,
        bytes calldata _destination,
        bytes calldata _payload,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes calldata _adapterParams
    ) external payable;

    // @notice used by the messaging library to publish verified payload
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source contract (as bytes) at the source chain
    // @param _dstAddress - the address on destination chain
    // @param _nonce - the unbound message ordering nonce
    // @param _gasLimit - the gas limit for external contract execution
    // @param _payload - verified payload to send to the destination contract
    function receivePayload(
        uint16 _srcChainId,
        bytes calldata _srcAddress,
        address _dstAddress,
        uint64 _nonce,
        uint _gasLimit,
        bytes calldata _payload
    ) external;

    // @notice get the inboundNonce of a receiver from a source chain which could be EVM or non-EVM chain
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    function getInboundNonce(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (uint64);

    // @notice get the outboundNonce from this source chain which, consequently, is always an EVM
    // @param _srcAddress - the source chain contract address
    function getOutboundNonce(uint16 _dstChainId, address _srcAddress) external view returns (uint64);

    // @notice gets a quote in source native gas, for the amount that send() requires to pay for message delivery
    // @param _dstChainId - the destination chain identifier
    // @param _userApplication - the user app address on this EVM chain
    // @param _payload - the custom message to send over LayerZero
    // @param _payInZRO - if false, user app pays the protocol fee in native token
    // @param _adapterParam - parameters for the adapter service, e.g. send some dust native token to dstChain
    function estimateFees(
        uint16 _dstChainId,
        address _userApplication,
        bytes calldata _payload,
        bool _payInZRO,
        bytes calldata _adapterParam
    ) external view returns (uint nativeFee, uint zroFee);

    // @notice get this Endpoint's immutable source identifier
    function getChainId() external view returns (uint16);

    // @notice the interface to retry failed message on this Endpoint destination
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    // @param _payload - the payload to be retried
    function retryPayload(uint16 _srcChainId, bytes calldata _srcAddress, bytes calldata _payload) external;

    // @notice query if any STORED payload (message blocking) at the endpoint.
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    function hasStoredPayload(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (bool);

    // @notice query if the _libraryAddress is valid for sending msgs.
    // @param _userApplication - the user app address on this EVM chain
    function getSendLibraryAddress(address _userApplication) external view returns (address);

    // @notice query if the _libraryAddress is valid for receiving msgs.
    // @param _userApplication - the user app address on this EVM chain
    function getReceiveLibraryAddress(address _userApplication) external view returns (address);

    // @notice query if the non-reentrancy guard for send() is on
    // @return true if the guard is on. false otherwise
    function isSendingPayload() external view returns (bool);

    // @notice query if the non-reentrancy guard for receive() is on
    // @return true if the guard is on. false otherwise
    function isReceivingPayload() external view returns (bool);

    // @notice get the configuration of the LayerZero messaging library of the specified version
    // @param _version - messaging library version
    // @param _chainId - the chainId for the pending config change
    // @param _userApplication - the contract address of the user application
    // @param _configType - type of configuration. every messaging library has its own convention.
    function getConfig(
        uint16 _version,
        uint16 _chainId,
        address _userApplication,
        uint _configType
    ) external view returns (bytes memory);

    // @notice get the send() LayerZero messaging library version
    // @param _userApplication - the contract address of the user application
    function getSendVersion(address _userApplication) external view returns (uint16);

    // @notice get the lzReceive() LayerZero messaging library version
    // @param _userApplication - the contract address of the user application
    function getReceiveVersion(address _userApplication) external view returns (uint16);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.5.0;

interface ILayerZeroUserApplicationConfig {
    // @notice set the configuration of the LayerZero messaging library of the specified version
    // @param _version - messaging library version
    // @param _chainId - the chainId for the pending config change
    // @param _configType - type of configuration. every messaging library has its own convention.
    // @param _config - configuration in the bytes. can encode arbitrary content.
    function setConfig(uint16 _version, uint16 _chainId, uint _configType, bytes calldata _config) external;

    // @notice set the send() LayerZero messaging library version to _version
    // @param _version - new messaging library version
    function setSendVersion(uint16 _version) external;

    // @notice set the lzReceive() LayerZero messaging library version to _version
    // @param _version - new messaging library version
    function setReceiveVersion(uint16 _version) external;

    // @notice Only when the UA needs to resume the message flow in blocking mode and clear the stored payload
    // @param _srcChainId - the chainId of the source chain
    // @param _srcAddress - the contract address of the source contract at the source chain
    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC165.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
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
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
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
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
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
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
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

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
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

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

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
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.2) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.25;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IBurnRedeemable} from "./interfaces/IBurnRedeemable.sol";
import {ICore} from "./interfaces/ICore.sol";
import {IALX} from "./interfaces/IALX.sol";
import {Bridge} from "./base/Bridge.sol";

/// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| \\\

/**
 * @title Interface for the ALX airdrop stake functionality.
 * @dev Defines functions for staking airdropped ALX tokens.
 */
interface IALXStake {

    /**
     * @notice Stakes ALX tokens received via airdrop.
     * @dev This function allows users to stake their airdropped ALX tokens.
     * @param _user The address of the user staking the tokens.
     * @param _amount The amount of ALX tokens to stake.
     * @param _duration The duration for staking the tokens.
     */
    function stakeWithAirdroppedALX(
        address _user,
        uint256 _amount,
        uint256 _duration
    ) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
}

/// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| \\\

/*
 * @title ALX Contract
 *
 * @notice Implements a token with airdrop and burnable functionalities.
 *
 * Co-Founders:
 * - Simran Dhillon: simran@xenify.io
 * - Hardev Dhillon: hardev@xenify.io
 * - Dayana Plaz: dayana@xenify.io
 *
 * Official Links:
 * - Twitter: https://twitter.com/alixa_io
 * - Telegram: https://t.me/alixa_io
 * - Website: https://alixa.io
 *
 * Disclaimer:
 * This contract aligns with the principles of the Fair Crypto Foundation, promoting self-custody, transparency, consensus-based
 * trust, and permissionless value exchange. There are no administrative access keys, underscoring our commitment to decentralisation.
 * Engaging with this contract involves technical and legal risks. Users must conduct their own due diligence and ensure compliance
 * with local laws and regulations. The software is provided "AS-IS," without warranties, and the co-founders and developers disclaim
 * all liability for any vulnerabilities, exploits, errors, or breaches that may occur. By using this contract, users accept all associated
 * risks and this disclaimer. The co-founders, developers, or related parties will not bear liability for any consequences of non-compliance.
 *
 * Redistribution and Use:
 * Redistribution, modification, or repurposing of this contract, in whole or in part, is strictly prohibited without express written
 * approval from all co-founders. Approval requests must be sent to the official email addresses of the co-founders, ensuring responses
 * are received directly from these addresses. Proposals for redistribution, modification, or repurposing must include a detailed explanation
 * of the intended changes or uses and the reasons behind them. The co-founders reserve the right to request additional information or
 * clarification as necessary. Approval is at the sole discretion of the co-founders and may be subject to conditions to uphold the
 * project’s integrity and the values of the Fair Crypto Foundation. Failure to obtain express written approval prior to any redistribution,
 * modification, or repurposing will result in a breach of these terms and immediate legal action.
 *
 * Copyright and License:
 * Copyright © 2024 Alixa (Simran Dhillon, Hardev Dhillon, Dayana Plaz). All rights reserved.
 * This software is provided 'as is' and may be used by the recipient. No permission is granted for redistribution,
 * modification, or repurposing of this contract. Any use beyond the scope defined herein may be subject to legal action.
 */
contract ALX is Bridge, IALX {

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ---------------------------------------------------------- VARIABLES ------------------------------------------------------------ \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Protocol owned pool address.
     * @dev This variable holds the protocol-owned pool address.
     */
    address public pool;

    /**
     * @notice Address of the core contract.
     * @dev This variable holds the address of the core contract.
     */
    address public immutable core;

    /**
     * @notice Root of the Merkle tree for airdrop claims.
     * @dev This variable holds the Merkle root for verifying airdrop claims.
     */
    bytes32 public immutable merkleRoot;

    /**
     * @notice Total supply of airdropped tokens.
     * @dev This variable holds the total supply of airdropped tokens.
     */
    uint256 public totalAirdroppedSupply;

    /**
     * @notice Marks the time when airdrop claiming begins.
     * @dev This variable holds the timestamp when the contract is deployed.
     */
    uint256 public immutable initialTimestamp;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ---------------------------------------------------------- MAPPINGS ------------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Records the total number of tokens burned by each user.
     * @dev This mapping tracks the number of tokens burned by each user.
     */
    mapping (address user => uint256 amountBurnt) public userBurns;

    /**
     * @notice Tracks the amount that was claimed.
     * @dev This mapping tracks the amount of tokens claimed from the airdrop.
     */
    mapping (bytes32 leaf => uint256 amountClaimed) public airdropClaimed;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------------ ERRORS ------------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Error when the core address is set more than once.
     * @dev Triggered when attempting to set the core address more than once.
     */
    error ContractAlreadySet();

    /**
     * @notice Error when claiming more than airdropped.
     * @dev Triggered when a claim exceeds the airdropped amount.
     */
    error InsufficientAirdroppedAmount();

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ---------------------------------------------------------- CONSTRUCTOR ---------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Initialises the ALX token with given parameters.
     * @dev Sets up the token with bridge functionality and airdrop parameters.
     * @param _merkleRoot Merkle root for airdrop claim verification.
     * @param _core Core contract address.
     * @param _gateway Gateway address for the bridge token.
     * @param _gasService Gas service address for the bridge token.
     * @param _endpoint Endpoint address for the bridge token.
     * @param _wormholeRelayer Wormhole relayer address for the bridge token.
     */
    constructor(
        bytes32 _merkleRoot,
        address _core,
        address _gateway,
        address _gasService,
        address _endpoint,
        address _wormholeRelayer
    ) payable
        Bridge(
            "ALX",
            "ALX",
            _gateway,
            _gasService,
            _endpoint,
            _wormholeRelayer
        )
    {
        initialTimestamp = block.timestamp;
        merkleRoot = _merkleRoot;
        core = _core;
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ----------------------------------------------------- EXTERNAL FUNCTIONS -------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Sets the ALX-vXNF POL address.
     * @dev Can only be set once by the core contract.
     * @param _ALXPOL The address of the ALX-vXNF POL contract.
     */
    function setPool(address _ALXPOL) external {
        if (pool != address(0))
            revert ContractAlreadySet();
        if (_ALXPOL == address(0))
            revert ZeroAddress();
        if (msg.sender == core)
            pool = _ALXPOL;
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Claims airdropped tokens using a Merkle proof.
     * @dev Verifies the claim against the Merkle root and mints the tokens.
     * @param _proof Array of bytes32 values representing the Merkle proof.
     * @param _airdroppedAmount Total airdropped amount for the user.
     * @param _amountToClaim Amount of tokens being claimed.
     */
    function claim(
        bytes32[] calldata _proof,
        uint256 _airdroppedAmount,
        uint256 _amountToClaim
    ) external {
        if (pool == address(0) || block.timestamp > initialTimestamp + 90 days)
            revert AirdropPeriodNotActive();
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, _airdroppedAmount))));
        if (!MerkleProof.verify(_proof, merkleRoot, leaf)) {
            revert InvalidClaimProof();
        }
        uint256 airdropClaimedAmount = airdropClaimed[leaf];
        if (_amountToClaim > _airdroppedAmount - airdropClaimedAmount) {
            revert InsufficientAirdroppedAmount();
        }
        unchecked {
            airdropClaimed[leaf] = airdropClaimedAmount + _amountToClaim;
            totalAirdroppedSupply = totalAirdroppedSupply + _amountToClaim;
        }
        _mint(msg.sender, _amountToClaim);
        emit Airdropped(msg.sender, _amountToClaim);
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Purchases bonds using airdropped ALX tokens.
     * @dev Verifies the user's airdropped tokens and initiates bond purchase.
     * @param _proof Merkle proof for verification.
     * @param _user Address of the user purchasing bonds.
     * @param _bondPower The power of the bond being purchased.
     * @param _bondCount The number of bonds to purchase.
     * @param _daysCount The duration of the bond in days.
     * @param _airdroppedAmount The total amount of airdropped tokens available.
     */
    function purchaseBondWithAirdroppedALX(
        bytes32[] calldata _proof,
        address _user,
        uint256 _bondPower,
        uint256 _bondCount,
        uint256 _daysCount,
        uint256 _airdroppedAmount
    ) external {
        if (block.timestamp > initialTimestamp + 90 days) {
            revert AirdropPeriodNotActive();
        }
        uint256 ALXRequired = ICore(core).getTokenAmounts(_bondPower, _bondCount, false);
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, _airdroppedAmount))));
        if (!MerkleProof.verify(_proof, merkleRoot, leaf)) {
            revert InvalidClaimProof();
        }
        uint256 airdropClaimedAmount = airdropClaimed[leaf];
        if (ALXRequired > _airdroppedAmount - airdropClaimedAmount) {
            revert InsufficientAirdroppedAmount();
        }
        unchecked {
            airdropClaimed[leaf] = airdropClaimedAmount + ALXRequired;
            totalAirdroppedSupply = totalAirdroppedSupply + ALXRequired;
        }
        emit Airdropped(msg.sender, ALXRequired);
        ICore(core).purchaseBondWithAirdroppedALX(
            _user,
            _bondCount,
            _daysCount,
            _bondPower,
            ALXRequired
        );
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Stakes airdropped ALX tokens.
     * @dev Verifies the user's airdropped tokens and initiates staking.
     * @param _proof Merkle proof for verification.
     * @param _user Address of the user staking tokens.
     * @param _duration Duration of the stake.
     * @param _amountToStake Amount of tokens being staked.
     * @param _airdroppedAmount The total amount of airdropped tokens available.
     */
    function stakeWithAirdroppedALX(
        bytes32[] calldata _proof,
        address _user,
        uint256 _duration,
        uint256 _amountToStake,
        uint256 _airdroppedAmount
    ) external {
        if (block.timestamp > initialTimestamp + 90 days) {
            revert AirdropPeriodNotActive();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, _airdroppedAmount))));
        if (!MerkleProof.verify(_proof, merkleRoot, leaf)) {
            revert InvalidClaimProof();
        }
        uint256 airdropClaimedAmount = airdropClaimed[leaf];
        if (_amountToStake > _airdroppedAmount - airdropClaimedAmount) {
            revert InsufficientAirdroppedAmount();
        }
        unchecked {
            airdropClaimed[leaf] = airdropClaimedAmount + _amountToStake;
            totalAirdroppedSupply = totalAirdroppedSupply + _amountToStake;
        }
        _mint(core, _amountToStake);
        emit Airdropped(msg.sender, _amountToStake);
        IALXStake(core).stakeWithAirdroppedALX(
            _user,
            _amountToStake,
            _duration
        );
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Mints ALX tokens to an account.
     * @dev Can only be called by the core contract.
     * @param _account The account to which the tokens will be minted.
     * @param _amount The amount of ALX tokens to mint.
     */
    function mint(address _account, uint256 _amount) external {
        if (msg.sender != core)
            revert InvalidCaller();
        if (totalSupply() + _amount + totalBridgedAmount > 50_000_000 ether)
            revert MaxSupplyExceeded();
        _mint(_account, _amount);
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Burns ALX tokens from a user's account.
     * @dev Can only be called by a contract implementing IBurnRedeemable.
     * @param _user The user from whom tokens will be burned.
     * @param _amount The amount of ALX tokens to burn.
     */
    function burn(address _user, uint256 _amount) external {
        if (!IERC165(msg.sender).supportsInterface(type(IBurnRedeemable).interfaceId)) {
            revert UnsupportedInterface();
        }
        if (msg.sender != _user) {
            _spendAllowance(
                _user,
                msg.sender,
                _amount
            );
        }
        _burn(_user, _amount);
        unchecked {
            userBurns[_user] += _amount;
        }
        IBurnRedeemable(msg.sender).onTokenBurned(_user, _amount);
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
}
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.25;

import {StringToAddress, AddressToString} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/utils/AddressString.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {ILayerZeroEndpoint} from "@layerzerolabs/lz-evm-sdk-v1-0.7/contracts/interfaces/ILayerZeroEndpoint.sol";
import {IWormholeRelayer} from "../interfaces/IWormholeRelayer.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IBridgeToken} from "../interfaces/IBridgeToken.sol";

/// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| \\\

/*
 * @title Bridge Contract
 *
 * @notice This contract facilitates cross-chain token bridging, utilising LayerZero, Axelar, and Wormhole protocols for interoperable token transfers.
 *
 * Co-Founders:
 * - Simran Dhillon: simran@xenify.io
 * - Hardev Dhillon: hardev@xenify.io
 * - Dayana Plaz: dayana@xenify.io
 *
 * Official Links:
 * - Twitter: https://twitter.com/alixa_io
 * - Telegram: https://t.me/alixa_io
 * - Website: https://alixa.io
 *
 * Disclaimer:
 * This contract aligns with the principles of the Fair Crypto Foundation, promoting self-custody, transparency, consensus-based
 * trust, and permissionless value exchange. There are no administrative access keys, underscoring our commitment to decentralisation.
 * Engaging with this contract involves technical and legal risks. Users must conduct their own due diligence and ensure compliance
 * with local laws and regulations. The software is provided "AS-IS," without warranties, and the co-founders and developers disclaim
 * all liability for any vulnerabilities, exploits, errors, or breaches that may occur. By using this contract, users accept all associated
 * risks and this disclaimer. The co-founders, developers, or related parties will not bear liability for any consequences of non-compliance.
 *
 * Redistribution and Use:
 * Redistribution, modification, or repurposing of this contract, in whole or in part, is strictly prohibited without express written
 * approval from all co-founders. Approval requests must be sent to the official email addresses of the co-founders, ensuring responses
 * are received directly from these addresses. Proposals for redistribution, modification, or repurposing must include a detailed explanation
 * of the intended changes or uses and the reasons behind them. The co-founders reserve the right to request additional information or
 * clarification as necessary. Approval is at the sole discretion of the co-founders and may be subject to conditions to uphold the
 * project’s integrity and the values of the Fair Crypto Foundation. Failure to obtain express written approval prior to any redistribution,
 * modification, or repurposing will result in a breach of these terms and immediate legal action.
 *
 * Copyright and License:
 * Copyright © 2024 Alixa (Simran Dhillon, Hardev Dhillon, Dayana Plaz). All rights reserved.
 * This software is provided 'as is' and may be used by the recipient. No permission is granted for redistribution,
 * modification, or repurposing of this contract. Any use beyond the scope defined herein may be subject to legal action.
 */
abstract contract Bridge is
    AxelarExecutable,
    IBridgeToken,
    ERC20
{

    /// -------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ----------------------------------------------------------- LIBRARIES ---------------------------------------------------------- \\\
    /// -------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Converts string to address format.
     * @dev Attaches StringToAddress library functions to string type for address conversions.
     */
    using StringToAddress for string;

    /**
     * @notice Converts address to string format.
     * @dev Attaches AddressToString library functions to address type for string conversions.
     */
    using AddressToString for address;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ---------------------------------------------------------- VARIABLES ------------------------------------------------------------ \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Address of this token in string format.
     * @dev Used for identifying this contract's address across various bridging protocols.
     */
    string public addressThis;

    /**
     * @notice Total amount of tokens bridged across all chains.
     * @dev Tracks the cumulative number of tokens bridged across all supported chains.
     */
    uint256 totalBridgedAmount;

    /**
     * @notice Interface for LayerZero endpoint.
     * @dev Used for interacting with LayerZero for cross-chain token transfers.
     */
    ILayerZeroEndpoint public immutable ENDPOINT;

    /**
     * @notice Interface for Axelar gas service.
     * @dev Used for estimating and paying gas fees for Axelar's cross-chain operations.
     */
    IAxelarGasService public immutable GAS_SERVICE;

    /**
     * @notice Interface for Wormhole relayer.
     * @dev Facilitates cross-chain transfers using the Wormhole protocol.
     */
    IWormholeRelayer public immutable WORMHOLE_RELAYER;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ----------------------------------------------------------- MAPPING ------------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Mapping to prevent replay attacks.
     * @dev Stores processed delivery hashes to prevent duplicate processing of messages.
     */
    mapping (bytes32 => bool) public seenDeliveryVaaHashes;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ----------------------------------------------------------- MODIFIER ------------------------------------------------------------ \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Ensures that a Wormhole message is processed only once.
     * @dev Checks if the provided _deliveryHash has been seen before to prevent replay attacks.
     * @param _deliveryHash Unique hash representing the delivery message from the Wormhole relayer.
     */
    modifier replayProtect(bytes32 _deliveryHash) {
        if (seenDeliveryVaaHashes[_deliveryHash]) {
            revert WormholeMessageAlreadyProcessed();
        }
        seenDeliveryVaaHashes[_deliveryHash] = true;
        _;
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ---------------------------------------------------------- CONSTRUCTOR ---------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Initialises a new Bridge contract instance.
     * @dev Sets up essential external contracts and services for bridge operations.
     * @param _name The name of the bridge token.
     * @param _symbol The symbol of the bridge token.
     * @param _gateway The address of the Axelar gateway contract.
     * @param _gasService The address of the Axelar gas service contract.
     * @param _endpoint The address of the LayerZero endpoint contract.
     * @param _wormholeRelayer The address of the Wormhole relayer contract.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _gateway,
        address _gasService,
        address _endpoint,
        address _wormholeRelayer
    ) ERC20(_name, _symbol) AxelarExecutable(_gateway) {
        GAS_SERVICE = IAxelarGasService(_gasService);
        ENDPOINT = ILayerZeroEndpoint(_endpoint);
        WORMHOLE_RELAYER = IWormholeRelayer(_wormholeRelayer);
        addressThis = address(this).toString();
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ----------------------------------------------------- EXTERNAL FUNCTIONS -------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Handles the receipt of ALX tokens sent via the LayerZero bridge.
     * @dev Mints ALX tokens for the recipient after a successful cross-chain transfer.
     * @param _srcChainId The source chain's identifier in the LayerZero network.
     * @param _srcAddress Encoded source address from which the tokens were sent.
     * @param _payload Encoded data comprising sender's and recipient's addresses and token amount.
     */
    function lzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64,
        bytes memory _payload
    ) external override {
        if (address(ENDPOINT) != msg.sender) {
            revert NotVerifiedCaller();
        }
        if (address(this) != address(uint160(bytes20(_srcAddress)))) {
            revert InvalidLayerZeroSourceAddress();
        }
        (address _from, address _to, uint256 _amount) = abi.decode(
            _payload,
            (address, address, uint256)
        );
        _mint(_to, _amount);
        emit BridgeReceive(
            _to,
            _amount,
            BridgeId.LayerZero,
            abi.encode(_srcChainId),
            _from
        );
        if (block.chainid == 1) {
            totalBridgedAmount -= _amount;
        }
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Handles incoming token transfers via the Wormhole bridge.
     * @dev Extracts transfer details from payload, mints tokens to the recipient, and updates state.
     * @param _payload Encoded information including recipient's address and token amount.
     * @param _sourceAddress The originating address from the source chain.
     * @param _srcChainId Identifier of the source chain.
     * @param _deliveryHash Unique hash for replay protection and verification.
     */
    function receiveWormholeMessages(
        bytes memory _payload,
        bytes[] memory,
        bytes32 _sourceAddress,
        uint16 _srcChainId,
        bytes32 _deliveryHash
    )
        external
        payable
        override
        replayProtect(_deliveryHash)
    {
        if (msg.sender != address(WORMHOLE_RELAYER)) {
            revert OnlyRelayerAllowed();
        }
        if (address(this) != address(uint160(uint256(_sourceAddress)))) {
            revert InvalidWormholeSourceAddress();
        }
        (address _from, address _to, uint256 _amount) = abi.decode(
            _payload,
            (address, address, uint256)
        );
        _mint(_to, _amount);
        emit BridgeReceive(
            _to,
            _amount,
            BridgeId.Wormhole,
            abi.encode(_srcChainId),
            _from
        );
        if (block.chainid == 1) {
            totalBridgedAmount -= _amount;
        }
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------ PUBLIC FUNCTIONS --------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Bridges tokens to a specified chain using the LayerZero protocol.
     * @dev Burns tokens from sender, constructs payload, and initiates bridge operation.
     * @param _dstChainId The ID of the destination chain within the LayerZero network.
     * @param _from The address initiating the token bridge on the source chain.
     * @param _to The address on the destination chain to receive the tokens.
     * @param _amount The number of tokens to bridge.
     * @param _feeRefundAddress The address to receive refunds for any excess fee paid.
     * @param _zroPaymentAddress Address holding ZRO tokens to cover fees, if applicable.
     * @param _adapterParams Parameters for the LayerZero adapter.
     */
    function bridgeViaLayerZero(
        uint16 _dstChainId,
        address _from,
        address _to,
        uint256 _amount,
        address payable _feeRefundAddress,
        address _zroPaymentAddress,
        bytes calldata _adapterParams
    )
        public
        payable
        override
    {
        if (_zroPaymentAddress == address(0)) {
            if (msg.value < estimateGasForLayerZero(
                    _dstChainId,
                    _from,
                    _to,
                    _amount,
                    false,
                    _adapterParams
                    )
                )
            {
                revert InsufficientFee();
            }
        }
        else {
            if (msg.value < estimateGasForLayerZero(
                    _dstChainId,
                    _from,
                    _to,
                    _amount,
                    true,
                    _adapterParams
                    )
                )
            {
                revert InsufficientFee();
            }
        }
        if (msg.sender != _from)
            _spendAllowance(
                _from,
                msg.sender,
                _amount
            );
        _burn(_from, _amount);
        if (_to == address(0)) {
            revert InvalidToAddress();
        }
        ENDPOINT.send{value: msg.value} (
            _dstChainId,
            abi.encodePacked(address(this),address(this)),
            abi.encode(
                _from,
                _to,
                _amount
            ),
            _feeRefundAddress,
            _zroPaymentAddress,
            _adapterParams
        );
        emit BridgeTransfer(
            _from,
            _amount,
            BridgeId.LayerZero,
            abi.encode(_dstChainId),
            _to
        );
        if (block.chainid == 1) {
            totalBridgedAmount += _amount;
        }
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Bridges tokens to a specified chain using the Axelar network.
     * @dev Encodes transaction details, invokes Axelar gateway, and burns bridged tokens.
     * @param _destinationChain The identifier of the destination chain within the Axelar network.
     * @param _from The address sending the tokens on the source chain.
     * @param _to The intended recipient address on the destination chain.
     * @param _amount The number of tokens to be bridged.
     * @param _feeRefundAddress The address to which any excess ETH should be refunded.
     */
    function bridgeViaAxelar(
        string calldata _destinationChain,
        address _from,
        address _to,
        uint256 _amount,
        address payable _feeRefundAddress
    )
        public
        payable
        override
    {
        bytes memory payload = abi.encode(_from, _to, _amount);
        string memory _ALXAddress = addressThis;
        if (msg.value != 0) {
            GAS_SERVICE.payNativeGasForContractCall{value: msg.value} (
                address(this),
                _destinationChain,
                _ALXAddress,
                payload,
                _feeRefundAddress
            );
        }
        if (_from != msg.sender)
            _spendAllowance(
                _from,
                msg.sender,
                _amount
            );
        _burn(_from, _amount);
        if (_to == address(0)) {
            revert InvalidToAddress();
        }
        gateway.callContract(
            _destinationChain,
            _ALXAddress,
            payload
        );
        emit BridgeTransfer(
            _from,
            _amount,
            BridgeId.Axelar,
            abi.encode(_destinationChain),
            _to
        );
        if (block.chainid == 1) {
            totalBridgedAmount += _amount;
        }
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Bridges tokens to a specified chain using the Wormhole network.
     * @dev Estimates gas fee, burns tokens from sender, and initiates bridge process via Wormhole relayer.
     * @param _targetChain The identifier of the destination chain within the Wormhole network.
     * @param _from The address initiating the token bridge on the source chain.
     * @param _to The intended recipient address on the target chain.
     * @param _amount The quantity of tokens to be bridged.
     * @param _feeRefundAddress The address to which any excess fees should be refunded.
     * @param _gasLimit The gas limit for processing the transaction on the destination chain.
     */
    function bridgeViaWormhole(
        uint16 _targetChain,
        address _from,
        address _to,
        uint256 _amount,
        address payable _feeRefundAddress,
        uint256 _gasLimit
    )
        public
        payable
        override
    {
        uint256 cost = estimateGasForWormhole(_targetChain, _gasLimit);
        if (msg.value < cost) {
            revert InsufficientFeeForWormhole();
        }
        if (msg.sender != _from)
            _spendAllowance(
                _from,
                msg.sender,
                _amount
            );
        _burn(_from, _amount);
        if (_to == address(0)) {
            revert InvalidToAddress();
        }
        WORMHOLE_RELAYER.sendPayloadToEvm{value: msg.value} (
            _targetChain,
            address(this),
            abi.encode(_from, _to, _amount),
            0,
            _gasLimit,
            _targetChain,
            _feeRefundAddress
        );
        emit BridgeTransfer(
            _from,
            _amount,
            BridgeId.Wormhole,
            abi.encode(_targetChain),
            _to
        );
        if (block.chainid == 1) {
            totalBridgedAmount += _amount;
        }
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Estimates the bridging fee on LayerZero for token transfer.
     * @dev Invokes the `estimateFees` function from LayerZero's endpoint contract.
     * @param _dstChainId The destination chain ID on LayerZero.
     * @param _from The address sending tokens on the source chain.
     * @param _to The address receiving tokens on the destination chain.
     * @param _amount The amount of tokens being bridged.
     * @param _payInZRO Indicates if the fee will be paid in ZRO token.
     * @param _adapterParam Adapter-specific parameters that may affect fee calculation.
     * @return nativeFee_ The estimated fee for the bridging operation in the native chain token.
     */
    function estimateGasForLayerZero(
        uint16 _dstChainId,
        address _from,
        address _to,
        uint256 _amount,
        bool _payInZRO,
        bytes calldata _adapterParam
    )
        public
        override
        view
        returns (uint256 nativeFee_)
    {
        (nativeFee_, ) = ENDPOINT.estimateFees(
            _dstChainId,
            address(this),
            abi.encode(_from, _to, _amount),
            _payInZRO,
            _adapterParam
        );
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Estimates the bridging fee using the Wormhole network for a specific transaction.
     * @dev Calls the `quoteEVMDeliveryPrice` function on the Wormhole relayer contract.
     * @param _targetChain The ID of the target chain within the Wormhole network.
     * @param _gasLimit The gas limit specified for the transaction on the destination chain.
     * @return cost_ The estimated cost for using Wormhole to bridge the transaction.
     */
    function estimateGasForWormhole(uint16 _targetChain, uint256 _gasLimit)
        public
        override
        view
        returns (uint256 cost_)
    {
        (cost_, ) = WORMHOLE_RELAYER.quoteEVMDeliveryPrice(
            _targetChain,
            0,
            _gasLimit
        );
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------ INTERNAL FUNCTION -------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Processes the minting of tokens based on a cross-chain transaction.
     * @dev Decodes the payload, validates the source address, and mints tokens to the recipient.
     * @param _sourceChain Identifies the blockchain from which the cross-chain request originated.
     * @param _sourceAddress The address on the source chain that initiated the mint request.
     * @param _payload Encoded data containing the details of the mint operation.
     */
    function _execute(
        string calldata _sourceChain,
        string calldata _sourceAddress,
        bytes calldata _payload
    ) internal override {
        if (_sourceAddress.toAddress() != address(this)) {
            revert InvalidSourceAddress();
        }
        (address _from, address _to, uint256 _amount) = abi.decode(
            _payload,
            (address, address, uint256)
        );
        _mint(_to, _amount);
        emit BridgeReceive(
            _to,
            _amount,
            BridgeId.Axelar,
            abi.encode(_sourceChain),
            _from
        );
        if (block.chainid == 1) {
            totalBridgedAmount -= _amount;
        }
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
}
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IBurnableToken} from "./IBurnableToken.sol";
import {IBridgeToken} from "./IBridgeToken.sol";

/// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| \\\

/*
 * @title IALX Interface
 *
 * @notice Interface for the ALX token, incorporating ERC20, burnable, and bridgeable functionalities.
 *
 * Co-Founders:
 * - Simran Dhillon: simran@xenify.io
 * - Hardev Dhillon: hardev@xenify.io
 * - Dayana Plaz: dayana@xenify.io
 *
 * Official Links:
 * - Twitter: https://twitter.com/alixa_io
 * - Telegram: https://t.me/alixa_io
 * - Website: https://alixa.io
 *
 * Disclaimer:
 * This interface aligns with the principles of the Fair Crypto Foundation, promoting self-custody, transparency, consensus-based
 * trust, and permissionless value exchange. There are no administrative access keys, underscoring our commitment to decentralisation.
 * Engaging with this interface involves technical and legal risks. Users must conduct their own due diligence and ensure compliance
 * with local laws and regulations. The software is provided "AS-IS," without warranties, and the co-founders and developers disclaim
 * all liability for any vulnerabilities, exploits, errors, or breaches that may occur. By using this interface, users accept all associated
 * risks and this disclaimer. The co-founders, developers, or related parties will not bear liability for any consequences of non-compliance.
 *
 * Redistribution and Use:
 * Redistribution, modification, or repurposing of this interface, in whole or in part, is strictly prohibited without express written
 * approval from all co-founders. Approval requests must be sent to the official email addresses of the co-founders, ensuring responses
 * are received directly from these addresses. Proposals for redistribution, modification, or repurposing must include a detailed explanation
 * of the intended changes or uses and the reasons behind them. The co-founders reserve the right to request additional information or
 * clarification as necessary. Approval is at the sole discretion of the co-founders and may be subject to conditions to uphold the
 * project’s integrity and the values of the Fair Crypto Foundation. Failure to obtain express written approval prior to any redistribution,
 * modification, or repurposing will result in a breach of these terms and immediate legal action.
 *
 * Copyright and License:
 * Copyright © 2024 Alixa (Simran Dhillon, Hardev Dhillon, Dayana Plaz). All rights reserved.
 * This software is provided 'as is' and may be used by the recipient. No permission is granted for redistribution,
 * modification, or repurposing of this interface. Any use beyond the scope defined herein may be subject to legal action.
 */
interface IALX is
    IBurnableToken,
    IBridgeToken,
    IERC20
{

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------------ ERRORS ------------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Thrown when attempting to mint tokens to the zero address.
     * @dev Prevents minting to invalid addresses, maintaining token integrity.
     */
    error ZeroAddress();

    /**
     * @notice Thrown when an unauthorised caller attempts a restricted function.
     * @dev Ensures only approved entities can perform sensitive operations.
     */
    error InvalidCaller();

    /**
     * @notice Thrown when attempting to set the Core address more than once.
     * @dev Maintains protocol integrity by allowing Core address to be set only once.
     */
    error CoreAlreadySet();

    /**
     * @notice Thrown when a minting operation would exceed the maximum supply.
     * @dev Enforces the predefined maximum supply limit for ALX tokens.
     */
    error ExceedsMaxSupply();

    /**
     * @notice Thrown when the maximum supply cap has been reached.
     * @dev Prevents further minting once the maximum token supply is achieved.
     */
    error MaxSupplyExceeded();

    /**
     * @notice Thrown when an invalid claim proof is provided for an airdrop.
     * @dev Ensures the validity of Merkle proofs in airdrop claims.
     */
    error InvalidClaimProof();

    /**
     * @notice Thrown when an unsupported interface is accessed.
     * @dev Restricts interactions to only supported interfaces.
     */
    error UnsupportedInterface();

    /**
     * @notice Thrown when a user attempts to claim an airdrop more than once.
     * @dev Prevents multiple airdrop claims by the same user.
     */
    error AirdropAlreadyClaimed();

    /**
     * @notice Thrown when attempting to claim an airdrop outside the active period.
     * @dev Enforces the time constraints for airdrop claims.
     */
    error AirdropPeriodNotActive();

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------------ EVENT -------------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Emitted when a user successfully claims their airdrop.
     * @param _user Address of the user claiming the airdrop.
     * @param _amount Amount of tokens claimed in the airdrop.
     */
    event Airdropped(address indexed _user, uint256 _amount);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ----------------------------------------------------- EXTERNAL FUNCTIONS -------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Sets the ALX-vXNF POL address.
     * @dev Can only be set once for protocol security.
     * @param _ALXPOL The address of the ALX-vXNF POL contract.
     */
    function setPool(address _ALXPOL) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Burns ALX tokens from a specified user's account.
     * @dev Reduces total supply by destroying tokens from the user's balance.
     * @param _user The address from which tokens will be burned.
     * @param _amount The amount of tokens to burn.
     */
    function burn(address _user, uint256 _amount) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Mints ALX tokens to a specified account.
     * @dev Allows authorised entities to create new ALX tokens.
     * @param _account The address to which new tokens will be minted.
     * @param _amount The amount of tokens to mint.
     */
    function mint(address _account, uint256 _amount) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Claims airdropped tokens using a Merkle proof.
     * @dev Verifies claim eligibility and mints tokens to the claimant.
     * @param _proof Array of bytes32 values representing the Merkle proof.
     * @param _airdroppedAmount Total amount of tokens airdropped to the user.
     * @param _amountToClaim Amount of tokens being claimed in this transaction.
     */
    function claim(
        bytes32[] calldata _proof,
        uint256 _airdroppedAmount,
        uint256 _amountToClaim
    ) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Purchases bonds using airdropped ALX tokens.
     * @dev Verifies airdrop eligibility before processing bond purchase.
     * @param _proof Merkle proof for airdrop verification.
     * @param _user Address of the bond purchaser.
     * @param _bondPower Power (tier) of the bond being purchased.
     * @param _bondCount Number of bonds to purchase.
     * @param _daysCount Duration of the bond in days.
     * @param _airdroppedAmount Total airdropped tokens available to the user.
     */
    function purchaseBondWithAirdroppedALX(
        bytes32[] calldata _proof,
        address _user,
        uint256 _bondPower,
        uint256 _bondCount,
        uint256 _daysCount,
        uint256 _airdroppedAmount
    ) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Stakes airdropped ALX tokens.
     * @dev Verifies airdrop eligibility before processing the stake.
     * @param _proof Merkle proof for airdrop verification.
     * @param _user Address of the user staking tokens.
     * @param _duration Staking duration.
     * @param _amountToStake Amount of tokens to stake.
     * @param _airdroppedAmount Total airdropped tokens available to the user.
     */
    function stakeWithAirdroppedALX(
        bytes32[] calldata _proof,
        address _user,
        uint256 _duration,
        uint256 _amountToStake,
        uint256 _airdroppedAmount
    ) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
}
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.25;

/*
 * @title IBridge Interface
 *
 * @notice Interface defining the functions and events for token bridging operations.
 *
 * Co-Founders:
 * - Simran Dhillon: simran@xenify.io
 * - Hardev Dhillon: hardev@xenify.io
 * - Dayana Plaz: dayana@xenify.io
 *
 * Official Links:
 * - Twitter: https://twitter.com/alixa_io
 * - Telegram: https://t.me/alixa_io
 * - Website: https://alixa.io
 *
 * Disclaimer:
 * This interface aligns with the principles of the Fair Crypto Foundation, promoting self-custody, transparency, consensus-based
 * trust, and permissionless value exchange. There are no administrative access keys, underscoring our commitment to decentralisation.
 * Engaging with this interface involves technical and legal risks. Users must conduct their own due diligence and ensure compliance
 * with local laws and regulations. The software is provided "AS-IS," without warranties, and the co-founders and developers disclaim
 * all liability for any vulnerabilities, exploits, errors, or breaches that may occur. By using this interface, users accept all associated
 * risks and this disclaimer. The co-founders, developers, or related parties will not bear liability for any consequences of non-compliance.
 *
 * Redistribution and Use:
 * Redistribution, modification, or repurposing of this interface, in whole or in part, is strictly prohibited without express written
 * approval from all co-founders. Approval requests must be sent to the official email addresses of the co-founders, ensuring responses
 * are received directly from these addresses. Proposals for redistribution, modification, or repurposing must include a detailed explanation
 * of the intended changes or uses and the reasons behind them. The co-founders reserve the right to request additional information or
 * clarification as necessary. Approval is at the sole discretion of the co-founders and may be subject to conditions to uphold the
 * project’s integrity and the values of the Fair Crypto Foundation. Failure to obtain express written approval prior to any redistribution,
 * modification, or repurposing will result in a breach of these terms and immediate legal action.
 *
 * Copyright and License:
 * Copyright © 2024 Alixa (Simran Dhillon, Hardev Dhillon, Dayana Plaz). All rights reserved.
 * This software is provided 'as is' and may be used by the recipient. No permission is granted for redistribution,
 * modification, or repurposing of this interface. Any use beyond the scope defined herein may be subject to legal action.
 */
interface IBridgeToken {

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------------- ENUM -------------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Enumerates the types of bridges supported.
     * @dev Defines different bridge protocols for cross-chain operations.
     */
    enum BridgeId {
        LayerZero,
        Wormhole,
        Axelar
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------------ EVENTS ------------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Emitted when tokens are received through a bridge.
     * @param to Recipient address on the destination chain.
     * @param amount Amount of tokens received.
     * @param bridgeId Identifier of the bridge protocol used.
     * @param fromChainId Identifier of the source chain.
     * @param from Sender address on the source chain.
     */
    event BridgeReceive(
        address indexed to,
        uint256 amount,
        BridgeId bridgeId,
        bytes fromChainId,
        address indexed from
    );

   /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Emitted when tokens are sent to another chain via a bridge.
     * @param from Sender address on the source chain.
     * @param amount Amount of tokens transferred.
     * @param bridgeId Bridge protocol used for the transfer.
     * @param toChainId Destination chain identifier.
     * @param to Recipient address on the destination chain.
     */
    event BridgeTransfer(
        address indexed from,
        uint256 amount,
        BridgeId bridgeId,
        bytes toChainId,
        address indexed to
    );

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------------ ERRORS ------------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Error for when the provided fee is insufficient.
     * @dev Ensures adequate fees for bridging to prevent transaction failures.
     */
    error InsufficientFee();

    /**
     * @notice Error for when the recipient address is invalid.
     * @dev Validates recipient address to prevent sending to invalid addresses.
     */
    error InvalidToAddress();

    /**
     * @notice Error for when a non-verified caller attempts an operation.
     * @dev Prevents unauthorised access to bridge functions.
     */
    error NotVerifiedCaller();

    /**
     * @notice Error indicating that the operation is restricted to the relayer.
     * @dev Ensures only the designated relayer can perform certain operations.
     */
    error OnlyRelayerAllowed();

    /**
     * @notice Error for when the source address is invalid.
     * @dev Validates source address to prevent security risks or incorrect attributions.
     */
    error InvalidSourceAddress();

    /**
     * @notice Error for when the fee for Wormhole bridging is insufficient.
     * @dev Ensures adequate fees specifically for Wormhole bridging.
     */
    error InsufficientFeeForWormhole();

    /**
     * @notice Error for when the Wormhole source address is invalid.
     * @dev Validates source address in Wormhole bridging for transfer integrity.
     */
    error InvalidWormholeSourceAddress();

    /**
     * @notice Error for when the LayerZero source address is invalid.
     * @dev Validates source address in LayerZero bridging for secure transfers.
     */
    error InvalidLayerZeroSourceAddress();

    /**
     * @notice Error for when a Wormhole message is replayed.
     * @dev Prevents replay attacks in Wormhole bridging operations.
     */
    error WormholeMessageAlreadyProcessed();

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ----------------------------------------------------- EXTERNAL FUNCTIONS -------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Receives tokens via LayerZero.
     * @dev Handles incoming LayerZero bridging operations.
     * @param _srcChainId Source chain ID on LayerZero network.
     * @param _srcAddress Source address of the ALX token sender.
     * @param _payload Encoded data with recipient address and amount.
     */
    function lzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64,
        bytes memory _payload
    ) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Receives tokens via Wormhole.
     * @dev Handles incoming Wormhole bridging operations.
     * @param _payload Encoded data with user address and amount.
     * @param _sourceAddress Caller's address on source chain in bytes32.
     * @param _srcChainId Source chain ID.
     * @param _deliveryHash Hash for verifying relay calls.
     */
    function receiveWormholeMessages(
        bytes memory _payload,
        bytes[] memory,
        bytes32 _sourceAddress,
        uint16 _srcChainId,
        bytes32 _deliveryHash
    ) external payable;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Bridges tokens to another chain via LayerZero.
     * @dev Facilitates LayerZero token transfer, handling locking and messaging.
     * @param _dstChainId Target chain ID on LayerZero.
     * @param _from Sender's address on source chain.
     * @param _to Recipient's address on destination chain.
     * @param _amount Amount of tokens to bridge.
     * @param _feeRefundAddress Address for excess fee refunds.
     * @param _zroPaymentAddress ZRO token holder address for fees.
     * @param _adapterParams Additional parameters for custom functionalities.
     */
    function bridgeViaLayerZero(
        uint16 _dstChainId,
        address _from,
        address _to,
        uint256 _amount,
        address payable _feeRefundAddress,
        address _zroPaymentAddress,
        bytes calldata _adapterParams
    ) external payable;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Bridges tokens to another chain via Axelar.
     * @dev Facilitates Axelar token transfer, handling locking and messaging.
     * @param _destinationChain Target chain ID on Axelar.
     * @param _from Sender's address on source chain.
     * @param _to Recipient's address on destination chain.
     * @param _amount Amount of tokens to bridge.
     * @param _feeRefundAddress Address for excess fee refunds.
     */
    function bridgeViaAxelar(
        string calldata _destinationChain,
        address _from,
        address _to,
        uint256 _amount,
        address payable _feeRefundAddress
    ) external payable;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Bridges tokens to another chain via Wormhole.
     * @dev Facilitates Wormhole token transfer, handling locking and messaging.
     * @param _targetChain Target chain ID on Wormhole.
     * @param _from Sender's address on source chain.
     * @param _to Recipient's address on destination chain.
     * @param _amount Amount of tokens to bridge.
     * @param _feeRefundAddress Address for excess fee refunds.
     * @param _gasLimit Gas limit for the transaction on destination chain.
     */
    function bridgeViaWormhole(
        uint16 _targetChain,
        address _from,
        address _to,
        uint256 _amount,
        address payable _feeRefundAddress,
        uint256 _gasLimit
    ) external payable;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Estimates the gas required for LayerZero bridging.
     * @dev Provides gas fee estimate for LayerZero bridging.
     * @param _dstChainId Destination chain ID on LayerZero.
     * @param _from Sender's address on source chain.
     * @param _to Recipient's address on destination chain.
     * @param _amount Amount of tokens to bridge.
     * @param _payInZRO True if fee is paid in ZRO tokens, false for native tokens.
     * @param _adapterParam Parameters for adapter services.
     * @return nativeFee_ Estimated fee in native tokens of destination chain.
     */
    function estimateGasForLayerZero(
        uint16 _dstChainId,
        address _from,
        address _to,
        uint256 _amount,
        bool _payInZRO,
        bytes calldata _adapterParam
    )
        external
        view
        returns (uint256 nativeFee_);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Estimates the gas required for Wormhole bridging.
     * @dev Provides gas fee estimate for Wormhole bridging.
     * @param _targetChain Destination chain ID on Wormhole.
     * @param _gasLimit Gas limit for the transaction on destination chain.
     * @return cost_ Estimated fee in native tokens of source chain.
     */
    function estimateGasForWormhole(uint16 _targetChain, uint256 _gasLimit)
        external
        view
        returns (uint256 cost_);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
}
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.25;

/*
 * @title IBurnRedeemable Interface
 *
 * @notice Interface for tokens with redeemable features upon burning.
 *
 * Co-Founders:
 * - Simran Dhillon: simran@xenify.io
 * - Hardev Dhillon: hardev@xenify.io
 * - Dayana Plaz: dayana@xenify.io
 *
 * Official Links:
 * - Twitter: https://twitter.com/alixa_io
 * - Telegram: https://t.me/alixa_io
 * - Website: https://alixa.io
 *
 * Disclaimer:
 * This interface aligns with the principles of the Fair Crypto Foundation, promoting self-custody, transparency, consensus-based
 * trust, and permissionless value exchange. There are no administrative access keys, underscoring our commitment to decentralisation.
 * Engaging with this interface involves technical and legal risks. Users must conduct their own due diligence and ensure compliance
 * with local laws and regulations. The software is provided "AS-IS," without warranties, and the co-founders and developers disclaim
 * all liability for any vulnerabilities, exploits, errors, or breaches that may occur. By using this interface, users accept all associated
 * risks and this disclaimer. The co-founders, developers, or related parties will not bear liability for any consequences of non-compliance.
 *
 * Redistribution and Use:
 * Redistribution, modification, or repurposing of this interface, in whole or in part, is strictly prohibited without express written
 * approval from all co-founders. Approval requests must be sent to the official email addresses of the co-founders, ensuring responses
 * are received directly from these addresses. Proposals for redistribution, modification, or repurposing must include a detailed explanation
 * of the intended changes or uses and the reasons behind them. The co-founders reserve the right to request additional information or
 * clarification as necessary. Approval is at the sole discretion of the co-founders and may be subject to conditions to uphold the
 * project’s integrity and the values of the Fair Crypto Foundation. Failure to obtain express written approval prior to any redistribution,
 * modification, or repurposing will result in a breach of these terms and immediate legal action.
 *
 * Copyright and License:
 * Copyright © 2024 Alixa (Simran Dhillon, Hardev Dhillon, Dayana Plaz). All rights reserved.
 * This software is provided 'as is' and may be used by the recipient. No permission is granted for redistribution,
 * modification, or repurposing of this interface. Any use beyond the scope defined herein may be subject to legal action.
 */
interface IBurnRedeemable {

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------ EXTERNAL FUNCTION -------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Callback triggered when a user burns tokens.
     * @dev Executes post-burn logic. Implement with reentrancy protection.
     * @param _user Address of the user burning tokens.
     * @param _amount Amount of tokens being burned.
     */
    function onTokenBurned(address _user, uint256 _amount) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
}
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.25;

/*
 * @title IBurnableToken Interface
 *
 * @notice Defines the functionality for tokens that can be burned, reducing the total supply irreversibly.
 *
 * Co-Founders:
 * - Simran Dhillon: simran@xenify.io
 * - Hardev Dhillon: hardev@xenify.io
 * - Dayana Plaz: dayana@xenify.io
 *
 * Official Links:
 * - Twitter: https://twitter.com/alixa_io
 * - Telegram: https://t.me/alixa_io
 * - Website: https://alixa.io
 *
 * Disclaimer:
 * This interface aligns with the principles of the Fair Crypto Foundation, promoting self-custody, transparency, consensus-based
 * trust, and permissionless value exchange. There are no administrative access keys, underscoring our commitment to decentralisation.
 * Engaging with this interface involves technical and legal risks. Users must conduct their own due diligence and ensure compliance
 * with local laws and regulations. The software is provided "AS-IS," without warranties, and the co-founders and developers disclaim
 * all liability for any vulnerabilities, exploits, errors, or breaches that may occur. By using this interface, users accept all associated
 * risks and this disclaimer. The co-founders, developers, or related parties will not bear liability for any consequences of non-compliance.
 *
 * Redistribution and Use:
 * Redistribution, modification, or repurposing of this interface, in whole or in part, is strictly prohibited without express written
 * approval from all co-founders. Approval requests must be sent to the official email addresses of the co-founders, ensuring responses
 * are received directly from these addresses. Proposals for redistribution, modification, or repurposing must include a detailed explanation
 * of the intended changes or uses and the reasons behind them. The co-founders reserve the right to request additional information or
 * clarification as necessary. Approval is at the sole discretion of the co-founders and may be subject to conditions to uphold the
 * project’s integrity and the values of the Fair Crypto Foundation. Failure to obtain express written approval prior to any redistribution,
 * modification, or repurposing will result in a breach of these terms and immediate legal action.
 *
 * Copyright and License:
 * Copyright © 2024 Alixa (Simran Dhillon, Hardev Dhillon, Dayana Plaz). All rights reserved.
 * This software is provided 'as is' and may be used by the recipient. No permission is granted for redistribution,
 * modification, or repurposing of this interface. Any use beyond the scope defined herein may be subject to legal action.
 */
interface IBurnableToken {

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------ EXTERNAL FUNCTION -------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Burns a specific amount of tokens from a user's account.
     * @dev Reduces total supply by destroying specified amount of tokens.
     * @param _user Address from which tokens will be burned.
     * @param _amount Number of tokens to be burned.
     */
    function burn(address _user, uint256 _amount) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
}
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.25;

/*
 * @title ICore Interface
 *
 * @notice Defines the core functionalities of the Alixa protocol, allowing interaction with bond and staking mechanisms.
 *
 * Co-Founders:
 * - Simran Dhillon: simran@xenify.io
 * - Hardev Dhillon: hardev@xenify.io
 * - Dayana Plaz: dayana@xenify.io
 *
 * Official Links:
 * - Twitter: https://twitter.com/alixa_io
 * - Telegram: https://t.me/alixa_io
 * - Website: https://alixa.io
 *
 * Disclaimer:
 * This interface aligns with the principles of the Fair Crypto Foundation, promoting self-custody, transparency, consensus-based
 * trust, and permissionless value exchange. There are no administrative access keys, underscoring our commitment to decentralisation.
 * Engaging with this interface involves technical and legal risks. Users must conduct their own due diligence and ensure compliance
 * with local laws and regulations. The software is provided "AS-IS," without warranties, and the co-founders and developers disclaim
 * all liability for any vulnerabilities, exploits, errors, or breaches that may occur. By using this interface, users accept all associated
 * risks and this disclaimer. The co-founders, developers, or related parties will not bear liability for any consequences of non-compliance.
 *
 * Redistribution and Use:
 * Redistribution, modification, or repurposing of this interface, in whole or in part, is strictly prohibited without express written
 * approval from all co-founders. Approval requests must be sent to the official email addresses of the co-founders, ensuring responses
 * are received directly from these addresses. Proposals for redistribution, modification, or repurposing must include a detailed explanation
 * of the intended changes or uses and the reasons behind them. The co-founders reserve the right to request additional information or
 * clarification as necessary. Approval is at the sole discretion of the co-founders and may be subject to conditions to uphold the
 * project’s integrity and the values of the Fair Crypto Foundation. Failure to obtain express written approval prior to any redistribution,
 * modification, or repurposing will result in a breach of these terms and immediate legal action.
 *
 * Copyright and License:
 * Copyright © 2024 Alixa (Simran Dhillon, Hardev Dhillon, Dayana Plaz). All rights reserved.
 * This software is provided 'as is' and may be used by the recipient. No permission is granted for redistribution,
 * modification, or repurposing of this interface. Any use beyond the scope defined herein may be subject to legal action.
 */
interface ICore {

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------------- ENUM -------------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Supported token types in the Alixa ecosystem.
     * @dev Defines eETH, ETHx, and ETH as valid token types.
     */
    enum Token {
        eeth,
        ethx,
        eth
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ----------------------------------------------------- EXTERNAL FUNCTIONS -------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Updates the current cycle.
     * @dev Calculates and updates the cycle based on protocol parameters.
     * @return Current cycle number.
     */
    function calculateCycle() external returns (uint256);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Initiates ALX token unbonding process.
     * @dev Starts unbonding for specified bond ID.
     * @param _bondID Bond identifier.
     * @param _restake If true, restakes rewards.
     */
    function unbondingALX(uint256 _bondID, bool _restake) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Provides ALX tokens for liquidity.
     * @dev Adds specified ALX amount to liquidity pool.
     * @param ALXAmount Amount of ALX tokens to provide.
     */
    function provideAssetsForLiquidity(uint256 ALXAmount) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Reactivates an existing bond.
     * @dev Reactivates bond using specified ETHx amount.
     * @param _bondID Bond identifier.
     * @param _ETHxAmount Amount of ETHx for reactivation.
     */
    function reactivate(uint256 _bondID, uint256 _ETHxAmount) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Claims ETHx rewards for a bond.
     * @dev Processes ETHx reward claims for specified bond.
     * @param _bondID Bond identifier.
     * @param _restake If true, restakes rewards.
     */
    function claimETHxRewards(uint256 _bondID, bool _restake) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Checks liquidity provision trigger status.
     * @dev Returns current status of liquidity provision trigger.
     * @return True if triggered, false otherwise.
     */
    function isTriggered()
        external
        view
        returns (bool);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Retrieves base cost for transactions.
     * @dev Returns fixed base cost value.
     * @return Base cost value.
     */
    function BASE_COST()
        external
        pure
        returns (uint256);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Gets current cycle number.
     * @dev Returns cycle number without state modification.
     * @return Current cycle number.
     */
    function getCurrentCycle()
        external
        view
        returns (uint256);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Calculates required token amounts for bonds.
     * @dev Determines token amount based on bond parameters.
     * @param _bondPower Bond power level.
     * @param _bondCount Number of bonds.
     * @param _isETHBond True if ETH bond, false otherwise.
     * @return tokenRequired_ Required token amount.
     */
     function getTokenAmounts(
        uint256 _bondPower,
        uint256 _bondCount,
        bool _isETHBond
    )
        external
        view
        returns (uint256 tokenRequired_);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Retrieves pending ALX rewards for a bond.
     * @dev Calculates pending ALX rewards for specified bond.
     * @param _bondID Bond identifier.
     * @return reward_ Pending ALX reward amount.
     */
    function pendingALX(uint256 _bondID)
        external
        view
        returns (uint256 reward_);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Checks bond existence for a user.
     * @dev Verifies if specified bond exists for given user.
     * @param _user User address.
     * @param _bondID Bond identifier.
     * @return exists_ True if bond exists, false otherwise.
     */
    function isExist(address _user, uint256 _bondID)
        external
        view
        returns (bool exists_);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Transfers bond ownership.
     * @dev Processes bond transfer to new owner.
     * @param _bondIDs Array of bond IDs to transfer.
     * @param _recipient New owner's address.
     * @param _restake If true, restakes rewards.
     */
    function transferBond(
        uint256[] calldata _bondIDs,
        address _recipient,
        bool _restake
    ) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Allows bond sniping.
     * @dev Processes bond sniping between users.
     * @param _user Bond owner's address.
     * @param _bondIDUser ID of bond to snipe.
     * @param _bondIDSniper Sniper's bond ID.
     * @param _restake If true, restakes rewards.
     */
    function snipe(
        address _user,
        uint256 _bondIDUser,
        uint256 _bondIDSniper,
        bool _restake
    ) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Calculates pending ETHx rewards for a bond.
     * @dev Computes various components of ETHx rewards.
     * @param _user User address.
     * @param _bondID Bond identifier.
     * @return pendingAmount_ Base pending ETHx amount.
     * @return pendingBonus_ Pending bonus amount.
     * @return totalPending_ Total pending rewards.
     */
    function pendingETHx(address _user, uint256 _bondID)
        external
        view
        returns (
            uint256 pendingAmount_,
            uint256 pendingBonus_,
            uint256 totalPending_
        );

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Purchases bond with ALX tokens.
     * @dev Processes ALX bond purchase.
     * @param _user Purchaser's address.
     * @param _bondCount Number of bonds to purchase.
     * @param _daysCount Bond duration in days.
     * @param _bondPower Bond power level.
     */
    function purchaseALXBond(
        address _user,
        uint256 _bondCount,
        uint256 _daysCount,
        uint256 _bondPower
    ) external;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Purchases bond with airdropped ALX tokens.
     * @dev Processes bond purchase using airdropped ALX.
     * @param _user Purchaser's address.
     * @param _bondCount Number of bonds to purchase.
     * @param _daysCount Bond duration in days.
     * @param _bondPower Bond power level.
     * @param _requiredALXAmount Required ALX amount for purchase.
     */
    function purchaseBondWithAirdroppedALX(
        address _user,
        uint256 _bondCount,
        uint256 _daysCount,
        uint256 _bondPower,
        uint256 _requiredALXAmount
    ) external payable;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Purchases ETH bond.
     * @dev Processes ETH or ETH-based token bond purchase.
     * @param _user Purchaser's address.
     * @param _bondCount Number of bonds to purchase.
     * @param _token Token type used for purchase.
     * @param _daysCount Bond duration in days.
     * @param _bondPower Bond power level.
     */
    function purchaseETHBond(
        address _user,
        uint256 _bondCount,
        Token _token,
        uint256 _daysCount,
        uint256 _bondPower
    ) external payable;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
}
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.25;

/*
 * @title IWormholeRelayerBase Interface
 *
 * @notice Defines the base interface for the Wormhole Relayer, facilitating cross-chain communication and message relaying.
 *
 * Co-Founders:
 * - Simran Dhillon: simran@xenify.io
 * - Hardev Dhillon: hardev@xenify.io
 * - Dayana Plaz: dayana@xenify.io
 *
 * Official Links:
 * - Twitter: https://twitter.com/alixa_io
 * - Telegram: https://t.me/alixa_io
 * - Website: https://alixa.io
 *
 * Disclaimer:
 * This interface aligns with the principles of the Fair Crypto Foundation, promoting self-custody, transparency, consensus-based
 * trust, and permissionless value exchange. There are no administrative access keys, underscoring our commitment to decentralisation.
 * Engaging with this interface involves technical and legal risks. Users must conduct their own due diligence and ensure compliance
 * with local laws and regulations. The software is provided "AS-IS," without warranties, and the co-founders and developers disclaim
 * all liability for any vulnerabilities, exploits, errors, or breaches that may occur. By using this interface, users accept all associated
 * risks and this disclaimer. The co-founders, developers, or related parties will not bear liability for any consequences of non-compliance.
 *
 * Redistribution and Use:
 * Redistribution, modification, or repurposing of this interface, in whole or in part, is strictly prohibited without express written
 * approval from all co-founders. Approval requests must be sent to the official email addresses of the co-founders, ensuring responses
 * are received directly from these addresses. Proposals for redistribution, modification, or repurposing must include a detailed explanation
 * of the intended changes or uses and the reasons behind them. The co-founders reserve the right to request additional information or
 * clarification as necessary. Approval is at the sole discretion of the co-founders and may be subject to conditions to uphold the
 * project’s integrity and the values of the Fair Crypto Foundation. Failure to obtain express written approval prior to any redistribution,
 * modification, or repurposing will result in a breach of these terms and immediate legal action.
 *
 * Copyright and License:
 * Copyright © 2024 Alixa (Simran Dhillon, Hardev Dhillon, Dayana Plaz). All rights reserved.
 * This software is provided 'as is' and may be used by the recipient. No permission is granted for redistribution,
 * modification, or repurposing of this interface. Any use beyond the scope defined herein may be subject to legal action.
 */

/// --------------------------------------------------------------------------------------------------------------------------------- \\\
/// ---------------------------------------------------------- STRUCTURE ------------------------------------------------------------ \\\
/// --------------------------------------------------------------------------------------------------------------------------------- \\\

/**
 * @notice VaaKey identifies a wormhole message.
 * @custom:member chainId Wormhole chain ID of the chain where this VAA was emitted from.
 * @custom:member emitterAddress Address of the emitter of the VAA, in Wormhole bytes32 format.
 * @custom:member sequence Sequence number of the VAA.
 */
struct VaaKey {
    uint16 chainId;
    bytes32 emitterAddress;
    uint64 sequence;
}

/// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| \\\

/**
 * @title IWormholeRelayerBase
 * @notice Interface for basic Wormhole Relayer operations.
 */
interface IWormholeRelayerBase {

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------------ EVENT -------------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Emitted when a Send operation is executed.
     * @param sequence The sequence of the send event.
     * @param deliveryQuote The delivery quote for the send operation.
     * @param paymentForExtraReceiverValue The payment value for the additional receiver.
     */
    event SendEvent(
        uint64 indexed sequence,
        uint256 deliveryQuote,
        uint256 paymentForExtraReceiverValue
    );

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------ EXTERNAL FUNCTION -------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Fetches the registered Wormhole Relayer contract for a given chain ID.
     * @param chainId The chain ID to fetch the relayer contract for.
     * @return The address of the registered Wormhole Relayer contract for the given chain ID.
     */
    function getRegisteredWormholeRelayerContract(uint16 chainId)
        external
        view
        returns (bytes32);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
}

/// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| \\\

/**
 * @title IWormholeRelayerSend
 * @notice The interface to request deliveries.
 */
interface IWormholeRelayerSend is IWormholeRelayerBase {

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ----------------------------------------------------- EXTERNAL FUNCTIONS -------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Publishes an instruction for the default delivery provider
     * to relay a payload to the address `targetAddress` on chain `targetChain`
     * with gas limit `gasLimit` and `msg.value` equal to `receiverValue`
     *
     * `targetAddress` must implement the IWormholeReceiver interface.
     *
     * This function must be called with `msg.value` equal to `quoteEVMDeliveryPrice(targetChain, receiverValue, gasLimit)`.
     *
     * Any refunds (from leftover gas) will be paid to the delivery provider. In order to receive the refunds, use the `sendPayloadToEvm` function
     * with `refundChain` and `refundAddress` as parameters.
     *
     * @param targetChain in Wormhole Chain ID format.
     * @param targetAddress address to call on targetChain (that implements IWormholeReceiver).
     * @param payload arbitrary bytes to pass in as parameter in call to `targetAddress`.
     * @param receiverValue msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units).
     * @param gasLimit gas limit with which to call `targetAddress`.
     * @return sequence sequence number of published VAA containing delivery instructions.
     */
    function sendPayloadToEvm(
        uint16 targetChain,
        address targetAddress,
        bytes memory payload,
        uint256 receiverValue,
        uint256 gasLimit
    )
        external
        payable
        returns (uint64 sequence);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Publishes an instruction for the default delivery provider.
     * to relay a payload to the address `targetAddress` on chain `targetChain`
     * with gas limit `gasLimit` and `msg.value` equal to `receiverValue`.
     *
     * Any refunds (from leftover gas) will be sent to `refundAddress` on chain `refundChain`
     * `targetAddress` must implement the IWormholeReceiver interface.
     *
     * This function must be called with `msg.value` equal to `quoteEVMDeliveryPrice(targetChain, receiverValue, gasLimit)`.
     *
     * @param targetChain in Wormhole Chain ID format.
     * @param targetAddress address to call on targetChain (that implements IWormholeReceiver).
     * @param payload arbitrary bytes to pass in as parameter in call to `targetAddress`.
     * @param receiverValue msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units).
     * @param gasLimit gas limit with which to call `targetAddress`. Any units of gas unused will be refunded according to the
     *        `targetChainRefundPerGasUnused` rate quoted by the delivery provider.
     * @param refundChain The chain to deliver any refund to, in Wormhole Chain ID format.
     * @param refundAddress The address on `refundChain` to deliver any refund to.
     * @return sequence sequence number of published VAA containing delivery instructions.
     */
    function sendPayloadToEvm(
        uint16 targetChain,
        address targetAddress,
        bytes memory payload,
        uint256 receiverValue,
        uint256 gasLimit,
        uint16 refundChain,
        address refundAddress
    )
        external
        payable
        returns (uint64 sequence);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Publishes an instruction for the default delivery provider
     * to relay a payload and VAAs specified by `vaaKeys` to the address `targetAddress` on chain `targetChain`
     * with gas limit `gasLimit` and `msg.value` equal to `receiverValue`
     *
     * `targetAddress` must implement the IWormholeReceiver interface
     *
     * This function must be called with `msg.value` equal to `quoteEVMDeliveryPrice(targetChain, receiverValue, gasLimit)`
     *
     * Any refunds (from leftover gas) will be paid to the delivery provider. In order to receive the refunds, use the `sendVaasToEvm` function
     * with `refundChain` and `refundAddress` as parameters
     *
     * @param targetChain in Wormhole Chain ID format
     * @param targetAddress address to call on targetChain (that implements IWormholeReceiver)
     * @param payload arbitrary bytes to pass in as parameter in call to `targetAddress`
     * @param receiverValue msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units)
     * @param gasLimit gas limit with which to call `targetAddress`.
     * @param vaaKeys Additional VAAs to pass in as parameter in call to `targetAddress`
     * @return sequence sequence number of published VAA containing delivery instructions
     */
    function sendVaasToEvm(
        uint16 targetChain,
        address targetAddress,
        bytes memory payload,
        uint256 receiverValue,
        uint256 gasLimit,
        VaaKey[] memory vaaKeys
    )
        external
        payable
        returns (uint64 sequence);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Publishes an instruction for the default delivery provider
     * to relay a payload and VAAs specified by `vaaKeys` to the address `targetAddress` on chain `targetChain`
     * with gas limit `gasLimit` and `msg.value` equal to `receiverValue`
     *
     * Any refunds (from leftover gas) will be sent to `refundAddress` on chain `refundChain`
     * `targetAddress` must implement the IWormholeReceiver interface
     *
     * This function must be called with `msg.value` equal to `quoteEVMDeliveryPrice(targetChain, receiverValue, gasLimit)`
     *
     * @param targetChain in Wormhole Chain ID format
     * @param targetAddress address to call on targetChain (that implements IWormholeReceiver)
     * @param payload arbitrary bytes to pass in as parameter in call to `targetAddress`
     * @param receiverValue msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units)
     * @param gasLimit gas limit with which to call `targetAddress`. Any units of gas unused will be refunded according to the
     *        `targetChainRefundPerGasUnused` rate quoted by the delivery provider
     * @param vaaKeys Additional VAAs to pass in as parameter in call to `targetAddress`
     * @param refundChain The chain to deliver any refund to, in Wormhole Chain ID format
     * @param refundAddress The address on `refundChain` to deliver any refund to
     * @return sequence sequence number of published VAA containing delivery instructions
     */
    function sendVaasToEvm(
        uint16 targetChain,
        address targetAddress,
        bytes memory payload,
        uint256 receiverValue,
        uint256 gasLimit,
        VaaKey[] memory vaaKeys,
        uint16 refundChain,
        address refundAddress
    )
        external
        payable
        returns (uint64 sequence);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Publishes an instruction for the delivery provider at `deliveryProviderAddress`
     * to relay a payload and VAAs specified by `vaaKeys` to the address `targetAddress` on chain `targetChain`
     * with gas limit `gasLimit` and `msg.value` equal to
     * receiverValue + (arbitrary amount that is paid for by paymentForExtraReceiverValue of this chain's wei) in targetChain wei.
     *
     * Any refunds (from leftover gas) will be sent to `refundAddress` on chain `refundChain`
     * `targetAddress` must implement the IWormholeReceiver interface
     *
     * This function must be called with `msg.value` equal to
     * quoteEVMDeliveryPrice(targetChain, receiverValue, gasLimit, deliveryProviderAddress) + paymentForExtraReceiverValue
     *
     * @param targetChain in Wormhole Chain ID format
     * @param targetAddress address to call on targetChain (that implements IWormholeReceiver)
     * @param payload arbitrary bytes to pass in as parameter in call to `targetAddress`
     * @param receiverValue msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units)
     * @param paymentForExtraReceiverValue amount (in current chain currency units) to spend on extra receiverValue
     *        (in addition to the `receiverValue` specified)
     * @param gasLimit gas limit with which to call `targetAddress`. Any units of gas unused will be refunded according to the
     *        `targetChainRefundPerGasUnused` rate quoted by the delivery provider
     * @param refundChain The chain to deliver any refund to, in Wormhole Chain ID format
     * @param refundAddress The address on `refundChain` to deliver any refund to
     * @param deliveryProviderAddress The address of the desired delivery provider's implementation of IDeliveryProvider
     * @param vaaKeys Additional VAAs to pass in as parameter in call to `targetAddress`
     * @param consistencyLevel Consistency level with which to publish the delivery instructions - see
     *        https://book.wormhole.com/wormhole/3_coreLayerContracts.html?highlight=consistency#consistency-levels
     * @return sequence sequence number of published VAA containing delivery instructions
     */
    function sendToEvm(
        uint16 targetChain,
        address targetAddress,
        bytes memory payload,
        uint256 receiverValue,
        uint256 paymentForExtraReceiverValue,
        uint256 gasLimit,
        uint16 refundChain,
        address refundAddress,
        address deliveryProviderAddress,
        VaaKey[] memory vaaKeys,
        uint8 consistencyLevel
    )
        external
        payable
        returns (uint64 sequence);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Publishes an instruction for the delivery provider at `deliveryProviderAddress`
     * to relay a payload and VAAs specified by `vaaKeys` to the address `targetAddress` on chain `targetChain`
     * with `msg.value` equal to
     * receiverValue + (arbitrary amount that is paid for by paymentForExtraReceiverValue of this chain's wei) in targetChain wei.
     *
     * Any refunds (from leftover gas) will be sent to `refundAddress` on chain `refundChain`
     * `targetAddress` must implement the IWormholeReceiver interface
     *
     * This function must be called with `msg.value` equal to
     * quoteDeliveryPrice(targetChain, receiverValue, encodedExecutionParameters, deliveryProviderAddress) + paymentForExtraReceiverValue
     *
     * @param targetChain in Wormhole Chain ID format
     * @param targetAddress address to call on targetChain (that implements IWormholeReceiver), in Wormhole bytes32 format
     * @param payload arbitrary bytes to pass in as parameter in call to `targetAddress`
     * @param receiverValue msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units)
     * @param paymentForExtraReceiverValue amount (in current chain currency units) to spend on extra receiverValue
     *        (in addition to the `receiverValue` specified)
     * @param encodedExecutionParameters encoded information on how to execute delivery that may impact pricing
     *        e.g. for version EVM_V1, this is a struct that encodes the `gasLimit` with which to call `targetAddress`
     * @param refundChain The chain to deliver any refund to, in Wormhole Chain ID format
     * @param refundAddress The address on `refundChain` to deliver any refund to, in Wormhole bytes32 format
     * @param deliveryProviderAddress The address of the desired delivery provider's implementation of IDeliveryProvider
     * @param vaaKeys Additional VAAs to pass in as parameter in call to `targetAddress`
     * @param consistencyLevel Consistency level with which to publish the delivery instructions - see
     *        https://book.wormhole.com/wormhole/3_coreLayerContracts.html?highlight=consistency#consistency-levels
     * @return sequence sequence number of published VAA containing delivery instructions
     */
    function send(
        uint16 targetChain,
        bytes32 targetAddress,
        bytes memory payload,
        uint256 receiverValue,
        uint256 paymentForExtraReceiverValue,
        bytes memory encodedExecutionParameters,
        uint16 refundChain,
        bytes32 refundAddress,
        address deliveryProviderAddress,
        VaaKey[] memory vaaKeys,
        uint8 consistencyLevel
    )
        external
        payable
        returns (uint64 sequence);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Performs the same function as a `send`, except:
     * 1)  Can only be used during a delivery (i.e. in execution of `receiveWormholeMessages`)
     * 2)  Is paid for (along with any other calls to forward) by (any msg.value passed in) + (refund leftover from current delivery)
     * 3)  Only executes after `receiveWormholeMessages` is completed (and thus does not return a sequence number)
     *
     * The refund from the delivery currently in progress will not be sent to the user; it will instead
     * be paid to the delivery provider to perform the instruction specified here
     *
     * Publishes an instruction for the same delivery provider (or default, if the same one doesn't support the new target chain)
     * to relay a payload to the address `targetAddress` on chain `targetChain`
     * with gas limit `gasLimit` and with `msg.value` equal to `receiverValue`
     *
     * The following equation must be satisfied (sum_f indicates summing over all forwards requested in `receiveWormholeMessages`):
     * (refund amount from current execution of receiveWormholeMessages) + sum_f [msg.value_f]
     * >= sum_f [quoteEVMDeliveryPrice(targetChain_f, receiverValue_f, gasLimit_f)]
     *
     * The difference between the two sides of the above inequality will be added to `paymentForExtraReceiverValue` of the first forward requested
     *
     * Any refunds (from leftover gas) from this forward will be paid to the same refundChain and refundAddress specified for the current delivery.
     *
     * @param targetChain in Wormhole Chain ID format
     * @param targetAddress address to call on targetChain (that implements IWormholeReceiver), in Wormhole bytes32 format
     * @param payload arbitrary bytes to pass in as parameter in call to `targetAddress`
     * @param receiverValue msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units)
     * @param gasLimit gas limit with which to call `targetAddress`.
     */
    function forwardPayloadToEvm(
        uint16 targetChain,
        address targetAddress,
        bytes memory payload,
        uint256 receiverValue,
        uint256 gasLimit
    ) external payable;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Performs the same function as a `send`, except:
     * 1)  Can only be used during a delivery (i.e. in execution of `receiveWormholeMessages`)
     * 2)  Is paid for (along with any other calls to forward) by (any msg.value passed in) + (refund leftover from current delivery)
     * 3)  Only executes after `receiveWormholeMessages` is completed (and thus does not return a sequence number)
     *
     * The refund from the delivery currently in progress will not be sent to the user; it will instead
     * be paid to the delivery provider to perform the instruction specified here
     *
     * Publishes an instruction for the same delivery provider (or default, if the same one doesn't support the new target chain)
     * to relay a payload and VAAs specified by `vaaKeys` to the address `targetAddress` on chain `targetChain`
     * with gas limit `gasLimit` and with `msg.value` equal to `receiverValue`
     *
     * The following equation must be satisfied (sum_f indicates summing over all forwards requested in `receiveWormholeMessages`):
     * (refund amount from current execution of receiveWormholeMessages) + sum_f [msg.value_f]
     * >= sum_f [quoteEVMDeliveryPrice(targetChain_f, receiverValue_f, gasLimit_f)]
     *
     * The difference between the two sides of the above inequality will be added to `paymentForExtraReceiverValue` of the first forward requested
     *
     * Any refunds (from leftover gas) from this forward will be paid to the same refundChain and refundAddress specified for the current delivery.
     *
     * @param targetChain in Wormhole Chain ID format
     * @param targetAddress address to call on targetChain (that implements IWormholeReceiver), in Wormhole bytes32 format
     * @param payload arbitrary bytes to pass in as parameter in call to `targetAddress`
     * @param receiverValue msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units)
     * @param gasLimit gas limit with which to call `targetAddress`.
     * @param vaaKeys Additional VAAs to pass in as parameter in call to `targetAddress`
     */
    function forwardVaasToEvm(
        uint16 targetChain,
        address targetAddress,
        bytes memory payload,
        uint256 receiverValue,
        uint256 gasLimit,
        VaaKey[] memory vaaKeys
    ) external payable;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Performs the same function as a `send`, except:
     * 1)  Can only be used during a delivery (i.e. in execution of `receiveWormholeMessages`)
     * 2)  Is paid for (along with any other calls to forward) by (any msg.value passed in) + (refund leftover from current delivery)
     * 3)  Only executes after `receiveWormholeMessages` is completed (and thus does not return a sequence number)
     *
     * The refund from the delivery currently in progress will not be sent to the user; it will instead
     * be paid to the delivery provider to perform the instruction specified here
     *
     * Publishes an instruction for the delivery provider at `deliveryProviderAddress`
     * to relay a payload and VAAs specified by `vaaKeys` to the address `targetAddress` on chain `targetChain`
     * with gas limit `gasLimit` and with `msg.value` equal to
     * receiverValue + (arbitrary amount that is paid for by paymentForExtraReceiverValue of this chain's wei) in targetChain wei.
     *
     * Any refunds (from leftover gas) will be sent to `refundAddress` on chain `refundChain`
     * `targetAddress` must implement the IWormholeReceiver interface
     *
     * The following equation must be satisfied (sum_f indicates summing over all forwards requested in `receiveWormholeMessages`):
     * (refund amount from current execution of receiveWormholeMessages) + sum_f [msg.value_f]
     * >= sum_f [quoteEVMDeliveryPrice(targetChain_f, receiverValue_f, gasLimit_f, deliveryProviderAddress_f) + paymentForExtraReceiverValue_f]
     *
     * The difference between the two sides of the above inequality will be added to `paymentForExtraReceiverValue` of the first forward requested
     *
     * @param targetChain in Wormhole Chain ID format
     * @param targetAddress address to call on targetChain (that implements IWormholeReceiver), in Wormhole bytes32 format
     * @param payload arbitrary bytes to pass in as parameter in call to `targetAddress`
     * @param receiverValue msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units)
     * @param paymentForExtraReceiverValue amount (in current chain currency units) to spend on extra receiverValue
     *        (in addition to the `receiverValue` specified)
     * @param gasLimit gas limit with which to call `targetAddress`. Any units of gas unused will be refunded according to the
     *        `targetChainRefundPerGasUnused` rate quoted by the delivery provider
     * @param refundChain The chain to deliver any refund to, in Wormhole Chain ID format
     * @param refundAddress The address on `refundChain` to deliver any refund to, in Wormhole bytes32 format
     * @param deliveryProviderAddress The address of the desired delivery provider's implementation of IDeliveryProvider
     * @param vaaKeys Additional VAAs to pass in as parameter in call to `targetAddress`
     * @param consistencyLevel Consistency level with which to publish the delivery instructions - see
     *        https://book.wormhole.com/wormhole/3_coreLayerContracts.html?highlight=consistency#consistency-levels
     */
    function forwardToEvm(
        uint16 targetChain,
        address targetAddress,
        bytes memory payload,
        uint256 receiverValue,
        uint256 paymentForExtraReceiverValue,
        uint256 gasLimit,
        uint16 refundChain,
        address refundAddress,
        address deliveryProviderAddress,
        VaaKey[] memory vaaKeys,
        uint8 consistencyLevel
    ) external payable;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Performs the same function as a `send`, except:
     * 1)  Can only be used during a delivery (i.e. in execution of `receiveWormholeMessages`)
     * 2)  Is paid for (along with any other calls to forward) by (any msg.value passed in) + (refund leftover from current delivery)
     * 3)  Only executes after `receiveWormholeMessages` is completed (and thus does not return a sequence number)
     *
     * The refund from the delivery currently in progress will not be sent to the user; it will instead
     * be paid to the delivery provider to perform the instruction specified here
     *
     * Publishes an instruction for the delivery provider at `deliveryProviderAddress`
     * to relay a payload and VAAs specified by `vaaKeys` to the address `targetAddress` on chain `targetChain`
     * with `msg.value` equal to
     * receiverValue + (arbitrary amount that is paid for by paymentForExtraReceiverValue of this chain's wei) in targetChain wei.
     *
     * Any refunds (from leftover gas) will be sent to `refundAddress` on chain `refundChain`
     * `targetAddress` must implement the IWormholeReceiver interface
     *
     * The following equation must be satisfied (sum_f indicates summing over all forwards requested in `receiveWormholeMessages`):
     * (refund amount from current execution of receiveWormholeMessages) + sum_f [msg.value_f]
     * >= sum_f [quoteDeliveryPrice(targetChain_f, receiverValue_f, encodedExecutionParameters_f, deliveryProviderAddress_f) + paymentForExtraReceiverValue_f]
     *
     * The difference between the two sides of the above inequality will be added to `paymentForExtraReceiverValue` of the first forward requested
     *
     * @param targetChain in Wormhole Chain ID format
     * @param targetAddress address to call on targetChain (that implements IWormholeReceiver), in Wormhole bytes32 format
     * @param payload arbitrary bytes to pass in as parameter in call to `targetAddress`
     * @param receiverValue msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units)
     * @param paymentForExtraReceiverValue amount (in current chain currency units) to spend on extra receiverValue
     *        (in addition to the `receiverValue` specified)
     * @param encodedExecutionParameters encoded information on how to execute delivery that may impact pricing
     *        e.g. for version EVM_V1, this is a struct that encodes the `gasLimit` with which to call `targetAddress`
     * @param refundChain The chain to deliver any refund to, in Wormhole Chain ID format
     * @param refundAddress The address on `refundChain` to deliver any refund to, in Wormhole bytes32 format
     * @param deliveryProviderAddress The address of the desired delivery provider's implementation of IDeliveryProvider
     * @param vaaKeys Additional VAAs to pass in as parameter in call to `targetAddress`
     * @param consistencyLevel Consistency level with which to publish the delivery instructions - see
     *        https://book.wormhole.com/wormhole/3_coreLayerContracts.html?highlight=consistency#consistency-levels
     */
    function forward(
        uint16 targetChain,
        bytes32 targetAddress,
        bytes memory payload,
        uint256 receiverValue,
        uint256 paymentForExtraReceiverValue,
        bytes memory encodedExecutionParameters,
        uint16 refundChain,
        bytes32 refundAddress,
        address deliveryProviderAddress,
        VaaKey[] memory vaaKeys,
        uint8 consistencyLevel
    ) external payable;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Requests a previously published delivery instruction to be redelivered
     * (e.g. with a different delivery provider)
     *
     * This function must be called with `msg.value` equal to
     * quoteEVMDeliveryPrice(targetChain, newReceiverValue, newGasLimit, newDeliveryProviderAddress)
     *
     *  @notice *** This will only be able to succeed if the following is true **
     *         - newGasLimit >= gas limit of the old instruction
     *         - newReceiverValue >= receiver value of the old instruction
     *         - newDeliveryProvider's `targetChainRefundPerGasUnused` >= old relay provider's `targetChainRefundPerGasUnused`
     *
     * @param deliveryVaaKey VaaKey identifying the wormhole message containing the
     *        previously published delivery instructions
     * @param targetChain The target chain that the original delivery targeted. Must match targetChain from original delivery instructions
     * @param newReceiverValue new msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units)
     * @param newGasLimit gas limit with which to call `targetAddress`. Any units of gas unused will be refunded according to the
     *        `targetChainRefundPerGasUnused` rate quoted by the delivery provider, to the refund chain and address specified in the original request
     * @param newDeliveryProviderAddress The address of the desired delivery provider's implementation of IDeliveryProvider
     * @return sequence sequence number of published VAA containing redelivery instructions
     *
     * @notice *** This will only be able to succeed if the following is true **
     *         - newGasLimit >= gas limit of the old instruction
     *         - newReceiverValue >= receiver value of the old instruction
     *         - newDeliveryProvider's `targetChainRefundPerGasUnused` >= old relay provider's `targetChainRefundPerGasUnused`
     */
    function resendToEvm(
        VaaKey memory deliveryVaaKey,
        uint16 targetChain,
        uint256 newReceiverValue,
        uint256 newGasLimit,
        address newDeliveryProviderAddress
    )
        external
        payable
        returns (uint64 sequence);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Requests a previously published delivery instruction to be redelivered
     *
     *
     * This function must be called with `msg.value` equal to
     * quoteDeliveryPrice(targetChain, newReceiverValue, newEncodedExecutionParameters, newDeliveryProviderAddress)
     *
     * @param deliveryVaaKey VaaKey identifying the wormhole message containing the
     *        previously published delivery instructions
     * @param targetChain The target chain that the original delivery targeted. Must match targetChain from original delivery instructions
     * @param newReceiverValue new msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units)
     * @param newEncodedExecutionParameters new encoded information on how to execute delivery that may impact pricing
     *        e.g. for version EVM_V1, this is a struct that encodes the `gasLimit` with which to call `targetAddress`
     * @param newDeliveryProviderAddress The address of the desired delivery provider's implementation of IDeliveryProvider
     * @return sequence sequence number of published VAA containing redelivery instructions
     *
     *  @notice *** This will only be able to succeed if the following is true **
     *         - (For EVM_V1) newGasLimit >= gas limit of the old instruction
     *         - newReceiverValue >= receiver value of the old instruction
     *         - (For EVM_V1) newDeliveryProvider's `targetChainRefundPerGasUnused` >= old relay provider's `targetChainRefundPerGasUnused`
     */
    function resend(
        VaaKey memory deliveryVaaKey,
        uint16 targetChain,
        uint256 newReceiverValue,
        bytes memory newEncodedExecutionParameters,
        address newDeliveryProviderAddress
    )
        external
        payable
        returns (uint64 sequence);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Returns the price to request a relay to chain `targetChain`, using the default delivery provider
     *
     * @param targetChain in Wormhole Chain ID format
     * @param receiverValue msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units)
     * @param gasLimit gas limit with which to call `targetAddress`.
     * @return nativePriceQuote Price, in units of current chain currency, that the delivery provider charges to perform the relay
     * @return targetChainRefundPerGasUnused amount of target chain currency that will be refunded per unit of gas unused,
     *         if a refundAddress is specified
     */
    function quoteEVMDeliveryPrice(
        uint16 targetChain,
        uint256 receiverValue,
        uint256 gasLimit
    )
        external
        view
        returns (uint256 nativePriceQuote, uint256 targetChainRefundPerGasUnused);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Returns the price to request a relay to chain `targetChain`, using delivery provider `deliveryProviderAddress`
     *
     * @param targetChain in Wormhole Chain ID format
     * @param receiverValue msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units)
     * @param gasLimit gas limit with which to call `targetAddress`.
     * @param deliveryProviderAddress The address of the desired delivery provider's implementation of IDeliveryProvider
     * @return nativePriceQuote Price, in units of current chain currency, that the delivery provider charges to perform the relay
     * @return targetChainRefundPerGasUnused amount of target chain currency that will be refunded per unit of gas unused,
     *         if a refundAddress is specified
     */
    function quoteEVMDeliveryPrice(
        uint16 targetChain,
        uint256 receiverValue,
        uint256 gasLimit,
        address deliveryProviderAddress
    )
        external
        view
        returns (uint256 nativePriceQuote, uint256 targetChainRefundPerGasUnused);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Returns the price to request a relay to chain `targetChain`, using delivery provider `deliveryProviderAddress`
     *
     * @param targetChain in Wormhole Chain ID format
     * @param receiverValue msg.value that delivery provider should pass in for call to `targetAddress` (in targetChain currency units)
     * @param encodedExecutionParameters encoded information on how to execute delivery that may impact pricing
     *        e.g. for version EVM_V1, this is a struct that encodes the `gasLimit` with which to call `targetAddress`
     * @param deliveryProviderAddress The address of the desired delivery provider's implementation of IDeliveryProvider
     * @return nativePriceQuote Price, in units of current chain currency, that the delivery provider charges to perform the relay
     * @return encodedExecutionInfo encoded information on how the delivery will be executed
     *        e.g. for version EVM_V1, this is a struct that encodes the `gasLimit` and `targetChainRefundPerGasUnused`
     *             (which is the amount of target chain currency that will be refunded per unit of gas unused,
     *              if a refundAddress is specified)
     */
    function quoteDeliveryPrice(
        uint16 targetChain,
        uint256 receiverValue,
        bytes memory encodedExecutionParameters,
        address deliveryProviderAddress
    )
        external
        view
        returns (uint256 nativePriceQuote, bytes memory encodedExecutionInfo);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Returns the (extra) amount of target chain currency that `targetAddress`
     * will be called with, if the `paymentForExtraReceiverValue` field is set to `currentChainAmount`
     *
     * @param targetChain in Wormhole Chain ID format
     * @param currentChainAmount The value that `paymentForExtraReceiverValue` will be set to
     * @param deliveryProviderAddress The address of the desired delivery provider's implementation of IDeliveryProvider
     * @return targetChainAmount The amount such that if `targetAddress` will be called with `msg.value` equal to
     *         receiverValue + targetChainAmount
     */
    function quoteNativeForChain(
        uint16 targetChain,
        uint256 currentChainAmount,
        address deliveryProviderAddress
    )
        external
        view
        returns (uint256 targetChainAmount);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Returns the address of the current default delivery provider
     * @return deliveryProvider The address of (the default delivery provider)'s contract on this source
     *   chain. This must be a contract that implements IDeliveryProvider.
     */
    function getDefaultDeliveryProvider()
        external
        view
        returns (address deliveryProvider);
}

/// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| \\\

/**
 * @title IWormholeRelayerDelivery
 * @notice The interface to execute deliveries. Only relevant for Delivery Providers
 */
interface IWormholeRelayerDelivery is IWormholeRelayerBase {

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------------- ENUM -------------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Represents the possible statuses of a delivery.
     */
    enum DeliveryStatus {
        SUCCESS,
        RECEIVER_FAILURE,
        FORWARD_REQUEST_FAILURE,
        FORWARD_REQUEST_SUCCESS
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice Represents the possible statuses of a refund after a delivery attempt.
     */
    enum RefundStatus {
        REFUND_SENT,
        REFUND_FAIL,
        CROSS_CHAIN_REFUND_SENT,
        CROSS_CHAIN_REFUND_FAIL_PROVIDER_NOT_SUPPORTED,
        CROSS_CHAIN_REFUND_FAIL_NOT_ENOUGH
    }

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------------- EVENT ------------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @custom:member recipientContract - The target contract address
     * @custom:member sourceChain - The chain which this delivery was requested from (in wormhole
     *     ChainID format)
     * @custom:member sequence - The wormhole sequence number of the delivery VAA on the source chain
     *     corresponding to this delivery request
     * @custom:member deliveryVaaHash - The hash of the delivery VAA corresponding to this delivery
     *     request
     * @custom:member gasUsed - The amount of gas that was used to call your target contract
     * @custom:member status:
     *   - RECEIVER_FAILURE, if the target contract reverts
     *   - SUCCESS, if the target contract doesn't revert and no forwards were requested
     *   - FORWARD_REQUEST_FAILURE, if the target contract doesn't revert, forwards were requested,
     *       but provided/leftover funds were not sufficient to cover them all
     *   - FORWARD_REQUEST_SUCCESS, if the target contract doesn't revert and all forwards are covered
     * @custom:member additionalStatusInfo:
     *   - If status is SUCCESS or FORWARD_REQUEST_SUCCESS, then this is empty.
     *   - If status is RECEIVER_FAILURE, this is `RETURNDATA_TRUNCATION_THRESHOLD` bytes of the
     *       return data (i.e. potentially truncated revert reason information).
     *   - If status is FORWARD_REQUEST_FAILURE, this is also the revert data - the reason the forward failed.
     *     This will be either an encoded Cancelled, DeliveryProviderReverted, or DeliveryProviderPaymentFailed error
     * @custom:member refundStatus - Result of the refund. REFUND_SUCCESS or REFUND_FAIL are for
     *     refunds where targetChain=refundChain; the others are for targetChain!=refundChain,
     *     where a cross chain refund is necessary
     * @custom:member overridesInfo:
     *   - If not an override: empty bytes array
     *   - Otherwise: An encoded `DeliveryOverride`
     */
    event Delivery(
        address indexed recipientContract,
        uint16 indexed sourceChain,
        uint64 indexed sequence,
        bytes32 deliveryVaaHash,
        DeliveryStatus status,
        uint256 gasUsed,
        RefundStatus refundStatus,
        bytes additionalStatusInfo,
        bytes overridesInfo
    );

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\
    /// ------------------------------------------------------ EXTERNAL FUNCTION -------------------------------------------------------- \\\
    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * @notice The delivery provider calls `deliver` to relay messages as described by one delivery instruction
     *
     * The delivery provider must pass in the specified (by VaaKeys[]) signed wormhole messages (VAAs) from the source chain
     * as well as the signed wormhole message with the delivery instructions (the delivery VAA)
     *
     * The messages will be relayed to the target address (with the specified gas limit and receiver value) iff the following checks are met:
     * - the delivery VAA has a valid signature
     * - the delivery VAA's emitter is one of these WormholeRelayer contracts
     * - the delivery provider passed in at least enough of this chain's currency as msg.value (enough meaning the maximum possible refund)
     * - the instruction's target chain is this chain
     * - the relayed signed VAAs match the descriptions in container.messages (the VAA hashes match, or the emitter address, sequence number pair matches, depending on the description given)
     *
     * @param encodedVMs - An array of signed wormhole messages (all from the same source chain
     *     transaction)
     * @param encodedDeliveryVAA - Signed wormhole message from the source chain's WormholeRelayer
     *     contract with payload being the encoded delivery instruction container
     * @param relayerRefundAddress - The address to which any refunds to the delivery provider
     *     should be sent
     * @param deliveryOverrides - Optional overrides field which must be either an empty bytes array or
     *     an encoded DeliveryOverride struct
     */
    function deliver(
        bytes[] memory encodedVMs,
        bytes memory encodedDeliveryVAA,
        address payable relayerRefundAddress,
        bytes memory deliveryOverrides
    ) external payable;
}

/// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| \\\

/**
 * @title IWormholeRelayer
 * @notice Interface for the primary Wormhole Relayer which aggregates the functionalities of the Delivery and Send interfaces.
 */
interface IWormholeRelayer is
    IWormholeRelayerDelivery,
    IWormholeRelayerSend {}

    uint256 constant RETURNDATA_TRUNCATION_THRESHOLD = 132;

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * Errors related to conversion and validation of EVM addresses.
     */
    error NotAnEvmAddress(bytes32);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * Errors related to unauthorised access or usage.
     */
    error RequesterNotWormholeRelayer();

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * Errors for when there are issues with the overrides provided.
     */
    error InvalidOverrideGasLimit();
    error InvalidOverrideReceiverValue();
    error InvalidOverrideRefundPerGasUnused();

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * Errors related to the state and progress of the WormholeRelayer's operations.
     */
    error NoDeliveryInProgress();
    error ReentrantDelivery(address msgSender, address lockedBy);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * Errors related to funding and refunds.
     */
    error InsufficientRelayerFunds(uint256 msgValue, uint256 minimum);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * Errors related to the VAA (signed wormhole message) validation.
     */
    error VaaKeysDoNotMatchVaas(uint8 index);
    error VaaKeysLengthDoesNotMatchVaasLength(uint256 keys, uint256 vaas);
    error InvalidEmitter(bytes32 emitter, bytes32 registered, uint16 chainId);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * Errors related to payment values and delivery prices.
     */
    error RequestedGasLimitTooLow();
    error DeliveryProviderCannotReceivePayment();
    error InvalidMsgValue(uint256 msgValue, uint256 totalFee);
    error DeliveryProviderDoesNotSupportTargetChain(address relayer, uint16 chainId);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * Errors for when there are issues with forwarding or delivery.
     */
    error InvalidVaaKeyType(uint8 parsed);
    error InvalidDeliveryVaa(string reason);
    error InvalidPayloadId(uint8 parsed, uint8 expected);
    error InvalidPayloadLength(uint256 received, uint256 expected);
    error ForwardRequestFromWrongAddress(address msgSender, address deliveryTarget);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\

    /**
     * Errors related to relaying instructions and target chains.
     */
    error TargetChainIsNotThisChain(uint16 targetChain);
    error ForwardNotSufficientlyFunded(uint256 amountOfFunds, uint256 amountOfFundsNeeded);

    /// --------------------------------------------------------------------------------------------------------------------------------- \\\