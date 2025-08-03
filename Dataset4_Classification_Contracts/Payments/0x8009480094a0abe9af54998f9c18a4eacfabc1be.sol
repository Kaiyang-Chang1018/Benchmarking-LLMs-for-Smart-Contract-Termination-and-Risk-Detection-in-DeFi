/*
    Name: Berachain Mainnet
    RPC: https://berachain.leakedrpc.chipswap.org
    ChainID: 80094
    Symbol: BERA
    Swap: https://chipswap.org
    X: https://x.com/ChipSwap_EVM
    Telegram: https://t.me/ChipSwap_EVM

    Send $ETH here to birdge your funds (you'll get 1 $BERA and the remaining will be $WETH)
    ($WETH on Berachain: 0x2F6F07CDcf3588944Bf4C42aC74ff24bF56e7590)
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

contract BerachainBridge {
    event BERADeposited(uint256 amount, address to);
    event WETHDeposited(uint256 amountLD, uint256 minAmountLD, address to);

    uint32 constant _dstEid = 30362;
    bytes constant _emptyData = new bytes(0);

    address constant _beraBridge = 0x26DA582889f59EaaE9dA1f063bE0140CD93E6a4f;
    address constant _wethBridge = 0x77b2043768d28E9C9aB44E1aBfC95944bcE57931;

    mapping(address => bool) public beraBridged;

    receive() external payable {
        if (!beraBridged[msg.sender]) {
            beraBridged[msg.sender] = true;
            _bridgeBERA(msg.sender);
        }
        _bridgeWETH(msg.sender);

        uint256 selfBalance = address(this).balance;
        if (selfBalance > 0) {
            (bool success, ) = msg.sender.call{value: selfBalance}("");
            require(success);
        }
    }

    function _bridgeBERA(address to) private {
        uint208 _optionsLeft = 0x00030100110100000000000000000000000000004e2001003102;
        uint128 _beraAmount = 1000000000000000000;

        bytes memory options = abi.encodePacked(_optionsLeft, _beraAmount, bytes32(uint256(uint160(to))));
        uint256 nativeFee = IBERABridge(_beraBridge).quote(_dstEid, _emptyData, options);
        require(address(this).balance >= nativeFee, "BRIDGE_BERA_FEE_INSUFFICIENT");

        uint256[] memory depositParams = new uint256[](1);
        depositParams[0] = uint256(_dstEid) << 224 | uint224(_beraAmount);

        IBERABridge(_beraBridge).sendDeposits{value: nativeFee}(depositParams, to);
        emit BERADeposited(_beraAmount, to);
    }

    function _bridgeWETH(address to) private {
        uint256 selfBalance = address(this).balance;
        IWETHBridge.SendParam memory sendParam = IWETHBridge.SendParam({
            dstEid: _dstEid,
            to: bytes32(uint256(uint160(to))),
            amountLD: selfBalance,
            minAmountLD: selfBalance,
            extraOptions: _emptyData,
            composeMsg: _emptyData,
            oftCmd: _emptyData
        });
        IWETHBridge.MessagingFee memory messagingFee = IWETHBridge(_wethBridge).quoteSend(sendParam, false);
        require(selfBalance > messagingFee.nativeFee, "BRIDGE_WETH_FEE_INSUFFICIENT");
        sendParam.amountLD = selfBalance - messagingFee.nativeFee;
        sendParam.minAmountLD = sendParam.amountLD * 995 / 1000;

        IWETHBridge(_wethBridge).send{value: selfBalance}(sendParam, messagingFee, to);
        emit WETHDeposited(sendParam.amountLD, sendParam.minAmountLD, to);
    }
}

interface IBERABridge {
    function quote(uint32 dstEid, bytes calldata message, bytes memory options) external view returns (uint256 nativeFee);

    function sendDeposits(uint256[] calldata depositParams, address to) external payable;
}

interface IWETHBridge {
    struct SendParam {
        uint32 dstEid;
        bytes32 to;
        uint256 amountLD;
        uint256 minAmountLD;
        bytes extraOptions;
        bytes composeMsg;
        bytes oftCmd;
    }

    struct MessagingFee {
        uint256 nativeFee;
        uint256 lzTokenFee;
    }

    function quoteSend(SendParam calldata sendParam, bool payInLzToken) external view returns (MessagingFee memory);

    function send(SendParam calldata sendParam, MessagingFee calldata fee, address refundAddress) external payable;
}