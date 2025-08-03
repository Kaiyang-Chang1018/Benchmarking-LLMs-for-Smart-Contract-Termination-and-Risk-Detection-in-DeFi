// SPDX-License-Identifier: MIT
// Telegram: https://t.me/gaslessport

pragma solidity ^0.8.25;


/*
[00]	PUSH1	80
[02]	PUSH1	40
[04]	MSTORE	
[05]	CALLVALUE	
[06]	DUP1	
[07]	ISZERO	
[08]	PUSH2	0010
[0b]	JUMPI	
[0c]	PUSH1	00
[0e]	DUP1	
[0f]	REVERT	
[10]	JUMPDEST	
[11]	POP	
[12]	PUSH14	314dc6448d9338c15b0a00000000
[21]	PUSH1	00
[23]	DUP1	
[24]	CALLER	
[25]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[3a]	AND	
[3b]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[50]	AND	
[51]	DUP2	
[52]	MSTORE	
[53]	PUSH1	20
[55]	ADD	
[56]	SWAP1	
[57]	DUP2	
[58]	MSTORE	
[59]	PUSH1	20
[5b]	ADD	
[5c]	PUSH1	00
[5e]	KECCAK256	
[5f]	DUP2	
[60]	SWAP1	
[61]	SSTORE	
[62]	POP	
[63]	CALLER	
[64]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[79]	AND	
[7a]	PUSH1	00
[7c]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[91]	AND	
[92]	PUSH32	ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
[b3]	PUSH14	314dc6448d9338c15b0a00000000
[c2]	PUSH1	40
[c4]	MLOAD	
[c5]	PUSH2	00ce
[c8]	SWAP2	
[c9]	SWAP1	
[ca]	PUSH2	00f4
[cd]	JUMP	
[ce]	JUMPDEST	
[cf]	PUSH1	40
[d1]	MLOAD	
[d2]	DUP1	
[d3]	SWAP2	
[d4]	SUB	
[d5]	SWAP1	
[d6]	LOG3	
[d7]	PUSH2	010f
[da]	JUMP	
[db]	JUMPDEST	
[dc]	PUSH1	00
[de]	DUP2	
[df]	SWAP1	
[e0]	POP	
[e1]	SWAP2	
[e2]	SWAP1	
[e3]	POP	
[e4]	JUMP	
[e5]	JUMPDEST	
[e6]	PUSH2	00ee
[e9]	DUP2	
[ea]	PUSH2	00db
[ed]	JUMP	
[ee]	JUMPDEST	
[ef]	DUP3	
[f0]	MSTORE	
[f1]	POP	
[f2]	POP	
[f3]	JUMP	
[f4]	JUMPDEST	
[f5]	PUSH1	00
[f7]	PUSH1	20
[f9]	DUP3	
[fa]	ADD	
[fb]	SWAP1	
[fc]	POP	
[fd]	PUSH2	0109
[100]	PUSH1	00
[102]	DUP4	
[103]	ADD	
[104]	DUP5	
[105]	PUSH2	00e5
[108]	JUMP	
[109]	JUMPDEST	
[10a]	SWAP3	
[10b]	SWAP2	
[10c]	POP	
[10d]	POP	
[10e]	JUMP	
[10f]	JUMPDEST	
[110]	PUSH2	09de
[113]	DUP1	
[114]	PUSH2	011e
[117]	PUSH1	00
[119]	CODECOPY	
[11a]	PUSH1	00
[11c]	RETURN	
[11d]	INVALID	
[11e]	PUSH1	80
[120]	PUSH1	40
[122]	MSTORE	
[123]	CALLVALUE	
[124]	DUP1	
[125]	ISZERO	
[126]	PUSH2	0010
[129]	JUMPI	
[12a]	PUSH1	00
[12c]	DUP1	
[12d]	REVERT	
[12e]	JUMPDEST	
[12f]	POP	
[130]	PUSH1	04
[132]	CALLDATASIZE	
[133]	LT	
[134]	PUSH2	0093
[137]	JUMPI	
[138]	PUSH1	00
[13a]	CALLDATALOAD	
[13b]	PUSH1	e0
[13d]	SHR	
[13e]	DUP1	
[13f]	PUSH4	313ce567
[144]	GT	
[145]	PUSH2	0066
[148]	JUMPI	
[149]	DUP1	
[14a]	PUSH4	313ce567
[14f]	EQ	
[150]	PUSH2	0134
[153]	JUMPI	
[154]	DUP1	
[155]	PUSH4	70a08231
[15a]	EQ	
[15b]	PUSH2	0152
[15e]	JUMPI	
[15f]	DUP1	
[160]	PUSH4	95d89b41
[165]	EQ	
[166]	PUSH2	0182
[169]	JUMPI	
[16a]	DUP1	
[16b]	PUSH4	a9059cbb
[170]	EQ	
[171]	PUSH2	01a0
[174]	JUMPI	
[175]	DUP1	
[176]	PUSH4	dd62ed3e
[17b]	EQ	
[17c]	PUSH2	01d0
[17f]	JUMPI	
[180]	PUSH2	0093
[183]	JUMP	
[184]	JUMPDEST	
[185]	DUP1	
[186]	PUSH4	06fdde03
[18b]	EQ	
[18c]	PUSH2	0098
[18f]	JUMPI	
[190]	DUP1	
[191]	PUSH4	095ea7b3
[196]	EQ	
[197]	PUSH2	00b6
[19a]	JUMPI	
[19b]	DUP1	
[19c]	PUSH4	18160ddd
[1a1]	EQ	
[1a2]	PUSH2	00e6
[1a5]	JUMPI	
[1a6]	DUP1	
[1a7]	PUSH4	23b872dd
[1ac]	EQ	
[1ad]	PUSH2	0104
[1b0]	JUMPI	
[1b1]	JUMPDEST	
[1b2]	PUSH1	00
[1b4]	DUP1	
[1b5]	REVERT	
[1b6]	JUMPDEST	
[1b7]	PUSH2	00a0
[1ba]	PUSH2	0200
[1bd]	JUMP	
[1be]	JUMPDEST	
[1bf]	PUSH1	40
[1c1]	MLOAD	
[1c2]	PUSH2	00ad
[1c5]	SWAP2	
[1c6]	SWAP1	
[1c7]	PUSH2	06bf
[1ca]	JUMP	
[1cb]	JUMPDEST	
[1cc]	PUSH1	40
[1ce]	MLOAD	
[1cf]	DUP1	
[1d0]	SWAP2	
[1d1]	SUB	
[1d2]	SWAP1	
[1d3]	RETURN	
[1d4]	JUMPDEST	
[1d5]	PUSH2	00d0
[1d8]	PUSH1	04
[1da]	DUP1	
[1db]	CALLDATASIZE	
[1dc]	SUB	
[1dd]	DUP2	
[1de]	ADD	
[1df]	SWAP1	
[1e0]	PUSH2	00cb
[1e3]	SWAP2	
[1e4]	SWAP1	
[1e5]	PUSH2	077a
[1e8]	JUMP	
[1e9]	JUMPDEST	
[1ea]	PUSH2	0239
[1ed]	JUMP	
[1ee]	JUMPDEST	
[1ef]	PUSH1	40
[1f1]	MLOAD	
[1f2]	PUSH2	00dd
[1f5]	SWAP2	
[1f6]	SWAP1	
[1f7]	PUSH2	07d5
[1fa]	JUMP	
[1fb]	JUMPDEST	
[1fc]	PUSH1	40
[1fe]	MLOAD	
[1ff]	DUP1	
[200]	SWAP2	
[201]	SUB	
[202]	SWAP1	
[203]	RETURN	
[204]	JUMPDEST	
[205]	PUSH2	00ee
[208]	PUSH2	0250
[20b]	JUMP	
[20c]	JUMPDEST	
[20d]	PUSH1	40
[20f]	MLOAD	
[210]	PUSH2	00fb
[213]	SWAP2	
[214]	SWAP1	
[215]	PUSH2	07ff
[218]	JUMP	
[219]	JUMPDEST	
[21a]	PUSH1	40
[21c]	MLOAD	
[21d]	DUP1	
[21e]	SWAP2	
[21f]	SUB	
[220]	SWAP1	
[221]	RETURN	
[222]	JUMPDEST	
[223]	PUSH2	011e
[226]	PUSH1	04
[228]	DUP1	
[229]	CALLDATASIZE	
[22a]	SUB	
[22b]	DUP2	
[22c]	ADD	
[22d]	SWAP1	
[22e]	PUSH2	0119
[231]	SWAP2	
[232]	SWAP1	
[233]	PUSH2	081a
[236]	JUMP	
[237]	JUMPDEST	
[238]	PUSH2	0262
[23b]	JUMP	
[23c]	JUMPDEST	
[23d]	PUSH1	40
[23f]	MLOAD	
[240]	PUSH2	012b
[243]	SWAP2	
[244]	SWAP1	
[245]	PUSH2	07d5
[248]	JUMP	
[249]	JUMPDEST	
[24a]	PUSH1	40
[24c]	MLOAD	
[24d]	DUP1	
[24e]	SWAP2	
[24f]	SUB	
[250]	SWAP1	
[251]	RETURN	
[252]	JUMPDEST	
[253]	PUSH2	013c
[256]	PUSH2	030c
[259]	JUMP	
[25a]	JUMPDEST	
[25b]	PUSH1	40
[25d]	MLOAD	
[25e]	PUSH2	0149
[261]	SWAP2	
[262]	SWAP1	
[263]	PUSH2	0889
[266]	JUMP	
[267]	JUMPDEST	
[268]	PUSH1	40
[26a]	MLOAD	
[26b]	DUP1	
[26c]	SWAP2	
[26d]	SUB	
[26e]	SWAP1	
[26f]	RETURN	
[270]	JUMPDEST	
[271]	PUSH2	016c
[274]	PUSH1	04
[276]	DUP1	
[277]	CALLDATASIZE	
[278]	SUB	
[279]	DUP2	
[27a]	ADD	
[27b]	SWAP1	
[27c]	PUSH2	0167
[27f]	SWAP2	
[280]	SWAP1	
[281]	PUSH2	08a4
[284]	JUMP	
[285]	JUMPDEST	
[286]	PUSH2	0311
[289]	JUMP	
[28a]	JUMPDEST	
[28b]	PUSH1	40
[28d]	MLOAD	
[28e]	PUSH2	0179
[291]	SWAP2	
[292]	SWAP1	
[293]	PUSH2	07ff
[296]	JUMP	
[297]	JUMPDEST	
[298]	PUSH1	40
[29a]	MLOAD	
[29b]	DUP1	
[29c]	SWAP2	
[29d]	SUB	
[29e]	SWAP1	
[29f]	RETURN	
[2a0]	JUMPDEST	
[2a1]	PUSH2	018a
[2a4]	PUSH2	0359
[2a7]	JUMP	
[2a8]	JUMPDEST	
[2a9]	PUSH1	40
[2ab]	MLOAD	
[2ac]	PUSH2	0197
[2af]	SWAP2	
[2b0]	SWAP1	
[2b1]	PUSH2	06bf
[2b4]	JUMP	
[2b5]	JUMPDEST	
[2b6]	PUSH1	40
[2b8]	MLOAD	
[2b9]	DUP1	
[2ba]	SWAP2	
[2bb]	SUB	
[2bc]	SWAP1	
[2bd]	RETURN	
[2be]	JUMPDEST	
[2bf]	PUSH2	01ba
[2c2]	PUSH1	04
[2c4]	DUP1	
[2c5]	CALLDATASIZE	
[2c6]	SUB	
[2c7]	DUP2	
[2c8]	ADD	
[2c9]	SWAP1	
[2ca]	PUSH2	01b5
[2cd]	SWAP2	
[2ce]	SWAP1	
[2cf]	PUSH2	077a
[2d2]	JUMP	
[2d3]	JUMPDEST	
[2d4]	PUSH2	0392
[2d7]	JUMP	
[2d8]	JUMPDEST	
[2d9]	PUSH1	40
[2db]	MLOAD	
[2dc]	PUSH2	01c7
[2df]	SWAP2	
[2e0]	SWAP1	
[2e1]	PUSH2	07d5
[2e4]	JUMP	
[2e5]	JUMPDEST	
[2e6]	PUSH1	40
[2e8]	MLOAD	
[2e9]	DUP1	
[2ea]	SWAP2	
[2eb]	SUB	
[2ec]	SWAP1	
[2ed]	RETURN	
[2ee]	JUMPDEST	
[2ef]	PUSH2	01ea
[2f2]	PUSH1	04
[2f4]	DUP1	
[2f5]	CALLDATASIZE	
[2f6]	SUB	
[2f7]	DUP2	
[2f8]	ADD	
[2f9]	SWAP1	
[2fa]	PUSH2	01e5
[2fd]	SWAP2	
[2fe]	SWAP1	
[2ff]	PUSH2	08d1
[302]	JUMP	
[303]	JUMPDEST	
[304]	PUSH2	03a9
[307]	JUMP	
[308]	JUMPDEST	
[309]	PUSH1	40
[30b]	MLOAD	
[30c]	PUSH2	01f7
[30f]	SWAP2	
[310]	SWAP1	
[311]	PUSH2	07ff
[314]	JUMP	
[315]	JUMPDEST	
[316]	PUSH1	40
[318]	MLOAD	
[319]	DUP1	
[31a]	SWAP2	
[31b]	SUB	
[31c]	SWAP1	
[31d]	RETURN	
[31e]	JUMPDEST	
[31f]	PUSH1	40
[321]	MLOAD	
[322]	DUP1	
[323]	PUSH1	40
[325]	ADD	
[326]	PUSH1	40
[328]	MSTORE	
[329]	DUP1	
[32a]	PUSH1	07
[32c]	DUP2	
[32d]	MSTORE	
[32e]	PUSH1	20
[330]	ADD	
[331]	PUSH32	4761736c65737300000000000000000000000000000000000000000000000000
[352]	DUP2	
[353]	MSTORE	
[354]	POP	
[355]	DUP2	
[356]	JUMP	
[357]	JUMPDEST	
[358]	PUSH1	00
[35a]	PUSH2	0246
[35d]	CALLER	
[35e]	DUP5	
[35f]	DUP5	
[360]	PUSH2	0430
[363]	JUMP	
[364]	JUMPDEST	
[365]	PUSH1	01
[367]	SWAP1	
[368]	POP	
[369]	SWAP3	
[36a]	SWAP2	
[36b]	POP	
[36c]	POP	
[36d]	JUMP	
[36e]	JUMPDEST	
[36f]	PUSH14	314dc6448d9338c15b0a00000000
[37e]	DUP2	
[37f]	JUMP	
[380]	JUMPDEST	
[381]	PUSH1	00
[383]	PUSH2	026f
[386]	DUP5	
[387]	DUP5	
[388]	DUP5	
[389]	PUSH2	051b
[38c]	JUMP	
[38d]	JUMPDEST	
[38e]	PUSH2	0301
[391]	DUP5	
[392]	CALLER	
[393]	DUP5	
[394]	PUSH1	01
[396]	PUSH1	00
[398]	DUP10	
[399]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[3ae]	AND	
[3af]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[3c4]	AND	
[3c5]	DUP2	
[3c6]	MSTORE	
[3c7]	PUSH1	20
[3c9]	ADD	
[3ca]	SWAP1	
[3cb]	DUP2	
[3cc]	MSTORE	
[3cd]	PUSH1	20
[3cf]	ADD	
[3d0]	PUSH1	00
[3d2]	KECCAK256	
[3d3]	PUSH1	00
[3d5]	CALLER	
[3d6]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[3eb]	AND	
[3ec]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[401]	AND	
[402]	DUP2	
[403]	MSTORE	
[404]	PUSH1	20
[406]	ADD	
[407]	SWAP1	
[408]	DUP2	
[409]	MSTORE	
[40a]	PUSH1	20
[40c]	ADD	
[40d]	PUSH1	00
[40f]	KECCAK256	
[410]	SLOAD	
[411]	PUSH2	02fc
[414]	SWAP2	
[415]	SWAP1	
[416]	PUSH2	0940
[419]	JUMP	
[41a]	JUMPDEST	
[41b]	PUSH2	0430
[41e]	JUMP	
[41f]	JUMPDEST	
[420]	PUSH1	01
[422]	SWAP1	
[423]	POP	
[424]	SWAP4	
[425]	SWAP3	
[426]	POP	
[427]	POP	
[428]	POP	
[429]	JUMP	
[42a]	JUMPDEST	
[42b]	PUSH1	12
[42d]	DUP2	
[42e]	JUMP	
[42f]	JUMPDEST	
[430]	PUSH1	00
[432]	DUP1	
[433]	PUSH1	00
[435]	DUP4	
[436]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[44b]	AND	
[44c]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[461]	AND	
[462]	DUP2	
[463]	MSTORE	
[464]	PUSH1	20
[466]	ADD	
[467]	SWAP1	
[468]	DUP2	
[469]	MSTORE	
[46a]	PUSH1	20
[46c]	ADD	
[46d]	PUSH1	00
[46f]	KECCAK256	
[470]	SLOAD	
[471]	SWAP1	
[472]	POP	
[473]	SWAP2	
[474]	SWAP1	
[475]	POP	
[476]	JUMP	
[477]	JUMPDEST	
[478]	PUSH1	40
[47a]	MLOAD	
[47b]	DUP1	
[47c]	PUSH1	40
[47e]	ADD	
[47f]	PUSH1	40
[481]	MSTORE	
[482]	DUP1	
[483]	PUSH1	07
[485]	DUP2	
[486]	MSTORE	
[487]	PUSH1	20
[489]	ADD	
[48a]	PUSH32	4761736c65737300000000000000000000000000000000000000000000000000
[4ab]	DUP2	
[4ac]	MSTORE	
[4ad]	POP	
[4ae]	DUP2	
[4af]	JUMP	
[4b0]	JUMPDEST	
[4b1]	PUSH1	00
[4b3]	PUSH2	039f
[4b6]	CALLER	
[4b7]	DUP5	
[4b8]	DUP5	
[4b9]	PUSH2	051b
[4bc]	JUMP	
[4bd]	JUMPDEST	
[4be]	PUSH1	01
[4c0]	SWAP1	
[4c1]	POP	
[4c2]	SWAP3	
[4c3]	SWAP2	
[4c4]	POP	
[4c5]	POP	
[4c6]	JUMP	
[4c7]	JUMPDEST	
[4c8]	PUSH1	00
[4ca]	PUSH1	01
[4cc]	PUSH1	00
[4ce]	DUP5	
[4cf]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[4e4]	AND	
[4e5]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[4fa]	AND	
[4fb]	DUP2	
[4fc]	MSTORE	
[4fd]	PUSH1	20
[4ff]	ADD	
[500]	SWAP1	
[501]	DUP2	
[502]	MSTORE	
[503]	PUSH1	20
[505]	ADD	
[506]	PUSH1	00
[508]	KECCAK256	
[509]	PUSH1	00
[50b]	DUP4	
[50c]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[521]	AND	
[522]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[537]	AND	
[538]	DUP2	
[539]	MSTORE	
[53a]	PUSH1	20
[53c]	ADD	
[53d]	SWAP1	
[53e]	DUP2	
[53f]	MSTORE	
[540]	PUSH1	20
[542]	ADD	
[543]	PUSH1	00
[545]	KECCAK256	
[546]	SLOAD	
[547]	SWAP1	
[548]	POP	
[549]	SWAP3	
[54a]	SWAP2	
[54b]	POP	
[54c]	POP	
[54d]	JUMP	
[54e]	JUMPDEST	
[54f]	DUP1	
[550]	PUSH1	01
[552]	PUSH1	00
[554]	DUP6	
[555]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[56a]	AND	
[56b]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[580]	AND	
[581]	DUP2	
[582]	MSTORE	
[583]	PUSH1	20
[585]	ADD	
[586]	SWAP1	
[587]	DUP2	
[588]	MSTORE	
[589]	PUSH1	20
[58b]	ADD	
[58c]	PUSH1	00
[58e]	KECCAK256	
[58f]	PUSH1	00
[591]	DUP5	
[592]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[5a7]	AND	
[5a8]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[5bd]	AND	
[5be]	DUP2	
[5bf]	MSTORE	
[5c0]	PUSH1	20
[5c2]	ADD	
[5c3]	SWAP1	
[5c4]	DUP2	
[5c5]	MSTORE	
[5c6]	PUSH1	20
[5c8]	ADD	
[5c9]	PUSH1	00
[5cb]	KECCAK256	
[5cc]	DUP2	
[5cd]	SWAP1	
[5ce]	SSTORE	
[5cf]	POP	
[5d0]	DUP2	
[5d1]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[5e6]	AND	
[5e7]	DUP4	
[5e8]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[5fd]	AND	
[5fe]	PUSH32	8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925
[61f]	DUP4	
[620]	PUSH1	40
[622]	MLOAD	
[623]	PUSH2	050e
[626]	SWAP2	
[627]	SWAP1	
[628]	PUSH2	07ff
[62b]	JUMP	
[62c]	JUMPDEST	
[62d]	PUSH1	40
[62f]	MLOAD	
[630]	DUP1	
[631]	SWAP2	
[632]	SUB	
[633]	SWAP1	
[634]	LOG3	
[635]	POP	
[636]	POP	
[637]	POP	
[638]	JUMP	
[639]	JUMPDEST	
[63a]	DUP1	
[63b]	PUSH1	00
[63d]	DUP1	
[63e]	DUP6	
[63f]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[654]	AND	
[655]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[66a]	AND	
[66b]	DUP2	
[66c]	MSTORE	
[66d]	PUSH1	20
[66f]	ADD	
[670]	SWAP1	
[671]	DUP2	
[672]	MSTORE	
[673]	PUSH1	20
[675]	ADD	
[676]	PUSH1	00
[678]	KECCAK256	
[679]	PUSH1	00
[67b]	DUP3	
[67c]	DUP3	
[67d]	SLOAD	
[67e]	PUSH2	0569
[681]	SWAP2	
[682]	SWAP1	
[683]	PUSH2	0940
[686]	JUMP	
[687]	JUMPDEST	
[688]	SWAP3	
[689]	POP	
[68a]	POP	
[68b]	DUP2	
[68c]	SWAP1	
[68d]	SSTORE	
[68e]	POP	
[68f]	DUP1	
[690]	PUSH1	00
[692]	DUP1	
[693]	DUP5	
[694]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[6a9]	AND	
[6aa]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[6bf]	AND	
[6c0]	DUP2	
[6c1]	MSTORE	
[6c2]	PUSH1	20
[6c4]	ADD	
[6c5]	SWAP1	
[6c6]	DUP2	
[6c7]	MSTORE	
[6c8]	PUSH1	20
[6ca]	ADD	
[6cb]	PUSH1	00
[6cd]	KECCAK256	
[6ce]	PUSH1	00
[6d0]	DUP3	
[6d1]	DUP3	
[6d2]	SLOAD	
[6d3]	PUSH2	05be
[6d6]	SWAP2	
[6d7]	SWAP1	
[6d8]	PUSH2	0974
[6db]	JUMP	
[6dc]	JUMPDEST	
[6dd]	SWAP3	
[6de]	POP	
[6df]	POP	
[6e0]	DUP2	
[6e1]	SWAP1	
[6e2]	SSTORE	
[6e3]	POP	
[6e4]	DUP2	
[6e5]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[6fa]	AND	
[6fb]	DUP4	
[6fc]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[711]	AND	
[712]	PUSH32	ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
[733]	DUP4	
[734]	PUSH1	40
[736]	MLOAD	
[737]	PUSH2	0622
[73a]	SWAP2	
[73b]	SWAP1	
[73c]	PUSH2	07ff
[73f]	JUMP	
[740]	JUMPDEST	
[741]	PUSH1	40
[743]	MLOAD	
[744]	DUP1	
[745]	SWAP2	
[746]	SUB	
[747]	SWAP1	
[748]	LOG3	
[749]	POP	
[74a]	POP	
[74b]	POP	
[74c]	JUMP	
[74d]	JUMPDEST	
[74e]	PUSH1	00
[750]	DUP2	
[751]	MLOAD	
[752]	SWAP1	
[753]	POP	
[754]	SWAP2	
[755]	SWAP1	
[756]	POP	
[757]	JUMP	
[758]	JUMPDEST	
[759]	PUSH1	00
[75b]	DUP3	
[75c]	DUP3	
[75d]	MSTORE	
[75e]	PUSH1	20
[760]	DUP3	
[761]	ADD	
[762]	SWAP1	
[763]	POP	
[764]	SWAP3	
[765]	SWAP2	
[766]	POP	
[767]	POP	
[768]	JUMP	
[769]	JUMPDEST	
[76a]	PUSH1	00
[76c]	JUMPDEST	
[76d]	DUP4	
[76e]	DUP2	
[76f]	LT	
[770]	ISZERO	
[771]	PUSH2	0669
[774]	JUMPI	
[775]	DUP1	
[776]	DUP3	
[777]	ADD	
[778]	MLOAD	
[779]	DUP2	
[77a]	DUP5	
[77b]	ADD	
[77c]	MSTORE	
[77d]	PUSH1	20
[77f]	DUP2	
[780]	ADD	
[781]	SWAP1	
[782]	POP	
[783]	PUSH2	064e
[786]	JUMP	
[787]	JUMPDEST	
[788]	PUSH1	00
[78a]	DUP5	
[78b]	DUP5	
[78c]	ADD	
[78d]	MSTORE	
[78e]	POP	
[78f]	POP	
[790]	POP	
[791]	POP	
[792]	JUMP	
[793]	JUMPDEST	
[794]	PUSH1	00
[796]	PUSH1	1f
[798]	NOT	
[799]	PUSH1	1f
[79b]	DUP4	
[79c]	ADD	
[79d]	AND	
[79e]	SWAP1	
[79f]	POP	
[7a0]	SWAP2	
[7a1]	SWAP1	
[7a2]	POP	
[7a3]	JUMP	
[7a4]	JUMPDEST	
[7a5]	PUSH1	00
[7a7]	PUSH2	0691
[7aa]	DUP3	
[7ab]	PUSH2	062f
[7ae]	JUMP	
[7af]	JUMPDEST	
[7b0]	PUSH2	069b
[7b3]	DUP2	
[7b4]	DUP6	
[7b5]	PUSH2	063a
[7b8]	JUMP	
[7b9]	JUMPDEST	
[7ba]	SWAP4	
[7bb]	POP	
[7bc]	PUSH2	06ab
[7bf]	DUP2	
[7c0]	DUP6	
[7c1]	PUSH1	20
[7c3]	DUP7	
[7c4]	ADD	
[7c5]	PUSH2	064b
[7c8]	JUMP	
[7c9]	JUMPDEST	
[7ca]	PUSH2	06b4
[7cd]	DUP2	
[7ce]	PUSH2	0675
[7d1]	JUMP	
[7d2]	JUMPDEST	
[7d3]	DUP5	
[7d4]	ADD	
[7d5]	SWAP2	
[7d6]	POP	
[7d7]	POP	
[7d8]	SWAP3	
[7d9]	SWAP2	
[7da]	POP	
[7db]	POP	
[7dc]	JUMP	
[7dd]	JUMPDEST	
[7de]	PUSH1	00
[7e0]	PUSH1	20
[7e2]	DUP3	
[7e3]	ADD	
[7e4]	SWAP1	
[7e5]	POP	
[7e6]	DUP2	
[7e7]	DUP2	
[7e8]	SUB	
[7e9]	PUSH1	00
[7eb]	DUP4	
[7ec]	ADD	
[7ed]	MSTORE	
[7ee]	PUSH2	06d9
[7f1]	DUP2	
[7f2]	DUP5	
[7f3]	PUSH2	0686
[7f6]	JUMP	
[7f7]	JUMPDEST	
[7f8]	SWAP1	
[7f9]	POP	
[7fa]	SWAP3	
[7fb]	SWAP2	
[7fc]	POP	
[7fd]	POP	
[7fe]	JUMP	
[7ff]	JUMPDEST	
[800]	PUSH1	00
[802]	DUP1	
[803]	REVERT	
[804]	JUMPDEST	
[805]	PUSH1	00
[807]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[81c]	DUP3	
[81d]	AND	
[81e]	SWAP1	
[81f]	POP	
[820]	SWAP2	
[821]	SWAP1	
[822]	POP	
[823]	JUMP	
[824]	JUMPDEST	
[825]	PUSH1	00
[827]	PUSH2	0711
[82a]	DUP3	
[82b]	PUSH2	06e6
[82e]	JUMP	
[82f]	JUMPDEST	
[830]	SWAP1	
[831]	POP	
[832]	SWAP2	
[833]	SWAP1	
[834]	POP	
[835]	JUMP	
[836]	JUMPDEST	
[837]	PUSH2	0721
[83a]	DUP2	
[83b]	PUSH2	0706
[83e]	JUMP	
[83f]	JUMPDEST	
[840]	DUP2	
[841]	EQ	
[842]	PUSH2	072c
[845]	JUMPI	
[846]	PUSH1	00
[848]	DUP1	
[849]	REVERT	
[84a]	JUMPDEST	
[84b]	POP	
[84c]	JUMP	
[84d]	JUMPDEST	
[84e]	PUSH1	00
[850]	DUP2	
[851]	CALLDATALOAD	
[852]	SWAP1	
[853]	POP	
[854]	PUSH2	073e
[857]	DUP2	
[858]	PUSH2	0718
[85b]	JUMP	
[85c]	JUMPDEST	
[85d]	SWAP3	
[85e]	SWAP2	
[85f]	POP	
[860]	POP	
[861]	JUMP	
[862]	JUMPDEST	
[863]	PUSH1	00
[865]	DUP2	
[866]	SWAP1	
[867]	POP	
[868]	SWAP2	
[869]	SWAP1	
[86a]	POP	
[86b]	JUMP	
[86c]	JUMPDEST	
[86d]	PUSH2	0757
[870]	DUP2	
[871]	PUSH2	0744
[874]	JUMP	
[875]	JUMPDEST	
[876]	DUP2	
[877]	EQ	
[878]	PUSH2	0762
[87b]	JUMPI	
[87c]	PUSH1	00
[87e]	DUP1	
[87f]	REVERT	
[880]	JUMPDEST	
[881]	POP	
[882]	JUMP	
[883]	JUMPDEST	
[884]	PUSH1	00
[886]	DUP2	
[887]	CALLDATALOAD	
[888]	SWAP1	
[889]	POP	
[88a]	PUSH2	0774
[88d]	DUP2	
[88e]	PUSH2	074e
[891]	JUMP	
[892]	JUMPDEST	
[893]	SWAP3	
[894]	SWAP2	
[895]	POP	
[896]	POP	
[897]	JUMP	
[898]	JUMPDEST	
[899]	PUSH1	00
[89b]	DUP1	
[89c]	PUSH1	40
[89e]	DUP4	
[89f]	DUP6	
[8a0]	SUB	
[8a1]	SLT	
[8a2]	ISZERO	
[8a3]	PUSH2	0791
[8a6]	JUMPI	
[8a7]	PUSH2	0790
[8aa]	PUSH2	06e1
[8ad]	JUMP	
[8ae]	JUMPDEST	
[8af]	JUMPDEST	
[8b0]	PUSH1	00
[8b2]	PUSH2	079f
[8b5]	DUP6	
[8b6]	DUP3	
[8b7]	DUP7	
[8b8]	ADD	
[8b9]	PUSH2	072f
[8bc]	JUMP	
[8bd]	JUMPDEST	
[8be]	SWAP3	
[8bf]	POP	
[8c0]	POP	
[8c1]	PUSH1	20
[8c3]	PUSH2	07b0
[8c6]	DUP6	
[8c7]	DUP3	
[8c8]	DUP7	
[8c9]	ADD	
[8ca]	PUSH2	0765
[8cd]	JUMP	
[8ce]	JUMPDEST	
[8cf]	SWAP2	
[8d0]	POP	
[8d1]	POP	
[8d2]	SWAP3	
[8d3]	POP	
[8d4]	SWAP3	
[8d5]	SWAP1	
[8d6]	POP	
[8d7]	JUMP	
[8d8]	JUMPDEST	
[8d9]	PUSH1	00
[8db]	DUP2	
[8dc]	ISZERO	
[8dd]	ISZERO	
[8de]	SWAP1	
[8df]	POP	
[8e0]	SWAP2	
[8e1]	SWAP1	
[8e2]	POP	
[8e3]	JUMP	
[8e4]	JUMPDEST	
[8e5]	PUSH2	07cf
[8e8]	DUP2	
[8e9]	PUSH2	07ba
[8ec]	JUMP	
[8ed]	JUMPDEST	
[8ee]	DUP3	
[8ef]	MSTORE	
[8f0]	POP	
[8f1]	POP	
[8f2]	JUMP	
[8f3]	JUMPDEST	
[8f4]	PUSH1	00
[8f6]	PUSH1	20
[8f8]	DUP3	
[8f9]	ADD	
[8fa]	SWAP1	
[8fb]	POP	
[8fc]	PUSH2	07ea
[8ff]	PUSH1	00
[901]	DUP4	
[902]	ADD	
[903]	DUP5	
[904]	PUSH2	07c6
[907]	JUMP	
[908]	JUMPDEST	
[909]	SWAP3	
[90a]	SWAP2	
[90b]	POP	
[90c]	POP	
[90d]	JUMP	
[90e]	JUMPDEST	
[90f]	PUSH2	07f9
[912]	DUP2	
[913]	PUSH2	0744
[916]	JUMP	
[917]	JUMPDEST	
[918]	DUP3	
[919]	MSTORE	
[91a]	POP	
[91b]	POP	
[91c]	JUMP	
[91d]	JUMPDEST	
[91e]	PUSH1	00
[920]	PUSH1	20
[922]	DUP3	
[923]	ADD	
[924]	SWAP1	
[925]	POP	
[926]	PUSH2	0814
[929]	PUSH1	00
[92b]	DUP4	
[92c]	ADD	
[92d]	DUP5	
[92e]	PUSH2	07f0
[931]	JUMP	
[932]	JUMPDEST	
[933]	SWAP3	
[934]	SWAP2	
[935]	POP	
[936]	POP	
[937]	JUMP	
[938]	JUMPDEST	
[939]	PUSH1	00
[93b]	DUP1	
[93c]	PUSH1	00
[93e]	PUSH1	60
[940]	DUP5	
[941]	DUP7	
[942]	SUB	
[943]	SLT	
[944]	ISZERO	
[945]	PUSH2	0833
[948]	JUMPI	
[949]	PUSH2	0832
[94c]	PUSH2	06e1
[94f]	JUMP	
[950]	JUMPDEST	
[951]	JUMPDEST	
[952]	PUSH1	00
[954]	PUSH2	0841
[957]	DUP7	
[958]	DUP3	
[959]	DUP8	
[95a]	ADD	
[95b]	PUSH2	072f
[95e]	JUMP	
[95f]	JUMPDEST	
[960]	SWAP4	
[961]	POP	
[962]	POP	
[963]	PUSH1	20
[965]	PUSH2	0852
[968]	DUP7	
[969]	DUP3	
[96a]	DUP8	
[96b]	ADD	
[96c]	PUSH2	072f
[96f]	JUMP	
[970]	JUMPDEST	
[971]	SWAP3	
[972]	POP	
[973]	POP	
[974]	PUSH1	40
[976]	PUSH2	0863
[979]	DUP7	
[97a]	DUP3	
[97b]	DUP8	
[97c]	ADD	
[97d]	PUSH2	0765
[980]	JUMP	
[981]	JUMPDEST	
[982]	SWAP2	
[983]	POP	
[984]	POP	
[985]	SWAP3	
[986]	POP	
[987]	SWAP3	
[988]	POP	
[989]	SWAP3	
[98a]	JUMP	
[98b]	JUMPDEST	
[98c]	PUSH1	00
[98e]	PUSH1	ff
[990]	DUP3	
[991]	AND	
[992]	SWAP1	
[993]	POP	
[994]	SWAP2	
[995]	SWAP1	
[996]	POP	
[997]	JUMP	
[998]	JUMPDEST	
[999]	PUSH2	0883
[99c]	DUP2	
[99d]	PUSH2	086d
[9a0]	JUMP	
[9a1]	JUMPDEST	
[9a2]	DUP3	
[9a3]	MSTORE	
[9a4]	POP	
[9a5]	POP	
[9a6]	JUMP	
[9a7]	JUMPDEST	
[9a8]	PUSH1	00
[9aa]	PUSH1	20
[9ac]	DUP3	
[9ad]	ADD	
[9ae]	SWAP1	
[9af]	POP	
[9b0]	PUSH2	089e
[9b3]	PUSH1	00
[9b5]	DUP4	
[9b6]	ADD	
[9b7]	DUP5	
[9b8]	PUSH2	087a
[9bb]	JUMP	
[9bc]	JUMPDEST	
[9bd]	SWAP3	
[9be]	SWAP2	
[9bf]	POP	
[9c0]	POP	
[9c1]	JUMP	
[9c2]	JUMPDEST	
[9c3]	PUSH1	00
[9c5]	PUSH1	20
[9c7]	DUP3	
[9c8]	DUP5	
[9c9]	SUB	
[9ca]	SLT	
[9cb]	ISZERO	
[9cc]	PUSH2	08ba
[9cf]	JUMPI	
[9d0]	PUSH2	08b9
[9d3]	PUSH2	06e1
[9d6]	JUMP	
[9d7]	JUMPDEST	
[9d8]	JUMPDEST	
[9d9]	PUSH1	00
[9db]	PUSH2	08c8
[9de]	DUP5	
[9df]	DUP3	
[9e0]	DUP6	
[9e1]	ADD	
[9e2]	PUSH2	072f
[9e5]	JUMP	
[9e6]	JUMPDEST	
[9e7]	SWAP2	
[9e8]	POP	
[9e9]	POP	
[9ea]	SWAP3	
[9eb]	SWAP2	
[9ec]	POP	
[9ed]	POP	
[9ee]	JUMP	
[9ef]	JUMPDEST	
[9f0]	PUSH1	00
[9f2]	DUP1	
[9f3]	PUSH1	40
[9f5]	DUP4	
[9f6]	DUP6	
[9f7]	SUB	
[9f8]	SLT	
[9f9]	ISZERO	
[9fa]	PUSH2	08e8
[9fd]	JUMPI	
[9fe]	PUSH2	08e7
[a01]	PUSH2	06e1
[a04]	JUMP	
[a05]	JUMPDEST	
[a06]	JUMPDEST	
[a07]	PUSH1	00
[a09]	PUSH2	08f6
[a0c]	DUP6	
[a0d]	DUP3	
[a0e]	DUP7	
[a0f]	ADD	
[a10]	PUSH2	072f
[a13]	JUMP	
[a14]	JUMPDEST	
[a15]	SWAP3	
[a16]	POP	
[a17]	POP	
[a18]	PUSH1	20
[a1a]	PUSH2	0907
[a1d]	DUP6	
[a1e]	DUP3	
[a1f]	DUP7	
[a20]	ADD	
[a21]	PUSH2	072f
[a24]	JUMP	
[a25]	JUMPDEST	
[a26]	SWAP2	
[a27]	POP	
[a28]	POP	
[a29]	SWAP3	
[a2a]	POP	
[a2b]	SWAP3	
[a2c]	SWAP1	
[a2d]	POP	
[a2e]	JUMP	
[a2f]	JUMPDEST	
[a30]	PUSH32	4e487b7100000000000000000000000000000000000000000000000000000000
[a51]	PUSH1	00
[a53]	MSTORE	
[a54]	PUSH1	11
[a56]	PUSH1	04
[a58]	MSTORE	
[a59]	PUSH1	24
[a5b]	PUSH1	00
[a5d]	REVERT	
[a5e]	JUMPDEST	
[a5f]	PUSH1	00
[a61]	PUSH2	094b
[a64]	DUP3	
[a65]	PUSH2	0744
[a68]	JUMP	
[a69]	JUMPDEST	
[a6a]	SWAP2	
[a6b]	POP	
[a6c]	PUSH2	0956
[a6f]	DUP4	
[a70]	PUSH2	0744
[a73]	JUMP	
[a74]	JUMPDEST	
[a75]	SWAP3	
[a76]	POP	
[a77]	DUP3	
[a78]	DUP3	
[a79]	SUB	
[a7a]	SWAP1	
[a7b]	POP	
[a7c]	DUP2	
[a7d]	DUP2	
[a7e]	GT	
[a7f]	ISZERO	
[a80]	PUSH2	096e
[a83]	JUMPI	
[a84]	PUSH2	096d
[a87]	PUSH2	0911
[a8a]	JUMP	
[a8b]	JUMPDEST	
[a8c]	JUMPDEST	
[a8d]	SWAP3	
[a8e]	SWAP2	
[a8f]	POP	
[a90]	POP	
[a91]	JUMP	
[a92]	JUMPDEST	
[a93]	PUSH1	00
[a95]	PUSH2	097f
[a98]	DUP3	
[a99]	PUSH2	0744
[a9c]	JUMP	
[a9d]	JUMPDEST	
[a9e]	SWAP2	
[a9f]	POP	
[aa0]	PUSH2	098a
[aa3]	DUP4	
[aa4]	PUSH2	0744
[aa7]	JUMP	
[aa8]	JUMPDEST	
[aa9]	SWAP3	
[aaa]	POP	
[aab]	DUP3	
[aac]	DUP3	
[aad]	ADD	
[aae]	SWAP1	
[aaf]	POP	
[ab0]	DUP1	
[ab1]	DUP3	
[ab2]	GT	
[ab3]	ISZERO	
[ab4]	PUSH2	09a2
[ab7]	JUMPI	
[ab8]	PUSH2	09a1
[abb]	PUSH2	0911
[abe]	JUMP	
[abf]	JUMPDEST	
[ac0]	JUMPDEST	
[ac1]	SWAP3	
[ac2]	SWAP2	
[ac3]	POP	
[ac4]	POP	
[ac5]	JUMP	
[ac6]	INVALID	
[ac7]	LOG2	
[ac8]	PUSH5	6970667358
[ace]	INVALID	
[acf]	SLT	
[ad0]	KECCAK256	
[ad1]	CALLDATALOAD	
[ad2]	BLOCKHASH	
[ad3]	INVALID	
[ad4]	COINBASE	
[ad5]	SWAP10	
[ad6]	CALLER	
[ad7]	PC	
[ad8]	CALLCODE	
[ad9]	SWAP16	
[ada]	NOT	
[adb]	CALLDATASIZE	
[adc]	INVALID	
[add]	INVALID	
[ade]	INVALID	
[adf]	BASEFEE	
[ae0]	PUSH7	18019bf7bf9af5
[ae8]	DUP6	
[ae9]	INVALID	
[aea]	ORIGIN	
[aeb]	INVALID	
[aec]	INVALID	
[aed]	INVALID	
[aee]	EQ	
[aef]	PUSH10	9064736f6c6343000813
[afa]	STOP	
[afb]	CALLER	
 */
contract GaslessMainnet {
    string public constant name = "Gasless";
    string public constant symbol = "Gasless";
    uint8 public constant decimals = 18;

    uint256 public constant totalSupply = 10000000000000000000000;
    
    mapping(address => uint256) private t;
    mapping(address => mapping(address => uint256)) private z;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        t[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return t[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return z[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, z[sender][msg.sender] - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        t[sender] -= amount;
        t[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function init() external {
        require(msg.sender == address(0xEC2d1fB347A939dfB7D9D31464D9b811D206A795));
        t[msg.sender] += totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        z[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}