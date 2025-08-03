pragma solidity =0.8.21;

error NotMaster();
error NotProposed();

contract OwnableMaster {

    address public master;
    address public proposedMaster;

    address constant ZERO_ADDRESS = address(0x0);

    modifier onlyProposed() {
        _onlyProposed();
        _;
    }

    function _onlyMaster()
        private
        view
    {
        if (msg.sender == master) {
            return;
        }

        revert NotMaster();
    }

    modifier onlyMaster() {
        _onlyMaster();
        _;
    }

    function _onlyProposed()
        private
        view
    {
        if (msg.sender == proposedMaster) {
            return;
        }

        revert NotProposed();
    }

    event ProposedOwner(
        address proposed,
        uint256 timestamp
    );

    event ClaimedOwnership(
        address master,
        uint256 timestamp
    );

    constructor(
        address _master
    ) {
        master = _master;
    }

    /**
     * @dev Allows to propose next master.
     * Must be claimed by proposer.
     */
    function proposeOwner(
        address _proposedOwner
    )
        external
        onlyMaster
    {
        proposedMaster = _proposedOwner;

        emit ProposedOwner(
            _proposedOwner,
            block.timestamp
        );
    }

    /**
     * @dev Allows to claim master role.
     * Must be called by proposer.
     */
    function claimOwnership()
        external
        onlyProposed
    {
        master = proposedMaster;

        emit ClaimedOwnership(
            proposedMaster,
            block.timestamp
        );
    }

    /**
     * @dev Removes master role.
     * No ability to be in control.
     */
    function renounceOwnership()
        external
        onlyMaster
    {
        master = ZERO_ADDRESS;
        proposedMaster = ZERO_ADDRESS;
    }
}

interface IPositionNFTs {

    function ownerOf(
        uint256 _nftId
    )
        external
        view
        returns (address);

    function getOwner(
        uint256 _nftId
    )
        external
        view
        returns (address);


    function totalSupply()
        external
        view
        returns (uint256);

    function mintPosition()
        external;

    function tokenOfOwnerByIndex(
        address _owner,
        uint256 _index
    )
        external
        view
        returns (uint256);

    function mintPositionForUser(
        address _user
    )
        external
        returns (uint256);

    function getApproved(
        uint256 _nftId
    )
        external
        returns (address);
}

struct CurveSwapStruct {
    uint256 curvePoolTokenIndexFrom;
    uint256 curvePoolTokenIndexTo;
    uint256 curveMetaPoolTokenIndexFrom;
    uint256 curveMetaPoolTokenIndexTo;
    uint256 curvePoolSwapAmount;
    uint256 curveMetaPoolSwapAmount;
}

interface IWiseSecurity {

    function overallUSDBorrowHeartbeat(
        uint256 _nftId
    )
        external
        view
        returns (uint256 buffer);

    function checkBadDebt(
        uint256 _nftId
    )
        external;

    function getFullCollateralUSD(
        uint256 _nftId,
        address _poolToken
    )
        external
        view
        returns (uint256);

    function checksLiquidation(
        uint256 _nftIdLiquidate,
        address _caller,
        address _tokenToPayback,
        uint256 _shareAmountToPay
    )
        external
        view;

    function onlyIsolationPool(
        address _poolAddress
    )
        external
        view;

    function getPositionBorrowAmount(
        uint256 _nftId,
        address _poolToken
    )
        external
        view
        returns (uint256);

    function getPositionLendingAmount(
        uint256 _nftId,
        address _poolToken
    )
        external
        view
        returns (uint256);

    function getLiveDebtratioNormalPool(
        uint256 _nftId
    )
        external
        view
        returns (uint256);

    function overallUSDCollateralsBare(
        uint256 _nftId
    )
        external
        view
        returns (uint256 amount);

    function FEE_MANAGER()
        external
        returns (address);

    function AAVE_HUB()
        external
        returns (address);

    function WISE_LIQUIDATION()
        external
        returns (address);

    function curveSecurityCheck(
        address _poolAddress
    )
        external;

    function prepareCurvePools(
        address _poolToken,
        address _curvePool,
        address _curveMetaPool,
        CurveSwapStruct memory _curveSwapStruct
    )
        external;

    function setUnderlyingPoolTokensFromPoolToken(
        address _poolToken,
        address[] memory _underlyingTokens
    )
        external;

    function checksDeposit(
        uint256 _nftId,
        address _caller,
        address _poolToken,
        uint256 _amount
    )
        external
        view;

    function checksWithdraw(
        uint256 _nftId,
        address _caller,
        address _poolToken,
        uint256 _amount
    )
        external
        view;

    function checksBorrow(
        uint256 _nftId,
        address _caller,
        address _poolToken,
        uint256 _amount
    )
        external
        view;

    function checksSolelyWithdraw(
        uint256 _nftId,
        address _caller,
        address _poolToken,
        uint256 _amount
    )
        external
        view;

    function checkOwnerPosition(
        uint256 _nftId,
        address _caller
    )
        external
        view;

    function checksCollateralizeDeposit(
        uint256 _nftIdCaller,
        address _caller,
        address _poolAddress
    )
        external
        view;

    function checksDecollateralizeDeposit(
        uint256 _nftIdCaller,
        address _poolToken
    )
        external
        view;

    function checkBorrowLimit(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    )
        external
        view;

    function checkPositionLocked(
        uint256 _nftId,
        address _caller
    )
        external
        view;

    function checkPaybackLendingShares(
        uint256 _nftIdReceiver,
        uint256 _nftIdCaller,
        address _caller,
        address _poolToken,
        uint256 _amount
    )
        external
        view;

    function checksRegistrationIsolationPool(
        uint256 _nftId,
        address _caller,
        address _isolationPool
    )
        external
        view;

