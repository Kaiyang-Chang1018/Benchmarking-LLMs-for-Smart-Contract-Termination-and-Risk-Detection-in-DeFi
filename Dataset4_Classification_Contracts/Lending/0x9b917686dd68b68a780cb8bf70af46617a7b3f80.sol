// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

abstract contract GenArt721  {
  function purchaseTo(address _to, uint256 _projectId) public virtual payable returns (uint256 _tokenId);
  function projectTokenInfo(uint256 _projectId) public virtual view returns (address artistAddress, uint256 pricePerTokenInWei, uint256 invocations, uint256 maxInvocations, bool active, address additionalPayee, uint256 additionalPayeePercentage);
  function tokensOfOwner(address owner) external virtual view returns (uint256[] memory);
}

contract Relic {
  uint256 public num = 0; 
  uint256 public cost = 1; // 1 wei
  bool public is_sealed = false;
  address public admin_address;
  address public admin_address2;
  string public message;
  bytes32 public squiggle_mint_tx;

  bool public paused;
  address public lacma_address = 0x2360A52d6F0eA089307b405d4be40D523D578594; 
  address constant snowfro_address = 0xf3860788D1597cecF938424bAABe976FaC87dC26; 

  GenArt721 public squiggle;
  
  mapping (address => bool) private has_inscribed;
  mapping (uint256 => address) public inscriptions;
  mapping (address => uint256) public num_squiggles; //number of squiggles owned 

  event eInscribe(address a);
    
  modifier requireAdmin() {
    require(msg.sender==admin_address, "Requires admin privileges");
    _;
  }

  modifier requireAdmin2() {
    require(msg.sender==admin_address ||
	    msg.sender==admin_address2, "Requires admin privileges");
    _;
  }
  
  modifier notSealed() {
    require(is_sealed == false, "Contract has been sealed");
    _;
  }

  constructor() {
    admin_address = snowfro_address;
    lacma_address = 0x2360A52d6F0eA089307b405d4be40D523D578594;    
    admin_address2 = msg.sender; 
    address _squiggle_contract_address = 0x059EDD72Cd353dF5106D2B9cC5ab83a52287aC3a;
    squiggle = GenArt721(_squiggle_contract_address);
    paused = true;    
  }

  receive() external payable  {
    inscribeAddress();
  }

  function seal() public requireAdmin notSealed {
    is_sealed = true;
  }

  function setLACMAAddress(address a) public notSealed {
    //only changeable by a multisig    
    require(msg.sender==0xb998A2520907Ed1fc0F9f457b2219FB2720466cd,"Access denied");
    lacma_address = a;
  }
  
  function setPaused(bool p) public requireAdmin2 notSealed {
    paused = p;
  }
  
  //mint the last squiggle
  function mint10000th() public requireAdmin notSealed {
    require(msg.sender == snowfro_address,"Must be initiated by Snowfro");
    squiggle.purchaseTo(lacma_address,0);
  }
  
  //set administrator, revoking previous
  function setAdmin(address a) public requireAdmin notSealed {
    admin_address = a;
  }

  // set 2nd administrator, revoking previous
  function setAdmin2(address a) public requireAdmin2 notSealed {
    admin_address2 = a;
  }
  
  //set the transaction hash of the final squiggle mint
  function setMintTX(bytes32 t) public requireAdmin notSealed {
    squiggle_mint_tx = t;
  }
    
  // snowfro can add a message
  function addMessage(string memory s) public requireAdmin notSealed {
    require(msg.sender == snowfro_address,"Must be initiated by Snowfro");
    message = s;
  }

  // set squiggle counts
  function setCounts(address[] memory a, uint256[] memory c) public requireAdmin2 notSealed {
    for (uint i=0;i<a.length;i++) {
      num_squiggles[a[i]] = c[i];
    }
  }

  // Query the inscription list by address; returning true/false for whether that address has inscribed,
  // and the number of squiggles under ownership (directly or through delegation)
  function inscriptionByAddress(address a) public view returns (bool inscribed, uint256 squiggle_count) {
    inscribed = has_inscribed[a];
    squiggle_count = inscribed ? num_squiggles[a] : 0;
  }
  
  function inscribeAddress() public payable notSealed {
    require(msg.value >= cost,"Must send minimum cost (will be refunded)");
    require(!paused, "Contract is paused");
    
    address a = msg.sender;

    require(has_inscribed[a]==false, "Already inscribed");
    has_inscribed[a] = true;
    inscriptions[num] = a;
    num++;
    emit eInscribe(a);
  
    //refund any amount sent
    if (msg.value > 0) {
      payable(msg.sender).transfer(msg.value);
    }
  }
  
}