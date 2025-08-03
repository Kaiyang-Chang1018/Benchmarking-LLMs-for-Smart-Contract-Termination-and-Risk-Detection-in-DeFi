pragma solidity ^0.8.20;

import "./base/BaseEscrow.sol";

contract ForgeEscrow is BaseEscrow {
    constructor(
        address _superAdmin,
        address _vault,
        uint256 _totalSupply
    ) BaseEscrow(_superAdmin, _vault, _totalSupply) {}

    /// @dev Number of co-founder reserved mints.
    uint8 public coFounderMintLimit = 1;

    /// @dev strictly for co-founder initial mint.
    uint256 public coFounderPrice = 0.55 ether;

    /**
     * @dev Allows NFT contract to clear the reserved amount for an address
     *
     * @param _account Address to check
     */
    function claimFor(address _account) external override onlyNftContract {
        /// @dev this is a redundent check but it is here for safety
        require(nftContract != address(0), "ESCROW: NFT contract not set.");
        require(
            nftReserveAmount[_account].publicReserved > 0 ||
                nftReserveAmount[_account].coFounderReserved > 0,
            "ESCROW: No nft reserved for account."
        );

        nftReserveAmount[_account].price = 0;
        nftReserveAmount[_account].publicReserved = 0;
        nftReserveAmount[_account].coFounderReserved = 0;
    }

    /**
     * @dev Allows NFT contract to set the escrow state to claim state.
     */
    function setClaim() external onlyNftContract {
        state = EscrowState.CLAIM;
    }

    /**
     * @dev Allows NFT contract to set the escrow state to pending state.
     */
    function setPending() external onlyNftContract {
        state = EscrowState.ESCROW;
    }

    /**
     * @dev Allows admin to withdraw funds into vault
     *
     */
    function withdrawETH() external onlyAdmin {
        require(
            address(this).balance > 0,
            "ESCROW: No eth balance to withdraw."
        );
        require(
            state == EscrowState.CLAIM,
            "ESCROW: Withdraw only allowed in claim state."
        );

        payable(vault).transfer(address(this).balance);
    }

    /**
     * @dev Allows admin to update co-founder price.
     *
     * @param _coFounderPrice New co-founder price.
     */
    function updateCoFounderPrice(uint256 _coFounderPrice) external onlyAdmin {
        coFounderPrice = _coFounderPrice;
    }

    /**
     * @dev Allows super admin to update co-founder mint limit.
     *
     * @param _coFounderMintLimit Mint limit.
     */
    function updateCoFounderMintLimit(
        uint8 _coFounderMintLimit
    ) external onlyAdmin {
        coFounderMintLimit = _coFounderMintLimit;
    }

    /**
     * @dev Emergency function to allow claimers to refund their reserved amount.
     */
    function setRefunded() external onlySuperAdmin {
        state = EscrowState.REFUND;
    }

    /**
     * Reserve mint NFT for whitelisted addresses, differentiating between co-founder and normal NFTs
     *
     * @param _amount amount to reserve
     */
    function reserveMint(
        uint256 _amount
    ) external payable override notPaused onlyWhitelisted {
        uint256 expectedPrice = calculatePrice(_amount, msg.sender);
        uint256 mintsAllowed = calculateMintsAllowed(msg.sender);

        require(
            msg.value == expectedPrice,
            "ESCROW: Incorrect ETH value sent."
        );
        require(
            _amount <= mintsAllowed,
            "ESCROW: Max nft per address reached."
        );
        require(
            reservedSupply + _amount <= totalSupply,
            "ESCROW: Quantity goes above total supply."
        );

        uint256 coFounderNfts = 0;

        if (
            nftReserveAmount[msg.sender].coFounderReserved <
            coFounderMintLimit &&
            whitelist[msg.sender]
        ) {
            coFounderNfts =
                coFounderMintLimit -
                nftReserveAmount[msg.sender].coFounderReserved;
            if (coFounderNfts > _amount) {
                coFounderNfts = _amount;
            }
        }

        reservedSupply += _amount;

        nftReserveAmount[msg.sender].publicReserved += (_amount -
            coFounderNfts);
        nftReserveAmount[msg.sender].coFounderReserved += coFounderNfts;
        nftReserveAmount[msg.sender].price += msg.value;

        emit NftReserved(msg.sender, _amount);
    }

    /**
     * @dev Emergency trustless functio to allow caller to refund their reserved amount.
     */
    function refund(address _address) external {
        require(
            state == EscrowState.REFUND,
            "ESCROW: Refund only allowed in refund state."
        );
        require(
            nftReserveAmount[_address].publicReserved > 0 ||
                nftReserveAmount[_address].coFounderReserved > 0,
            "ESCROW: No nft reserved for account."
        );

        uint256 refundAmount = nftReserveAmount[_address].price;

        nftReserveAmount[_address].publicReserved = 0;
        nftReserveAmount[_address].coFounderReserved = 0;
        nftReserveAmount[_address].price = 0;

        payable(_address).transfer(refundAmount);
    }

    /**
     * @dev Allows admins to set a reserved amount for an address
     *
     * @notice The value of the reserved amount will affect the total supply.
     *
     * @param _to Address to set reserve for
     * @param _newPublicAmount New reserve amount for the address
     * @param _newCoFounderAmount New co-founder reserve amount for the address
     */
    function adminReserveMint(
        address _to,
        uint256 _newPublicAmount,
        uint256 _newCoFounderAmount
    ) external override onlyAdmin {
        uint256 currentPublicAmount = nftReserveAmount[_to].publicReserved;
        uint256 currentCoFounderAmount = nftReserveAmount[_to]
            .coFounderReserved;

        require(
            currentPublicAmount != _newPublicAmount ||
                currentCoFounderAmount != _newCoFounderAmount,
            "ESCROW: No change in amount."
        );

        uint256 totalNewAmount = _newPublicAmount + _newCoFounderAmount;
        uint256 totalCurrentAmount = currentPublicAmount +
            currentCoFounderAmount;

        if (totalNewAmount > totalCurrentAmount) {
            uint256 additionalAmount = totalNewAmount - totalCurrentAmount;

            require(
                reservedSupply + additionalAmount <= totalSupply,
                "ESCROW: New amount exceeds max limit."
            );

            reservedSupply += additionalAmount;
        } else if (totalCurrentAmount > totalNewAmount) {
            uint256 reductionAmount = totalCurrentAmount - totalNewAmount;

            reservedSupply -= reductionAmount;
        }

        nftReserveAmount[_to].publicReserved = _newPublicAmount;
        nftReserveAmount[_to].coFounderReserved = _newCoFounderAmount;

        emit NftReserved(_to, totalNewAmount);
    }

    /**
     * @dev Calculates allowed mints in total.
     *
     * @notice This will not take into account the current amount minted.
     *
     * @param _account Address of the account
     */
    function calculateMintsAllowed(
        address _account
    ) public view returns (uint256) {
        uint256 alreadyMintedNfts = nftReserveAmount[_account].publicReserved +
            nftReserveAmount[_account].coFounderReserved;

        if (whitelist[_account]) {
            uint256 whitelistedLimit = maxNftPerAddress + coFounderMintLimit;

            return
                (whitelistedLimit > alreadyMintedNfts)
                    ? (whitelistedLimit - alreadyMintedNfts)
                    : 0;
        }

        return
            (maxNftPerAddress > alreadyMintedNfts)
                ? (maxNftPerAddress - alreadyMintedNfts)
                : 0;
    }

    /**
     *  This function will help determine the price of the nft based on their role and what they've already minted as a co-founder
     *
     * @param _amount quantity of nfts
     * @param _account  address of the account
     */
    function calculatePrice(
        uint256 _amount,
        address _account
    ) public view returns (uint256) {
        if (
            !whitelist[_account] ||
            nftReserveAmount[_account].coFounderReserved >= coFounderMintLimit
        ) {
            return _amount * nftPrice;
        }

        uint256 coFounderEligibleAmount = coFounderMintLimit -
            nftReserveAmount[_account].coFounderReserved;

        if (coFounderEligibleAmount > _amount) {
            coFounderEligibleAmount = _amount;
        }

        uint256 coFounderTotalPrice = coFounderEligibleAmount * coFounderPrice;

        uint256 standardAmount = _amount - coFounderEligibleAmount;
        uint256 standardTotalPrice = standardAmount * nftPrice;

        return coFounderTotalPrice + standardTotalPrice;
    }
}
pragma solidity ^0.8.20;