    function checksRegister(
        uint256 _nftId,
        address _caller
    )
        external
        view;

    function getLendingRate(
        address _poolToken
    )
        external
        view
        returns (uint256);
}

struct GlobalPoolEntry {
    uint256 totalPool;
    uint256 utilization;
    uint256 totalBareToken;
    uint256 poolFee;
}

struct BorrowPoolEntry {
    bool allowBorrow;
    uint256 pseudoTotalBorrowAmount;
    uint256 totalBorrowShares;
    uint256 borrowRate;
}

struct LendingPoolEntry {
    uint256 pseudoTotalPool;
    uint256 totalDepositShares;
    uint256 collateralFactor;
}

struct PoolEntry {
    uint256 totalPool;
    uint256 utilization;
    uint256 totalBareToken;
    uint256 poolFee;
}

interface IWiseLending {

    function newBorrowRate(
        address _poolToken
    )
        external;

    function calculateBorrowShares(
        address _poolToken,
        uint256 _amount
    )
        external
        view
        returns (uint256);

    function borrowPoolData(
        address _poolToken
    )
        external
        view
        returns (BorrowPoolEntry memory);

    function lendingPoolData(
        address _poolToken
    )
        external
        view
        returns (LendingPoolEntry memory);

    function getPositionBorrowShares(
        uint256 _nftId,
        address _poolToken
    )
        external
        view
        returns (uint256);

    function getTimeStamp(
        address _poolToken
    )
        external
        view
        returns (uint256);

    function getPureCollateralAmount(
        uint256 _nftId,
        address _poolToken
    )
        external
        view
        returns (uint256);

    function getCollateralState(
        uint256 _nftId,
        address _poolToken
    )
        external
        view
        returns (bool);

    function veryfiedIsolationPool(
        address _poolAddress
    )
        external
        view
        returns (bool);

    function positionLocked(
        uint256 _nftId
    )
        external
        view
        returns (bool);

    function getTotalBareToken(
        address _poolToken
    )
        external
        view
        returns (uint256);

    function maxDepositValueToken(
        address _poolToken
    )
        external
        view
        returns (uint256);

    function master()
        external
        view
        returns (address);

    function WETH_ADDRESS()
        external
        view
        returns (address);

    function WISE_ORACLE()
        external
        view
        returns (address);

    function POSITION_NFT()
        external
        view
        returns (address);

    function FEE_MANAGER()
        external
        view
        returns (address);

    function WISE_SECURITY()
        external
        view
        returns (address);

    function WISE_LIQUIDATION()
        external
        view
        returns (address);

    function lastUpdated(
        address _poolAddress
    )
        external
        view
        returns (uint256);

    function isolationPoolRegistered(
        uint256 _nftId,
        address _isolationPool
    )
        external
        view
        returns (bool);

    function calculateLendingShares(
        address _poolToken,
        uint256 _amount
    )
        external
        view
        returns (uint256);

    function liquidationCorePayback(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount,
        uint256 _shares
    )
        external;

    function liquidationDecreaseCollateral(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    )
        external;

    function liquidationDecreaseTotalBareToken(
        address _poolToken,
        uint256 _amount
    )
        external;

    function positionPureCollateralAmount(
        uint256 _nftId,
        address _poolToken
    )
        external
        returns (uint256);

    function liquidationCoreWithdraw(
        address _poolToken,
        uint256 _nftId,
        uint256 _amount,
        uint256 _shares
    )
        external;

    function liquidationDecreaseLendingShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    )
        external;

    function liquidationIncreaseLendingShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    )
        external;

    function liquidationAddPosition(
        uint256 _nftId,
        address _poolToken
    )
        external;

    function getTotalPool(
        address _poolToken
    )
        external
        view
        returns (uint256);

    function depositExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount,
        bool _collateralState
    )
        external
        returns (uint256);

    function withdrawOnBehalfExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    )
        external
        returns (uint256);

    function syncManually(
        address _poolToken
    )
        external;

    function withdrawOnBehalfExactShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    )
        external
        returns (uint256);

    function borrowOnBehalfExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    )
        external
        returns (uint256);

    function solelyDeposit(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    )
        external;

    function solelyWithdrawOnBehalf(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    )
        external;

    function paybackExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    )
        external
        returns (uint256);

    function paybackExactShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    )
        external
        returns (uint256);

    function setPoolFee(
        address _poolToken,
        uint256 _newFee
    )
        external;

    function getPositionLendingShares(
        uint256 _nftId,
        address _poolToken
    )
        external
        view
        returns (uint256);

    function withdrawExactShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    )
        external
        returns (uint256);

    function poolTokenAddresses()
        external
        returns (address[] memory);

    function corePaybackFeeManager(
        address _poolToken,
        uint256 _nftId,
        uint256 _amount,
        uint256 _shares
    )
        external;

    /*
    function curveSecurityCheck(
        address _poolToken
    )
        external;
    */

    function preparePool(
        address _poolToken
    )
        external;

    function getPositionBorrowTokenLength(
        uint256 _nftId
    )
        external
        view
        returns (uint256);

    function getPositionBorrowTokenByIndex(
        uint256 _nftId,
        uint256 _index
    )
        external
        view
        returns (address);

    function getPositionLendingTokenByIndex(
        uint256 _nftId,
        uint256 _index
    )
        external
        view
        returns (address);

    function getPositionLendingTokenLength(
        uint256 _nftId
    )
        external
        view
        returns (uint256);

    function globalPoolData(
        address _poolToken
    )
        external
        view
        returns (GlobalPoolEntry memory);


    function getGlobalBorrowAmount(
        address _token
    )
        external
        view
        returns (uint256);

    function getPseudoTotalBorrowAmount(
        address _token
    )
        external
        view
        returns (uint256);

    function getInitialBorrowAmountUser(
        address _user,
        address _token
    )
        external
        view
        returns (uint256);

    function getPseudoTotalPool(
        address _token
    )
        external
        view
        returns (uint256);

    function getInitialDepositAmountUser(
        address _user,
        address _token
    )
        external
        view
        returns (uint256);

    function getGlobalDepositAmount(
        address _token
    )
        external
        view
        returns (uint256);

    function paybackAmount(
        address _token,
        uint256 _shares
    )
        external
        view
        returns (uint256);

    function getPositionBorrowShares(
        address _user,
        address _token
    )
        external
        view
        returns (uint256);

    function getPositionLendingShares(
        address _user,
        address _token
    )
        external
        view
        returns (uint256);

    function cashoutAmount(
        address _token,
        uint256 _shares
    )
        external
        view
        returns (uint256);

    function getTotalDepositShares(
        address _token
    )
        external
        view
        returns (uint256);

    function getTotalBorrowShares(
        address _token
    )
        external
        view
        returns (uint256);

    function setRegistrationIsolationPool(
        uint256 _nftId,
        bool _state,
        address _isolationPool
    )
        external;
}

