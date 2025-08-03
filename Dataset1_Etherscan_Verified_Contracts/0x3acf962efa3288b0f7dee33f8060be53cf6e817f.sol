// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract CCXInvest  {
    address public owner;
    address public ccxToken;
    address public signController;

    mapping(uint256 => bool) public isValidSign;


    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 nonce;
        uint256 time;
    }

    event Withdraw(
        uint256 indexed uniqueId,
        uint256 indexed userId,
        address indexed user,
        uint256 ccxAmount
    );

    event InvestDetails(
        uint256 indexed userId,
        address indexed user,
        uint256 ccxAmount,
        uint8 planId
    );

    event TokensWithdrawn(address token, uint256 amount);
    event SignControllerUpdated(
        address indexed oldController,
        address indexed newController
    );
    event NativeRecovered(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(
        address _owner,
        address _ccxToken,
        address _signController
    ) {
        owner = _owner;
        ccxToken = _ccxToken;
        signController = _signController;
    }


    /**
     * @dev Swaps USDT to CCX
     * @param userId The user id of user
     * @param ccxAmount The amount of CCX to swap
     */
    function Invest(uint256 userId, uint256 ccxAmount,uint8 _planId) external {
        require(ccxAmount > 0, "Amount must be greater than zero");

        IERC20 usdt = IERC20(ccxToken);

        // Transfer USDT from user to this contract
        require(
            usdt.transferFrom(msg.sender, address(this), ccxAmount),
            "CCX transfer failed"
        );

        emit InvestDetails(userId, msg.sender, ccxAmount,_planId);
    }

    /**
     * @dev Allows users to withdraw their CCX tokens with signature verification
     * @param uniqueId A unique identifier for this withdrawal transaction
     * @param userId The user ID associated with this withdrawal
     * @param ccxAmount The amount of CCX to withdraw
     * @param sign The signature data for verification
     */
    function withdraw(
        uint256 uniqueId,
        uint256 userId,
        uint256 ccxAmount,
        Sign memory sign
    ) external {
        require(ccxAmount > 0, "Amount must be greater than zero");

        // Verify the signature
        verifySign(uniqueId, userId, msg.sender, ccxAmount, sign);

        // Transfer CCX tokens to the user
        IERC20 ccx = IERC20(ccxToken);
        uint256 contractBalance = ccx.balanceOf(address(this));
        require(contractBalance >= ccxAmount, "Insufficient contract balance");

        require(ccx.transfer(msg.sender, ccxAmount), "CCX transfer failed");

        emit Withdraw(uniqueId, userId, msg.sender, ccxAmount);
    }

    /**
     * @dev Allows the owner to withdraw tokens from the contract
     * @param token The address of the token to withdraw
     * @param amount The amount of tokens to withdraw
     */
    function withdrawTokens(address token, uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");

        IERC20 tokenContract = IERC20(token);
        uint256 contractBalance = tokenContract.balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient contract balance");

        require(tokenContract.transfer(owner, amount), "Token transfer failed");

        emit TokensWithdrawn(token, amount);
    }

    /**
     * @dev Verifies the signature for withdrawal requests
     * @param uniqueId A unique identifier for the transaction
     * @param userId The user ID associated with this transaction
     * @param user The address of the user requesting withdrawal
     * @param amount The amount to withdraw
     * @param sign The signature data to verify
     */
    function verifySign(
        uint256 uniqueId,
        uint256 userId,
        address user,
        uint256 amount,
        Sign memory sign
    ) internal {
        bytes32 hash = keccak256(
            abi.encodePacked(
                uniqueId,
                userId,
                user,
                amount,
                sign.nonce,
                sign.time,
                address(this)
            )
        );

        require(!isValidSign[uniqueId], "Duplicate signature");
        isValidSign[uniqueId] = true;
        require(
            signController ==
                ecrecover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            hash
                        )
                    ),
                    sign.v,
                    sign.r,
                    sign.s
                ),
            "Invalid signature"
        );
    }

    /**
     * @dev Updates the signature controller address
     * @param _signController The address of the new signature controller
     */
    function setSignController(address _signController) external onlyOwner {
        require(
            _signController != address(0),
            "Invalid sign controller address"
        );

        address oldController = signController;
        signController = _signController;
        emit SignControllerUpdated(oldController, _signController);
    }

    /**
     * @dev Allows the owner to recover native cryptocurrency (ETH) sent to the contract
     * @param amount The amount of native currency to recover
     */
    function recoverNative(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(
            amount <= address(this).balance,
            "Insufficient contract balance"
        );
        payable(owner).transfer(amount);
        emit NativeRecovered(amount);
    }

    /**
     * @dev Allows the owner to transfer ownership of the contract
     * @param newOwner The address of the new owner
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        owner = newOwner;
    }
}