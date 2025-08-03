// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IAyeAyeCoin {
    function sendCoin(address _receiver, uint256 _amount) external;

    function coins(address _owner) external view returns (uint256);
}

interface IWAYE {
    function createDropBox() external;

    function wrap(uint256 value) external;

    function dropBoxes(address x) external view returns (address);

    function transfer(address to, uint256 value) external returns (bool);
}

contract ClaimWaye {
    IWAYE waye = IWAYE(0x30aE41D5f9988D359c733232C6c693c0e645C77E);

    constructor() {
        waye.createDropBox();
    }

    function claim(uint256 amount) external {
        assembly {
            mstore(
                0x00,
                0x5479f98b00000000000000000000000000000000000000000000000000000000
            )
            for {
                let i := 0
            } lt(i, amount) {
                i := add(i, 1)
            } {
                pop(
                    call(
                        gas(),
                        0x3edDc7ebC7db94f54b72D8Ed1F42cE6A527305bB,
                        0,
                        0,
                        0x04,
                        0,
                        0
                    )
                )
            }
        }
        IAyeAyeCoin(0x3edDc7ebC7db94f54b72D8Ed1F42cE6A527305bB).sendCoin(
            waye.dropBoxes(address(this)),
            amount
        );
        waye.wrap(amount);
        waye.transfer(msg.sender, amount);
    }

    function canClaimAmount() external view returns (uint256) {
        return
            IAyeAyeCoin(0x3edDc7ebC7db94f54b72D8Ed1F42cE6A527305bB).coins(
                0xcD063B3081Ea55535E5b60a21eff7f14E785A877
            );
    }
}