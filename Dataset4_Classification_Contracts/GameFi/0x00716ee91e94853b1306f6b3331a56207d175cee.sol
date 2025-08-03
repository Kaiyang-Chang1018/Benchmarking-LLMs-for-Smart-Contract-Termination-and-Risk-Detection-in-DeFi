// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
//optimize 100
/// Standard IERC20 interface
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function owner() external view returns(address);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/// Factory interface of uniswap and forks
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/// First part of the router interface of uniswap and forks
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/// Second part of the router interface of uniswap and forks
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}

/// Interface for the pairs of uniswap and forks
interface IPair {
    function burn(address to) external returns (uint amount0, uint amount1);
    function mint(address to) external returns (uint liquidity);
    function token0() external view returns(address);
    function token1() external view returns(address);
    function sync() external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external view returns(uint);
}

interface Dataport {
    function DATA_READ() external view returns(address);
}

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
        require(address(this).balance >= value);
        (bool success, bytes memory returndata) = target.call{value: value}(data);
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

/// Transfer Helper to ensure the correct transfer of the tokens or ETH
library SafeTransfer {
    using Address for address;
    /** Safe Transfer asset from one wallet with approval of the wallet
    * @param erc20: the contract address of the erc20 token
    * @param from: the wallet to take from
    * @param amount: the amount to take from the wallet
    **/
    function _pullUnderlying(IERC20 erc20, address from, uint amount) internal
    {
        safeTransferFrom(erc20,from,address(this),amount);
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /** Safe Transfer asset to one wallet from within the contract
    * @param erc20: the contract address of the erc20 token
    * @param to: the wallet to send to
    * @param amount: the amount to send from the contract
    **/
    function _pushUnderlying(IERC20 erc20, address to, uint amount) internal
    {
        safeTransfer(erc20,to,amount);
    }

    /** Safe Transfer ETH to one wallet from within the contract
    * @param to: the wallet to send to
    * @param value: the amount to send from the contract
    **/
    function safeTransferETH(address to, uint256 value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface Logic{
    function createSD(string memory n, string memory symbol, uint supply, uint[12] memory fee, bool sb, address ownerAddr, address backingTokenAddress, bool _LGE) external returns (address);
    function afterConstructor() external;
    function sdOwner() external view returns(address);
    function backingAsset() external view returns(address);
}

/// Main contract that deploys smartdefi contract and can be used to verify the original code
contract SDDeployer {
    mapping(address => address) public creatorOfSD; // tracker for bridge
    mapping(address => address) public SDOfCreator; // enforce unique names
    mapping(string => bool) public useInfo; // enforce unique info names
    mapping(string => bool) public use; // enforce unique names
    mapping(address => uint256[]) public tick; // balance data tracking
    mapping(address => Protector) public protect; // slippage user data for front run protection
    mapping(address => mapping(string => string)) public info; // project information data
    mapping(address => string[]) private news; // project news feed
    mapping(address => string[]) public usedInfoStrings; // used data strings for project, for ui tracking
    mapping(address => mapping(address => KYC)) private kyc; // 
    mapping(address => uint256) public KYCopen;
    mapping(address => mapping(string => bool)) public usedInfoStringsBool; // bool to confirm used info string
    mapping(address => mapping(address => uint256[])) public myTickets;
    mapping(address => mapping(address => bool)) public isSupport;
    mapping(address => mapping(address => uint256[])) public myReplied;
    mapping(address => Tickets[]) private ticket;
    mapping(address => uint256) public ticketsOpened;
    mapping(address => uint256) public ticketsClosed;
    mapping(address => uint256) public minTicketCost;
    mapping(address => uint256) public heldDonation;
    mapping(address => uint256) public karma;
    mapping(address => uint256) public karmaDonation;
    mapping(address => mapping(address => uint256)) public lastKarma;
    mapping(address => address) public donationLocation;
    address[] public allSD; // A pseudo list of all SD addresses in order.
    address public logic = 0x7a8B3a2c9e2d6506045fA95180be608c95cf2a30; // SD logic address
    address public dataread;
    uint256 public length = 0; // public read for total SD created
    uint256 public minDonation = 1e15;
    string internal fill = "Awaiting"; // Standard fill for submission of support and suggestions.
    bool public on = false;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    mapping(address => bool) whitelist;
    uint256 private _status;
    uint256 private _status2;
    event Created(string name, address pair);
    event SetProtection(address user, uint256 slippage);
    event Dock(string symbol, bool _bool);
    event DockInfo(string symbol, bool _bool);
    event ConfirmKYC(address sd, address who);
    event UpdateInformation(string choice, string input);
    event AddNews(address sd, string input);
    event EditNews(address sd, uint256 id, string input);
    event SubmitKYC(address sd, address user);
    event GiveKarma(address sd, uint256 choice);
    event SubmitTicket(address sd, address user, uint256 id);
    event ReplyTicket(address sd, uint256 id);

    constructor() {        
    dataread = Dataport(0xcCeD1a96321B2B2a06E8F3F4B0B883dDD059968c).DATA_READ();
    address feg = 0xF3c7CECF8cBC3066F9a87b310cEBE198d00479aC;
    address own = 0x4b01518524845a2E32cA4B136e8d05Cc0Ef1Ca78;
    creatorOfSD[feg] = own;
    SDOfCreator[own] = feg;
    allSD.push(feg);
    length += 1;
    isSupport[feg][own] = true;
    minTicketCost[feg] = minDonation;
    ticket[feg].push();
    news[feg].push();
    donationLocation[feg] = own;
    string memory f = 'FEG';
    use[f] = true;
    _status = _NOT_ENTERED;
    }

    receive() external payable {
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED || whitelist[msg.sender], "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    function addWhitelist(address toAdd) internal {
        whitelist[toAdd] = true;
    }

    /**
     * @dev Allows for holders to make get support directly from project leaders in real time
     */
    struct Tickets {
        address sd;
        address user;
        address lastAdmin;
        string[] question;
        string[] answer;
        uint256 donation;
        uint256 time;
        bool closed;
    }

    struct KYC {
        string document;
        uint256 donation;
        uint256 time;
        bool confirmed;
    }

    function dock(string[] memory sym, bool[] memory _bool) external {
        require(Reader(dataread).isAdmin(msg.sender) || Reader(dataread).isSetter(msg.sender));
        for(uint256 i = 0; i < sym.length; i++) {
        use[sym[i]] = _bool[i];
        emit Dock(sym[i], _bool[i]);
        }
    }

    function setOn(bool _bool) external {        
        require(Reader(dataread).isAdmin(msg.sender) || Reader(dataread).superAdmin(msg.sender));
        on = _bool;
    }

    function openTickets(address sd, uint256 start, uint256 amount) external view returns(uint256[] memory ids) {
        uint256 a = amount > 0 ? amount : ticket[sd].length;
        require(start + a <= ticket[sd].length, "over");
        uint256 b = 0;
        ids = new uint256[](a);
        for(uint256 i = start; i < start + a; i++) {
            if(!ticket[sd][i].closed) {
                ids[b] = i;
                b++;
            }
        }
    }

    /**
     * @dev you can submit your suggestions with this function simply type out your suggestion and submit the transaction
     */
    function submitTicket(address sd, string memory _question) external payable {
        uint256 cost = minTicketCost[sd];
        if(cost > 0) {
        require(msg.value == cost, "min");
        }
        ticket[sd].push();
        uint256 id = ticket[sd].length - 1;
        ticket[sd][id].sd = sd;
        ticket[sd][id].question.push(_question);
        ticket[sd][id].user = msg.sender;
        if(cost > 0) {
        ticket[sd][id].donation = msg.value;
        heldDonation[sd] += msg.value;
        }
        ticket[sd][id].time = block.timestamp;
        myTickets[sd][msg.sender].push(ticket[sd].length - 1);
        ticketsOpened[sd] += 1;
        emit SubmitTicket(sd, msg.sender, id);
    }

    function recoverDonation(address sd, uint256 id) external nonReentrant() {
        require(ticket[sd][id].user == msg.sender, "user");
        require(block.timestamp > ticket[sd][id].time + 72 hours , "!expired");
        uint256 d = ticket[sd][id].donation;
        uint256 k = kyc[sd][msg.sender].donation;
        require(d + k > 0, "no donation"); 
        if(k > 0) {
        d += k;
        KYCopen[sd] -= 1;
        kyc[sd][msg.sender].donation = 0;
        }
        if(d > 0) {
        ticketsOpened[sd] -= 1;
        ticket[sd][id].donation = 0;
        }
        heldDonation[sd] = d > heldDonation[sd] ? 0 : heldDonation[sd] - d;
        SafeTransfer.safeTransferETH(msg.sender, d);
    }

    function giveKarma(address sd, uint256 choice) external payable nonReentrant() {
        require(msg.value == karmaDonation[sd], "min");
        require(block.timestamp > lastKarma[msg.sender][sd] + 1 days, "1 day");
        bool d;
        (uint256[] memory _balances, uint256[] memory blockNumbers) = Reader(sd).allLastBalance(msg.sender);
        for(uint256 i = 0; i < _balances.length; i++) {
        if(blockNumbers[i] < block.number - 5 && IERC20(sd).balanceOf(msg.sender) >= _balances[i]) {
            d = true;
            break;
        }
        }
        require(d, "!5blocks");
        karma[sd] = choice == 0 ? karma[sd] + 1 : karma[sd] > 0 ? karma[sd] - 1 : 0;
        if(karmaDonation[sd] > 0) {
        SafeTransfer.safeTransferETH(donationLocation[sd], msg.value);
        }
        lastKarma[msg.sender][sd] = block.timestamp;
        emit GiveKarma(sd, choice);
    }

    function setKarmaDonation(address sd, uint256 amt) external {
        require(Logic(sd).sdOwner() == msg.sender, "owner");
        require(amt <= 1e17, "1e17");
        karmaDonation[sd] = amt;
    }

    function setDonationLocation(address sd, address location) external {
        require(Logic(sd).sdOwner() == msg.sender, "owner");
        donationLocation[sd] = location;
    }

    function submitKYC(address sd, string memory document) external payable{
        require(!kyc[sd][msg.sender].confirmed && kyc[sd][msg.sender].time == 0, "already");
        uint256 cost = minTicketCost[sd];
        if(cost > 0) {
        require(msg.value == cost, "min");
        kyc[sd][msg.sender].donation = msg.value;
        heldDonation[sd] += cost;
        }
        kyc[sd][msg.sender].document = document;
        kyc[sd][msg.sender].time = block.timestamp;
        KYCopen[sd] += 1;
        emit SubmitKYC(sd, msg.sender);
    }

    function confirmKYC(address sd, address user) external {
        require(isSupport[sd][msg.sender], "not support");
        require(!kyc[sd][user].confirmed && kyc[sd][msg.sender].time > 0, "already");
        KYCopen[sd] -= 1;
        uint256 don = kyc[sd][user].donation;
        kyc[sd][user].confirmed = true;
        if(don > 0) {
        kyc[sd][user].donation = 0;
        SafeTransfer.safeTransferETH(msg.sender, don);        
        heldDonation[sd] = don > heldDonation[sd] ? 0 : heldDonation[sd] - don;
        }
        emit ConfirmKYC(sd, user);
    }

    function viewKYC(address sd, address user) external view returns(string memory document, bool confirmed) {
        if(isSupport[sd][msg.sender]) {
        document = kyc[sd][user].document;
        confirmed = kyc[sd][user].confirmed;
        }
        else {
        document = kyc[sd][msg.sender].document;
        confirmed = kyc[sd][msg.sender].confirmed;
        }
    }

    /**
     * @dev to view suggestion enter the user address and suggestionID(ticket#) note: only the user and isAdmin can view support tickets
     */
    function viewTicket(address sd, uint256 ticketID) external view returns(string[] memory question, string[] memory answer, address lastAdmin, uint256 donation, uint256 time) {
        require(ticket[sd][ticketID].user == msg.sender || isSupport[sd][msg.sender], "only");
        uint256 i;
        question = new string[](ticket[sd][ticketID].question.length);
        answer = new string[](ticket[sd][ticketID].answer.length);

        for(i = 0; i > ticket[sd][ticketID].question.length; i++) {
            question[i] = ticket[sd][ticketID].question[i];
        }

        for(i = 0; i > ticket[sd][ticketID].answer.length; i++) {
            answer[i] = ticket[sd][ticketID].answer[i];
        }

        lastAdmin = ticket[sd][ticketID].lastAdmin;
        donation = ticket[sd][ticketID].donation;
        time = ticket[sd][ticketID].time;
    }

    /**
     * @dev only isAdmin can use this function to reply to suggestions, enter the users address, suggestID and reply to log a reply to the suggestion.
     */
    function replyTicket(address sd, uint256 ticketID, string memory _answer) external nonReentrant() {
        address user = ticket[sd][ticketID].user;
        require(isSupport[sd][msg.sender] || user == msg.sender, "Only");
        uint256 don = ticket[sd][ticketID].donation;
        if(msg.sender != user) {
        ticket[sd][ticketID].answer.push(_answer);
        ticket[sd][ticketID].lastAdmin = msg.sender;
        myReplied[msg.sender][sd].push(ticketID);
        if(don > 0) {
        SafeTransfer.safeTransferETH(msg.sender, don);
        heldDonation[sd] = don > heldDonation[sd] ? 0 : heldDonation[sd] - don;
        ticket[sd][ticketID].donation = 0;
        }
        if(!ticket[sd][ticketID].closed) {
        ticketsClosed[sd] += 1;
        ticket[sd][ticketID].closed = true;
        }
        }

        if(msg.sender == user) {
        myReplied[user][sd].push(ticketID);
        ticket[sd][ticketID].question.push(_answer);
        if(ticket[sd][ticketID].closed) {
        ticketsClosed[sd] = ticketsClosed[sd] > 1 ? ticketsClosed[sd] - 1 : 0;
        ticket[sd][ticketID].closed = false;
        }
        }
        emit ReplyTicket(sd, ticketID);
    }

    /**
     * @dev can add or remove admins with this function, true = isAdmin, false = notAdmin. Admins cannot do anything to change the contract they can only reply to support tickets and suggestions.
     */
    function setSupport(address sd, address _supporter, bool _bool) external {
        require(msg.sender == Logic(sd).sdOwner());
        isSupport[sd][_supporter] = _bool;
    }

    function setMinDonation(address sd, uint256 amt) external {
        require(msg.sender == Logic(sd).sdOwner());
        require(amt <= 1e17, "0.1");
        minTicketCost[sd] = amt;
    }

    function mySupportIDs(address sd, address user) external view returns(uint256[] memory ids) {
        uint256 a = myTickets[sd][user].length;
        ids = new uint256[](a);
        for(uint256 i = 0; i < a; i++) {
            ids[i] = myTickets[sd][user][i];
        }
    }

    function supportReplyIDs(address sd, address user) external view returns(uint256[] memory ids) {
        uint256 a = myReplied[user][sd].length;
        ids = new uint256[](a);
        for(uint256 i = 0; i < a; i++) {
            ids[i] = myReplied[user][sd][i];
        }
    }

    /**
    * Onchain information system for project data, which can provide official links, verify admin contacts etc.
    * @param sd : address of SD token
    * @param choice : string input example: twitter
    * @param input : string input example: https://twitter.com/fegtoken
    **/
    function updateInformation(address sd, string[] memory choice, string[] memory input) external {
        uint256 a = input.length;
        uint256 b = choice.length;
        require(a == b, "same");
        require(isSD(sd), "Not SD");
        require(msg.sender == Logic(sd).sdOwner());
        for(uint256 i = 0; i < a; i++) {
            require(!useInfo[input[i]], "docked");
            info[sd][choice[i]] = input[i];
            emit UpdateInformation(choice[i], input[i]);
            if(!usedInfoStringsBool[sd][choice[i]]) {
            usedInfoStrings[sd].push(choice[i]);
            usedInfoStringsBool[sd][choice[i]] = true;
            }
        }
    }

    // function to view all news array
    function viewAllNews(address sd) external view returns(string[] memory posts) {
        uint256 l = news[sd].length;
        posts = new string[](l);
        for(uint256 i = 0; i < l; i++) {
            posts[i] = news[sd][i];
        }
    }

    // function to view single news article
    function viewNews(address sd, uint256 id) external view returns(string memory post) {
        return news[sd][id];
    }

    // function to create new news article
    function newNews(address sd, string memory input) external {
        require(isSD(sd), "Not SD");
        require(isSupport[sd][msg.sender], "staff");
        news[sd].push(input);
        emit AddNews(sd,input);
    }

    // function to edit new article
    function editNews(address sd, uint256 id, string memory input) external {
        require(isSD(sd), "Not SD");
        require(isSupport[sd][msg.sender], "staff");
        require(id <= news[sd].length - 1, "Invalid");
        news[sd][id] = input;
        emit EditNews(sd,id,input);
    }

    function viewInfo(address sd, string[] memory choice) external view returns(string[] memory _info) {
        uint256 a = choice.length;
        _info = new string[](a);
        for(uint256 i = 0; i < a; i++) {
            _info[i] = info[sd][choice[i]];
        }
    }

    function wETH() public view returns(address) {
        return Reader(dataread).wETH();
    }

    /**
    * Main function to create an SD and register it as an official SD.
    * @param name: the name of the token
    * @param symbol: The symbol of the token
    * @param fee: the fees that should be applied (0.1% = 1 and 1000 = 0)
    *   fee[0] = backingFeeBuy
    *   fee[1] = burningFeeBuy
    *   fee[2] = liquidityFeeBuy
    *   fee[3] = growthFeeBuy
    *   fee[4] = stakingFeeBuy
    *   fee[5] = reflectionFeeBuy
    *   fee[6] = backingFeeSell
    *   fee[7] = burningFeeSell
    *   fee[8] = liquidityFeeSell
    *   fee[9] = growthFeeSell
    *   fee[10] = stakingFeeSell
    *   fee[11] = reflectionFeeSell
    * @param sb: if true all Fees apply to only buy and sells. On false it alows also for transfer taxes.
    * @param backingTokenAddress: The ERC20 address of the backing token. Need to be listed on uniswap/pancakeswap
    **/
    function createSD(address owner, string memory name, string memory symbol, uint256 supply, uint[12] calldata fee, bool sb, address _uniswapV2Router, address backingTokenAddress, bool _LGE) external returns (address SD) {
        require(on, "!on");
        require((supply <= 1e75) && !use[symbol], "sym used");
        if(backingTokenAddress != address(0)) {
        require(backingTokenAddress.code.length > 0, "not");
        }
        require(fee[0] + fee[1] + fee[2] + fee[3] + fee[4] + fee[5] < 501, " 50% max");
        require(fee[6] + fee[7] + fee[8] + fee[9] + fee[10] + fee[11] < 501, " 50% max");
        use[symbol] = true;
        address fac = IUniswapV2Router01(_uniswapV2Router).factory();
        address o = owner;
        SD = Logic(logic).createSD(name, symbol, supply, fee, sb, o, backingTokenAddress, _LGE);
        require(SDOfCreator[owner] == address(0), "already created");
        creatorOfSD[SD] = owner;
        SDOfCreator[owner] = SD;
        backingTokenAddress = backingTokenAddress == address(0) ? SD : backingTokenAddress;
        address uniswapV2Pair = IUniswapV2Factory(fac).createPair(SD, wETH());
        address pair = backingTokenAddress != wETH() ? IUniswapV2Router01(fac).getPair(wETH(), backingTokenAddress) : uniswapV2Pair;
        require(pair != address(0), "!ETHPair");
        allSD.push(SD);
        length += 1;
        Reader(dataread).setIsSD(SD);
        Reader(dataread).set_UNISWAP_V2_ROUTER(SD,_uniswapV2Router, uniswapV2Pair);
        Logic(SD).afterConstructor();   
        address oo = owner;
        isSupport[SD][oo] = true;
        minTicketCost[SD] = minDonation;
        ticket[SD].push();
        news[SD].push();
        donationLocation[SD] = owner;
        emit Created(name, SD);
        return SD;
    }

    struct Protector {
        uint256 range;
        uint256 slippage;
    }
    
    // view slippage of users front run protection system
    function slippage(address user) external view returns(uint256,uint256) {
        return (protect[user].range,protect[user].slippage);
    }

    // update the Logic can only be called by superAdmin multisig
    function setLogic(address addy) external {
        require(Reader(dataread).superAdmin(msg.sender), "admin");
        logic = addy;
    }

    /**
    * Setting your desired front run protection range
    * @param _slippage : amount of pool slippage you will allow
    * @param user : if user does not match msg.sender then require SmartDeFi calling contract.
    **/
    function setFrontRunProtection(address user, uint256 _range, uint256 _slippage) external {
        if(user != msg.sender) {
        require(isSD(msg.sender), "caller");
        }
        require(_slippage <= 30 , "30");
        require(_range <= 100 , "100");
        protect[user].slippage = _slippage;
        protect[user].range = _range;
        emit SetProtection(user, _slippage);
    }

    function dockInfo(string[] memory symbol, bool[] memory bool_) external {
        require(Reader(dataread).isAdmin(msg.sender) || Reader(dataread).isSetter(msg.sender));
        for(uint256 i = 0; i < bool_.length; i++) {
        useInfo[symbol[i]] = bool_[i];
        emit DockInfo(symbol[i], bool_[i]);
        }
    }

    function setCreatorOFSD(address sd, address creator) external {
        require(Reader(dataread).superAdmin(msg.sender), "admin");
        creatorOfSD[sd] = creator;
        SDOfCreator[creator] = sd;
    }

    /**
    * This will track the balance of wETH in the FEG main pair as well as backing asset in the backing pair of SmartDeFi token.
    * @param who : address of the SD token
    **/
    function setTick(address who) external {
        address DR = dataread;
        if(!Reader(DR).tickOn(who)) {
        address ba = Logic(who).backingAsset();
        address weth = wETH();
        require(Reader(DR).isProtocol(who) && isSD(who), "caller");
        address fac = IUniswapV2Router01(Reader(who).UNISWAP_V2_ROUTER()).factory();
        address t = ba == weth ? Reader(DR).uniswapV2Pair(who) : IUniswapV2Router01(fac).getPair(wETH(), ba);
        if(IERC20(ba).balanceOf(t) > 0) {
        uint256 k1 = tick[t].length > 0 ? tick[t][tick[t].length - 1] : 0;
        (uint112 reserve0, uint112 reserve1,) = IPair(t).getReserves();
        uint256 reserve = ba == IPair(t).token0() ? reserve0 : reserve1;
        if(reserve != k1) {
        tick[t].push(reserve);
        }
        }
        }
    }

    /**
    * This function lets you know if there was a front run trade before your transaction within a given percentage rate.
    * If you input range 5 then if the last trade moved the tracked balance of the previous 3 trades average by 5% then front run happened.
    * On contracts if returned bool is true then revert trade to save losses.
    * @param who : The name of to register
    * @param range : amount of slippage desired
    **/
    function frontRun(address who, uint256 range, uint256 slip) external view returns(bool yes) {
        if(!Reader(dataread).tickOn(who)) {
        if(range > 0) {
        uint256 a;
        address fac = IUniswapV2Router01(Reader(who).UNISWAP_V2_ROUTER()).factory();
        address ba = Logic(who).backingAsset();
        address t = ba == wETH() ? Reader(dataread).uniswapV2Pair(who) : IUniswapV2Router01(fac).getPair(wETH(), ba);
        (uint112 reserve0, uint112 reserve1,) = IPair(t).getReserves();
        a = (ba == IPair(t).token0() ? reserve0 : reserve1) * range;    
        if(tick[t].length > range + 3) {
        uint256 l = tick[who].length - (isSD(ba) ? 1 : 2); 
        uint256 c;
        for(uint256 i = 0; i < range; i++) {
            c += tick[who][l - i];
            if(l - i == 0) {
            a = (i + 1) * a / range;
            break;
            }
        }
        if(a > (c + (c * slip / 100))) {
            yes = true;
        }
        if(a < (c - (c * slip / 100))) {
            yes = true;
        }
        }
        }
        }
    }

    function ticketLength(address sd) external view returns(uint256) {
        return ticket[sd].length;
    }

    function isSD(address addy) public view returns(bool) {
        return Reader(dataread).isSD(addy);
    }
}

interface Reader {
    function isAdmin(address addy) external view returns (bool);
    function superAdmin(address addy) external view returns (bool);
    function isSetter(address addy) external view returns (bool);
    function isSD(address addy) external view returns (bool);
    function setIsSD(address addy) external;
    function protocolAddy() external view returns (address);    
    function feeConverter() external view returns (address);
    function sdDepAddy() external view returns (address);
    function getProtocolFee() external view returns (uint256);
    function breaker() external view returns (bool); //circuit breaked in case of an exploit to handle
    function isWhitelistContract(address addy) external view returns (bool);
    function setWhitelistContract(address addy, bool _bool) external;
    function stakeDeployerAddress() external view returns(address);
    function LEAPDepAddy() external view returns(address);
    function fegAddress() external view returns(address);
    function UNISWAP_V2_ROUTER(address token) external view returns(address);
    function UNISWAP_V2_ROUTER() external view returns(address);
    function uniswapV2Pair(address token) external view returns(address);
    function set_UNISWAP_V2_ROUTER(address token, address _uniswapV2Router, address _uniswapV2Pair) external;
    function backingLogicDep() external view returns(address);
    function BackingLogicAddress() external view returns(address);
    function setTick(address who) external;
    function frontRun(address who, uint256 range, uint256 slip, uint256 trades) external view returns(bool yes);
    function lastBalance(address user) external view returns(uint256);
    function wETH() external view returns(address);
    function LGEAddress() external view returns(address);
    function currentRouter() external view returns(address);
    function feeConverterSD(address sd) external view returns(address);
    function tickOn(address token) external view returns(bool);
    function isProtocol(address addy) external view returns(bool);
    function allLastBalance(address user) external view returns(uint256[] memory _balances, uint256[] memory blockNumbers);
}