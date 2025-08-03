// |) /\ \/\/ |\|
//
// SPDX-License-Identifier: MIT
// Copyright Han, 2023

pragma solidity ^0.8.21;

contract Dawn {
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
        'Life has a way.' '\n'
    );

    string public constant CORE = (
        '"use strict";const credits="wwwtyro sphere intersect";let s={signature:"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjE2IiBoZWlnaHQ9IjIxNiIgdmlld0JveD0iMCAwIDIxNiAyMTYiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGZpbGwtcnVsZT0iZXZlbm9kZCIgY2xpcC1ydWxlPSJldmVub2RkIiBkPSJNOCA4SDIwOFYyMDhIOFY4Wk0wIDIxNlYwSDIxNlYyMTZIMFpNOTkgMTE3SDExN1Y5OUg5OVYxMTdaTTkzIDkzVjEyM0gxMjNWOTNIOTNaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K",mouse_sensitivity:1,mouse_limit:0,color_offset_frames:60,frame:0,res:[0,0],save_frames:0},h={newline:String.fromCharCode(10),parser:new URL(window.location)};const mobile=/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);let w=window,d=document,b=d.body;d.body.style.touchAction="none",d.body.style.userSelect="none";let c=d.createElement("canvas");c.style.display="block",b.appendChild(c);const image=d.createElement("img");image.src=s.signature.trim(),image.style.cssText="width:40px;z-index:50;position:fixed;bottom:20px;right:20px;",b.appendChild(image);const glOptions={powerPreference:"high-performance"};mobile&&delete glOptions.powerPreference,w.gl=c.getContext("webgl2",glOptions),h.uniform1i=(e,t)=>h.uniform(e,t,"uniform1i"),h.uniform=(e,t,r)=>{s.uniforms||={};(s.uniforms[e]||=(()=>{const i=gl.getUniformLocation(s.current_program,e),o=r||(Array.isArray(t)?"uniform2fv":"uniform1f");return{update:e=>gl[o](i,e)}})()).update(t)},h.resize=()=>{let e,t,r,i={x:h.ix.mouse.x/s.res[0],y:h.ix.mouse.y/s.res[1]};const o=h.parser.searchParams.get("res",t);o?(e=t=o,r=1):(e=w.innerWidth,t=w.innerHeight,s.aspect&&(e>t*s.aspect?e=t*s.aspect:t=e/s.aspect),r=w.devicePixelRatio),s.res[0]=c.width=e*r,s.res[1]=c.height=t*r,c.style.width=e+"px",c.style.height=t+"px",h.ix.set(c.width*i.x,c.height*i.y)},h.ix={start:{x:0,y:0},mouse:{x:0,y:0}},h.ix.set=(e,t)=>{h.ix.mouse={x:e,y:t}},h.ix.start=e=>{h.ix.start.x=e.clientX,h.ix.start.y=e.clientY,d.addEventListener("pointermove",h.ix.move)},h.clamp=(e,t,r)=>Math.max(t,Math.min(r,e)),h.ix.move=e=>{h.ix.mouse.x+=(e.clientX-h.ix.start.x)*window.devicePixelRatio*s.mouse_sensitivity,h.ix.mouse.y-=(e.clientY-h.ix.start.y)*window.devicePixelRatio*s.mouse_sensitivity,h.ix.start.x=e.clientX,h.ix.start.y=e.clientY,h.ix.mouse.x=h.clamp(h.ix.mouse.x,s.res[0]*s.mouse_limit,s.res[0]*(1-s.mouse_limit)),h.ix.mouse.y=h.clamp(h.ix.mouse.y,s.res[1]*s.mouse_limit,s.res[1]*(1-s.mouse_limit))},h.ix.stop=()=>{d.removeEventListener("pointermove",h.ix.move)},h.save={},h.save.toImage=()=>{const e=new Date;let t=String(e.getFullYear()).slice(2,4)+"-"+e.getMonth()+"-"+e.getDate()+" ("+s.frame+").png",r=document.createElement("a");r.setAttribute("download",t);let i=c.toDataURL("image/png").replace("data:image/png","data:application/octet-stream");r.setAttribute("href",i),r.click(),r.remove()},h.buildShader=(e,t)=>{let r=gl.createShader(e);return gl.shaderSource(r,t),gl.compileShader(r),r},h.initProgram=(e,t,r)=>{const i=gl.createProgram(),s=h.buildShader(gl.VERTEX_SHADER,t),o=h.buildShader(gl.FRAGMENT_SHADER,e);gl.attachShader(i,s),gl.attachShader(i,o),gl.linkProgram(i),gl.getShaderParameter(s,gl.COMPILE_STATUS)||console.error("V: "+gl.getShaderInfoLog(s)),gl.getShaderParameter(o,gl.COMPILE_STATUS)||console.error("F: "+gl.getShaderInfoLog(o)),gl.getProgramParameter(i,gl.LINK_STATUS)||console.error("P: "+gl.getProgramInfoLog(i));let a=gl.createBuffer(),n=gl.getAttribLocation(i,"p");return gl.bindBuffer(gl.ARRAY_BUFFER,a),gl.bufferData(gl.ARRAY_BUFFER,r,gl.STATIC_DRAW),gl.enableVertexAttribArray(n),gl.vertexAttribPointer(n,2,gl.FLOAT,!1,0,0),i},s.pixel=new Uint8Array(4),h.render=()=>{gl.viewport(0,0,c.width,c.height),gl.useProgram(s.program),s.current_program=s.program,h.uniform("u_time",.01667*s.frame),h.uniform("u_resolution",s.res),h.uniform("u_mouse",[h.ix.mouse.x,h.ix.mouse.y]),gl.drawArrays(gl.TRIANGLE_STRIP,0,4),gl.readPixels(0,0,1,1,gl.RGBA,gl.UNSIGNED_BYTE,s.pixel),(h.save.queued||s.frame<s.save_frames&&s.frame>3)&&(h.save.queued=!1,h.save.toImage()),s.frame++,requestAnimationFrame(h.render)};const init=async()=>{if(gl){h.resize(),h.ix.set(c.width/2,c.height/2),d.addEventListener("pointerdown",h.ix.start),d.addEventListener("pointerup",h.ix.stop),w.addEventListener("resize",h.resize),s.save_frames=h.parser.searchParams.get("frames")||0,d.addEventListener("keyup",(e=>{if(!(e.ctrlKey||e.altKey||e.shiftKey||e.metaKey))switch(e.key){case"f":const e=prompt("Frames to render",s.save_frames);h.parser.searchParams.set("frames",e),window.location=h.parser.href;break;case"r":const t=prompt("Canvas size in pixels (max 8192)",c.height);t>=8&&t<=8192&&(h.parser.searchParams.set("res",t),window.location=h.parser.href);break;case"s":h.save.queued=!0}}));let e=Float32Array.of(-1,1,-1,-1,1,1,1,-1);const t="#version 300 es"+h.newline+"precision highp float; in vec2 p; void main(){ gl_Position =vec4(p,1.0,1.0); }";let r="precision highp float;out vec4 fragColor;const int AA=4;uniform vec2 u_resolution;uniform float u_time;uniform vec2 u_mouse;const vec3 v=vec3(.890196078431372),f=vec3(.749019607843137);const vec3 n=vec3(0,0,10);uniform float u_light_speed;float t(vec3 v,vec3 f,float A){float s=dot(f,f),u,r;vec3 i=v-vec3(0);u=2.*dot(f,i);r=dot(i,i)-A*A;return u*u-4.*s*r<0.?-1.:(-u-sqrt(u*u-4.*s*r))/(2.*s);}vec2 t(vec3 v,vec3 f,out vec3 u,float A,float i){float s=-1.,r,c;u=vec3(0);r=1e3;c=t(v,f,mix(.8,i,.5+.5*sin(A)));return c!=-1.?(s=1.,u=normalize(v+f*c-vec3(0)),vec2(c,s)):vec2(r,s);}vec3 t(){vec3 v=gl_FragCoord.xyy,f;v=vec3(dot(v,vec3(127.1,311.7,74.7)),dot(v,vec3(269.5,183.3,246.1)),dot(v,vec3(113.5,271.9,124.6)));f=-1.+2.*fract(sin(v)*43758.5453123);return fract(555.*sin(777.*f))/256.;}vec3 t(vec3 v){v+=t();return v;}vec3 s(inout vec3 u,inout vec3 s,float A,float i,float m){vec3 c,r,d,y;vec2 g=t(u,s,c,i,m),z;r=vec3(0);A*=10.;d=vec3(cos(A),sin(A),0)*10.;d.z=n.z;z=vec2(u_mouse/u_resolution);d.x+=(z.x-.5)*60.;d.y-=(z.y-.5)*60.;y=normalize(d-u-g.x*s);float o=1.;if(g.y==1.){float x=pow(1.-dot(c,-s),2.),e;x*=1.2;x=max(0.,x);e=max(0.,dot(c,y));e*=1.;o=e+x;}return mix(f,v,o);}vec3 s(float v,float A){float s=sin(A);return vec3(19.306*s*cos(v),19.306*cos(A),19.306*s*sin(v));}mat3 t(vec3 v,vec2 A){vec3 f=normalize(vec3(0)-v),s=normalize(cross(vec3(0,floor(mod(A.y,2.))==0.?-1.:1.,0),f));return mat3(s,normalize(cross(f,s)),f);}void main(){float v=u_time,f,r,A;vec3 u=vec3(0),c;vec2 i=vec2(.5),d;c=s(-2.*acos(-1.)*i.y-1.570795,i.x*3.14159);mat3 x=t(c,i);d=gl_FragCoord.xy;f=.5+.5*sin(d.x*147.)*sin(d.y*131.);r=2.*smoothstep(0.,1.,sin(2.*acos(-1.)*v/90.));v+=100.98;A=5.685;for(int y=0;y<AA;y++)for(int m=0;m<AA;m++){vec2 o=vec2(y,m)/float(AA)-.5,z=(gl_FragCoord.xy+o-.5*u_resolution.xy)*.616836022204993/min(u_resolution.x,u_resolution.y);vec3 e=normalize(x*vec3(z,1));float a=v-.2*(float(m*AA+y)+f)/float(AA*AA),n,g=n=2.*acos(-1.)*a/180.;n=2.*acos(-1.)*(a-r)/180.;u.x+=s(c,e,n,g,A).x;n=2.*acos(-1.)*a/180.;u.y+=s(c,e,n,g,A).y;n=2.*acos(-1.)*(a+r)/180.;u.z+=s(c,e,n,g,A).z;}u/=float(AA*AA);u=t(u);fragColor=vec4(u,1);}";if(r="#version 300 es"+h.newline+r,mobile){const e="const int AA=4";r=r.replace(e,"const int AA=1")}window.program=s.program=h.initProgram(r,t,e),h.render()}else{const e=d.createElement("div");e.style.cssText="align-items:center;background:#969696;color:#fff;display:flex;font-family:monospace;font-size:20px;height:100vh;justify-content:center;left:0;position:fixed;top:0;width:100vw;",e.innerHTML="Your browser does not support WebGL.",b.append(e)}};init();'
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
        return 'Dawn';
    }

    function symbol() public view virtual returns (string memory) {
        return 'D';
    }

    function artpiece() public view virtual returns (string memory) {
        return string.concat(
            '<!DOCTYPE html>'
            '<html>'
                '<head>'
                    '<title>', 'Dawn', '</title>'

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