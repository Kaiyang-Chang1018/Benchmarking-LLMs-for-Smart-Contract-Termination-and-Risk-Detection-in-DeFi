// SPDX-License-Identifier: WAGDIE
//
//    ℑ? ???????? ?????, ????? ??????? ???,
//    ??? ???? ?? ???????? ??????? ???.
//    ????? ?? ???, ??? ????? ??????,
//    ℌ?? ?????, ? ??????????, ??????? ????.
//
//
//    ??????? ??? ???????, ? ??????? ?????,
//    ???????? ???????, ??? ????? ?? ?????.
//    ??????? ??????, ????? ???? ??????,
//    ????? ??? ????, ? ????? ???????.
//
//
//    ????????? ????? ?? ???????'? ???,
//    ??? ?????'? ???? ?? ????? ????.
//    ???????? ??????? ?? ?????'? ???????,
//    ℭ??????? ????? ??? ??????????? ?????.
//
//
//    ℑ? ????? ??????, ??? ???? ???? ????,
//    ????????'? ?????????, ???? ???? ?? ????.
//    ℑ? ????????, ?? ???????, ?? ????? ?? ?????,
//    ℌ?? ?????? ???????, ?? ????? ???? ?? ?????.
//
//

pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;

    function transfer(address to, uint256 tokenId) external;
}

interface IConcord {
    function bestowTokensMany(
        address[] calldata _to,
        uint256[] calldata _tokens,
        uint256[] calldata _amounts
    ) external;
}

contract AstarothsVengeance {
    address constant burnAddress =
        address(0x000000000000000000000000000000000000dEaD);
    address constant wagdieAuthor =
        address(0x8d2Eb1c6Ab5D87C5091f09fFE4a5ed31B1D9CF71);

    bool public vengeanceAchieved = false;

    struct Acolytes {
        uint256 wagdieTokenId;
        uint256 acolyteTokenId;
        bool vengeanceAgreed;
    }

    mapping(address => Acolytes) private submissions;
    address[] private acolyteAddresses;

    IERC721 public wagdieContract;
    IERC721 public acolyteContract;
    IConcord public concordContract;

    constructor() {
        wagdieContract = IERC721(
            address(0x659A4BdaAaCc62d2bd9Cb18225D9C89b5B697A5A)
        );
        acolyteContract = IERC721(
            address(0xE7061488cE937012dadee6F82608cB5becaFF8D9)
        );
        concordContract = IConcord(
            address(0x1d38150f1Fd989Fb89Ab19518A9C4E93C5554634)
        );
    }

    // Acolytes arrive to demand vengeance for Astaroth
    function sendAcolyte(uint256 wagdieTokenId, uint256 acolyteTokenId) public {
        require( submissions[msg.sender].wagdieTokenId == 0 && submissions[msg.sender].acolyteTokenId == 0, "This address has already sent an Acolyte." );
        require(acolyteTokenId >= 31 && acolyteTokenId <= 43,"This AKIB Hero is not an Acolyte of Astaroth.");
        require(!vengeanceAchieved, "Cannot join the pact, after vengeance has been achieved.");

        wagdieContract.transferFrom(msg.sender, address(this), wagdieTokenId);
        acolyteContract.transferFrom(msg.sender, address(this), acolyteTokenId);

        // Upon entry, arrive with a sense of unfulfilled vengeance
        acolyteAddresses.push(msg.sender);
        submissions[msg.sender] = Acolytes(
            wagdieTokenId,
            acolyteTokenId,
            false
        );
    }

    // Once Vengeance has been granted and agreed, Acolytes may return
    function returnAcolyte() public {
        require(vengeanceAchieved, "Vengeance has not yet been achieved.");

        for (uint i = 0; i < acolyteAddresses.length; i++) {
            require(submissions[acolyteAddresses[i]].vengeanceAgreed, "Not all Acolytes have agreed to vengeance.");
        }

        Acolytes storage submission = submissions[msg.sender];

        require(submission.wagdieTokenId > 0 && submission.acolyteTokenId > 0, "No Acolyte from this address is present.");

        // Transfer the tokens back to the sender
        wagdieContract.transfer(msg.sender, submission.wagdieTokenId);
        acolyteContract.transfer(msg.sender, submission.acolyteTokenId);

        // Remove the user's address from acolyteAddresses
        _removeAddressFromSubmitters(_findAddressIndex(msg.sender));
    }

    // The Two may slay random Acolytes
    function slayAcolyte() public {
        require(
            msg.sender == wagdieAuthor,
            "Fates can only be controlled by The Two."
        );
        require(acolyteAddresses.length > 0, "No acolytes to slay.");

        // Select Random Acolyte
        uint256 rng = _getPseudoRandomNumber();
        uint256 submitterCount = acolyteAddresses.length;
        uint256 selectedAddressIndex = rng % submitterCount;
        address selectedAddress = acolyteAddresses[selectedAddressIndex];

        // Burn Acolyte Token Pair
        wagdieContract.transferFrom(
            address(this),
            burnAddress,
            submissions[selectedAddress].wagdieTokenId
        );
        acolyteContract.transferFrom(
            address(this),
            burnAddress,
            submissions[selectedAddress].acolyteTokenId
        );

        // Remove Acolyte From Set
        _removeAddressFromSubmitters(selectedAddressIndex);
    }

    // The Two grant an opportunity at vengeance
    function grantVengeance() public {
        require(
            msg.sender == wagdieAuthor,
            "Vengeance can only be granted by The Two."
        );

        vengeanceAchieved = true;

    }

    // Individual Acolyte agrees to vengeance
    function agreeVengeance() public {
        require(
            submissions[msg.sender].wagdieTokenId != 0,
            "No Acolyte from this address is present."
        );

        submissions[msg.sender].vengeanceAgreed = true;

    }

    // Random number generator
    function _getPseudoRandomNumber() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            );
    }

    // Locate address index within array (for removals)
    function _findAddressIndex(address addr) private view returns (uint256) {
        for (uint256 i = 0; i < acolyteAddresses.length; i++) {
            if (acolyteAddresses[i] == addr) {
                return i;
            }
        }
        revert("Address not found in acolyteAddresses.");
    }

    // Remove address from array by index (does not affect memory)
    function _removeAddressFromSubmitters(uint256 index) private {
        uint256 lastAddressIndex = acolyteAddresses.length - 1;
        acolyteAddresses[index] = acolyteAddresses[lastAddressIndex];
        acolyteAddresses.pop();
    }
}