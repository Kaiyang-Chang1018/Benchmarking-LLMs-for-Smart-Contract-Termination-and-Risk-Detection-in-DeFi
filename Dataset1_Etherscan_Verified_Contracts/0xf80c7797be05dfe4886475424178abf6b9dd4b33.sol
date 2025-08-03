// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;


interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
}


contract BulkTransfer {
    address public owner;
    mapping(address => bool) public inWhitelist;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event InWhitelist(address indexed addr, bool status);
    event FailedTransfer(address indexed token, address indexed to, uint256 value);
    event BNBRecovered(address indexed recipient, uint256 amount);
    event ERC20Recovered(address indexed token, address indexed recipient, uint256 amount);


    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    modifier onlyWhitelist {
        require(inWhitelist[msg.sender], "Only the whitelister can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        inWhitelist[msg.sender] = true;
        emit InWhitelist(msg.sender, true);
    }

    receive() external payable {
        // This function allows the contract to receive BNB
    }


    function transferBNB(address[] calldata recipients, uint256[] calldata amounts) public payable {
        require(recipients.length == amounts.length, "Array lengths do not match");

        uint256 total;
        for (uint256 i = 0; i < amounts.length; i++) {
            total += amounts[i];
        }
        require(total == msg.value, "Msg.value does not match");
      
        for (uint256 i = 0; i < recipients.length; i++) {
            (bool success, ) = recipients[i].call{value: amounts[i]}("");
            if (!success) {
                emit FailedTransfer(address(0), recipients[i], amounts[i]);
                // Refund the amount to the sender if the transfer fails
                (bool refundSuccess, ) = payable(msg.sender).call{value: amounts[i]}("");
                require(refundSuccess, "Refund failed");
            }
        }
    }

    // Bulk transfer tokens
    function transferTokens(address[] calldata tokens, address[] calldata recipients, uint256[] calldata amounts) public {
        require(tokens.length == recipients.length, "Array lengths do not match");
        require(recipients.length == amounts.length, "Array lengths do not match");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Cannot transfer to zero address");
            require(tokens[i] != address(0), "Cannot transfer token at zero address");

            IERC20 token = IERC20(tokens[i]);
            (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(token.transferFrom.selector, msg.sender, recipients[i], amounts[i]));
            if (!success || abi.decode(data, (bool)) == false) {
                emit FailedTransfer(tokens[i], recipients[i], amounts[i]);
            }
        }
    }


    // Transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }


    // Manage whitelist
    function manageWhitelist(address addr, bool status) public onlyOwner {
        require(addr != address(0), "Zero address");
        inWhitelist[addr] = status;
        emit InWhitelist(addr, status);
    }


    // Recover BNB
    function recoverBNB(address payable recipient) external onlyWhitelist {
        require(recipient != address(0), "Cannot send to zero address");
        uint256 balance = address(this).balance;
        (bool success, ) = payable(recipient).call{value: balance}("");
        require(success, "Transfer failed");
        emit BNBRecovered(recipient, balance);
    }

    // Recover ERC20 tokens
    function recoverERC20Tokens(address token, address recipient) external onlyWhitelist {
        require(recipient != address(0), "Cannot send to zero address");
        
        uint256 amount = IERC20(token).balanceOf(address(this));
        if (amount > 0) {
            // Low-level call to the transfer function to ensure compatibility with transfer functions that have or do not have a return value.
            (bool success, bytes memory data) = token.call(
                abi.encodeWithSelector(IERC20(token).transfer.selector, recipient, amount)
            );
            require(success && (data.length == 0 || abi.decode(data, (bool))), "Transfer failed");

            emit ERC20Recovered(token, recipient, amount);
        }
    }
}