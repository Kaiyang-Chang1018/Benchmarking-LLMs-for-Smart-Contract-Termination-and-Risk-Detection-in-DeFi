// o--o              o    
// |   |             |    
// O-Oo   o  o  o-o  O--o 
// |  \   |  |  \    |  | 
// o   o  o--o  o-o  o  o 
//
// SPDX-License-Identifier: MIT
// Copyright Han, 2023

pragma solidity ^0.8.25;

contract Rush {
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
        'It happens as it is supposed to.' '\n'
    );

    string public constant CORE = (
        '"use strict";let s={signature:"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjE2IiBoZWlnaHQ9IjIxNiIgdmlld0JveD0iMCAwIDIxNiAyMTYiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGZpbGwtcnVsZT0iZXZlbm9kZCIgY2xpcC1ydWxlPSJldmVub2RkIiBkPSJNMTg0LjYwOSAxNzIuMjc2TDE5MC43MzQgMTc3LjQyMkMyMDYuNSAxNTguNjUgMjE2IDEzNC40MzQgMjE2IDEwOEMyMTYgODEuNTY1OSAyMDYuNSA1Ny4zNTAxIDE5MC43MzQgMzguNTc4MUwxODQuNjA5IDQzLjcyMzZMMTc4LjQ4NCA0OC44Njg3QzE5MS45MjIgNjQuODY2MiAyMDAgODUuNDY4OCAyMDAgMTA4QzIwMCAxMzAuNTMxIDE5MS45MjIgMTUxLjEzNCAxNzguNDg0IDE2Ny4xMzFMMTg0LjYwOSAxNzIuMjc2Wk0xNzIuMjczIDMxLjM5MDZMMTc3LjQyMiAyNS4yNjQ2QzE1OC42NDggOS40OTY1OCAxMzQuNDM4IDAgMTA4IDBDODEuNTYyNSAwIDU3LjM1MTYgOS40OTY1OCAzOC41NzgxIDI1LjI2NDZMNDMuNzI2NiAzMS4zOTA2TDQ4Ljg2NzIgMzcuNTE2MUM2NC44NjcyIDI0LjA3OTEgODUuNDY4OCAxNiAxMDggMTZDMTMwLjUzMSAxNiAxNTEuMTMzIDI0LjA3OTEgMTY3LjEzMyAzNy41MTYxTDE3Mi4yNzMgMzEuMzkwNlpNMCAxMDhDMCA4MS41NjU5IDkuNSA1Ny4zNTAxIDI1LjI2NTYgMzguNTc4MUwzMS4zOTA2IDQzLjcyMzZMMzcuNTE1NiA0OC44Njg3QzI0LjA3ODEgNjQuODY2MiAxNiA4NS40Njg4IDE2IDEwOEMxNiAxMzAuNTMxIDI0LjA3ODEgMTUxLjEzNCAzNy41MTU2IDE2Ny4xMzFMMzEuMzkwNiAxNzIuMjc2TDI1LjI2NTYgMTc3LjQyMkM5LjUgMTU4LjY1IDAgMTM0LjQzNCAwIDEwOFpNNDMuNzI2NiAxODQuNjA5TDM4LjU3ODEgMTkwLjczNUM1Ny4zNTE2IDIwNi41MDMgODEuNTYyNSAyMTYgMTA4IDIxNkMxMzQuNDM4IDIxNiAxNTguNjQ4IDIwNi41MDMgMTc3LjQyMiAxOTAuNzM1TDE3Mi4yNzMgMTg0LjYwOUwxNjcuMTMzIDE3OC40ODRDMTUxLjEzMyAxOTEuOTIxIDEzMC41MzEgMjAwIDEwOCAyMDBDODUuNDY4OCAyMDAgNjQuODY3MiAxOTEuOTIxIDQ4Ljg2NzIgMTc4LjQ4NEw0My43MjY2IDE4NC42MDlaTTEyMCA5Nkg5NlYxMjBIMTIwVjk2WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+Cg==",mouse_sensitivity:.2,mouse_limit:.4,frame:0,res:[0,0]};window.h={newline:String.fromCharCode(10),parser:new URL(window.location)};const mobile=/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);let w=window,d=document,b=d.body;d.body.style.touchAction="none",d.body.style.userSelect="none";let c=d.createElement("canvas");c.style.display="block",b.appendChild(c);const image=d.createElement("img");image.src=s.signature.trim(),image.style.cssText="width:40px;z-index:50;position:fixed;bottom:20px;right:20px;",b.appendChild(image);const CREDITS="I am grateful to Dima, WillStall, and Inigo Quilez (smin_exp, sphere and box intersect) for making this piece possible, you are wizards. - Han";console.log(CREDITS);const glOptions={powerPreference:"high-performance"};mobile&&delete glOptions.powerPreference,w.gl=c.getContext("webgl2",glOptions),h.uniform1i=(e,t)=>h.uniform(e,t,"uniform1i"),h.uniform=(e,t,i)=>{s.uniforms||={};(s.uniforms[e]||=(()=>{const o=gl.getUniformLocation(s.current_program,e),r=i||(Array.isArray(t)?"uniform2fv":"uniform1f");return{update:e=>gl[r](o,e)}})()).update(t)},h.resize=()=>{let e,t,i,o={x:h.ix.mouse.x/s.res[0],y:h.ix.mouse.y/s.res[1]};e=w.innerWidth,t=w.innerHeight,s.aspect&&(e>t*s.aspect?e=t*s.aspect:t=e/s.aspect),i=w.devicePixelRatio,s.res[0]=c.width=e*i,s.res[1]=c.height=t*i,c.style.width=e+"px",c.style.height=t+"px",h.ix.set(c.width*o.x,c.height*o.y)},h.ix={start:{x:0,y:0},mouse:{x:0,y:0}},h.ix.set=(e,t)=>{h.ix.mouse={x:e,y:t}},h.ix.start=e=>{h.ix.start.x=e.clientX,h.ix.start.y=e.clientY,d.addEventListener("pointermove",h.ix.move)},h.clamp=(e,t,i)=>Math.max(t,Math.min(i,e)),h.ix.move=e=>{h.ix.mouse.x+=(e.clientX-h.ix.start.x)*window.devicePixelRatio*s.mouse_sensitivity,h.ix.mouse.y-=(e.clientY-h.ix.start.y)*window.devicePixelRatio*s.mouse_sensitivity,h.ix.start.x=e.clientX,h.ix.start.y=e.clientY,h.ix.mouse.x=h.clamp(h.ix.mouse.x,s.res[0]*s.mouse_limit,s.res[0]*(1-s.mouse_limit)),h.ix.mouse.y=h.clamp(h.ix.mouse.y,s.res[1]*s.mouse_limit,s.res[1]*(1-s.mouse_limit))},h.ix.stop=()=>{d.removeEventListener("pointermove",h.ix.move)},h.save={},h.save.toImage=()=>{const e=new Date;let t=String(e.getFullYear()).slice(2,4)+"-"+e.getMonth()+"-"+e.getDate()+" ("+s.frame+").png",i=document.createElement("a");i.setAttribute("download",t);let o=c.toDataURL("image/png").replace("data:image/png","data:application/octet-stream");i.setAttribute("href",o),i.click(),i.remove()},h.buildShader=(e,t)=>{let i=gl.createShader(e);return gl.shaderSource(i,t),gl.compileShader(i),i},h.initProgram=(e,t,i)=>{const o=gl.createProgram(),r=h.buildShader(gl.VERTEX_SHADER,t),n=h.buildShader(gl.FRAGMENT_SHADER,e);gl.attachShader(o,r),gl.attachShader(o,n),gl.linkProgram(o),gl.getShaderParameter(r,gl.COMPILE_STATUS)||console.error("V: "+gl.getShaderInfoLog(r)),gl.getShaderParameter(n,gl.COMPILE_STATUS)||console.error("F: "+gl.getShaderInfoLog(n)),gl.getProgramParameter(o,gl.LINK_STATUS)||console.error("P: "+gl.getProgramInfoLog(o));let s=gl.createBuffer(),a=gl.getAttribLocation(o,"p");return gl.bindBuffer(gl.ARRAY_BUFFER,s),gl.bufferData(gl.ARRAY_BUFFER,i,gl.STATIC_DRAW),gl.enableVertexAttribArray(a),gl.vertexAttribPointer(a,2,gl.FLOAT,!1,0,0),o};const p={balls:[]},hash3=e=>{const t=[Math.sin(e),Math.sin(e+1),Math.sin(e+2)],i=[43758.5453123,22578.1459123,19642.3490423];return t.map(((e,t)=>e*i[t]-Math.floor(e*i[t])))},length=e=>Math.sqrt(e.reduce(((e,t)=>e+t*t),0)),distance=(e,t)=>length(e.map(((e,i)=>e-t[i])));p.update=e=>{p.counts=new Float32Array(9),p.groups=new Float32Array(81);let t=e;t=2*Math.PI*t/10;for(let e=0;e<9;e++){const i=4*e;p.balls[e]=[2*Math.sin(p.u_noise_cache[i]+t),2*Math.sin(p.u_noise_cache[i+1]+t),2*Math.sin(p.u_noise_cache[i+2]+t)*.1,.4928]}console.log(),new Float32Array(9).fill(-1);let i=[];for(let e=0;e<9;e++){let t;for(let o of i)o.has(e)&&(t=o);t||(t=new Set,t.add(e),i.push(t));for(let o=0;o<9;o++)if(distance(p.balls[e],p.balls[o])<10){let e=!1;for(let r of i)if(r.has(o)&&r!==t){for(let e of t)r.add(e);i.splice(i.indexOf(t),1),t=r,e=!0;break}e||t.add(o)}}p.groups.fill(-1);for(let e=0;e<i.length;e++){let t=9*e;for(let o of i[e])p.groups[t]=o,t++}let o=new Float32Array(9);o.fill(-1);for(let e=0;e<9;e++)for(let t=0;t<i.length;t++)i[t].has(e)&&(o[e]=t);h.uniform("u_groups",p.groups,"uniform1iv"),h.uniform("u_group_indices",o,"uniform1iv")},s.pixel=new Uint8Array(4),h.render=()=>{gl.viewport(0,0,c.width,c.height),gl.useProgram(s.program),s.current_program=s.program;let e=.001*performance.now();p.update(e),h.uniform("u_time",e),h.uniform("u_resolution",s.res),h.uniform("u_mouse",[h.ix.mouse.x,h.ix.mouse.y]),gl.drawArrays(gl.TRIANGLE_STRIP,0,4),gl.readPixels(0,0,1,1,gl.RGBA,gl.UNSIGNED_BYTE,s.pixel),h.save.queued&&(h.save.queued=!1,h.save.toImage()),s.frame++,requestAnimationFrame(h.render)};const init=async()=>{if(gl){h.resize(),h.ix.set(c.width/2,c.height/2),d.addEventListener("pointerdown",h.ix.start),d.addEventListener("pointerup",h.ix.stop),w.addEventListener("resize",h.resize),d.addEventListener("keyup",(e=>{if(!(e.ctrlKey||e.altKey||e.shiftKey||e.metaKey)&&"s"===e.key)h.save.queued=!0}));let e=Float32Array.of(-1,1,-1,-1,1,1,1,-1);const t="#version 300 es"+h.newline+"precision highp float; in vec2 p; void main(){ gl_Position =vec4(p,1.0,1.0); }";let i="precision highp float;out vec4 fragColor;const int AA=2;const float v=acos(-1.)*2.;uniform vec2 u_resolution;uniform float u_time;uniform vec2 u_mouse;const vec3 f=vec3(1),i=vec3(.8);const vec3 n=vec3(0,0,-.56);int r;vec4 u[9];uniform vec4 u_noise_cache[9];uniform int u_groups[81],u_group_indices[9];vec3 t(){vec3 v=gl_FragCoord.xyy,f;v=vec3(dot(v,vec3(127.1,311.7,74.7)),dot(v,vec3(269.5,183.3,246.1)),dot(v,vec3(113.5,271.9,124.6)));f=-1.+2.*fract(sin(v)*43758.5453123);return fract(555.*sin(777.*f))/256.;}vec3 t(vec3 v){v+=t();return v;}vec2 t(vec3 v,vec3 y){vec3 f=1./y,i=f*v,x=abs(f)*(vec3(6)/2.),n=-i-x,u=-i+x;float m=max(max(n.x,n.y),n.z),A=min(min(u.x,u.y),u.z);return m>A||A<0.?vec2(-1):vec2(m,A);}float t(vec3 v,vec3 f,vec3 x,float A){float y=dot(f,f),i,r;vec3 u=v-x;i=2.*dot(f,u);r=dot(u,u)-A*A;return i*i-4.*y*r<0.?-1.:(-i-sqrt(i*i-4.*y*r))/(2.*y);}vec2 t(vec3 v,float f,int m){float i;i=1e2;for(int x=0;x<r;x++){int A=m*9+x,n=u_groups[A];if(n==-1)break;vec4 d=u[n];i=-log(exp(-3.5*i)+exp(-3.5*(length(d.xyz-v)-d.w/2.)))/3.5;}i-=.01;return vec2(i,1);}vec3 s(vec3 v,float f,int u){vec2 n=vec2(.001,0);vec3 i=t(v,f,u).x-vec3(t(v-n.xyy,f,u).x,t(v-n.yxy,f,u).x,t(v-n.yyx,f,u));return normalize(i);}vec2 s(vec3 v,vec3 f,float u,int i){float r=0.,n=-1.;for(int x=0;x<64;x++){vec3 m=v+f*r;vec2 d=t(m,u,i);n=d.y;r+=d.x;if(abs(d.x)<.009||r>1e2)break;}return vec2(r,n);}vec3 s(){return mix(i,f,.7);}void s(float v){for(int i=0;i<9;i++)u[i]=2.*sin(u_noise_cache[i]+v),u[i].z*=.1,u[i].w=.4928;}vec3 m(float v,vec3 u,vec3 m,vec3 y){float A=v*2.,r,x;vec3 d=n,z;d+=vec3(cos(A),sin(A),n.z)*2.;z=normalize(d-u);r=1.3*pow(1.-clamp(dot(m,-y),0.,1.),.7);r=max(0.,r);x=max(0.,dot(m,z))+r;return mix(i,f,x);}vec3 m(inout vec3 v,inout vec3 f,float u,float i,float x,float A,int y){s(u);vec2 n=s(v,f,u,y);vec3 r=v+n.x*f,d=s(r,u,y),z=s();if(n.x<1e2)z.x=m(i,r,d,f).x,z.y=m(x,r,d,f).y,z.z=m(A,r,d,f).z;return z;}vec3 m(float v,float f){float i=sin(f);return vec3(15.*i*cos(v),15.*cos(f),15.*i*sin(v));}mat3 s(vec3 v,vec2 f){vec3 u=normalize(vec3(0)-v),i=normalize(cross(vec3(0,floor(mod(f.y,2.))==0.?-1.:1.,0),u));return mat3(i,normalize(cross(u,i)),u);}void main(){float i=u_time,f,x,y,n,A;vec3 d=vec3(0),z,e;vec2 c=vec2(.5),g,a,k;c=u_mouse/u_resolution;f=(1.-c.y)*acos(-1.);x=c.x*v+acos(-1.)/2.;z=m(x,f);mat3 w=s(z,c);g=gl_FragCoord.xy;y=.5+.5*sin(g.x*147.)*sin(g.y*131.);n=.8*smoothstep(0.,1.,sin(v*i/10.));i+=0.;r=int(floor(9.));a=(gl_FragCoord.xy-.5*u_resolution.xy)*.442628884695583/min(u_resolution.x,u_resolution.y);e=normalize(w*vec3(a,1));k=t(z,e);fragColor=vec4(s(),1);if(k.x==-1.)return;s(v*i/10.);bool h=false;int l=-1;A=1e2;for(int b=0;b<r;b++){float C=t(z,e,u[b].xyz,u[b].w*1.45);if(C!=-1.){h=true;if(C<A)A=C,l=u_group_indices[b];}}if(l==-1&&h){fragColor=vec4(1);return;}if(!h)return;for(int b=0;b<AA;b++)for(int C=0;C<AA;C++){vec2 E=vec2(b,C)/float(AA)-.5,D=(gl_FragCoord.xy+E-.5*u_resolution.xy)*.442628884695583/min(u_resolution.x,u_resolution.y);vec3 B=normalize(w*vec3(D,1));float p=i-.05*(float(C*AA+b)+y)/float(AA*AA);d+=m(z,B,v*p/10.,v*(p-n)/10.,v*p/10.,v*(p+n)/10.,l);}d/=float(AA*AA);d=t(d);fragColor=vec4(d,1);}";if(i="#version 300 es"+h.newline+i,mobile){const e="const int AA=2";i=i.replace(e,"const int AA=1")}window.program=s.program=h.initProgram(i,t,e),p.count||=9,p.u_noise_cache=new Float32Array(4*p.count);for(let e=0;e<p.count;e++){let t=e/p.count,i=hash3(1.17*t);i[0]*=2*Math.PI,i[1]*=2*Math.PI,i[2]*=2*Math.PI,p.u_noise_cache[4*e]=i[0],p.u_noise_cache[4*e+1]=i[1],p.u_noise_cache[4*e+2]=i[2]}gl.useProgram(s.program);let o=gl.getUniformLocation(s.program,"u_noise_cache");gl.uniform4fv(o,p.u_noise_cache),h.render()}else{const e=d.createElement("div");e.style.cssText="align-items:center;background:#969696;color:#fff;display:flex;font-family:monospace;font-size:20px;height:100vh;justify-content:center;left:0;position:fixed;top:0;width:100vw;",e.innerHTML="Your browser does not support WebGL.",b.append(e)}};init();'
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
        return 'Rush';
    }

    function symbol() public view virtual returns (string memory) {
        return 'R';
    }

    function artpiece() public view virtual returns (string memory) {
        return string.concat(
            '<!DOCTYPE html>'
            '<html>'
                '<head>'
                    '<title>', 'Rush', '</title>'

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