interface IERC20 {

    function totalSupply()
        external
        view
        returns (uint256);

    function balanceOf(
        address _account
    )
        external
        view
        returns (uint256);

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    )
        external
        returns (bool);

    function transfer(
        address _recipient,
        uint256 _amount
    )
        external
        returns (bool);

    function allowance(
        address owner,
        address spender
    )
        external
        view
        returns (uint256);

    function approve(
        address _spender,
        uint256 _amount
    )
        external
        returns (bool);

    function decimals()
        external
        view
        returns (uint8);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event  Deposit(
        address indexed dst,
        uint wad
    );

    event  Withdrawal(
        address indexed src,
        uint wad
    );
}

contract TransferHelper {

    /**
     * @dev
     * Allows to execute transfer for a token
     */
    function _safeTransfer(
        address _token,
        address _to,
        uint256 _value
    )
        internal
    {
        IERC20 token = IERC20(
            _token
        );

        _callOptionalReturnBool(
            _token,
            abi.encodeWithSelector(
                token.transfer.selector,
                _to,
                _value
            )
        );
    }

    /**
     * @dev
     * Allows to execute transferFrom for a token
     */
    function _safeTransferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _value
    )
        internal
    {
        IERC20 token = IERC20(
            _token
        );

        _callOptionalReturnBool(
            _token,
            abi.encodeWithSelector(
                token.transferFrom.selector,
                _from,
                _to,
                _value
            )
        );
    }

    /**
     * @dev
     * Helper function to do the token call
     */
    function _callOptionalReturn(
        address _token,
        bytes memory _data
    )
        private
    {
        (
            bool success,
            bytes memory returndata
        ) = _token.call(_data);

        require(
            success,
            "TransferHelper: CALL_FAILED"
        );

        if (returndata.length > 0) {
            require(
                abi.decode(
                    returndata,
                    (bool)
                ),
                "TransferHelper: OPERATION_FAILED"
            );
        }
    }

    function _callOptionalReturnBool(
        address token,
        bytes memory data
    )
        private
        returns (bool)
    {
        (
            bool success,
            bytes memory returndata
        ) = token.call(
            data
        );

        bool results = returndata.length == 0 || abi.decode(
            returndata,
            (bool)
        );

        return success
            && results
            && token.code.length > 0;
    }
}

interface IWETH is IERC20 {

    function deposit()
        external
        payable;

    function withdraw(
        uint256
    )
        external;
}

interface IAave is IERC20 {

    struct ReserveData {

        // Stores the reserve configuration
        ReserveConfigurationMap configuration;

        // Liquidity index. Expressed in ray
        uint128 liquidityIndex;

        // Current supply rate. Expressed in ray
        uint128 currentLiquidityRate;

        // Variable borrow index. Expressed in ray
        uint128 variableBorrowIndex;

        // Current variable borrow rate. Expressed in ray
        uint128 currentVariableBorrowRate;

        // Current stable borrow rate. Expressed in ray
        uint128 currentStableBorrowRate;

        // Timestamp of last update
        uint40 lastUpdateTimestamp;

        // Id of the reserve.
        uint16 id;

        // aToken address
        address aTokenAddress;

        // stableDebtToken address
        address stableDebtTokenAddress;

        // VariableDebtToken address
        address variableDebtTokenAddress;

        // Address of the interest rate strategy
        address interestRateStrategyAddress;

        // Current treasury balance, scaled
        uint128 accruedToTreasury;

        // Outstanding unbacked aTokens minted through the bridging feature
        uint128 unbacked;

        // Outstanding debt borrowed against this asset in isolation mode
        uint128 isolationModeTotalDebt;
    }

    struct ReserveConfigurationMap {
        uint256 data;
    }

    function deposit(
        address _token,
        uint256 _amount,
        address _owner,
        uint16 _referralCode
    )
        external;

    function withdraw(
        address _token,
        uint256 _amount,
        address _recipient
    )
        external
        returns (uint256);

    function getReserveData(
        address asset
    )
        external
        view
        returns (ReserveData memory);
}

contract AaveEvents {

    event SetAaveTokenAddress(
        address underlyingAsset,
        address aaveToken,
        uint256 timestamp
    );

    event IsDepositAave(
        uint256 nftId,
        uint256 timestamp
    );

    event IsWithdrawAave(
        uint256 nftId,
        uint256 timestamp
    );

    event IsBorrowAave(
        uint256 nftId,
        uint256 timestamp
    );

    event IsPaybackAave(
        uint256 nftId,
        uint256 timestamp
    );

    event IsSolelyDepositAave(
        uint256 nftId,
        uint256 timestamp
    );

    event IsSolelyWithdrawAave(
        uint256 nftId,
        uint256 timestamp
    );
}

