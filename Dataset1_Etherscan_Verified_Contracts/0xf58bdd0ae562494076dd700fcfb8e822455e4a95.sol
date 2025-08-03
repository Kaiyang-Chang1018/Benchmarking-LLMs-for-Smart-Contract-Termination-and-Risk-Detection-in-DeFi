// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
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
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC721Burnable {
    function ownerOf(uint tokenId) external view returns(address);
    function burn(uint tokenId) external;
}

interface IDGinBetweeners {
    function mint(address to, uint tokenId) external;
}

contract InbetERC721RedeemRouter is Ownable {

    IERC721Burnable public token;
    IDGinBetweeners public mirrorToken;

    event TokenRedeemed(address indexed account, uint[] tokenIds, bytes metadata);

    uint public startTime = 0;
    uint public endTime = 0;

    // uint public price = 0.0055 ether;
    uint public price = 0 ether;

    mapping(uint => bool) public redeemed;

    address payable public moneyReceiver = payable(0xDC9781Bf813d46B686e8458d81457C184722C212);
    address payable public feeReceiver = payable(0xAc4B36C464D12A8B6eFD2410d36aC2928c07038C);

    address public verifyAddress;
    mapping(bytes => bool) public usedSig;

    event ErrorMoneySend(address indexed to, uint amount);

    constructor(IERC721Burnable _token, IDGinBetweeners _mirrorToken, address _verifyAddress) {
        token = _token;
        verifyAddress = _verifyAddress;
        mirrorToken = _mirrorToken;
    }

    function update(uint _startTime, uint _endTime, uint _price) public onlyOwner {
        startTime = _startTime;
        endTime = _endTime;
        price = _price;
    }

    function redeemBatch(uint[] memory /*tokenIds*/, bytes memory /*metadata*/) external payable {
        revert("inactive");
    }
    
    function redeemBatchWithVerification(uint[] memory tokenIds, bytes memory metadata, uint _amount, uint _seed, bytes memory signature) external payable {
        require(startTime < block.timestamp && block.timestamp < endTime, "burn inactive");
//        require(tokenIds.length == 1, "invalid tokenIds");
        require(!usedSig[signature], "seed already used");

        require(verify(msg.sender, _amount, _seed, signature), "invalid signature");
        usedSig[signature] = true;

        require(msg.value == price * tokenIds.length + _amount, "invalid value");

        (bool success, ) = moneyReceiver.call{value: price * tokenIds.length}("");
        if(!success) {
            emit ErrorMoneySend(moneyReceiver, price * tokenIds.length);
        }

        (success, ) = feeReceiver.call{value: _amount}("");
        if(!success){
            emit ErrorMoneySend(moneyReceiver, _amount);
        }

        for(uint i = 0; i < tokenIds.length; i++) {
            require(!redeemed[tokenIds[i]], "token already redeemed");
            token.burn(tokenIds[i]);
            redeemed[tokenIds[i]] = true;
            mirrorToken.mint(msg.sender, tokenIds[i]);
        }

        emit TokenRedeemed(msg.sender, tokenIds, metadata);
    }

    function withdraw() public onlyOwner {
        (bool success, ) = moneyReceiver.call{value: address(this).balance}("");
        if(!success) {
            emit ErrorMoneySend(msg.sender, address(this).balance);
        }
    }

    /// signature methods.
    function verify(
        address _userAddress,
        uint _amount,
        uint _seed,
        bytes memory signature
    )
    public view returns(bool)
    {
        bytes32 message = prefixed(keccak256(abi.encodePacked(_userAddress, _amount, _seed, address(this))));
        return (recoverSigner(message, signature) == verifyAddress);
    }

    function recoverSigner(bytes32 message, bytes memory sig)
    internal
    pure
    returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(sig, (uint8, bytes32, bytes32));

        return ecrecover(message, v, r, s);
    }

    /// builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

}