// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: MIT

//** DCB IDO Contract */
//** Author: Aceson 2024.5 */

pragma solidity 0.8.25;

import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { Initializable } from "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import { MerkleProof } from "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

import { IDCBIDO } from "./interfaces/IDCBIDO.sol";
import { IDCBFactory } from "./interfaces/IDCBFactory.sol";
import { IDCBVesting } from "./interfaces/IDCBVesting.sol";

contract DCBIDO is IDCBIDO, Initializable {
    IDCBFactory public factory; // factory contract
    IDCBVesting public vesting; // vesting contract

    AgreementInfo public dcbAgreement; // agreement info
    IERC20 public saleToken; // sale token

    uint32[3] public durations; // duration of each round
    address[] private _participants; // total number of participants
    mapping(address => uint256) public userInvestment; // user investment mapping
    bytes32 public merkleRoot; // merkle root
    uint256[3] public roundsMultipliers; // allocation multiplier for each round

    uint8 public constant VERSION = 2;

    /**
     * @dev Modifier to restrict access to only the manager.
     */
    modifier onlyManager() {
        if (!factory.hasRole(keccak256("MANAGER_ROLE"), msg.sender)) revert NotManager();
        _;
    }

    /**
     * @dev Initializes the contract with given parameters.
     * @param p Parameters for the IDO.
     */
    function initialize(Params calldata p) external initializer {
        // Validate input parameters
        if (p.totalTokenOnSale == 0 || p.hardcap == 0 || p.startDate < block.timestamp) revert InvalidInput();

        // Set the factory, vesting contract addresses, and sale token address
        factory = IDCBFactory(p.factoryAddr);
        vesting = IDCBVesting(p.vestingAddr);
        saleToken = IERC20(p.saleTokenAddr);
        durations = p.durations;

        // Calculate the total duration of the IDO
        uint32 totalDuration = p.durations[0] + p.durations[1] + p.durations[2];
        if (totalDuration == 0) revert InvalidDuration();

        // Initialize the agreement with provided parameters
        dcbAgreement.totalTokenOnSale = p.totalTokenOnSale;
        dcbAgreement.hardcap = p.hardcap;
        dcbAgreement.startDate = p.startDate;
        dcbAgreement.endDate = p.startDate + totalDuration;
        dcbAgreement.token = IERC20(p.paymentToken);
        dcbAgreement.totalInvestFund = 0;

        // Initialize rounds multipliers
        roundsMultipliers = [1, 2, 10];

        // Emit event to signal creation of agreement
        emit CreateAgreement(p);
    }

    /**
     * @dev Function to edit the agreement.
     * @param p Parameters of the agreement.
     */
    function setParams(Params calldata p) external {
        // Only factory can call this function
        if (msg.sender != address(factory)) revert NotManager();
        // Validate input parameters
        if (p.totalTokenOnSale == 0 || p.hardcap == 0 || p.startDate < block.timestamp) revert InvalidInput();

        // Update sale token and durations
        saleToken = IERC20(p.saleTokenAddr);
        durations = p.durations;

        // Calculate the total duration of the IDO
        uint32 totalDuration = p.durations[0] + p.durations[1] + p.durations[2];
        if (totalDuration == 0) revert InvalidDuration();

        // Edit the agreement with provided parameters
        dcbAgreement.totalTokenOnSale = p.totalTokenOnSale;
        dcbAgreement.hardcap = p.hardcap;
        dcbAgreement.startDate = p.startDate;
        dcbAgreement.endDate = p.startDate + totalDuration;
        dcbAgreement.token = IERC20(p.paymentToken);

        // Emit event to signal the editing of agreement
        emit EditAgreement(p);
    }

    /**
     * @dev Function to set the sale token.
     * @param _token Address of the token.
     */
    function setToken(address _token) external {
        if (msg.sender != address(factory)) revert NotManager();
        saleToken = IERC20(_token);
    }

    /**
     * @dev Function to set the Merkle root.
     * @param _merkleRoot Merkle root of the agreement.
     */
    function setMerkleRoot(bytes32 _merkleRoot) external onlyManager {
        if (merkleRoot != 0x0) revert MerkleRootAlreadySet();
        merkleRoot = _merkleRoot;
    }

    /**
     * @dev Function to set the rounds multipliers.
     * @param _multipliers Multipliers for each round.
     */
    function setRoundsMultipliers(uint256[3] calldata _multipliers) external onlyManager {
        roundsMultipliers = _multipliers;
    }

    /**
     * @dev Function to fund the agreement.
     * @param _investFund Amount of fund to invest.
     * @param allocation Allocation of the user.
     * @param refundFee Refund fee of the user.
     * @param merkleProof Merkle proof of the user.
     * @return bool Return status of the operation.
     */
    function fundAgreement(
        uint256 _investFund,
        uint256 allocation,
        uint256 refundFee,
        bytes32[] calldata merkleProof
    )
        external
        override
        returns (bool)
    {
        if (merkleRoot == 0x0) revert MerkleRootNotSet();
        // Verify the Merkle proof.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, allocation, refundFee))));
        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) revert InvalidProof();
        // Check if the sale token is received.
        if (saleToken.balanceOf(address(vesting)) < dcbAgreement.totalTokenOnSale) revert TokenNotRecived();
        // Check if the IDO is open.
        if (block.timestamp < dcbAgreement.startDate || block.timestamp > dcbAgreement.endDate) revert IDONotOpen();
        // Check if the hardcap is achieved.
        if (dcbAgreement.totalInvestFund + _investFund > dcbAgreement.hardcap) revert HardcapAchieved();

        uint256 multi = 0;

        if (uint32(block.timestamp) < dcbAgreement.startDate + durations[0]) {
            // First round - FCFS - 1x default allocation.
            multi = roundsMultipliers[0];
        } else if (uint32(block.timestamp) < dcbAgreement.startDate + durations[0] + durations[1]) {
            // Second round - FCFS - 2x default allocation.
            multi = roundsMultipliers[1];
        } else {
            // Third round - FCFS - 10x default allocation.
            multi = roundsMultipliers[2];
        }

        // Check if the user has already used up the allocation.
        if (userInvestment[msg.sender] + _investFund > allocation * multi) revert AmountExceedsAllocation();
        if (userInvestment[msg.sender] == 0) {
            // Add the user to the list of participants.
            _participants.push(msg.sender);
        }

        // Update the user investment.
        userInvestment[msg.sender] += _investFund;
        dcbAgreement.totalInvestFund = dcbAgreement.totalInvestFund + _investFund;

        // Calculate the number of tokens to be received.
        uint256 value = userInvestment[msg.sender];
        uint256 numTokens = (value * dcbAgreement.totalTokenOnSale) / (dcbAgreement.hardcap);

        if (numTokens == 0) revert InvalidTokensReceived();

        // Setup vesting and transfer payment token.
        factory.setUserInvestment(msg.sender, address(this), value);
        vesting.setIDOWhitelist(msg.sender, numTokens, value, refundFee);

        emit NewInvestment(msg.sender, _investFund);

        return true;
    }

    /**
     * @dev Getter function for the list of participants.
     * @return address[] Return total participants of IDO.
     */
    function getParticipants() external view returns (address[] memory) {
        return _participants;
    }

    /**
     * @dev Getter function for agreement info.
     * @return uint256 Hardcap.
     * @return uint256 Start date.
     * @return uint256 End date.
     * @return uint256 Total investment fund.
     * @return uint256 Number of participants.
     */
    function getInfo() public view override returns (uint256, uint256, uint256, uint256, uint256) {
        return (
            dcbAgreement.hardcap,
            dcbAgreement.startDate,
            dcbAgreement.endDate,
            dcbAgreement.totalInvestFund,
            _participants.length
        );
    }
}
// SPDX-License-Identifier: UNLICENSED

