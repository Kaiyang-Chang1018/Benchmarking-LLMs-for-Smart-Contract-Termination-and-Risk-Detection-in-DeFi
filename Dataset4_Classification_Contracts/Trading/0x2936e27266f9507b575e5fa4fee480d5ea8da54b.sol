// SPDX-License-Identifier: MIT

pragma solidity = 0.8.26;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Presale {
    IERC20 private _token;
    address private _owner;

    // common config
    uint256 public _totalSupply;
    uint256 public _minContribution;
    uint256 public _maxContribution;
    uint256 public _emergencyDiscountPercents;
    uint256 public _price;

    bool public _buyable;
    bool public _claimable;
    bool public _withdrawable;

    mapping(address => uint256) public _userContribution;
    uint256 public _globalContributors;

    event contributeETH(address indexed user, uint256 amountETH);
    event emergencyWithdrawETH(address indexed user, uint256 amountETH);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not owner");
        _;
    }

    constructor() {
        _owner = msg.sender;

        _totalSupply = 45_000_000_000_000 * 1e18;
        _minContribution = 0.01 * 1e18;
        _maxContribution = 10 * 1e18;
        _emergencyDiscountPercents = 20;

        _token = IERC20(0x68e686bC641605877AD72fF76a7047d7325D8D3e);

        // phase 1
        _buyable = true;
        _withdrawable = true;
        _claimable = false;
    }

    function setPhase2() external onlyOwner {
        _buyable = false;
        _withdrawable = false;
        _claimable = true;
    }

    function setMinContribution(uint256 minUserView_) external onlyOwner {
        _minContribution = minUserView_ * 1e18;
    }

    function setMaxContribution(uint256 maxUserView_) external onlyOwner {
        _maxContribution = maxUserView_ * 1e18;
    }

    function setEmergencyDiscountPercents(uint256 percents_) external onlyOwner {
        require(percents_ >= 0 && percents_ <= 100, "p");
        _emergencyDiscountPercents = percents_;
    }

    receive() external payable {
        buyTokens(msg.sender, msg.value);
    }

    fallback() external payable {
        buyTokens(msg.sender, msg.value);
    }

    function contribute() external payable {
        buyTokens(msg.sender, msg.value);
    }

    function buyTokens(address user_, uint256 ethValue_) private {
        require(_buyable, "b");
        require(ethValue_ >= _minContribution, "Min Contribution");

        uint256 userContribution = _userContribution[user_];
        require(userContribution + ethValue_ <= _maxContribution, "Max Contribution");

        unchecked {
            if (_userContribution[user_] == 0) {
                ++_globalContributors;
            }
            _userContribution[user_] = userContribution + ethValue_;
        }

        emit contributeETH(user_, ethValue_);
    }

    function setBuyable(bool buyable_) external onlyOwner {
        _buyable = buyable_;
    }

    function emergencyWithdraw() external {
        require(_withdrawable, "w");

        uint256 myTotalContribution = _userContribution[msg.sender];
        require(myTotalContribution > 0, "Contribution zero");

        unchecked {
            uint256 realEthAmount = myTotalContribution * (100 - _emergencyDiscountPercents) / 100;

            _userContribution[msg.sender] = 0;
            (bool sent, ) = msg.sender.call{value: realEthAmount}("");
            require(sent, "Send ETH fail");

            emit emergencyWithdrawETH(msg.sender, realEthAmount);
        }
    }

    function setWithdrawable(bool withdrawable_) external onlyOwner {
        _withdrawable = withdrawable_;
    }

    function claimTokens() external {
        require(_claimable, "c");

        uint256 myContribution = _userContribution[msg.sender];
        require(myContribution > 0, "Contribution zero");

        uint256 claimableTokenAmount = myContribution * _price;
        require(claimableTokenAmount > 0, "Claim amount zero");

        uint256 bal = _token.balanceOf(address(this));
        require(bal > claimableTokenAmount, "Balance zero");

        _token.transfer(msg.sender, claimableTokenAmount);
        _userContribution[msg.sender] = 0;
    }


    function setClaimable(bool claimable_) external onlyOwner {
        _claimable = claimable_;
    }

    function withdrawToken() external onlyOwner {
        _token.transfer(msg.sender, _token.balanceOf(address(this)));
    }

    function withdrawETH() external onlyOwner {
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "fc");
    }

    function setPrice(uint256 price_) external onlyOwner {
        _price = price_ > 0 ? price_ : (_totalSupply / address(this).balance);
    }
}