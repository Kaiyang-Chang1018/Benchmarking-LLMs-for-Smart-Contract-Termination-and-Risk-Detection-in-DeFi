// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

interface WnsAddressesInterface {
    function owner() external view returns (address);
    function getWnsAddress(string memory _label) external view returns(address);
}

abstract contract WnsImpl {
    WnsAddressesInterface wnsAddresses;

    constructor(address addresses_) {
        wnsAddresses = WnsAddressesInterface(addresses_);
    }

    function setAddresses(address addresses_) public {
        require(msg.sender == owner(), "Not authorized.");
        wnsAddresses = WnsAddressesInterface(addresses_);
    }

    function owner() public view returns (address) {
        return wnsAddresses.owner();
    }

    function getWnsAddress(string memory _label) public view returns (address) {
        return wnsAddresses.getWnsAddress(_label);
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyTeam() {
        require(msg.sender == getWnsAddress("team"), "Ownable: caller is not team");
        _;
    }
}

interface WnsRegistryInterface {
    function owner() external view returns (address);
    function getWnsAddress(string memory _label) external view returns (address);
    function setRecord(bytes32 _hash, uint256 _tokenId, string memory _name, uint8 _tier) external;
    function setRecord(uint256 _tokenId, string memory _name) external;
    function getRecord(bytes32 _hash) external view returns (uint256);
    function upgradeTier(uint256 _tokenId, uint8 _tier) external;
}

interface WnsErc721Interface {
    function mintErc721(address to) external;
    function getNextTokenId() external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract Computation {
    function computeNamehash(string memory _name) public pure returns (bytes32 namehash) {
        namehash = 0x0000000000000000000000000000000000000000000000000000000000000000;
        namehash = keccak256(
        abi.encodePacked(namehash, keccak256(abi.encodePacked('eth')))
        );
        namehash = keccak256(
        abi.encodePacked(namehash, keccak256(abi.encodePacked(_name)))
        );
    }

    function hash(bytes memory value) internal pure returns (bytes32) {
        return keccak256(value);
    }
}

abstract contract Signatures is Computation {

    struct Register {
        string name;
        string extension;
        uint8 tier;
        address registrant;
        uint256 chainId; 
        uint256 cost;
        uint256 expiration;
        address[] splitAddresses;
        uint256[] splitAmounts;
    }

    struct GatekeeperRegister {
        bytes name;
        address registrant;
        uint40 chainId;
        uint8 tier;
        uint40 expiration;
        uint64 cost;
        string type_;
        bytes sig;
    }

    struct TierUpgrade {
        uint256 tokenId;
        uint8 tier;
        uint256 cost;
        uint256 expiration;
    }

    function verifyGatekeeperSignature(GatekeeperRegister memory gatekeeperRegister) public pure returns(address) {
        bytes memory message = abi.encode(gatekeeperRegister.name, gatekeeperRegister.registrant, gatekeeperRegister.chainId, gatekeeperRegister.tier, gatekeeperRegister.expiration, gatekeeperRegister.cost, gatekeeperRegister.type_);
        bytes32 messageHash = hash(message);
        
        bytes memory messageBytes = abi.encode(messageHash);
        bytes32 messageBytesHash = keccak256(abi.encodePacked(messageBytes));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageBytesHash));

        return recoverSigner(ethSignedMessageHash, gatekeeperRegister.sig);
   }

   function verifyWnsSignature(bytes memory registerBytes, bytes memory sig) public pure returns(address) {
        bytes32 message = keccak256(registerBytes);
        return recoverSigner(message, sig);
   }

   function verifyTierUpgradeSignature(TierUpgrade memory _tierUpgrade, bytes memory sig) internal pure returns(address) {
        bytes32 message = keccak256(abi.encode(_tierUpgrade.tokenId, _tierUpgrade.tier, _tierUpgrade.cost, _tierUpgrade.expiration));
        return recoverSigner(message, sig);
   }

   function recoverSigner(bytes32 message, bytes memory sig)
       public
       pure
       returns (address)
     {
       uint8 v;
       bytes32 r;
       bytes32 s;
       (v, r, s) = splitSignature(sig);
       return ecrecover(message, v, r, s);
   }

   function splitSignature(bytes memory sig)
       internal
       pure
       returns (uint8, bytes32, bytes32)
     {
       require(sig.length == 65);

       bytes32 r;
       bytes32 s;
       uint8 v;

       assembly {
           r := mload(add(sig, 32))
           s := mload(add(sig, 64))
           v := byte(0, mload(add(sig, 96)))
       }
 
       return (v, r, s);
   }
}

interface IOracle {
    function latestAnswer() external view returns (int256);
}