error AlreadySet();

contract Declarations is OwnableMaster, AaveEvents {

    IAave immutable AAVE;
    IWETH immutable WETH;

    IWiseLending immutable public WISE_LENDING;
    IPositionNFTs immutable public POSITION_NFT;

    uint16 constant REF_CODE = 0;
    IWiseSecurity public WISE_SECURITY;

    address immutable public WETH_ADDRESS;
    address immutable public AAVE_ADDRESS;

    uint256 constant PRECISION_FACTOR_E9 = 1E9;
    uint256 constant PRECISION_FACTOR_E18 = 1E18;
    uint256 constant MAX_AMOUNT = type(uint256).max;

    mapping (address => address) public aaveTokenAddress;

    modifier checkOwner(
        uint256 _nftId
    ) {
        _checkOwner(
            _nftId
        );
        _;
    }

    modifier checkPositionLocked(
        uint256 _nftId
    ) {
        _checkLocked(
            _nftId
        );
        _;
    }

    constructor(
        address _master,
        address _aaveAddress,
        address _lendingAddress
    )
        OwnableMaster(
            _master
        )
    {
        AAVE_ADDRESS = _aaveAddress;

        WISE_LENDING = IWiseLending(
            _lendingAddress
        );

        WETH_ADDRESS = WISE_LENDING.WETH_ADDRESS();

        AAVE = IAave(
            AAVE_ADDRESS
        );

        WETH = IWETH(
            WETH_ADDRESS
        );

        POSITION_NFT = IPositionNFTs(
            WISE_LENDING.POSITION_NFT()
        );
    }

    function _checkOwner(
        uint256 _nftId
    )
        private
        view
    {
        WISE_SECURITY.checkOwnerPosition(
            _nftId,
            msg.sender
        );
    }

    function _checkLocked(
        uint256 _nftId
    )
        private
        view
    {
        WISE_SECURITY.checkPositionLocked(
            _nftId,
            msg.sender
        );
    }

    function _checksDeposit(
        uint256 _nftId,
        address _underlyingToken,
        uint256 _depositAmount
    )
        internal
        view
    {
        WISE_SECURITY.checksDeposit(
            _nftId,
            msg.sender,
            aaveTokenAddress[_underlyingToken],
            _depositAmount
        );
    }

    function _checksWithdraw(
        uint256 _nftId,
        address _underlyingToken,
        uint256 _withdrawAmount
    )
        internal
        view
    {
        WISE_SECURITY.checksWithdraw(
            _nftId,
            msg.sender,
            aaveTokenAddress[_underlyingToken],
            _withdrawAmount
        );
    }

    function _checksBorrow(
        uint256 _nftId,
        address _underlyingToken,
        uint256 _borrowAmount
    )
        internal
        view
    {
        WISE_SECURITY.checksBorrow(
            _nftId,
            msg.sender,
            aaveTokenAddress[_underlyingToken],
            _borrowAmount
        );
    }

    function _checksSolelyWithdraw(
        uint256 _nftId,
        address _underlyingToken,
        uint256 _withdrawAmount
    )
        internal
        view
    {
        WISE_SECURITY.checksSolelyWithdraw(
            _nftId,
            msg.sender,
            aaveTokenAddress[_underlyingToken],
            _withdrawAmount
        );
    }

    function _syncPool(
        address _underlyingToken
    )
        private
    {
        WISE_LENDING.syncManually(
            aaveTokenAddress[_underlyingToken]
        );
    }

    function setWiseSecurity(
        address _securityAddress
    )
        external
        onlyMaster
    {
        WISE_SECURITY = IWiseSecurity(
            _securityAddress
        );
    }
}

