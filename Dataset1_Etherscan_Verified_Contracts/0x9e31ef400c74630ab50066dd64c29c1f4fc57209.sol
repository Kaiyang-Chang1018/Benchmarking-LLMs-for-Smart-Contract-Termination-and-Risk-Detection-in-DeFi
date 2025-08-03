// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./lib/WasabiStructs.sol";
import "./WasabiOption.sol";

/**
 * @dev Required interface of an WasabiConduit compliant contract.
 */
interface IWasabiConduit {

    /// @notice ETH Transfer Failed
    error EthTransferFailed();

    /**
     * @dev Buys multiple options
     */
    function buyOptions(
        WasabiStructs.PoolAsk[] calldata _requests,
        WasabiStructs.Ask[] calldata _asks,
        bytes[] calldata _signatures
    ) external payable returns (uint256[] memory);

    /**
     * @dev Buys an option
     */
    function buyOption(
        WasabiStructs.PoolAsk calldata _request,
        bytes calldata _signature
    ) external payable returns (uint256);

    /**
     * @dev Transfers a NFT to _target
     *
     * @param _nft the address of NFT
     * @param _tokenId the tokenId to transfer
     * @param _target the target to transfer the NFT
     */
    function transferToken(
        address _nft,
        uint256 _tokenId,
        address _target
    ) external;

    /**
     * @dev Sets the BNPL contract
     */
    function setBNPL(address _bnplContract) external;

    /**
     * @dev Sets Option information
     */
    function setOption(WasabiOption _option) external;

    /**
     * @dev Sets maximum number of option to buy
     */
    function setMaxOptionsToBuy(uint256 _maxOptionsToBuy) external;

    /**
     * @dev Sets pool factory address
     */
    function setPoolFactoryAddress(address _factory) external;

    /**
     * @dev Accpets the Ask
     */
    function acceptAsk(
        WasabiStructs.Ask calldata _ask,
        bytes calldata _signature
    ) external payable returns (uint256);

    /**
     * @dev Accpets the Bid
     */
    function acceptBid(
        uint256 _optionId,
        address _poolAddress,
        WasabiStructs.Bid calldata _bid,
        bytes calldata _signature
    ) external payable;

    /**
     * @dev Pool Accepts the _bid
     */
    function poolAcceptBid(WasabiStructs.Bid calldata _bid, bytes calldata _signature, uint256 _optionId) external;

    /**
     * @dev Cancel the _ask
     */
    function cancelAsk(
        WasabiStructs.Ask calldata _ask,
        bytes calldata _signature
    ) external;

    /**
     * @dev Cancel the _bid
     */
    function cancelBid(
        WasabiStructs.Bid calldata _bid,
        bytes calldata _signature
    ) external;

    /// @dev Withdraws any stuck ETH in this contract
    function withdrawETH(uint256 _amount) external payable;

    /// @dev Withdraws any stuck ERC20 in this contract
    function withdrawERC20(IERC20 _token, uint256 _amount) external;

    /// @dev Withdraws any stuck ERC721 in this contract
    function withdrawERC721(IERC721 _token, uint256 _tokenId) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @dev Required interface for defining all the errors
 */

interface IWasabiErrors {

    /**
     * @dev Thrown when an order that has been filled or cancelled is being acted upon
     */
    error OrderFilledOrCancelled();

    /**
     * @dev Thrown when someone tries to make an unauthorized request
     */
    error Unauthorized();

    /**
     * @dev Thrown when a signature is invalid
     */
    error InvalidSignature();

    /**
     * @dev Thrown when there is no sufficient available liquidity left in the pool for issuing a PUT option
     */
    error InsufficientAvailableLiquidity();

    /**
     * @dev Thrown when the requested NFT for a CALL is already locked for another option
     */
    error RequestNftIsLocked();

    /**
     * @dev Thrown when the NFT is not in the pool or invalid
     */
    error NftIsInvalid();

    /**
     * @dev Thrown when the expiry of an ask is invalid for the pool
     */
    error InvalidExpiry();

    /**
     * @dev Thrown when the strike price of an ask is invalid for the pool
     */
    error InvalidStrike();

    /**
     * @dev Thrown when an expired order or option is being exercised
     */
    error HasExpired();
    
    /**
     * @dev Thrown when sending ETH failed
     */
    error FailedToSend();
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "./lib/WasabiStructs.sol";

/**
 * @dev Required interface of an WasabiPool compliant contract.
 */
interface IWasabiPool is IERC165, IERC721Receiver {
    
    /**
     * @dev Emitted when `admin` is changed.
     */
    event AdminChanged(address admin);

    /**
     * @dev Emitted when an order is cancelled.
     */
    event OrderCancelled(uint256 id);

    /**
     * @dev Emitted when a pool bid is taken
     */
    event PoolBidTaken(uint256 id);

    /**
     * @dev Emitted when an ERC721 is received
     */
    event ERC721Received(uint256 tokenId);

    /**
     * @dev Emitted when ETH is received
     */
    event ETHReceived(uint amount);

    /**
     * @dev Emitted when ERC20 is received
     */
    event ERC20Received(uint amount);

    /**
     * @dev Emitted when an ERC721 is withdrawn
     */
    event ERC721Withdrawn(uint256 tokenId);

    /**
     * @dev Emitted when ERC20 is withdrawn
     */
    event ERC20Withdrawn(uint amount);

    /**
     * @dev Emitted when ETH is withdrawn
     */
    event ETHWithdrawn(uint amount);

    /**
     * @dev Emitted when an option is executed.
     */
    event OptionExecuted(uint256 optionId);

    /**
     * @dev Emitted when an option is issued
     */
    event OptionIssued(uint256 optionId, uint256 price);

    /**
     * @dev Emitted when an option is issued
     */
    event OptionIssued(uint256 optionId, uint256 price, uint256 poolAskId);

    /**
     * @dev Emitted when the pool settings are edited
     */
    event PoolSettingsChanged();

    /**
     * @dev Returns the address of the nft
     */
    function getNftAddress() external view returns(address);

    /**
     * @dev Returns the address of the nft
     */
    function getLiquidityAddress() external view returns(address);

    /**
     * @dev Writes an option for the given ask.
     */
    function writeOption(
        WasabiStructs.PoolAsk calldata _request, bytes calldata _signature
    ) external payable returns (uint256);

    /**
     * @dev Writes an option for the given rule and buyer.
     */
    function writeOptionTo(
        WasabiStructs.PoolAsk calldata _request, bytes calldata _signature, address _receiver
    ) external payable returns (uint256);

    /**
     * @dev Executes the option for the given id.
     */
    function executeOption(uint256 _optionId) external payable;

    /**
     * @dev Executes the option for the given id.
     */
    function executeOptionWithSell(uint256 _optionId, uint256 _tokenId) external payable;

    /**
     * @dev Cancels the order for the given _orderId.
     */
    function cancelOrder(uint256 _orderId) external;

    /**
     * @dev Withdraws ERC721 tokens from the pool.
     */
    function withdrawERC721(IERC721 _nft, uint256[] calldata _tokenIds) external;

