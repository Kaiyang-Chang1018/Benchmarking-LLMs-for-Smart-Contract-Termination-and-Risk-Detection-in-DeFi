//SPDX-License-Identifier: Unlicensed
pragma solidity >=0.7.0 <0.9.0;

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }


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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

contract RewardToken is Context, IERC20 {
    using SafeERC20 for IERC20;
    struct Share {
        uint256 amount;
        uint256 realised;
        uint256 excluded;
    }
    struct Fee {
        uint16 rewardFee;
        uint16 marketingFee;
    }
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) public _balances;
    mapping(address => bool) liquidityPair;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isDividendExempt;
    mapping(address => bool) isMaxWalletExempt;
    mapping(address => uint256) shareholderClaims;
    mapping(address => Share) public shares;

    uint256 totalShares;
    uint256 totalDividends;
    uint256 totalDistributed;
    uint256 dividendsPerShare;
    uint256 dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 _totalSupply;
    uint256 public maxWallet;
    uint256 public maxTransaction;
    uint256 feeAmount;
    uint256 rewardFees;
    uint256 tokensToSwap;

    uint16 public buyFee = 200;
    uint16[2] buyFees = [5,195];
    uint16 public sellFee = 700;
    uint16[2] sellFees = [5,695];
    uint16 public transferFee;
    uint16[2] transferFees;
    uint16 currentFee;
    uint16 feeDenominator = 1000;

    bool inSwap;
    bool swapEnabled;
    bool feesEnabled;
    bool rewardsEnabled;
    bool tradingOpen;
    bool limitInPlace;
    IERC20 pepe = IERC20(0x6982508145454Ce325dDbE47a25d4ec3d2311933);
    address deployer;
    address public ownerWallet;

    string private _name;
    string private _symbol;

    IRouter router;

    modifier onlyOwner() {
        require(_msgSender() == ownerWallet, "You are not the owner");
        _;
    }

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(string memory name_, string memory symbol_, uint256 supply) {
        _name = name_;
        _symbol = symbol_;
        _mint(_msgSender(), supply * (10 ** 18));
        router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address pair = IFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        liquidityPair[pair] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0xdead)] = true;

        isMaxWalletExempt[_msgSender()] = true;
        isMaxWalletExempt[address(this)] = true;
        isMaxWalletExempt[pair] = true;

        isFeeExempt[address(this)] = true;
        isFeeExempt[_msgSender()] = true;

        maxWallet = _totalSupply / 50;
        maxTransaction = _totalSupply / 100;

        _approve(address(this), address(router), type(uint256).max);
        _approve(_msgSender(), address(router), type(uint256).max);

        deployer = _msgSender();
        ownerWallet = _msgSender();
    }

    receive() external payable {}

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function renounceOwnership() external onlyOwner {
        ownerWallet = address(0);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address, use renounceOwnership Function"
        );

        if (balanceOf(ownerWallet) > 0)
            _transfer(ownerWallet, newOwner, balanceOf(ownerWallet));

        ownerWallet = newOwner;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view {
        if (limitInPlace) {
            if (!isMaxWalletExempt[to]) {
                require(
                    amount <= maxTransaction &&
                        balanceOf(to) + amount <= maxWallet,
                    "TOKEN: Amount exceeds Transaction size"
                );
            } else if (liquidityPair[to] && !isMaxWalletExempt[from]) {
                require(
                    amount <= maxTransaction,
                    "TOKEN: Amount exceeds Transaction size"
                );
            }
        }
    }

    function takeFee(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256 _amount) {
        if (isFeeExempt[to]) {
            return amount;
        }
        if (liquidityPair[to]) {
            currentFee = sellFee;
        } else if (liquidityPair[from]) {
            currentFee = buyFee;
        } else {
            currentFee = transferFee;
        }
        if (currentFee == 0) {
            return amount;
        }

        feeAmount = (amount * currentFee) / feeDenominator;
        uint256 fromBalance = _balances[from];
        unchecked {
            _balances[from] = fromBalance - feeAmount;
            _balances[address(this)] += feeAmount;
        }
        emit Transfer(from, address(this), feeAmount);
        if (rewardsEnabled) {
            rewardFees +=
                (feeAmount * (sellFees[0] + buyFees[0])) /
                (buyFee + sellFee);
        }
        return amount - feeAmount;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed += amount;
            pepe.safeTransfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].realised += amount;
            shares[shareholder].excluded = getCumulativeDividends(
                shares[shareholder].amount
            );

        }
    }

    function setShare(address shareholder, uint256 amount) internal {
        distributeDividend(shareholder);

        totalShares = (totalShares - shares[shareholder].amount) + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].excluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function getUnpaidEarnings(
        address shareholder
    ) public view returns (uint256) {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].excluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function getCumulativeDividends(
        uint256 share
    ) internal view returns (uint256) {
        return (share * dividendsPerShare) / dividendsPerShareAccuracyFactor;
    }

    function shouldSwap(address from) internal view returns (bool) {
        return
            !liquidityPair[from] &&
            swapEnabled &&
            !inSwap &&
            balanceOf(address(this)) >= tokensToSwap;
    }

    function swapBack() internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swap() internal swapping {
        if (rewardFees >= tokensToSwap) {
            uint256 balanceBefore = IERC20(pepe).balanceOf(address(this));
            swapBack();
            uint256 balance = address(this).balance;
            address[] memory path = new address[](2);
            path[0] = router.WETH();
            path[1] = address(pepe);
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: balance}(
                0,
                path,
                address(this),
                block.timestamp
            );
            uint256 amount = IERC20(pepe).balanceOf(address(this)) - balanceBefore;
            totalDividends += amount;
            dividendsPerShare = dividendsPerShare + ((dividendsPerShareAccuracyFactor * amount) / totalShares);            
        } else {
            swapBack();
            uint256 balance = address(this).balance;
            payable(deployer).transfer(balance);
        }
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(
            _balances[from] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        if (!tradingOpen) {
            require(from == deployer, "Trading is not open");
        }
        _beforeTokenTransfer(from, to, amount);
        if (shouldSwap(from)) {
            swap();
        }

        uint256 amountSent = tradingOpen && feesEnabled && !isFeeExempt[from]
            ? takeFee(from, to, amount)
            : amount;
        uint256 fromBalance = _balances[from];
        unchecked {
            _balances[from] = fromBalance - amountSent;
            _balances[to] += amountSent;
        }
        emit Transfer(from, to, amountSent);

        if(!isDividendExempt[from]){
            setShare(from, _balances[from]);
        }        
        
        if(!isDividendExempt[to]){
            setShare(to, _balances[to]);
        }
    }

    function setLimits(
        bool inPlace,
        uint256 _maxTransaction,
        uint256 _maxWallet
    ) external onlyOwner {
        require(
            _maxTransaction >= 1 && _maxWallet > 1,
            "Max Transaction and Max Wallet must be over 1%"
        );
        maxTransaction = (_totalSupply * _maxTransaction) / 100;
        maxWallet = (_totalSupply * _maxWallet) / 100;
        limitInPlace = inPlace;
    }

    function setMaxWalletExempt(
        address wallet,
        bool exempt
    ) external onlyOwner {
        isMaxWalletExempt[wallet] = exempt;
    }

    function setFees(
        uint16[2] memory _buyFee,
        uint16[2] memory _sellFee,
        uint16[2] memory _transferFee,
        bool _feesEnabled
    ) external onlyOwner {
        require(_buyFee[0] + _buyFee[1] + _sellFee[0] + _sellFee[1] <= 400);
        sellFees = _sellFee;
        buyFees = _buyFee;
        transferFees = _transferFee;
        buyFee = _buyFee[0] + _buyFee[1];
        sellFee = _sellFee[0] + _sellFee[1];
        transferFee = _transferFee[0] + _transferFee[1];
        feesEnabled = _feesEnabled;
    }

    function setFeeExempt(address wallet, bool exempt) external onlyOwner {
        isFeeExempt[wallet] = exempt;
    }

    function setSwapSettings(
        bool _swapEnabled,
        bool _rewardsEnabled,
        uint256 numerator
    ) external onlyOwner {
        require(numerator <= 10000);
        swapEnabled = _swapEnabled;
        rewardsEnabled = _rewardsEnabled;
        tokensToSwap = (_totalSupply * numerator) / 10000;
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function claimDividendFor(address shareholder) external {
        distributeDividend(shareholder);
    }

    function setPair(address pairs, bool isPair) external onlyOwner {
        liquidityPair[pairs] = isPair;
    }

    function enableTrade() external onlyOwner {
        require(!tradingOpen);
        tradingOpen = true;
        limitInPlace = true;
        feesEnabled = true;
        swapEnabled = true;
        rewardsEnabled = true;
        tokensToSwap = (_totalSupply * 10) / (10000);
    }

    function getShareholderInfo(
        address shareholder
    ) external view returns (uint256, uint256, uint256, uint256) {
        return (
            totalShares,
            totalDistributed,
            shares[shareholder].amount,
            shares[shareholder].realised
        );
    }

    function setPepe(address _pepe) external onlyOwner {
        pepe = IERC20(_pepe);
    }

    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }
}