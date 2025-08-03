// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title IPoolAddressesProvider
 * @notice Defines the basic interface for a Pool Addresses Provider.
 */
interface IPoolAddressesProvider {
    function getPool() external view returns (address);
}

/**
 * @title FlashLoanSimpleReceiverBase
 * @notice Base contract to develop a flashloan-receiver contract.
 */
abstract contract FlashLoanSimpleReceiverBase {
    IPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
    IPool public immutable POOL;

    constructor(IPoolAddressesProvider provider) {
        ADDRESSES_PROVIDER = provider;
        POOL = IPool(provider.getPool());
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external virtual returns (bool);
}

/**
 * @title IPool
 * @notice Basic interface for Aave pool interactions.
 */
interface IPool {
    function flashLoanSimple(
        address receiverAddress,
        address asset,
        uint256 amount,
        bytes calldata params,
        uint16 referralCode
    ) external;
}


interface ICurvePool {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
}

interface IMetaStreet {
    function redeem(uint128 tick, uint256 shares) external returns (uint128);
    function withdraw(uint128 tick, uint128 redemptionId) external returns (uint256, uint256);
}

contract FlashLoan is FlashLoanSimpleReceiverBase {
    address payable owner;

    address public TOKEN_MWSTKETH_ADDRESS_40 = 0xC272B96bCcdaf1BF98F2197D355066Da3C15982a;
    address public TOKEN_MWSTKETH_ADDRESS_20 = 0xC975342A95cCb75378ddc646B8620fa3Cd5bc051;

    address public CONTRACT_CURVE_POOL_40_ADDRESS = 0x2A7f617AF3009578021473a88A7c5a2aF5aACd79;
    address public CONTRACT_CURVE_POOL_20_ADDRESS = 0xFE3C78D947b329160496E192b4Cf417bB86272Ed;

    address public CONTRACT_METASTREET_ADDRESS = 0xC0874B4B9a1BaE857B054936167F8Ef79257A757;

    bool private forToken40;

    constructor(address _addressProvider)
        FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider))
    {
        owner = payable(msg.sender);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {

        initiateCurveSwap(1,0, amount, asset);

        uint128 tick = 10240000000000000000032;
        uint256 mwstkEthBalance = 0;

        if (forToken40) {
            mwstkEthBalance = IERC20(TOKEN_MWSTKETH_ADDRESS_40).balanceOf(address(this));
            IERC20(TOKEN_MWSTKETH_ADDRESS_40).approve(CONTRACT_METASTREET_ADDRESS, mwstkEthBalance);
        } else {
            mwstkEthBalance = IERC20(TOKEN_MWSTKETH_ADDRESS_20).balanceOf(address(this));
            tick = 5120000000000000000032;
            IERC20(TOKEN_MWSTKETH_ADDRESS_20).approve(CONTRACT_METASTREET_ADDRESS, mwstkEthBalance);
        }

        if (mwstkEthBalance > 0) {
            uint128 redemptionId = redeemMwstkEtkTokensOnMetaStreetContract(tick, mwstkEthBalance);
            withdrawFromMetaStreet(tick, redemptionId);
        }

        uint256 amountOwed = amount + premium;
        IERC20(asset).approve(address(POOL), amountOwed);

        return true;
    }

    function requestFlashLoan(address _token, uint256 _amount, bool _forToken40) public {
        forToken40 = _forToken40;

        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function initiateCurveSwap(int128 i, int128 j, uint256 amount, address asset) internal {
        uint min_dy = amount;

        if (forToken40) {
            IERC20(asset).approve(CONTRACT_CURVE_POOL_40_ADDRESS, amount);
            ICurvePool(CONTRACT_CURVE_POOL_40_ADDRESS).exchange(i, j, amount, min_dy);
        } else {
            IERC20(asset).approve(CONTRACT_CURVE_POOL_20_ADDRESS, amount);
            ICurvePool(CONTRACT_CURVE_POOL_20_ADDRESS).exchange(i, j, amount, min_dy);
        }
    }

    function redeemMwstkEtkTokensOnMetaStreetContract(uint128 tick, uint256 shares) internal returns (uint128) {
        return IMetaStreet(CONTRACT_METASTREET_ADDRESS).redeem(tick, shares);
    }

    function withdrawFromMetaStreet(uint128 tick, uint128 redemptionId) internal {
        (uint256 amountBurned, uint256 amountWithdrawn) = IMetaStreet(CONTRACT_METASTREET_ADDRESS).withdraw(tick, redemptionId);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    receive() external payable {}
}