    /**
     * @dev Deposits ERC721 tokens to the pool.
     */
    function depositERC721(IERC721 _nft, uint256[] calldata _tokenIds) external;

    /**
     * @dev Withdraws ETH from this pool
     */
    function withdrawETH(uint256 _amount) external payable;

    /**
     * @dev Withdraws ERC20 tokens from this pool
     */
    function withdrawERC20(IERC20 _token, uint256 _amount) external;

    /**
     * @dev Sets the admin of this pool.
     */
    function setAdmin(address _admin) external;

    /**
     * @dev Removes the admin from this pool.
     */
    function removeAdmin() external;

    /**
     * @dev Returns the address of the current admin.
     */
    function getAdmin() external view returns (address);

    /**
     * @dev Returns the address of the factory managing this pool
     */
    function getFactory() external view returns (address);

    /**
     * @dev Returns the available balance this pool contains that can be withdrawn or collateralized
     */
    function availableBalance() view external returns(uint256);

    /**
     * @dev Returns an array of ids of all outstanding (issued or expired) options
     */
    function getOptionIds() external view returns(uint256[] memory);

    /**
     * @dev Returns the id of the option that locked the given token id, reverts if there is none
     */
    function getOptionIdForToken(uint256 _tokenId) external view returns(uint256);

    /**
     * @dev Returns the option data for the given option id
     */
    function getOptionData(uint256 _optionId) external view returns(WasabiStructs.OptionData memory);

    /**
     * @dev Returns 'true' if the option for the given id is valid and active, 'false' otherwise
     */
    function isValid(uint256 _optionId) view external returns(bool);

    /**
     * @dev Checks if _tokenId unlocked
     */
    function isAvailableTokenId(uint256 _tokenId) external view returns(bool);

    /**
     * @dev Clears the expired options from the pool
     */
    function clearExpiredOptions(uint256[] memory _optionIds) external;

    /**
     * @dev accepts the bid for LPs with _tokenId. If its a put option, _tokenId can be 0
     */
    function acceptBid(WasabiStructs.Bid calldata _bid, bytes calldata _signature, uint256 _tokenId) external returns(uint256);

    /**
     * @dev accepts the ask for LPs
     */
    function acceptAsk(WasabiStructs.Ask calldata _ask, bytes calldata _signature) external;

    /**
     * @dev accepts a bid created for this pool
     */
    function acceptPoolBid(WasabiStructs.PoolBid calldata _poolBid, bytes calldata _signature) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @dev Required interface of an WasabiPoolFactory compliant contract.
 */
interface IWasabiPoolFactory {

    /**
     * @dev The States of Pools
     */
    enum PoolState {
        INVALID,
        ACTIVE,
        DISABLED
    }

    /**
     * @dev Emitted when there is a new pool created
     */
    event NewPool(address poolAddress, address indexed nftAddress, address indexed owner);

    /**
     * @dev INVALID/ACTIVE/DISABLE the specified pool.
     */
    function togglePool(address _poolAddress, PoolState _poolState) external;

    /**
     * @dev Checks if the pool for the given address is enabled.
     */
    function isValidPool(address _poolAddress) external view returns(bool);

    /**
     * @dev Returns the PoolState
     */
    function getPoolState(address _poolAddress) external view returns(PoolState);

    /**
     * @dev Returns IWasabiConduit Contract Address.
     */
    function getConduitAddress() external view returns(address);

    /**
     * @dev Returns IWasabiFeeManager Contract Address.
     */
    function getFeeManager() external view returns(address);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./IWasabiPool.sol";
import "./IWasabiPoolFactory.sol";
import "./fees/IWasabiFeeManager.sol";

/**
 * @dev An ERC721 which tracks Wasabi Option positions of accounts
 */
contract WasabiOption is ERC721, IERC2981, Ownable {
    
    address private lastFactory;
    mapping(address => bool) private factoryAddresses;
    mapping(uint256 => address) private optionPools;
    uint256 private _currentId = 1;
    string private _baseURIextended;

    /**
     * @dev Constructs WasabiOption
     */
    constructor() ERC721("Wasabi Option NFTs", "WASAB") {}

    /**
     * @dev Toggles the owning factory
     */
    function toggleFactory(address _factory, bool _enabled) external onlyOwner {
        factoryAddresses[_factory] = _enabled;
        if (_enabled) {
            lastFactory = _factory;
        }
    }

    /**
     * @dev Mints a new WasabiOption
     */
    function mint(address _to, address _factory) external returns (uint256 mintedId) {
        require(factoryAddresses[_factory] == true, "Invalid Factory");
        require(IWasabiPoolFactory(_factory).isValidPool(_msgSender()), "Only valid pools can mint");

        _safeMint(_to, _currentId);
        mintedId = _currentId;
        optionPools[mintedId] = _msgSender();
        _currentId++;
    }

    /**
     * @dev Burns the specified option
     */
    function burn(uint256 _optionId) external {
        require(optionPools[_optionId] == _msgSender(), "Caller can't burn option");
        _burn(_optionId);
    }

    /**
     * @dev Sets the base URI
     */
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    /**
     * @dev Returns the address of the pool which created the given option
     */
    function getPool(uint256 _optionId) external view returns (address) {
        return optionPools[_optionId];
    }
    
    /// @inheritdoc ERC721
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    /// @inheritdoc IERC2981
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address, uint256) {
        IWasabiPool pool = IWasabiPool(optionPools[_tokenId]);
        IWasabiPoolFactory factory = IWasabiPoolFactory(pool.getFactory());
        IWasabiFeeManager feeManager = IWasabiFeeManager(factory.getFeeManager());
        return feeManager.getFeeDataForOption(_tokenId, _salePrice);
    }
    
    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, IERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "../lib/Signing.sol";

/**
 * @dev Signature Verification for Bid and Ask
 */
abstract contract ConduitSignatureVerifier {

    bytes32 constant EIP712DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 constant BID_TYPEHASH =
        keccak256(
            "Bid(uint256 id,uint256 price,address tokenAddress,address collection,uint256 orderExpiry,address buyer,uint8 optionType,uint256 strikePrice,uint256 expiry,uint256 expiryAllowance,address optionTokenAddress)"
        );

    bytes32 constant ASK_TYPEHASH =
        keccak256(
            "Ask(uint256 id,uint256 price,address tokenAddress,uint256 orderExpiry,address seller,uint256 optionId)"
        );

    /**
     * @dev Creates the hash of the EIP712 domain for this validator
     *
     * @param _eip712Domain the domain to hash
     * @return the hashed domain
     */
    function hashDomain(
        WasabiStructs.EIP712Domain memory _eip712Domain
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    EIP712DOMAIN_TYPEHASH,
                    keccak256(bytes(_eip712Domain.name)),
                    keccak256(bytes(_eip712Domain.version)),
                    _eip712Domain.chainId,
                    _eip712Domain.verifyingContract
                )
            );
    }

