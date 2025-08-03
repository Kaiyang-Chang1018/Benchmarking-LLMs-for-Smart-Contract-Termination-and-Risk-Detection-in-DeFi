// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

//////////////////////////////
//  Created by PREME Token  //
//     for collaboration    //
// visit www.premetoken.com //
//////////////////////////////

// Interface for interacting with Router V2
interface IRouterV2 {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function getAmountsOut(
        uint amountIn,
        address[] memory path
    )external view returns (uint[] memory amounts);
}

// Interface for interacting with token contract
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract PTCSwapper {
    address constant public PTC = 0x1776c8ba4883B7e8F710E8F7b68646788340C177;
    address constant public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address[] public path;
    address private _owner;
    IRouterV2 public Router;
    bool public isActivated;
    bool public supportingFeeOnTransferTokens;
    bool public useMinAmountOut;
    uint256 public minAmountOutPercentage; // 10000 = 100%

    event ChangedRouter(address indexed router);
    event ChangedIsActivated(bool indexed isActivated);
    event ChangedUseMinAmountOut(bool indexed useMinAmountOut);
    event ChangedSupportingFeeOnTransferTokens(bool indexed supportingFeeOnTransferTokens);
    event ChangedMinAmountOutPercentage(uint256  indexed minAmountOutPercentage);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid owner");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Unauthorized Account");
        _;
    }

    constructor () 
    {
        _transferOwnership(msg.sender);
        Router = IRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        isActivated = true;
        useMinAmountOut = true;
        minAmountOutPercentage = 9800;
        supportingFeeOnTransferTokens = true;
        path = new address[](2);
        path[0] = WETH;
        path[1] = PTC;
    }

    // Function to activate or deactivate the swapper contract
    function changeIsActivated(bool _isActivated) public onlyOwner {
        isActivated = _isActivated;
        emit ChangedIsActivated(_isActivated);
    }
    
    // Function to specify if minAmountOut is used on swap
    function changeUseMinAmountOut(bool _useMinAmountOut) public onlyOwner {
        useMinAmountOut = _useMinAmountOut;
        emit ChangedUseMinAmountOut(_useMinAmountOut);
    }

    // Function to change the use router
    function changeRouter(address _router) public onlyOwner {
        Router = IRouterV2(_router);
        emit ChangedRouter(_router);
    }
    
    // Function to specify which swap method will be used
    function changeSupportingFeeOnTransferTokens(bool _supportingFeeOnTransferTokens) public onlyOwner {
        supportingFeeOnTransferTokens = _supportingFeeOnTransferTokens;
        emit ChangedSupportingFeeOnTransferTokens(_supportingFeeOnTransferTokens);
    }

    // Function to specify minAmountOut percentage (10,000 = 100%)
    function changeMinAmountOutPercentage(uint256 _minAmountOutPercentage) public onlyOwner {
        require(_minAmountOutPercentage <= 10000, "Min amount can't increase 100%");
        minAmountOutPercentage = _minAmountOutPercentage;
        emit ChangedMinAmountOutPercentage(_minAmountOutPercentage);
    }
    
    // Internal function to swap on router V2
    function swapETHforTokens(address msgsender, uint256 amountETH) private {
        uint256 amountOutMin;
        if (useMinAmountOut) amountOutMin = Router.getAmountsOut(amountETH, path)[1] * minAmountOutPercentage / 10000;
        // Swap ETH to Token with tax
        if (supportingFeeOnTransferTokens) {
            Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountETH}(amountOutMin, path, msgsender, block.timestamp);
        // Swap ETH to Token without tax
        } else {
            Router.swapExactETHForTokens{value: amountETH}(amountOutMin, path, msgsender, block.timestamp);      
        }
    }

    // Function to withdraw stranded token
    function withdrawTokens(address _token) external onlyOwner {
        require(IERC20(_token).balanceOf(address(this)) > 0, "No tokens available for withdraw");
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

    // Allows contract to receive ETH if activated
    receive() external payable {
        require(isActivated, "Contract is not activated");
        swapETHforTokens(msg.sender,msg.value);
    }
}