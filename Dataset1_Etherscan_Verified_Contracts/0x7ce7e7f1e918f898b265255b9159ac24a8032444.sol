//         _____ _______ _____ _______
//  |        |   |  |  |   |      |   
//  |_____ __|__ |  |  | __|__    |   
//
// SPDX-License-Identifier: MIT
// Copyright Han, 2023

pragma solidity ^0.8.21;

contract Limit {
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
        'Algorithmic behaviors.' '\n'
    );

    string public constant CORE = (
        '"use strict";let w=window,d=document,b=d.body;d.body.style.touchAction="none",d.body.style.userSelect="none";let c=d.querySelector("canvas");c||(c=d.createElement("canvas"),c.style.display="block",b.appendChild(c));const mobile=/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent),frag_shader_string="precision highp float;uniform vec2 u_resolution,u_mouse;uniform float u_time;const int AA=2;float v;vec3 t(vec3 v){v=vec3(dot(v,vec3(127.1,311.7,74.7)),dot(v,vec3(269.5,183.3,246.1)),dot(v,vec3(113.5,271.9,124.6)));return-1.+2.*fract(sin(v)*43758.5453123);}vec3 n(vec3 v){return clamp(v*(2.51*v+.03)/(v*(2.43*v+.59)+.14),0.,1.);}float m(float v){v=fract(v*.1031);v*=v+33.33;v*=v+v;return fract(v);}float f(float v){float x=floor(v);return mix(m(x),m(x+1.),smoothstep(0.,1.,fract(v)));}float f(vec3 v){vec3 f=floor(v),x=fract(v);x=x*x*(3.-2.*x);float y=f.x+f.y*157.+4.*f.z;return mix(mix(mix(m(y),m(y+1.),x.x),mix(m(y+157.),m(y+158.),x.x),x.y),mix(mix(m(y+113.),m(y+114.),x.x),mix(m(y+270.),m(y+271.),x.x),x.y),x.z);}float x(vec3 x){vec2 m=vec2(.06,.035),A=vec2(50,100),y=x.xy*vec2(1.4,.2),r;y.x+=v*A.x;y.y+=v*A.y;y*=1.001;float n=f(vec3(y,1.5)),d;n=n*2.-1.;n*=.45;d=abs(x.y-n)-m.x;r=vec2(d,abs(x.z)-m.y);return min(max(r.x,r.y),0.)+length(max(r,0.));}vec2 p(vec3 v){float r=1e3,y=x(v);y-=.0025;y*=.9;r=min(r,y);return vec2(r,0);}vec3 e(vec3 v){vec2 x=vec2(.01,0);float m=p(v).x;return normalize(vec3(m-p(v-x.xyy).x,m-p(v-x.yxy).x,m-p(v-x.yyx).x));}vec2 e(vec3 v,vec3 x){float y=0.;vec2 m;for(int r=0;r<64;r++){vec3 f=v+x*y;m=p(f);y+=m.x;if(y>20.||abs(m.x)<.005)break;}y=min(y,20.);return vec2(y,m.y);}vec4 f(vec3 v,vec3 y){vec3 x=e(v),r=vec3(0,-100,0),m;r=normalize(v-r);float f=clamp(dot(r,x),0.,1.),A=clamp(1.+dot(y,x),0.,1.),d=clamp(dot(reflect(-r,x),-y),0.,1.);m=mix(vec3(.6745),vec3(2),f);m+=vec3(1)*pow(A,7.);m+=vec3(1)*pow(d,2.)*.75;return vec4(m,A);}vec4 m(vec2 m,vec2 x){v=fract(v);vec2 y=(m-.5*x)/x.y,r;vec3 A=vec3(0,10,-10),d=normalize(vec3(0)-A),s=normalize(vec3(d.z,0,-d.x)),u=normalize(y.x*s+y.y*cross(d,s)+d/.14),i,z;r=e(A,u);i=A+u*r.x;z=vec3(0);z=vec3(.88);if(r.x<20.)z=f(i,u).xyz;z=n(z);return vec4(z,1);}vec4 n(vec2 y,vec2 x){vec4 r=vec4(.3216,.3216,.3216,1);float A=.5+.5*sin(y.x*147.)*sin(y.y*131.),d=f(u_time*.5),z;d=pow(d,3.);d=smoothstep(.2,.8,d);z=.2*d;for(int u=0;u<AA;u++)for(int i=0;i<AA;i++){float n=u_time-.125*(float(u*AA+i)+A)/float(AA*AA);vec2 s=y+vec2(i,u)/float(AA);v=(n-z)/12.;r.x+=m(s,x).x;v=n/12.;r.y+=m(s,x).y;v=(n+z)/12.;r.z+=m(s,x).z;}r/=float(AA*AA);return r;}void main(){vec4 v=vec4(1);vec2 y=gl_FragCoord.xy;v=n(y,u_resolution);vec3 r=fract(555.*sin(777.*t(y.xyy)))/256.;gl_FragColor=vec4(v.xyz+r,1);}",SIGNATURE_SVG="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjE2IiBoZWlnaHQ9IjIxNiIgdmlld0JveD0iMCAwIDIxNiAyMTYiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGZpbGwtcnVsZT0iZXZlbm9kZCIgY2xpcC1ydWxlPSJldmVub2RkIiBkPSJNMC4xMzE4OTkgMEwxMDAuMjkzIDEwLjE3MzRMMjA1LjYxOSAwLjE0OTk4NkwyMTUuMTczIDEwNy42MzZWMjE1Ljc4N0wxMDAuMzI3IDIwMi43NTNMMCAyMTZMMTAuNjMxMiAxMTUuOTVMMC4xMzE4OTkgMFpNMTk1LjM4MiAxMi40NjE5TDEwMC4yNTcgMjEuNTE0NkwxMi42MDY4IDEyLjYxMTlMMjEuOTcyMSAxMTYuMDM4TDEyLjczODcgMjAyLjkzM0wxMDAuMjIzIDE5MS4zODJMMjAzLjg4NyAyMDMuMTQ3VjEwOC4xMzdMMTk1LjM4MiAxMi40NjE5WiIgZmlsbD0id2hpdGUiLz4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik05OC4yNDgyIDg2LjkxMDJMMTI2LjQ4NyA4OS4zNjU3TDEyOC45MzkgMTE4Ljc4OEw5Mi4xMTcyIDEyMi40N0w5OC4yNDgyIDg2LjkxMDJaTTEwNC40ODggOTUuMDA1NkwxMDEuMjEzIDExMy45OThMMTIwLjgyNSAxMTIuMDM3TDExOS41MTUgOTYuMzEyM0wxMDQuNDg4IDk1LjAwNTZaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K",CREDITS="I am grateful to Dima, WillStall, and IQ (sdf) for making this piece possible, you are wizards. - Han";console.log(CREDITS);const appendSignature=()=>{const e=d.createElement("img");e.src=SIGNATURE_SVG.trim(),e.style.cssText="width:40px;z-index:50;position:fixed;bottom:20px;right:20px;",b.appendChild(e)};let h={},s={};const glOptions={powerPreference:"high-performance"};mobile&&delete glOptions.powerPreference,window.gl=c.getContext("webgl",glOptions),h.uniform=(e,t)=>{let r=Array.isArray(t)?t.length-1:0,i=[["uniform1f",0,"float"],["uniform2fv",[0,0],"vec2"]],o={};return o.name=e,o.type=i[r][0],o.value=t||i[r][1],o.inner_type=i[r][2],o.location="",o.dirty=!1,o},s.uniforms=[["u_resolution",[0,0]],["u_time",0],["u_mouse",[0,0]]],s.uniforms.forEach(((e,t)=>s.uniforms[t]=h.uniform(e[0],e[1]))),h.resize=()=>{let e=s.uniforms[0],t={x:h.ix.mouse.x/e.value[0],y:h.ix.mouse.y/e.value[1]},r=window.innerWidth,i=window.innerHeight;s.aspect&&(r>i*s.aspect?r=i*s.aspect:i=r/s.aspect);let o=window.devicePixelRatio;e.value[0]=c.width=r*o,e.value[1]=c.height=i*o,c.style.width=r+"px",c.style.height=i+"px",e.dirty=!0,h.ix.set(c.width*t.x,c.height*t.y)},h.ix={start:{x:0,y:0},mouse:{x:0,y:0}},h.ix.events={start:["pointerdown"],move:["pointermove"],stop:["pointerup"]},h.ix.save=()=>{let e=s.uniforms[2];e.value=[h.ix.mouse.x,h.ix.mouse.y],e.dirty=!0},h.ix.set=(e,t)=>{h.ix.mouse={x:e,y:t},h.ix.save()},h.ix.start=e=>{h.ix.start.x=e.clientX,h.ix.start.y=e.clientY;for(let e of h.ix.events.move)d.addEventListener(e,h.ix.move)},h.ix.move=e=>{h.ix.mouse.x+=(e.clientX-h.ix.start.x)*window.devicePixelRatio,h.ix.mouse.y-=(e.clientY-h.ix.start.y)*window.devicePixelRatio,h.ix.start.x=e.clientX,h.ix.start.y=e.clientY,h.ix.save()},h.ix.stop=()=>{for(let e of h.ix.events.move)d.removeEventListener(e,h.ix.move)},h.buildShader=(e,t)=>{let r=gl.createShader(e);return gl.shaderSource(r,t),gl.compileShader(r),r},h.initProgram=(e,t)=>{window.program=s.program=gl.createProgram();const r=h.buildShader(gl.VERTEX_SHADER,t),i=h.buildShader(gl.FRAGMENT_SHADER,e);gl.attachShader(s.program,r),gl.attachShader(s.program,i),gl.linkProgram(s.program),gl.getShaderParameter(r,gl.COMPILE_STATUS)||console.error("V: "+gl.getShaderInfoLog(r)),gl.getShaderParameter(i,gl.COMPILE_STATUS)||console.error("F: "+gl.getShaderInfoLog(i)),gl.getProgramParameter(s.program,gl.LINK_STATUS)||console.error("P: "+gl.getProgramInfoLog(s.program));for(let e in s.uniforms){let t=s.uniforms[e];t.location=gl.getUniformLocation(s.program,t.name),t.dirty=!0}let o=Float32Array.of(-1,1,-1,-1,1,1,1,-1),n=gl.createBuffer(),a=gl.getAttribLocation(s.program,"p");gl.bindBuffer(gl.ARRAY_BUFFER,n),gl.bufferData(gl.ARRAY_BUFFER,o,gl.STATIC_DRAW),gl.enableVertexAttribArray(a),gl.vertexAttribPointer(a,2,gl.FLOAT,!1,0,0),gl.useProgram(s.program)},s.pixel=new Uint8Array(4),h.render=()=>{gl.viewport(0,0,c.width,c.height);let e=s.uniforms[1];e.value=.001*performance.now(),e.dirty=!0;let t=s.uniforms.filter((e=>e.dirty));for(let e in t)gl[t[e].type](t[e].location,t[e].value),t[e].dirty=!1;gl.drawArrays(gl.TRIANGLE_STRIP,0,4),gl.readPixels(0,0,1,1,gl.RGBA,gl.UNSIGNED_BYTE,s.pixel),requestAnimationFrame(h.render)};const init=async()=>{if(gl){const e="attribute vec2 p;void main(){gl_Position=vec4(p,1.0,1.0);}";h.initProgram(frag_shader_string,e),h.resize(),h.ix.set(c.width/2,c.height/2),h.render();for(let e of h.ix.events.start)d.addEventListener(e,h.ix.start);for(let e of h.ix.events.stop)d.addEventListener(e,h.ix.stop);window.addEventListener("resize",h.resize),appendSignature()}else{const e=d.createElement("div");e.style.cssText="align-items:center;background:#969696;color:#fff;display:flex;font-family:monospace;font-size:20px;height:100vh;justify-content:center;left:0;position:fixed;top:0;width:100vw;",e.innerHTML="Your browser does not support WebGL.",b.append(e)}};init();'
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
        return 'Limit';
    }

    function symbol() public view virtual returns (string memory) {
        return 'L';
    }

    function artpiece() public view virtual returns (string memory) {
        return string.concat(
            '<!DOCTYPE html>'
            '<html>'
                '<head>'
                    '<title>', 'Limit', '</title>'

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