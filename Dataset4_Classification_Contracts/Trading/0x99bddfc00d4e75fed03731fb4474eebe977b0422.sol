// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external;

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external;
}

interface Aggregator {
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

interface CatsPresaleV1 {
    function userDeposits(address user) external view returns (uint256);

    function isUserExist(address user) external view returns (bool);

    function presaleDetails(uint256 index) external view returns (PresaleDetails memory);

    function totalUsers() external view returns (uint256);

    function currentPresaleStage() external view returns (uint256);

    function presaleStartTime() external view returns (uint256);

    function totalUSDAmount() external view returns (uint256);

    function totalTokenSold() external view returns (uint256);

    function inSale() external view returns (uint256);
}

struct PresaleDetails {
    uint256 stage;
    uint256 totalTokens;
    uint256 inSale;
    uint256 totalTokenSold;
    uint256 totalUSDAmount;
    uint256 priceMultipler;
    uint256 priceDivider;
    uint256 startTime;
    uint256 endTime;
}

contract CatsPreSale is Ownable, Pausable, ReentrancyGuard {
    uint256 public totalTokensForPresale = 1_700_000 * 10**18;
    uint256 public inSale = 1_700_000 * 10**18;
    uint256 public totalTokenSold = 0;
    uint256 public totalUSDAmount;

    bool internal isInitialize;
    bool public isPresaleCompleted;
    uint256 public presaleStartTime;
    address public saleToken;

    address public presaleV1 = 0x0d72eD66517E4f77c12741988B3DF87Dc2De59Cc;
    address public dataOracle = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address public usdtToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    
    address public targetAddress = 0xb5D11E5AD4A7f094156F4fbe3891D2F30cD54d76;

    IERC20 usdtTokenInterface = IERC20(usdtToken);

    uint256 public claimStart;

    uint256 public currentPresaleStage;
    uint256 public totalPresaleStages = 10;

    uint256 public remainingTokens;

    uint256 public totalUsers;

    mapping(address => uint256) internal userDeposits;
    mapping(address => bool) internal isUserExist;

    mapping(address => uint256) public userClaimedAmount;
    mapping(address => bool) public hasClaimed;
    mapping(uint256 => PresaleDetails) public presaleDetails;


    modifier onlyInitialized() {
        require(isInitialize, "Contract is not initialized");
        _;
    }

    event TokensBought(address indexed user, uint256 indexed tokensBought, uint256 indexed amountPaid, string method, uint256 stage, uint256 timestamp);

    event TokensClaimed(address indexed user, uint256 amount, uint256 timestamp);


    function initialize() public onlyOwner {
        require(!isInitialize, "Contract is already Initialized");
        inSale = CatsPresaleV1(presaleV1).inSale();
        totalTokenSold = CatsPresaleV1(presaleV1).totalTokenSold();
        totalUSDAmount = CatsPresaleV1(presaleV1).totalUSDAmount();
        presaleStartTime = CatsPresaleV1(presaleV1).presaleStartTime();
        currentPresaleStage = CatsPresaleV1(presaleV1).currentPresaleStage();
        totalUsers = CatsPresaleV1(presaleV1).totalUsers();
        presaleDetails[currentPresaleStage] = CatsPresaleV1(presaleV1).presaleDetails(currentPresaleStage);
        isInitialize = true;
    }

    function getUserDeposits(address user) public view returns (uint256 amount) {
        if (hasClaimed[user]) {
            return 0;
        }
        amount = userDeposits[user] + CatsPresaleV1(presaleV1).userDeposits(user);
    }

    function checkIsUserExists(address user) public view returns (bool) {
        if (isUserExist[user]) return true;
        return CatsPresaleV1(presaleV1).isUserExist(user);
    }

    function stagewiseToken(uint256 _stage) internal pure returns (uint256 tokens) {
        if (_stage == 1) {
            tokens = 250_000 * 10**18;
        } else if (_stage == 2) {
            tokens = 227_272 * 10**18;
        } else if (_stage == 3) {
            tokens = 206_611 * 10**18;
        } else if (_stage == 4) {
            tokens = 187_969 * 10**18;
        } else if (_stage == 5) {
            tokens = 171_232 * 10**18;
        } else if (_stage == 6) {
            tokens = 155_279 * 10**18;
        } else if (_stage == 7) {
            tokens = 141_242 * 10**18;
        } else if (_stage == 8) {
            tokens = 128_534 * 10**18;
        } else if (_stage == 9) {
            tokens = 116_822 * 10**18;
        } else if (_stage == 10) {
            tokens = 106_157 * 10**18;
        } else {
            tokens = 0;
        }
    }

    function stagewisePrice(uint256 _stage) internal pure returns (uint256 priceMultipler, uint256 priceDivider) {
        if (_stage == 1) {
            priceMultipler = 2;
            priceDivider = 1;
        } else if (_stage == 2) {
            priceMultipler = 22;
            priceDivider = 10;
        } else if (_stage == 3) {
            priceMultipler = 242;
            priceDivider = 100;
        } else if (_stage == 4) {
            priceMultipler = 266;
            priceDivider = 100;
        } else if (_stage == 5) {
            priceMultipler = 292;
            priceDivider = 100;
        } else if (_stage == 6) {
            priceMultipler = 322;
            priceDivider = 100;
        } else if (_stage == 7) {
            priceMultipler = 354;
            priceDivider = 100;
        } else if (_stage == 8) {
            priceMultipler = 389;
            priceDivider = 100;
        } else if (_stage == 9) {
            priceMultipler = 428;
            priceDivider = 100;
        } else if (_stage == 10) {
            priceMultipler = 471;
            priceDivider = 100;
        } else {
            priceMultipler = 1;
            priceDivider = 1;
        }
    }

    constructor() {
        presaleStartTime = block.timestamp;
        currentPresaleStage++;
        (uint256 _priceMultipler, uint256 _priceDivider) = stagewisePrice(currentPresaleStage);
        presaleDetails[currentPresaleStage] = PresaleDetails({stage: currentPresaleStage, totalTokens: stagewiseToken(currentPresaleStage), inSale: stagewiseToken(currentPresaleStage), totalTokenSold: 0, totalUSDAmount: 0, priceMultipler: _priceMultipler, priceDivider: _priceDivider, startTime: block.timestamp, endTime: 0});
    }

    function startClaim(uint256 tokensAmount, address _saleToken) external onlyOwner {
        require(_saleToken != address(0), "Zero token address");
        claimStart = block.timestamp;
        saleToken = _saleToken;
        IERC20(_saleToken).transferFrom(_msgSender(), address(this), tokensAmount);
    }

    function claim() external whenNotPaused nonReentrant {
        require(isPresaleCompleted, "Presale not Completed yet");
        require(saleToken != address(0), "Sale token not added");
        require(block.timestamp >= claimStart, "Claim has not started yet");
        uint256 amount = getUserDeposits(_msgSender());
        require(amount != 0, "Nothing to claim.");
        require(!hasClaimed[_msgSender()], "Already claimed");
        hasClaimed[_msgSender()] = true;
        userClaimedAmount[_msgSender()] = amount;
        userDeposits[_msgSender()] = 0;
        IERC20(saleToken).transfer(_msgSender(), amount);
        emit TokensClaimed(_msgSender(), amount, block.timestamp);
    }

    function getTokenAmountForETHInCurrentPresale(uint256 _ethAmount) public view returns (uint256 tokenAmount) {
        uint256 usdAmount = (_ethAmount * getETHLatestPrice()) / 10**18;
        tokenAmount = (usdAmount * presaleDetails[currentPresaleStage].priceDivider) / presaleDetails[currentPresaleStage].priceMultipler;
    }

    function getTokenAmountForUSDTInCurrentPresale(uint256 _usdAmount) public view returns (uint256 tokenAmount) {
        tokenAmount = (_usdAmount * presaleDetails[currentPresaleStage].priceDivider) / presaleDetails[currentPresaleStage].priceMultipler;
    }

    function getETHAmountForTokenInCurrentPresale(uint256 _tokenAmount) public view returns (uint256 ethAmount) {
        uint256 amount = (_tokenAmount * 10**18) / getETHLatestPrice();
        ethAmount = (amount * presaleDetails[currentPresaleStage].priceMultipler) / presaleDetails[currentPresaleStage].priceDivider;
    }

    function getUSDTAmountForTokenInCurrentPresale(uint256 _tokenAmount) public view returns (uint256 usdtAmount) {
        usdtAmount = (_tokenAmount * presaleDetails[currentPresaleStage].priceMultipler) / presaleDetails[currentPresaleStage].priceDivider;
    }

    function getETHLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = Aggregator(dataOracle).latestRoundData();
        price = (price * (10**10));
        return uint256(price);
    }