    /**
     * @dev Creates the hash of the Bid for this validator
     *
     * @param _bid to hash
     * @return the bid domain
     */
    function hashForBid(
        WasabiStructs.Bid memory _bid
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    BID_TYPEHASH,
                    _bid.id,
                    _bid.price,
                    _bid.tokenAddress,
                    _bid.collection,
                    _bid.orderExpiry,
                    _bid.buyer,
                    _bid.optionType,
                    _bid.strikePrice,
                    _bid.expiry,
                    _bid.expiryAllowance,
                    _bid.optionTokenAddress
                )
            );
    }

    /**
     * @dev Creates the hash of the Ask for this validator
     *
     * @param _ask the ask to hash
     * @return the ask domain
     */
    function hashForAsk(
        WasabiStructs.Ask memory _ask
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    ASK_TYPEHASH,
                    _ask.id,
                    _ask.price,
                    _ask.tokenAddress,
                    _ask.orderExpiry,
                    _ask.seller,
                    _ask.optionId
                )
            );
    }

    /**
     * @dev Gets the signer of the given signature for the given bid
     *
     * @param _bid the bid to validate
     * @param _signature the signature to validate
     * @return address who signed the signature
     */
    function getSignerForBid(
        WasabiStructs.Bid memory _bid,
        bytes memory _signature
    ) public view returns (address) {
        bytes32 domainSeparator = hashDomain(
            WasabiStructs.EIP712Domain({
                name: "ConduitSignature",
                version: "1",
                chainId: getChainID(),
                verifyingContract: address(this)
            })
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, hashForBid(_bid))
        );
        return Signing.recoverSigner(digest, _signature);
    }

    /**
     * @dev Gets the signer of the given signature for the given ask
     *
     * @param _ask the ask to validate
     * @param _signature the signature to validate
     * @return address who signed the signature
     */
    function getSignerForAsk(
        WasabiStructs.Ask memory _ask,
        bytes memory _signature
    ) public view returns (address) {
        bytes32 domainSeparator = hashDomain(
            WasabiStructs.EIP712Domain({
                name: "ConduitSignature",
                version: "1",
                chainId: getChainID(),
                verifyingContract: address(this)
            })
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, hashForAsk(_ask))
        );
        return Signing.recoverSigner(digest, _signature);
    }

    /**
     * @dev Checks the signer of the given signature for the given bid is the given signer
     *
     * @param _bid the bid to validate
     * @param _signature the signature to validate
     * @param _signer the signer to validate
     * @return true if the signature belongs to the signer, false otherwise
     */
    function verifyBid(
        WasabiStructs.Bid memory _bid,
        bytes memory _signature,
        address _signer
    ) internal view returns (bool) {
        return getSignerForBid(_bid, _signature) == _signer;
    }

    /**
     * @dev Checks the signer of the given signature for the given ask is the given signer
     *
     * @param _ask the ask to validate
     * @param _signature the signature to validate
     * @param _signer the signer to validate
     * @return true if the signature belongs to the signer, false otherwise
     */
    function verifyAsk(
        WasabiStructs.Ask memory _ask,
        bytes memory _signature,
        address _signer
    ) internal view returns (bool) {
        return getSignerForAsk(_ask, _signature) == _signer;
    }

    /**
     * @return the current chain id
     */
    function getChainID() internal view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../IWasabiPool.sol";
import "../IWasabiErrors.sol";
import "../IWasabiPoolFactory.sol";
import "../IWasabiConduit.sol";
import "../WasabiOption.sol";
import "./ConduitSignatureVerifier.sol";
import "../fees/IWasabiFeeManager.sol";
import "../lending/BNPLOptionBidValidator.sol";

/**
 * @dev A conduit that allows for trades of WasabiOptions
 */
