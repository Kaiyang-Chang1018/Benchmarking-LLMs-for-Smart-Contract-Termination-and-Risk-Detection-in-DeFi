pragma solidity >=0.4.22 <0.9.0;


contract DeathTrapsClaim {
    bool public killswitchActive;

    WMinter public watchMinter;
    WAdmin public watchAdmin;
    DeathTraps public deathTraps;

    address public owner;

    uint256 public constant DEVIATE_CIRCLE_ID = 4;
    uint256 public constant DEVIATE_CROSS_ID = 3;
    uint256 public constant DEVIATE_TRIANGLE_ID = 2;

    uint256 public constant BLACK_PACK_ID = 64;

    constructor(DeathTraps _deathTraps, WMinter _watchMinter, WAdmin _watchAdmin) {
        owner = msg.sender;
        
        deathTraps = _deathTraps;
        watchMinter = _watchMinter;
        watchAdmin = _watchAdmin;
    }

    modifier ownerOnly() {
        require(killswitchActive == false, "Killswitch has been activated");
        require(msg.sender == owner, "User is not the owner");
        _;
    }

    modifier user() {
        require(killswitchActive == false, "Killswitch has been activated");
        _;
    }

    function activateKillswitch() external ownerOnly {
        killswitchActive = true;
    }

    function calculateBalances(address _address) external view returns (uint256, uint256, uint256) {
        uint256 deviateCircleBalance = deathTraps.balanceOf(_address, DEVIATE_CIRCLE_ID);
        uint256 deviateCrossBalance = deathTraps.balanceOf(_address, DEVIATE_CROSS_ID);
        uint256 deviateTriangleBalance = deathTraps.balanceOf(_address, DEVIATE_TRIANGLE_ID);

        return (deviateCircleBalance, deviateCrossBalance, deviateTriangleBalance);
    }

    function claim() external user {
        // Ensure the contract is approved on the DeathTraps contract
        require(deathTraps.isApprovedForAll(msg.sender, address(this)), "Contract is not approved");
        uint256 deviateCircleBalance = deathTraps.balanceOf(msg.sender, DEVIATE_CIRCLE_ID);
        uint256 deviateCrossBalance = deathTraps.balanceOf(msg.sender, DEVIATE_CROSS_ID);
        uint256 deviateTriangleBalance = deathTraps.balanceOf(msg.sender, DEVIATE_TRIANGLE_ID);

        uint256 totalBalance = deviateCircleBalance + deviateCrossBalance * 5 + deviateTriangleBalance * 10;

        require(totalBalance > 0, "User has no tokens to claim");

        uint256[] memory burnIds = new uint256[](3);
        uint256[] memory burnAmounts = new uint256[](3);

        burnIds[0] = DEVIATE_CIRCLE_ID;
        burnIds[1] = DEVIATE_CROSS_ID;
        burnIds[2] = DEVIATE_TRIANGLE_ID;

        burnAmounts[0] = deviateCircleBalance;
        burnAmounts[1] = deviateCrossBalance;
        burnAmounts[2] = deviateTriangleBalance;

        deathTraps.burn(msg.sender, burnIds, burnAmounts);

        watchAdmin.mint(msg.sender, BLACK_PACK_ID, totalBalance);
    }
}

abstract contract WMinter {
  function balanceOf(address _account, uint256 _id) virtual public view returns (uint256);
  function balanceOfBatch(address[] memory _accounts, uint256[] memory _ids) virtual public view returns (uint256[] memory);
}

abstract contract WAdmin {
    mapping (address => bool) public isAdmin;
    function mint(address _to, uint256 _id, uint256 _amount) external virtual;
}

abstract contract DeathTraps {
    function balanceOf(address _account, uint256 _id) virtual public view returns (uint256);
    function isApprovedForAll(address account, address operator) virtual external view returns (bool);
    function burn(address account, uint256[] memory tokenIds, uint256[] memory amounts) virtual public;
}