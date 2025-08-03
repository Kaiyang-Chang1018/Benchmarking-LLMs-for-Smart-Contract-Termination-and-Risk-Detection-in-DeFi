// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;


// File: @openzeppelin/contracts/utils/Context.sol
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



// File: @openzeppelin/contracts/access/Ownable.sol
pragma solidity ^0.8.0;
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
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract Descriptor is Ownable {
  // attribute svgs
  string internal constant BEGINNING = "<image href='data:image/png;base64,";
  string internal constant END = "'/>";
  string internal constant F = "<g fill='#";
  string internal constant FEND = "'>";
  string internal constant GB = "</g>";
  string internal constant S = '<g><style>';
  string internal constant svghair = "<polygon points='13,30 13,26 14,26 14,25 15,25 15,24 21,24 21,25 22,25 22,26 15,26 15,27 14,27 14,30'/><polygon points='15,27 17,27 17,28 15,28'/><polygon points='19,27 21,27 21,28 19,28'/>";
  string internal constant svgeye = "<polygon points='15,28 17,28 17,30 15,30'/><polygon points='19,28 21,28 21,30 19,30'/><g fill='white' fill-opacity='0.9'><polygon points='15,28 17,28 17,29 16,29 16,30 15,30'/><polygon points='19,28 21,28 21,29 20,29 20,30 19,30'/></g>";
  string internal constant GA = "<g>";
  string internal constant FL ="var sto;function randomise(n){return rand=Math.floor(n*Math.random())}function initSnow(){var t=xj15-xj14,n;for(marginBottom=80,marginRight=72,i=0;i<=sm1;i++)coords[i]=0,lefr[i]=Math.random()*transX,pos[i]=.03+Math.random()/10,snow[i]=document.getElementById('flake'+i),snow[i].size=randomise(t)+xj14,snow[i].style.fontSize=snow[i].size+'px',snow[i].style.zIndex=1e3,snow[i].sink=ss1*snow[i].size/5,snow[i].posX=randomise(marginRight-snow[i].size),snow[i].posY=randomise(2*marginBottom-marginBottom-2*snow[i].size),snow[i].setAttribute('x',snow[i].posX+'px'),snow[i].setAttribute('y',snow[i].posY+'px');n=document.getElementById('xs54');n.remove();document.getElementById('wt78').appendChild(n);moveSnow()}function resize(){marginBottom=document.body.scrollHeight-5;marginRight=document.body.clientWidth-15}function moveSnow(){for(i=0;i<=sm1;i++)coords[i]+=pos[i],snow[i].posY+=snow[i].sink,snow[i].setAttribute('x',snow[i].posX+lefr[i]*Math.sin(coords[i])+'px'),snow[i].setAttribute('y',snow[i].posY+'px'),(snow[i].posY>=marginBottom-2*snow[i].size||parseInt(snow[i].style.left)>marginRight-3*lefr[i])&&(snow[i].posX=randomise(marginRight-snow[i].size),snow[i].posY=0);sto=setTimeout('moveSnow()',sr1)}function generateSnow(){for(i=0;i<=sm1;i++){let n=document.createElementNS('http://www.w3.org/2000/svg','rect');n.setAttribute('x','-'+xj15);n.setAttribute('y','0');n.setAttribute('width','0.3');n.setAttribute('height','0.3');n.setAttribute('fill',sc1);n.setAttribute('id','flake'+i);document.getElementById('wt78').appendChild(n)}initSnow()}var xj14=8,xj15=20,sr1=20,snowStyles='cursor: default; -webkit-user-select: none; -moz-user-select: none; -ms-user-select: none; -o-user-select: none; user-select: none;',snow=[],pos=[],coords=[],lefr=[],marginBottom,marginRight;window.onresize=resize;]]></script>";
  string internal constant FW = "</style><filter id='thrth'> <feTurbulence type='turbulence' baseFrequency='0.2' numOctaves='10' result='turbulence'/> <feDisplacementMap in2='turbulence' in='SourceGraphic' scale='4' xChannelSelector='R' yChannelSelector='G'/></filter><rect class='cc1' x='-0.7' y='-0.65' width='52' height='52' stroke-width='3' fill='transparent' style='filter: url(#thrth)' /><rect class='cc2' x='-0.7' y='-0.7' width='52' height='52' stroke-width='1.5' fill='transparent' style='filter: url(#thrth)' /><rect class='cc1' x='-0.65' y='-0.65' width='52' height='52' stroke-width='0.4' fill='transparent' style='filter: url(#thrth)'/><g class='cc3' id='xs55' onclick='pauseAudio()' transform='matrix(0.03 0 0 0.03 48.9 1.6)'  fill-opacity='0' stroke-width='6' stroke-linejoin='round'><path d='M39.389,13.769 L22.235,28.606 L6,28.606 L6,47.699 L21.989,47.699 L39.389,62.75 L39.389,13.769z'/><path d='M48,27.6a19.5,19.5 0 0 1 0,21.4M55.1,20.5a30,30 0 0 1 0,35.6M61.6,14a38.8' style='fill:none'/></g><g class='cc3' id='xs56' onclick='init()' transform='matrix(0.083 0 0 0.083 46.7 1.9)' stroke-width='2' fill-opacity='0'><path d='M19.444 9.361c-.882-4.926-2.854-6.379-3.903-6.379-1.637 0-2.057 1.217-5.541 1.258-3.484-.041-3.904-1.258-5.541-1.258-1.049 0-3.022 1.453-3.904 6.379-.503 2.812-1.049 7.01.252 7.514 1.619.627 2.168-.941 3.946-2.266C6.558 13.266 7.424 12.95 10 12.95s3.442.316 5.247 1.659c1.778 1.324 2.327 2.893 3.946 2.266 1.301-.504.755-4.701.251-7.514zM6 10a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm7 0a1 1 0 1 1 0-2 1 1 0 1 1 0 2zm2-2a1 1 0 1 1 0-2 1 1 0 1 1 0 2z'/></g></g>";
  string internal constant sFW = "<g id='xs54'><style>";

  uint8 public LockState = 0; // 1 = lock

  string[] public Weathers;
  string[] public Eyes;
  string[] public backgrounds;
  string[] public bodys;
  string[] public Eyewears;
  string[] public Hats;
  string[] public hairs;
  string[] public Clothes;
  string[] public frameworks;
  string[] public Others;

  function _addWeather(string calldata _trait) internal {
    Weathers.push(_trait);
  }

  function _addEye(string calldata _trait) internal {
    Eyes.push(_trait);
  }

  function _addBackground(string calldata _trait) internal {
    backgrounds.push(_trait);
  }

  function _addBody(string calldata _trait) internal {
    bodys.push(_trait);
  }

  function _addEyewear(string calldata _trait) internal {
    Eyewears.push(_trait);
  }

  function _addHats(string calldata _trait) internal {
    Hats.push(_trait);
  }

  function _addHairs(string calldata _trait) internal {
    hairs.push(_trait);
  }

  function _addClothe(string calldata _trait) internal {
    Clothes.push(_trait);
  }

  function _addframework(string calldata _trait) internal {
    frameworks.push(_trait);
  }

  function _addother(string calldata _trait) internal {
    Others.push(_trait);
  }

  // calldata input format: ["trait1","trait2","trait3",...]
  function addManyWeathers(string[] calldata _traits) external onlyOwner {
    for (uint256 i = 0; i < _traits.length; i++) {
      _addWeather(_traits[i]);
    }
  }

  function addManyEyes(string[] calldata _traits) external onlyOwner {
    for (uint256 i = 0; i < _traits.length; i++) {
      _addEye(_traits[i]);
    }
  }

  function addManybackgrounds(string[] calldata _traits) external onlyOwner {
    for (uint256 i = 0; i < _traits.length; i++) {
      _addBackground(_traits[i]);
    }
  }

  function addManyBodys(string[] calldata _traits) external onlyOwner {
    for (uint256 i = 0; i < _traits.length; i++) {
      _addBody(_traits[i]);
    }
  }

  function addManyEyewears(string[] calldata _traits) external onlyOwner {
    for (uint256 i = 0; i < _traits.length; i++) {
      _addEyewear(_traits[i]);
    }
  }

  function addManyHats(string[] calldata _traits) external onlyOwner {
    for (uint256 i = 0; i < _traits.length; i++) {
      _addHats(_traits[i]);
    }
  }

  function addManyHairs(string[] calldata _traits) external onlyOwner {
    for (uint256 i = 0; i < _traits.length; i++) {
      _addHairs(_traits[i]);
    }
  }

  function addManyClothes(string[] calldata _traits) external onlyOwner {
    for (uint256 i = 0; i < _traits.length; i++) {
      _addClothe(_traits[i]);
    }
  }

  function addManyframeworks(string[] calldata _traits) external onlyOwner {
    for (uint256 i = 0; i < _traits.length; i++) {
      _addframework(_traits[i]);
    }
  }  

    function addManyOthers(string[] calldata _traits) external onlyOwner {
    for (uint256 i = 0; i < _traits.length; i++) {
      _addother(_traits[i]);
    }
  }  

  function clearWeathers() external onlyOwner {
    require(LockState == 0);
    delete Weathers;
  }

  function clearEyes() external onlyOwner {
    require(LockState == 0);
    delete Eyes;
  }

  function clearBackgrounds() external onlyOwner {
    require(LockState == 0);
    delete backgrounds;
  }

  function clearBodys() external onlyOwner {
    require(LockState == 0);
    delete bodys;
  }

  function clearEyewears() external onlyOwner {
    require(LockState == 0);
    delete Eyewears;
  }

  function clearHats() external onlyOwner {
    require(LockState == 0);
    delete Hats;
  }

  function clearHairs() external onlyOwner {
    require(LockState == 0);
    delete hairs;
  }

  function clearClothes() external onlyOwner {
    require(LockState == 0);
    delete Clothes;
  }

  function clearFrameworks() external onlyOwner {
    require(LockState == 0);
    delete frameworks;
  }  

  function clearOthers() external onlyOwner {
    require(LockState == 0);
    delete Others;
  } 

  function renderWeather(uint256 _trait,uint256 _tokenutc) public view returns (bytes memory) {
    uint256 hora = uint256((block.timestamp + ((_tokenutc % 24) * 3600)) % 86400);
    if (_trait == 1) {
      return abi.encodePacked(GA, "<style>:root{--trans:",uint2str(hora),";}", Weathers[1], GB);
    } else {
      return abi.encodePacked(GA, "<style>:root{--trans:",uint2str(hora),";}", Weathers[2], GB);
    }
  }

    function renderWeather1(uint256 _trait) public view returns (bytes memory) {
    uint256 b = block.timestamp % 31556952;
    bytes memory data = "<script><![CDATA[var svg = document.querySelector('svg');";
    string memory datas = "var sc1='#bebee6';var transX = 0.5;var ss1=0.25;";
    string memory datan = "var sm1=250;";
    bytes memory none = "<script><![CDATA[function generateSnow(){n=document.getElementById('xs54');n.remove();document.getElementById('wt78').appendChild(n);}]]></script>";
    if (_trait == 1){
      return abi.encodePacked(none);
    }
    if (_trait == 2){
      return abi.encodePacked(none);
    }
    if (_trait == 4) {
     datan = "var sm1=500;";    
    }
    if (_trait == 5) {
     datan = "var sm1=1000;";     
    }
    if (_trait == 6) {
     datan = "var sm1=2000;";     
    }
    if (b < 6825600 || b > 30736152) {
      datas = "var sc1='#eeeeee';var transX = 2;var ss1=0.1;";
    }   
    return abi.encodePacked(data, datas, datan, FL);
  }

  function renderEye(uint256 _eye) external view returns (bytes memory) {
     return abi.encodePacked(F,Eyes[_eye], FEND, svgeye, GB);
  }

  function renderBackground(uint256 _Background) external view returns (bytes memory) {
    uint256 b = block.timestamp % 31556952;
    bytes memory bg = abi.encodePacked(BEGINNING, backgrounds[1], END);
    string memory season = "";
    string memory city = "";
    if (b < 6825600) {
      season = backgrounds[26];
      city = backgrounds[3];
    }
    else if (b > 30736152) {
      season = backgrounds[26];
      city = backgrounds[7];
    }
    else if (b >= 6825600 && b <= 14857200) {
      season = backgrounds[27];
      city = backgrounds[4];
    }
    else if (b > 14857200 && b < 22892400){
      season = backgrounds[28];
      city = backgrounds[5];
    }
    else {season = backgrounds[29];
          city = backgrounds[6];}
   
    // city skin
    if (_Background == 2) {
      city = backgrounds[2];
    }
    else if (_Background == 4) {
      city = backgrounds[8];
    }
    else if (_Background == 5) {
      city = backgrounds[9];
    }
    else if (_Background == 6) {
      city = backgrounds[10];
    }
    else if (_Background == 7) {
      city = backgrounds[11];
    }
    else if (_Background == 8) {
      city = backgrounds[16];
      if (b < 6825600 || b > 30736152) {season = backgrounds[12];}
      else if (b >= 6825600 && b <= 14857200) {season = backgrounds[13];}
      else if (b > 14857200 && b < 22892400){season = backgrounds[14];}
      else {season = backgrounds[15];}
    }
    else if (_Background == 9) {
      city = backgrounds[21];
      if (b < 6825600 || b > 30736152) {season = backgrounds[17];}
      else if (b >= 6825600 && b <= 14857200) {season = backgrounds[18];}
      else if (b > 14857200 && b < 22892400){season = backgrounds[19];}
      else {season = backgrounds[20];}
    }
    else if (_Background == 1) {
      city = "";
      if (b < 6825600 || b > 30736152) {season = backgrounds[22];}
      else if (b >= 6825600 && b <= 14857200) {season = backgrounds[23];}
      else if (b > 14857200 && b < 22892400){season = backgrounds[24];}
      else {season = backgrounds[25];}
    }
    return abi.encodePacked(bg, GA, BEGINNING, string(city), END, BEGINNING, string(season), END, GB);
  }
  

  function renderBody(uint256 _Body) external view returns (bytes memory) {
    bytes memory Bodyb;
    if (_Body == 1) {
      Bodyb = "<g fill='#fdeae1'><style>.e{fill : #ffb3ae;}";}
    else if (_Body == 2) {
      Bodyb = "<g fill='#ae8b60'><style>.e{fill : #785d3c;}";}
    else if (_Body == 3) {
      Bodyb = "<g fill='#713f1c'><style>.e{fill : #4d2a12;}";}
    else if (_Body == 4) {
      Bodyb = "<g fill='#7ca268'><style>.e{fill : #547642;}";}
    else if (_Body == 5) {
      Bodyb = "<g fill='#c7fbfb'><style>.e{fill : #6bacac;}";}
    else {
      Bodyb = "<g fill='#352410'><style>.d{fill : #856f55;}";
    }
    return abi.encodePacked(GA, BEGINNING, string(bodys[_Body]), END, GB, Bodyb, Others[3]);
  }

  function renderEyewear(uint256 _eyewear) external view returns (bytes memory) {
    return abi.encodePacked(BEGINNING, string(Eyewears[_eyewear]), END);
  }

  function renderHats(uint256 _Hats, string[10] memory _listcolor) external view returns (bytes memory) {
    bytes memory Color5 = abi.encodePacked("<g fill='#",_listcolor[5],"'>");
    bytes memory Color6 = abi.encodePacked("<g fill='#",_listcolor[6],"'>");
    if (_Hats <= 11) {
      return abi.encodePacked(GA, BEGINNING, string(Hats[_Hats]), END, GB);
    }
    else if (_Hats == 12) {
      return abi.encodePacked(Color5,Hats[12],GB,Color6,Hats[13],GB);
    }
    else if (_Hats == 13) {
      return abi.encodePacked(Color5,Hats[14],GB,Color6,Hats[15],GB);
    }
    else if (_Hats == 14) {
      return abi.encodePacked(Color5,Hats[16],GB,Color6,Hats[17],GB);
    }
    else if (_Hats == 15) {
      return abi.encodePacked(Color5,Hats[18],GB);
    }
    else {
      return abi.encodePacked(Color5,Hats[19],GB);
    }
  }

  function renderHairs(uint256 _hairs) external view returns (bytes memory) {
    if (_hairs == 1) {
      return abi.encodePacked(hairs[_hairs], svghair, GB );
    }
    else {
      return abi.encodePacked(F, hairs[_hairs], FEND, svghair, GB );
    }
  }


  function renderClothes(uint256 _Clothe, string[10] memory _listcolor) external view returns (bytes memory) {
    bytes memory Color0 = abi.encodePacked("<g fill='#",_listcolor[0],"'>");
    bytes memory Color1 = abi.encodePacked("<g fill='#",_listcolor[1],"'>");
    bytes memory Color2 = abi.encodePacked("<g fill='#",_listcolor[2],"'>");
    bytes memory Color3 = abi.encodePacked("<g fill='#",_listcolor[3],"'>");
    bytes memory Color4 = abi.encodePacked("<g fill='#",_listcolor[4],"'>");
    bytes memory Brascolor;
    bytes memory start;
    bytes memory start2;
    if (_Clothe == 1) {
      Brascolor = abi.encodePacked("<g fill-opacity='0'><style>.a{fill : #",_listcolor[1],";}.b{fill : #",_listcolor[1],";}.c{fill : #ffffff;}");
      start = abi.encodePacked(Color0,Clothes[4],GB,Color1,Clothes[8],GB,Color2,Clothes[9],GB);
      start2 = abi.encodePacked(start,Color3,Clothes[6],GB,Color4,Clothes[5],GB);
      return abi.encodePacked(start2, Brascolor, Others[3]);
    }
    else if (_Clothe == 2) {
      Brascolor = abi.encodePacked("<g fill-opacity='0'><style>.a{fill : #",_listcolor[0],";}.b{fill : #",_listcolor[0],";}.c{fill : #ffffff;}");
      start = abi.encodePacked(Color0,Clothes[2],GB,Color1,Clothes[4],GB,Color2,Clothes[10],GB);
      start2 = abi.encodePacked(start,Color3,Clothes[6],GB,Color4,Clothes[5],GB);
      return abi.encodePacked(start2, Brascolor, Others[3]);
    }
    else if (_Clothe == 3) {
      Brascolor = abi.encodePacked("<g fill-opacity='0'><style>.a{fill : #",_listcolor[0],";}");
      start = abi.encodePacked(Color0,Clothes[1],GB,Color1,Clothes[3],GB,Color2,Clothes[10],GB);
      return abi.encodePacked(start,Color3,Clothes[7],GB, Brascolor, Others[3]);
    }
    else if (_Clothe == 4) {
      start = abi.encodePacked(Color0,Clothes[12],GB,Color1,Clothes[11],GB,Color2,Clothes[10],GB);
      return abi.encodePacked(start,Color3,Clothes[7],GB);
    }
    else if (_Clothe == 5) {
      return abi.encodePacked(Color0,Clothes[11],GB,Color1,Clothes[13],GB);
    }
    else {
      if (_Clothe == 6) {
        Brascolor = "<g fill-opacity='0'><style>.a{fill : #1f1e28;}.b{fill : #dfc74d;}.c{fill : #ffffff;}";
      }
      else if (_Clothe == 7) {
        Brascolor = "<g fill-opacity='0'><style>.a{fill : #1c1c1c;}.b{fill : #1c1c1c;}.c{fill : #1c1c1c;}";
      }
      else if (_Clothe == 8) {
        Brascolor = "<g fill-opacity='0'><style>.a{fill : #3540ac;}";
      }
      else if (_Clothe == 9) {
        Brascolor = "<g fill-opacity='0'><style>.a{fill : #906458;}";
      }
      else if (_Clothe == 10) {
        Brascolor = "<g fill-opacity='0'><style>";
      }
      else if (_Clothe == 11) {
        Brascolor = "<g fill-opacity='0'><style>.a{fill : #063a6d;}.b{fill : #063a6d;}.c{fill : #063a6d;}";
      }
      else if (_Clothe == 12) {
        Brascolor = "<g fill-opacity='0'><style>.a{fill : #bd2d36;}";
      }
      else {
        Brascolor = "<g fill-opacity='0'><style>.a{fill : #323a95;}.b{fill : #323a95;}.c{fill : #000000;}";
      }
      return abi.encodePacked(GA, BEGINNING, string(Clothes[_Clothe + 8]), END, GB, Brascolor, Others[3]);
    }
  }

  function renderFramework(uint256 _framework) external view returns (bytes memory) {
    return abi.encodePacked(sFW, frameworks[_framework], FW);
  }

  function renderOther(uint256 _other) external view returns (bytes memory) {
     return abi.encodePacked(Others[_other]);
  }

  function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
    if (_i == 0) {
      return "0";
    }
    uint256 j = _i;
    uint256 len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint256 k = len;
    while (_i != 0) {
      k = k - 1;
      uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
      bytes1 b1 = bytes1(temp);
      bstr[k] = b1;
      _i /= 10;
    }
    return string(bstr);
  }

    function Lock() external onlyOwner {
    require(LockState < 1, "Sale state is already closed");
    LockState++;
  }


}