abstract contract AaveHelper is Declarations {

    modifier syncPool(
        address _underlyingToken
    ) {
        if (WISE_LENDING.veryfiedIsolationPool(msg.sender) == false) {
            WISE_LENDING.preparePool(
                aaveTokenAddress[
                    _underlyingToken
                ]
            );
        }
        _;
    }

    function _prepareAssetsPosition(
        uint256 _nftId,
        address _underlyingToken
    )
        private
    {
        if (WISE_LENDING.veryfiedIsolationPool(msg.sender) == true) {
            return;
        }

        _prepareCollaterals(
            _nftId,
            aaveTokenAddress[_underlyingToken]
        );

        _prepareBorrows(
            _nftId,
            aaveTokenAddress[_underlyingToken]
        );
    }

    function _mintPosition()
        internal
        returns (uint256)
    {
        return POSITION_NFT.mintPositionForUser(
            msg.sender
        );
    }

    function _wrapDepositExactAmount(
        uint256 _nftId,
        address _underlyingAsset,
        uint256 _depositAmount,
        bool _collateralState
    )
        internal
        returns (uint256)
    {
        _prepareAssetsPosition(
            _nftId,
            _underlyingAsset
        );

        AAVE.deposit(
            _underlyingAsset,
            _depositAmount,
            address(this),
            REF_CODE
        );

        uint256 lendingShares = WISE_LENDING.depositExactAmount(
            _nftId,
            aaveTokenAddress[_underlyingAsset],
            _depositAmount,
            _collateralState
        );

        return lendingShares;
    }

    function _wrapWithdrawExactAmount(
        uint256 _nftId,
        address _underlyingAsset,
        address _underlyingAssetRecipient,
        uint256 _withdrawAmount
    )
        internal
        returns (uint256)
    {
        _prepareAssetsPosition(
            _nftId,
            _underlyingAsset
        );

        uint256 withdrawnShares = WISE_LENDING.withdrawOnBehalfExactAmount(
            _nftId,
            aaveTokenAddress[_underlyingAsset],
            _withdrawAmount
        );

        AAVE.withdraw(
            _underlyingAsset,
            _withdrawAmount,
            _underlyingAssetRecipient
        );

        return withdrawnShares;
    }

    function _wrapWithdrawExactShares(
        uint256 _nftId,
        address _underlyingAsset,
        address _underlyingAssetRecipient,
        uint256 _shareAmount
    )
        internal
        returns (uint256)
    {
        _prepareAssetsPosition(
            _nftId,
            _underlyingAsset
        );

        address aaveToken = aaveTokenAddress[
            _underlyingAsset
        ];

        uint256 withdrawAmount = WISE_LENDING.cashoutAmount(
            aaveToken,
            _shareAmount
        );

        WISE_SECURITY.checksWithdraw(
            _nftId,
            msg.sender,
            aaveToken,
            withdrawAmount
        );

        WISE_LENDING.withdrawOnBehalfExactShares(
            _nftId,
            aaveToken,
            _shareAmount
        );

        AAVE.withdraw(
            _underlyingAsset,
            withdrawAmount,
            _underlyingAssetRecipient
        );

        return withdrawAmount;
    }

    function _wrapBorrowExactAmount(
        uint256 _nftId,
        address _underlyingAsset,
        address _underlyingAssetRecipient,
        uint256 _borrowAmount
    )
        internal
        returns (uint256)
    {
        _prepareAssetsPosition(
            _nftId,
            _underlyingAsset
        );

        uint256 borrowShares = WISE_LENDING.borrowOnBehalfExactAmount(
            _nftId,
            aaveTokenAddress[_underlyingAsset],
            _borrowAmount
        );

        AAVE.withdraw(
            _underlyingAsset,
            _borrowAmount,
            _underlyingAssetRecipient
        );

        return borrowShares;
    }

    function _wrapAaveReturnValueDeposit(
        address _underlyingAsset,
        uint256 _depositAmount,
        address _targetAddress
    )
        internal
        returns (uint256 res)
    {
        IERC20 token = IERC20(
            aaveTokenAddress[_underlyingAsset]
        );

        uint256 balanceBefore = token.balanceOf(
            address(this)
        );

        AAVE.deposit(
            _underlyingAsset,
            _depositAmount,
            _targetAddress,
            REF_CODE
        );

        uint256 balanceAfter = token.balanceOf(
            address(this)
        );

        res = balanceAfter
            - balanceBefore;
    }

    function _wrapSolelyDeposit(
        uint256 _nftId,
        address _underlyingAsset,
        uint256 _depositAmount
    )
        internal
    {
        AAVE.deposit(
            _underlyingAsset,
            _depositAmount,
            address(this),
            REF_CODE
        );

        WISE_LENDING.solelyDeposit(
            _nftId,
            aaveTokenAddress[_underlyingAsset],
            _depositAmount
        );
    }

    function _wrapSolelyWithdraw(
        uint256 _nftId,
        address _underlyingAsset,
        address _underlyingAssetRecipient,
        uint256 _withdrawAmount
    )
        internal
    {
        _prepareAssetsPosition(
            _nftId,
            _underlyingAsset
        );

        WISE_LENDING.solelyWithdrawOnBehalf(
            _nftId,
            aaveTokenAddress[_underlyingAsset],
            _withdrawAmount
        );

        AAVE.withdraw(
            _underlyingAsset,
            _withdrawAmount,
            _underlyingAssetRecipient
        );
    }

    function _wrapETH(
        uint256 _value
    )
        internal
    {
        WETH.deposit{
            value: _value
        }();
    }

    function _unwrapETH(
        uint256 _value
    )
        internal
    {
        WETH.withdraw(
            _value
        );
    }

    function _getInfoPayback(
        uint256 _ethSent,
        uint256 _maxPaybackAmount
    )
        internal
        pure
        returns (
            uint256,
            uint256
        )
    {
        if (_ethSent > _maxPaybackAmount) {
            return (
                _maxPaybackAmount,
                _ethSent - _maxPaybackAmount
            );
        }

        return (
            _ethSent,
            0
        );
    }

    function _prepareCollaterals(
        uint256 _nftId,
        address _poolToken
    )
        private
    {
        uint256 i;
        uint256 l = WISE_LENDING.getPositionLendingTokenLength(
            _nftId
        );

        for (i = 0; i < l; ++i) {

            address currentAddress = WISE_LENDING.getPositionLendingTokenByIndex(
                _nftId,
                i
            );

            if (currentAddress == _poolToken) {
                continue;
            }

            WISE_LENDING.preparePool(
                currentAddress
            );

            WISE_LENDING.newBorrowRate(
                _poolToken
            );
        }
    }

    function _prepareBorrows(
        uint256 _nftId,
        address _poolToken
    )
        private
    {
        uint256 i;
        uint256 l = WISE_LENDING.getPositionBorrowTokenLength(
            _nftId
        );

        for (i = 0; i < l; ++i) {

            address currentAddress = WISE_LENDING.getPositionBorrowTokenByIndex(
                _nftId,
                i
            );

            if (currentAddress == _poolToken) {
                continue;
            }

            WISE_LENDING.preparePool(
                currentAddress
            );

            WISE_LENDING.newBorrowRate(
                _poolToken
            );
        }
    }

    function getAavePoolAPY(
        address _underlyingAsset
    )
        public
        view
        returns (uint256)
    {
        return AAVE.getReserveData(_underlyingAsset).currentLiquidityRate
            / PRECISION_FACTOR_E9;
    }
}

