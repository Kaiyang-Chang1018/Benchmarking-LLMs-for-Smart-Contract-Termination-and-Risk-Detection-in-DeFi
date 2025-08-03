// File: ethereum/IERC20Token.sol



pragma solidity 0.8.7;

interface IERC20Token {
    function mint(address account, uint256 value) external;
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}
// File: ethereum/IBridgeLog.sol



pragma solidity 0.8.7;

interface IBridgeLog {
  function outgoing(address _wallet, uint256 _amount, uint256 _fee, uint256 _chainID, uint256 _bridgeIndex) external;
  function incoming(address _wallet, uint256 _amount, uint256 _fee, uint256 _chainID, uint256 _logIndex, bytes32 _txHash) external;
  function withdrawalCompleted(bytes32 _withdrawalId) external view returns (bool completed);
}
// File: ethereum/Managed.sol



// This contract stores and verify accounts with administratives privileges

pragma solidity 0.8.7;

contract Managed {
  event AddManager(address Wallet);
  event RemoveManager(address Wallet);
  mapping(address => bool) public managers;
  modifier onlyManagers() {
    require(managers[msg.sender] == true, "Caller is not manager");
    _;
  }
  constructor() {
    managers[msg.sender] = true;
    emit AddManager(msg.sender);
  }
  function setManager(address _wallet, bool _manager) public onlyManagers {
    require(_wallet != msg.sender, "Not allowed");
    require(_wallet != address(0), "Invalid address");
    managers[_wallet] = _manager;
    if (_manager) {
      emit AddManager(_wallet);
    } else {
      emit RemoveManager(_wallet);
    }
  }
}
// File: ethereum/POLCBridgeTransfers.sol



pragma solidity 0.8.7;




contract POLCBridgeTransfers is Managed {
  event NewTransfer(address indexed sender, uint256 chainTo, uint256 amount);
  event VaultChange(address vault);
  event FeeChange(uint256 fee);
  event TXLimitChange(uint256 minTX, uint256 maxTX);
  event LoggerChange(address _logger);
  event ChainUpdate(uint256 chain, bool available);
  event PauseTransfers(bool paused);

  address public polcVault;
  address public polcTokenAddress;
  uint256 public bridgeFee;
  IERC20Token private polcToken;
  uint256 public depositIndex;
  IBridgeLog public logger;
  bool public paused;
  
  struct Deposit {
      address sender;
      uint256 amount;
      uint256 fee;
      uint256 chainTo;
  } 
  
  mapping (uint256 => Deposit) public deposits;
  mapping (address => bool) public whitelisted;
  mapping (uint256 => bool) public chains;
  uint256 public maxTXAmount = 25000 ether;
  uint256 public minTXAmount = 50 ether;
    
  constructor() {
    polcTokenAddress = 0xaA8330FB2B4D5D07ABFE7A72262752a8505C6B37;
    logger = IBridgeLog(0x303bAA0Ef71F1882Ed0Ca7Abe296a642F62Ddf02);
    polcToken = IERC20Token(polcTokenAddress);
    polcVault = 0xf7A9F6001ff8b499149569C54852226d719f2D76;
    bridgeFee = 1;
    whitelisted[0xf7A9F6001ff8b499149569C54852226d719f2D76] = true;
    whitelisted[0xeA50CE6EBb1a5E4A8F90Bfb35A2fb3c3F0C673ec] = true;
    whitelisted[0x00d6E1038564047244Ad37080E2d695924F8515B] = true;
    managers[0x00d6E1038564047244Ad37080E2d695924F8515B] = true;
    chains[56] = true;
    chains[112358] = true;
    depositIndex = 1;
  }

  function bridgeSend(uint256 _amount, uint256 _chainTo) public {
    require((_amount>=(minTXAmount) && _amount<=(maxTXAmount)), "Invalid amount");
    uint256 fee;
    if (bridgeFee > 0) {
      fee = (_amount * bridgeFee) /100;  // bridge transaction fee
    }
    _bridge(msg.sender, _amount, fee, _chainTo);
  }
    
  function platformTransfer(uint256 _amount, uint256 _chainTo) public {
    require(whitelisted[msg.sender] == true, "Not allowed");
    _bridge(msg.sender, _amount, 0, _chainTo);
  }

  function _bridge(address _wallet, uint256 _amount, uint256 _fee, uint256 _chainTo) private {
    require(chains[_chainTo] == true, "Invalid chain");
    require(!paused, "Contract is paused");
    require(polcToken.transferFrom(msg.sender, polcVault, _amount), "ERC20 transfer error");
    deposits[depositIndex].sender = _wallet;
    deposits[depositIndex].amount = _amount;
    deposits[depositIndex].fee = _fee;
    deposits[depositIndex].chainTo = _chainTo;
    logger.outgoing(_wallet, _amount, _fee, _chainTo, depositIndex);
    depositIndex += 1;
    emit NewTransfer(_wallet, _chainTo, _amount);
  }
       
  function setVault(address _vault) public onlyManagers {
    require(_vault != address(0), "Invalid address");
    polcVault = _vault;
    emit VaultChange(_vault);
  }
  
  function setFee(uint256 _fee) public onlyManagers {
    require(_fee <= 5, "Fee too high");
    bridgeFee = _fee;   
    emit FeeChange(_fee);
  }
      
  function setMaxTXAmount(uint256 _amount) public onlyManagers {
    require(_amount > 10000 ether, "Max amount too low");
    maxTXAmount = _amount;
    emit TXLimitChange(minTXAmount, maxTXAmount);
  }
  
  function setMinTXAmount(uint256 _amount) public onlyManagers {
    require(_amount < 1000 ether, "Min amount too high");
    minTXAmount = _amount;
    emit TXLimitChange(minTXAmount, maxTXAmount);
  }

  function whitelistWallet(address _wallet, bool _whitelisted) public onlyManagers {
    whitelisted[_wallet] = _whitelisted;
  }

  function setLogger (address _logger) public onlyManagers {
    require(_logger != address(0), "Invalid address");
    logger = IBridgeLog(_logger);
    emit LoggerChange(_logger);
  }

  function setChain(uint256 _chain, bool _available) public onlyManagers {
    chains[_chain] = _available;
    emit ChainUpdate(_chain, _available);
  }
    
  function pauseBridge(bool _paused) public onlyManagers {
    paused = _paused;
    emit PauseTransfers(_paused);
  }
}