    receive() external payable {
        buyWithETH();
    }

    function buyWithETH() public payable whenNotPaused nonReentrant onlyInitialized {
        require(isPresaleStarted(), "Presale is not started yet!");
        require(!isPresaleCompleted, "Presale Completed");
        require(msg.value > 0, "Less payment");
        uint256 usdAmount = (msg.value * getETHLatestPrice()) / 10**18;
        require(usdAmount > 0, "USD Amount can not be zero");
        uint256 tokenAmount = getTokenAmountForETHInCurrentPresale(msg.value);
        require(tokenAmount > 0, "Token Amount can not be zero");
        require(presaleDetails[currentPresaleStage].inSale >= tokenAmount, "Less tokens in current presale!");

        if (!checkIsUserExists(_msgSender())) {
            isUserExist[_msgSender()] = true;
            totalUsers++;
        }

        userDeposits[_msgSender()] += tokenAmount;

        inSale -= tokenAmount;
        totalTokenSold += tokenAmount;
        totalUSDAmount += usdAmount;

        presaleDetails[currentPresaleStage].inSale -= tokenAmount;
        presaleDetails[currentPresaleStage].totalTokenSold += tokenAmount;
        presaleDetails[currentPresaleStage].totalUSDAmount += usdAmount;

        sendValue(payable(targetAddress), msg.value);

        emit TokensBought(_msgSender(), tokenAmount, msg.value, "buyWithETH", currentPresaleStage, block.timestamp);

        if (presaleDetails[currentPresaleStage].inSale < 1 * 10**18) {
            _updatePresaleStage();
        }
        
    }