//** DCB Investments Interface */
//** Author Aaron & Aceson : DCB 2023.2 */

pragma solidity 0.8.25;

interface IDCBFactory {
    function changeImplementations(address _newVesting, address _newL2E, address _newIDO) external;

    function hasRole(bytes32, address) external view returns (bool);

    function claimDistribution(address _event) external returns (bool);

    function idoImpl() external view returns (address);

    function eventsList(uint256) external view returns (address);

    function getUserInvestments(address _address) external view returns (address[] memory);

    function initialize() external;

    function numUserInvestments(address) external view returns (uint256);

    function setManagerRole(address _user, bool _status) external;

    function setUserInvestment(address _address, address _event, uint256 _amount) external returns (bool);

    function l2eImpl() external view returns (address);

    function userAmount(address, address) external view returns (uint256);

    function vestingImpl() external view returns (address);
}
// SPDX-License-Identifier: MIT

//** DCB IDO Interface */
//** Author: Aceson & Aaron 2023.3 */

import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

pragma solidity 0.8.25;

interface IDCBIDO {
    struct Params {
        uint32 startDate;
        address factoryAddr;
        address vestingAddr;
        address paymentToken;
        address saleTokenAddr;
        uint256 totalTokenOnSale;
        uint256 hardcap;
        uint32[3] durations;
    }

