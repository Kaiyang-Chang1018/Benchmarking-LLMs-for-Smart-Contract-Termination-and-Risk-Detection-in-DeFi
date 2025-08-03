/*
   _______  _        _______ _________ _______      _______  _______  _______ _________ _        _        _______ 
  (  ____ \( \      (  ___  )\__   __/(       )    (  ____ \(  ____ \(  ____ )\__   __/( \      ( \      (  ___  )
  | (    \/| (      | (   ) |   ) (   | () () |    | (    \/| (    \/| (    )|   ) (   | (      | (      | (   ) |
  | |      | |      | (___) |   | |   | || || |    | (_____ | |      | (____)|   | |   | |      | |      | (___) |
  | |      | |      |  ___  |   | |   | |(_)| |    (_____  )| |      |     __)   | |   | |      | |      |  ___  |
  | |      | |      | (   ) |   | |   | |   | |          ) || |      | (\ (      | |   | |      | |      | (   ) |
  | (____/\| (____/\| )   ( |___) (___| )   ( |    /\____) || (____/\| ) \ \_____) (___| (____/\| (____/\| )   ( |
  (_______/(_______/|/     \|\_______/|/     \|your\_______)(_______/|/   \__/\_______/(_______/(_______/|/     \|
                                                                                                                                                                                                         
*/
//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.10;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function tokensForSale() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(address from, address to, uint256 value) external;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface presaleData {
    function users(
        address _user
    ) external view returns (uint256 _value1, uint256 _value2, uint256 _value3);
}

contract claimScrilla {
    presaleData public presaleContract =
        presaleData(0x8C82443d507CD684048383A29413E619FBf7Fc0b);
    IERC20 public Scrilla = IERC20(0x5965393509eF9de9BbEF9dAacE807Cf155f2b8E8); 
    address public owner = 0x3A04A1044494f2e7AdD96DB4C4786c8F2d99d494;

    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not an owner");
        _;
    }

    uint256 public total_eth_Collected;
    uint256 public claimers;

    bool public enableClaim;

    mapping(address => bool) public BLusers;
    mapping(address => claimedHistory) public UserclaimedData;

    struct claimedHistory {
        uint256 Eth_Contribution;
        uint256 claimed_token;
    }

    constructor() {
        BLusers[0x1426EabAAb1af3a5d8a7C7295B126B3F6Eacb054] = true;
        // Sorry Neiko.  No Scrilla for you
    }

    function GetusersData(
        address _user
    ) public view returns (uint256 _value1, uint256 _value2) {
        (_value1, _value2, ) = presaleData(presaleContract).users(_user);
    }

    // to claim token after launch time w=> for web3 use
    function claimToken() public {
        require(enableClaim == true, "wait for owner to enable claim)");
        require(!BLusers[msg.sender], "Blocked USer");
        require(
            UserclaimedData[msg.sender].claimed_token == 0,
            "Already Claimed"
        );

        (uint256 eth_balance, uint256 token_balance) = GetusersData(msg.sender);

        uint256 tokenBalance = token_balance;
        total_eth_Collected += eth_balance;

        Scrilla.transfer(msg.sender, tokenBalance);
        UserclaimedData[msg.sender].Eth_Contribution += eth_balance;
        UserclaimedData[msg.sender].claimed_token += token_balance;
        claimers += 1;
    }

    // add or remove user from Block List
    function UpdateBLusers(address user, bool _status) public onlyOwner {
        BLusers[user] = _status;
    }

    // enable claim
    function EnableClaim(bool _status) public onlyOwner {
        enableClaim = _status;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // change tokens
    function changeToken(address _token) external onlyOwner {
        Scrilla = IERC20(_token);
    }

    // to draw out tokens
    function transferTokens(IERC20 token, uint256 _value) external onlyOwner {
        token.transfer(msg.sender, _value);
    }
}