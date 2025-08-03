// .  .   .  .          .         .              . 
//  \  \ /  /           |         |              | 
//   \  \  /.-. .--. .-.| .-. .--.| .-.  .--. .-.| 
//    \/ \/(   )|  |(   |(.-' |   |(   ) |  |(   | 
//     ' '  `-' '  `-`-'`-`--''   `-`-'`-'  `-`-'`-
//
// SPDX-License-Identifier: MIT
// Copyright Han, 2023

pragma solidity ^0.8.25;

contract Wonderland {
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
        'Wake up.' '\n'
    );

    string public constant CORE = (
        '"use strict";let s={signature:"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjE2IiBoZWlnaHQ9IjIxNiIgdmlld0JveD0iMCAwIDIxNiAyMTYiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGQ9Ik0xMjAgOTZIOTZWMTIwSDEyMFY5NloiIGZpbGw9IndoaXRlIi8+CjxwYXRoIGZpbGwtcnVsZT0iZXZlbm9kZCIgY2xpcC1ydWxlPSJldmVub2RkIiBkPSJNMjE2IDEwOEMyMTYgMTY3LjY0OCAxNjcuNjQ4IDIxNiAxMDggMjE2QzQ4LjM1MTYgMjE2IDAgMTY3LjY0OCAwIDEwOEMwIDQ4LjM1MTYgNDguMzUxNiAwIDEwOCAwQzE2Ny42NDggMCAyMTYgNDguMzUxNiAyMTYgMTA4Wk0yMDAgMTA4QzIwMCAxNTguODA5IDE1OC44MDkgMjAwIDEwOCAyMDBDNTcuMTkxNCAyMDAgMTYgMTU4LjgwOSAxNiAxMDhDMTYgNTcuMTkxNCA1Ny4xOTE0IDE2IDEwOCAxNkMxNTguODA5IDE2IDIwMCA1Ny4xOTE0IDIwMCAxMDhaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K",mouse_sensitivity:.6,mouse_limit:0,frame:0,res:[0,0],save_frames:0};window.h={newline:String.fromCharCode(10),parser:new URL(window.location)};const mobile=/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);let w=window,d=document,b=d.body;d.body.style.touchAction="none",d.body.style.userSelect="none";let c=d.createElement("canvas");c.style.display="block",b.appendChild(c);const image=d.createElement("img");image.src=s.signature.trim(),image.style.cssText="width:40px;z-index:50;position:fixed;bottom:20px;right:20px;",b.appendChild(image);const CREDITS="I am grateful to Dima, WillStall, and IQ (sdf), Demofox (Refraction) for making this piece possible, you are wizards. - Han";console.log(CREDITS);const glOptions={powerPreference:"high-performance"};mobile&&delete glOptions.powerPreference,w.gl=c.getContext("webgl2",glOptions),h.uniform1i=(e,t)=>h.uniform(e,t,"uniform1i"),h.uniform=(e,t,r)=>{s.uniforms||={};(s.uniforms[e]||=(()=>{const i=gl.getUniformLocation(s.current_program,e),o=r||(Array.isArray(t)?"uniform2fv":"uniform1f");return{update:e=>gl[o](i,e)}})()).update(t)},h.resize=()=>{let e,t,r,i={x:h.ix.mouse.x/s.res[0],y:h.ix.mouse.y/s.res[1]};const o=h.parser.searchParams.get("res",t);o?(e=t=o,r=1):(e=w.innerWidth,t=w.innerHeight,s.aspect&&(e>t*s.aspect?e=t*s.aspect:t=e/s.aspect),r=w.devicePixelRatio),s.res[0]=c.width=e*r,s.res[1]=c.height=t*r,c.style.width=e+"px",c.style.height=t+"px",h.ix.set(c.width*i.x,c.height*i.y)},h.ix={start:{x:0,y:0},mouse:{x:0,y:0}},h.ix.set=(e,t)=>{h.ix.mouse={x:e,y:t}},h.ix.start=e=>{h.ix.start.x=e.clientX,h.ix.start.y=e.clientY,d.addEventListener("pointermove",h.ix.move)},h.clamp=(e,t,r)=>Math.max(t,Math.min(r,e)),h.ix.move=e=>{h.ix.mouse.x+=(e.clientX-h.ix.start.x)*window.devicePixelRatio*s.mouse_sensitivity,h.ix.mouse.y-=(e.clientY-h.ix.start.y)*window.devicePixelRatio*s.mouse_sensitivity,h.ix.start.x=e.clientX,h.ix.start.y=e.clientY,h.ix.mouse.x=h.clamp(h.ix.mouse.x,s.res[0]*s.mouse_limit,s.res[0]*(1-s.mouse_limit)),h.ix.mouse.y=h.clamp(h.ix.mouse.y,s.res[1]*s.mouse_limit,s.res[1]*(1-s.mouse_limit))},h.ix.stop=()=>{d.removeEventListener("pointermove",h.ix.move)},h.save={},h.save.toImage=()=>{const e=new Date;let t=String(e.getFullYear()).slice(2,4)+"-"+e.getMonth()+"-"+e.getDate()+" ("+s.frame+").png",r=document.createElement("a");r.setAttribute("download",t);let i=c.toDataURL("image/png").replace("data:image/png","data:application/octet-stream");r.setAttribute("href",i),r.click(),r.remove()},h.buildShader=(e,t)=>{let r=gl.createShader(e);return gl.shaderSource(r,t),gl.compileShader(r),r},h.initProgram=(e,t,r)=>{const i=gl.createProgram(),o=h.buildShader(gl.VERTEX_SHADER,t),a=h.buildShader(gl.FRAGMENT_SHADER,e);gl.attachShader(i,o),gl.attachShader(i,a),gl.linkProgram(i),gl.getShaderParameter(o,gl.COMPILE_STATUS)||console.error("V: "+gl.getShaderInfoLog(o)),gl.getShaderParameter(a,gl.COMPILE_STATUS)||console.error("F: "+gl.getShaderInfoLog(a)),gl.getProgramParameter(i,gl.LINK_STATUS)||console.error("P: "+gl.getProgramInfoLog(i));let s=gl.createBuffer(),c=gl.getAttribLocation(i,"p");return gl.bindBuffer(gl.ARRAY_BUFFER,s),gl.bufferData(gl.ARRAY_BUFFER,r,gl.STATIC_DRAW),gl.enableVertexAttribArray(c),gl.vertexAttribPointer(c,2,gl.FLOAT,!1,0,0),i},s.pixel=new Uint8Array(4),h.render=()=>{gl.viewport(0,0,c.width,c.height),gl.useProgram(s.program),s.current_program=s.program,s.frame<s.save_frames?h.uniform("u_time",.01667*s.frame):h.uniform("u_time",.001*performance.now()),h.uniform("u_resolution",s.res),h.uniform("u_mouse",[h.ix.mouse.x,h.ix.mouse.y]),gl.drawArrays(gl.TRIANGLE_STRIP,0,4),gl.readPixels(0,0,1,1,gl.RGBA,gl.UNSIGNED_BYTE,s.pixel),(h.save.queued||s.frame<s.save_frames&&s.frame>3)&&(h.save.queued=!1,h.save.toImage()),s.frame++,requestAnimationFrame(h.render)};const init=async()=>{if(gl){h.resize(),h.ix.set(c.width/2,c.height/2),d.addEventListener("pointerdown",h.ix.start),d.addEventListener("pointerup",h.ix.stop),w.addEventListener("resize",h.resize),s.save_frames=h.parser.searchParams.get("frames")||0,d.addEventListener("keyup",(e=>{if(!(e.ctrlKey||e.altKey||e.shiftKey||e.metaKey))switch(e.key){case"f":const e=prompt("Frames to render",s.save_frames);h.parser.searchParams.set("frames",e),window.location=h.parser.href;break;case"r":const t=prompt("Canvas size in pixels (max 8192)",c.height);t>=8&&t<=8192&&(h.parser.searchParams.set("res",t),window.location=h.parser.href);break;case"s":h.save.queued=!0}}));let e=Float32Array.of(-1,1,-1,-1,1,1,1,-1);const t="#version 300 es"+h.newline+"precision highp float; in vec2 p; void main(){ gl_Position =vec4(p,1.0,1.0); }";let r="precision highp float;out vec4 fragColor;const int AA=2;uniform vec2 u_resolution;uniform float u_time;uniform vec2 u_mouse;const vec3 v=vec3(.909803921568627),f=vec3(.8);const vec3 d=vec3(0,0,-.2);vec3 t(){vec3 v=gl_FragCoord.xyy,f;v=vec3(dot(v,vec3(127.1,311.7,74.7)),dot(v,vec3(269.5,183.3,246.1)),dot(v,vec3(113.5,271.9,124.6)));f=-1.+2.*fract(sin(v)*43758.5453123);return fract(555.*sin(777.*f))/256.;}vec3 t(vec3 v){v+=t();return v;}float s(vec2 v){return fract(sin(dot(v.xy,vec2(12.9898,78.233)))*43758.5453123);}vec3 s(vec3 v,vec4 f){return v+2.*cross(f.xyz,cross(f.xyz,v)+v*f.w);}vec3 t(vec3 v,float f){return s(v,vec4(sin(f/2.),0,0,cos(f/2.)));}vec3 n(vec3 v,float f){return s(v,vec4(0,sin(f/2.),0,cos(f/2.)));}vec3 m(vec3 v,float f){return s(v,vec4(0,0,sin(f/2.),cos(f/2.)));}float m(vec3 v,vec3 f,vec3 m){vec3 i=v-f,x=m-f;return length(i-x*clamp(dot(i,x)/dot(x,x),0.,1.))-.4;}float n(vec3 v,vec3 f,vec3 m){vec3 x=m-f,d=v-f;float y=dot(x,x),s=dot(d,x),c=length(d*y-x*s)-8.*y,a=abs(s-y*.5)-y*.5,i=c*c,o=a*a*y,A=max(c,a)<0.?-min(i,o):(c>0.?i:0.)+(a>0.?o:0.);return sign(A)*sqrt(abs(A))/y;}vec2 x(vec2 v,float f){vec2 i;float y=s(v)-.5;i.x=2.*acos(-1.)*y;i.y=1.+round(s(v)*(f-1.));i.y*=2.*mod(round(y*10.),2.)-1.;return i;}void m(float v,vec2 f,out vec3 i,out vec3 d,out float r){vec2 u=u_mouse.xy/u_resolution.xy,y;u-=.5;v+=u.x*10.;v-=u.y*5.;float c=f.x+f.y*6.,o,A;y=vec2(c,c*-.5);r=sin(v+2.*acos(-1.)*s(y)-3.14159)*.2;o=cos(v*round(3.))*.2;A=sin(v*round(3.))*.2;i=vec3(o,-.3705,A);d=vec3(-o,.3705,-A);{vec2 a=x(y,2.);i=t(i,v*a.y+a.x);d=t(d,v*a.y+a.x);}{vec2 a=x(y*.75,1.);i=n(i,v*a.y+a.x);d=n(d,v*a.y+a.x);}{vec2 a=x(y*.55,1.);i=m(i,v*a.y+a.x);d=m(d,v*a.y+a.x);}i.y+=r;d.y+=r;}vec2 s(vec3 v,float f,vec2 x){float i=1e3,y,d,o,r,c,A;vec3 s,a,u;m(f,x,s,a,y);d=m(v,s,a);s+=10.*(s-a);u=vec3(0,y,0);o=n(v,u,s);r=max(d,o);i=min(i,r);c=max(-r,d);i=min(i,c);A=0.;if(i==r)A=1.;else if(i==c)A=2.;return vec2(i,A);}vec2 m(vec3 v,vec3 f,float i,vec2 x){float y=0.,r=-1.;for(int d=0;d<32;d++){vec3 c=v+f*y;vec2 a=s(c,i,x);r=a.y;y+=a.x*-1.;if(abs(a.x)<.001||y>1e3)break;}return vec2(y,r);}float n(vec3 v,vec3 f,vec3 i,vec3 y,out float x){vec3 d=y-i,c=v-i;float a=dot(d,d),s=dot(d,f),A=dot(d,c),o=a-s*s,r=a*dot(f,c)-A*s,u=a*dot(c,c)-A*A-.16*a,m=r*r-o*u;if(m>=0.){float n=(-r-sqrt(m))/o,g=A+n*s;if(g>0.&&g<a)return x=g<a/2.?0.:1.,n;vec3 z=g<=0.?c:v-y;r=dot(f,z);u=dot(z,z)-.16;m=r*r-u;if(m>0.)return x=g<=0.?0.:1.,-r-sqrt(m);}return-1.;}vec3 t(vec3 v,vec3 f,vec3 x){vec3 i=x-f,d=v-f;return(d-clamp(dot(d,i)/dot(i,i),0.,1.)*i)/.4;}vec2 s(vec3 v,vec3 f,float i,vec2 d,out vec3 x){float c=1e3,y,o,r;vec3 s,A;m(i,d,s,A,y);r=n(v,f,s,A,o);if(r>0.)x=t(v+r*f,s,A),c=r;return vec2(c,o);}vec3 m(){return mix(f,v,1.);}float i(vec3 v,vec3 f){float y=-.2/2.2,i,d;y*=y;i=-dot(f,v);d=1.-i;return y+(1.-y)*pow(d,5.);}vec3 i(vec3 v,vec3 f,vec3 i,float d,vec2 x){f=refract(f,i,1./1.2);v+=-i*.01*1.5;vec2 a=m(v,f,d,x);return a.x<0.?vec3(1,0,0):m()*exp(-vec3(.33)*a.x);}vec3 t(inout vec3 y,inout vec3 x,float a,float c,vec2 o){vec3 A,r,u;vec2 n=s(y,x,c,o,A),z=n;r=y+z.x*x;u=m();if(z.x<1e3){float g=c*2.,e,k;vec3 h=d,t;h+=vec3(cos(g),sin(g),d.z)*8.;t=normalize(h-r);e=max(0.,dot(A,t));k=3.*pow(1.-clamp(dot(A,-x),0.,1.),1.35);k=max(0.,k);if(z.y==0.){u=vec3(e+k);vec3 l=i(r,x,A,c,o);float p=clamp(i(x,A),0.,1.);u+=mix(l,f,p);u=mix(f,v,u.x);}else if(z.y==1.)u=mix(f,v,e+k);}return u;}vec3 p(float v,float f){float a=sin(f);return vec3(21.78*a*cos(v),21.78*cos(f),21.78*a*sin(v));}mat3 r(vec3 v,vec2 f){vec3 i=normalize(vec3(0)-v),d=normalize(cross(vec3(0,floor(mod(f.y,2.))==0.?-1.:1.,0),i));return mat3(d,normalize(cross(i,d)),i);}void main(){float v=u_time,f,i,d,x;vec3 y=vec3(0),c;vec2 a=vec2(.5),A;a=vec2(0);f=(1.-a.y)*3.14159;i=2.*acos(-1.)*a.x+1.570795;c=p(i,f);c=vec3(0,0,21.78);mat3 u=r(c,a);A=gl_FragCoord.xy;d=.5+.5*sin(A.x*147.)*sin(A.y*131.);x=.3*smoothstep(0.,1.,sin(2.*acos(-1.)*v/5.));v+=0.;for(int o=0;o<AA;o++)for(int s=0;s<AA;s++){vec2 n=gl_FragCoord.xy;n=(n-.5*u_resolution.xy)/min(u_resolution.x,u_resolution.y);if(abs(n.x)<.42669&&abs(n.y)<.42669){n=(n+.42669)/.85338*6.;vec2 z=floor(vec2(n)),e;n=fract(n)-.5;e=n*.115441447619942;vec3 g=normalize(u*vec3(e,1));float h=v-.15*(float(s*AA+o)+d)/float(AA*AA),k,l=k=2.*acos(-1.)*h/5.;k=2.*acos(-1.)*(h-x)/5.;y.x+=t(c,g,l,k,z).x;k=2.*acos(-1.)*h/5.;y.y+=t(c,g,l,k,z).y;k=2.*acos(-1.)*(h+x)/5.;y.z+=t(c,g,l,k,z).z;}else y+=m();}y/=float(AA*AA);y=t(y);fragColor=vec4(y,1);}";if(r="#version 300 es"+h.newline+r,mobile){const e="const int AA=2";r=r.replace(e,"const int AA=1")}window.program=s.program=h.initProgram(r,t,e),h.render()}else{const e=d.createElement("div");e.style.cssText="align-items:center;background:#969696;color:#fff;display:flex;font-family:monospace;font-size:20px;height:100vh;justify-content:center;left:0;position:fixed;top:0;width:100vw;",e.innerHTML="Your browser does not support WebGL.",b.append(e)}};init();'
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
        return 'Wonderland';
    }

    function symbol() public view virtual returns (string memory) {
        return 'W';
    }

    function artpiece() public view virtual returns (string memory) {
        return string.concat(
            '<!DOCTYPE html>'
            '<html>'
                '<head>'
                    '<title>', 'Wonderland', '</title>'

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