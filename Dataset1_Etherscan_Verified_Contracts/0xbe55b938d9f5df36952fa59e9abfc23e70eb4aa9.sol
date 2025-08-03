// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract GasRelayWithdrawalSystem {
    address public owner;
    IERC20 public token;
    address public gasFeeCoverWallet;
    
    uint public feeUsdt = 15 * 10**6;// USDT for withdraw fees
    uint public minWithdrawLimit = 100 * 10**6;// Min USDT for withdraw

    constructor(address _tokenAddress, address _gasFeeCoverWallet) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
        gasFeeCoverWallet = _gasFeeCoverWallet;
    }

    // Event to log withdrawals
    event Withdrawal(address indexed from, address indexed to, uint256 value);
    event InternalTransfer(address indexed from, address indexed to, uint256 value);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier onlyFeeCoverWallet() {
        require(msg.sender == gasFeeCoverWallet || msg.sender == owner, "Caller is not the owner or fee cover wallet");
        _;
    }

    function setOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // Function to allow the owner to change the gas fee cover wallet
    function setGasFeeCoverWallet(address _newWallet) external onlyOwner {
        gasFeeCoverWallet = _newWallet;
    }

    function setWithdrawUsdtFees(uint256 _feeUsdt) external onlyOwner {
        require(minWithdrawLimit > _feeUsdt, "Fees should be less than minimum withdrawal");
        feeUsdt = _feeUsdt;
    }

    function setWithdrawUsdtMinLimit(uint256 _minWithdrawLimit) external onlyOwner {
        require(_minWithdrawLimit > feeUsdt, "Minimum withdrawal limit should be greater than fees");
        minWithdrawLimit = _minWithdrawLimit;
    }

    // Withdraw function called by the user or backend on behalf of the user
    // It requires pre-approval of the token transfer from the user's wallet
    function withdraw(address userWallet, address recipient, uint256 amount) external onlyFeeCoverWallet {
        require(minWithdrawLimit <= amount, "Withdraw amount should be greater than or equal minimum withdrawal");
        token.transferFrom(userWallet, recipient, amount - feeUsdt);
        token.transferFrom(userWallet, gasFeeCoverWallet, feeUsdt);
        emit Withdrawal(userWallet, recipient, amount);
    }

    function internalTransfer(address userWallet, address recipient, uint256 amount) external onlyFeeCoverWallet {
        require(0 < amount, "Amount should be greater than zero");
        token.transferFrom(userWallet, recipient, amount);
        emit InternalTransfer(userWallet, recipient, amount);
    }


    // Emergency function to allow owner to withdraw tokens (for safety and contract migration purposes)
    function ownerWithdrawERC20(address _tokenContract, uint256 _amount) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        require(tokenContract.transfer(msg.sender, _amount), "Withdraw failed");
    }
    
    /**
     * @dev Withdraws Eth (Ether) from the contract.
     * @param _amount Amount of Eth to withdraw.
     */
    function withdrawEth(uint _amount) external onlyOwner {
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Withdrawal failed");
    }

}