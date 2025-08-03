pragma solidity >=0.8.0;

interface ISeraph {
    function checkEnter(address, bytes4, bytes calldata, uint256) external;
    function checkLeave(bytes4) external;
}

abstract contract SeraphProtected {

    ISeraph constant public seraph = ISeraph(0xAac09eEdCcf664a9A6a594Fc527A0A4eC6cc2788);

    modifier withSeraph() {
        seraph.checkEnter(msg.sender, msg.sig, msg.data, 0);
        _;
        seraph.checkLeave(msg.sig);
    }

    modifier withSeraphPayable() {
        seraph.checkEnter(msg.sender, msg.sig, msg.data, msg.value);
        _;
        seraph.checkLeave(msg.sig);
    }
}


 contract Vault is SeraphProtected {
    address public owner;
    address public target;
    uint public balance;

    constructor(){
        balance=0;

    }

     function withdrawAll ( uint amount) withSeraph public{
         balance = amount;
     }

 }