// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in construction,
        // since the code is only stored at the end of the constructor execution.
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ConsensusBridgeDChainSafe {
    using SafeERC20 for IERC20;

    address private validatorConsensusGovernanceAccountAddress;
    address private validatorConsensusAlgorythmAccountAddress;

    event Deposit(address indexed sender, address tokenAddress, uint256 amount);
    event Redeem(address indexed user, address tokenAddress, uint256 amount, bytes32 hash);
    event ConstructorDebug(address validatorConsensusGovernanceAccountAddress, address validatorConsensusAlgorythmAccountAddress);

    constructor(address validatorConsensusAlgorythmAccountAddress_) {
        require(validatorConsensusAlgorythmAccountAddress_ != address(0), "validatorConsensusAlgorythmAccountAddress_ cannot be zero address");

        validatorConsensusGovernanceAccountAddress = msg.sender;
        validatorConsensusAlgorythmAccountAddress = validatorConsensusAlgorythmAccountAddress_;

        emit ConstructorDebug(validatorConsensusGovernanceAccountAddress, validatorConsensusAlgorythmAccountAddress);
    }

    mapping (bytes32 => bool) redeemed;

    receive() external payable {
        revert("cannot send eth directly...");
    }

    function deposit() external payable {
        emit Deposit(msg.sender, address(0), msg.value);
    }

    function depositForUser(address user) external payable {
        emit Deposit(user, address(0), msg.value);
    }

    function depositToken(address tokenAddress, uint256 amount) public {
        require(tokenAddress != address(0), "Token address cannot be zero");

        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, tokenAddress, amount);
    }

    function depositTokenForUser(address tokenAddress, address user, uint256 amount) public {
        require(tokenAddress != address(0), "Token address cannot be zero");

        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), amount);

        emit Deposit(user, tokenAddress, amount);
    }

    function redeem(address user, address tokenAddress, uint256 amount, bytes32 hash) public onlyValidatorConsensusAlgorythmAccountAddress {
        require(!redeemed[hash], "Redeem hash already used");
        redeemed[hash] = true;

        if (tokenAddress == address(0)) {
            payable(user).transfer(amount);
        } else {
            IERC20(tokenAddress).safeTransfer(user, amount);
        }        

        emit Redeem(user, tokenAddress, amount, hash);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function setValidatorConsensusAlgorythmAccountAddress(address validatorConsensusAlgorythmAccountAddress_) public onlyValidatorConsensusGovernanceAccountAddress {
        require(validatorConsensusAlgorythmAccountAddress_ != address(0), "validatorConsensusAlgorythmAccountAddress_ cannot be zero address");
        validatorConsensusAlgorythmAccountAddress = validatorConsensusAlgorythmAccountAddress_;
    }

    function transferOwnership(address newGovernanceAccountAddress) public onlyValidatorConsensusGovernanceAccountAddress {
        require(newGovernanceAccountAddress != address(0), "invalid address");
        validatorConsensusGovernanceAccountAddress = newGovernanceAccountAddress;
    }

    modifier onlyValidatorConsensusGovernanceAccountAddress() {
        require(msg.sender == validatorConsensusGovernanceAccountAddress, "access denied");
        _;
    }

    modifier onlyValidatorConsensusAlgorythmAccountAddress() {
        require(msg.sender == validatorConsensusAlgorythmAccountAddress, "access denied");
        _;
    }
}