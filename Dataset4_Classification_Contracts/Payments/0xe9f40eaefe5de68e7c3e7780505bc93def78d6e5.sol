// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract TokenPresale {
    IERC20 public token;
    address public owner;
    address public pendingOwner;
    uint256 public price;
    bool public saleActive;
    bool private locked;

    event Purchase(address indexed buyer, uint256 amount);
    event PriceUpdated(uint256 newPrice);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address _token, uint256 _price) {
        require(_price > 0, "Price should be greater than 0");

        token = IERC20(_token);
        owner = msg.sender;
        price = _price;
        saleActive = false;
        locked = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyPendingOwner() {
        require(
            msg.sender == pendingOwner,
            "Only pending owner can call this function"
        );
        _;
    }

    modifier noReentrancy() {
        require(!locked, "No reentrancy allowed");
        locked = true;
        _;
        locked = false;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        pendingOwner = newOwner;
    }

    function acceptOwnership() external onlyPendingOwner {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }

    function startSale() external onlyOwner {
        require(!saleActive, "Sale already active");
        saleActive = true;
    }

    function stopSale() external onlyOwner {
        require(saleActive, "Sale not active");
        saleActive = false;
    }

    function buyTokens(uint256 tokenAmount) external payable noReentrancy {
        require(saleActive, "Sale not active");
        require(tokenAmount > 0, "Cannot purchase 0 tokens");

        uint256 tokenToTransfer = tokenAmount * 10**18;
        require(
            token.balanceOf(address(this)) >= tokenToTransfer,
            "Insufficient tokens"
        );

        uint256 requiredETH = tokenAmount * price;
        require(msg.value >= requiredETH, "Insufficient ETH sent");

        token.transfer(msg.sender, tokenToTransfer);
        emit Purchase(msg.sender, tokenAmount);

        if (msg.value > requiredETH) {
            payable(msg.sender).transfer(msg.value - requiredETH);
        }
    }

    function setPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "Price should be greater than 0");
        price = _price;
        emit PriceUpdated(_price);
    }

    function withdrawETH() external onlyOwner {
        require(!saleActive, "Sale must be stopped before withdrawing ETH");
        payable(owner).transfer(address(this).balance);
    }

    function withdrawTokens() external onlyOwner {
        require(!saleActive, "Sale must be stopped before withdrawing tokens");
        token.transfer(owner, token.balanceOf(address(this)));
    }
}