    function buyWithUSDT(uint256 usdAmount) external whenNotPaused nonReentrant onlyInitialized {
        usdAmount = usdAmount * 10**12;
        require(isPresaleStarted(), "Presale is not started yet!");
        require(!isPresaleCompleted, "Presale Completed");
        require(usdAmount > 0, "USD Amount can not be zero");
        uint256 tokenAmount = getTokenAmountForUSDTInCurrentPresale(usdAmount);
        require(tokenAmount > 0, "Token Amount can not be zero");
        require(presaleDetails[currentPresaleStage].inSale >= tokenAmount, "Less tokens in current presale!");

        if (!checkIsUserExists(_msgSender())) {
            isUserExist[_msgSender()] = true;
            totalUsers++;
        }

        userDeposits[_msgSender()] += tokenAmount;

        inSale -= tokenAmount;
        totalTokenSold += tokenAmount;
        totalUSDAmount += usdAmount;

        presaleDetails[currentPresaleStage].inSale -= tokenAmount;
        presaleDetails[currentPresaleStage].totalTokenSold += tokenAmount;
        presaleDetails[currentPresaleStage].totalUSDAmount += usdAmount;

        usdtTokenInterface.transferFrom(_msgSender(), targetAddress, usdAmount / 10**12);

        emit TokensBought(_msgSender(), tokenAmount, usdAmount, "buyWithUSDT", currentPresaleStage, block.timestamp);

        if (presaleDetails[currentPresaleStage].inSale < 1 * 10**18) {
            _updatePresaleStage();
        }
    }

