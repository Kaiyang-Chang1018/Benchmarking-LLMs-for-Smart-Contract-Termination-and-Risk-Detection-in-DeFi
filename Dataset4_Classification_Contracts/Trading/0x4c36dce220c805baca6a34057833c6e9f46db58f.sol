/**

// https://kick.fun

// SPDX-License-Identifier: UNLICENSE

*/

pragma solidity 0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

// Interface
interface KickTokensContract {
    function openTrading() external;
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
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
}

contract Kick is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    address payable public _taxWallet;

    uint256 private _swapBuyTax = 5;
    uint256 private _swapSellTax = 5;

    string private constant _name = unicode"Kick Factory";
    string private constant _symbol = unicode"KICK";

    struct Pair {
        address token0;
        address token1;
        address pairAddress;
        string name;
        string symbol;
        uint256 reserve0;
        uint256 reserve1;
        bool isLaunched;
    }

    Pair[] public pairs;

    // Modifier to restrict function calls to only the tax wallet
    modifier onlyTaxWallet() {
        require(msg.sender == _taxWallet, "Kick: Caller is not the tax wallet");
        _;
    }

    constructor() {
        _taxWallet = payable(_msgSender());
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
    }

    // returns the pair at that index in the pairs array.
    function getPair(uint256 indexID) public view returns (Pair memory) {
        require(indexID < pairs.length, "Invalid indexID");
        return pairs[indexID];
    }

    function _syncTokens0Reservser(address pairAddress) private {
        require(
            pairAddress != address(0),
            "Kick: Recipient address is the zero address"
        );

        uint256 index = getPairIndex(pairAddress);
        Pair storage pair = pairs[index];

        uint256 tokenBalance = IERC20(pair.token0).balanceOf(address(this));
        pairs[index].reserve0 = tokenBalance;
    }

    // Function to get pair index from the address, error if not found
    function getPairIndex(address pairAddress)
        internal
        view
        returns (uint256 index)
    {
        for (uint256 i = 0; i < pairs.length; i++) {
            if (pairs[i].pairAddress == pairAddress) {
                return i;
            }
        }
        revert("Pair not found");
    }

    // Token price
    function getTokenPrice(address pairAddress)
        public
        view
        returns (uint256 price)
    {
        uint256 index = getPairIndex(pairAddress);
        Pair storage pair = pairs[index];
        uint256 tokenBalance = IERC20(pair.token0).balanceOf(address(this));
        return pair.reserve1.mul(1e18).div(tokenBalance);
    }

    // returns the pair at that index in the pairs array.
    function getTokenInfoByPairAddress(address pairAddress)
        public
        view
        returns (
            address,
            address,
            address,
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        )
    {
        for (uint256 i = 0; i < pairs.length; i++) {
            if (pairs[i].pairAddress == pairAddress) {
                return (
                    pairs[i].token0,
                    pairs[i].token1,
                    pairs[i].pairAddress,
                    pairs[i].name,
                    pairs[i].symbol,
                    pairs[i].reserve0,
                    pairs[i].reserve1,
                    pairs[i].isLaunched
                );
            }
        }
        revert("Pair not found");
    }

    function prepareAndLaunchToken(
        address tokenContractAddress,
        address pairAddress
    ) external onlyOwner {
        (, uint256 reserve1) = getReserves(pairAddress);

        if (reserve1 < 2 ether) {
            revert("Not enough ETH reserves.");
        }

        // Calculate ETH amount to transfer
        uint256 ethAmount = reserve1 - 1 ether;
        if (ethAmount > address(this).balance) {
            revert("Not enough ETH balance");
        }

        // Send ETH to the token contract
        (bool sent, ) = tokenContractAddress.call{value: ethAmount}("");
        require(sent, "Failed to send ETH");

        // Check the contract's token balance for the token in the pair
        uint256 tokenBalance = IERC20(tokenContractAddress).balanceOf(
            address(this)
        );

        // Transfer all token (reserve0) to the token contract
        bool tokensSent = IERC20(tokenContractAddress).transfer(
            tokenContractAddress,
            tokenBalance
        );
        require(tokensSent, "Failed to send tokens");

        // Finally, trigger openTrading
        KickTokensContract(tokenContractAddress).openTrading();
    }

    // Get how many tokens you can buy with your ETH after a 5% cut
    function getBuyQuote(address pairAddress, uint256 ethAmount)
        public
        view
        returns (uint256 tokenAmount)
    {
        uint256 index = getPairIndex(pairAddress);
        Pair storage pair = pairs[index];
        require(pair.isLaunched == false, "Kick: Token is launched.");
        uint256 tokenBalance = IERC20(pair.token0).balanceOf(address(this));
        uint256 originalTokenAmount = ethAmount.mul(tokenBalance).div(
            pair.reserve1
        );
        // Apply a 5% tax
        uint256 finalTokenAmount = originalTokenAmount.mul(95).div(100);
        return finalTokenAmount;
    }

    // Get how much ETH you can get for your tokens after a 5% cut
    function getSellQuote(address pairAddress, uint256 tokenAmount)
        public
        view
        returns (uint256 ethAmount)
    {
        uint256 index = getPairIndex(pairAddress);
        Pair storage pair = pairs[index];
        require(pair.isLaunched == false, "Kick: Token is launched.");
        uint256 tokenBalance = IERC20(pair.token0).balanceOf(address(this));
        uint256 originalEthAmount = tokenAmount.mul(pair.reserve1).div(
            tokenBalance
        );
        // Apply a 5% tax
        uint256 finalEthAmount = originalEthAmount.mul(95).div(100);
        return finalEthAmount;
    }

    // Returns the number of token pairs in 'pairs' array.
    function allPairsLength() public view returns (uint256) {
        return pairs.length;
    }

    // Given a pairAddress, returns the pair's reserves if exists.
    function getReserves(address pairAddress)
        public
        view
        returns (uint256, uint256)
    {
        for (uint256 i = 0; i < pairs.length; i++) {
            if (pairs[i].pairAddress == pairAddress) {
                uint256 tokenBalance = IERC20(pairs[i].token0).balanceOf(
                    address(this)
                );
                return (tokenBalance, pairs[i].reserve1);
            }
        }
        revert("Pair not found");
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "Kick: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "Kick: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "Kick: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "Kick: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn.mul(1000); //997
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "Kick: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "Kick: INSUFFICIENT_LIQUIDITY"
        );
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(1000); //997
        amountIn = (numerator / denominator).add(1);
    }

    // Function to calculate the output amount given an input amount for a specified pair
    function getAmountOutSinglePair(address pairAddress, uint256 amountIn)
        public
        view
        returns (uint256 amountOut)
    {
        (uint256 reserveIn, uint256 reserveOut) = getReserves(pairAddress);
        require(amountIn > 0, "Kick: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "Kick: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getPairFromToken0Token1(address token0, address token1)
        public
        view
        returns (
            address,
            address,
            address,
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        )
    {
        for (uint256 i = 0; i < pairs.length; i++) {
            if (
                (pairs[i].token0 == token0 && pairs[i].token1 == token1) ||
                (pairs[i].token0 == token1 && pairs[i].token1 == token0)
            ) {
                return (
                    pairs[i].token0,
                    pairs[i].token1,
                    pairs[i].pairAddress,
                    pairs[i].name,
                    pairs[i].symbol,
                    pairs[i].reserve0,
                    pairs[i].reserve1,
                    pairs[i].isLaunched
                );
            }
        }
        // If no pair found, revert transaction to save gas for the caller
        revert("Pair not found.");
    }

    // Function to calculate the input amount required to get a specified output amount for a pair
    function getAmountInSinglePair(address pairAddress, uint256 amountOut)
        public
        view
        returns (uint256 amountIn)
    {
        (uint256 reserveIn, uint256 reserveOut) = getReserves(pairAddress);
        require(amountOut > 0, "Kick: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "Kick: INSUFFICIENT_LIQUIDITY"
        );
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // Function to calculate output amount with fee applied
    function getAmountOutWithFee(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 feePercent
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "Kick: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "Kick: INSUFFICIENT_LIQUIDITY"
        );
        uint256 feeAmount = amountIn.mul(feePercent).div(100);
        uint256 amountInAfterFee = amountIn.sub(feeAmount);
        uint256 amountInWithFee = amountInAfterFee.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // Function to add liquidity to a token pair, callable only by the owner.
    function addTokenPairLiquidity(
        address token0,
        address token1,
        address pairAddress,
        string memory tname,
        string memory tsymbol,
        uint256 reserve0,
        uint256 reserve1
    ) public onlyOwner {
        // Check if the pair with the given address already exists
        for (uint256 i = 0; i < pairs.length; i++) {
            require(
                pairs[i].pairAddress != pairAddress,
                "Error: A pair with the given address already exists."
            );
        }
        // Add the new pair since it doesn't exist
        Pair memory newPair = Pair({
            token0: token0,
            token1: token1,
            pairAddress: pairAddress,
            name: tname,
            symbol: tsymbol,
            reserve0: reserve0,
            reserve1: reserve1,
            isLaunched: false
        });
        pairs.push(newPair);

        _syncTokens0Reservser(pairAddress);
    }

    // Function to change the launch status of a pair, callable only by the owner
    function changePairStatus(address pairAddress, bool status)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < pairs.length; i++) {
            if (pairs[i].pairAddress == pairAddress) {
                pairs[i].isLaunched = status;
                return;
            }
        }
        revert("Pair not found");
    }

    // Function to set reserves for a specific token pair, callable only by the owner.
    function setReserves(
        address pairAddress,
        uint256 newReserve0,
        uint256 newReserve1
    ) public onlyOwner {
        bool pairFound = false;
        for (uint256 i = 0; i < pairs.length; i++) {
            if (pairs[i].pairAddress == pairAddress) {
                pairs[i].reserve0 = newReserve0;
                pairs[i].reserve1 = newReserve1;
                pairFound = true;
                break;
            }
        }
        require(pairFound, "Pair not found");
    }

    // Function to add reserves to an existing token pair, callable only by the owner.
    function addReserves(
        address pairAddress,
        uint256 addReserve0,
        uint256 addReserve1
    ) public onlyOwner {
        bool pairFound = false;
        for (uint256 i = 0; i < pairs.length; i++) {
            if (pairs[i].pairAddress == pairAddress) {
                pairs[i].reserve0 = pairs[i].reserve0.add(addReserve0);
                pairs[i].reserve1 = pairs[i].reserve1.add(addReserve1);
                pairFound = true;
                break;
            }
        }
        require(pairFound, "Pair not found");
    }

    function removePairByAddress(address pairAddress) external onlyOwner {
        uint256 index = getPairIndex(pairAddress);

        require(index < pairs.length, "Kick: PAIR_NOT_FOUND");

        // Swap the element to be removed with the last in the array
        if (index < pairs.length - 1) {
            // Check if it's not already the last element
            pairs[index] = pairs[pairs.length - 1];
        }

        // Remove the last element
        pairs.pop();
    }

    event SwapETHForTokens(
        address indexed from,
        address indexed to,
        uint256 amountInETH,
        uint256 amountOutTokens
    );

    event SwapTokensForETH(
        address indexed from,
        address indexed to,
        uint256 amountInTokens,
        uint256 amountOutETH
    );

    function buyToken(address pairAddress)
        external
        payable
        returns (uint256 amountOutTokens)
    {
        require(msg.value > 0, "Kick: INSUFFICIENT_ETH");

        uint256 pairIndex = getPairIndex(pairAddress);
        Pair storage pair = pairs[pairIndex];
        require(pair.isLaunched == false, "Kick: Pair not on cruve.");

        uint256 feeAmount = msg.value.mul(_swapBuyTax).div(100);
        uint256 amountInWithFee = msg.value.sub(feeAmount);

        (uint256 reserve0, uint256 reserve1) = getReserves(pairAddress);

        amountOutTokens = getAmountOut(amountInWithFee, reserve1, reserve0);

        sendETHToFee(feeAmount);

        pairs[pairIndex].reserve0 = reserve0.sub(amountOutTokens);
        pairs[pairIndex].reserve1 = reserve1.add(amountInWithFee);

        IERC20(pairs[pairIndex].token0).transfer(msg.sender, amountOutTokens);

        _syncTokens0Reservser(pairAddress);

        emit SwapETHForTokens(
            msg.sender,
            msg.sender,
            msg.value,
            amountOutTokens
        );
    }

    function sellTokens(address pairAddress, uint256 amountInTokens)
        external
        returns (uint256 amountOutETH)
    {
        require(amountInTokens > 0, "Kick: INSUFFICIENT_TOKEN_AMOUNT");

        uint256 pairIndex = getPairIndex(pairAddress);
        Pair storage pair = pairs[pairIndex];
        require(pair.isLaunched == false, "Kick: Pair not on cruve.");

        (uint256 reserve0, uint256 reserve1) = getReserves(pairAddress);

        amountOutETH = getAmountOut(amountInTokens, reserve0, reserve1);

        uint256 feeAmount = amountOutETH.mul(_swapSellTax).div(100);
        uint256 amountOutETHWithFee = amountOutETH.sub(feeAmount);

        // Transfer the tokens from the sender to this contract with the original amount
        require(
            IERC20(pairs[pairIndex].token0).transferFrom(
                msg.sender,
                address(this),
                amountInTokens
            ),
            "Kick: TRANSFER_FROM_FAILED"
        );

        sendETHToFee(feeAmount);

        // Update reserves
        pairs[pairIndex].reserve0 = reserve0.add(amountInTokens);
        pairs[pairIndex].reserve1 = reserve1.sub(amountOutETHWithFee);

        // Send ETH to the sender
        (bool sent, ) = payable(msg.sender).call{value: amountOutETHWithFee}(
            ""
        );
        require(sent, "Kick: ETH_TRANSFER_FAILED");

        _syncTokens0Reservser(pairAddress);

        emit SwapTokensForETH(
            msg.sender,
            msg.sender,
            amountInTokens,
            amountOutETH
        );

        return amountOutETHWithFee;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 contractTokenBalance = balanceOf(address(this));
        require(
            contractTokenBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    // Function to allow the owner to change the _taxWallet address
    function setTaxWallet(address payable newTaxWallet) public onlyOwner {
        require(
            newTaxWallet != address(0),
            "Kick: The tax wallet cannot be the zero address"
        );
        _taxWallet = newTaxWallet;
    }

    receive() external payable {}

    function rescueToken(address tokenAddress, address recipient)
        external
        onlyTaxWallet
    {
        require(
            recipient != address(0),
            "Kick: Recipient address is the zero address"
        );
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
        require(tokenBalance > 0, "Kick: No tokens to transfer");

        bool success = IERC20(tokenAddress).transfer(recipient, tokenBalance);
        require(success, "Kick: Token rescue failed");
    }

    function rescueETH() external {
        require(_msgSender() == _taxWallet);
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }
}