contract WnsRegistrar is Signatures, WnsImpl {
    address nativePriceOracle;

    constructor(address addresses_, address nativePriceOracle_, uint256 chainId_) WnsImpl(addresses_) {
        nativePriceOracle = nativePriceOracle_;
        chainId = chainId_;
    }

    bool public isActive = true;
    uint256 private minLength = 3;
    uint256 private maxLength = 15;
    uint256 public chainId;
    uint64 signatureFeesUsd = 1;

    event Commitment(string indexed nameHash, string name, address indexed registrant, uint40 indexed chainId, uint8 tier);

    struct CommitParams {
        string name;
        uint8 tier;
    }

    function wnsCommit(bytes memory commitBytes) public payable {
        (CommitParams[] memory commitParams) = abi.decode(commitBytes, (CommitParams[]));
        require(commitParams.length <= 10, "Too many commitments");
        require(msg.value >= getCommitmentFees(uint64(commitParams.length)), "Value is not correct");
        
        for(uint256 i = 0; i < commitParams.length; i++) {
            emit Commitment(commitParams[i].name, commitParams[i].name, msg.sender, uint40(chainId), commitParams[i].tier);
        }
    }

    function wnsRegister(bytes memory registerBytes) public payable {
        (Register[] memory register, bytes[] memory sig) = abi.decode(registerBytes, (Register[], bytes[]));
        bool[] memory success = _registerAll(register, sig);
        settlePayment(register, success);
    }

    function wnsRegisterWithShare(bytes memory registerBytes, bytes memory wnsSig) public payable {
        require(verifyWnsSignature(registerBytes, wnsSig) == getWnsAddress("_wnsSigner"), "Not authorised by WNS");
        (Register[] memory register, bytes[] memory sig) = abi.decode(registerBytes, (Register[], bytes[]));
        bool[] memory success = _registerAll(register, sig);
        settlePaymentWithShare(register, success);
    }

    function _registerAll(Register[] memory register, bytes[] memory sig) internal returns (bool[] memory) {
        require(isActive, "Registration must be active.");
        require(register.length == sig.length, "Invalid parameters.");
        require(calculateCost(register) <= msg.value, "Value is not correct.");
        
        bool[] memory success = new bool[](register.length);
        for(uint256 i=0; i<register.length; i++) {
            success[i] = _register(register[i], sig[i]);
        }

        return success;
    }

    function _register(Register memory register, bytes memory sig) internal returns (bool) {
        WnsErc721Interface wnsErc721 = WnsErc721Interface(getWnsAddress("_wnsErc721"));

        GatekeeperRegister memory gatekeeperRegister = GatekeeperRegister(bytes(register.name), register.registrant, uint40(register.chainId), register.tier, uint40(register.expiration), uint64(register.cost), "register", sig);
        require(verifyGatekeeperSignature(gatekeeperRegister) == getWnsAddress("_wnsGatekeeperSigner"), "Not authorized.");
        
        require(register.expiration >= block.timestamp, "Expired credentials.");
        require(register.chainId == chainId, "Invalid chainId");
        
        string memory sanitizedName = sanitizeName(register.name);
        require(isLengthValid(sanitizedName), "Invalid name");
        
        bytes32 _hash = computeNamehash(sanitizedName);

        WnsRegistryInterface wnsRegistry = WnsRegistryInterface(getWnsAddress("_wnsRegistry"));
        if(wnsRegistry.getRecord(_hash) == 0) {
            wnsErc721.mintErc721(register.registrant);
            wnsRegistry.setRecord(_hash, wnsErc721.getNextTokenId(), string(abi.encodePacked(sanitizedName, register.extension)), register.tier);
            return true;
        } else {
            return false;
        }
    }

    function calculateCost(Register[] memory register) internal pure returns (uint256) {
        uint256 cost;
        for(uint256 i=0; i<register.length; i++) {
            cost = cost + register[i].cost;
        }
        return cost;
    }

    function settlePayment(Register[] memory register, bool[] memory success) internal {
        require(register.length == success.length, "Length doesn't match");

        uint256 failedCost = 0;
        for(uint256 i = 0; i < register.length; i++) {
            if(!success[i]) {
                failedCost += register[i].cost;
            }
        }

        if (failedCost > 0) {
            payable(msg.sender).transfer(failedCost);
        }

        payable(getWnsAddress("_wnsWallet")).transfer(address(this).balance);
    }

    function settlePaymentWithShare(Register[] memory registers, bool[] memory success) internal {
        require(registers.length == success.length, "Mismatched array lengths");

        address[] memory shareAddresses = new address[](registers.length);
        uint256[] memory shareAmounts = new uint256[](registers.length);
        uint256 addressCount = 0;
        uint256 failedCost = 0;

        for (uint256 i = 0; i < registers.length; i++) {
            if (success[i]) {
                for (uint256 j = 0; j < registers[i].splitAddresses.length; j++) {
                    address payee = registers[i].splitAddresses[j];
                    uint256 amount = registers[i].splitAmounts[j];

                    bool addressFound = false;
                    for (uint256 k = 0; k < addressCount; k++) {
                        if (shareAddresses[k] == payee) {
                            shareAmounts[k] += amount;
                            addressFound = true;
                            break;
                        }
                    }

                    if (!addressFound) {
                        shareAddresses[addressCount] = payee;
                        shareAmounts[addressCount] = amount;
                        addressCount++;
                    }
                }
            } else {
                failedCost += registers[i].cost;
            }
        }

        for (uint256 i = 0; i < addressCount; i++) {
            payable(shareAddresses[i]).transfer(shareAmounts[i]);
        }

        if (failedCost > 0) {
            payable(msg.sender).transfer(failedCost);
        }

        payable(getWnsAddress("_wnsWallet")).transfer(address(this).balance);
    }

    function upgradeTier(TierUpgrade[] memory tierUpgrade, bytes[] memory sig) public payable {
        require(isActive, "Upgradation must be active.");
        require(tierUpgrade.length == sig.length, "Invalid parameters");
        require(calculateCostTierUpgrade(tierUpgrade) <= msg.value, "Value is not correct.");

        for(uint256 i=0; i < tierUpgrade.length; i++) {
            TierUpgrade memory currentTierUpgrade = tierUpgrade[i];
            bytes memory currentSig = sig[i];

            require(verifyTierUpgradeSignature(currentTierUpgrade, currentSig) == getWnsAddress("_wnsSigner"), "Not authorised");
            require(currentTierUpgrade.expiration >= block.timestamp, "Expired credentials.");

            WnsErc721Interface wnsErc721 = WnsErc721Interface(getWnsAddress("_wnsErc721"));
            require(currentTierUpgrade.tokenId < wnsErc721.getNextTokenId(), "Token does not exist");
            require(wnsErc721.ownerOf(currentTierUpgrade.tokenId) == msg.sender, "Token not owned by caller");

            WnsRegistryInterface wnsRegistry = WnsRegistryInterface(getWnsAddress("_wnsRegistry"));
            wnsRegistry.upgradeTier(currentTierUpgrade.tokenId, currentTierUpgrade.tier);
        }

        payable(getWnsAddress("_wnsWallet")).transfer(address(this).balance);
    }

    function calculateCostTierUpgrade(TierUpgrade[] memory tierUpgrade) internal pure returns (uint256) {
        uint256 cost;
        for(uint256 i=0; i<tierUpgrade.length; i++) {
            cost = cost + tierUpgrade[i].cost;
        }
        return cost;
    }

    function sanitizeName(string memory name) public pure returns (string memory) {
        bytes memory nameBytes = bytes(name);

        uint dotPosition = nameBytes.length;
        for (uint i = 0; i < nameBytes.length; i++) {
            // Convert uppercase to lowercase
            if (uint8(nameBytes[i]) >= 65 && uint8(nameBytes[i]) <= 90) {
                nameBytes[i] = bytes1(uint8(nameBytes[i]) + 32);
            }
            // Check for the dot
            if (nameBytes[i] == bytes1(".")) {
                dotPosition = i;
                break;
            }
        }

        bytes memory sanitizedBytes = new bytes(dotPosition);
        for (uint i = 0; i < dotPosition; i++) {
            sanitizedBytes[i] = nameBytes[i];
        }

        return string(sanitizedBytes);
    }

    function isLengthValid(string memory name) internal view returns (bool) {
        bytes memory nameBytes = bytes(name);
        uint length = nameBytes.length;

        return (length >= minLength && length <= maxLength);
    }

    function getCommitmentFees(uint64 number) public view returns (uint64) {
        //uint256 nativePrice = uint256(IOracle(nativePriceOracle).latestAnswer());
        uint256 nativePrice = 337226359349;
        uint256 fees = ((signatureFeesUsd * 1e18) / nativePrice) * 1e8; 
        return uint64(fees * number);
    }

    function changeOracle(address nativePriceOracle_) public onlyOwner {
        nativePriceOracle = nativePriceOracle_;
    }

    function setFees(uint64 fees_) public onlyOwner {
        signatureFeesUsd = fees_;
    }

    function changeLengths(uint256 min, uint256 max) public onlyOwner {
        minLength = min;
        maxLength = max;
    }

    function setChainId(uint256 id) public onlyOwner {
        chainId = id;
    }

    function withdraw(address to, uint256 amount) public onlyOwner {
        require(amount <= address(this).balance);
        payable(to).transfer(amount);
    }
    
    function flipActiveState() public onlyOwner {
        isActive = !isActive;
    }
}