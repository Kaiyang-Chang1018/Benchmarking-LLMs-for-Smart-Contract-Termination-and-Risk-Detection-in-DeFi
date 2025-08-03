// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
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

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

contract AISmartNet is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    struct VestingSchedule {
        uint256 totalAllocation; // Total tokens allocated for the beneficiary
        uint256 cliffDuration; // Cliff period in seconds
        uint256 vestingDuration; // Vesting period in seconds
        uint256 startTime; // Vesting start time
        uint256 amountReleased; // Amount of tokens already released
    }

    uint256 public buyTax = 2;
    uint256 public sellTax = 2;
    uint256 public normalTax = 2;
    uint256 public _buyCount = 0;
    uint256 public taxChangeDelay = 1 days;
    uint256 public lastTaxChangeTime;

    uint8 private constant _decimals = 18;
    uint256 private _tTotal = 1000_000_000 * 10**_decimals;
    string private constant _name = unicode"AI SmartNet";
    string private constant _symbol = unicode"SMNT";
    uint256 public _maxWalletSize = 100_000_000 * 10**_decimals;
    uint256 public teamSupply = 150_000_000 * 10**_decimals;
    uint256 public investorsSupply = 100_000_000 * 10**_decimals;
    uint256 public communitySupply = 100_000_000 * 10**_decimals;
    uint256 public reserveFunds = 50_000_000 * 10**_decimals;
    uint256 public advisorsSupply = 50_000_000 * 10**_decimals;
    uint256 dailyBurnLimit = 500000 * 10**_decimals;
    address private teamAddress;
    address private investorsAddress;
    address private communityAddress;
    address private advisorAddress;
    address public tradingAuthority;

    mapping(address => bool) public isLpPair;
    mapping(address => VestingSchedule) private _vestingSchedules;
    mapping(address => bool) private _isBeneficiary;
    mapping(address => uint256) public lastBurnTime;
    mapping(address => uint256) public burnedAmountToday;

    event TokensReleased(address indexed beneficiary, uint256 amount);
    event VestingScheduleCreated(
        address indexed beneficiary,
        uint256 allocation
    );

    bool private tradingOpen;

    modifier onlyTradingAuthority() {
        require(msg.sender == tradingAuthority, "Not the trading authority");
        _;
    }

    constructor(
        address _tradingAuth,
        address _teamAddr,
        address _communityAddr,
        address _investorsAddr,
        address _adivsorAddr
    ) {
        tradingAuthority = _tradingAuth;
        teamAddress = _teamAddr;
        investorsAddress = _investorsAddr;
        communityAddress = _communityAddr;
        advisorAddress = _adivsorAddr;
        _balances[_msgSender()] = 550_000_000 * 10**_decimals;
        _balances[address(this)] = 400_000_000 * 10**_decimals;
        _balances[_communityAddr] = 50_000_000 * 10**_decimals;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_investorsAddr] = true;
        _isExcludedFromFee[_teamAddr] = true;
        _isExcludedFromFee[_communityAddr] = true;
        _isExcludedFromFee[_adivsorAddr] = true;
        _vestingSchedules[_teamAddr] = VestingSchedule({
            totalAllocation: 150_000_000 * 10**_decimals,
            cliffDuration: 365 days,
            vestingDuration: 1095 days,
            startTime: block.timestamp,
            amountReleased: 0
        });
        _vestingSchedules[_communityAddr] = VestingSchedule({
            totalAllocation: 100_000_000 * 10**_decimals,
            cliffDuration: 365 days,
            vestingDuration: 1095 days,
            startTime: block.timestamp,
            amountReleased: 0
        });
        _vestingSchedules[_investorsAddr] = VestingSchedule({
            totalAllocation: 100_000_000 * 10**_decimals,
            cliffDuration: 180 days,
            vestingDuration: 730 days,
            startTime: block.timestamp,
            amountReleased: 0
        });

        _vestingSchedules[_adivsorAddr] = VestingSchedule({
            totalAllocation: 50_000_000 * 10**_decimals,
            cliffDuration: 365 days,
            vestingDuration: 730 days,
            startTime: block.timestamp,
            amountReleased: 0
        });
        _isBeneficiary[_teamAddr] = true;
        _isBeneficiary[_communityAddr] = true;
        _isBeneficiary[_adivsorAddr] = true;
        _isBeneficiary[_investorsAddr] = true;

        emit Transfer(address(0), _msgSender(), 550_000_000 * 10**_decimals);
        emit Transfer(address(0), _communityAddr, 50_000_000 * 10**_decimals);
        emit Transfer(address(0), address(this), 400_000_000 * 10**_decimals);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balances[from] >= amount, "Insufficient balance");
        uint256 taxAmount = 0;
        if (from != owner() && to != owner()) {
            if (!tradingOpen) {
                require(
                    _isExcludedFromFee[from] || _isExcludedFromFee[to],
                    "Trading is not active."
                );
            }
            taxAmount = 0;

            if (isLpPair[from] && !_isExcludedFromFee[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;

                taxAmount = amount.mul(buyTax).div(1000);
            } else if (
                isLpPair[to] &&
                from != address(this) &&
                !_isExcludedFromFee[from]
            ) {
                taxAmount = amount.mul(sellTax).div(1000);
            } else if (
                from != address(this) &&
                !_isExcludedFromFee[to] &&
                !isLpPair[from] &&
                !isLpPair[to]
            ) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                taxAmount = amount.mul(normalTax).div(1000);
            }
        }

        if (taxAmount > 0) {
            uint256 taxToTransfer = taxAmount / 2;
            _balances[teamAddress] = _balances[teamAddress].add(taxToTransfer);
            _balances[communityAddress] = _balances[communityAddress].add(
                taxToTransfer
            );
            emit Transfer(from, teamAddress, taxToTransfer);
            emit Transfer(from, communityAddress, taxToTransfer);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function removeLimits() external onlyOwner {
        _maxWalletSize = _tTotal;
    }

    function openTrading(address _lpPair) external onlyTradingAuthority {
        isLpPair[_lpPair] = true;
        tradingOpen = true;
    }

    function exludedFromFee(address _add) external onlyOwner {
        require(!_isExcludedFromFee[_add], "Already excluded");
        _isExcludedFromFee[_add] = true;
    }

    function setBuyTax(uint256 _tax) external onlyOwner {
        require(_tax <= 30, "Can't set more than 3%");
        require(
            block.timestamp >= lastTaxChangeTime + taxChangeDelay,
            "Cooldown not reached"
        );
        buyTax = _tax;
        lastTaxChangeTime = block.timestamp;
    }

    function setSellTax(uint256 _tax) external onlyOwner {
        require(_tax <= 30, "Can't set more than 3%");
        require(
            block.timestamp >= lastTaxChangeTime + taxChangeDelay,
            "Cooldown not reached"
        );
        sellTax = _tax;
        lastTaxChangeTime = block.timestamp;
    }

    function setNormalTax(uint256 _tax) external onlyOwner {
        require(_tax <= 30, "Can't set more than 3%");
        require(
            block.timestamp >= lastTaxChangeTime + taxChangeDelay,
            "Cooldown not reached"
        );
        normalTax = _tax;
        lastTaxChangeTime = block.timestamp;
    }

    function notExludedFromFee(address _add) external onlyOwner {
        require(_isExcludedFromFee[_add], "Not excluded");
        _isExcludedFromFee[_add] = false;
    }

    function burn(uint256 amount) external {
        require(msg.sender != address(0), "ERC20: burn from the zero address");
        uint256 currentTime = block.timestamp;
        if (currentTime > lastBurnTime[msg.sender] + 1 days) {
            burnedAmountToday[msg.sender] = 0;
        }
        require(
            burnedAmountToday[msg.sender] + amount <= dailyBurnLimit,
            "Daily burn limit exceeded!"
        );
        uint256 accountBalance = _balances[msg.sender];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        burnedAmountToday[msg.sender] += amount;
        lastBurnTime[msg.sender] = currentTime;
        _balances[msg.sender] = accountBalance - amount;
        _tTotal -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
    
    function setMaxWalletAmount(uint256 _amount) external onlyOwner {
        _maxWalletSize = _amount;
    }

    function releaseTokens() external {
        VestingSchedule storage schedule = _vestingSchedules[msg.sender];
        require(
            schedule.totalAllocation > 0,
            "No vesting schedule for beneficiary"
        );

        uint256 currentTime = block.timestamp;
        require(
            currentTime >= schedule.startTime.add(schedule.cliffDuration),
            "Cliff period not reached"
        );

        uint256 vestedAmount = _calculateVestedAmount(schedule, currentTime);
        uint256 releasableAmount = vestedAmount.sub(schedule.amountReleased);

        require(releasableAmount > 0, "No tokens to release");

        schedule.amountReleased = schedule.amountReleased.add(releasableAmount);
        _transfer(address(this), msg.sender, releasableAmount);

        emit TokensReleased(msg.sender, releasableAmount);
    }

    function _calculateVestedAmount(
        VestingSchedule memory schedule,
        uint256 currentTime
    ) private pure returns (uint256) {
        if (currentTime < schedule.startTime.add(schedule.cliffDuration)) {
            return 0;
        } else {
            // Calculate the number of months elapsed since the cliff period
            uint256 monthsElapsed = (
                currentTime.sub(schedule.startTime.add(schedule.cliffDuration))
            ).div(30 days);

            // Calculate the vested amount as 1% per month
            uint256 vestedAmount = schedule
                .totalAllocation
                .mul(monthsElapsed)
                .div(100);

            // Ensure the vested amount does not exceed the total allocation
            if (
                currentTime >= schedule.startTime.add(schedule.vestingDuration)
            ) {
                return schedule.totalAllocation;
            } else {
                return
                    vestedAmount > schedule.totalAllocation
                        ? schedule.totalAllocation
                        : vestedAmount;
            }
        }
    }

    function getVestingSchedule(address beneficiary)
        external
        view
        returns (
            uint256 totalAllocation,
            uint256 cliffDuration,
            uint256 vestingDuration,
            uint256 startTime,
            uint256 amountReleased
        )
    {
        VestingSchedule memory schedule = _vestingSchedules[beneficiary];
        return (
            schedule.totalAllocation,
            schedule.cliffDuration,
            schedule.vestingDuration,
            schedule.startTime,
            schedule.amountReleased
        );
    }
}