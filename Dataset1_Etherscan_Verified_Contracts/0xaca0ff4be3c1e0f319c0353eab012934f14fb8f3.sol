//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

// In the tx 0xe474bba90d66465dfbc5ee935f77f4a1ca7e0838960054926727e763e08c0c67 a frontrun of a Mindx Rug happened.
// Due to the weird circumstances surrounding the original transaction I've decided that a direct permissionless refund makes more sense.
// The refund will remain open for a few months, after that point I will reposess the remaining assets. One can reach out via Etherscan / Blockscan and I will manually refund once that point has passed.

contract MindxFrontrunRedistribution {
    address constant owner_ = 0xC0ffeEBABE5D496B2DDE509f9fa189C25cF29671;
    mapping (address => bool) public claimed_;

    // 85.10530732 ETH, distributed to all presale buyers, early sellers have had their relative refund reduced to get an equal % refund to non sellers.
    // Its 85.10530732 ETH because of a ~ 5 ETH bribe, aswell as sellers that got out more than their investment when the first presale launched. 
    function claim_presale_refund() external {
        uint amount;
        if (msg.sender == address(0x0080d7b4627fbee05ecccb6cff65ee1eb4f7e34d96)) {amount = 0.32675399 ether;}
        else if (msg.sender == address(0x0046828c44998e29673b81436f34c9594be005da21)) {amount = 0.367721467 ether; }
        else if (msg.sender == address(0x007e0b2a128bb5265fd102214ab502dbee41f03844)) {amount = 0.000736166 ether; }
        else if (msg.sender == address(0x000cdfc1cb26564c08ff1439ebfe9d029b789cc2e1)) {amount = 0.830709792 ether; }
        else if (msg.sender == address(0x0044329e36038ae0df5838a2bfa93512024beec917)) {amount = 0.045772175 ether; }
        else if (msg.sender == address(0x001f62671d9f4233c2bd9261031505278a4d99b3e8)) {amount = 0.015658077 ether; }
        else if (msg.sender == address(0x005bcc365fc3a5326e7482013eadbe26c78b8f86e5)) {amount = 0.156171619 ether; }
        else if (msg.sender == address(0x002e0eb501bc66509658b90dfdc2b8589bf436c172)) {amount = 0.023941059 ether; }
        else if (msg.sender == address(0x0040acc7e68506df38aaf8f8216d2fb2aeb98c8759)) {amount = 1.091119763 ether; }
        else if (msg.sender == address(0x0014ba6e40d942aef168c4eff4b433340789fe59f0)) {amount = 1.355797403 ether; }
        else if (msg.sender == address(0x001f7087c052dd6786f2d40b2eb3f06ff7523d3f93)) {amount = 0.111462629 ether; }
        else if (msg.sender == address(0x003739cf6de9d491e6fa4f136a0f6886577e4bfffd)) {amount = 0.184322111 ether; }
        else if (msg.sender == address(0x00bc9cfc2b994105f9d661b4b763b9e25af45b4091)) {amount = 0.162204294 ether; }
        else if (msg.sender == address(0x001e74fa6c928fc80104ba4553d30549458f7c21b5)) {amount = 0.147458585 ether; }
        else if (msg.sender == address(0x0056da861948c7ca193470be07979011db18a6cce6)) {amount = 1.452466539 ether; }
        else if (msg.sender == address(0x00b24c841b71f59f56b789dd35ce7dd69c8bf60685)) {amount = 1.400855811 ether; }
        else if (msg.sender == address(0x00511a5f06cc3418fc348785d37435561cd1f039d7)) {amount = 1.452466539 ether; }
        else if (msg.sender == address(0x00f454c632a8c40406052d30e2b303ede3ec9d6307)) {amount = 0.715173615 ether; }
        else if (msg.sender == address(0x004b2f2b5e8ac86531a19f19f101eb9c4d053c5e44)) {amount = 1.459838647 ether; }
        else if (msg.sender == address(0x00459592f69d20ba4ed03b9b4c4e5fbd565d2a2dd5)) {amount = 1.400855811 ether; }
        else if (msg.sender == address(0x003cf33d79775b4e4e9b016e6ec5bd2a396260c44a)) {amount = 1.286575445 ether; }
        else if (msg.sender == address(0x0084dc7e87e97e8799926262b368c749b27ec24626)) {amount = 1.349245082 ether; }
        else if (msg.sender == address(0x00cb58e5b910d260aa1e6cf55fecc5261868cca570)) {amount = 0.014745709 ether; }
        else if (msg.sender == address(0x009df1e271c6a5fdf4bc37c3e3f4b4f3cd200e2878)) {amount = 1.021219875 ether; }
        else if (msg.sender == address(0x00658dfe94028a2760dda5080631084990a0d8c2b7)) {amount = 0.11165675 ether; }
        else if (msg.sender == address(0x00717f061d65ba4b2cf5b3058fafb274539129a736)) {amount = 1.400855811 ether; }
        else if (msg.sender == address(0x006df9d46e086c0bcbf6334e224fb428b376c7bca3)) {amount = 0.737292925 ether; }
        else if (msg.sender == address(0x00a8de82fe34c02c25a3c03263f1a464d12d86f396)) {amount = 0.88475151 ether; }
        else if (msg.sender == address(0x000940da0c7686ff3fe35fe7642cb58a4de334f80f)) {amount = 0.073728546 ether; }
        else if (msg.sender == address(0x009c61216b8467a768d8e949b05f622e1363bd8da9)) {amount = 0.07520237 ether; }
        else if (msg.sender == address(0x00da849368c5a78c1c8896a0043e1de84768ee4eef)) {amount = 1.47458585 ether; }
        else if (msg.sender == address(0x005b466b4ac7f22dfaaeabe19d2aea50d1e3453fa4)) {amount = 1.176718045 ether; }
        else if (msg.sender == address(0x0044fffdc19e9ba41d02a2c2d4be382d249c8a4aac)) {amount = 0.265422765 ether; }
        else if (msg.sender == address(0x008998f4ebd339407406df9690a4c2922937c2ce3e)) {amount = 0.081102147 ether; }
        else if (msg.sender == address(0x00bb7f47752412a932bd801a807703a08231a3dba8)) {amount = 0.368645716 ether; }
        else if (msg.sender == address(0x000aba1505e3c3ba3826e73c08282cf5dfae45a834)) {amount = 0.368645716 ether; }
        else if (msg.sender == address(0x00d5890765ad970cc6f0430eb350dec7aa2bfd1d7b)) {amount = 1.47458585 ether; }
        else if (msg.sender == address(0x0055ec8bd6c80ea86b22a70eb47de84e2839bbb1ae)) {amount = 0.191695713 ether; }
        else if (msg.sender == address(0x0069d5f2c1ab0ec8c6f0d96993c8c3fc7891eba20a)) {amount = 0.294915677 ether; }
        else if (msg.sender == address(0x0092f98d868624403dcb5a484d8f2d033f5717800f)) {amount = 0.048660094 ether; }
        else if (msg.sender == address(0x00a8259961e6da8aaa2bdc5a25c536f5e4b2b5dbff)) {amount = 2.413159571 ether; }
        else if (msg.sender == address(0x004466f7ceb3fa64ea3b245061263078ceab1ffe9b)) {amount = 1.459837154 ether; }
        else if (msg.sender == address(0x0069cdaebb6a6ef4945e44a66976c68e7b667b8857)) {amount = 1.452466539 ether; }
        else if (msg.sender == address(0x0007104d4c02ab2dbbc6483ea1b30dd96c183391ab)) {amount = 0.833133315 ether; }
        else if (msg.sender == address(0x008976dbdd9bc93216c8fc5edda9a5f163b599427b)) {amount = 0.58983434 ether; }
        else if (msg.sender == address(0x003a335085e6d79a0a3bee0fddbd3b932e61d0d8a0)) {amount = 0.003685307 ether; }
        else if (msg.sender == address(0x0016be8a14eac37b9b11a6eb41c7063d6ad61b2b0e)) {amount = 0.054925713 ether; }
        else if (msg.sender == address(0x0041f2feb660ef5cf84ea1549908723faa65c4ee47)) {amount = 0.626697866 ether; }
        else if (msg.sender == address(0x000ff1256561f7d66c04f99db61b3c51ef32ceb18d)) {amount = 1.467212249 ether; }
        else if (msg.sender == address(0x00d76387b9e05850e3dc7ed5918bec0b1025a37983)) {amount = 0.55296932 ether; }
        else if (msg.sender == address(0x00995a965786a2d454a89b0558baf66d9174c628d2)) {amount = 2.433065906 ether; }
        else if (msg.sender == address(0x00114c175b44b8be9a17583112518082b229d3fb7a)) {amount = 1.033683919 ether; }
        else if (msg.sender == address(0x002c4eedc71d1d745a60ed8a80f80eb6bdd50521d5)) {amount = 0.184322111 ether; }
        else if (msg.sender == address(0x001ef6cbe29ea8139dcb4dc06e40c36d17839217aa)) {amount = 0.007372108 ether; }
        else if (msg.sender == address(0x00562afd5f606740f16302862a519b151a7ada5dc4)) {amount = 0.077413853 ether; }
        else if (msg.sender == address(0x00ab052d13ea924263793529369a63498a93f4cd41)) {amount = 0.088474255 ether; }
        else if (msg.sender == address(0x007f516c044901faa3025af7ee88537ba9372be9f3)) {amount = 1.363990791 ether; }
        else if (msg.sender == address(0x006c5730b9d3495b11285539ceb6b354db3a6d954e)) {amount = 9.547938524 ether; }
        else if (msg.sender == address(0x00dcfbc1cdb108eccf64bde41c57a7c5b1afe48005)) {amount = 1.069073621 ether; }
        else if (msg.sender == address(0x00c0976d038c587e5debe8058218fab2354fbe2d91)) {amount = 2.204505173 ether; }
        else if (msg.sender == address(0x0011200917c834c34f639676f5357571035fc9fd16)) {amount = 0.925300344 ether; }
        else if (msg.sender == address(0x00455e0f335d67e2536936358e93de094297631594)) {amount = 1.467212249 ether; }
        else if (msg.sender == address(0x00b8f41a1d4d627ac022b4ea232f590a21b4c8cab3)) {amount = 1.835857964 ether; }
        else if (msg.sender == address(0x00745813178f2f9fedf47d3cdc486a709030dd275f)) {amount = 0.870004307 ether; }
        else if (msg.sender == address(0x008b2bfd6c290d714bd34f45fd47266cd88c6d7457)) {amount = 0.951106455 ether; }
        else if (msg.sender == address(0x005df07cda7e911cfa718395fc9f773a8559e7b8a9)) {amount = 0.051609235 ether; }
        else if (msg.sender == address(0x00d3ed5e1df9dac44e5e143b7c281d34adf9312cfa)) {amount = 2.573150889 ether; }
        else if (msg.sender == address(0x00529ae7d67441ae6e032da6499d6fb81e9f37a504)) {amount = 1.422975121 ether; }
        else if (msg.sender == address(0x003e2ff89472d972591ea808d8cc85b1ec778ae187)) {amount = 0.368645716 ether; }
        else if (msg.sender == address(0x008e9758a122fe4b5c07f3abec8f128742ccd75386)) {amount = 0.870004307 ether; }
        else if (msg.sender == address(0x00a167c53d16c72f47c32784a0560174f2fdd4c764)) {amount = 0.280169968 ether; }
        else if (msg.sender == address(0x009e43d6ba519a2111c6b97f0d56208586264e6a75)) {amount = 0.058982837 ether; }
        else if (msg.sender == address(0x00401975108c7c026cacd263a33568894e540e940b)) {amount = 0.823351123 ether; }
        else if (msg.sender == address(0x008c68bd62c277f1f267ea25e8bde819ee30bc009f)) {amount = 0.319982636 ether; }
        else if (msg.sender == address(0x004d088bdce28ad68202fc206a0f6a3e7b7a3bcbba)) {amount = 0.060456661 ether; }
        else if (msg.sender == address(0x00c49654e52a0a6ffe8df4a834cf128b7bfb5a0e4f)) {amount = 0.17694851 ether; }
        else if (msg.sender == address(0x0051ab932cde9ed203fe9ec722f5a7dcb489f04dd6)) {amount = 0.88475151 ether; }
        else if (msg.sender == address(0x003ee53e2789e3330595de2041518496c0e7ebde19)) {amount = 1.47458585 ether; }
        else if (msg.sender == address(0x00e0902f39605d31c38f9449ee42261c8616a5d1ba)) {amount = 0.564026736 ether; }
        else if (msg.sender == address(0x007b26e71c7f89de31feb752d9b14219078fbd4585)) {amount = 0.184322111 ether; }
        else if (msg.sender == address(0x001ffcd8a87eddbe79b2a2cd73275caa2b1e3d94a4)) {amount = 0.106169106 ether; }
        else if (msg.sender == address(0x00dc303340825a4044505144ce540446ec83ef4ac2)) {amount = 0.176950003 ether; }
        else if (msg.sender == address(0x0029b62ab2678ce6c8ea66d667c79ad09b484b101e)) {amount = 0.29491717 ether; }
        else if (msg.sender == address(0x00abb4010f7bee5e80c8b5444dee29730c8d33c531)) {amount = 1.275516536 ether; }
        else if (msg.sender == address(0x0002bd927b2df53f1a96504236de4421a673463f60)) {amount = 0.058982837 ether; }
        else if (msg.sender == address(0x0065863d3452cd4f38100c200dff39d4cdf954be18)) {amount = 0.077415346 ether; }
        else if (msg.sender == address(0x009d774944f97e2536f41d07d93accd9f5fafa81f0)) {amount = 0.29491717 ether; }
        else if (msg.sender == address(0x00e8995e2b849b8d5bf6571ef01f3d41740a0a5f62)) {amount = 0.140084984 ether; }
        else if (msg.sender == address(0x001ee8d166616be0001358126b9b86903e50ae7c91)) {amount = 0.479239281 ether; }
        else if (msg.sender == address(0x0001c1b9daae71979e44ec3ffef91fdf5e22e5f0c7)) {amount = 0.025804618 ether; }
        else if (msg.sender == address(0x00b8cb5c2d34465819f26111c521e27f0541efce02)) {amount = 1.47458585 ether; }
        else if (msg.sender == address(0x00210e59f5eacaf6844ab54ad61aaa3ec692e646a3)) {amount = 1.47458585 ether; }
        else if (msg.sender == address(0x00b43609407c5fe91339e62f8515eaa17b6df1b9a7)) {amount = 0.29491717 ether; }
        else if (msg.sender == address(0x006130f97655edd23347fc8aae245eb91d0d51e744)) {amount = 0.737292925 ether; }
        else if (msg.sender == address(0x0089707d991bc711cfb984d42d3e6221d56e264279)) {amount = 0.073728546 ether; }
        else if (msg.sender == address(0x00bb9e076877bae3f1de9a7c0dec917a56b42cf9eb)) {amount = 0.184322111 ether; }
        else if (msg.sender == address(0x004446c75e18c9f4746b5aa3b6b72fabbca522c43d)) {amount = 1.253397226 ether; }
        else if (msg.sender == address(0x00085aeb4652f79428b6b6482395525c89d4a9a6f7)) {amount = 1.47458585 ether; }
        else if (msg.sender == address(0x00f2e8b075a507ebebb54a28ca36d792f19db8b705)) {amount = 0.212044045 ether; }
        else if (msg.sender == address(0x004b5815374edddebd9a74f958494bc3bfbc8986e5)) {amount = 0.191695713 ether; }
        else if (msg.sender == address(0x00d3d26a2c15b1f65eb8a1e13c6061b1203a105670)) {amount = 0.55296932 ether; }
        else if (msg.sender == address(0x00f350e95c8c4a92637c7baa23130de46946eb1c63)) {amount = 1.47458585 ether; }
        else if (msg.sender == address(0x00aa70b4ce02164e92f1724b054fc0ccf0e50e0ac5)) {amount = 0.103219964 ether; }
        else if (msg.sender == address(0x00ef2df374213fc93fb9d8b5b63bd082258c4d1d05)) {amount = 0.23593284 ether; }
        else if (msg.sender == address(0x00624ce55f7b13c59765f3c9dac7b3663e8bcc50af)) {amount = 1.47458585 ether; }
        else if (msg.sender == address(0x004c8deab6e78c564e77f41f8566bd6eebcc6177c9)) {amount = 0.752038634 ether; }
        else if (msg.sender == address(0x005ec9aa4ff5e6535250a1effd7c1ad0313e8226de)) {amount = 0.110593565 ether; }
        else if (msg.sender == address(0x00ece791daf5a9b0c20e7a3df9659ff6639a6d93f6)) {amount = 1.032210095 ether; }
        else if (msg.sender == address(0x00a0e33c3fdd19bf09e043baa7d82c1c13df4830a7)) {amount = 0.039075009 ether; }
        require(amount > 0 && !claimed_[msg.sender]);
        claimed_[msg.sender] = true;
        (bool success, ) = msg.sender.call{value:amount}("");
        require(success);
    }

    receive() external payable {}

    function drain() external {
        require(msg.sender == owner_);
        payable(msg.sender).transfer(address(this).balance);
    }
}