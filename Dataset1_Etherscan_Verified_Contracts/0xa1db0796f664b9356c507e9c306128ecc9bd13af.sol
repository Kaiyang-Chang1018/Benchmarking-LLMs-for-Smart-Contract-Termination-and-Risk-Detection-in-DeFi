// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IDEXFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity >0.4.13;

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }

    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }

    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }

    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    //rounds to zero if x*y < WAD / 2
    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    //rounds to zero if x*y < WAD / 2
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    //rounds to zero if x*y < WAD / 2
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    //rounds to zero if x*y < RAY / 2
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}
pragma solidity ^0.8.17;
//SPDX-License-Identifier: MIT
import "Auth.sol";
import "OperaStakingV2.sol";

contract OperaPool is Auth {
    uint256 public totalEthLent;
    uint256 public totalAvailableEth;
    uint256 public numberOfLenders;
    uint256 public lendingStakingRequirement;
    uint256 public borrowLimit = 3;
    uint256 public _tokenDecimals = 1 * 10 ** 18;
    bool public borrowingEnable = true;
    OperaStakingV2 public operaStakingAddress;
    mapping(address => uint256) public usersCurrentLentAmount;
    mapping(uint256 => address) public lenderIdToAddress;
    mapping(address => uint256) public lenderAddressToId;
    mapping(address => bool) public authorizedFactoryAddresses;

    event ethMoved(
        address account,
        uint256 amount,
        uint256 code,
        uint256 blocktime
    ); // 1 lent 2 borrowed 3 returned 4 withdrawn

    event factoryStatusChange(address factoryAddress, bool status);

    constructor() Auth(msg.sender) {}

    modifier onlyFactoryAuthorized() {
        require(
            authorizedFactoryAddresses[msg.sender],
            "only factory contracts can borrow eth"
        );
        _;
    }

    function updateFactoryAuthorization(
        address addy,
        bool status
    ) external onlyOwner {
        authorizedFactoryAddresses[addy] = status;
        emit factoryStatusChange(addy, status);
    }

    function updateBorrowLimit(uint256 limit) external onlyOwner {
        borrowLimit = limit;
    }

    function updateLendingStakeRequirement(uint256 limit) external onlyOwner {
        lendingStakingRequirement = limit;
    }

    function setStakingAddress(address addy) external onlyOwner {
        operaStakingAddress = OperaStakingV2(addy);
    }

    function updateBorrowingEnabled(bool status) external onlyOwner {
        borrowingEnable = status;
    }

    receive() external payable {}

    function lendEth() external payable returns (bool) {
        require(
            msg.value > 0 && msg.value % _tokenDecimals == 0,
            "Only send full ether."
        );
        if (lendingStakingRequirement > 0) {
            require(
                operaStakingAddress.balanceOf(msg.sender) >=
                    lendingStakingRequirement,
                "You are not staking enough to lend."
            );
        }
        if (lenderAddressToId[msg.sender] == 0) {
            lenderAddressToId[msg.sender] = numberOfLenders + 1;
            lenderIdToAddress[numberOfLenders + 1] = msg.sender;
            numberOfLenders += 1;
        }
        uint256 amountReceived = msg.value / _tokenDecimals;
        emit ethMoved(msg.sender, amountReceived, 1, block.timestamp);
        totalEthLent += amountReceived;

        usersCurrentLentAmount[msg.sender] += amountReceived;
        totalAvailableEth += amountReceived;

        return true;
    }

    function borrowEth(uint256 _amount) external onlyFactoryAuthorized {
        require(_amount <= totalAvailableEth, "Not Enough eth to borrow");
        require(_amount > 0, "Cannot borrow 0");
        require(borrowingEnable, "Borrowing is not enabled.");
        require(_amount <= borrowLimit, "Can't borrow that much.");
        totalAvailableEth -= _amount;
        payable(msg.sender).transfer(_amount * _tokenDecimals);
        emit ethMoved(msg.sender, _amount, 2, block.timestamp);
    }

    function returnLentEth(uint256 amountEth) external payable returns (bool) {
        require(
            (amountEth * _tokenDecimals) - msg.value == 0,
            "Did not send enough eth."
        );

        emit ethMoved(msg.sender, amountEth, 3, block.timestamp);
        totalAvailableEth += amountEth;

        return true;
    }

    function withdrawLentEth(uint256 _amountEther) external payable {
        require(
            usersCurrentLentAmount[msg.sender] >= _amountEther,
            "You Did not lend that much."
        );

        require(_amountEther > 0, "Cant withdraw 0.");
        require(_amountEther <= totalAvailableEth, "Not enough eth available.");
        if (usersCurrentLentAmount[msg.sender] == _amountEther) {
            uint256 tempIdOfUser = lenderAddressToId[msg.sender];
            address addressOfLastUser = lenderIdToAddress[numberOfLenders];
            if (addressOfLastUser != msg.sender) {
                delete lenderAddressToId[msg.sender];
                lenderAddressToId[addressOfLastUser] = tempIdOfUser;
                lenderIdToAddress[tempIdOfUser] = addressOfLastUser;
                delete lenderIdToAddress[numberOfLenders];
                numberOfLenders -= 1;
            } else {
                delete lenderAddressToId[msg.sender];
                delete lenderIdToAddress[tempIdOfUser];
                numberOfLenders -= 1;
            }
        }
        usersCurrentLentAmount[msg.sender] -= _amountEther;
        totalAvailableEth -= _amountEther;
        totalEthLent -= _amountEther;
        payable(msg.sender).transfer(_amountEther * _tokenDecimals);
        emit ethMoved(msg.sender, _amountEther, 4, block.timestamp);
    }

    //safe gaurd so no funds get locked
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function removeExcess() external payable onlyOwner {
        require(
            address(this).balance > totalAvailableEth * _tokenDecimals,
            "There is no excess eth"
        );
        uint256 excessAmount = address(this).balance -
            (totalAvailableEth * _tokenDecimals);
        payable(owner).transfer(excessAmount);
    }
}
pragma solidity ^0.8.17;

