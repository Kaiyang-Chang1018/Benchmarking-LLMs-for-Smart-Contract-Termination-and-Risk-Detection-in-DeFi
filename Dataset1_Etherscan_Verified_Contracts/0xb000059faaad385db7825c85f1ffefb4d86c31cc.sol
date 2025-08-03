// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    ) external;
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}
contract presale is Ownable {
    AggregatorV3Interface internal priceFeed;

    uint256[] public pricesUSDT = [
        43478000000000000000000,
        39526000000000000000000,
        35932000000000000000000,
        32666000000000000000000,
        29696000000000000000000,
        26997000000000000000000,
        24542000000000000000000,
        22311000000000000000000,
        20283000000000000000000,
        18439000000000000000000 
    ]; // Amount of token user will get per 1 USDT in stage Wise
    uint256 public constant totalTokenAmount = 500000000000000000000000000000; // Total Amount Allocated for Presale
                                                
     uint256 public constant stages = 10; // Number Of Stages
    uint256 public tokenAmountPerStage;
    uint256 public lastStagetime ;
    uint256 public stage = 0;
    uint256 public tokenSold = 0;
    IERC20 public token = IERC20(0xb042FB97DCeF012c3F0F544e38F734c7F1902E1F);
    IERC20 public usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    mapping(address => Purchase[]) public purchases;

    struct Purchase {
        uint256 stage;
        uint256 amount;
        bool claimed;
    }
    bool public isPresaleOpen = true;
        bool public isClaimable = false;


    constructor() {
        tokenAmountPerStage = totalTokenAmount / stages;
        lastStagetime = block.timestamp;
       priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    }

    function buyTokensUSDT(uint256 usdtAmount) public {
        require(isPresaleOpen, "Presale has ended");
        
        uint256 tokensToBuy = usdtAmount * pricesUSDT[stage];
        uint256 usdtAmountFortransfer = usdtAmount / 1000000000000;
        usdt.transferFrom(msg.sender, address(this), usdtAmountFortransfer);
        
        tokenSold += (tokensToBuy / 1000000000000000000);
        purchases[msg.sender].push(Purchase(stage, tokensToBuy / 1000000000000000000, false));

        if (tokenSold >= tokenAmountPerStage) {
            stage++;
            tokenSold = 0;
            lastStagetime = block.timestamp;
        }
    }
 function getLatestPriceETH() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price / 100000000;
    }
    function buyTokensNative() public payable {
        
       int256 latestPrice = getLatestPriceETH();
       uint256 nativeprice = uint256(latestPrice) ;
       require(isPresaleOpen, "Presale has ended");

        uint256 tokensToBuy = msg.value * (pricesUSDT[stage] * nativeprice);

        tokenSold += (tokensToBuy / 1000000000000000000);
        purchases[msg.sender].push(Purchase(stage, tokensToBuy / 1000000000000000000 , false));

        if (tokenSold >= tokenAmountPerStage) {
            stage++;
            tokenSold = 0;
            lastStagetime = block.timestamp;
        }

        address payable contractOwner = payable(owner());
        contractOwner.transfer(msg.value);
    }
   
   
    function claimTokens() public {
           require(isClaimable, "Claim Not allowed at this moment");
        require(purchases[msg.sender].length > 0, "No purchases found");

        uint256 totalTokensToClaim = 0;
        for (uint256 i = 0; i < purchases[msg.sender].length; i++) {
            Purchase storage purchase = purchases[msg.sender][i];
            require(!purchase.claimed, "Tokens already claimed");

            totalTokensToClaim += purchase.amount;
            purchase.claimed = true;
  }

        require(
            token.balanceOf(address(this)) >= totalTokensToClaim,
            "Not enough tokens available"
        );

        require(
            token.transfer(msg.sender, totalTokensToClaim),
            "Token transfer failed"
        );
    }
  function Claimable(bool status) public onlyOwner {
        isClaimable = status;
    }
    function getPurchaseInfo(address walletAddress)
        public
        view
        returns (Purchase[] memory)
    {
        return purchases[walletAddress];
    }

    function EndPresale(bool status) public onlyOwner {
        isPresaleOpen = status;
    }
    

    function withdrawStablecoins() external onlyOwner {
        uint256 balance = usdt.balanceOf(address(this));
        require(balance > 0, "Presale: No stablecoins to withdraw");

        usdt.transfer(owner(), balance);
    }

    function withdrawTokens() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "Presale: No tokens to withdraw");

        token.transfer(owner(), balance);
    }
}