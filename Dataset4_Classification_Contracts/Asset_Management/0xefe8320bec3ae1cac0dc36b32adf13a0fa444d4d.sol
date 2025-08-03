// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.8.0

// SPDX-License-Identifier: MIT

// File contracts/interfaces/IUSDB.sol

pragma solidity ^0.8.9;

interface IUSDB {
    function mintTo(address account, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);

    event TokenMinted(address account, uint256 amount);
    event TokenBurned(address account, uint256 amount);
}


// File contracts/MintGuard.sol

pragma solidity ^0.8.9;

contract MintGuard {

  address private _owner;
  address private _currentMintAddress;
  uint256 private _currentMintAmount;
  uint256 private _currentMintApprovals;
  uint256 private _mintThreshold;
  mapping(address => bool) public _requesters;
  mapping(address => bool) public _approvers;

  address private _usdbAddress;

  modifier onlyRequester() {
    require(_requesters[msg.sender], "MintGuard: not requester");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == _owner, "MintGuard: not owner");
    _;
  }

  modifier onlyApprover() {
    require(_approvers[msg.sender], "MintGuard: not approver");
    _;
  }

  constructor() {
    _owner = msg.sender;
  }

  function getCurrentMint() public view returns (address, uint256) {
    return (_currentMintAddress, _currentMintAmount);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _owner = newOwner;
  }

  function setUSDBAddress(address usdbAddress) public onlyOwner {
    _usdbAddress = usdbAddress;
  }

  function adjustApprover(address approver, bool approved) public onlyOwner {
    _approvers[approver] = approved;
  }

  function adjustMinThreshold(uint256 threshold) public onlyOwner {
    _mintThreshold = threshold;
  }

  function adjustRequester(address requester, bool approved) public onlyOwner {
    _requesters[requester] = approved;
  }

  function requestMint(address mintAddress, uint256 mintAmount) public onlyRequester {
    _currentMintAddress = mintAddress;
    _currentMintAmount = mintAmount;
    _currentMintApprovals = 0;
  }

  function approveMint(address mintAddress, uint256 mintAmount) public onlyApprover {
    require(mintAddress == _currentMintAddress, "MintGuard: mint address mismatch");
    require(mintAmount == _currentMintAmount, "MintGuard: mint amount mismatch");
    _currentMintApprovals += 1;
    if (_currentMintApprovals >= _mintThreshold) {
      _mint(_currentMintAddress, _currentMintAmount);
    }
  }

  function _mint(address recipient, uint256 amount) internal {
    IUSDB(_usdbAddress).mintTo(recipient, amount);
    _currentMintAddress = address(0);
    _currentMintAmount = 0;
    _currentMintApprovals = 0;
  }

}