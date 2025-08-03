// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function burn(uint256 amount) external;
}

contract MarketPlace is Ownable {
    address public marketingAddress;
    IERC20 public token;

    uint256 public hintPrice = 100 * 10 ** 18;
    uint256 public skipQuestPricePerQuest = 100 * 10 ** 18;
    uint256 public healthPrice = 20 * 10 ** 18;
    uint256 public sideQuestPrice = 40 * 10 ** 18;

    uint256 public totalBuyHintAmount;
    uint256 public totalBuyHealthAmount;
    uint256 public totalBuySideQuestAmount;
    uint256 public totalSkipQuestAmount;
    uint256 public totalBurnTokenAmount;

    mapping (address => uint256) public hintCounts;
    mapping (address => uint256) public skipQuests;
    mapping (address => uint256) public healthCounts;
    mapping (address => uint256) public sideQuestCounts;

    constructor(
        address _marketingAddress,
        address _tokenAddress
    ) {
        marketingAddress = _marketingAddress;
        token = IERC20(_tokenAddress);
    }

    function buyHint() external {
        require(token.allowance(msg.sender, address(this)) >= hintPrice, "Marketplace: Insufficient allowance.");

        uint256 burnAmount = hintPrice * 90 / 100;
        uint256 marketingAmount = hintPrice * 10 / 100;

        token.transferFrom(msg.sender, marketingAddress, marketingAmount);
        token.transferFrom(msg.sender, address(this), burnAmount);
        token.burn(burnAmount);

        totalBurnTokenAmount += burnAmount;
        totalBuyHintAmount++;
        hintCounts[msg.sender] += 1;
    }

    function skipQuest(uint256 questId) external {
        require(questId < 5, "Marketplace: QuestDay must be less than 5.");

        uint256 burnAmount = skipQuestPricePerQuest * questId * 90 / 100;
        uint256 marketingAmount = skipQuestPricePerQuest * questId * 10 / 100;

        token.transferFrom(msg.sender, marketingAddress, marketingAmount);
        token.transferFrom(msg.sender, address(this), burnAmount);
        token.burn(burnAmount);

        totalBurnTokenAmount += burnAmount;
        totalSkipQuestAmount++;
        skipQuests[msg.sender] += 1;
    }

    function buyHealth(uint256 healthCount) external {
        require(healthCount < 10, "Marketplace: You can buy max 10 health.");

        uint256 burnAmount = healthPrice * healthCount * 90 / 100;
        uint256 marketingAmount = healthPrice * healthCount * 10 / 100;

        token.transferFrom(msg.sender, marketingAddress, marketingAmount);
        token.transferFrom(msg.sender, address(this), burnAmount);

        token.burn(burnAmount);
        totalBurnTokenAmount += burnAmount;
        totalBuyHealthAmount += healthCount;
        healthCounts[msg.sender] += healthCount;
    }

    function buySideQuest() external {
        uint256 burnAmount = sideQuestPrice * 90 / 100;
        uint256 marketingAmount = sideQuestPrice * 10 / 100;

        token.transferFrom(msg.sender, marketingAddress, marketingAmount);
        token.transferFrom(msg.sender, address(this), burnAmount);
        token.burn(burnAmount);

        totalBurnTokenAmount += burnAmount;
        totalBuySideQuestAmount += 1;
        sideQuestCounts[msg.sender] += 1;
    }

    function setNewMarketingWallet(address _marketingWallet) external onlyOwner {
        marketingAddress = _marketingWallet;
    }

    function setNewTokenContract(address _tokenAddress) external onlyOwner {
        token = IERC20(_tokenAddress);
    }

    function setHintPrice (uint256 _price) external  onlyOwner {
        hintPrice = _price;
    }

    function setSkipQuestPricePerQuest (uint256 _price) external onlyOwner {
        skipQuestPricePerQuest = _price;
    }

    function setHealthPrice (uint256 _price) external onlyOwner {
        healthPrice = _price;
    }

    function setSideQuestPrice (uint256 _price) external onlyOwner {
        sideQuestPrice = _price;
    }
}