import "../interfaces/IEscrow.sol";

abstract contract BaseEscrow is IEscrow {
    /// @dev The super admin address.
    address public superAdmin;

    /// @dev The vault address that will be storing the funds
    address public vault;

    /// @dev total supply
    uint256 public totalSupply;

    /// @dev max nft per address
    uint256 public maxNftPerAddress;

    constructor(address _superAdmin, address _vault, uint256 _totalSupply) {
        superAdmin = _superAdmin;
        vault = _vault;
        totalSupply = _totalSupply;
    }

    ///@dev nft contract address - this will be 0 during the presale
    address public nftContract;

    /// @dev if the mint is restricted to only whitelisted addresses
    bool public restrictedMint = true;

    /// @dev paused state of the contract
    bool public paused = false;

    /// @dev reserved supply
    uint256 public reservedSupply;

    /// @dev nft price
    uint256 public nftPrice = 0.050 ether;

    /// @dev escrow state
    EscrowState public state = EscrowState.ESCROW;

    /// @dev Mapping of whitelisted addresses.
    mapping(address => bool) public whitelist;

    /// @dev Mapping of admin addresses.
    mapping(address => bool) public admin;

    /// @dev Mapping of nfts reserved.
    mapping(address => NftReserve) public nftReserveAmount;

    /// @dev Checks if sender is admin.
    modifier onlyAdmin() {
        require(
            admin[msg.sender] || msg.sender == superAdmin,
            "ESCROW: only admin"
        );
        _;
    }

    /// @dev Checks if sender is super admin.
    modifier onlySuperAdmin() {
        require(msg.sender == superAdmin, "ESCROW: only super admin");
        _;
    }

    /// @dev Checks if sender is whitelisted.
    modifier onlyWhitelisted() {
        if (restrictedMint) {
            require(whitelist[msg.sender], "ESCROW: only whitelisted");
        }
        _;
    }

    /// @dev Checks if sender is nft contract.
    modifier onlyNftContract() {
        require(msg.sender == nftContract, "ESCROW: only nft contract");
        _;
    }

    /// @dev Checks if contract is not paused.
    modifier notPaused() {
        require(!paused, "ESCROW: paused");
        _;
    }

    /**
     * Allows super admin to update escrow price.
     *
     * @param _nftPrice New escrow price.
     */
    function updateNftPrice(uint256 _nftPrice) external onlySuperAdmin {
        nftPrice = _nftPrice;
    }

    /**
     * @dev Allows super admin to toggle an admin account
     *
     * @param _account The address to be marked as admin
     */
    function toggleAdminStatus(
        address _account
    ) external override onlySuperAdmin {
        admin[_account] = !admin[_account];
    }

    /**
     * @dev Allows admin to toggle mint restriction
     */
    function toggleMintRestriction() external onlyAdmin {
        restrictedMint = !restrictedMint;
    }

    /**
     * @dev Allows admin to update total supply
     *
     * @param _totalSupply total supply of escrow.
     */
    function updateTotalSupply(uint256 _totalSupply) external onlyAdmin {
        totalSupply = _totalSupply;
    }

    /**
     * @dev Allows admin to toggle whitelist
     *
     * @param _account The address to be toggled
     */
    function toggleWhitelist(address _account) external override onlyAdmin {
        whitelist[_account] = !whitelist[_account];
    }

    /**
     *  @dev Allows admin to batch whitelist addresses
     *
     * @param _accounts array of addresses to be whitelisted
     */
    function batchWhitelist(address[] calldata _accounts) external onlyAdmin {
        for (uint256 i = 0; i < _accounts.length; i++) {
            whitelist[_accounts[i]] = true;
        }
    }

    /**
     * @dev Allows super admin to update vault address.
     *
     * @param _vault The new vault address.
     */
    function updateVault(address _vault) external override onlySuperAdmin {
        vault = _vault;
    }

    /**
     * @dev Allows super admin to update nft contract address.
     *
     * @param _nftContract The new nft contract address.
     */
    function updateNftContract(
        address _nftContract
    ) external override onlySuperAdmin {
        nftContract = _nftContract;
    }

    /**
     * @dev Allows admins to toggle paused status
     */
    function togglePaused() external onlyAdmin {
        paused = !paused;
    }

    /**
     * Allows admins to set a wallet limit.
     *
     * @param _limit The new limit.
     */
    function setLimitPerWallet(uint256 _limit) external onlyAdmin {
        maxNftPerAddress = _limit;
    }

    /**
     * Allows super admin to renounce super admin role to another.
     *
     * @param _superAdmin The new super admin address.
     */
    function renounceSuperAdmin(address _superAdmin) external onlySuperAdmin {
        superAdmin = _superAdmin;
    }
}
pragma solidity ^0.8.20;

interface IEscrow {
    ///@dev Event emiited when nft is reserved
    event NftReserved(address indexed to, uint256 amount);

    /// @dev Event emitted when whitelist is toggled.
    event WhitelistToggled(address indexed account);

    enum EscrowState {
        ESCROW,
        CLAIM,
        REFUND
    }

    struct NftReserve {
        uint256 publicReserved;
        uint256 coFounderReserved;
        uint256 price;
    }

    function claimFor(address _account) external;

    function toggleWhitelist(address _account) external;

    function toggleAdminStatus(address _account) external;

    function updateNftContract(address _nftContract) external;

    function updateVault(address _vault) external;

    function reserveMint(uint256 _amount) external payable;

    function adminReserveMint(
        address _to,
        uint256 _amount,
        uint256 coFounderAmount
    ) external;
}