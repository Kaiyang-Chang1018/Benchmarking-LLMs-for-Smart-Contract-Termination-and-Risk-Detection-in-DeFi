// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable-next-line interface-starts-with-i
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// *************************************************************************/
//       					⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢤⣀⠀⡀⠀⠀⠀⠀⠀⠀⠀
//       					⠀⠀⠀⠀⠀⠀⠀⠀⣤⠀⠀⠀⠀⠀⠀⠀⠀⢠⣖⠒⠛⠉⣻⣿⣶⡆⠀⠀⠀⠀⠀
//       					⠀⠀⠀⠀⠀⠀⠀⠸⢻⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣀⣠⢾⢿⣿⣿⠁⠀⠀⠀⠀⠀
//       					⠀⠀⠀⠀⠀⠀⠀⠇⠸⡀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⢸⠈⠙⢺⠉⠳⡀⠀⠀⠀⠀
//       					⠀⠀⢸⣆⠀⠀⠀⢰⡀⡳⠒⠀⠒⢬⡻⣦⡀⠀⠀⠀⠀⡇⠀⢸⠀⣷⡽⠀⠀⠀⠀
//       					⡀⠀⠈⣯⠶⠒⠀⠉⣹⠀⢀⡴⠲⢄⠙⢿⢳⡀⠀,*⢦⠀⠈⠓⠁⠈⠢⡀⠀⠀
//       					⠸⣤⠞⠓⠲⢭⣉⣉⡇⡰⠋⠀⠀⠈⢣⠈⡆/' |⡞⢀⡀⡀⣠⠀⡄⢼⣦⠀
//       					⠀⠹⢍⡙⠉⠉⣥⡤⡿⢁⣴⠊⠉⢳⠈⢇/   :⣿⣿⣷⢷⠟⢦⡟⢾⣿⡆
//       					⠀⠀⠀⡸⠋⠀⢉⠟⢋⠟⠁⠀⣀.--'   /⠀⢸⠀⠀⠀⠀⠀⠀⡇⠀
//       					⠀⢀⡜⠁⢀⡴⢃⣴⠋⢀⠖⠉⠀\v    /\/⠀⠀⢸⠀⠀⠀⠀⢀⡼⠀⠀
//       					⠙⢯⣀⠴⣹⢡⣾⠃⢰⠃⠀⢀⡴/ :  /__\⣤⢸⠀⠀⠀⢀⠞⠀⠀⠀
//       					⠀⠀⠀⢠⣷⢃⠇⠀⣿⠀⢠⠋_/    /⠴⠴⠹⡞⠀⢀⠔⠁⠀⠀⠀⠀
//       					⠀⠀⠀⣼⠃⡸⠀⢸⢹⢠⡇⠀)'-. /⣶⢀⣰⡷⣣⠞⠁⠀⠀⠀⠀⠀⠀
//       					⠀⠀⠀⠋⠀⡇⠀⡆⢸⣸⡇⠀./  :\⢿⡋⠘⡖⠁⠀⠀⠀⠀⠀⠀⠀⠀
//       					⠀⠀⠀⠀⡼⢀⡼⠀⠈⣿⢱⠀⠈/.' '⡆⡿⣦⣟⣂⠰⠾⣭⣩⣷⣤⣀⠀
//       					⠀⠀⠀⠾⠓⠋⠀⠀⠀⠙⠀'/'⠀⠀⠀⠀⡿⠀⠀⠁⠀⠀⠘⠋⠁⢹⡏⢻⡇
//       					⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀+⡆⠀⠀⠀⠀⡇⡆⠀⠀⠀⠀⠀⠀⠀⠘⠃⠈⠀
//       					⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀'⠀⠀⠀⠀⢀⣠⠇⠘⢢⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
//       							`.
//       						.-"-		_____			______	______
//       						(    |		| __|   ______ 	|  _  | |  _  |
//       					. .-'  '.		| |		|  _  |	| | | | | |_| |
//       					( (.   )8:		| |__	| |_| |	| |_| |	|  ___|
//       				.'    / (_  )		|____|	|_____|	|_____|	|_|
//       				_. :(.   )8P  `
//       			.  (  `-' (  `.   .
//       				.  :  (   .a8a)
//       			/_`( "a `a. )"'
//       		(  (/  .  ' )=='
//       		(   (    )  .8"   +
//       			(`'8a.( _(   (
//       		..-. `8P    ) `  )  +
//       	-'   (      -ab:  )
//       	'    _  `    (8P"Ya
//       _(    (    )b  -`.  ) +
//       ( 8)  ( _.aP" _a   \( \   *
//       +  )/    (8P   (88    )  )
//       (a:f   "     `"`
//
// *************************************************************************/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract LTDPresale {
    AggregatorV3Interface internal SHIB_ETH_Feed;
    AggregatorV3Interface internal ETH_USD_Feed;

    uint MAX_TOTAL = 25000000000;
    uint MAX_WALLET =  250000000;
    uint MIN_ENTRY =    50000000;
    uint raisedValue = 0;

    mapping(address => Commit[]) PreSaleCommits;
    address[] committedWallets;

    struct Commit {
        address wa;
        string currency;
        uint qty;
        uint USDValue;
    }

    struct ExportData {
        address wallet;
        uint totalUSDValue;
    }
    
    address adminWallet = 0x5E2614e1965640d7760324Cf9E7F138EA091AC4C;
    address ownerWallet = 0x75d9df1efe6d860218AFCF5c688F3DAd61638d83;

    address presaleWallet = 0x8ef3782e967DB943233bE4f09D67d4fd51EA0102;

    IERC20 internal constant ERC20_Shib =
        IERC20(0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE);

    IERC20 internal constant ERC20_USDT =
        IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    IERC20 internal constant ERC20_USDC =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);


    event PreSaleCommit(
        address indexed buyer,
        uint usdValue
    );

    constructor() { 
        SHIB_ETH_Feed = AggregatorV3Interface(0x8dD1CD88F43aF196ae478e91b9F5E4Ac69A97C61);
        ETH_USD_Feed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }

    function addCommitForValue(uint qty, string calldata currency) public payable {
        uint i = 0;
        uint walletCommit = 0;
        uint usdValue = 0;

        while (i < PreSaleCommits[msg.sender].length) {
            walletCommit = walletCommit + PreSaleCommits[msg.sender][i].USDValue;
            i++;
        }

        bytes32 inputHash = keccak256(abi.encodePacked(currency));

        if (inputHash == keccak256(abi.encodePacked("SHIB"))) {
            usdValue = getUSDValue(qty, currency);
            require(ERC20_Shib.balanceOf(msg.sender) >= qty, "nsf");
            ERC20_Shib.transferFrom(msg.sender, presaleWallet, qty);

        } else if (inputHash == keccak256(abi.encodePacked("USDC"))) {
            usdValue = qty; // USDC uses 6 decimals
            require(ERC20_USDC.balanceOf(msg.sender) >= qty, "nsf");
            ERC20_USDC.transferFrom(msg.sender, presaleWallet, qty);

        } else if (inputHash == keccak256(abi.encodePacked("USDT"))) {
            usdValue = qty; // USDT uses 6 decimals
            require(ERC20_USDT.balanceOf(msg.sender) >= qty, "nsf");
            ERC20_USDT.transferFrom(msg.sender, presaleWallet, qty);

        } else if (inputHash == keccak256(abi.encodePacked("ETH"))) {
            usdValue = getUSDValue(qty, currency);
            require(msg.value >= qty, "nsf"); // ETH uses 18 decimals
            (bool success, ) = presaleWallet.call{value: qty}("");
            require(success, "Transfer failed.");

        } else {
            revert("Invalid Currency");
        }

        require(usdValue + walletCommit <= MAX_WALLET, "Pre-Sale Wallet Limit Reached");
        require(usdValue >= MIN_ENTRY, "Min $50 Required");
        addCommit(msg.sender, currency, qty, usdValue);
    }

    function addCommit(address wa, string memory currency, uint qty, uint256 usdValue) private {
        require(usdValue + raisedValue <= MAX_TOTAL, "Pre-Sale Total Limit Reached");

        Commit memory c = Commit(
            msg.sender,
            currency,
            qty,
            usdValue
        );

        raisedValue = raisedValue + usdValue;
        PreSaleCommits[msg.sender].push(c);

        bool isAlreadyCommitted = false;
        for (uint i = 0; i < committedWallets.length; i++) {
            if (committedWallets[i] == wa) {
                isAlreadyCommitted = true;
                break;
            }
        }
        if (!isAlreadyCommitted) {
            committedWallets.push(wa);
        }

        emit PreSaleCommit(wa, usdValue);
    }    

    function getWalletCommits(address wa) public view returns(Commit[] memory) {
        if (wa != msg.sender) {
            require(msg.sender == adminWallet || msg.sender == ownerWallet);
        }
    
        uint count = PreSaleCommits[wa].length;

        Commit[] memory returnCommits = new Commit[](count);
        for (uint i = 0; i < count; i++) {
            returnCommits[i] = PreSaleCommits[wa][i];
        }

        return returnCommits;
    }

    function getWalletTotal(address wa) public view returns(uint) {
        if (wa != msg.sender) {
            require(msg.sender == adminWallet || msg.sender == ownerWallet);
        }
    
        uint i = 0;
        uint walletCommit = 0;

        while (i < PreSaleCommits[wa].length) {
            walletCommit = walletCommit + PreSaleCommits[wa][i].USDValue;
            i++;
        }

        return walletCommit;
    }

    function getRaisedValue() public view returns(uint val) {
        return raisedValue;
    }

    function getFullExport() public view isAdmin returns(ExportData[] memory) {
        uint length = committedWallets.length;
        ExportData[] memory data = new ExportData[](length);

        for (uint i = 0; i < length; i++) {
            address wallet = committedWallets[i];
            uint totalUSDValue = 0;

            for (uint j = 0; j < PreSaleCommits[wallet].length; j++) {
                totalUSDValue += PreSaleCommits[wallet][j].USDValue;
            }

            data[i] = ExportData(wallet, totalUSDValue);
        }

        return data;
    }

    function getUSDValue(uint quantity, string calldata currency) public view returns (uint) {
        int price = 0;

        bytes32 inputHash = keccak256(abi.encodePacked(currency));

        if (inputHash == keccak256(abi.encodePacked("SHIB"))) {

            (, int shibEthPrice, , ,) = SHIB_ETH_Feed.latestRoundData();
            (, int ethUsdPrice, , ,) = ETH_USD_Feed.latestRoundData();
            
            // Calculate SHIB to USD price
            // qty * shibEthPrice * ethUsdPrice / 10^38
            int shibUsdValue = (int(quantity) * shibEthPrice * ethUsdPrice) / int(10 ** 38);
            
            return uint256(shibUsdValue); // Already in 6 decimals
        } else if (inputHash == keccak256(abi.encodePacked("USDC"))) {
            return quantity;
        } else if (inputHash == keccak256(abi.encodePacked("USDT"))) {
            return quantity;
        } else if (inputHash == keccak256(abi.encodePacked("ETH"))) {
            (, price, , ,) = ETH_USD_Feed.latestRoundData();
            return (uint256(price) * quantity) / (10 ** 20);

        } else {
            revert("Invalid Currency");
        }
    }

    modifier isAdmin() {
        require(msg.sender == adminWallet || msg.sender == ownerWallet);

        _;
    }
}