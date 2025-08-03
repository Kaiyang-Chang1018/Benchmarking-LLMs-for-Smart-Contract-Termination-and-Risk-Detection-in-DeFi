// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

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

contract VOIP_Presale {
    using SafeMath for uint256;
    IERC20 public token;
    uint256 public tokensPerUSDT;
    uint256 public tokensPerETH;
    address public preSaleOwner;
    uint256 public totalFundsRaised;
    uint256 public currentRound;
    uint256[] public roundTokenPrices;
    uint256[] public roundTokenPricesEth;
    uint256[] public roundLimits;

    // Events
    event FundsRaised(uint256 amount);

    IERC20 USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    constructor(address _tokenAddress, address _owner) {
        token = IERC20(_tokenAddress);
        preSaleOwner = _owner;
        roundTokenPrices = [100, 50, 33, 25, 20, 16, 14, 12, 9, 8];
        roundTokenPricesEth = [
            358565,
            179282,
            118326,
            89641,
            71713,
            57370,
            50199,
            43028,
            32270,
            28685
        ];
        roundLimits = [
            100000 * (10**6),
            300000 * (10**6),
            600000 * (10**6),
            1400000 * (10**6),
            2400000 * (10**6),
            3600000 * (10**6),
            5700000 * (10**6),
            8250000 * (10**6),
            13750000 * (10**6),
            20000000 * (10**6)
        ];
        currentRound = 0;
        totalFundsRaised = 0;
        tokensPerUSDT = roundTokenPrices[currentRound];
        tokensPerETH = roundTokenPricesEth[currentRound];
    }

    modifier onlyOwner() {
        require(
            msg.sender == preSaleOwner,
            "ONLY_OWNER_CAN_ACCESS_THIS_FUNCTION"
        );
        _;
    }

    function endPreSale() public onlyOwner {
        uint256 contractTokenBalance = token.balanceOf(address(this));
        token.transfer(msg.sender, contractTokenBalance);
    }

    function buyWithUsdt(uint256 _USDTAmount) public {
        require(currentRound < roundLimits.length, "Presale has ended");
        require(
            totalFundsRaised.add(_USDTAmount) <= roundLimits[currentRound],
            "Presale round limit reached"
        );

        uint256 tAmount = _USDTAmount.mul(tokensPerUSDT);

        uint256 tokenAmount = tAmount.mul(10**12);

        USDT.transferFrom(msg.sender, preSaleOwner, _USDTAmount);

        require(
            token.balanceOf(address(this)) >= tokenAmount,
            "INSUFFICIENT_BALANCE_IN_CONTRACT"
        );

        bool sent = token.transfer(msg.sender, tokenAmount);
        require(sent, "FAILED_TO_TRANSFER_TOKENS_TO_BUYER");

        // Update total funds raised
        totalFundsRaised = totalFundsRaised.add(_USDTAmount);

        emit FundsRaised(_USDTAmount); // Emit event

        if (totalFundsRaised >= roundLimits[currentRound]) {
            currentRound++;
            if (currentRound < roundLimits.length) {
                tokensPerUSDT = roundTokenPrices[currentRound];
                tokensPerETH = roundTokenPricesEth[currentRound];
            }
        }
    }

    function buyWithEth() public payable {
        require(currentRound < roundLimits.length, "Presale has ended");

        uint256 ethAmountToBuy = msg.value;
        uint256 tokenAmount = ethAmountToBuy.mul(tokensPerETH);

        require(
            token.balanceOf(address(this)) >= tokenAmount,
            "INSUFFICIENT_BALANCE_IN_CONTRACT"
        );

        // Calculate the equivalent USDT value of the purchased tokens
        uint256 usdtVal = tokenAmount.div(tokensPerUSDT);
        uint256 usdtValue = usdtVal.div(10**12); // Keep only six decimal places

        payable(preSaleOwner).transfer(msg.value);

        // Update total funds raised with only six decimal places
        totalFundsRaised = totalFundsRaised.add(usdtValue);

        // Emit event
        emit FundsRaised(usdtValue);

        // Transfer tokens to the buyer
        bool sent = token.transfer(msg.sender, tokenAmount);
        require(sent, "FAILED_TO_TRANSFER_TOKENS_TO_BUYER");

        // Check if the current round limit is reached
        if (totalFundsRaised >= roundLimits[currentRound]) {
            currentRound++;
            if (currentRound < roundLimits.length) {
                tokensPerUSDT = roundTokenPrices[currentRound];
                tokensPerETH = roundTokenPricesEth[currentRound];
            }
        }
    }

    function recoverTokens(address tokenToRecover) public onlyOwner {
        IERC20 tokenContract = IERC20(tokenToRecover);
        uint256 contractTokenBalance = tokenContract.balanceOf(address(this));
        require(contractTokenBalance > 0, "No tokens to recover");

        bool sent = tokenContract.transfer(msg.sender, contractTokenBalance);
        require(sent, "Failed to recover tokens");
    }

    function newPresaleOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        preSaleOwner = newOwner;
    }
}