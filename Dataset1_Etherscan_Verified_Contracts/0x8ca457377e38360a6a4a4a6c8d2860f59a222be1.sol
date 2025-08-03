// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Bean Monger
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                //
//                                                                                                                                //
//    8@88@8@88@8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888@88@88@8@88@88@8    //
//    88@88@8@888@8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888@8@88@8@88@8@8    //
//    8@8@8888888888@88@88@88@88@8888888888888888888888888888888888888888888888888888888888888@88@88@88@88@88888888@8888@88@8@    //
//    8@88@8888S88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888@888888888888888@8    //
//    88@88@tttX88888888@88888888888888St;.::;tS888888888888888888888888888888888888St;...;tS@8888888888@88888@88@88%ttX88888@    //
//    8888@88X%X88888@88888888888888@;.  .    . .tX888888888888888888888888888888@t.   . .   .;X888888888888888888@88XSS8888@8    //
//    88888888888888888888888888888S   ..:::;;%@888888888888888888888888888888888888@S;:::::   .%8888888888@88888888888888888@    //
//    88@8888888888888888888888888%.tS@8888888888888888888888888888888888888888888888888888888St:%888888888888@8888888888888@8    //
//    888888888888888888888888888;  .88888888888888888888888888888888888888888888888888888888888;%;88888888888888@888888888888    //
//    88888888888888888888888888tXt%S8888888888888888888888888888888888888888888888888888888888t t%X88888888888888888888888888    //
//    888@88@88888888888888888888S% 888888888888888888888888888888888888888888888888888888888888%tS:@8888888888888888@88888@88    //
//    88888888888888888888888888S88%@888888888888888888888888888 8 8 888888888888888888888888888X888888888888888888@88888@8888    //
//    8888@888888X;888888888888SX88@@888888888888888888888 888S8 888 SS 88888888888888888888888888X8tX88888888888;%88888888888    //
//    88@88888888S8.%88888888888888t8888888888888888 888 8888.  % 8S8 8 @X88 888888888888888888888888X888888888t.@;S88888888@8    //
//    88888888888:t@; ;X888888888@@X 8888888888 88888888888S SS@SXX8@   8 X 8888 88888888888888 @88XS88888888; ;8S;888888@8888    //
//    88888888888X  X  .;88888888XX@ @8888.88 8888888888888   8   8 X8@  8 @ 888888 888888888888X8888888888%  :X;;8@8888888888    //
//    888888888888S% %  .:X8888 XXX8@t888888888888 888 88%  8  888888 @XX 8 88 S 888888 8888 8SX88X8 88888:  ;8St S@8888888888    //
//    888888888888X ..    .;@888;@SX8@t8888888888888888888  8888888888 8X   % :@8888888888888SX8888 @88@:   S@%t.8S@8888888888    //
//    888888888888@8.%t t   .;88.X8@8X;:88 8888 8888 888S8 88 888 8888 8  8 X%t88888 88888 888%XS:8t88;  . S@; :88S88888888888    //
//    8888888888888t.%S%;S   .:X888888X;;8888 8888%88888 8 88888888 88S8  X@88 88 888888 88 8 S8888@S: .  S8: t%88%@8888888888    //
//    8888888888888Xt:SS8:8    .;X888XS:: 88888888888888888%888 88888 88 S8.88888888888888S8  X@X ;.  . :88%:S@8888X8888888888    //
//    88888888888888S@;8t8;8      %.S8X% t%888888888 88 8@8@t88888 88@@ 8 8S8;88888888888@  t%%8t      :88%tXX888S%88888888888    //
//    888888888888888:8;8%8t8    . Xt@S%t.:8 888 88888888 %8;X88888888 88t:@ 888 888888 @X@ 8.X.t .   t8@%S8S8888X8X8888888888    //
//    888888888888888@t8;8X8S88     :8@tt88 88 888 8888888 8:;X8888888@ 8@ t88 8888 8 88 X:8 8 ;. . :@8@8X8X8888X;%88888888888    //
//    8888888888t8;..:;S88S88888;   . tX 8t%t8 ;88888 8 88888 t@88 88 88S 8888888888 888%:8 8;::   %8888@8X88@;. :S8@888888888    //
//    88888888888@88:   ;@88888888.  . %8%88888.X 8888888 88 ; ;888X @@8t88 88 888 S8XS 8:88t . .:S@@88888S;: .S8 ;t@888888888    //
//    88888888888888@@@: .;:%@8@@X8@; ..;;888888X88  8888888. :.:S8X8X888888 8888@888%8888 S. .;S@XXXXXt.. .:@8t%88S8888888888    //
//    888888888888888%%%X :   %XXXS@8X. .:X88888SSX%8888888888% ..888 8 8 8888888%88S8888X.  .X8XXSSXt  .  S8@@@8888S888888888    //
//    88888888888888X8%888S. . :tXXXX88@t%tXX8888 t .%888888 8; .. @ 888888888St.X888 8@8t%t@888XSSt: . .t@888@888XS8888888888    //
//    888888888888888%@%888@%:  . :%X@888S:;88888@88 .:%S%X8X:.  :88888888X@t.. 8%888@88:;%88888%:.   :tX@888888888X8888888888    //
//    88888888888.8888S%S88XXXt   .  ;S88StS88888@X8S   .....  . SX..X8888: .  X.8@8@888@tt8S8S   . .tXXX@@888888S8X8888888888    //
//    888888888 8@888S88;@8@SSS%;: .  .:%t%t@8@XXS8S@t;; .     . 88.:SS8X;. ;@S 8%SXX8X8%%t;:... ..;%%SSX@88S88@8S888888888888    //
//    8888888888888888X88t888@%tttt;::  :.tt%%. X S   ;     .. .SX8X;;SX%.. ;8;  S XS S%tt.  .:tt%t%t%S888888@8%88X88888888888    //
//    8888888888888 888888%8X888t:;:;;ttt:.;ttt8.X S %;    .  8X 88. 8%:t:  .::.S @ 8;tt;.:tX@@%ttttS8X8888@X8X8@8888888888888    //
//    88888;8888888888@;.     ;t.::::::;SXXXS;;tt8 .S8;.  :8SX 88tS8  @ 8X.   %t.%8t;;tS88888@S%;;::::.::.. ..%8888888S8888888    //
//    88888888888888888XS%; .. :.  . .:.:ttt%St;:8%8888; 8; 8.@ 888.8 8  88;:t%X% 8S;tX@@@XS%;:.    . .:;S@88XX888888888888888    //
//    888888888SS8888888X%%@@St:.   .  . ...::;;;8 8.888..SX@8 8 8;8:8 8;8 ;@@S8SX8t;;;;..    ..  . :;%%SSX88@8@88SX 888888888    //
//    8888888X@ 8 88888:88SXXXStt;;:.....:..::t;;S8t8888%;tX888S8:8 8:88tX8:X8XXX8@t;;:.......:::;;tt%%%S@8888@888   8%8888888    //
//    888%88X88@S88888888t88%%XX%t;;;:;tt%SSSXXt;%S%X@XX;.;8X88@@8 %%X88S8 :%@X%ttt;tX@XXS%%tttttt%SX@88888X8@88888X@8SS888888    //
//    88888 X88 888888 888t8X888X8X8@@S;;t;;;.. .:tt:::;::t8X8@8@8%88%8@8@ ;. t;;tt. ..;tttttSSX@8888@8X88888888S888 X88 88888    //
//    88888S88 8888 8888888:88S8X88@t.:.. .  ...:;t%tt:;.:t88888888X8%S8X@ ;: ;t;t;:...     ..:tS888888888888X8888888 X8S 8888    //
//    8888 @8 88888888888 88888:8%...  ......:.::;;;;. . XX@888@88X%X8;%%S8;.  .;;;;::.:.......   ;8@8@8X8X8888t888888 8X 8888    //
//    8888 @ 888888888888888888888;.. ..........::. . ..   S88@88;t8:S8S .;..    .:::.:.::.:.:::.:S8S88%888%88888888888S@ 8888    //
//    8888 X 8888 888888 88888 8888888Xt;:;;t%@:   .....    ; 8888tS88 @;...    . . ;tt;;;;;;tS888X88;888:8888:888 8888 @ 8888    //
//    8888 X 888888888 888888888%8 8:8t8;SSS%St   .. . .   .:  ; 88:;:.::. ...   . . :8XXX@XXXX8S88;8888888888888888888 @ 8888    //
//    888888 888888 8 8888@88888888888 888:888 ..   .t888@. ;  .:.  . .t..88;88    .. t%8t88t88;88:8888888X88 8 8888888X 88888    //
//    88888 S 88888888888  @8  8X88 888 888 8X::;tS8@SSS%%%8t:  .;;.  tt88.88 8;8X; ..;8:8.88.8888888  X8@X 8@88888888 SX88888    //
//    888888  888888888@X  88@8    88%88 88888 8;8:S%8;8:88 88. ..8% :S8.88 88 88:8;SS%88888888%X  8;@8t%; 8X 88888888X 888888    //
//    8888888  8888888888  @88 8;8  888888S88888 88.8 88%8 8 8S @ 88:;8.8 88S88 88 888.8 8 8%88X 8t8 XS@8%.888888@888  8888888    //
//    88888888 888X8888888S% %X8 t8  S8 8888888 88 8 8 88 888 8.XS88:88888888%8% 888S888888888XS8.X88XSS8S88888888888%88888888    //
//    88888888888@@X8X@8888 8t;t8@ t8 888888888888888:88X 8S8888:8S:t8 8S8 88:.8888  8 88 8 8S88 t@ S88%. 88888888888888888888    //
//    88888 8 .X8 88888888S.8t8.XS888;.888888 S 8 8X @88@.88 8 8t8@ 888 88 @8X8 @S8 X 8888888%%8:@ 8.t.S8S88X@8888888;;8888888    //
//    8888888;.S88888S:;t8%S8.t88  888S 8 888S88 8SSX%S%t .X88888:.;8 8888%XSS8%t.X StX8S8888X8  8:8%8t @%88XSS8888@S ;88t8888    //
//    8888 888@88XSS@88X8t.:;8 :@88@ 8t@8888X:@  88SS88:88S; 8888: 888  .X%S8;88:88t  .888888X@  8: 8;88:X:8@88@%%@888%X888888    //
//    8888888S8888:. ..tS ::t 8;S;%88S8X88888.;%XXS88 888 8@ 8888%.888888X 8:8 88 88;: X88 8X%88S8@8%X8@X88. .. ..X888S8@88888    //
//    8888888@X@88t .. 8 S888. 8;8t8t..S8888:  XX8;8 888@%% 8 8888t8888:%@S8888 888 8.:;8888SS8888@8%8888888: .. 88S8XX8X88888    //
//    888888888@8X;t.;:8;;%88@88XX@X@X88 888.:88S88888XtXX8%88 88S88888888S@8S8888888@S 8888888888X8888S@8:%@ . X t88@X8S88888    //
//    888888X8SXX@88SS   8%S. 8%8% %:% 888 8SS @S8S88@@8 8%8 88888888 8 88:XSX8 888 88@t8 8 8 S888.tXX88X%S8 ;; 8S8 8888;S8888    //
//    888888@88%8X888888.. @S: 888%:..;8 888  .%8888888X88.8888@88888888 88888888888 8%:888S@.@X8S@.8 .X8 8.Xt%t%8SX88@t:88888    //
//    888888;%8X8 8888888S @8.t@:@8S@8%X888;@ %%.8 88 8.8888 88888 88%8888 88.88 88%8@@@S8XX%tS8t88@;S.%8;@8888888 888S.@88888    //
//    8888888:t88888888 88@SS%X;S%8%8888S.X8S88%;88 88888 888888%8888888@888888888 %:@8.@%t@8888St88@S88% t%:8888888@t.8888888    //
//    88888888SX8S888888888888%888t8888888888; 8%@S888 888888888888 8888888888%888. 8.8888888%888::@8X8888;8; 8888888@88888888    //
//    88888888888@ XX@@@888X888S88888.88.88:88888 888 8888888888888888888888 88:;SXX88@88%8t888888888:88X@8888%t 8888888888888    //
//    88888888888  X88@88@88 888888;88888888    :888t8 88888 88 8888888 88 88S8S888::   t888888888888X@ 8@.88XX XX:88888888888    //
//    8888888888888888@@888888888888888 S88 8;  8.Sttt8888 88888888S888888888.:S:8: :. 8 S8X:88 888888888:X@8%8888888888888888    //
//    888888888888888888888888888.888@8:SS t%St.:t  ; ;@X 888888 8888 88 888 .:%;8; :SSt8t 8.8 8888888888888888888888888888888    //
//    888888888888888888888888888888@ 88 %@88@8888S%88@S; 8888 88888888888Xt88X8%@8@8%%SS@X%S .S888888888888888888888888888888    //
//    8888888X@88888888888888888888@%X%;@8.888@88X8888.  tX888888888888 8%:% S@888888888@t;8SSS  88888888888888888888@@8888888    //
//    8888888X%8888888888888888888XtX X8XX88X888888%8888.Xt8888888888 8@88XS%888888@8888888 @8:X. 8888888888888888888@SX888888    //
//    8888888888888888888888888 888 8t88X888888t888888888 X 8 8888888888 8.@88X88%88888X888 8XX8t@@888888888888888888888888888    //
//    888888888888888888888888888 8 888X.8888t888888:88;8 8S888888888888S8t8888888888%88888 XS8%8 8888888888888888888888888888    //
//    8888888888888888888888888888tS8%S8@888888888.888888%888888888888888S:88S8888888888888S8X8 888X88888888888888888888888888    //
//                                                                                                                                //
//                                                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract BM is ERC1155Creator {
    constructor() ERC1155Creator("Bean Monger", "BM") {}
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";

contract ERC1155Creator is Proxy {

    constructor(string memory name, string memory symbol) {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = 0xE9FF7CA11280553Af56d04Ecb8Be6B8c4468DCB2;
        (bool success, ) = 0xE9FF7CA11280553Af56d04Ecb8Be6B8c4468DCB2.delegatecall(abi.encodeWithSignature("initialize(string,string)", name, symbol));
        require(success, "Initialization failed");
    }

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the current implementation address.
     */
     function implementation() public view returns (address) {
        return _implementation();
    }

    function _implementation() internal override view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }    

}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

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
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, `uint256`._
 * _Available since v4.9 for `string`, `bytes`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}