contract WasabiConduit is
    Ownable,
    IERC721Receiver,
    ReentrancyGuard,
    ConduitSignatureVerifier,
    IWasabiConduit
{
    event AskTaken(
        uint256 optionId,
        uint256 orderId,
        address seller,
        address taker
    );
    event BidTaken(
        uint256 optionId,
        uint256 orderId,
        address buyer,
        address taker
    );

    event BidCancelled(uint256 orderId, address buyer);
    event AskCancelled(uint256 orderId, address seller);

    WasabiOption private option;
    uint256 public maxOptionsToBuy;
    address public bnplContract;
    mapping(bytes => bool) public idToFinalizedOrCancelled;
    address private factory;

    /**
     * @dev Initializes a new WasabiConduit
     */
    constructor(WasabiOption _option, address _bnplContract, address _factory) {
        option = _option;
        maxOptionsToBuy = 100;
        bnplContract = _bnplContract;
        factory = _factory;
    }

    /// @inheritdoc IWasabiConduit
    function buyOptions(
        WasabiStructs.PoolAsk[] calldata _requests,
        WasabiStructs.Ask[] calldata _asks,
        bytes[] calldata _signatures
    ) external payable returns (uint256[] memory) {
        uint256 size = _requests.length + _asks.length;
        require(size > 0, "Need to provide at least one request");
        require(size <= maxOptionsToBuy, "Cannot buy that many options");
        require(
            size == _signatures.length,
            "Need to provide the same amount of signatures and requests"
        );

        uint256[] memory optionIds = new uint[](size);
        for (uint256 index = 0; index < _requests.length; index++) {
            uint256 tokenId = buyOption(_requests[index], _signatures[index]);
            optionIds[index] = tokenId;
        }
        for (uint256 index = 0; index < _asks.length; index++) {
            uint256 sigIndex = index + _requests.length;
            uint256 tokenId = acceptAsk(
                _asks[index],
                _signatures[sigIndex]
            );
            optionIds[sigIndex] = tokenId;
        }
        return optionIds;
    }

    /// @inheritdoc IWasabiConduit
    function buyOption(
        WasabiStructs.PoolAsk calldata _request,
        bytes calldata _signature
    ) public payable returns (uint256) {

        IWasabiPoolFactory poolFactory = IWasabiPoolFactory(factory);
        IWasabiFeeManager feeManager = IWasabiFeeManager(poolFactory.getFeeManager());
        (, uint256 feeAmount) = feeManager.getFeeData(_request.poolAddress, _request.premium);
        uint256 amount = _request.premium + feeAmount;

        IWasabiPool pool = IWasabiPool(_request.poolAddress);

        if (pool.getLiquidityAddress() != address(0)) {
            IERC20 erc20 = IERC20(pool.getLiquidityAddress());
            if (!erc20.transferFrom(_msgSender(), address(this), amount)) {
                revert IWasabiErrors.FailedToSend();
            }
            erc20.approve(_request.poolAddress, amount);
            return pool.writeOptionTo(_request, _signature, _msgSender());
        } else {
            require(msg.value >= amount, "Not enough ETH supplied");
            return pool.writeOptionTo{value: amount}(_request, _signature, _msgSender());
        }
    }

    /**
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address /* operator */,
        address /* from */,
        uint256 /* tokenId */,
        bytes memory /* data */
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /// @inheritdoc IWasabiConduit
    function transferToken(
        address _nft,
        uint256 _tokenId,
        address _target
    ) external onlyOwner {
        IERC721(_nft).safeTransferFrom(address(this), _target, _tokenId);
    }

    /// @inheritdoc IWasabiConduit
    function setBNPL(address _bnplContract) external onlyOwner {
        bnplContract = _bnplContract;
    }

    /// @inheritdoc IWasabiConduit
    function setOption(WasabiOption _option) external onlyOwner {
        option = _option;
    }

    /// @inheritdoc IWasabiConduit
    function setMaxOptionsToBuy(uint256 _maxOptionsToBuy) external onlyOwner {
        maxOptionsToBuy = _maxOptionsToBuy;
    }

    /// @inheritdoc IWasabiConduit
    function setPoolFactoryAddress(address _factory) external onlyOwner {
        factory = _factory;
    }

    /// @inheritdoc IWasabiConduit
    function acceptAsk(
        WasabiStructs.Ask calldata _ask,
        bytes calldata _signature
    ) public payable nonReentrant returns (uint256) {
        bytes memory id = getAskId(_ask);
        require(
            !idToFinalizedOrCancelled[id],
            "Order was finalized or cancelled"
        );

        validateAsk(_ask, _signature);

        uint256 price = _ask.price;
        address royaltyAddress;
        uint256 royaltyAmount;

        if (option.getPool(_ask.optionId) == bnplContract) {
            IWasabiFeeManager feeManager = IWasabiFeeManager(IWasabiPoolFactory(factory).getFeeManager());
            (royaltyAddress, royaltyAmount) = feeManager.getFeeDataForOption(_ask.optionId, price);
        } else {
            (royaltyAddress, royaltyAmount) = option.royaltyInfo(_ask.optionId, price);
        }

        if (_ask.tokenAddress == address(0)) {
            require(msg.value >= price, "Not enough ETH supplied");
            if (royaltyAmount > 0) {
                (bool sent, ) = payable(royaltyAddress).call{value: royaltyAmount}("");
                if (!sent) {
                    revert IWasabiErrors.FailedToSend();
                }
                price -= royaltyAmount;
            }
            (bool _sent, ) = payable(_ask.seller).call{value: price}("");
            if (!_sent) {
                revert IWasabiErrors.FailedToSend();
            }
        } else {
            IERC20 erc20 = IERC20(_ask.tokenAddress);
            if (royaltyAmount > 0) {
                if(!erc20.transferFrom(_msgSender(), royaltyAddress, royaltyAmount)) {
                    revert IWasabiErrors.FailedToSend();
                }
                price -= royaltyAmount;
            }
            if (!erc20.transferFrom(_msgSender(), _ask.seller, price)) {
                revert IWasabiErrors.FailedToSend();
            }
        }
        option.safeTransferFrom(_ask.seller, _msgSender(), _ask.optionId);
        idToFinalizedOrCancelled[id] = true;

        emit AskTaken(_ask.optionId, _ask.id, _ask.seller, _msgSender());
        return _ask.optionId;
    }

    /// @inheritdoc IWasabiConduit
    function acceptBid(
        uint256 _optionId,
        address _poolAddress,
        WasabiStructs.Bid calldata _bid,
        bytes calldata _signature
    ) external payable nonReentrant {
        bytes memory id = getBidId(_bid);
        require(
            !idToFinalizedOrCancelled[id],
            "Order was finalized or cancelled"
        );

        require(
            option.ownerOf(_optionId) == _msgSender(),
            "Seller is not owner"
        );

        validateBid(_bid, _signature);

        uint256 price = _bid.price;

        address royaltyAddress;
        uint256 royaltyAmount;

        if (_poolAddress == bnplContract) {
            BNPLOptionBidValidator.validateBidForBNPLOption(bnplContract, _optionId, _bid);

            IWasabiFeeManager feeManager = IWasabiFeeManager(IWasabiPoolFactory(factory).getFeeManager());
            (royaltyAddress, royaltyAmount) = feeManager.getFeeDataForOption(_optionId, price);
        } else {
            IWasabiPool pool = IWasabiPool(_poolAddress);
            validateOptionForBid(_optionId, pool, _bid);

            (royaltyAddress, royaltyAmount) = option.royaltyInfo(_optionId, price);
        }

        IERC20 erc20 = IERC20(_bid.tokenAddress);
        if (royaltyAmount > 0) {
            if (!erc20.transferFrom(_bid.buyer, royaltyAddress, royaltyAmount)) {
                revert IWasabiErrors.FailedToSend();
            }
            price -= royaltyAmount;
        }
        if (!erc20.transferFrom(_bid.buyer, _msgSender(), price)) {
            revert IWasabiErrors.FailedToSend();
        }
        option.safeTransferFrom(_msgSender(), _bid.buyer, _optionId);
        idToFinalizedOrCancelled[id] = true;

        emit BidTaken(_optionId, _bid.id, _bid.buyer, _msgSender());
    }

    /// @inheritdoc IWasabiConduit
    function poolAcceptBid(WasabiStructs.Bid calldata _bid, bytes calldata _signature, uint256 _optionId) external {
        bytes memory id = getBidId(_bid);

        address poolAddress = _msgSender();
        require(
            !idToFinalizedOrCancelled[id],
            "Order was finalized or cancelled"
        );
        
        require(IWasabiPoolFactory(factory).isValidPool(_msgSender()), "Pool is not valid");

        IWasabiPool pool = IWasabiPool(poolAddress);
        validateBid(_bid, _signature);
        validateOptionForBid(_optionId, pool, _bid);

        IERC20 erc20 = IERC20(_bid.tokenAddress);

        (address royaltyAddress, uint256 royaltyAmount) = option.royaltyInfo(_optionId, _bid.price);

        if (royaltyAmount > 0) {
            if (!erc20.transferFrom(_bid.buyer, royaltyAddress, royaltyAmount)) {
                revert IWasabiErrors.FailedToSend();
            }
        }
        if (!erc20.transferFrom(_bid.buyer, poolAddress, _bid.price - royaltyAmount)) {
            revert IWasabiErrors.FailedToSend();
        }

        idToFinalizedOrCancelled[id] = true;

        emit BidTaken(_optionId, _bid.id, _bid.buyer, poolAddress);
    }

    /**
     * @dev Validates if the _ask with _signature
     *
     * @param _ask the _ask to validate
     * @param _signature the _signature to validate the ask with
     */
    function validateAsk(
        WasabiStructs.Ask calldata _ask,
        bytes calldata _signature
    ) internal view {
        // Validate Signature
        address currentOwner = option.ownerOf(_ask.optionId);

        require(
            verifyAsk(_ask, _signature, owner()) || verifyAsk(_ask, _signature, currentOwner),
            "Incorrect signature"
        );
        require(currentOwner == _ask.seller, "Seller is not owner");

        require(_ask.orderExpiry >= block.timestamp, "Order expired");
        require(_ask.price > 0, "Price needs to be greater than 0");
    }

    /**
     * @dev Validates the bid against the given option
     *
     * @param _optionId the id of option
     * @param _pool the pool where the option was issued from
     * @param _bid the _bid to validate
     */
    function validateOptionForBid(
        uint256 _optionId,
        IWasabiPool _pool,
        WasabiStructs.Bid calldata _bid
    ) internal view {
        WasabiStructs.OptionData memory optionData = _pool.getOptionData(_optionId);

        require(
            optionData.optionType == _bid.optionType,
            "Option types don't match"
        );
        require(
            optionData.strikePrice == _bid.strikePrice,
            "Strike prices don't match"
        );

        uint256 diff = optionData.expiry > _bid.expiry
            ? optionData.expiry - _bid.expiry
            : _bid.expiry - optionData.expiry;
        require(diff <= _bid.expiryAllowance, "Not within expiry range");

        require(_pool.getNftAddress() == _bid.collection, "Collections don't match");
        require(_pool.getLiquidityAddress() == _bid.optionTokenAddress, "Option liquidity doesn't match");
    }

    /**
     * @dev Validates the bid
     *
     * @param _bid the _bid to validate
     * @param _signature the _signature to validate the bid with
     */
    function validateBid(
        WasabiStructs.Bid calldata _bid,
        bytes calldata _signature
    ) internal view {
        // Validate Signature
        require(
            verifyBid(_bid, _signature, owner()) ||
                verifyBid(_bid, _signature, _bid.buyer),
            "Incorrect signature"
        );
        require(
            _bid.tokenAddress != address(0),
            "Bidder didn't provide a ERC20 token"
        );

        require(_bid.orderExpiry >= block.timestamp, "Order expired");
        require(_bid.price > 0, "Price needs to be greater than 0");
    }

    /// @inheritdoc IWasabiConduit
    function cancelAsk(
        WasabiStructs.Ask calldata _ask,
        bytes calldata _signature
    ) external {
        // Validate Signature
        require(verifyAsk(_ask, _signature, _ask.seller), "Incorrect signature");
        require(_msgSender() == _ask.seller, "Only the signer can cancel");

        bytes memory id = getAskId(_ask);
        require(
            !idToFinalizedOrCancelled[id],
            "Order was already finalized or cancelled"
        );

        idToFinalizedOrCancelled[id] = true;

        emit AskCancelled(_ask.id, _ask.seller);
    }

    /// @inheritdoc IWasabiConduit
    function cancelBid(
        WasabiStructs.Bid calldata _bid,
        bytes calldata _signature
    ) external {
        // Validate Signature
        require(verifyBid(_bid, _signature, _bid.buyer), "Incorrect signature");
        require(_msgSender() == _bid.buyer, "Only the signer can cancel");

        bytes memory id = getBidId(_bid);
        require(
            !idToFinalizedOrCancelled[id],
            "Order was already finalized or cancelled"
        );

        idToFinalizedOrCancelled[id] = true;
        emit BidCancelled(_bid.id, _bid.buyer);
    }

    /**
     * @dev returns the id of _ask
     */
    function getAskId(
        WasabiStructs.Ask calldata _ask
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(_ask.seller, _ask.id);
    }

    /**
     * @dev returns the id of _bid
     */
    function getBidId(
        WasabiStructs.Bid calldata _bid
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(_bid.buyer, _bid.id);
    }

    /// @dev Withdraws any stuck ETH in this contract
    function withdrawETH(uint256 _amount) external payable onlyOwner {
        if (_amount > address(this).balance) {
            _amount = address(this).balance;
        }
        (bool sent, ) = payable(owner()).call{value: _amount}("");
        if (!sent) {
            revert EthTransferFailed();
        }
    }

    /// @dev Withdraws any stuck ERC20 in this contract
    function withdrawERC20(IERC20 _token, uint256 _amount) external onlyOwner {
        _token.transfer(_msgSender(), _amount);
    }

    /// @dev Withdraws any stuck ERC721 in this contract
    function withdrawERC721(
        IERC721 _token,
        uint256 _tokenId
    ) external onlyOwner {
        _token.safeTransferFrom(address(this), owner(), _tokenId);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Required interface of an Wasabi Fee Manager compliant contract.
 */
interface IWasabiFeeManager {
    /**
     * @dev Returns the fee data for the given pool and amount
     * @param _pool the pool address
     * @param _amount the amount being paid
     * @return receiver the receiver of the fee
     * @return amount the fee amount
     */
    function getFeeData(address _pool, uint256 _amount) external view returns (address receiver, uint256 amount);

    /**
     * @dev Returns the fee data for the given option and amount
     * @param _optionId the option id
     * @param _amount the amount being paid
     * @return receiver the receiver of the fee
     * @return amount the fee amount
     */
    function getFeeDataForOption(uint256 _optionId, uint256 _amount) external view returns (address receiver, uint256 amount);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./WasabiBNPL.sol";
import "./ZhartaLending.sol";
import "./interfaces/IWasabiBNPL.sol";
import "./interfaces/INFTLending.sol";
import "../lib/WasabiStructs.sol";

/**
 * @dev Verifies BNPL options against WasabiConduit objects
 */
library BNPLOptionBidValidator {

    address constant ZHARTA_LENDING = 0x6209A1b9751F67594427a45b5225bC3492009788;

    /// @notice Validates the given bid for the option
    /// @param _bnplAddress the BNPL contract address
    /// @param _optionId the id of the option the validate
    function validateBidForBNPLOption(
        address _bnplAddress,
        uint256 _optionId,
        WasabiStructs.Bid calldata _bid
    ) external view {
        WasabiBNPL bnpl = WasabiBNPL(payable(_bnplAddress));
        (address lending, uint256 loanId) = bnpl.optionToLoan(_optionId);

        INFTLending.LoanDetails memory loanDetails;
        if (lending == ZHARTA_LENDING) {
            loanDetails = ZhartaLending(payable(lending)).getLoanDetailsForBorrower(loanId, _bnplAddress);
        } else {
            loanDetails = INFTLending(lending).getLoanDetails(loanId);
        }

        WasabiStructs.OptionData memory optionData = bnpl.getOptionData(_optionId);

        require(
            optionData.optionType == _bid.optionType,
            "Option types don't match"
        );
        require(
            optionData.strikePrice == _bid.strikePrice,
            "Strike prices don't match"
        );

        uint256 diff = optionData.expiry > _bid.expiry
            ? optionData.expiry - _bid.expiry
            : _bid.expiry - optionData.expiry;
        require(diff <= _bid.expiryAllowance, "Not within expiry range");

        require(loanDetails.nftAddress == _bid.collection, "Collections don't match");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../lib/Signing.sol";
import {IWETH} from "../IWETH.sol";
import "./interfaces/IWasabiBNPL.sol";
import "./interfaces/IWasabiOption.sol";
import "./interfaces/IFlashloan.sol";
import "./interfaces/ILendingAddressProvider.sol";
import "./interfaces/INFTLending.sol";

contract WasabiBNPL is IWasabiBNPL, Ownable, IERC721Receiver, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;

    /// @notice Wasabi Option
    IWasabiOption public wasabiOption;

    /// @notice Wasabi Flashloan
    IFlashloan public flashloan;

    /// @notice Wasabi Address Provider
    ILendingAddressProvider public addressProvider;

    /// @notice Wasabi Pool Factory
    address public factory;

    /// @notice Option ID to LoanInfo mapping
    mapping(uint256 => LoanInfo) public optionToLoan;

    /// @notice
    address public wethAddress;

    /// @notice WasabiBNPL Constructor
    /// @param _wasabiOption Wasabi Option address
    /// @param _flashloan Wasabi Flashloan address
    /// @param _addressProvider Wasabi Address Provider address
    /// @param _wethAddress Wrapped ETH address
    /// @param _factory Wasabi Pool Factory address
    constructor(
        IWasabiOption _wasabiOption,
        IFlashloan _flashloan,
        ILendingAddressProvider _addressProvider,
        address _wethAddress,
        address _factory
    ) {
        wasabiOption = _wasabiOption;
        flashloan = _flashloan;
        addressProvider = _addressProvider;
        wethAddress = _wethAddress;
        factory = _factory;
    }

    /// @dev Returns the option data for the given option id
    function getOptionData(
        uint256 _optionId
    ) external view returns (WasabiStructs.OptionData memory optionData) {
        LoanInfo memory loanInfo = optionToLoan[_optionId];
        INFTLending.LoanDetails memory loanDetails = INFTLending(
            loanInfo.nftLending
        ).getLoanDetails(loanInfo.loanId);
        bool active = wasabiOption.ownerOf(_optionId) != address(0) &&
            loanDetails.loanExpiration > block.timestamp;

        optionData = WasabiStructs.OptionData(
            active,
            WasabiStructs.OptionType.CALL,
            loanDetails.repayAmount,
            loanDetails.loanExpiration,
            loanDetails.tokenId
        );
    }

    /// @notice Executes BNPL flow
    /// @dev BNLP flow
    ///      1. take flashloan
    ///      2. buy nft from marketplace
    ///      3. get loan from nft lending protocol
    /// @param _nftLending NFTLending contract address
    /// @param _borrowData Borrow data
    /// @param _flashLoanAmount Call value
    /// @param _marketplaceCallData List of marketplace calldata
    /// @param _signatures Signatures
    function bnpl(
        address _nftLending,
        bytes calldata _borrowData,
        uint256 _flashLoanAmount,
        FunctionCallData[] calldata _marketplaceCallData,
        bytes[] calldata _signatures
    ) external payable nonReentrant returns (uint256) {
        validate(_marketplaceCallData, _signatures);

        if (!addressProvider.isLending(_nftLending)) {
            revert InvalidParam();
        }

        // 1. Get flash loan
        uint256 flashLoanRepayAmount = flashloan.borrow(_flashLoanAmount);

        // 2. Buy NFT
        bool marketSuccess = executeFunctions(_marketplaceCallData);
        if (!marketSuccess) {
            revert FunctionCallFailed();
        }

        // 3. Get loan
        bytes memory result = _nftLending.functionDelegateCall(
            abi.encodeWithSelector(INFTLending.borrow.selector, _borrowData)
        );

        uint256 loanId = abi.decode(result, (uint256));
        uint256 optionId = wasabiOption.mint(_msgSender(), factory);
        optionToLoan[optionId] = LoanInfo({
            nftLending: _nftLending,
            loanId: loanId
        });

        // 4. Repay flashloan
        if (address(this).balance < flashLoanRepayAmount) {
            revert LoanNotPaid();
        }
        uint256 payout = address(this).balance - flashLoanRepayAmount;

        (bool sent, ) = payable(address(flashloan)).call{
            value: flashLoanRepayAmount
        }("");
        if (!sent) {
            revert EthTransferFailed();
        }
        if (payout > 0) {
            (sent, ) = payable(_msgSender()).call{value: payout}("");
            if (!sent) {
                revert EthTransferFailed();
            }
        }

        return optionId;
    }

    /// @notice Executes a given list of functions
    /// @param _marketplaceCallData List of marketplace calldata
    function executeFunctions(
        FunctionCallData[] memory _marketplaceCallData
    ) internal returns (bool) {
        uint256 length = _marketplaceCallData.length;
        for (uint256 i; i != length; ++i) {
            FunctionCallData memory functionCallData = _marketplaceCallData[i];
            (bool success, ) = functionCallData.to.call{
                value: functionCallData.value
            }(functionCallData.data);
            if (success == false) {
                return false;
            }
        }
        return true;
    }

    /// @notice Validates if the FunctionCallData list has been approved
    /// @param _marketplaceCallData List of marketplace calldata
    /// @param _signatures Signatures
    function validate(
        FunctionCallData[] calldata _marketplaceCallData,
        bytes[] calldata _signatures
    ) internal view {
        uint256 calldataLength = _marketplaceCallData.length;
        require(calldataLength > 0, "Need marketplace calls");
        require(calldataLength == _signatures.length, "Length is invalid");
        for (uint256 i; i != calldataLength; ++i) {
            bytes32 ethSignedMessageHash = Signing.getEthSignedMessageHash(
                getMessageHash(_marketplaceCallData[i])
            );
            require(
                Signing.recoverSigner(ethSignedMessageHash, _signatures[i]) ==
                    owner(),
                "Owner is not signer"
            );
        }
    }

    /// @notice Returns the message hash for the given _data
    function getMessageHash(
        FunctionCallData calldata _data
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_data.to, _data.value, _data.data));
    }

    /// @dev Withdraws any stuck ETH in this contract
    function withdrawETH(uint256 _amount) external payable onlyOwner {
        if (_amount > address(this).balance) {
            _amount = address(this).balance;
        }
        (bool sent, ) = payable(owner()).call{value: _amount}("");
        if (!sent) {
            revert EthTransferFailed();
        }
    }

    /// @dev Withdraws any stuck ERC20 in this contract
    function withdrawERC20(IERC20 _token, uint256 _amount) external onlyOwner {
        _token.safeTransfer(_msgSender(), _amount);
    }

    /// @dev Withdraws any stuck ERC721 in this contract
    function withdrawERC721(
        IERC721 _token,
        uint256 _tokenId
    ) external onlyOwner {
        _token.safeTransferFrom(address(this), owner(), _tokenId);
    }

    function onERC721Received(
        address /* operator */,
        address /* from */,
        uint256 /* tokenId */,
        bytes memory /* data */
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable {}

    /**
     * @dev Executes the given option id
     * @param _optionId The option id
     */
    function executeOption(uint256 _optionId) external payable nonReentrant {
        require(
            wasabiOption.ownerOf(_optionId) == _msgSender(),
            "Only owner can exercise option"
        );

        LoanInfo storage loanInfo = optionToLoan[_optionId];
        require(loanInfo.nftLending != address(0), "Invalid Option");

        INFTLending.LoanDetails memory loanDetails = INFTLending(
            loanInfo.nftLending
        ).getLoanDetails(loanInfo.loanId);
        require(
            loanDetails.loanExpiration > block.timestamp,
            "Loan has expired"
        );
        require(
            msg.value >= loanDetails.repayAmount,
            "Insufficient repay amount supplied"
        );

        loanInfo.nftLending.functionDelegateCall(
            abi.encodeWithSelector(
                INFTLending.repay.selector,
                loanInfo.loanId,
                _msgSender()
            )
        );

        wasabiOption.burn(_optionId);
        emit OptionExecuted(_optionId);
    }

    /**
     * @dev Executes the given option id and sells the NFT to the market
     * @param _optionId The option id
     * @param _marketplaceCallData List of marketplace calldata
     * @param _signatures List of signatures of the marketplace call data
     */
    function executeOptionWithArbitrage(
        uint256 _optionId,
        FunctionCallData[] calldata _marketplaceCallData,
        bytes[] calldata _signatures
    ) external payable nonReentrant {
        validate(_marketplaceCallData, _signatures);
        require(
            wasabiOption.ownerOf(_optionId) == _msgSender(),
            "Only owner can exercise option"
        );

        LoanInfo storage loanInfo = optionToLoan[_optionId];
        require(loanInfo.nftLending != address(0), "Invalid Option");

        INFTLending.LoanDetails memory loanDetails = INFTLending(
            loanInfo.nftLending
        ).getLoanDetails(loanInfo.loanId);
        require(
            loanDetails.loanExpiration > block.timestamp,
            "Loan has expired"
        );

        uint256 initialBalance = address(this).balance;

        // 1. Get flash loan
        uint256 flashLoanRepayAmount = flashloan.borrow(
            loanDetails.repayAmount
        );

        // 2. Repay loan
        loanInfo.nftLending.functionDelegateCall(
            abi.encodeWithSelector(
                INFTLending.repay.selector,
                loanInfo.loanId,
                address(this)
            )
        );
        wasabiOption.burn(_optionId);

        // 3. Sell NFT
        bool marketSuccess = executeFunctions(_marketplaceCallData);
        if (!marketSuccess) {
            revert FunctionCallFailed();
        }

        // Withdraw any WETH received
        IWETH weth = IWETH(wethAddress);
        uint256 wethBalance = weth.balanceOf(address(this));
        if (wethBalance > 0) {
            weth.withdraw(wethBalance);
        }

        uint256 balanceChange = address(this).balance - initialBalance;

        // 4. Repay flashloan
        if (balanceChange < flashLoanRepayAmount) {
            revert LoanNotPaid();
        }
        (bool sent, ) = payable(address(flashloan)).call{
            value: flashLoanRepayAmount
        }("");
        if (!sent) {
            revert EthTransferFailed();
        }

        // 5. Give payout
        uint256 payout = balanceChange - flashLoanRepayAmount;
        if (payout > 0) {
            (sent, ) = payable(_msgSender()).call{value: payout}("");
            if (!sent) {
                revert EthTransferFailed();
            }
        }

        emit OptionExecutedWithArbitrage(_optionId, payout);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/INFTLending.sol";
import "./interfaces/zharta/ILoansPeripheral.sol";
import "./interfaces/zharta/ILoansCore.sol";
import {IWETH} from "../IWETH.sol";

/// @title Zharta Lending
/// @notice Manages creating and repaying a loan on Zharta
contract ZhartaLending is INFTLending {
    using SafeERC20 for IERC20;

    /// @notice LoansPeripheral Contract
    ILoansPeripheral public immutable loansPeripheral;

    /// @notice LoansCore Contract
    ILoansCore public immutable loansCore;

    /// @notice Collateral Vault Core
    address public immutable collateralVaultCore;

    constructor(ILoansPeripheral _loansPeripheral, ILoansCore _loansCore, address _collateralVaultCore) {
        loansPeripheral = _loansPeripheral;
        loansCore = _loansCore;
        collateralVaultCore = _collateralVaultCore;
    }

    /// @inheritdoc INFTLending
    function getLoanDetails(
        uint256 _loanId
    ) external view returns (LoanDetails memory loanDetails) {
        // Get Loan for loanId
        ILoansCore.Loan memory loanDetail = loansCore.getLoan(
            msg.sender,
            _loanId
        );

        uint256 repayAmount = loansPeripheral.getLoanPayableAmount(
            msg.sender,
            _loanId,
            block.timestamp
        );

        return LoanDetails(
            loanDetail.amount, // borrowAmount
            repayAmount, // repayAmount
            loanDetail.maturity, // loanExpiration
            loanDetail.collaterals[0].contractAddress, // nftAddress
            loanDetail.collaterals[0].tokenId // tokenId
        );
    }

    /// @notice Get loan details for given loan id and the borrower
    /// @param _loanId The loan id
    /// @param _borrower The borrower
    function getLoanDetailsForBorrower(
        uint256 _loanId,
        address _borrower
    ) external view returns (LoanDetails memory loanDetails) {
        // Get Loan for loanId
        ILoansCore.Loan memory loanDetail = loansCore.getLoan(
            _borrower,
            _loanId
        );

        uint256 repayAmount = loansPeripheral.getLoanPayableAmount(
            _borrower,
            _loanId,
            block.timestamp
        );

        return LoanDetails(
            loanDetail.amount, // borrowAmount
            repayAmount, // repayAmount
            loanDetail.maturity, // loanExpiration
            loanDetail.collaterals[0].contractAddress, // nftAddress
            loanDetail.collaterals[0].tokenId // tokenId
        );
    }

    /// @inheritdoc INFTLending
    function borrow(
        bytes calldata _inputData
    ) external payable returns (uint256) {
        // Decode `inputData` into required parameters
        ILoansPeripheral.Calldata memory callData = abi.decode(
            _inputData,
            (ILoansPeripheral.Calldata)
        );

        IERC721 nft = IERC721(callData.collateral.contractAddress);

        // Approve
        if (!nft.isApprovedForAll(address(this), collateralVaultCore)) {
            nft.setApprovalForAll(collateralVaultCore, true);
        }

        ILoansCore.Collateral[] memory collaterals = new ILoansCore.Collateral[](1);
        collaterals[0] = callData.collateral;

        // Borrow on Zharta
        uint256 loanId = loansPeripheral.reserveEth(
            callData.amount,
            callData.interest,
            callData.maturity,
            collaterals,
            callData.delegations,
            callData.deadline,
            callData.nonce,
            callData.genesisToken,
            callData.v,
            callData.r,
            callData.s
        );

        // Return loan id
        return loanId;
    }

    /// @inheritdoc INFTLending
    function repay(uint256 _loanId, address _receiver) external payable {
        // Pay back loan
        uint256 repayAmount = loansPeripheral.getLoanPayableAmount(
            address(this),
            _loanId,
            block.timestamp
        );
        loansPeripheral.pay{value: repayAmount}(_loanId);

        if (_receiver != address(this)) {
            // Get Loan for loanId
            ILoansCore.Loan memory loanDetail = loansCore.getLoan(
                address(this),
                _loanId
            );

            // Transfer collateral NFT to the user
            IERC721(loanDetail.collaterals[0].contractAddress).safeTransferFrom(
                address(this),
                _receiver,
                loanDetail.collaterals[0].tokenId
            );
        }
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title Flashloan Interface
interface IFlashloan {
    /// @notice Flashloan Info Struct
    /// @param enabled Enabled flag
    /// @param flashloanPremiumValue;
    struct FlashLoanInfo {
        bool enabled;
        uint256 flashloanPremiumValue;
    }

    /// @notice ETH Transfer Failed
    error EthTransferFailed();

    /// @notice Borrow ETH
    /// @param amount Flashloan amount
    /// @return flashLoanRepayAmount Flashloan repayment amount
    function borrow(uint256 amount) external returns (uint256 flashLoanRepayAmount);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ILendingAddressProvider {
    event LendingAdded(address indexed lending);

    event LendingRemoved(address indexed lending);

    function isLending(address) external view returns (bool);

    function addLending(address _lending) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @notice NFTLending Interface
interface INFTLending {
    /// @notice Loan Details struct
    /// @param borrowAmount Borrow amount
    /// @param repayAmount Repay amount
    /// @param loanExpiration Loan expiration
    struct LoanDetails {
        uint256 borrowAmount;
        uint256 repayAmount;
        uint256 loanExpiration;
        address nftAddress;
        uint256 tokenId;
    }

    /// @notice Get loan details for given loan id
    /// @param _loanId The loan id
    function getLoanDetails(
        uint256 _loanId
    ) external view returns (LoanDetails memory);

    /// @notice Borrow WETH from the protocol
    /// @param _inputData Encoded input parameters
    /// @return _loanId The loan id
    function borrow(
        bytes calldata _inputData
    ) external payable returns (uint256 _loanId);

    /// @notice Repay the loan
    /// @param _loanId The loan id to repay
    /// @param _receiver The user address to receive collateral NFT
    function repay(uint256 _loanId, address _receiver) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title WasabiBNPL Interface
interface IWasabiBNPL {
    /// @notice Function Calldata Struct
    /// @param to to address
    /// @param value call value
    /// @param data call data
    struct FunctionCallData {
        address to;
        uint256 value;
        bytes data;
    }

    /// @notice Loan Info Struct
    /// @param nftLending INFTLending address
    /// @param loanId loan id
    struct LoanInfo {
        address nftLending;
        uint256 loanId;
    }

    /// @notice Function Call Failed
    error FunctionCallFailed();

    /// @notice Loan Not Paid
    error LoanNotPaid();

    /// @notice ETH Transfer Failed
    error EthTransferFailed();

    /// @notice Invalid Param
    error InvalidParam();

    /// @dev Emitted when an option is executed
    event OptionExecuted(uint256 optionId);

    /// @dev Emitted when an option is executed and the NFT is sold to the market
    event OptionExecutedWithArbitrage(uint256 optionId, uint256 payout);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IWasabiOption {
    function mint(address, address) external returns (uint256);

    function burn(uint256) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ILoansCore {
    struct Collateral {
        address contractAddress;
        uint256 tokenId;
        uint256 amount;
    }

    struct Loan {
        uint256 id;
        uint256 amount;
        uint256 interest;
        uint256 maturity;
        uint256 startTime;
        Collateral[] collaterals;
        uint256 paidPrincipal;
        uint256 paidInterestAmount;
        bool started;
        bool invalidated;
        bool paid;
        bool defaulted;
        bool canceled;
    }

    function getLoan(
        address _borrower,
        uint256 _loanId
    ) external view returns (Loan memory);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./ILoansCore.sol";

interface ILoansPeripheral {

    struct Calldata {
        uint256 amount;
        uint256 interest;
        uint256 maturity;
        ILoansCore.Collateral collateral;
        bool delegations;
        uint256 deadline;
        uint256 nonce;
        uint256 genesisToken;
        uint256 v;
        uint256 r;
        uint256 s;
    }

    function reserveEth(
        uint256 _amount,
        uint256 _interest,
        uint256 _maturity,
        ILoansCore.Collateral[] calldata _collaterals,
        bool _delegations,
        uint256 _deadline,
        uint256 _nonce,
        uint256 _genesisToken,
        uint256 _v,
        uint256 _r,
        uint256 _s
    ) external returns (uint256);

    function pay(uint256 _loanId) external payable;

    function getLoanPayableAmount(
        address _borrower,
        uint256 _loanId,
        uint256 _timestamp
    ) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {WasabiStructs} from "./WasabiStructs.sol";

/**
 * @dev Signature Verification
 */
library Signing {

    /**
     * @dev Returns the message hash for the given request
     */
    function getMessageHash(WasabiStructs.PoolAsk calldata _request) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _request.id,
                _request.poolAddress,
                _request.optionType,
                _request.strikePrice,
                _request.premium,
                _request.expiry,
                _request.tokenId,
                _request.orderExpiry));
    }

    /**
     * @dev Returns the message hash for the given request
     */
    function getAskHash(WasabiStructs.Ask calldata _ask) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _ask.id,
                _ask.price,
                _ask.tokenAddress,
                _ask.orderExpiry,
                _ask.seller,
                _ask.optionId));
    }

    function getBidHash(WasabiStructs.Bid calldata _bid) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _bid.id,
                _bid.price,
                _bid.tokenAddress,
                _bid.collection,
                _bid.orderExpiry,
                _bid.buyer,
                _bid.optionType,
                _bid.strikePrice,
                _bid.expiry,
                _bid.expiryAllowance));
    }

    /**
     * @dev creates an ETH signed message hash
     */
    function getEthSignedMessageHash(bytes32 _messageHash) internal pure returns (bytes32) {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function getSigner(
        WasabiStructs.PoolAsk calldata _request,
        bytes memory signature
    ) internal pure returns (address) {
        bytes32 messageHash = getMessageHash(_request);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature);
    }

    function getAskSigner(
        WasabiStructs.Ask calldata _ask,
        bytes memory signature
    ) internal pure returns (address) {
        bytes32 messageHash = getAskHash(_ask);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature);
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        internal
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library WasabiStructs {
    enum OptionType {
        CALL,
        PUT
    }

    struct OptionData {
        bool active;
        OptionType optionType;
        uint256 strikePrice;
        uint256 expiry;
        uint256 tokenId; // Locked token for CALL options
    }

    struct PoolAsk {
        uint256 id;
        address poolAddress;
        OptionType optionType;
        uint256 strikePrice;
        uint256 premium;
        uint256 expiry;
        uint256 tokenId; // Token to lock for CALL options
        uint256 orderExpiry;
    }

    struct PoolBid {
        uint256 id;
        uint256 price;
        address tokenAddress;
        uint256 orderExpiry;
        uint256 optionId;
    }

    struct Bid {
        uint256 id;
        uint256 price;
        address tokenAddress;
        address collection;
        uint256 orderExpiry;
        address buyer;
        OptionType optionType;
        uint256 strikePrice;
        uint256 expiry;
        uint256 expiryAllowance;
        address optionTokenAddress;
    }

    struct Ask {
        uint256 id;
        uint256 price;
        address tokenAddress;
        uint256 orderExpiry;
        address seller;
        uint256 optionId;
    }

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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