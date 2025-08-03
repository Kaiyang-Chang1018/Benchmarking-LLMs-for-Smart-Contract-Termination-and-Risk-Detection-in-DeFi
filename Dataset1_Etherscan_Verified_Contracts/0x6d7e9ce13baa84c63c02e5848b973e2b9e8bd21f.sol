// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
abstract contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
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

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
}

contract PaymentForwarder is Context, Ownable, ReentrancyGuard{
    IERC20 public usdtToken;
    address public usdtTokenAddress;
    address public payee;

    mapping(address => uint256) balances;
    mapping(string => uint256) servicePrices;

    struct UserData {
        string choosenService;
        uint256 dueDate;
    }

    mapping(address => UserData) public usersData;

    event PaymentCreated(address indexed payee, uint256 amount);
    event BalanceDeposits(address indexed payee, uint256 amount);

    constructor(address _usdtTokenAddress) {
        usdtTokenAddress = _usdtTokenAddress;
        usdtToken = IERC20(usdtTokenAddress);
        payee = _msgSender();
    }

    function setPayee(address _payee) public onlyOwner {
        payee = _payee;
    }

    function setServicePrice(
        string memory _service,
        uint256 _price
    ) public onlyOwner {
        servicePrices[_service] = _price;
    }

    function getServicePrice(
        string memory _service
    ) public view returns (uint256) {
        return servicePrices[_service];
    }

    function getActiveService(
        address _user
    ) public view returns (string memory) {
        return usersData[_user].choosenService;
    }

    function deposit(uint256 _amount) public nonReentrant {
        require(
            usdtToken.transferFrom(_msgSender(), address(this), _amount),
            "USDT transfer failed"
        );
        balances[_msgSender()] += _amount;
        emit BalanceDeposits(_msgSender(), _amount);
    }

    function getUserBalance(address _address) public view returns (uint256) {
        return balances[_address];
    }

    function createPaymentForAnnualService(
        string memory _service
    ) public nonReentrant {
        require(
            balances[_msgSender()] >= servicePrices[_service],
            "Insufficient balance"
        );
        require(
            usersData[_msgSender()].dueDate == 0,
            "User already has a service"
        );
        balances[_msgSender()] -= servicePrices[_service];
        usersData[_msgSender()] = UserData(
            _service,
            block.timestamp + 365 days
        );
        usdtToken.transfer(payee, servicePrices[_service]);
        emit PaymentCreated(_msgSender(), servicePrices[_service]);
    }

    function createPaymentForMonthlyService(
        string memory _service
    ) public nonReentrant {
        require(
            balances[_msgSender()] >= servicePrices[_service],
            "Insufficient balance"
        );
        require(
            usersData[_msgSender()].dueDate == 0,
            "User already has a service"
        );
        balances[_msgSender()] -= servicePrices[_service];
        usersData[_msgSender()] = UserData(_service, block.timestamp + 30 days);
        usdtToken.transfer(payee, servicePrices[_service]);
        emit PaymentCreated(_msgSender(), servicePrices[_service]);
    }

    function getRemainingServiceTime() public view returns (uint256) {
        return usersData[_msgSender()].dueDate - block.timestamp;
    }

    function withdrawTokens(address _token) public onlyOwner {
        IERC20 token = IERC20(_token);
        token.transfer(owner, token.balanceOf(address(this)));
    }

    function cancelServiceByUser() public nonReentrant {
        require(usersData[_msgSender()].dueDate != 0, "User has no service");
        usersData[_msgSender()] = UserData("", 0);
    }

    function forceCancelService(address _user) public onlyOwner {
        require(usersData[_user].dueDate != 0, "User has no service");
        usersData[_user] = UserData("", 0);
    }

    function getUserData(address _user) public view returns (UserData memory) {
        return usersData[_user];
    }

    function setMultipleServicePrices(
        string[] memory _services,
        uint256[] memory _prices
    ) public onlyOwner {
        require(
            _services.length == _prices.length,
            "Services and prices length mismatch"
        );
        for (uint256 i = 0; i < _services.length; i++) {
            servicePrices[_services[i]] = _prices[i];
        }
    }
}