    struct AgreementInfo {
        IERC20 token;
        uint32 startDate;
        uint32 endDate;
        uint256 totalTokenOnSale;
        uint256 hardcap;
        uint256 totalInvestFund;
    }

    event CreateAgreement(Params);
    event EditAgreement(Params p);
    event NewInvestment(address wallet, uint256 amount);

    error NotManager();
    error InvalidInput();
    error InvalidDuration();
    error InvalidProof();
    error IDONotOpen();
    error TokenNotRecived();
    error HardcapAchieved();
    error AmountExceedsAllocation();
    error InvalidTokensReceived();
    error MerkleRootAlreadySet();
    error MerkleRootNotSet();

    function initialize(Params memory p) external;
    function setParams(Params calldata p) external;
    function setToken(address _token) external;
    function setRoundsMultipliers(uint256[3] calldata multipliers) external;
    function fundAgreement(
        uint256 _investFund,
        uint256 allocation,
        uint256 refundFee,
        bytes32[] calldata merkleProof
    )
        external
        returns (bool);
    function getInfo()
        external
        view
        returns (
            uint256 hardcap,
            uint256 startDate,
            uint256 endDate,
            uint256 totalInvestFund,
            uint256 totalParticipants
        );
    function getParticipants() external view returns (address[] memory);
}
// SPDX-License-Identifier: MIT

//** DCB Vesting Interface */

pragma solidity 0.8.25;

interface IDCBVesting {
    struct VestingInfo {
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 initialUnlockPercent;
    }

    struct VestingPool {
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 initialUnlockPercent;
        WhitelistInfo[] whitelistPool;
        mapping(address => HasWhitelist) hasWhitelist;
    }

    /**
     *
     * @dev WhiteInfo is the struct type which store whitelist information
     *
     */
    struct WhitelistInfo {
        bool refunded;
        address wallet;
        uint256 amount;
        uint256 distributedAmount;
        uint256 value; // price * amount in decimals of payment token
        uint256 refundFee;
        uint256 refundDate;
    }

    struct HasWhitelist {
        uint256 arrIdx;
        bool active;
    }

    struct ContractSetup {
        address _innovator;
        address _vestedToken;
        address _paymentToken;
        uint256 _totalTokenOnSale;
        uint256 _gracePeriod;
    }

    struct VestingSetup {
        uint256 _startTime;
        uint256 _cliff;
        uint256 _duration;
        uint256 _initialUnlockPercent;
    }

    error OnlyInnovator();
    error OnlyFactory();
    error UserNotInWhitelist();
    error InvalidParams();
    error VestingAlreadyStarted();
    error AlreadyVested();
    error AlreadyRefunded();
    error AlreadyClaimed();
    error NotInGracePeriod();
    error IDOStillInProgress();
    error GracePeriodInProgress();
    error ZeroAmount();
    error AlreadyRegistered();
    error FundsNotClaimed();

    event IDOInitialized(ContractSetup c, VestingSetup p);
    event IDOSet(ContractSetup c);
    event L2EInitialized(address _token, VestingSetup p);
    event RaisedFundsClaimed(uint256 payment, uint256 remaining);
    event BuybackAndBurn(uint256 amount);
    event SetVestingParams(uint256 _cliff, uint256 _start, uint256 _duration, uint256 _initialUnlockPercent);
    event Claim(address indexed token, uint256 amount, uint256 time);
    event SetWhitelist(address indexed wallet, uint256 amount, uint256 value);
    event Refund(address indexed wallet, uint256 amount);

    function initializeIDO(ContractSetup memory c, VestingSetup memory p) external;

    function initializeL2E(address _token, VestingSetup memory p) external;

    function setIDOWhitelist(address _wallet, uint256 _amount, uint256 _value, uint256 _refundFee) external;

    function setL2EWhitelist(address _wallet, uint256 _amount) external;

    function claimDistribution(address _wallet) external returns (bool);

    function getWhitelist(address _wallet) external view returns (WhitelistInfo memory);

    function getWhitelistPool() external view returns (WhitelistInfo[] memory);

    function transferOwnership(address _newOwner) external;

    function setVestingParams(
        uint256 _cliff,
        uint256 _start,
        uint256 _duration,
        uint256 _initialUnlockPercent
    )
        external;

    function setIDOParams(ContractSetup calldata c) external;

    function setToken(address _newToken) external;

    function rescueTokens(address _receiver, uint256 _amount) external;

    /**
     *
     * inherit functions will be used in contract
     *
     */
    function getVestAmount(address _wallet) external view returns (uint256);

    function getReleasableAmount(address _wallet) external view returns (uint256);

    function getVestingInfo() external view returns (VestingInfo memory);
}