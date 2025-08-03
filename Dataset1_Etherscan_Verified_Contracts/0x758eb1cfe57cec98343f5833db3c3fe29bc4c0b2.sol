// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
pragma solidity ^0.8.20;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IERC20 {
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract IconCommunity {
    address internal admin;
    address internal devrel;
    address public liquidityPool;
    uint public tokenPrice;
    AggregatorV3Interface public priceFeed;
    IERC20 public iconToken;
    uint public MinimumPurchase;

    struct UserData {
        uint iconsReceived;
        uint totalCommitment;
    }

    struct adminData {
        uint totalUsers;
        bool saleActive;
    }

    mapping(address => UserData) public userData;
    adminData public AdminData;

    event UserJoined(address indexed user, uint ethAmount, uint tokensIssued);

    modifier onlyAdmins() {
        require(msg.sender == admin || msg.sender == liquidityPool, "Only Admin Can Call This Function");
        _;
    }

    modifier onlyControl() {
        require(msg.sender == admin, "Only Admin Can Call This Function");
        _;
    }

    constructor(address _devrel, address _liquidityPool, IERC20 _iconToken, address _priceFeed, uint _tokenPrice, uint _minimumPurchase) {
        require(_devrel != address(0) && _liquidityPool != address(0), "Invalid Address");
        require(address(_iconToken) != address(0), "Invalid Token Address");

        admin = msg.sender;
        devrel = _devrel;
        liquidityPool = _liquidityPool;
        iconToken = _iconToken;
        tokenPrice = _tokenPrice;

        priceFeed = AggregatorV3Interface(_priceFeed);
        AdminData.saleActive = true;
        MinimumPurchase = _minimumPurchase;
    }

    function joinIconCommunity() public payable {
        require(msg.value > 0, "Ether Amount Must Be Greater Than Zero");
        require(AdminData.saleActive == true, "The Sale Is Now Inactive");

        uint pricePerToken = convertUSDToETH(tokenPrice);
        uint amount = msg.value / pricePerToken;
        require(amount > MinimumPurchase, "Purchased Amount Must Be Above The Minimum");
        require(iconToken.transfer(msg.sender, (amount *10**18)), "Token Transfer Failed");

        UserData storage user = userData[msg.sender];
        if (user.totalCommitment == 0) {
            AdminData.totalUsers++;
        }
        user.iconsReceived += amount;
        user.totalCommitment += msg.value;

        emit UserJoined(msg.sender, msg.value, amount);
    }

    function updateAddresses(address _devrel, address _liquidityPool, IERC20 _iconToken, address _priceFeed, uint _tokenPrice, uint _minimumPurchase) external onlyControl {
        require(_devrel != address(0) && _liquidityPool != address(0), "Invalid Address");
        devrel = _devrel;
        liquidityPool = _liquidityPool;
        priceFeed = AggregatorV3Interface(_priceFeed);
        iconToken = _iconToken;
        tokenPrice = _tokenPrice;
        MinimumPurchase = _minimumPurchase;
    }

    function recoverLiquidity()public onlyAdmins {
        uint amountToDevrel = ((address(this).balance) * 15) / 100;
        uint amountToLiquidityPool = ((address(this).balance) * 85) / 100;

        payable(devrel).transfer(amountToDevrel);
        payable(liquidityPool).transfer(amountToLiquidityPool);
    }

    /**
     * @dev Fetches the latest ETH/USD price from Chainlink
     * @return price - the latest price with 8 decimals
    **/
    function getLatestPrice() public view returns (int) {
        (
            ,
            int price, // Latest ETH/USD price
            ,
            ,
            
        ) = priceFeed.latestRoundData();
        return price;
    }

    /**
     * @dev Converts a given USD amount to ETH
     * @param usdAmount - the USD amount in cents (e.g., $0.15 = 15 cents)
     * @return ethAmount - the equivalent amount of ETH (18 decimals)
     * @dev 
     *      4 Decimal Place
     *      samples - $0.15 = 1500
     *              - $1000 = 10000000
     *      
     */
    function convertUSDToETH(uint usdAmount) public view returns (uint) {
        // Fetch the latest ETH/USD price
        int ethPrice = getLatestPrice();
        require(ethPrice > 0, "Invalid ETH Price");

        uint adjustedPrice = uint(ethPrice) / 10**4;

        // Calculate ETH amount: (USD amount * 10^18) / ETH price
        uint ethAmount = (usdAmount * 10**18) / uint(adjustedPrice);

        return ethAmount;
    }

    function endIconSale(address _liquidityPool) public onlyAdmins {
        uint tokenBal = iconToken.balanceOf(address(this));
        require(iconToken.transfer(_liquidityPool, tokenBal), "Token Transfer Failed");
        payable(_liquidityPool).transfer(address(this).balance);
        AdminData.saleActive = false;
    }

    receive() external payable {
        joinIconCommunity();
    }
}