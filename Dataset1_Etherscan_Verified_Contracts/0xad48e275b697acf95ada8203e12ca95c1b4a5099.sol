pragma solidity ^0.6.6;

contract Bribe {
    function bribe() payable public {
        // 将收到的 ETH 发送给当前区块的矿工
        block.coinbase.transfer(msg.value);
    }
}