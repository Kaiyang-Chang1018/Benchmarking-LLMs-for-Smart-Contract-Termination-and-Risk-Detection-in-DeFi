//   __       
//  /__)_     
// /   / ()/) 
//        /   
//
// SPDX-License-Identifier: MIT
// Copyright Han, 2023

pragma solidity ^0.8.21;

contract Prop {
    event ArtpieceCreated(address indexed creator);
    event ArtpieceTransferred(address indexed oldOwner, address indexed newOwner);
    event BidAccepted(uint256 value, address indexed fromAddress, address indexed toAddress);
    event BidPlaced(uint256 value, address indexed fromAddress);
    event BidWithdrawn(uint256 value, address indexed fromAddress);
    event ListedForSale(uint256 value, address indexed fromAddress, address indexed toAddress);
    event SaleCanceled(uint256 value, address indexed fromAddress, address indexed toAddress);
    event SaleCompleted(uint256 value, address indexed fromAddress, address indexed toAddress);

    error FundsTransfer();
    error InsufficientFunds();
    error ListedForSaleToSpecificAddress();
    error NoBid();
    error NotForSale();
    error NotOwner();
    error NotRoyaltyRecipient();
    error NotYourBid();
    error NullAddress();
    error RoyaltyTooHigh();

    string public constant MANIFEST = (
        'Hidden dreams.' '\n'
    );

    string public constant CORE = (
        '"use strict";const CREDITS="I am grateful to Dima, WillStall, and IQ (soft shadow) for making this piece possible, you\u2019re wizards. - Han";console.log(CREDITS);let s={signature:"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjE2IiBoZWlnaHQ9IjIxNiIgdmlld0JveD0iMCAwIDIxNiAyMTYiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGZpbGwtcnVsZT0iZXZlbm9kZCIgY2xpcC1ydWxlPSJldmVub2RkIiBkPSJNNDEgMTZIMTc1QzE4OC44MDcgMTYgMjAwIDI3LjE5MjkgMjAwIDQxVjE3NUMyMDAgMTg4LjgwNyAxODguODA3IDIwMCAxNzUgMjAwSDQxQzI3LjE5MjkgMjAwIDE2IDE4OC44MDcgMTYgMTc1VjQxQzE2IDI3LjE5MjkgMjcuMTkyOSAxNiA0MSAxNlpNMCA0MUMwIDE4LjM1NjMgMTguMzU2MyAwIDQxIDBIMTc1QzE5Ny42NDQgMCAyMTYgMTguMzU2MyAyMTYgNDFWMTc1QzIxNiAxOTcuNjQ0IDE5Ny42NDQgMjE2IDE3NSAyMTZINDFDMTguMzU2MyAyMTYgMCAxOTcuNjQ0IDAgMTc1VjQxWk0xMTkgMTE5SDk3Vjk3SDExOVYxMTlaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K",mouse_sensitivity:.2,mouse_limit:.47},h={};const mobile=/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);let w=window,d=document,b=d.body;d.body.style.touchAction="none",d.body.style.userSelect="none";let c=d.createElement("canvas");c.style.display="block",b.appendChild(c);const glOptions={powerPreference:"high-performance"};mobile&&delete glOptions.powerPreference,window.gl=c.getContext("webgl",glOptions),h.uniform=(e,i)=>{let t=Array.isArray(i)?i.length-1:0,o=[["uniform1f",0,"float"],["uniform2fv",[0,0],"vec2"]],r={};return r.name=e,r.type=o[t][0],r.value=i||o[t][1],r.inner_type=o[t][2],r.location="",r.dirty=!1,r},s.uniforms=[["u_resolution",[0,0]],["u_time",0],["u_mouse",[0,0]]],s.uniforms.forEach(((e,i)=>s.uniforms[i]=h.uniform(e[0],e[1]))),h.resize=()=>{let e=s.uniforms[0],i={x:h.ix.mouse.x/e.value[0],y:h.ix.mouse.y/e.value[1]},t=window.innerWidth,o=window.innerHeight;s.aspect&&(t>o*s.aspect?t=o*s.aspect:o=t/s.aspect);let r=window.devicePixelRatio;e.value[0]=c.width=t*r,e.value[1]=c.height=o*r,c.style.width=t+"px",c.style.height=o+"px",e.dirty=!0,h.ix.set(c.width*i.x,c.height*i.y)},h.ix={start:{x:0,y:0},mouse:{x:0,y:0}},h.ix.save=()=>{let e=s.uniforms[2];e.value=[h.ix.mouse.x,h.ix.mouse.y],e.dirty=!0},h.ix.set=(e,i)=>{h.ix.mouse={x:e,y:i},h.ix.save()},h.ix.start=e=>{h.ix.start.x=e.clientX,h.ix.start.y=e.clientY,d.addEventListener("pointermove",h.ix.move)},h.clamp=(e,i,t)=>e<i?i:e>t?t:e,h.ix.move=e=>{if(window.changing)return;h.ix.mouse.x+=(e.clientX-h.ix.start.x)*window.devicePixelRatio*s.mouse_sensitivity,h.ix.mouse.y-=(e.clientY-h.ix.start.y)*window.devicePixelRatio*s.mouse_sensitivity,h.ix.start.x=e.clientX,h.ix.start.y=e.clientY;let i=s.uniforms[0];h.ix.mouse.x=h.clamp(h.ix.mouse.x,i[0]*s.mouse_limit,i[0]*(1-s.mouse_limit)),h.ix.mouse.y=h.clamp(h.ix.mouse.y,i[1]*s.mouse_limit,i[1]*(1-s.mouse_limit)),h.ix.save()},h.ix.stop=()=>{d.removeEventListener("pointermove",h.ix.move)},h.buildShader=(e,i)=>{let t=gl.createShader(e);return gl.shaderSource(t,i),gl.compileShader(t),t},h.initProgram=(e,i)=>{window.program=s.program=gl.createProgram();const t=h.buildShader(gl.VERTEX_SHADER,i),o=h.buildShader(gl.FRAGMENT_SHADER,e);gl.attachShader(s.program,t),gl.attachShader(s.program,o),gl.linkProgram(s.program),gl.getShaderParameter(t,gl.COMPILE_STATUS)||console.error("V: "+gl.getShaderInfoLog(t)),gl.getShaderParameter(o,gl.COMPILE_STATUS)||console.error("F: "+gl.getShaderInfoLog(o)),gl.getProgramParameter(s.program,gl.LINK_STATUS)||console.error("P: "+gl.getProgramInfoLog(s.program));for(let e in s.uniforms){let i=s.uniforms[e];i.location=gl.getUniformLocation(s.program,i.name),i.dirty=!0}let r=Float32Array.of(-1,1,-1,-1,1,1,1,-1),n=gl.createBuffer(),l=gl.getAttribLocation(s.program,"p");gl.bindBuffer(gl.ARRAY_BUFFER,n),gl.bufferData(gl.ARRAY_BUFFER,r,gl.STATIC_DRAW),gl.enableVertexAttribArray(l),gl.vertexAttribPointer(l,2,gl.FLOAT,!1,0,0),gl.useProgram(s.program)},s.pixel=new Uint8Array(4),h.render=()=>{gl.viewport(0,0,c.width,c.height);let e=s.uniforms[1];e.value=.001*performance.now(),e.dirty=!0;let i=s.uniforms.filter((e=>e.dirty));for(let e in i)gl[i[e].type](i[e].location,i[e].value),i[e].dirty=!1;gl.drawArrays(gl.TRIANGLE_STRIP,0,4),gl.readPixels(0,0,1,1,gl.RGBA,gl.UNSIGNED_BYTE,s.pixel),requestAnimationFrame(h.render)};const init=async()=>{if(gl){const e="attribute vec2 p;void main(){gl_Position=vec4(p,1.0,1.0);}";let i="precision highp float;const int AA=2;uniform vec2 u_resolution;uniform float u_time;uniform vec2 u_mouse;const vec3 v=vec3(1),f=vec3(.690196078431373),i=vec3(0,0,7);float n(float v,float A){return exp(-.8*v)*sin(3.19*(v-.8*A))*.9;}vec2 s(vec3 v,float f){float i=1e3,y=length(v.xy),m=n(y,f);v.z+=m;i=v.z;return vec2(i,0);}vec2 n(vec3 v,vec3 A,float f){float i=0.,r=0.;for(int u=0;u<128;u++){vec2 m=s(v+i*A,f);i+=m.x;r=m.y;if(m.x<=.001||i>1e3)break;}return vec2(i,r);}float s(vec3 v,vec3 A,float f){float i=1.,r=1.5;for(int u=0;u<10;u++){float m=s(v+r*A,f).x,y=m/(0.*r);i=min(i,y);r+=clamp(m,.01,1.);if(i<=-1.||r>1e3)break;}return clamp(i,0.,1.);}vec3 n(){vec3 v=gl_FragCoord.xyy,f;v=vec3(dot(v,vec3(127.1,311.7,74.7)),dot(v,vec3(269.5,183.3,246.1)),dot(v,vec3(113.5,271.9,124.6)));f=-1.+2.*fract(sin(v)*43758.5453123);return fract(555.*sin(777.*f))/256.;}vec3 n(vec3 v){vec2 i=gl_FragCoord.xy/u_resolution.xy;float m=(i.x+4.)*(i.y+4.)*(1e2+u_time);vec3 f=vec3(mod((mod(m,13.)+1.)*(mod(m,123.)+1.),.01)-.005)*.0265*1e2;v*=1.-f;return v*(1.-f);}vec3 s(vec3 v){v=n(v);v+=n();return v;}vec3 t(vec3 v,float f){vec2 i=vec2(.002,0);float m=s(v,f).x;return normalize(vec3(m-s(v-i.xyy,f).x,m-s(v-i.yxy,f).x,m-s(v-i.yyx,f).x));}vec3 t(inout vec3 m,inout vec3 A,float y){vec2 u=n(m,A,y);vec3 r=m+u.x*A,x=t(r,y),e=vec3(0);if(u.x>=1e3)e=f;else{r+=x*.01;vec3 d=normalize(i-r);float c=(dot(x,normalize(vec3(0,1,-.5)))+dot(d,x)+1.)/2.,z=s(r,d,y);c*=mix(1.,z,.91);e=mix(f,v,c);if(u.y==1.)e=vec3(1,0,0);}return e;}vec3 e(float v,float f){float A=sin(f);return vec3(40.*A*cos(v),40.*cos(f),40.*A*sin(v));}mat3 m(vec3 v,vec2 f){vec3 i=normalize(vec3(0)-v),m=normalize(cross(vec3(0,floor(mod(f.y,2.))==0.?-1.:1.,0),i));return mat3(m,normalize(cross(i,m)),i);}vec3 e(){float v=u_time,f,i;vec3 r=vec3(0),y;vec2 A=vec2(u_mouse/u_resolution),u;y=e(2.*acos(-1.)*A.x+1.570795,A.y*3.14159);y.z=40.;mat3 c=m(y,A);u=gl_FragCoord.xy;f=.5+.5*sin(u.x*147.)*sin(u.y*131.);i=.37*smoothstep(0.,1.,2.987*cos(2.*acos(-1.)*v/20.));for(int x=0;x<AA;x++)for(int d=0;d<AA;d++){vec2 n=vec2(x,d)/float(AA)-.5,z=(gl_FragCoord.xy+n-.5*u_resolution.xy)*.192433455611695/u_resolution.y;vec3 h=normalize(c*vec3(z,1));float s=v-.1*(float(d*AA+x)+f)/float(AA*AA),k;k=2.*acos(-1.)*(s-i)/10.;r.x+=t(y,h,k).x;k=2.*acos(-1.)*s/10.;r.y+=t(y,h,k).y;k=2.*acos(-1.)*(s+i)/10.;r.z+=t(y,h,k).z;}r/=float(AA*AA);return r;}void main(){vec3 v=e();gl_FragColor=vec4(s(v),1);}";if(mobile){const e="const int AA=2";i=i.replace(e,"const int AA=1")}h.initProgram(i,e),h.resize(),h.ix.set(c.width/2,c.height/2),h.render(),d.addEventListener("pointerdown",h.ix.start),d.addEventListener("pointerup",h.ix.stop),window.addEventListener("resize",h.resize);const t=d.createElement("img");t.src=s.signature.trim(),t.style.cssText="width:40px;z-index:50;position:fixed;bottom:20px;right:20px;",b.appendChild(t)}else{const e=d.createElement("div");e.style.cssText="align-items:center;background:#969696;color:#fff;display:flex;font-family:monospace;font-size:20px;height:100vh;justify-content:center;left:0;position:fixed;top:0;width:100vw;",e.innerHTML="Your browser does not support WebGL.",b.append(e)}};init();'
    );

    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert NotOwner();
        }

        _;
    }

    modifier onlyRoyaltyRecipient() {
        if (royaltyRecipient != msg.sender) {
            revert NotRoyaltyRecipient();
        }

        _;
    }

    struct Offer {
        bool active;
        uint256 value;
        address toAddress;
    }

    struct Bid {
        bool active;
        uint256 value;
        address fromAddress;
    }

    address public owner;

    Offer public currentOffer;

    Bid public currentBid;

    address public royaltyRecipient;

    uint256 public royaltyPercentage;

    mapping (address => uint256) public pendingWithdrawals;

    constructor(uint256 _royaltyPercentage) {
        if (_royaltyPercentage >= 100) {
            revert RoyaltyTooHigh();
        }

        owner = msg.sender;
        royaltyRecipient = msg.sender;
        royaltyPercentage = _royaltyPercentage;

        emit ArtpieceCreated(msg.sender);
    }

    function name() public view virtual returns (string memory) {
        return 'Prop';
    }

    function symbol() public view virtual returns (string memory) {
        return 'P';
    }

    function artpiece() public view virtual returns (string memory) {
        return string.concat(
            '<!DOCTYPE html>'
            '<html>'
                '<head>'
                    '<title>', 'Prop', '</title>'

                    '<meta name="viewport" content="width=device-width, initial-scale=1" />'

                    '<style>html,body{background:#969696;margin:0;padding:0;overflow:hidden;}</style>'
                '</head>'

                '<body>'
                    '<script type="text/javascript">',
                        CORE,
                    '</script>'
                '</body>'
            '</html>'
        );
    }

    function withdraw() public {
        uint256 amount = pendingWithdrawals[msg.sender];

        pendingWithdrawals[msg.sender] = 0;

        _sendFunds(amount);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner == address(0)) {
            revert NullAddress();
        }

        _transferOwnership(newOwner);

        if (currentBid.fromAddress == newOwner) {
            uint256 amount = currentBid.value;

            currentBid = Bid({ active: false, value: 0, fromAddress: address(0) });

            pendingWithdrawals[newOwner] += amount;
        }

        if (currentOffer.active) {
            currentOffer = Offer({ active: false, value: 0, toAddress: address(0) });
        }
    }

    function listForSale(uint256 salePriceInWei) public onlyOwner {
        currentOffer = Offer({ active: true, value: salePriceInWei, toAddress: address(0) });

        emit ListedForSale(salePriceInWei, msg.sender, address(0));
    }

    function listForSaleToAddress(uint256 salePriceInWei, address toAddress) public onlyOwner {
        currentOffer = Offer({ active: true, value: salePriceInWei, toAddress: toAddress });

        emit ListedForSale(salePriceInWei, msg.sender, toAddress);
    }

    function cancelFromSale() public onlyOwner {
        Offer memory oldOffer = currentOffer;

        currentOffer = Offer({ active: false, value: 0, toAddress: address(0) });

        emit SaleCanceled(oldOffer.value, msg.sender, oldOffer.toAddress);
    }

    function buyNow() public payable {
        if (!currentOffer.active) {
            revert NotForSale();
        }

        if (currentOffer.toAddress != address(0) && currentOffer.toAddress != msg.sender) {
            revert ListedForSaleToSpecificAddress();
        }

        if (msg.value != currentOffer.value) {
            revert InsufficientFunds();
        }

        currentOffer = Offer({ active: false, value: 0, toAddress: address(0) });

        uint256 royaltyAmount = _calcRoyalty(msg.value);

        pendingWithdrawals[owner] += msg.value - royaltyAmount;
        pendingWithdrawals[royaltyRecipient] += royaltyAmount;

        emit SaleCompleted(msg.value, owner, msg.sender);

        _transferOwnership(msg.sender);
    }

    function placeBid() public payable {
        if (msg.value <= currentBid.value) {
            revert InsufficientFunds();
        }

        if (currentBid.value > 0) {
            pendingWithdrawals[currentBid.fromAddress] += currentBid.value;
        }

        currentBid = Bid({ active: true, value: msg.value, fromAddress: msg.sender });

        emit BidPlaced(msg.value, msg.sender);
    }

    function acceptBid() public onlyOwner {
        if (!currentBid.active) {
            revert NoBid();
        }

        uint256 amount = currentBid.value;
        address bidder = currentBid.fromAddress;

        currentOffer = Offer({ active: false, value: 0, toAddress: address(0) });
        currentBid = Bid({ active: false, value: 0, fromAddress: address(0) });

        uint256 royaltyAmount = _calcRoyalty(amount);

        pendingWithdrawals[owner] += amount - royaltyAmount;
        pendingWithdrawals[royaltyRecipient] += royaltyAmount;

        emit BidAccepted(amount, owner, bidder);

        _transferOwnership(bidder);
    }

    function withdrawBid() public {
        if (msg.sender != currentBid.fromAddress) {
            revert NotYourBid();
        }

        uint256 amount = currentBid.value;

        currentBid = Bid({ active: false, value: 0, fromAddress: address(0) });

        _sendFunds(amount);

        emit BidWithdrawn(amount, msg.sender);
    }

    function setRoyaltyRecipient(address newRoyaltyRecipient) public onlyRoyaltyRecipient {
        if (newRoyaltyRecipient == address(0)) {
            revert NullAddress();
        }

        royaltyRecipient = newRoyaltyRecipient;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = owner;

        owner = newOwner;

        emit ArtpieceTransferred(oldOwner, newOwner);
    }

    function _sendFunds(uint256 amount) internal virtual {
        (bool success, ) = msg.sender.call{value: amount}('');

        if (!success) {
            revert FundsTransfer();
        }
    }

    function _calcRoyalty(uint256 amount) internal virtual returns (uint256) {
        return (amount * royaltyPercentage) / 100;
    }
}