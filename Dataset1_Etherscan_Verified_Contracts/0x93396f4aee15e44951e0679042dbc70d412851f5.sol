// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}
// SPDX-License-Identifier: CC-BY-NC-ND-3.0-DE
//@author smashice.eth - https://dtech.vision - https://hupfmedia.de
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract sharedInvest is Ownable {
    /**
     * Event getting fired when a new request is created
     * @param id Request ID
     * @param creator Wallet that created the Request
     * @param timestamp Timestamp at which it was created
     */
    event RequestCreated(
        uint256 indexed id,
        address indexed creator,
        uint256 timestamp
    );
    /**
     * Event getting fired when a request is supported
     * @param id Request ID
     * @param supporter Wallet that supported the request
     * @param amount The amount invested in the request
     * @param timestamp Timestamp at which it was supported
     */
    event RequestSupported(
        uint256 indexed id,
        address indexed supporter,
        uint256 indexed amount,
        uint256 timestamp
    );
    /**
     * Event getting fired when a request is finalized
     * @param id Request ID
     * @param success true if request raised successfully
     * @param amount The amount raised by the request
     * @param targetAmount The target amount by the request
     * @param timestamp Timestamp at which it was finalized
     */
    event RequestFinalized(
        uint256 indexed id,
        bool indexed success,
        uint256 indexed amount,
        uint256 targetAmount,
        uint256 timestamp
    );
    /**
     * Event getting fired when a request gets a payout without being sold (airdrop)
     * @param id Request ID
     * @param amount The amount airdropped/payed out to investors
     * @param description Description of the AirDrop
     * @param timestamp Timestamp of Airdrop
     */
    event RequestAirdrop(
        uint256 indexed id,
        uint256 indexed amount,
        string description,
        uint256 timestamp
    );
    /**
     * Event getting fired when a request is sold
     * @param id Request ID
     * @param amount The amount sold for
     * @param timestamp Timestamp of sale announcement
     */
    event RequestSold(
        uint256 indexed id,
        uint256 indexed amount,
        uint256 timestamp
    );
    /**
     * Event getting fired when a request is payed out
     * @param id Request ID
     * @param timestamp Timestamp of sale announcement
     */
    event RequestPayedOut(
        uint256 indexed id,
        uint256 indexed timestamp
    );

    using ECDSA for bytes32; 
    //funding request - opportunity
    struct request {
        uint256 id;
        uint256 expiry;
        uint256 targetAmount;
        uint256 currentAmount;
        uint256 soldAmount;
        string title;
        string description;
        address targetCollection; //the smartcontract address of the investment target
        address[] participantWallets;
        uint256[] participantAmounts;
        uint256[] participantTimestamp;
        uint8 status; //0 = running, 1=refunded, 2=invested, 3=sold, 4=payed out
    }

    uint256 public nextId = 0;
    uint256 public activeRequests = 0;
    mapping (uint256 => request) public requests;
    mapping (address => int256) public totalPnL;
    mapping (address => int256) public totalInvested;

    address payable public trust;
    address public signerAddress;

    bool public pauseCreation = false;
    bool public pauseSupport  = false;
    bool public pauseFinalize = false;
    bool public pauseSold     = false;
    bool public pausePayout   = false;

    bool public payingOut     = false;

    constructor(
        address signer_,
        address payable trust_
    )
    {
        signerAddress = signer_;
        trust = trust_;
    }

    /**
     * Allows Owner to change Signer
     * @param signer_ the new signer address
     */
    function setSigner (
        address signer_
    ) public onlyOwner {
        signerAddress = signer_;
    }

    /**
     * Allows Owner to pause Request Creation
     */
    function flipPauseCreation()
    public onlyOwner {
        pauseCreation = !pauseCreation;
    }

    /**
     * Allows Owner to pause Request Support
     */
    function flipPauseSupport()
    public onlyOwner {
        pauseSupport = !pauseSupport;
    }

    /**
     * Allows Owner to pause Request Finalization
     */
    function flipPauseFinalize()
    public onlyOwner {
        pauseFinalize = !pauseFinalize;
    }

    /**
     * Allows Owner to pause Request marking as Sold
     */
    function flipPauseSold()
    public onlyOwner {
        pauseSold = !pauseSold;
    }

    /**
     * Allows Owner to pause Request Payout
     */
    function flipPausePayout()
    public onlyOwner {
        pausePayout = !pausePayout;
    }

    /**
     * Create an investment/funding request
     * @param title_ string: Title of the investment
     * @param description_ string: description of the investment
     * @param expiry_  uint256: timestamp of when the targetAmount is to be collected
     * @param targetAmount_ uint256: how much WEI to collect
     * @param targetCollection_ address: from which collection/contract to buy
     * @param signature_ bytes: verification that you are allowed to use the tool
     */
    function createRequest(
        string memory title_,
        string memory description_,
        uint256 expiry_,
        uint256 targetAmount_,
        address targetCollection_,
        bytes memory signature_
    ) public payable 
    {
        require(!pauseCreation, "702 Creation Paused");
        require(
          matchAddresSigner(hashTransaction(msg.sender, msg.value), signature_),
         "706 Signature doesn't match."
        );
        require(expiry_ > block.timestamp, "already expired");

        uint256 id = nextId++;

        request storage req = requests[id];
        req.id=id;
        req.status = 0;
        req.expiry = expiry_;
        req.targetAmount = targetAmount_;
        req.currentAmount += msg.value;
        req.title = title_;
        req.description = description_;
        req.targetCollection = targetCollection_;
        req.participantWallets = [msg.sender];
        req.participantAmounts = [msg.value];
        req.participantTimestamp = [block.timestamp];

        requests[id] = req; 
        activeRequests++;

        totalInvested[msg.sender] += (int)(msg.value);
        emit RequestCreated(id, msg.sender, block.timestamp);
    }
 
    /**
     * Support the Request by adding funds
     * @param id_ The request id to invest in/support
     * @param signature_ bytes: verification that you are allowed to use the tool
     */
    function supportRequest(
        uint256 id_,
        bytes memory signature_
    ) public payable 
    {
        require(!pauseSupport, "702 Supporting Paused");
        require(
          matchAddresSigner(hashTransaction(msg.sender, msg.value), signature_),
         "706 Signature doesn't match."
        );

        require(id_ < nextId, "704 Query for nonexistent id"); 
        request storage req = requests[id_];
        require (req.expiry > block.timestamp, "support too late, request expired");
        require (msg.value > 0, "need to send currency");
        require ((msg.value + req.currentAmount) <= req.targetAmount, "Invest would exceed target Amount");

        req.currentAmount += msg.value;
        req.participantAmounts.push(msg.value);
        req.participantWallets.push(msg.sender);
        req.participantTimestamp.push(block.timestamp);

        requests[id_] = req;
        totalInvested[msg.sender] += (int)(msg.value);
        emit RequestSupported(id_, msg.sender, msg.value, block.timestamp);
    }

    /**
     * Finalize the request by refunding or initiating invest
     * @param id_ The request id to finalize
     */
    function finalizeRequest(
        uint256 id_
    ) public 
    {
       require(!pauseFinalize, "702 Finalization Paused");
       require(id_ >= 0 && id_ < nextId,"704 Query for nonexistent id");
       request storage req = requests[id_]; 
       if(req.currentAmount >= req.targetAmount)
       {
          //successful
          require(req.status == 0, "Request already finalized");
          req.status = 2;
          requests[id_] = req; 
          require (!payingOut, "Please wait for current finalize to finish.");
          payingOut = true;
          (bool success, ) = trust.call{value: req.currentAmount}("");
          require(success, "Transfer failed!");
          payingOut = false;
          emit RequestFinalized(id_, true, req.currentAmount, req.targetAmount, block.timestamp);
       }
       else 
       {
          require (req.expiry < block.timestamp, "not ready");
          //not successful
          require(req.status == 0, "Request already finalized");
          req.status = 1;
          requests[id_] = req; 
          bool success = refundRequest(req.id);
          require(success);
          emit RequestFinalized(id_, false, req.currentAmount, req.targetAmount, block.timestamp);
       }
    }

    /**
     * Refund the request
     * @param id_ The request id to payout/refund
     */
    function refundRequest(
        uint256 id_
    ) private returns (bool)
    {
       require(id_ < nextId, "704 Query for nonexistent id"); 
       request storage req = requests[id_]; 
       for(uint256 i = 0; i < req.participantWallets.length; i++)
       {
          address payable wallet = payable(req.participantWallets[i]);
          uint256 amount = req.participantAmounts[i];
          if(amount > 0) //no transfer of negative or zero amounts
          {
            totalInvested[wallet] -= (int)(amount);
            require (!payingOut, "Please wait for current finalize to finish.");
            payingOut = true;
            (bool success, ) = wallet.call{value: amount}("");
            require(success, "Transfer failed!");
            payingOut = false;
          }
       }
       return true;
    }

    /**
     * Pays out successful investment
     * @param id_ The request id to payout
     */
    function payoutRequest(
        uint256 id_
    ) public returns (bool)
    {
       require(!pausePayout, "702 Payout Paused");
       require(id_ < nextId, "704 Query for nonexistent id"); 
       request storage req = requests[id_]; 
       require(req.status == 3, "Status not 3");
       req.status = 4;
       requests[id_] = req; 

       for(uint256 i = 0; i < req.participantWallets.length; ++i){
          address payable wallet = payable(req.participantWallets[i]);
          require(req.currentAmount > 0, "704 Nothing invested in request");
          uint256 amount = (req.participantAmounts[i] * req.soldAmount) / req.currentAmount;         
          if(amount > 0) //no transfer of negative or zero amounts
          {
            require (!payingOut, "Please wait for current payout to finish.");
            payingOut = true;
            (bool success, ) = wallet.call{value: amount}("");
            require(success, "Transfer failed!");
            payingOut = false;
          }
       }
       emit RequestPayedOut(id_, block.timestamp);
       return true;
    }

    /**
     * Let the trust mark the request as sold and indicate the amount
     * @param id_ The request id to mark as sold
     */
    function soldRequest(
        uint256 id_
    ) public payable 
    {
       require(!pauseSold, "702 Mark as Sold Paused");
       require(msg.sender == trust, "Only available from trust");
       require(0 <= id_ && id_ < nextId, "704 Query for nonexistent id"); 
       request storage req = requests[id_]; 
       require(req.status == 2, "Status not 2");
       require(req.currentAmount > 0, "704 Nothing invested in request");
       req.status = 3;
       req.soldAmount = msg.value;
       requests[id_] = req; 

       for(uint256 i = 0; i < req.participantWallets.length; ++i){
          address payable wallet = payable(req.participantWallets[i]);
          uint256 amount = (req.participantAmounts[i] * req.soldAmount) / req.currentAmount;         
          totalPnL[wallet] += (int)(amount) - (int)(req.participantAmounts[i]);
       }
       emit RequestSold(id_, msg.value, block.timestamp);
    }

    /**
     * Splits the sent either to investors of the request as "Airdrop"
     * @param id_ The request id to airdrop to
     * @param description Short description of the Airdrop
     */
    function payoutRequestAirdrop(
        uint256 id_,
        string memory description
    ) public payable returns (bool)
    {
       require(!pausePayout, "702 Payout Paused");
       require(id_ < nextId, "704 Query for nonexistent id"); 
       request storage req = requests[id_]; 
       uint256 value = msg.value;

       for(uint256 i = 0; i < req.participantWallets.length; ++i){
          address payable wallet = payable(req.participantWallets[i]);
          require(req.currentAmount > 0, "704 Nothing invested in request");
          uint256 amount = (req.participantAmounts[i] * value) / req.currentAmount;         
          if(amount > 0) //no transfer of negative or zero amounts
          {
            require (!payingOut, "Please wait for current payout to finish.");
            payingOut = true;
            (bool success, ) = wallet.call{value: amount}("");
            require(success, "Transfer failed!");
            payingOut = false;
            totalPnL[wallet] += (int)(amount);
          }
       }
       emit RequestAirdrop(id_, msg.value, description, block.timestamp);
       return true;
    }

    /**
     * Returns the request given by the specific id_
     * @param id_ uint256 id of the request
     */
    function getRequest(
        uint256 id_
    ) public view returns (request memory)
    {
        require(id_ < nextId, "704 Query for nonexistent id"); 
        return requests[id_];
    }

    /**
     * Returns all active requests (not sold or failed)
     */
    function getActiveRequests(
    ) public view returns (request[] memory)
    {
        request[] memory reqs = new request[](nextId); 
        for(uint256 i = 0; i < nextId; ++i)
        {
            if(reqs[i].status == 0 || reqs[i].status == 2)
            {
                reqs[i] = requests[i];
            }
        }
        return reqs;
    }

    /**
     * Returns all the Requests
     */
    function getAllRequests(
    ) public view returns (request[] memory)
    {
        request[] memory reqs = new request[](nextId); 
        for(uint256 i = 0; i < nextId; ++i)
        {
            reqs[i] = requests[i];
        }
        return reqs;
    }

    /**
     * Verify that address signing the hash with signature is indeed the signerAddress
     * @param hash The signed hash
     * @param signature The signature used to sign the hash
     */
    function matchAddresSigner(
        bytes32 hash,
        bytes memory signature
        ) private view returns(
            bool
        ) {
        return signerAddress == hash.recover(signature);
    }

    /**
     * Verify that the hash actually corresponds to the given public sale mint data
     * @param sender The address sending the transaction
     * @param amount the amount being sent (in WEI)
     */
    function hashTransaction(
        address sender,
        uint256 amount
        ) private pure returns(
            bytes32
        ) {
          return keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            keccak256(abi.encodePacked(sender, amount)))
          );
    }
}