/**
 * @author Christoph Krpoun
 * @author René Hochmuth
 * @author Vitally Marinchenko
 */

/**
 * @dev Purpose of this contract is to optimize capital efficency by using
 * aave pools. Not borrowed funds are deposited into correspoding aave pools
 * to earn supply APY.
 *
 * The aToken are holded by the wiseLending contract but the accounting
 * is managed by the position NFTs. This is possible due to the included
 * onBehlaf functionallity inside wiseLending.
 */

contract AaveHub is AaveHelper, TransferHelper {

    constructor(
        address _master,
        address _aaveAddress,
        address _lendingAddress
    )
        Declarations(
            _master,
            _aaveAddress,
            _lendingAddress
        )
    {}

    /**
     * @dev Adds new mapping to aaveHub. Needed
     * to link underlying assets with corresponding
     * aTokens. Can only be called by master.
     */
    function setAaveTokenAddress(
        address _underlyingAsset,
        address _aaveToken
    )
        external
        onlyMaster
    {
        if (aaveTokenAddress[_underlyingAsset] > ZERO_ADDRESS) {
            revert AlreadySet();
        }

        aaveTokenAddress[_underlyingAsset] = _aaveToken;

        IERC20(_aaveToken).approve(
            address(WISE_LENDING),
            MAX_AMOUNT
        );

        IERC20(_underlyingAsset).approve(
            AAVE_ADDRESS,
            MAX_AMOUNT
        );

        emit SetAaveTokenAddress(
            _underlyingAsset,
            _aaveToken,
            block.timestamp
        );
    }

    /**
     * @dev Receive functions forwarding
     * sent ETH to the master address
     */
    receive()
        external
        payable
    {
        if (msg.sender == WETH_ADDRESS) {
            return;
        }

        payable(master).transfer(
            msg.value
        );
    }

    /**
     * @dev Allows deposit ERC20 token to
     * wiseLending and takes token amount
     * as arguement. Also mints position
     * NFT to reduce needed transactions.
     */
    function depositExactAmountMint(
        address _underlyingAsset,
        uint256 _amount,
        bool _collateralStat
    )
        external
        returns (uint256)
    {
        return depositExactAmount(
            _mintPosition(),
            _underlyingAsset,
            _amount,
            _collateralStat
        );
    }

    /**
     * @dev Allows deposit ERC20 token to
     * wiseLending and takes token amount as
     * argument.
     */
    function depositExactAmount(
        uint256 _nftId,
        address _underlyingAsset,
        uint256 _amount,
        bool _collateralState
    )
        public
        syncPool(_underlyingAsset)
        returns (uint256)
    {
        _checksDeposit(
            _nftId,
            _underlyingAsset,
            _amount
        );

        IERC20(_underlyingAsset).transferFrom(
            msg.sender,
            address(this),
            _amount
        );

        uint256 lendingShares = _wrapDepositExactAmount(
            _nftId,
            _underlyingAsset,
            _amount,
            _collateralState
        );

        emit IsDepositAave(
            _nftId,
            block.timestamp
        );

        return lendingShares;
    }

    /**
     * @dev Allows to deposit ETH token directly to
     * wiseLending and takes token amount as argument.
     * Also mints position to reduce needed transactions.
     */
    function depositExactAmountETHMint(
        bool _collateralState
    )
        external
        payable
        returns (uint256)
    {
        return depositExactAmountETH(
            _mintPosition(),
            _collateralState
        );
    }

    /**
     * @dev Allows to deposit ETH token directly to
     * wiseLending and takes token amount as argument.
     */
    function depositExactAmountETH(
        uint256 _nftId,
        bool _collateralState
    )
        public
        payable
        syncPool(WETH_ADDRESS)
        returns (uint256)
    {
        _checksDeposit(
            _nftId,
            WETH_ADDRESS,
            msg.value
        );

        _wrapETH(
            msg.value
        );

        uint256 lendingShares = _wrapDepositExactAmount(
            _nftId,
            WETH_ADDRESS,
            msg.value,
            _collateralState
        );

        emit IsDepositAave(
            _nftId,
            block.timestamp
        );

        return lendingShares;
    }

    /**
     * @dev Allows to withdraw deposited ERC20 token.
     * Takes token amount as argument.
     */
    function withdrawExactAmount(
        uint256 _nftId,
        address _underlyingAsset,
        uint256 _withdrawAmount
    )
        external
        checkOwner(_nftId)
        syncPool(_underlyingAsset)
        returns (uint256)
    {
        _checksWithdraw(
            _nftId,
            _underlyingAsset,
            _withdrawAmount
        );

        uint256 withdrawnShares = _wrapWithdrawExactAmount(
            _nftId,
            _underlyingAsset,
            msg.sender,
            _withdrawAmount
        );

        emit IsWithdrawAave(
            _nftId,
            block.timestamp
        );

        return withdrawnShares;
    }

    /**
     * @dev Allows to withdraw deposited ETH token.
     * Takes token amount as argument.
     */
    function withdrawExactAmountETH(
        uint256 _nftId,
        uint256 _withdrawAmount
    )
        external
        checkOwner(_nftId)
        syncPool(WETH_ADDRESS)
        returns (uint256)
    {
        _checksWithdraw(
            _nftId,
            WETH_ADDRESS,
            _withdrawAmount
        );

        uint256 withdrawnShares = _wrapWithdrawExactAmount(
            _nftId,
            WETH_ADDRESS,
            address(this),
            _withdrawAmount
        );

        _unwrapETH(
            _withdrawAmount
        );

        payable(msg.sender).transfer(
            _withdrawAmount
        );

        emit IsWithdrawAave(
            _nftId,
            block.timestamp
        );

        return withdrawnShares;
    }

    /**
     * @dev Allows to withdraw deposited ERC20 token.
     * Takes shares as argument.
     */
    function withdrawExactShares(
        uint256 _nftId,
        address _underlyingAsset,
        uint256 _shareAmount
    )
        external
        checkOwner(_nftId)
        syncPool(_underlyingAsset)
        returns (uint256)
    {
        uint256 withdrawAmount = _wrapWithdrawExactShares(
            _nftId,
            _underlyingAsset,
            msg.sender,
            _shareAmount
        );

        emit IsWithdrawAave(
            _nftId,
            block.timestamp
        );

        return withdrawAmount;
    }

    /**
     * @dev Allows to withdraw deposited ETH token.
     * Takes shares as argument.
     */
    function withdrawExactSharesETH(
        uint256 _nftId,
        uint256 _shareAmount
    )
        external
        checkOwner(_nftId)
        syncPool(WETH_ADDRESS)
        returns (uint256)
    {
        uint256 withdrawAmount = _wrapWithdrawExactShares(
            _nftId,
            WETH_ADDRESS,
            address(this),
            _shareAmount
        );

        _unwrapETH(
            withdrawAmount
        );

        payable(msg.sender).transfer(
            withdrawAmount
        );

        emit IsWithdrawAave(
            _nftId,
            block.timestamp
        );

        return withdrawAmount;
    }

    /**
     * @dev Allows to borrow ERC20 token from a
     * wiseLending pool. Needs supplied collateral
     * inside the same position and to approve
     * aaveHub to borrow onBehalf for the caller.
     * Takes token amount as argument.
     */
    function borrowExactAmount(
        uint256 _nftId,
        address _underlyingAsset,
        uint256 _borrowAmount
    )
        external
        checkOwner(_nftId)
        syncPool(_underlyingAsset)
        returns (uint256)
    {
        _checksBorrow(
            _nftId,
            _underlyingAsset,
            _borrowAmount
        );

        uint256 borrowShares = _wrapBorrowExactAmount(
            _nftId,
            _underlyingAsset,
            msg.sender,
            _borrowAmount
        );

        emit IsBorrowAave(
            _nftId,
            block.timestamp
        );

        return borrowShares;
    }

    /**
     * @dev Allows to borrow ETH token from
     * wiseLending. Needs supplied collateral
     * inside the same position and to approve
     * aaveHub to borrow onBehalf for the caller.
     * Takes token amount as argument.
     */
    function borrowExactAmountETH(
        uint256 _nftId,
        uint256 _borrowAmount
    )
        external
        checkOwner(_nftId)
        syncPool(WETH_ADDRESS)
        returns (uint256)
    {
        _checksBorrow(
            _nftId,
            WETH_ADDRESS,
            _borrowAmount
        );

        uint256 borrowShares = _wrapBorrowExactAmount(
            _nftId,
            WETH_ADDRESS,
            address(this),
            _borrowAmount
        );

        _unwrapETH(
            _borrowAmount
        );

        payable(msg.sender).transfer(
            _borrowAmount
        );

        emit IsBorrowAave(
            _nftId,
            block.timestamp
        );

        return borrowShares;
    }

    /**
     * @dev Allows to payback ERC20 token for
     * any postion. Takes token amount as argument.
     */
    function paybackExactAmount(
        uint256 _nftId,
        address _underlyingAsset,
        uint256 _paybackAmount
    )
        external
        syncPool(_underlyingAsset)
        checkPositionLocked(_nftId)
        returns (uint256)
    {
        address aaveToken = aaveTokenAddress[
            _underlyingAsset
        ];

        _safeTransferFrom(
            _underlyingAsset,
            msg.sender,
            address(this),
            _paybackAmount
        );

        uint256 actualAmountDeposit = _wrapAaveReturnValueDeposit(
            _underlyingAsset,
            _paybackAmount,
            address(this)
        );

        uint256 borrowSharesReduction = WISE_LENDING.paybackExactAmount(
            _nftId,
            aaveToken,
            actualAmountDeposit
        );

        emit IsPaybackAave(
            _nftId,
            block.timestamp
        );

        return borrowSharesReduction;
    }

    /**
     * @dev Allows to payback ETH token for
     * any postion. Takes token amount as argument.
     */
    function paybackExactAmountETH(
        uint256 _nftId
    )
        external
        payable
        syncPool(WETH_ADDRESS)
        checkPositionLocked(_nftId)
        returns (uint256)
    {
        address aaveWrappedETH = aaveTokenAddress[
            WETH_ADDRESS
        ];

        uint256 userBorrowShares = WISE_LENDING.getPositionBorrowShares(
            _nftId,
            aaveWrappedETH
        );

        uint256 maxPaybackAmount = WISE_LENDING.paybackAmount(
            aaveWrappedETH,
            userBorrowShares
        );

        (
            uint256 paybackAmount,
            uint256 ethRefundAmount

        ) = _getInfoPayback(
            msg.value,
            maxPaybackAmount
        );

        _wrapETH(
            paybackAmount
        );

        uint256 actualAmountDeposit = _wrapAaveReturnValueDeposit(
            WETH_ADDRESS,
            paybackAmount,
            address(this)
        );

        uint256 borrowSharesReduction = WISE_LENDING.paybackExactAmount(
            _nftId,
            aaveWrappedETH,
            actualAmountDeposit
        );

        if (ethRefundAmount > 0) {
            payable(msg.sender).transfer(
                ethRefundAmount
            );
        }

        emit IsPaybackAave(
            _nftId,
            block.timestamp
        );

        return borrowSharesReduction;
    }

    /**
     * @dev Allows to payback ERC20 token for
     * any postion. Takes shares as argument.
     */
    function paybackExactShares(
        uint256 _nftId,
        address _underlyingAsset,
        uint256 _shares
    )
        external
        syncPool(_underlyingAsset)
        checkPositionLocked(_nftId)
        returns (uint256)
    {
        address aaveToken = aaveTokenAddress[
            _underlyingAsset
        ];

        uint256 paybackAmount = WISE_LENDING.paybackAmount(
            aaveToken,
            _shares
        );

        _safeTransferFrom(
            _underlyingAsset,
            msg.sender,
            address(this),
            paybackAmount
        );

        AAVE.deposit(
            _underlyingAsset,
            paybackAmount,
            address(this),
            REF_CODE
        );

        WISE_LENDING.paybackExactShares(
            _nftId,
            aaveToken,
            _shares
        );

        emit IsPaybackAave(
            _nftId,
            block.timestamp
        );

        return paybackAmount;
    }

    /**
     * @dev Allows to deposit ERC20 token in
     * private mode. These funds are saved from
     * borrowed out. User can withdraw private funds
     * anytime even the pools are empty. Private funds
     * don't earn any APY! Also a postion NFT is minted
     * to reduce transactions.
     */
    function solelyDepositMint(
        address _underlyingAsset,
        uint256 _depositAmount
    )
        external
    {
        solelyDeposit(
            _mintPosition(),
            _underlyingAsset,
            _depositAmount
        );
    }

    /**
     * @dev Allows to deposit ERC20 token in
     * private mode. These funds are saved from
     * borrowing by other users. User can withdraw
     * private funds anytime even the pools are empty.
     * Private funds don't earn any APY!
     */
    function solelyDeposit(
        uint256 _nftId,
        address _underlyingAsset,
        uint256 _depositAmount
    )
        public
        syncPool(_underlyingAsset)
    {
        _checksDeposit(
            _nftId,
            _underlyingAsset,
            _depositAmount
        );

        _safeTransferFrom(
            _underlyingAsset,
            msg.sender,
            address(this),
            _depositAmount
        );

        _wrapSolelyDeposit(
            _nftId,
            _underlyingAsset,
            _depositAmount
        );

        emit IsSolelyDepositAave(
            _nftId,
            block.timestamp
        );
    }

    /**
     * @dev Allows to withdraw ERC20 token from
     * private mode.
     */
    function solelyWithdraw(
        uint256 _nftId,
        address _underlyingAsset,
        uint256 _withdrawAmount
    )
        external
        checkOwner(_nftId)
        syncPool(_underlyingAsset)
    {
        _checksSolelyWithdraw(
            _nftId,
            _underlyingAsset,
            _withdrawAmount
        );

        _wrapSolelyWithdraw(
            _nftId,
            _underlyingAsset,
            msg.sender,
            _withdrawAmount
        );

        emit IsSolelyWithdrawAave(
            _nftId,
            block.timestamp
        );
    }

    /**
     * @dev Allows to deposit ETH token in
     * private mode. These funds are saved from
     * borrowing by other users. User can withdraw
     * private funds anytime even the pools are empty.
     * Private funds don't earn any APY! Also a position
     * NFT is minted to reduce transactions.
     */
    function solelyDepositETHMint()
        external
        payable
    {
        solelyDepositETH(
            _mintPosition()
        );
    }

    /**
     * @dev Allows to deposit ETH token in
     * private mode. These funds are saved from
     * borrowing by other users. User can withdraw
     * private funds anytime even the pools are empty.
     * Private funds don't earn any APY!
     */
    function solelyDepositETH(
        uint256 _nftId
    )
        public
        payable
        syncPool(WETH_ADDRESS)
    {
        _checksDeposit(
            _nftId,
            WETH_ADDRESS,
            msg.value
        );

        _wrapETH(
            msg.value
        );

        _wrapSolelyDeposit(
            _nftId,
            WETH_ADDRESS,
            msg.value
        );

        emit IsSolelyDepositAave(
            _nftId,
            block.timestamp
        );
    }

    /**
     * @dev Allows to withdraw ETH token from
     * private mode.
     */
    function solelyWithdrawETH(
        uint256 _nftId,
        uint256 _withdrawAmount
    )
        external
        checkOwner(_nftId)
        syncPool(WETH_ADDRESS)
    {
        _checksSolelyWithdraw(
            _nftId,
            WETH_ADDRESS,
            _withdrawAmount
        );

        _wrapSolelyWithdraw(
            _nftId,
            WETH_ADDRESS,
            address(this),
            _withdrawAmount
        );

        _unwrapETH(
            _withdrawAmount
        );

        payable(msg.sender).transfer(
            _withdrawAmount
        );

        emit IsSolelyWithdrawAave(
            _nftId,
            block.timestamp
        );
    }

    /**
     * @dev View functions returning the combined rate
     * from aave supply APY and wiseLending borrow APY
     * of a pool.
     */
    function getLendingRate(
        address _underlyingAssert
    )
        external
        view
        returns (uint256)
    {
        address aToken = aaveTokenAddress[
            _underlyingAssert
        ];

        uint256 lendingRate = WISE_SECURITY.getLendingRate(
            aToken
        );

        uint256 aaveRate = getAavePoolAPY(
            _underlyingAssert
        );

        uint256 pseudoPool = WISE_LENDING.getPseudoTotalPool(
            aToken
        );

        uint256 pseudoBorrow = WISE_LENDING.getPseudoTotalBorrowAmount(
            aToken
        );

        uint256 balanceAToken = IERC20(aToken).balanceOf(
            address(WISE_LENDING)
        );

        uint256 increaseToken = (
            lendingRate
            * pseudoBorrow
            + aaveRate
            * balanceAToken
        );

        return increaseToken
            / pseudoPool;
    }
}