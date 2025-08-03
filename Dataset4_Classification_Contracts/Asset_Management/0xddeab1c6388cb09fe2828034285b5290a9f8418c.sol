// SPDX-License-Identifier: MIT
// File: contracts/Interface/IOCCoinPrice.sol


pragma solidity ^0.8.00;

interface IOCCPrice {
    function oCC_uSD() external view returns (uint);
}
// File: contracts/Interface/IERC20.sol


pragma solidity ^0.8.00;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: contracts/Rootala-Invest-Factory.sol


pragma solidity ^0.8.00;



contract RootalaInvestV01Factory{

    IERC20 occoin;
    IOCCPrice occPrice;
    
    address public factoryCreator;
    uint64 public userCounter;
    uint16 public p200ActiveUsers;
    uint16 public p500ActiveUsers;
    uint16 public p1000ActiveUsers;
    uint16 public p2000ActiveUsers;
    bool private pause;
    bool private locked;

    mapping (address=>bool) public isUser;
    mapping (address=>UserDetail) public userDetail;

    enum Package {
        p200,
        p500,
        p1000,
        p2000
    }

    struct UserDetail{
        uint dateOfJoin;
        uint investedToken;
        uint referralCreditBalance;
        uint allProfitReceived;
        uint64 userNumber;
        uint32 ratedProfit;
        uint32 referrals;
        uint received;
        address representative;
        Package package;
    }

    event result(Package indexed package,uint indexed activeUsers);


    constructor(){
        factoryCreator = msg.sender;
        occoin = IERC20(0x4665e227c521849a202f808E927d1dc5F63C7941);
        occPrice = IOCCPrice(0xC74A1022cf45802Ec3190aFb69512F83Ef898E3b);
        isUser[address(this)]=true;
    }

    modifier onlyOwner{
        require(msg.sender==factoryCreator, " only owner can do this");
        _;
    }

    modifier isInvestor{
        require(isUser[msg.sender]==true,"you are not investor!!!");
        _;
    }

    modifier paused{
        require(pause != true , "invest plan has been paused");
        _;
    }

    modifier noReentrancy{
        require(locked != true,"No Reentrancy,pls wait");
        locked = true;
        _;
        locked = false;
    }

    function register(address _referral, Package _package) public noReentrancy paused {
        require(isUser[_referral] == true,"your referral address is not true");
        require(isUser[msg.sender] != true,"you are registered befor");
        uint16 packageActiveUsers;
        if (_package == Package.p200) {
            packageActiveUsers = p200ActiveUsers;
            p200ActiveUsers ++;
            emit result(_package,packageActiveUsers);
        }else if (_package == Package.p500) {
            packageActiveUsers = p500ActiveUsers;
            p500ActiveUsers ++;
            emit result(_package,packageActiveUsers);
        }else if (_package == Package.p1000) {
            packageActiveUsers = p1000ActiveUsers;
            p1000ActiveUsers ++;
            emit result(_package,packageActiveUsers);
        }else if (_package == Package.p2000) {
            packageActiveUsers = p2000ActiveUsers;
            p2000ActiveUsers ++;
            emit result(_package,packageActiveUsers);
        }else revert("invalid package!!!");

        require(packageActiveUsers<10000,"this invest plan package is full");
        uint iPrice = investPrice(_package);
        require(occoin.balanceOf(msg.sender)>=iPrice,"low balance");
        occoin.transferFrom(msg.sender,address(this), iPrice);
        userDetail[_referral].referralCreditBalance += (iPrice * (10000-packageActiveUsers))/100000;
        userDetail[_referral].referrals++;

        UserDetail memory newUser;
        newUser.dateOfJoin = block.timestamp;
        newUser.investedToken = iPrice;
        newUser.ratedProfit = 10000-packageActiveUsers;
        newUser.representative = _referral;
        newUser.package = _package;
        newUser.userNumber = ++userCounter;
        userDetail[msg.sender] = newUser;

        isUser[msg.sender] = true;

        
    }

    function receiveProfits() public isInvestor noReentrancy {
        require(userDetail[msg.sender].received < 52,"renewal required");
        uint profitAmount = (weekCounter()*userProfitCalculator()) + userDetail[msg.sender].referralCreditBalance;
        require(profitAmount != 0,"you have no profit/credit yet!!!");
        userDetail[msg.sender].received = calcul7Days();
        userDetail[msg.sender].allProfitReceived += profitAmount;
        userDetail[msg.sender].referralCreditBalance = 0;
        occoin.transfer(msg.sender, profitAmount);
    }

    function withdrawInvestedToken() public isInvestor noReentrancy{
        require(remainingWeeks()==0,"There are still a few weeks left.");
        require(userDetail[msg.sender].received == 52,"You have not yet received your all weekly profits!");
        require(userDetail[msg.sender].referralCreditBalance == 0,"You have not yet received your referral credits!");
        occoin.transfer(msg.sender, userDetail[msg.sender].investedToken);
        if (userDetail[msg.sender].package == Package.p200) {
            p200ActiveUsers --;
        }else if (userDetail[msg.sender].package == Package.p500) {
            p500ActiveUsers --;
        }else if (userDetail[msg.sender].package == Package.p1000) {
            p1000ActiveUsers --;
        }else if (userDetail[msg.sender].package == Package.p2000) {
            p2000ActiveUsers --;
        }
        delete userDetail[msg.sender];
        delete isUser[msg.sender];

    }

    function weekCounter() public isInvestor view returns(uint creditor7Days){
        creditor7Days = calcul7Days()-userDetail[msg.sender].received;
    }

    function allActiveUsers() public view returns(uint activeUsers){
        activeUsers = p200ActiveUsers + p500ActiveUsers + p1000ActiveUsers + p2000ActiveUsers;
    }

    function calcul7Days() public isInvestor view returns(uint) {
        uint calc7Days = (block.timestamp - userDetail[msg.sender].dateOfJoin)/1 weeks;
        if (calc7Days > 52) {
            calc7Days = 52;
        }
        return calc7Days;
    }



    function profitCalculator() public view returns(uint cp1 , uint cp2 , uint cp3 , uint cp4){
        uint occP = getOccPrice();
        uint profit1 = 10000 - p200ActiveUsers;
        uint profit2 = 10000 - p500ActiveUsers;
        uint profit3 = 10000 - p1000ActiveUsers;
        uint profit4 = 10000 - p2000ActiveUsers;
        cp1 = (((5e18 * (profit1))/10000)/occP)*1e18;
        cp2 = (((125e17 * (profit2))/10000)/occP)*1e18;
        cp3 = (((25e18 * (profit3))/10000)/occP)*1e18;
        cp4 = (((50e18 * (profit4))/10000)/occP)*1e18;
    }

    function userProfitCalculator() public isInvestor view returns(uint cp){
        uint profit = userDetail[msg.sender].ratedProfit;
        uint occP = getOccPrice();
        if (userDetail[msg.sender].package == Package.p200) {
            cp = (((5e18 * (profit))/10000)/occP)*1e18;
        }else if (userDetail[msg.sender].package == Package.p500) {
            cp = (((125e17 * (profit))/10000)/occP)*1e18;
        }else if (userDetail[msg.sender].package == Package.p1000) {
            cp = (((25e18 * (profit))/10000)/occP)*1e18;
        }else if (userDetail[msg.sender].package == Package.p2000) {
            cp = (((50e18 * (profit))/10000)/occP)*1e18;
        }
    }

    function getOccPrice() public view returns (uint price){
        price = occPrice.oCC_uSD();
    }

    function investPrice(Package _package) public view returns(uint){
        Package package = _package;
        if (package == Package.p200) {
            return ((200e18) / getOccPrice()) *1e18;
        }else if (package == Package.p500) {
            return ((500e18) / getOccPrice()) *1e18;
        }else if (package == Package.p1000) {
            return ((1000e18) / getOccPrice()) *1e18;
        }else if (package == Package.p2000) {
            return ((2000e18) / getOccPrice()) *1e18;
        }else revert("invalid input");
    }



    function remainingWeeks() public isInvestor view returns(uint rw) {
        uint pw = ((block.timestamp - userDetail[msg.sender].dateOfJoin)/1 weeks);
        if (pw > 52) {
            pw = 52;
        }
        rw = 52 - pw ;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        factoryCreator = _newOwner;
    }


    function setPause() public onlyOwner{
        pause = !pause;
    }
}