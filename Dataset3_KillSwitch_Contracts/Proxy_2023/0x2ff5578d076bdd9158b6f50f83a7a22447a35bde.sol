// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            'Address: insufficient balance'
        );

        (bool success, ) = recipient.call{ value: amount }('');
        require(
            success,
            'Address: unable to send value, recipient may have reverted'
        );
    }

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                'Address: low-level call with value failed'
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            'Address: insufficient balance for call'
        );
        require(isContract(target), 'Address: call to non-contract');

        (bool success, bytes memory returndata) = target.call{ value: value }(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                'Address: low-level static call failed'
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), 'Address: static call to non-contract');

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionDelegateCall(
                target,
                data,
                'Address: low-level delegate call failed'
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), 'Address: delegate call to non-contract');

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
            if (returndata.length > 0) {
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), 'Ownable: caller is not the owner');
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            'Ownable: new owner is the zero address'
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, 'ReentrancyGuard: reentrant call');

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

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

library Strings {
    bytes16 private constant _HEX_SYMBOLS = '0123456789abcdef';
    uint8 private constant _ADDRESS_LENGTH = 20;

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return '0';
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

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return '0x00';
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, 'Strings: hex length insufficient');
        return string(buffer);
    }

    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

contract GamechainPresale is ReentrancyGuard, Ownable {
    address public saleToken;
    uint256 public totalRaised;
    uint256 public presaleId;
    uint256 public uniqueInvestors;
    address public fundReceiver;
    uint256 public ETH_MULTIPLIER;
    uint256 public USDT_MULTIPLIER;

    struct PresaleData {
        uint256 startTime;
        uint256 endTime;
        uint256 price;
        uint256 nextRoundPrice;
        uint256 tokensToSell;
        uint256 baseDecimals;
        uint256 inSale;
        uint256 amountRaised;
        uint256 vestingStartTime;
        uint256 vestingCliff;
    }

    struct VestingData {
        uint256 totalAmount;
        uint256 claimedAmount;
        uint256 claimStart;
    }

    IERC20 public USDTInterface;
    AggregatorV3Interface internal aggregatorInterface;

    mapping(uint256 => bool) public paused;
    mapping(uint256 => PresaleData) public presaleRound;
    mapping(address => mapping(uint256 => VestingData)) public investorRound;
    mapping(address => VestingData) public investors;

    event PresaleCreated(
        uint256 indexed _id,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _endTime
    );

    event PresaleUpdated(
        bytes32 indexed key,
        uint256 prevValue,
        uint256 newValue,
        uint256 timestamp
    );

    event TokensBought(
        address indexed user,
        uint256 indexed id,
        address indexed purchaseToken,
        uint256 tokensBought,
        uint256 amountPaid,
        uint256 timestamp
    );

    event TokensClaimed(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    event PresaleTokenAddressUpdated(
        address indexed prevValue,
        address indexed newValue,
        uint256 timestamp
    );

    event PresalePaused(uint256 indexed id, uint256 timestamp);
    event PresaleUnpaused(uint256 indexed id, uint256 timestamp);

    constructor(address _oracle, address _usdt) {
        require(_oracle != address(0), 'Zero aggregator address');
        require(_usdt != address(0), 'Zero USDT address');

        aggregatorInterface = AggregatorV3Interface(_oracle);
        USDTInterface = IERC20(_usdt);
        ETH_MULTIPLIER = (10 ** 18);
        USDT_MULTIPLIER = (10 ** 6);
        fundReceiver = _msgSender();
    }

    function createPresale(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _price,
        uint256 _nextRoundPrice,
        uint256 _tokensToSell,
        uint256 _baseDecimals,
        uint256 _vestingStartTime,
        uint256 _vestingCliff
    ) external onlyOwner {
        require(
            _endTime > _startTime && _endTime > block.timestamp,
            string.concat(
                'Invalid presale period. Current time: ',
                string(Strings.toString(block.timestamp)),
                ' Presale start time: ',
                string(Strings.toString(_startTime)),
                ' Presale end time: ',
                string(Strings.toString(_endTime))
            )
        );
        require(_price > 0, 'Zero price');
        require(_tokensToSell > 0, 'Zero tokens to sell');
        require(_baseDecimals > 0, 'Zero decimals for the token');
        require(
            _vestingStartTime >= _endTime,
            'Vesting starts before Presale ends'
        );

        presaleId++;
        presaleRound[presaleId] = PresaleData(
            _startTime,
            _endTime,
            _price,
            _nextRoundPrice,
            _tokensToSell * _baseDecimals,
            _baseDecimals,
            _tokensToSell * _baseDecimals,
            0,
            _vestingStartTime,
            _vestingCliff
        );

        emit PresaleCreated(presaleId, _tokensToSell, _startTime, _endTime);
    }

    function changeSaleTimes(
        uint256 _id,
        uint256 _startTime,
        uint256 _endTime
    ) external checkPresaleId(_id) onlyOwner {
        require(_startTime > 0 || _endTime > 0, 'Invalid parameters');

        if (_startTime > 0) {
            require(
                block.timestamp < presaleRound[_id].startTime,
                'Sale already started'
            );

            uint256 prevValue = presaleRound[_id].startTime;
            presaleRound[_id].startTime = _startTime;

            emit PresaleUpdated(
                bytes32('START'),
                prevValue,
                _startTime,
                block.timestamp
            );
        }

        if (_endTime > 0) {
            require(
                block.timestamp < presaleRound[_id].endTime,
                'Sale already ended'
            );
            require(_endTime > presaleRound[_id].startTime, 'Invalid endTime');

            uint256 prevValue = presaleRound[_id].endTime;
            presaleRound[_id].endTime = _endTime;

            emit PresaleUpdated(
                bytes32('END'),
                prevValue,
                _endTime,
                block.timestamp
            );
        }
    }

    function changeVestingStartTime(
        uint256 _id,
        uint256 _vestingStartTime
    ) external checkPresaleId(_id) onlyOwner {
        require(
            _vestingStartTime >= presaleRound[_id].endTime,
            'Vesting starts before Presale ends'
        );

        uint256 prevValue = presaleRound[_id].vestingStartTime;
        presaleRound[_id].vestingStartTime = _vestingStartTime;

        emit PresaleUpdated(
            bytes32('VESTING_START_TIME'),
            prevValue,
            _vestingStartTime,
            block.timestamp
        );
    }

    function changeSaleToken(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), 'Zero token address');

        address prevValue = saleToken;
        saleToken = _newAddress;

        emit PresaleTokenAddressUpdated(
            prevValue,
            _newAddress,
            block.timestamp
        );
    }

    function changePrice(
        uint256 _id,
        uint256 _price,
        uint256 _nextRoundPrice,
        uint256 _tokensToSell
    ) external checkPresaleId(_id) onlyOwner {
        require(_price > 0, 'Zero price');
        require(_nextRoundPrice > 0, 'Zero next round price');
        require(_tokensToSell > 0, 'Zero tokens to sell');

        presaleRound[_id].price = _price;
        presaleRound[_id].nextRoundPrice = _nextRoundPrice;
        presaleRound[_id].tokensToSell = _tokensToSell;
    }

    function pausePresale(uint256 _id) external checkPresaleId(_id) onlyOwner {
        require(!paused[_id], 'Already paused');

        paused[_id] = true;
        emit PresalePaused(_id, block.timestamp);
    }

    function unPausePresale(
        uint256 _id
    ) external checkPresaleId(_id) onlyOwner {
        require(paused[_id], 'Not paused');

        paused[_id] = false;
        emit PresaleUnpaused(_id, block.timestamp);
    }

    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = aggregatorInterface.latestRoundData();
        price = (price * (10 ** 10));
        return uint256(price);
    }

    modifier checkPresaleId(uint256 _id) {
        require(_id > 0 && _id <= presaleId, 'Invalid presale id');
        _;
    }

    modifier checkSaleState(uint256 _id, uint256 amount) {
        require(
            block.timestamp >= presaleRound[_id].startTime &&
                block.timestamp <= presaleRound[_id].endTime,
            string.concat(
                'Invalid time for buying. Current time: ',
                Strings.toString(block.timestamp),
                ' Presale start time: ',
                Strings.toString(presaleRound[_id].startTime),
                ' Presale end time: ',
                Strings.toString(presaleRound[_id].endTime)
            )
        );
        require(
            amount > 0 && amount <= presaleRound[_id].inSale,
            string.concat('Invalid sale amount ', Strings.toString(amount))
        );
        _;
    }

    function buyWithUSDT(
        uint256 _id,
        uint256 usdAmount
    )
        external
        checkPresaleId(_id)
        checkSaleState(_id, usdtToTokens(_id, usdAmount))
        nonReentrant
        returns (bool)
    {
        require(!paused[_id], 'Presale paused');

        uint256 tokens = usdtToTokens(_id, usdAmount);

        uint256 senderAllowance = USDTInterface.allowance(
            _msgSender(),
            address(this)
        );
        require(
            usdAmount <= senderAllowance,
            'Make sure to add enough allowance'
        );

        presaleRound[_id].inSale -= tokens;
        presaleRound[_id].amountRaised += usdAmount;
        totalRaised += usdAmount;

        PresaleData memory _presale = presaleRound[_id];

        if (investorRound[_msgSender()][_id].totalAmount > 0) {
            investorRound[_msgSender()][_id].totalAmount += tokens;
        } else {
            investorRound[_msgSender()][_id] = VestingData(
                tokens,
                0,
                _presale.vestingStartTime + _presale.vestingCliff
            );
        }

        if (investors[_msgSender()].totalAmount > 0) {
            investors[_msgSender()].totalAmount += tokens;
        } else {
            investors[_msgSender()] = VestingData(
                tokens,
                0,
                _presale.vestingStartTime + _presale.vestingCliff
            );
            uniqueInvestors++;
        }

        (bool success, ) = address(USDTInterface).call(
            abi.encodeWithSignature(
                'transferFrom(address,address,uint256)',
                _msgSender(),
                fundReceiver,
                usdAmount
            )
        );
        require(success, 'USDT payment failed');

        emit TokensBought(
            _msgSender(),
            _id,
            address(USDTInterface),
            tokens,
            usdAmount,
            block.timestamp
        );
        return true;
    }

    function buyWithEth(
        uint256 _id
    )
        external
        payable
        checkPresaleId(_id)
        checkSaleState(_id, ethToTokens(_id, msg.value))
        nonReentrant
        returns (bool)
    {
        require(!paused[_id], 'Presale paused');

        uint256 usdAmount = (msg.value * getLatestPrice() * USDT_MULTIPLIER) /
            (ETH_MULTIPLIER * ETH_MULTIPLIER);

        uint256 tokens = usdtToTokens(_id, usdAmount);

        presaleRound[_id].inSale -= tokens;
        presaleRound[_id].amountRaised += usdAmount;
        totalRaised += usdAmount;

        PresaleData memory _presale = presaleRound[_id];

        if (investorRound[_msgSender()][_id].totalAmount > 0) {
            investorRound[_msgSender()][_id].totalAmount += tokens;
        } else {
            investorRound[_msgSender()][_id] = VestingData(
                tokens,
                0,
                _presale.vestingStartTime + _presale.vestingCliff
            );
        }

        if (investors[_msgSender()].totalAmount > 0) {
            investors[_msgSender()].totalAmount += tokens;
        } else {
            investors[_msgSender()] = VestingData(
                tokens,
                0,
                _presale.vestingStartTime + _presale.vestingCliff
            );
            uniqueInvestors++;
        }

        sendValue(payable(fundReceiver), msg.value);

        emit TokensBought(
            _msgSender(),
            _id,
            address(0),
            tokens,
            msg.value,
            block.timestamp
        );
        return true;
    }

    function claimableAmount(address user) public view returns (uint256) {
        VestingData memory _user = investors[user];
        require(_user.totalAmount > 0, 'Nothing to claim');

        uint256 amount = _user.totalAmount - _user.claimedAmount;
        require(amount > 0, 'Already claimed');

        if (block.timestamp < _user.claimStart) return 0;

        return amount;
    }

    function claim(address user) public returns (bool) {
        uint256 amount = claimableAmount(user);
        require(amount > 0, 'Zero claim amount');

        require(saleToken != address(0), 'Presale token address not set');

        require(
            amount <= IERC20(saleToken).allowance(owner(), address(this)),
            'Not enough presale token allowance'
        );

        investors[user].claimedAmount += amount;

        bool status = IERC20(saleToken).transferFrom(owner(), user, amount);
        require(status, 'Token transfer failed');

        emit TokensClaimed(user, amount, block.timestamp);

        return true;
    }

    function claimMultiple(address[] calldata users) external returns (bool) {
        require(users.length > 0, 'Zero users length');

        for (uint256 i; i < users.length; i++) {
            require(claim(users[i]), 'Claim failed');
        }

        return true;
    }

    function currentRound() public view returns (uint256) {
        require(presaleId > 0, 'No presale rounds');

        uint256 currentRoundId = 0;

        for (uint256 i = 1; i <= presaleId; i++) {
            if (
                block.timestamp >= presaleRound[i].startTime &&
                block.timestamp <= presaleRound[i].endTime
            ) {
                currentRoundId = i;
                break;
            }
        }

        return currentRoundId;
    }

    function ethToTokens(
        uint256 _id,
        uint256 amount
    ) public view returns (uint256) {
        uint256 usdAmount = (amount * getLatestPrice() * USDT_MULTIPLIER) /
            (ETH_MULTIPLIER * ETH_MULTIPLIER);
        return usdtToTokens(_id, usdAmount);
    }

    function usdtToTokens(
        uint256 _id,
        uint256 amount
    ) public view returns (uint256) {
        return (amount * presaleRound[_id].price) / USDT_MULTIPLIER;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Low balance');

        (bool success, ) = recipient.call{ value: amount }('');
        require(success, 'ETH Payment failed');
    }

    function changeClaimStart(
        address[] memory _address,
        uint256[] memory _claimStart
    ) public onlyOwner {
        for (uint256 i = 0; i < _address.length; i++) {
            investors[_address[i]].claimStart = _claimStart[i];
        }
    }

    function changeClaimAddress(
        address _oldAddress,
        address _newAddress
    ) public onlyOwner {
        require(
            investors[_oldAddress].totalAmount > 0,
            'User is not an investor'
        );
        require(
            investors[_newAddress].totalAmount == 0,
            'New address already in use'
        );
        investors[_newAddress].totalAmount = investors[_oldAddress].totalAmount;
        investors[_newAddress].claimedAmount = investors[_oldAddress]
            .claimedAmount;
        investors[_newAddress].claimStart = investors[_oldAddress].claimStart;
        investors[_oldAddress].totalAmount = 0;
    }

    function changeFundWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0), 'Invalid parameters');
        fundReceiver = _wallet;
    }

    function withdrawTokens(address _token, uint256 amount) external onlyOwner {
        IERC20(_token).transfer(fundReceiver, amount);
    }

    function withdrawFunds(uint256 amount) external onlyOwner {
        sendValue(payable(fundReceiver), amount);
    }

    function changeOracleAddress(address _oracle) public onlyOwner {
        require(_oracle != address(0), 'Zero aggregator address');
        aggregatorInterface = AggregatorV3Interface(_oracle);
    }

    function changeUSDTToken(address _usdt) external onlyOwner {
        require(_usdt != address(0), 'Zero token address');
        USDTInterface = IERC20(_usdt);
    }

    receive() external payable {}
}