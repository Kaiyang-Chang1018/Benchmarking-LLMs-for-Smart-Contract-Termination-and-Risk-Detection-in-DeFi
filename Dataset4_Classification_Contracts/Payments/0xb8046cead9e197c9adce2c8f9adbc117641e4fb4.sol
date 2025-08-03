// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract PrizeDistributor {
    uint256 totalUsdt;
    uint256 totalWeth;

    uint256 totalAwardee;
    address owner;

    IERC20 usdt;
    IERC20 weth;

    address[] awardees;
    mapping(address => bool) claimed;

    constructor(
        address _usdt,
        address _weth,
        uint256 _usdtAmount,
        uint256 _wethAmount,
        address[] memory _awardees
    ) {
        owner = tx.origin;
        usdt = IERC20(_usdt);
        weth = IERC20(_weth);

        awardees = _awardees;
        totalUsdt = _usdtAmount;
        totalWeth = _wethAmount;
    }

    function getMyPrize() external {
        require(isAwardee(tx.origin), "You are not in the awardees list");
        require(!claimed[tx.origin], "Prize already claimed");

        uint256 partUsdt = totalUsdt / 6;
        uint256 partWeth = totalWeth / 6;
        require(usdt.transfer(tx.origin, partUsdt), "USDT transfer failed");
        require(weth.transfer(tx.origin, partWeth), "WETH transfer failed");
        claimed[tx.origin] = true;
    }

    function finish() external {
        require(msg.sender == owner);
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            require(usdt.transfer(owner, usdtBalance), "USDT transfer failed");
        }
        uint256 wethBalance = weth.balanceOf(address(this));
        if (wethBalance > 0) {
            require(weth.transfer(owner, wethBalance), "WETH transfer failed");
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            (bool sent, ) = payable(owner).call{value: ethBalance}("");
            require(sent, "ETH transfer failed");
        }
    }

    function isAwardee(address _addr) public view returns (bool) {
        for (uint256 i = 0; i < 6; i++) {
            if (awardees[i] == _addr) {
                return true;
            }
        }
        return false;
    }
}

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}