//SPDX-License-Identifier: MIT
import "OperaToken.sol";
import "OperaLendingPool.sol";
import "IERC20.sol";
import "Math.sol";

contract OperaRevenue {
    address public owner;
    address public teamAlpha;
    address public teamBeta = 0xB0241BD37223F8c55096A2e15A13534A57938716;
    mapping(address => uint256) public claimableRewardsForAddress;
    address public lendingPoolAddress;
    event rewardsMoved(
        address account,
        uint256 amount,
        uint256 blocktime,
        bool incoming
    );
    event rewardsAwarded(address user, uint256 amount, uint256 blocktime);

    constructor() {
        owner = msg.sender;
        teamAlpha = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function requestReward() external {
        uint256 usersRewardAmount = claimableRewardsForAddress[msg.sender];
        require(usersRewardAmount > 0, "You have no rewards.");
        claimableRewardsForAddress[msg.sender] = 0;
        payable(msg.sender).transfer(usersRewardAmount);
        emit rewardsMoved(
            msg.sender,
            usersRewardAmount,
            block.timestamp,
            false
        );
    }

    function setLendingPoolAddress(address addy) external onlyOwner {
        lendingPoolAddress = addy;
    }

    function setBetaAddress(address addy) external onlyOwner {
        teamBeta = addy;
    }

    function setAlphaAddress(address addy) external onlyOwner {
        teamAlpha = addy;
    }

    function getAddressBalance(address _address) public view returns (uint256) {
        return _address.balance;
    }

    receive() external payable {}

    function recieveRewards() external payable {
        OperaPool lender = OperaPool(payable(lendingPoolAddress));
        uint256 totalEthLent = lender.totalEthLent();
        if (totalEthLent == 0) {
            uint256 getTeamFee = (msg.value * 50) / 100;
            claimableRewardsForAddress[teamAlpha] += getTeamFee;
            claimableRewardsForAddress[teamBeta] += getTeamFee;
        } else {
            uint256 numberOfLenders = lender.numberOfLenders();
            uint256 getLenderFee = (msg.value * 70) / 100;
            uint256 getTeamFee = (msg.value * 15) / 100;
            uint256 rewardsPerShare = getLenderFee / totalEthLent;
            address tempAddress;
            uint256 tempLentAmount;
            claimableRewardsForAddress[teamAlpha] += getTeamFee;
            claimableRewardsForAddress[teamBeta] += getTeamFee;
            for (uint256 i = 0; i < numberOfLenders; i++) {
                tempAddress = lender.lenderIdToAddress(i + 1);
                tempLentAmount = lender.usersCurrentLentAmount(tempAddress);
                claimableRewardsForAddress[tempAddress] +=
                    tempLentAmount *
                    rewardsPerShare;
                emit rewardsAwarded(
                    tempAddress,
                    tempLentAmount * rewardsPerShare,
                    block.timestamp
                );
            }
        }

        emit rewardsMoved(msg.sender, msg.value, block.timestamp, true);
    }
}
//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "OperaToken.sol";
import "SafeMath.sol";
import "IERC20.sol";

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
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
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
        require(_paused, "Pausable: not paused");
        _;
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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract OperaStakingV2 is Pausable, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public stakingTokensDecimalRate;
    address public stakeAdmin;
    uint256 public lockDuration;

    bool private initialised;
    bool public locked;

    uint256 public constant MAX_UNSTAKE_FEE = 2000;

    uint256 public earlyUnstakeFee = 1500;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor() {
        stakingTokensDecimalRate = 10 ** 9;
        rewardsToken = IERC20(0x3bd8268791DE798d4ED5d424d49412cF42B8eC3a);
        stakingToken = IERC20(0x3bd8268791DE798d4ED5d424d49412cF42B8eC3a);
        rewardsDuration = 2630000;
        locked = true;
        if (locked) {
            lockDuration = 2630000;
        }
        stakeAdmin = msg.sender;
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(stakingTokensDecimalRate)
                    .div(_totalSupply)
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            _balances[account]
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(stakingTokensDecimalRate)
                .add(rewards[account]);
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate.mul(rewardsDuration);
    }

    function min(uint256 a, uint256 b) public pure returns (uint256) {
        return a < b ? a : b;
    }

    function PoolInfo()
        public
        view
        returns (
            uint256 _periodFinish,
            uint256 _rewardRate,
            uint256 _rewardsDuration,
            uint256 _lastUpdateTime,
            uint256 _rewardPerToken,
            uint256 _getRewardForDuration,
            uint256 _lockDuration,
            uint256 _earlyUnstakeFee,
            uint256 _totSupply
        )
    {
        _periodFinish = periodFinish;
        _rewardRate = rewardRate;
        _rewardsDuration = rewardsDuration;
        _lastUpdateTime = lastUpdateTime;
        _rewardPerToken = rewardPerToken();
        _getRewardForDuration = rewardRate.mul(rewardsDuration);
        _lockDuration = lockDuration;
        _earlyUnstakeFee = earlyUnstakeFee;
        _totSupply = _totalSupply;
    }

    function UserInfo(
        address account
    )
        public
        view
        returns (uint256 _balanceOf, uint256 _earned, uint256 _rewards)
    {
        _balanceOf = _balances[account];
        _earned = earned(account);
        _rewards = rewards[account];
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(
        uint256 amount
    ) external notContract whenNotPaused updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(
        uint256 amount
    ) public notContract updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        if (locked) {
            require(block.timestamp >= periodFinish, "Lock Time is not over");
        }
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public notContract updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function emergencyWithdraw(
        uint256 amount //allows you to exit the contract before unlock time, at a penalty to your balance
    ) public notContract updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        getReward();
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        if (earlyUnstakeFee > 0) {
            uint256 adminFee = amount.mul(earlyUnstakeFee).div(10000);
            amount -= adminFee;
            stakingToken.safeTransfer(stakeAdmin, adminFee);
        }
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(
        uint256 reward
    ) external onlyOwner updateReward(address(0)) {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        require(
            rewardRate <= balance.div(rewardsDuration),
            "Provided reward too high"
        );

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }

    function setEarlyUnstakeFee(uint256 _earlyUnstakeFee) external onlyOwner {
        require(
            _earlyUnstakeFee <= MAX_UNSTAKE_FEE,
            "earlyUnstakeFee cannot be more than MAX_UNSTAKE_FEE"
        );
        earlyUnstakeFee = _earlyUnstakeFee;
    }

    // function setTokenInternalFee(uint256 _tokenInternalFess) external onlyOwner {
    //     tokenInternalFess = _tokenInternalFess;
    // }

    function manualUnlock() external onlyOwner {
        locked = false;
    }

    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    ) external onlyOwner {
        require(
            block.timestamp >= periodFinish + 2 hours,
            "Lock Time is not over"
        );

        IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        require(
            block.timestamp > periodFinish,
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);
    event Compounded(address indexed user, uint256 amount);
}
pragma solidity ^0.8.17;
//SPDX-License-Identifier: MIT
import "OperaStakingV2.sol";
import "IERC20.sol";
import "Auth.sol";
import "SafeMath.sol";
import "IDEXRouter.sol";
import "IDEXFactory.sol";
import "OperaRevenue.sol";

contract OperaToken is IERC20, Auth {
    using SafeMath for uint256;

    string _name;
    string _symbol;
    string _telegram;
    string _website;

    uint8 constant _decimals = 9;

    uint256 public _totalSupply;

    uint256 public _maxWalletToken;
    uint256 public _swapThreshold;

    uint256 public _operaTax;
    uint256 public _marketingBuyTax;
    uint256 public _marketingSellTax;
    uint256 public _devBuyTax;
    uint256 public _devSellTax;
    uint256 public _liquidityBuyTax;
    uint256 public _liquiditySellTax;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isFeeExempt;

    address public pair;
    address public routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    // address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public _devAddress;
    address public _marketingAddress;
    address public _operaRewardAddress;
    address public _operaAddress;
    address public WETHAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // address public WETHAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    IDEXRouter public router;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    event AutoLiquify(uint256 amountETH, uint256 amountCoin);

    constructor(
        string[] memory _stringData,
        address[] memory _addressData,
        uint256[] memory _intData,
        address rewardsAddress
    ) Auth(msg.sender) {
        require(_stringData.length == 4, "String List needs 4 string inputs");
        require(
            _addressData.length == 2,
            "Address List needs 2 address inputs"
        );
        require(_intData.length == 9, "Int List needs 9 int inputs");
        _operaRewardAddress = rewardsAddress;
        _operaAddress = msg.sender;
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        authorizations[routerAddress] = true;

        _name = _stringData[0];
        _symbol = _stringData[1];
        _telegram = _stringData[2];
        _website = _stringData[3];

        _devAddress = _addressData[0];
        _marketingAddress = _addressData[1];

        require(_intData[0] > 0 && _intData[0] < 999999999999999999);
        _totalSupply = _intData[0] * 10 ** _decimals;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        _maxWalletToken = (_totalSupply * _intData[1]) / 1000;
        _swapThreshold = (_totalSupply * _intData[2]) / 1000;
        _marketingBuyTax = _intData[3];
        _marketingSellTax = _intData[4];
        _devBuyTax = _intData[5];
        _devSellTax = _intData[6];
        _liquidityBuyTax = _intData[7];
        _liquiditySellTax = _intData[8];

        _allowances[address(this)][address(router)] = _totalSupply;

        require(
            _swapThreshold <= (_totalSupply / 20) &&
                _swapThreshold >= (_totalSupply / 500),
            "Swap Threshold must be less than 5% of total supply, or greater than 0.2%."
        );
        require(
            _maxWalletToken >= (_totalSupply / 500),
            "Max Wallet must be greater than 0.2%."
        );
        require(getSellTax() <= 480, "Sell tax can't be greater than 48%.");
        require(getBuyTax() <= 480, "Buy tax can't be greater than 48%.");
        if (getTotalTax() > 192) {
            _operaTax = 20;
        } else {
            _operaTax = 4;
        }
        require(
            _devAddress != address(0) && _marketingAddress != address(0),
            "Reciever wallets can't be Zero address."
        );
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (owner == msg.sender) {
            return _basicTransfer(msg.sender, recipient, amount);
        } else {
            return _transferFrom(msg.sender, recipient, amount);
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (
            authorizations[sender] ||
            authorizations[recipient] ||
            recipient == _operaAddress
        ) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        checkLimits(sender, recipient, amount);
        if (shouldTokenSwap(recipient)) {
            tokenSwap();
        }

        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        uint256 amountReceived = (recipient == pair || sender == pair)
            ? takeFee(sender, recipient, amount)
            : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        if (isFeeExempt[sender] || isFeeExempt[recipient]) {
            return amount;
        }
        uint256 _totalFee;

        _totalFee = (recipient == pair) ? getSellTax() : getBuyTax();

        uint256 feeAmount = amount.mul(_totalFee).div(1000);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function getBuyTax() public view returns (uint) {
        return _liquidityBuyTax + _devBuyTax + _marketingBuyTax + _operaTax;
    }

    function getSellTax() public view returns (uint) {
        return _liquiditySellTax + _devSellTax + _marketingSellTax + _operaTax;
    }

    function getTotalTax() public view returns (uint) {
        return getSellTax() + getBuyTax();
    }

    function setTaxes(
        uint256 _marketingBuyPercent,
        uint256 _marketingSellPercent,
        uint256 _devBuyPercent,
        uint256 _devSellPercent,
        uint256 _liquidityBuyPercent,
        uint256 _liquiditySellPercent
    ) external authorized {
        uint256 amount = _balances[address(this)];
        if (_operaTax == 20) {
            if (amount > 0) {
                tokenSwap();
            }

            _operaTax = 4;
        }
        _marketingBuyTax = _marketingBuyPercent;
        _liquidityBuyTax = _liquidityBuyPercent;
        _devBuyTax = _devBuyPercent;
        _marketingSellTax = _marketingSellPercent;
        _liquiditySellTax = _liquiditySellPercent;
        _devSellTax = _devSellPercent;
        requireLimits();
    }

    function tokenSwap() internal swapping {
        uint256 amount = _balances[address(this)];

        uint256 amountToLiquify = (_liquidityBuyTax + _liquiditySellTax > 0)
            ? amount
                .mul(_liquidityBuyTax + _liquiditySellTax)
                .div(getTotalTax())
                .div(2)
            : 0;

        uint256 amountToSwap = amount.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETHAddress;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        bool tmpSuccess;

        uint256 amountETH = address(this).balance.sub(balanceBefore);
        uint256 totalETHFee = (_liquidityBuyTax + _liquiditySellTax > 0)
            ? getTotalTax().sub((_liquidityBuyTax + _liquiditySellTax).div(2))
            : getTotalTax();

        uint256 amountETHLiquidity = amountETH
            .mul(_liquidityBuyTax + _liquiditySellTax)
            .div(totalETHFee)
            .div(2);
        if (_devBuyTax + _devSellTax > 0) {
            uint256 amountETHDev = amountETH.mul(_devBuyTax + _devSellTax).div(
                totalETHFee
            );
            (tmpSuccess, ) = payable(_devAddress).call{
                value: amountETHDev,
                gas: 100000
            }("");
            tmpSuccess = false;
        }

        if (_marketingBuyTax + _marketingSellTax > 0) {
            uint256 amountETHMarketing = amountETH
                .mul(_marketingBuyTax + _marketingSellTax)
                .div(totalETHFee);
            (tmpSuccess, ) = payable(_marketingAddress).call{
                value: amountETHMarketing,
                gas: 100000
            }("");
            tmpSuccess = false;
        }

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                _operaAddress,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }
        uint256 operaFee = amountETH.mul(_operaTax.mul(2)).div(totalETHFee);

        OperaRevenue rewardContract = OperaRevenue(
            payable(_operaRewardAddress)
        );
        rewardContract.recieveRewards{value: operaFee}();
    }

    function shouldTokenSwap(address recipient) internal view returns (bool) {
        return ((recipient == pair) &&
            !inSwap &&
            _balances[address(this)] >= _swapThreshold);
    }

    function checkLimits(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        if (
            !authorizations[sender] &&
            recipient != address(this) &&
            sender != address(this) &&
            recipient != address(DEAD) &&
            recipient != pair &&
            recipient != _marketingAddress &&
            recipient != _devAddress &&
            recipient != _operaAddress
        ) {
            uint256 heldTokens = balanceOf(recipient);
            require(
                (heldTokens + amount) <= _maxWalletToken,
                "Total Holding is currently limited, you can not buy that much."
            );
        }
    }

    function setMaxWallet(uint256 percent) external authorized {
        _maxWalletToken = (_totalSupply * percent) / 1000;
        requireLimits();
    }

    function setTokenSwapSettings(uint256 percent) external authorized {
        _swapThreshold = (_totalSupply * percent) / 1000;
        requireLimits();
    }

    function requireLimits() internal view {
        require(
            _swapThreshold <= (_totalSupply / 20) &&
                _swapThreshold >= (_totalSupply / 500),
            "Swap Threshold must be less than 5% of total supply, or greater than 0.2%."
        );
        require(
            _maxWalletToken >= (_totalSupply / 500),
            "Max Wallet must be greater than 0.2%."
        );
        require(getSellTax() <= 100, "Sell tax can't be greater than 10%.");
        require(getBuyTax() <= 100, "Buy tax can't be greater than 10%.");
        require(
            _devAddress != address(0) && _marketingAddress != address(0),
            "Reciever wallets can't be Zero address."
        );
    }

    function getAddress() external view returns (address) {
        return address(this);
    }

    function aboutMe() external view returns (string memory, string memory) {
        return (_telegram, _website);
    }

    function updateAboutMe(
        string memory telegram,
        string memory website
    ) external authorized {
        _telegram = telegram;
        _website = website;
    }

    function factoryAuthorizeOverride(address addy) external {
        require(msg.sender == _operaAddress, "Only the factory can call this.");
        authorizations[addy] = true;
    }

    function setAddresses(
        address marketingAddress,
        address devAddress
    ) external authorized {
        _marketingAddress = marketingAddress;
        _devAddress = devAddress;
        requireLimits();
    }

    function setFeeExemption(address user, bool status) external authorized {
        isFeeExempt[user] = status;
    }

    function clearStuckBalance() external {
        if (!inSwap) {
            require(
                msg.sender == _operaAddress,
                "Only Factory Contract can clear balance."
            );
            payable(_operaAddress).transfer(address(this).balance);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}