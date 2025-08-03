pragma solidity ^0.5.16;

/**
 * @title ERC 20 Token Standard Interface
 *  https://eips.ethereum.org/EIPS/eip-20
 */
interface EIP20Interface {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    /**
      * @notice Get the total number of tokens in circulation
      * @return The supply of tokens
      */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Gets the balance of the specified address
     * @param owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
      * @notice Transfer `amount` tokens from `msg.sender` to `dst`
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      * @return Whether or not the transfer succeeded
      */
    function transfer(address dst, uint256 amount) external returns (bool success);

    /**
      * @notice Transfer `amount` tokens from `src` to `dst`
      * @param src The address of the source account
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      * @return Whether or not the transfer succeeded
      */
    function transferFrom(address src, address dst, uint256 amount) external returns (bool success);

    /**
      * @notice Approve `spender` to transfer up to `amount` from `src`
      * @dev This will overwrite the approval amount for `spender`
      *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
      * @param spender The address of the account which may transfer tokens
      * @param amount The number of tokens that are approved (-1 means infinite)
      * @return Whether or not the approval succeeded
      */
    function approve(address spender, uint256 amount) external returns (bool success);

    /**
      * @notice Get the current allowance from `owner` for `spender`
      * @param owner The address of the account which owns the tokens to be spent
      * @param spender The address of the account which may transfer tokens
      * @return The number of tokens allowed to be spent (-1 means infinite)
      */
    function allowance(address owner, address spender) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}
pragma solidity >=0.5.16;
pragma experimental ABIEncoderV2;

import "./EIP20Interface.sol";

contract DividendRecordsV2 {
    /// @notice ESG token
    EIP20Interface public esg;

    /// @notice Emitted when ESG is claimed 
    event EsgClaimed(address account, uint userAmount, address wallet1, uint feeAmount1, address wallet2, uint feeAmount2, address wallet3, uint feeAmount3);
    event FeeRateChanged(uint feeRate1, uint feeRate2, uint feeRate3);
    event FeeWalletChanged(address wallet1, address wallet2, address wallet3);

    address public _marketingWalletAddress1;
    address public _marketingWalletAddress2;
    address public _marketingWalletAddress3;
    uint256 public _feeRate1 = 5;
    uint256 public _feeRate2 = 5;
    uint256 public _feeRate3 = 5;
    mapping (address => uint256) public bonuslist;
    address public owner;

    constructor(address esgAddress, address _marketingWallet1, address _marketingWallet2, address _marketingWallet3) public {
        owner = msg.sender;
        _marketingWalletAddress1 = _marketingWallet1;
        _marketingWalletAddress2 = _marketingWallet2;
        _marketingWalletAddress3 = _marketingWallet3;
        esg = EIP20Interface(esgAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function setFeeRate(uint256 _fee1, uint256 _fee2, uint256 _fee3) onlyOwner public {
        require(_fee1 <= 100 && _fee2 <= 100 && _fee3 <= 100 && _fee1 + _fee2 + _fee3 <=100, "Fee rate must be less than or equal to 100%");
        _feeRate1 = _fee1;
        _feeRate2 = _fee2;
        _feeRate3 = _fee3;
        emit FeeRateChanged(_fee1, _fee2, _fee3);
    }

    function setFeeWallets(address _wallet1, address _wallet2, address _wallet3) onlyOwner public {
        require(_wallet1 != address(0) && _wallet2 != address(0) && _wallet3 != address(0), "Invalid address");
        _marketingWalletAddress1 = _wallet1;
        _marketingWalletAddress2 = _wallet2;
        _marketingWalletAddress3 = _wallet3;
        emit FeeWalletChanged(_wallet1, _wallet2, _wallet3);
    }

    function setEsgAmount(address[] memory _to, uint256[] memory _amount) onlyOwner public returns (bool) {
        require(_to.length == _amount.length, "The length of the two arrays must be the same");
        for (uint256 i = 0; i < _to.length; i++) {
            bonuslist[_to[i]] += _amount[i];
        }
        return true;
    }

    function claim() public returns (bool) {
        require(bonuslist[msg.sender] > 0, "No locked amount.");
        uint256 totalAmount = bonuslist[msg.sender];
        bonuslist[msg.sender] = 0;
        uint256 feeWallet1 = totalAmount * _feeRate1 / 100;
        uint256 feeWallet2 = totalAmount * _feeRate2 / 100;
        uint256 feeWallet3 = totalAmount * _feeRate3 / 100;
        uint256 userAmount = totalAmount - feeWallet1 - feeWallet2 - feeWallet3;
        
        esg.transfer(_marketingWalletAddress1, feeWallet1);
        esg.transfer(_marketingWalletAddress2, feeWallet2);
        esg.transfer(_marketingWalletAddress3, feeWallet3);
        esg.transfer(msg.sender, userAmount);

        emit EsgClaimed(msg.sender, userAmount, _marketingWalletAddress1, feeWallet1, _marketingWalletAddress2, feeWallet2, _marketingWalletAddress3, feeWallet3);
        return true;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }
}