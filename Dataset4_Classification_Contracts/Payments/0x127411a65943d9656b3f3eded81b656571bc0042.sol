// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// proof struct
struct proof {
  address relay;
  address token;
  bytes32 tohash;
  bytes proof;
}
// IERC20 Interface
interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
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
    (bool success, bytes memory returndata) = address(token).call(data);
    require(success, "SafeERC20: low-level call failed");

    if (returndata.length > 0) {
      // Return data is optional
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}

interface Verifier {
  function verifySignature(proof memory data, uint256 nonce) external view returns (address);
  function getNonce(address user) external view returns (uint256);
}
// SafeMath Library
library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;
    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }
}

// Ownable Contract
abstract contract Ownable {
  address private _owner;
  address private _pendingOwner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event OwnershipTransferRequested(address indexed currentOwner, address indexed pendingOwner);

  constructor() {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  modifier onlyOwner() {
    require(owner() == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function owner() public view returns (address) {
    return _owner;
  }

  function requestOwnershipTransfer(address newOwner) external onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _pendingOwner = newOwner;
    emit OwnershipTransferRequested(_owner, newOwner);
  }

  function acceptOwnership() external {
    require(msg.sender == _pendingOwner, "Ownable: caller is not the pending owner");
    address oldOwner = _owner;
    _owner = _pendingOwner;
    _pendingOwner = address(0);
    emit OwnershipTransferred(oldOwner, _owner);
  }
}
contract Mixezs is Ownable {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  mapping(address => mapping(uint256 => mapping(address => uint256))) private tokenAmount;
  mapping(bytes32 => uint256) private hashToNonce;
  mapping(address => uint256) public income;
  mapping(address => uint256) private usernonce;
  address private addressVerifier;
  struct DataItem {
    uint256 nonce;
    bytes32 tohash;
    string symbol;
    uint256 decimals;
    address token;
    uint256 amount;
    uint256 time;
  }
  mapping(address => DataItem[]) private dataMap;
  address private WETH;
  uint256 private rate;
  uint256 private agentShareRatio;
  event Deposited(address indexed user, address indexed token, uint256 amount);
  event ParametersSet(uint256 agentShareRatio, uint256 rate);
  event VerifierSet(address verifier);
  constructor(address weth, uint8 _agentShareRatio) {
    WETH = weth;
    agentShareRatio = _agentShareRatio;
    rate = 1;
  }

  function withdraw(proof memory data, address to, address acting) external {
    require(data.proof.length == 65, "invalid signature length");
    require(to != address(0), "mixezs: Address cannot be zero");
    uint256 nonce = hashToNonce[data.tohash];
    address token = data.token;
    address holder = Verifier(addressVerifier).verifySignature(data, nonce);
    require(msg.sender == data.relay, "mixezs: INVALID-RELAY");
    address stealthAddress = computeStealthAddress(holder, nonce);

    uint256 amount = tokenAmount[stealthAddress][nonce][token];
    require(amount > 0, "mixezs: INSUFFICIENT_BALANCE");
    uint256 revenue = amount.mul(rate).div(100);
    uint256 agentIncome = revenue.mul(agentShareRatio).div(100);
    hashToNonce[data.tohash] = 0;
    tokenAmount[stealthAddress][nonce][token] = 0;
    removeDataByNonce(holder, nonce);
    if (address(token) == WETH) {
      payable(to).transfer(amount.sub(revenue));
      if (address(acting) != address(0)) {
        payable(acting).transfer(agentIncome);
      } else {
        agentIncome = 0;
      }
    } else {
      IERC20(token).safeTransfer(to, amount.sub(revenue));
      if (address(acting) != address(0)) {
        IERC20(token).safeTransfer(acting, agentIncome);
      } else {
        agentIncome = 0;
      }
    }
    income[address(token)] += revenue.sub(agentIncome);
  }

  function deposit(address token, uint256 amount) external payable {
    usernonce[msg.sender]++;
    uint256 currentNonce = uint256(keccak256(abi.encodePacked(block.timestamp, usernonce[msg.sender], Verifier(addressVerifier).getNonce(msg.sender))));
    address stealthAddress = computeStealthAddress(msg.sender, currentNonce);
    if (address(token) == WETH) {
      require(msg.value > 0 && amount == msg.value, "mixezs: Send error");
      tokenAmount[stealthAddress][currentNonce][token] = msg.value;
    } else {
      require(amount > 0 && msg.value == 0, "mixezs: Send error");
      IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
      tokenAmount[stealthAddress][currentNonce][token] = amount;
    }

    IERC20 erc20 = IERC20(token);
    bytes32 noncehash = keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp, msg.sender));
    hashToNonce[noncehash] = currentNonce;

    DataItem memory newItem = DataItem({nonce: currentNonce, tohash: noncehash, symbol: erc20.symbol(), decimals: erc20.decimals(), token: token, amount: amount, time: block.timestamp});
    dataMap[msg.sender].push(newItem);
    emit Deposited(msg.sender, token, amount);
  }

  function removeDataByNonce(address form, uint256 nonce) internal {
    DataItem[] storage userDataArray = dataMap[form];
    uint256 length = userDataArray.length;
    for (uint256 i = 0; i < length; i++) {
      if (userDataArray[i].nonce == nonce) {
        userDataArray[i] = userDataArray[length - 1];
        userDataArray.pop();
        return;
      }
    }
  }

  function getMyData(bytes memory bytehash, bytes memory signature) external view returns (DataItem[] memory) {
    address signer = recoverSigner(bytehash, signature);

    require(signer == msg.sender, "mixezs: Invalid signature");

    return dataMap[msg.sender];
  }

  function recoverSigner(bytes memory bytehash, bytes memory signature) internal pure returns (address) {
    require(signature.length == 65, "mixezs: Invalid signature length");

    bytes32 tohash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", bytehash));

    bytes32 r;
    bytes32 s;
    uint8 v;

    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    return ecrecover(tohash, v, r, s);
  }

  function computeStealthAddress(address user, uint256 nonce) internal pure returns (address) {
    return address(uint160(uint256(keccak256(abi.encodePacked(user, nonce)))));
  }

  function setParameters(uint256 agentshareratioinput, uint256 rateinput) external onlyOwner {
    require(agentshareratioinput <= 10 && rateinput <= 10, "mixezs: The handling fee is too high");
    rate = rateinput;
    agentShareRatio = agentshareratioinput;
    emit ParametersSet(agentshareratioinput, rateinput);
  }

  function setverifier(address verifier) external onlyOwner {
    addressVerifier = verifier;
    emit VerifierSet(verifier);
  }

  function claim(address token, address to) external onlyOwner {
    require(to != address(0), "mixezs: Address cannot be zero");
    if (address(token) == WETH) {
      require(address(this).balance >= income[address(token)], "mixezs: Insufficient balance");
      payable(to).transfer(income[address(token)]);
    } else {
      require(IERC20(token).balanceOf(address(this)) >= income[address(token)], "mixezs: Insufficient balance");
      IERC20(token).safeTransfer(to, income[address(token)]);
    }
    income[address(token)] = 0;
  }
  receive() external payable {}

  fallback() external payable {}
}