    function adminAssignToken(address user, uint256 tokenAmount) public whenNotPaused onlyOwner nonReentrant onlyInitialized {
        require(isPresaleStarted(), "Presale is not started yet!");
        require(!isPresaleCompleted, "Presale Completed");
        require(tokenAmount > 0, "Token Amount can not be zero");

        uint256 usdAmount = getUSDTAmountForTokenInCurrentPresale(tokenAmount);
        require(usdAmount > 0, "USD Amount can not be zero");

        require(presaleDetails[currentPresaleStage].inSale >= tokenAmount, "Less tokens in current presale!");

        if (!checkIsUserExists(user)) {
            isUserExist[user] = true;
            totalUsers++;
        }

        userDeposits[user] += tokenAmount;

        inSale -= tokenAmount;
        totalTokenSold += tokenAmount;
        totalUSDAmount += usdAmount;

        presaleDetails[currentPresaleStage].inSale -= tokenAmount;
        presaleDetails[currentPresaleStage].totalTokenSold += tokenAmount;
        presaleDetails[currentPresaleStage].totalUSDAmount += usdAmount;

        emit TokensBought(user, tokenAmount, 0, "adminAssignToken", currentPresaleStage, block.timestamp);

        if (presaleDetails[currentPresaleStage].inSale < 1 * 10**18) {
            _updatePresaleStage();
        }
    }

    function _updatePresaleStage() internal {
        presaleDetails[currentPresaleStage].endTime = block.timestamp;
        remainingTokens += presaleDetails[currentPresaleStage].inSale;
        if (currentPresaleStage == totalPresaleStages) {
            isPresaleCompleted = true;
            return;
        }
        currentPresaleStage++;
        (uint256 _priceMultipler, uint256 _priceDivider) = stagewisePrice(currentPresaleStage);
        presaleDetails[currentPresaleStage] = PresaleDetails({stage: currentPresaleStage, totalTokens: stagewiseToken(currentPresaleStage), inSale: stagewiseToken(currentPresaleStage), totalTokenSold: 0, totalUSDAmount: 0, priceMultipler: _priceMultipler, priceDivider: _priceDivider, startTime: block.timestamp, endTime: 0});
        if (currentPresaleStage == totalPresaleStages) {
            presaleDetails[currentPresaleStage].totalTokens += remainingTokens;
            presaleDetails[currentPresaleStage].inSale += remainingTokens;
        }
    }

    function addTokensInLastStage(uint256 tokens) external onlyOwner {
        require(!isPresaleCompleted, "Presale is already completed!");
        require(currentPresaleStage == totalPresaleStages, "Presale is not in its last stage.");
        presaleDetails[currentPresaleStage].totalTokens += tokens;
        presaleDetails[currentPresaleStage].inSale += tokens;
        inSale += tokens;
        totalTokensForPresale += tokens;
    }

    function completeCurrentPresaleStage() external onlyOwner {
        _updatePresaleStage();
    }

    function updateCurrentPresalePrice(uint256 _multipler, uint256 _divider) external onlyOwner {
        require(_multipler != 0 || _divider != 0, "multipler or divider cannot be zero");
        presaleDetails[currentPresaleStage].priceMultipler = _multipler;
        presaleDetails[currentPresaleStage].priceDivider = _divider;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Low balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "ETH Payment failed");
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setDataOracle(address _dataOracle) external onlyOwner {
        dataOracle = _dataOracle;
    }

    function updateSaleStatus() external onlyOwner {
        isPresaleCompleted = !isPresaleCompleted;
    }

    function setTargetaddress(address _targetAddress) external onlyOwner {
        targetAddress = _targetAddress;
    }

    function setUSDTAddress(address _usdtAddress) external onlyOwner {
        usdtToken = _usdtAddress;
        usdtTokenInterface = IERC20(usdtToken);
    }

    function isPresaleStarted() public view returns (bool) {
        return presaleStartTime >= block.timestamp ? false : true;
    }

    function setPresaleStartTime(uint256 _startTime) external onlyOwner {
        require(_startTime > block.timestamp, "Presale is already started!");
        presaleStartTime = _startTime;
        presaleDetails[currentPresaleStage].startTime = _startTime;
    }

    function withdrawTokens(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(targetAddress, amount);
    }

    function withdrawETHs() external onlyOwner {
        (bool success, ) = payable(targetAddress).call{value: address(this).balance}("");
        require(success, "Failed to withdraw");
    }
}