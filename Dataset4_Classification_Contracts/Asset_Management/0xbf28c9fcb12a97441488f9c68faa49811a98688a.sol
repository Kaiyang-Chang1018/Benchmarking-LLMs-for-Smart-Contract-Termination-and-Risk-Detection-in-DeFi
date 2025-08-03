// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.25;

interface ILRTDepositPool {
    function depositAsset(
        address asset,
        uint256 depositAmount,
        uint256 minRSETHAmountExpected,
        string calldata referralId
    ) external;

    function depositETH(uint256 minRSETHAmountExpected, string calldata referralId) external payable;

    function getRsETHAmountToMint(address asset, uint256 depositAmount) external view returns (uint256);
}

interface IERC4626 {
    function deposit(uint256 assets, address receiver) external;
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

/// @title RSETHAdapter
/// @notice This contract facilitates the minting of RSETH using either ETH or ERC20 assets and deposits the minted RSETH into a vault on behalf of the user.
contract RSETHAdapter {
    ILRTDepositPool public immutable lrtDepositPool;
    IERC4626 public immutable vault;
    IERC20 public immutable rsETH;

    event RSETHMintedAndDepositedInVault(address indexed user, uint256 rsETHAmount, string refferalId);

    /// @notice Constructs the RSETHAdapter contract.
    /// @param _lrtDepositPool Address of the LRTDepositPool contract.
    /// @param _vault Address of the Vault contract.
    /// @param _rsETH Address of the RSETH token contract.
    constructor(ILRTDepositPool _lrtDepositPool, IERC4626 _vault, IERC20 _rsETH) {
        lrtDepositPool = _lrtDepositPool;
        vault = _vault;
        rsETH = _rsETH;
    }

    /// @notice deposit rsETH directly to the vault
    /// @param rsETHAmount Amount of rsETH to deposit
    /// @param referralId Referral ID for the deposit.
    function depositRsETH(uint256 rsETHAmount, string calldata referralId) external {
        rsETH.transferFrom(msg.sender, address(this), rsETHAmount);
        _depositRSETHInVaultForUser(referralId);
    }

    /// @notice Mints RSETH using ETH and deposits it into the vault for the user.
    /// @param referralId Referral ID for the deposit.
    function getRSETHWithETH(string calldata referralId) external payable {
        address kelpDaoETHAssetId = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        uint256 minRSETHAmountExpected = lrtDepositPool.getRsETHAmountToMint(kelpDaoETHAssetId, msg.value);

        lrtDepositPool.depositETH{value: msg.value}(minRSETHAmountExpected, referralId);

        _depositRSETHInVaultForUser(referralId);
    }

    /// @notice Mints RSETH using an ERC20 asset accepted by Kelp and deposits it into the vault for the user.
    /// @dev The user must approve the RSETHAdapter contract to spend the ERC20 asset.
    /// @dev it will revert if the asset is not allowed to be deposited in Kelp LRTDepositPool.
    /// @param asset Address of the ERC20 asset to be deposited.
    /// @param depositAmount Amount of the ERC20 asset to be deposited.
    /// @param referralId Referral ID for the deposit.
    function getRSETHWithERC20(address asset, uint256 depositAmount, string calldata referralId) external {
        IERC20(asset).transferFrom(msg.sender, address(this), depositAmount);
        uint256 minRSETHAmountExpected = lrtDepositPool.getRsETHAmountToMint(asset, depositAmount);

        IERC20(asset).approve(address(lrtDepositPool), depositAmount);

        lrtDepositPool.depositAsset(asset, depositAmount, minRSETHAmountExpected, referralId);

        _depositRSETHInVaultForUser(referralId);
    }

    /// @notice Deposits the minted RSETH into the vault for the user.
    function _depositRSETHInVaultForUser(string calldata referralId) private {
        uint256 rsETHAmountMinted = rsETH.balanceOf(address(this));
        rsETH.approve(address(vault), rsETHAmountMinted);
        vault.deposit(rsETHAmountMinted, msg.sender);

        emit RSETHMintedAndDepositedInVault(msg.sender, rsETHAmountMinted, referralId);
    }
}