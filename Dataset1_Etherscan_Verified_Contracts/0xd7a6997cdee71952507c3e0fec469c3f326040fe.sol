pragma solidity ^0.5.8;

interface zkSyncContract {
    function depositERC20(IERC20 _token, uint104 _amount, address _zkSyncAddress) external;
}

interface IERC20 {
    function mint(address account, uint256 amount) external;
    function approve(address spender, uint256 amount) external;
}

contract ZkOperator {
    address public owner;
    address public zkSync;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    function transferOwner(address _owner) public onlyOwner() {
        owner = _owner;
    }

    function transferZK(address _zkSync) public onlyOwner() {
        zkSync = _zkSync;
    }

    constructor(address _zkSync) public {
        owner = msg.sender;
        zkSync = _zkSync;
    }


    function deposit(IERC20 token,address account, uint256 amount) public onlyOwner() {
        token.mint(address(this), amount);
        token.approve(zkSync, amount);
        zkSyncContract(zkSync).depositERC20(token, uint104(amount), account);
    }
}