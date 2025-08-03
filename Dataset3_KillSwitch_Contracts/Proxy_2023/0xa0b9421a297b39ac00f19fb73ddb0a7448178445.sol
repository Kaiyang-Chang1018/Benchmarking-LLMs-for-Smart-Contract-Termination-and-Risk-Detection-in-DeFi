// SPDX-License-Identifier: MIT
  
pragma solidity ^0.8.23;

contract Publisher {

  event Published( string val, bool flag );

  address payable _publisher;

  modifier isPublisher {
    if (msg.sender != _publisher) {
      revert( "publisher only" );
    }
    _;
  }

  constructor() {
    _publisher = payable(msg.sender);
  }

  receive() external payable {}
  fallback() external payable {}

  function publish( string memory val, bool flag ) external isPublisher {
    emit Published( val, flag );
  }

  function chown( address payable newpub ) external isPublisher {
    _publisher = newpub;
  }

  function sweep() external isPublisher {
    _publisher.transfer( address(this).balance );
  }

}