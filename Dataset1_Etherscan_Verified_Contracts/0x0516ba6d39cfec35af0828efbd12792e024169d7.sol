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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
pragma solidity 0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface IReleases {
    function releaseExists(uint256 __id) external view returns (bool);

    function mint(address __account, uint256 __id, uint256 __amount) external;

    function maxSupply(uint __id) external returns (uint256);
}

contract Claims is Ownable, Pausable {
    error AccountsAndAmountsDoNotMatch();
    error AmountExceedsAvailableClaims();
    error AmountsDoNotMatchMaxSupply();
    error ClaimIsPaused();
    error Forbidden();
    error HasEnded();
    error HasNotStarted();
    error InvalidAddress();
    error InvalidAmount();
    error InvalidStart();
    error ReleaseNotFound();

    event ClaimCreated(uint256 __releaseID, uint256 __start, uint256 __end);
    event ClaimPaused(uint256 __releaseID);
    event ClaimUnpaused(uint256 __releaseID);

    struct Claim {
        bool paused;
        uint256 start;
        uint256 end;
    }

    mapping(uint256 => Claim) private _claims;
    mapping(uint256 => mapping(address => uint256)) private _availableClaims;

    IReleases private _releasesContract;

    constructor(address __releasesContractAddress) {
        if (__releasesContractAddress == address(0)) {
            revert InvalidAddress();
        }

        _releasesContract = IReleases(__releasesContractAddress);
    }

    ////////////////////////////////////////////////////////////////////////////
    // MODIFIERS
    ////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Checks if sender is EOA.
     *
     * Requirements:
     *
     * - Sender must be EOA.
     */
    modifier onlyEOA() {
        if (tx.origin != msg.sender) {
            revert Forbidden();
        }
        _;
    }

    ////////////////////////////////////////////////////////////////////////////
    // OWNER
    ////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Creates a new claim for a release.
     *
     * Requirements:
     *
     * - Release must exist.
     * - Start must be earlier than End.
     * - Length of Accounts and Amounts must match.
     * - Total Amount must match Max Supply of Release.
     */
    function createClaim(
        uint256 __releaseID,
        uint256 __start,
        uint256 __end,
        address[] memory __accounts,
        uint256[] memory __amounts
    ) external onlyOwner {
        if (!_releasesContract.releaseExists(__releaseID)) {
            revert ReleaseNotFound();
        }

        if (__start > __end) {
            revert InvalidStart();
        }

        if (__accounts.length != __amounts.length) {
            revert AccountsAndAmountsDoNotMatch();
        }

        uint256 total = 0;
        for (uint256 i = 0; i < __amounts.length; i++) {
            total += __amounts[i];
        }

        if (_releasesContract.maxSupply(__releaseID) != total) {
            revert AmountsDoNotMatchMaxSupply();
        }

        for (uint256 i = 0; i < __accounts.length; i++) {
            _availableClaims[__releaseID][__accounts[i]] = __amounts[i];
        }

        _claims[__releaseID] = Claim({
            paused: false,
            start: __start,
            end: __end
        });

        emit ClaimCreated(__releaseID, __start, __end);
    }

    /**
     * @dev Pauses contract.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses contract.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Pauses specific claim.
     */
    function pauseClaim(uint256 __releaseID) external onlyOwner {
        _claims[__releaseID].paused = true;

        emit ClaimPaused(__releaseID);
    }

    /**
     * @dev Unpauses specific claim.
     */
    function unpauseClaim(uint256 __releaseID) external onlyOwner {
        _claims[__releaseID].paused = false;

        emit ClaimUnpaused(__releaseID);
    }

    ////////////////////////////////////////////////////////////////////////////
    // WRITES
    ////////////////////////////////////////////////////////////////////////////

    function useClaim(
        uint256 __releaseID,
        uint __amount
    ) external whenNotPaused onlyEOA {
        if (!_releasesContract.releaseExists(__releaseID)) {
            revert ReleaseNotFound();
        }

        if (__amount == 0) {
            revert InvalidAmount();
        }

        address account = _msgSender();

        if (__amount > availableClaims(account, __releaseID)) {
            revert AmountExceedsAvailableClaims();
        }

        Claim memory claim = _claims[__releaseID];

        if (claim.paused) {
            revert ClaimIsPaused();
        }

        if (block.timestamp < claim.start) {
            revert HasNotStarted();
        }

        if (block.timestamp > claim.end) {
            revert HasEnded();
        }

        _releasesContract.mint(account, __releaseID, __amount);

        _availableClaims[__releaseID][account] -= __amount;
    }

    ////////////////////////////////////////////////////////////////////////////
    // AVAILABLE CLAIMS
    ////////////////////////////////////////////////////////////////////////////

    function availableClaims(
        address __account,
        uint256 __releaseID
    ) public view returns (uint256) {
        return _availableClaims[__releaseID][__account];
    }
}
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMNOdxXMMMMMMMMNOdlloxXMMMXxooxXMMMXxokNMXOxoxXMMMMNOxoodkXW0xkKMMKxdONKxddddddddONMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMM0'  dMMMMMMNx,   ...kMMWd    oWMMx. ,KMO:. .kMWKl'   ...dN:  lWWl  '0x.      . ;0MMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMM0'  dMMMMMNo. .cOK00WMMK;    ,KMMd  ,KMOc. .kWk.  .lk00OXN:  .;;.  '0N00k'  :00KWMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMM0'  dMMMMMO.  cNMMMMMMMx. ..  oWMd  ,KMOl. .x0'  'OMWNXNWN:   ...  '0MMMX;  oMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMM0'  dMMMMMk.  cWMMMMMMX;  ',  '0Md  '0Mk:. .kO.  ;XM0:.;ON:  :XXc  '0MMMX;  oMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMM0'  dMMMMMK;  .dXWWNWMx.       lWO.  :k;   ,KNl   ,dc. .kN:  cWWl  '0MMMX;  oMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMM0'  dMMMMMMKc.  .,,;OX;  :xkl. .ONo.      .xWMNx,      .kWc  cWWl  '0MMMX;  oMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMXdcl0MMMMMMMW0dc;;;c0Xo:lKMMNxcl0MWOoc:clo0WMMMMNOdc::cxXWOlcOWM0lcdXMMMNxcl0MMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMWklclOWMMMMMMMMMMWKxlcclkNMWKdc:clkNMM0olxXMXxlo0XxoooooooooxXXxooooodx0WMMMNklcl0MMMMMW0dlcclkN0dooooooookNMMM
// MMMMMM0'   ,KMMMMMMMMMKc.  ...:XNo.  .   :XWl   ;KO.  oO,...    ..'Ok.  ...  .cXMMO.   ;XMMM0:.  ...cXd...    ..cXMMM
// MMMMMWo     oWMMMMMMMK;  'xXXKXWo  .dKo.  oWl    ;d.  oWXKK0:  ,0KKWk. .dX0:  .kMWl    .xMM0'  'kXXKXMNKKk'  lKKXWMMM
// MMMMMK, .'. ,KMMMMMMMo  .xMMMMMK,  lWMK,  cNl     .   oMMMMWl  :NMMMk.  ':,.  ;KM0' .'. ;KWl  .kMMMMMMMMMK,  dMMMMMMM
// MMMMWo  .,.  oWMMMMMWl  .xMMMMM0'  oMM0'  oWl         oMMMMWl  :NMMMk.  ..   :KMWo  .,.  dNc  .kMMMMMMMMMK,  dMMMMMMM
// MMMMK,       '0MMMMMMO.  'kXNXNNc  'xx,  '0Wl  ;o.    oMMMMWl  :NMMMk. .xO'  cNM0'       ,Kk.  ,kXNXNMMMMK,  dMMMMMMM
// MMMWd  'xOk;  lWMMMMMWO;.  .'.:KK:      'OWWl  ;XO'   oMMMMWl  :NMMMk. .OWx. .xWo  ,kOk,  oNk,   .'.cXMMMK,  dMMMMMMM
// MMMWkccOWMMKolkNMMMMMMMW0dc::cdXMNkl::cxXMMMOllkWM0oll0MMMMWOolOWMMMXdldXMNkllkNkclOMMM0olkWMNOdc::cxXMMMNkloKMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMNkodKMWOllkNKolxXMMMWKxocccdKWOod0MM0olxNMMMMWOlccccccccoKKdlllllodONMMMXxc::co0WMXdloOWMMMMM0olokNMMMMMMMMM
// MMMMMMMMMK,  oNX:  ,Kd. '0MWO:.  ....xN:  lNXc  '0MMMMWc    .....,Ox.  ...   cXWk'  ..  .xWO.  .xWMMMO'   ,KMMMMMMMMM
// MMMMMMMMMK,  .'.   ,Kd  '0Wd.  ,xKXXKNN:  .'..  '0MMMMWc   'xO0KKXWk. .xX0:  .kO.  cK0,  ,KO.   .xWWO'    ,KMMMMMMMMM
// MMMMMMMMMX;  .;,.  ,Kd  '0O.  ,KMWK0KNN:  .,,.  '0MMMMWc    ..cKMMMk.  ';'.  :Ko  '0MMd  .OO.    .ox.     ,KMMMMMMMMM
// MMMMMMMMMX;  oWN:  ,Kd  '0O.  ,KMO,.'ON:  cWWc  '0MMMMWc   .::dXMMMk.  ..   cXWo  ,KMNc  ,KO.  ..     ;,  ,KMMMMMMMMM
// MMMMMMMMMX;  oMN:  ,Kd  '0No.  .c:  .kN:  lWWc  '0MMMMWc   :NMMMMMMk. .O0'  cNMO.  ckc. .dWO.  ox.   cXo  ,KMMMMMMMMM
// MMMMMMMMMN:  oMNc  ,Kd  '0MNk;.     .ONc  lWWl  '0MMMMWc   :NMMMMMMk. .OWx. .dWWx.     .oNMO.  dWO,.oNMo  ,KMMMMMMMMM
// MMMMMMMMMWOddKMW0ddONKxdkNMMMWKkdoodONW0dd0MM0ddkNMMMMWOoooOWMMMMMMXxoxXMWOooOWMMKxlcld0WMMXkdxKMMXKWMMKddONMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMM0lcoXWOlclOWNxclOWOc:xWMMMMMXo::lKMMMMMWk::ccccc:xNXdccccccokXMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMd  .xo.  cXMX;  oWl  :NMMMMMO.  .kMMMMMWc   .....lN0'  .'..  ,0MMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMo   .   ,KMMX;  oWl  :NMMMMMO.  .kMMMMMN:  ;kO0XXNW0'  oNKc   dMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMd       .dWMX;  oWc  :NMMMMMk.  .OMMMMMN:   ..:KMMM0'  .'..  ,0MMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMd   ,kd. '0MX;  oWc  cNMMMMMk.  .OMMMMMN:  .ccdXMMM0'  .'   ;KMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMd  .OMNc  cNX;  oN:  ,kOOO0Nk.  .oOOOOXN:  ;OOOOO0N0' .xX:  ,KMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMd  .OMMO. .xX;  oN:       'Ox.        oX:        .x0' .xM0'  lNMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMKxdkNMMW0xx0W0dxKWOdddddddxXXxdddddddd0WOdddddddddKNkdxXMM0ddONMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWMMMMMMMMMMWWWWMMMMMMMMMMMWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXo,,;OMMMMMXxc,',,;xNKl:oKXo,,,;:lONMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMx.   ;XMMWx'  .;;,,dWk. .O0'  ...  ;0MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX:    .dWWx.  cXMMWWWMk. .OO. .ONO;  :NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk. .;. ,KN:  '0MMMMMMMk. .OO. '0MMk. '0MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN:  ..   dN:  .kMMMMMMMk. .OO. '0MWd. ,KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.  ...  ,Kk.  'd00OOXMk. .OO. .oxc. .xWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNc  cKX0;  oW0c.      :Xk. .OO.     .,kWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWOdxXMMMXkkKWMWXOdoodd0NNOkONNkdddxk0NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWWWWWWWWMMWWWWMMMWWWMMWWWMMMMWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNo,,,,,,,,lXk,,,dWMk;'lX0:,;xNWd,,oNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX;  .,;,,,oXl   cNMd  '0x.  .oX:  ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX;  ;kOKWWWNc   cWMx. '0x.   .:,  ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX;     cNMMN:   cNMx. '0k.        ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX;  ,odOWMMWl   ,KWl  ,Kk. ..     ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNO0WX;  oMMMMMMMk.   ,;.  lWk. .xl    ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWd.'0X;  dMMMMMMMWx'..   .lXMk. .ONd.  :XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXO0WW0kkXMMMMMMMMMNK0kkOXWMMNOkONMWKkkKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXKK0KXNWMMMMMMMMMMMMMMMMMMMMMMWKxo:,'''';:lx0XWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMW0dc;'.......,:ldOXWMMMMMMMMMMMMMMWk;.             .;oOXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMWO;.                .;lkNMMMMMMMMMMMk.    ':cclc:;'.     .:xNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMO.    .;codxxxdoc;'.    'l0WMMMMMMMWl   .xNMN0OO0KNXOd:.    'xNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMN:   .dKKkollox0NMMN0d:.   .c0WMMMMMN:   lWMXc.  ..;dXWWXd'    ,kNMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMK,  .OWk' ...  .,kNMMMWK:    .oxdoddl.   lWMO. ;xd'  .oXMMXd.    cXMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMM0'  cNK, ;0Nd.    cXMMMMXc               lWMK, :NMx.   ;0MMW0;    ,OWMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMM0'  oMK, :NM0'     ;0MMMM0'              lWMX; ;XMk.    :XMMMX;    .kWMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMO.  oWWc .OMNc      ,0MMMX;     .:::'    cWMX; ;XMO.    .kMMMMk.    .kWMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMk.  cNMx. oWMd       cNMMN:   .dXWMM0'   cWMX; ,KMO.     lWMMMX;     '0MMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMx.  ,KMX; ,OKo.      ;XMM0'  .xWMMMM0'   oWMWo .;oc.     .OMMMWl      ;XMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMWXl   '0MWk. ...   ...'xWMMx.  :XMMMMMNo  ,0MMMNx:'.        dMMMWl       cNMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMNk:.    cXMMMXkdxkOO00KKNMMMMXd:oKMMMMMMMN0OXMMMMMMMWX0kdc,''cKMMWx.       .dWMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMNl.   .:xXMMMMMMMMMMMMMMMWX00NMMMMMMMMMMMMMMMMMMMMMMMMMWXNWWWWMMMWd.         '0MMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMNl   .xNWMMMMMMMMMMMMMMMMKc.  ,OMMMMMMMMMMMMMMMMMMMMMMWk,..oNMMMMWd.           lNMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMWd.   .lXMMMMMMMWNXKKXXWMX;     lWMMMMMMMWWNK0OOO0KNWMMO.   .OMMMMX;            .oWMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMM0'     .xMMMW0dc,......'::.     oWMMMWKxc;''''''''.';lx:    .xMMMMW0occldxxo;.   .kMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMWo    .;xNMKo,..,ldxkkkdl;.     .xMMWO:.'cdxk0KXXXKOxl,.      dMMMMMMMMMMMMMMWK:   :NMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMX;   :0WMXo. ,dKWMMMMMMMMWXx,   .xMXl.'xXMMMMMMMMMMMMMWO:     dMMMMMMMMMMMMMMMM0'  .OMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMO.   lNMK;  ;dxxxddoolllcccc;.  .kNl .lxxxkkkkkkkkkkOOO0Oc    dMMMMMMMMMMMMMMMMX;   oMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMk.    oXc        .'''.     .'.  .xk. ..       ...     ....    oWMMMMMMMMMMMMMMMX;   :NMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMx.    ;k, :k:    :kkd'    lXNk. '0d 'kO;    .cxxd'   .oOOk:   .oNMMMMMMMMMMMMMMK,   ,KMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMx.   .x0' oMXl.         'xNMWo  lWx.'0MK:.   ....   .xWMMN:     ;0MMMMNkdodxkOkc.   lNMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMx.  'kWNc ,KMW0o:;'';coONMMNd. :KMK, cXMW0oc;'....;oKWMMWd.      ;XMM0;            .kMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMx. ,KMMM0, ,OWMMMWWWWMMMMNk; .oXWX0l. 'lxOKNNNXKKXWMMMWKc.    .,cOWMM0'             ;KMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMO. ;0XNMMKc..:x0XNWWNX0kl'..cddc,..       ..,cd0KKXKOd:.  .;lxKWMMMMMWx.          .. .dNMMMMMMMMMMMMMM
// MMMMMMMMMMMMMWKl. .,',cONW0;  ..''''.. .:lc;. .;loxkkOOkdl:,.  ....      .,;l0MMMMMMMWO,         .c:  ,kWMMMMMMMMMMMM
// MMMMMMMMMMMMXl';dOKKOo..ck0Oc'.....,;loo:. 'lkXMMMMMMMMMMMMWKx:.           .,kMMMMMMMMMK;        .xNk' .oNMMMMMMMMMMM
// MMMMMMMMMMM0,.dNNkllkXO.  .'l0XXXXNXkl'..ckNMMMMMMMMMMMMMMMMMMWKl.   .lxxkOKNMMMMMMMMMMM0'   .'';xNMM0' .dMMMMMMMMMMM
// MMMMMMMMMMK,.xWK:.,'.lX:     cXXOd:'..:xXMMMMMMMMMMMMMMMMMMMMMMMWKc.  lNMMMMMMMMMMMMMMMMWd. ,0WNWWXkl'  ,OMMMMMMMMMMM
// MMMMMMMMMMd ;XWl.lNk.;0:      ....;ok0xokNMMMMMMMMMMMMMMMMMMNOxxKWNl   ':oxOKNMMMMMMMMMMMK, .OMWO;.  'ckNMMMMMMMMMMMM
// MMMMMMMMMMo ;XX;.dk;.ox.  .',cok0NWMMO'.cXMMMMMMMMMMMMMMW0xl'.  '0MX;       .'lXMMMMMMMMMWo  dMNc   ,0MMMMMMMMMMMMMMM
// MMMMMMMMMMk..OWO:,,;do..cOXNWMM0l:kWMWKOKWMMMMMMMMMMMNOo,. .cl.  dMMx.        '0MWK0OO0KNWO. ;XMXd,  ,0MMMMMMMMMMMMMM
// MMMMMMMMMMNl.'xXNKkd;..xWMMMMMMO;,dNMMk,'oXMMMMMWNOdc'  .:d0Wd  .kMMO.      .c0WO;.    ..,;. ,KMMMNo. ,0MMMMMMMMMMMMM
// MMMMMMMMMMMNk,..''.  .dMMMMMMMMMWWMMMMO:;xNWX0ko;.   .,'...':.  ;XMMk.    .lKWMN:           ,kWMMMMWd. 'OWMMMMMMMMMMM
// MMMMMMMMMMMMMN0kkxl'  .coxk0KXXXXK00Okxdol:,..  ..  .dNNKxl;.  .kMMNc   .c0WMMMWk.         .OMMMMMMWKl. .OMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMNOo:'.   .......           ,k0KOc..lXMMMWO; .xWWx.  ,OWMMMMMMM0;        '0Nklc:;'..  ;0MMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMXl. .;lxd:.  .,cl:,','. ,KMMMWx. cXMMMMX: 'Ox. .oNMMMMMMMMMMX:    ..:OWd    ':lodONMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMWk' ,dXWWO,.'lOXNk,... :x; 'xWMMWk. lNMMMMO. .. .kWMMMMMMMMMMMM0'  lKNWMMKl.  ,xNMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMM0' ,KMMMK, :XMMWd..dKd..cd. .oNMMWl .OMMMMX;   :KMMMMMMMMMMMMMMWl  lWMMMMMMXx;  ;0WMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMx. ,KMMMNl .:llc. .,'.       .OMMMk. dMMMMX; .xNMMMMMMMMMMMMMMMMx. :NMMMMMMMMNx. 'OMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMK,  'dKWMNkl:;;::cloddxkkl.   dMMMO. oWWMM0' lWMMMMMWX0OOOOO00Od, .dWMMMNXKK0ko'  dMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMO'   .;lxOKXNWWMMMWWWWNNXo.  dMMM0' lNWMWd .OMMMMMKc.           .dWMNk:'...   .,dXMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMXo'      ..',,;;;,,'''...  .xMMMO. oWWMK, cNMMMMWl              'kWO.  .codkOKWMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMNk;                      .kMMMx..OMMNl 'OMMMMMM0:.             .ONx,  'xNMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMNd.       ,lxkkxl,     .xMMMKdOWMNo..xWMMMMMMMW0c.          .lXMMNO, .dWMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMWO'     :XMMMMMMNk'    ,0MMMMW0x:..dWMMMMMMMMMMWk'   .;odxOXWMMMWNl  lWMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMK:    '0MMMMMMMMK;    .cool;. .;OWMMMMMMMMMMMMMk.  .ckkkxdol:;,.  ,0MMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNo.   :XMMMMMMMMK,        .cx0WMMMMMMMMMMMMMMMNc        ...',;cokXMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWx.   ;0WMMMMMMM0;       cNMMMMMMMMMMMMMMMMMMX;  .dkkOO0KXNWMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWO,   .cONMMMMMMNx;...'lXMMMMMMMMMMMMMMMWXOo,   cOXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0kdc.     'cxKNWWWWNK00KXXKK00Okkxdoolc:;'.        .cKMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMXo'.            ..',,,,'''......                       ;0MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMXo,'....',,;::cccccccccllllllooooooooooooollllllllllodONMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNXXXNWWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Claims} from "./Claims.sol";

contract KillerAcidFunEditionsClaims is Claims {
    constructor() Claims(0x9cfa218c61ff494cA627B813ee2c9D1e106D6fA6) {}
}