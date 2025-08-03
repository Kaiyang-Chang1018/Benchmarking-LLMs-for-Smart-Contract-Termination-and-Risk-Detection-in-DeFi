// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;


interface ERC20 {

    function _maxWalletSize() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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


contract LushExchange {

    address public deployer;
    address public oldTokenContract = 0xdc247546a6551117c8Ea82DB2Cc0AD6e048e5f6e;
    address public lushV2Address;
    mapping(address => uint256) public tokenAllocation;
    bool isActive;
    

    constructor(address _lushV2Address) payable {
        deployer = msg.sender;
        lushV2Address = _lushV2Address;
    }

    /// @notice User calls this function to exchange tokens 1:1
    function claimTokenExchange() external{
        require(isActive  == true, "Not active yet");
        uint256 exchangeAlloc = tokenAllocation[msg.sender];
        require(exchangeAlloc  > 0, "Nothing to claim");
        uint256 oldTokenWalletBalance = ERC20(oldTokenContract).balanceOf(msg.sender);
        require(oldTokenWalletBalance  > 0, "Empty Wallet");


        uint256 tokensToExchange = 0;
        if(exchangeAlloc >= oldTokenWalletBalance){
            tokensToExchange = oldTokenWalletBalance;
        }
        else{
            tokensToExchange = exchangeAlloc;
        }


        ERC20(oldTokenContract).transferFrom(msg.sender, address(this), tokensToExchange);
        tokenAllocation[msg.sender] = tokenAllocation[msg.sender] - tokensToExchange;
        ERC20(lushV2Address).transfer(msg.sender, tokensToExchange);
    }

//////////////////////////////////////////////////////////Admin Functions////////////////////////////////////////////////

    /// @notice Airdrop LushV2 to old Lush token holders
    /// @param recipients Array of wallets
    /// @param values LushV1 balances corresponding to each wallet
    function disperseAirdrop(address[] memory recipients, uint256[] memory values) external {
        require(msg.sender  == deployer, "No permission");
        require(recipients.length  == values.length, "Invalid Data");

        for (uint8 i = 0; i < recipients.length; i++)
        {
            uint256 transferAmount=values[i]*10**18;
             require(ERC20(lushV2Address).transfer(recipients[i], transferAmount));
        }
    }


    /// @notice Upload LushV1 vesting wallet allocations
    /// @param walletAddresses Array of wallets
    /// @param walletAmounts LushV1 balances corresponding to each wallet
    function uploadTokenAllocationData(address[] memory walletAddresses, uint256[] memory walletAmounts) external{
        require(msg.sender  == deployer, "No permission");
        require(walletAddresses.length  == walletAmounts.length, "Invalid Data");
        require(isActive  == false, "Can only upload balances prior to start of activation");

        for (uint8 i = 0; i < walletAddresses.length; i++) {
            tokenAllocation[walletAddresses[i]] = walletAmounts[i]*10**18;
        }
    }


    /// @notice Execute this function after finished calling uploadTokenAllocationData
    function activateExchange() external{
        require(msg.sender  == deployer, "No permission");
        isActive = true;
    }

    /// @notice Emergency withdrawal function
    function extractRemainingLush() external {
        require(msg.sender  == deployer, "No permission");
        uint256 lushContractBalance = ERC20(lushV2Address).balanceOf(address(this));
        ERC20(lushV2Address).transfer(deployer, lushContractBalance);
    }   


    receive() external payable {

    }
}