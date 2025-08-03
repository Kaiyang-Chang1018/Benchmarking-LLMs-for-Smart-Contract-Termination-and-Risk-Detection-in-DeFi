// SPDX-License-Identifier: MIT
// Telegram: https://t.me/infinitegastoken
/*
assembly opcode: 
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
[12]	PUSH10	152d02c7e14af6800000
[1d]	PUSH1	00
[1f]	DUP1	
[20]	CALLER	
[21]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[36]	AND	
[37]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[4c]	AND	
[4d]	DUP2	
[4e]	MSTORE	
[4f]	PUSH1	20
[51]	ADD	
[52]	SWAP1	
[53]	DUP2	
[54]	MSTORE	
[55]	PUSH1	20
[57]	ADD	
[58]	PUSH1	00
[5a]	KECCAK256	
[5b]	DUP2	
[5c]	SWAP1	
[5d]	SSTORE	
[5e]	POP	
[5f]	CALLER	
[60]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[75]	AND	
[76]	PUSH1	00
[78]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[8d]	AND	
[8e]	PUSH32	ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
[af]	PUSH10	152d02c7e14af6800000
[ba]	PUSH1	40
[bc]	MLOAD	
[bd]	PUSH2	00c6
[c0]	SWAP2	
[c1]	SWAP1	
[c2]	PUSH2	00ec
[c5]	JUMP	
[c6]	JUMPDEST	
[c7]	PUSH1	40
[c9]	MLOAD	
[ca]	DUP1	
[cb]	SWAP2	
[cc]	SUB	
[cd]	SWAP1	
[ce]	LOG3	
[cf]	PUSH2	0107
[d2]	JUMP	
[d3]	JUMPDEST	
[d4]	PUSH1	00
[d6]	DUP2	
[d7]	SWAP1	
[d8]	POP	
[d9]	SWAP2	
[da]	SWAP1	
[db]	POP	
[dc]	JUMP	
[dd]	JUMPDEST	
[de]	PUSH2	00e6
[e1]	DUP2	
[e2]	PUSH2	00d3
[e5]	JUMP	
[e6]	JUMPDEST	
[e7]	DUP3	
[e8]	MSTORE	
[e9]	POP	
[ea]	POP	
[eb]	JUMP	
[ec]	JUMPDEST	
[ed]	PUSH1	00
[ef]	PUSH1	20
[f1]	DUP3	
[f2]	ADD	
[f3]	SWAP1	
[f4]	POP	
[f5]	PUSH2	0101
[f8]	PUSH1	00
[fa]	DUP4	
[fb]	ADD	
[fc]	DUP5	
[fd]	PUSH2	00dd
[100]	JUMP	
[101]	JUMPDEST	
[102]	SWAP3	
[103]	SWAP2	
[104]	POP	
[105]	POP	
[106]	JUMP	
[107]	JUMPDEST	
[108]	PUSH2	09da
[10b]	DUP1	
[10c]	PUSH2	0116
[10f]	PUSH1	00
[111]	CODECOPY	
[112]	PUSH1	00
[114]	RETURN	
[115]	INVALID	
[116]	PUSH1	80
[118]	PUSH1	40
[11a]	MSTORE	
[11b]	CALLVALUE	
[11c]	DUP1	
[11d]	ISZERO	
[11e]	PUSH2	0010
[121]	JUMPI	
[122]	PUSH1	00
[124]	DUP1	
[125]	REVERT	
[126]	JUMPDEST	
[127]	POP	
[128]	PUSH1	04
[12a]	CALLDATASIZE	
[12b]	LT	
[12c]	PUSH2	0093
[12f]	JUMPI	
[130]	PUSH1	00
[132]	CALLDATALOAD	
[133]	PUSH1	e0
[135]	SHR	
[136]	DUP1	
[137]	PUSH4	313ce567
[13c]	GT	
[13d]	PUSH2	0066
[140]	JUMPI	
[141]	DUP1	
[142]	PUSH4	313ce567
[147]	EQ	
[148]	PUSH2	0134
[14b]	JUMPI	
[14c]	DUP1	
[14d]	PUSH4	70a08231
[152]	EQ	
[153]	PUSH2	0152
[156]	JUMPI	
[157]	DUP1	
[158]	PUSH4	95d89b41
[15d]	EQ	
[15e]	PUSH2	0182
[161]	JUMPI	
[162]	DUP1	
[163]	PUSH4	a9059cbb
[168]	EQ	
[169]	PUSH2	01a0
[16c]	JUMPI	
[16d]	DUP1	
[16e]	PUSH4	dd62ed3e
[173]	EQ	
[174]	PUSH2	01d0
[177]	JUMPI	
[178]	PUSH2	0093
[17b]	JUMP	
[17c]	JUMPDEST	
[17d]	DUP1	
[17e]	PUSH4	06fdde03
[183]	EQ	
[184]	PUSH2	0098
[187]	JUMPI	
[188]	DUP1	
[189]	PUSH4	095ea7b3
[18e]	EQ	
[18f]	PUSH2	00b6
[192]	JUMPI	
[193]	DUP1	
[194]	PUSH4	18160ddd
[199]	EQ	
[19a]	PUSH2	00e6
[19d]	JUMPI	
[19e]	DUP1	
[19f]	PUSH4	23b872dd
[1a4]	EQ	
[1a5]	PUSH2	0104
[1a8]	JUMPI	
[1a9]	JUMPDEST	
[1aa]	PUSH1	00
[1ac]	DUP1	
[1ad]	REVERT	
[1ae]	JUMPDEST	
[1af]	PUSH2	00a0
[1b2]	PUSH2	0200
[1b5]	JUMP	
[1b6]	JUMPDEST	
[1b7]	PUSH1	40
[1b9]	MLOAD	
[1ba]	PUSH2	00ad
[1bd]	SWAP2	
[1be]	SWAP1	
[1bf]	PUSH2	06bb
[1c2]	JUMP	
[1c3]	JUMPDEST	
[1c4]	PUSH1	40
[1c6]	MLOAD	
[1c7]	DUP1	
[1c8]	SWAP2	
[1c9]	SUB	
[1ca]	SWAP1	
[1cb]	RETURN	
[1cc]	JUMPDEST	
[1cd]	PUSH2	00d0
[1d0]	PUSH1	04
[1d2]	DUP1	
[1d3]	CALLDATASIZE	
[1d4]	SUB	
[1d5]	DUP2	
[1d6]	ADD	
[1d7]	SWAP1	
[1d8]	PUSH2	00cb
[1db]	SWAP2	
[1dc]	SWAP1	
[1dd]	PUSH2	0776
[1e0]	JUMP	
[1e1]	JUMPDEST	
[1e2]	PUSH2	0239
[1e5]	JUMP	
[1e6]	JUMPDEST	
[1e7]	PUSH1	40
[1e9]	MLOAD	
[1ea]	PUSH2	00dd
[1ed]	SWAP2	
[1ee]	SWAP1	
[1ef]	PUSH2	07d1
[1f2]	JUMP	
[1f3]	JUMPDEST	
[1f4]	PUSH1	40
[1f6]	MLOAD	
[1f7]	DUP1	
[1f8]	SWAP2	
[1f9]	SUB	
[1fa]	SWAP1	
[1fb]	RETURN	
[1fc]	JUMPDEST	
[1fd]	PUSH2	00ee
[200]	PUSH2	0250
[203]	JUMP	
[204]	JUMPDEST	
[205]	PUSH1	40
[207]	MLOAD	
[208]	PUSH2	00fb
[20b]	SWAP2	
[20c]	SWAP1	
[20d]	PUSH2	07fb
[210]	JUMP	
[211]	JUMPDEST	
[212]	PUSH1	40
[214]	MLOAD	
[215]	DUP1	
[216]	SWAP2	
[217]	SUB	
[218]	SWAP1	
[219]	RETURN	
[21a]	JUMPDEST	
[21b]	PUSH2	011e
[21e]	PUSH1	04
[220]	DUP1	
[221]	CALLDATASIZE	
[222]	SUB	
[223]	DUP2	
[224]	ADD	
[225]	SWAP1	
[226]	PUSH2	0119
[229]	SWAP2	
[22a]	SWAP1	
[22b]	PUSH2	0816
[22e]	JUMP	
[22f]	JUMPDEST	
[230]	PUSH2	025e
[233]	JUMP	
[234]	JUMPDEST	
[235]	PUSH1	40
[237]	MLOAD	
[238]	PUSH2	012b
[23b]	SWAP2	
[23c]	SWAP1	
[23d]	PUSH2	07d1
[240]	JUMP	
[241]	JUMPDEST	
[242]	PUSH1	40
[244]	MLOAD	
[245]	DUP1	
[246]	SWAP2	
[247]	SUB	
[248]	SWAP1	
[249]	RETURN	
[24a]	JUMPDEST	
[24b]	PUSH2	013c
[24e]	PUSH2	0308
[251]	JUMP	
[252]	JUMPDEST	
[253]	PUSH1	40
[255]	MLOAD	
[256]	PUSH2	0149
[259]	SWAP2	
[25a]	SWAP1	
[25b]	PUSH2	0885
[25e]	JUMP	
[25f]	JUMPDEST	
[260]	PUSH1	40
[262]	MLOAD	
[263]	DUP1	
[264]	SWAP2	
[265]	SUB	
[266]	SWAP1	
[267]	RETURN	
[268]	JUMPDEST	
[269]	PUSH2	016c
[26c]	PUSH1	04
[26e]	DUP1	
[26f]	CALLDATASIZE	
[270]	SUB	
[271]	DUP2	
[272]	ADD	
[273]	SWAP1	
[274]	PUSH2	0167
[277]	SWAP2	
[278]	SWAP1	
[279]	PUSH2	08a0
[27c]	JUMP	
[27d]	JUMPDEST	
[27e]	PUSH2	030d
[281]	JUMP	
[282]	JUMPDEST	
[283]	PUSH1	40
[285]	MLOAD	
[286]	PUSH2	0179
[289]	SWAP2	
[28a]	SWAP1	
[28b]	PUSH2	07fb
[28e]	JUMP	
[28f]	JUMPDEST	
[290]	PUSH1	40
[292]	MLOAD	
[293]	DUP1	
[294]	SWAP2	
[295]	SUB	
[296]	SWAP1	
[297]	RETURN	
[298]	JUMPDEST	
[299]	PUSH2	018a
[29c]	PUSH2	0355
[29f]	JUMP	
[2a0]	JUMPDEST	
[2a1]	PUSH1	40
[2a3]	MLOAD	
[2a4]	PUSH2	0197
[2a7]	SWAP2	
[2a8]	SWAP1	
[2a9]	PUSH2	06bb
[2ac]	JUMP	
[2ad]	JUMPDEST	
[2ae]	PUSH1	40
[2b0]	MLOAD	
[2b1]	DUP1	
[2b2]	SWAP2	
[2b3]	SUB	
[2b4]	SWAP1	
[2b5]	RETURN	
[2b6]	JUMPDEST	
[2b7]	PUSH2	01ba
[2ba]	PUSH1	04
[2bc]	DUP1	
[2bd]	CALLDATASIZE	
[2be]	SUB	
[2bf]	DUP2	
[2c0]	ADD	
[2c1]	SWAP1	
[2c2]	PUSH2	01b5
[2c5]	SWAP2	
[2c6]	SWAP1	
[2c7]	PUSH2	0776
[2ca]	JUMP	
[2cb]	JUMPDEST	
[2cc]	PUSH2	038e
[2cf]	JUMP	
[2d0]	JUMPDEST	
[2d1]	PUSH1	40
[2d3]	MLOAD	
[2d4]	PUSH2	01c7
[2d7]	SWAP2	
[2d8]	SWAP1	
[2d9]	PUSH2	07d1
[2dc]	JUMP	
[2dd]	JUMPDEST	
[2de]	PUSH1	40
[2e0]	MLOAD	
[2e1]	DUP1	
[2e2]	SWAP2	
[2e3]	SUB	
[2e4]	SWAP1	
[2e5]	RETURN	
[2e6]	JUMPDEST	
[2e7]	PUSH2	01ea
[2ea]	PUSH1	04
[2ec]	DUP1	
[2ed]	CALLDATASIZE	
[2ee]	SUB	
[2ef]	DUP2	
[2f0]	ADD	
[2f1]	SWAP1	
[2f2]	PUSH2	01e5
[2f5]	SWAP2	
[2f6]	SWAP1	
[2f7]	PUSH2	08cd
[2fa]	JUMP	
[2fb]	JUMPDEST	
[2fc]	PUSH2	03a5
[2ff]	JUMP	
[300]	JUMPDEST	
[301]	PUSH1	40
[303]	MLOAD	
[304]	PUSH2	01f7
[307]	SWAP2	
[308]	SWAP1	
[309]	PUSH2	07fb
[30c]	JUMP	
[30d]	JUMPDEST	
[30e]	PUSH1	40
[310]	MLOAD	
[311]	DUP1	
[312]	SWAP2	
[313]	SUB	
[314]	SWAP1	
[315]	RETURN	
[316]	JUMPDEST	
[317]	PUSH1	40
[319]	MLOAD	
[31a]	DUP1	
[31b]	PUSH1	40
[31d]	ADD	
[31e]	PUSH1	40
[320]	MSTORE	
[321]	DUP1	
[322]	PUSH1	0c
[324]	DUP2	
[325]	MSTORE	
[326]	PUSH1	20
[328]	ADD	
[329]	PUSH32	496e66696e697465204741530000000000000000000000000000000000000000
[34a]	DUP2	
[34b]	MSTORE	
[34c]	POP	
[34d]	DUP2	
[34e]	JUMP	
[34f]	JUMPDEST	
[350]	PUSH1	00
[352]	PUSH2	0246
[355]	CALLER	
[356]	DUP5	
[357]	DUP5	
[358]	PUSH2	042c
[35b]	JUMP	
[35c]	JUMPDEST	
[35d]	PUSH1	01
[35f]	SWAP1	
[360]	POP	
[361]	SWAP3	
[362]	SWAP2	
[363]	POP	
[364]	POP	
[365]	JUMP	
[366]	JUMPDEST	
[367]	PUSH10	152d02c7e14af6800000
[372]	DUP2	
[373]	JUMP	
[374]	JUMPDEST	
[375]	PUSH1	00
[377]	PUSH2	026b
[37a]	DUP5	
[37b]	DUP5	
[37c]	DUP5	
[37d]	PUSH2	0517
[380]	JUMP	
[381]	JUMPDEST	
[382]	PUSH2	02fd
[385]	DUP5	
[386]	CALLER	
[387]	DUP5	
[388]	PUSH1	01
[38a]	PUSH1	00
[38c]	DUP10	
[38d]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[3a2]	AND	
[3a3]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[3b8]	AND	
[3b9]	DUP2	
[3ba]	MSTORE	
[3bb]	PUSH1	20
[3bd]	ADD	
[3be]	SWAP1	
[3bf]	DUP2	
[3c0]	MSTORE	
[3c1]	PUSH1	20
[3c3]	ADD	
[3c4]	PUSH1	00
[3c6]	KECCAK256	
[3c7]	PUSH1	00
[3c9]	CALLER	
[3ca]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[3df]	AND	
[3e0]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[3f5]	AND	
[3f6]	DUP2	
[3f7]	MSTORE	
[3f8]	PUSH1	20
[3fa]	ADD	
[3fb]	SWAP1	
[3fc]	DUP2	
[3fd]	MSTORE	
[3fe]	PUSH1	20
[400]	ADD	
[401]	PUSH1	00
[403]	KECCAK256	
[404]	SLOAD	
[405]	PUSH2	02f8
[408]	SWAP2	
[409]	SWAP1	
[40a]	PUSH2	093c
[40d]	JUMP	
[40e]	JUMPDEST	
[40f]	PUSH2	042c
[412]	JUMP	
[413]	JUMPDEST	
[414]	PUSH1	01
[416]	SWAP1	
[417]	POP	
[418]	SWAP4	
[419]	SWAP3	
[41a]	POP	
[41b]	POP	
[41c]	POP	
[41d]	JUMP	
[41e]	JUMPDEST	
[41f]	PUSH1	12
[421]	DUP2	
[422]	JUMP	
[423]	JUMPDEST	
[424]	PUSH1	00
[426]	DUP1	
[427]	PUSH1	00
[429]	DUP4	
[42a]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[43f]	AND	
[440]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[455]	AND	
[456]	DUP2	
[457]	MSTORE	
[458]	PUSH1	20
[45a]	ADD	
[45b]	SWAP1	
[45c]	DUP2	
[45d]	MSTORE	
[45e]	PUSH1	20
[460]	ADD	
[461]	PUSH1	00
[463]	KECCAK256	
[464]	SLOAD	
[465]	SWAP1	
[466]	POP	
[467]	SWAP2	
[468]	SWAP1	
[469]	POP	
[46a]	JUMP	
[46b]	JUMPDEST	
[46c]	PUSH1	40
[46e]	MLOAD	
[46f]	DUP1	
[470]	PUSH1	40
[472]	ADD	
[473]	PUSH1	40
[475]	MSTORE	
[476]	DUP1	
[477]	PUSH1	04
[479]	DUP2	
[47a]	MSTORE	
[47b]	PUSH1	20
[47d]	ADD	
[47e]	PUSH32	4947415300000000000000000000000000000000000000000000000000000000
[49f]	DUP2	
[4a0]	MSTORE	
[4a1]	POP	
[4a2]	DUP2	
[4a3]	JUMP	
[4a4]	JUMPDEST	
[4a5]	PUSH1	00
[4a7]	PUSH2	039b
[4aa]	CALLER	
[4ab]	DUP5	
[4ac]	DUP5	
[4ad]	PUSH2	0517
[4b0]	JUMP	
[4b1]	JUMPDEST	
[4b2]	PUSH1	01
[4b4]	SWAP1	
[4b5]	POP	
[4b6]	SWAP3	
[4b7]	SWAP2	
[4b8]	POP	
[4b9]	POP	
[4ba]	JUMP	
[4bb]	JUMPDEST	
[4bc]	PUSH1	00
[4be]	PUSH1	01
[4c0]	PUSH1	00
[4c2]	DUP5	
[4c3]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[4d8]	AND	
[4d9]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[4ee]	AND	
[4ef]	DUP2	
[4f0]	MSTORE	
[4f1]	PUSH1	20
[4f3]	ADD	
[4f4]	SWAP1	
[4f5]	DUP2	
[4f6]	MSTORE	
[4f7]	PUSH1	20
[4f9]	ADD	
[4fa]	PUSH1	00
[4fc]	KECCAK256	
[4fd]	PUSH1	00
[4ff]	DUP4	
[500]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[515]	AND	
[516]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[52b]	AND	
[52c]	DUP2	
[52d]	MSTORE	
[52e]	PUSH1	20
[530]	ADD	
[531]	SWAP1	
[532]	DUP2	
[533]	MSTORE	
[534]	PUSH1	20
[536]	ADD	
[537]	PUSH1	00
[539]	KECCAK256	
[53a]	SLOAD	
[53b]	SWAP1	
[53c]	POP	
[53d]	SWAP3	
[53e]	SWAP2	
[53f]	POP	
[540]	POP	
[541]	JUMP	
[542]	JUMPDEST	
[543]	DUP1	
[544]	PUSH1	01
[546]	PUSH1	00
[548]	DUP6	
[549]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[55e]	AND	
[55f]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[574]	AND	
[575]	DUP2	
[576]	MSTORE	
[577]	PUSH1	20
[579]	ADD	
[57a]	SWAP1	
[57b]	DUP2	
[57c]	MSTORE	
[57d]	PUSH1	20
[57f]	ADD	
[580]	PUSH1	00
[582]	KECCAK256	
[583]	PUSH1	00
[585]	DUP5	
[586]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[59b]	AND	
[59c]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[5b1]	AND	
[5b2]	DUP2	
[5b3]	MSTORE	
[5b4]	PUSH1	20
[5b6]	ADD	
[5b7]	SWAP1	
[5b8]	DUP2	
[5b9]	MSTORE	
[5ba]	PUSH1	20
[5bc]	ADD	
[5bd]	PUSH1	00
[5bf]	KECCAK256	
[5c0]	DUP2	
[5c1]	SWAP1	
[5c2]	SSTORE	
[5c3]	POP	
[5c4]	DUP2	
[5c5]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[5da]	AND	
[5db]	DUP4	
[5dc]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[5f1]	AND	
[5f2]	PUSH32	8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925
[613]	DUP4	
[614]	PUSH1	40
[616]	MLOAD	
[617]	PUSH2	050a
[61a]	SWAP2	
[61b]	SWAP1	
[61c]	PUSH2	07fb
[61f]	JUMP	
[620]	JUMPDEST	
[621]	PUSH1	40
[623]	MLOAD	
[624]	DUP1	
[625]	SWAP2	
[626]	SUB	
[627]	SWAP1	
[628]	LOG3	
[629]	POP	
[62a]	POP	
[62b]	POP	
[62c]	JUMP	
[62d]	JUMPDEST	
[62e]	DUP1	
[62f]	PUSH1	00
[631]	DUP1	
[632]	DUP6	
[633]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[648]	AND	
[649]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[65e]	AND	
[65f]	DUP2	
[660]	MSTORE	
[661]	PUSH1	20
[663]	ADD	
[664]	SWAP1	
[665]	DUP2	
[666]	MSTORE	
[667]	PUSH1	20
[669]	ADD	
[66a]	PUSH1	00
[66c]	KECCAK256	
[66d]	PUSH1	00
[66f]	DUP3	
[670]	DUP3	
[671]	SLOAD	
[672]	PUSH2	0565
[675]	SWAP2	
[676]	SWAP1	
[677]	PUSH2	093c
[67a]	JUMP	
[67b]	JUMPDEST	
[67c]	SWAP3	
[67d]	POP	
[67e]	POP	
[67f]	DUP2	
[680]	SWAP1	
[681]	SSTORE	
[682]	POP	
[683]	DUP1	
[684]	PUSH1	00
[686]	DUP1	
[687]	DUP5	
[688]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[69d]	AND	
[69e]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[6b3]	AND	
[6b4]	DUP2	
[6b5]	MSTORE	
[6b6]	PUSH1	20
[6b8]	ADD	
[6b9]	SWAP1	
[6ba]	DUP2	
[6bb]	MSTORE	
[6bc]	PUSH1	20
[6be]	ADD	
[6bf]	PUSH1	00
[6c1]	KECCAK256	
[6c2]	PUSH1	00
[6c4]	DUP3	
[6c5]	DUP3	
[6c6]	SLOAD	
[6c7]	PUSH2	05ba
[6ca]	SWAP2	
[6cb]	SWAP1	
[6cc]	PUSH2	0970
[6cf]	JUMP	
[6d0]	JUMPDEST	
[6d1]	SWAP3	
[6d2]	POP	
[6d3]	POP	
[6d4]	DUP2	
[6d5]	SWAP1	
[6d6]	SSTORE	
[6d7]	POP	
[6d8]	DUP2	
[6d9]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[6ee]	AND	
[6ef]	DUP4	
[6f0]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[705]	AND	
[706]	PUSH32	ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
[727]	DUP4	
[728]	PUSH1	40
[72a]	MLOAD	
[72b]	PUSH2	061e
[72e]	SWAP2	
[72f]	SWAP1	
[730]	PUSH2	07fb
[733]	JUMP	
[734]	JUMPDEST	
[735]	PUSH1	40
[737]	MLOAD	
[738]	DUP1	
[739]	SWAP2	
[73a]	SUB	
[73b]	SWAP1	
[73c]	LOG3	
[73d]	POP	
[73e]	POP	
[73f]	POP	
[740]	JUMP	
[741]	JUMPDEST	
[742]	PUSH1	00
[744]	DUP2	
[745]	MLOAD	
[746]	SWAP1	
[747]	POP	
[748]	SWAP2	
[749]	SWAP1	
[74a]	POP	
[74b]	JUMP	
[74c]	JUMPDEST	
[74d]	PUSH1	00
[74f]	DUP3	
[750]	DUP3	
[751]	MSTORE	
[752]	PUSH1	20
[754]	DUP3	
[755]	ADD	
[756]	SWAP1	
[757]	POP	
[758]	SWAP3	
[759]	SWAP2	
[75a]	POP	
[75b]	POP	
[75c]	JUMP	
[75d]	JUMPDEST	
[75e]	PUSH1	00
[760]	JUMPDEST	
[761]	DUP4	
[762]	DUP2	
[763]	LT	
[764]	ISZERO	
[765]	PUSH2	0665
[768]	JUMPI	
[769]	DUP1	
[76a]	DUP3	
[76b]	ADD	
[76c]	MLOAD	
[76d]	DUP2	
[76e]	DUP5	
[76f]	ADD	
[770]	MSTORE	
[771]	PUSH1	20
[773]	DUP2	
[774]	ADD	
[775]	SWAP1	
[776]	POP	
[777]	PUSH2	064a
[77a]	JUMP	
[77b]	JUMPDEST	
[77c]	PUSH1	00
[77e]	DUP5	
[77f]	DUP5	
[780]	ADD	
[781]	MSTORE	
[782]	POP	
[783]	POP	
[784]	POP	
[785]	POP	
[786]	JUMP	
[787]	JUMPDEST	
[788]	PUSH1	00
[78a]	PUSH1	1f
[78c]	NOT	
[78d]	PUSH1	1f
[78f]	DUP4	
[790]	ADD	
[791]	AND	
[792]	SWAP1	
[793]	POP	
[794]	SWAP2	
[795]	SWAP1	
[796]	POP	
[797]	JUMP	
[798]	JUMPDEST	
[799]	PUSH1	00
[79b]	PUSH2	068d
[79e]	DUP3	
[79f]	PUSH2	062b
[7a2]	JUMP	
[7a3]	JUMPDEST	
[7a4]	PUSH2	0697
[7a7]	DUP2	
[7a8]	DUP6	
[7a9]	PUSH2	0636
[7ac]	JUMP	
[7ad]	JUMPDEST	
[7ae]	SWAP4	
[7af]	POP	
[7b0]	PUSH2	06a7
[7b3]	DUP2	
[7b4]	DUP6	
[7b5]	PUSH1	20
[7b7]	DUP7	
[7b8]	ADD	
[7b9]	PUSH2	0647
[7bc]	JUMP	
[7bd]	JUMPDEST	
[7be]	PUSH2	06b0
[7c1]	DUP2	
[7c2]	PUSH2	0671
[7c5]	JUMP	
[7c6]	JUMPDEST	
[7c7]	DUP5	
[7c8]	ADD	
[7c9]	SWAP2	
[7ca]	POP	
[7cb]	POP	
[7cc]	SWAP3	
[7cd]	SWAP2	
[7ce]	POP	
[7cf]	POP	
[7d0]	JUMP	
[7d1]	JUMPDEST	
[7d2]	PUSH1	00
[7d4]	PUSH1	20
[7d6]	DUP3	
[7d7]	ADD	
[7d8]	SWAP1	
[7d9]	POP	
[7da]	DUP2	
[7db]	DUP2	
[7dc]	SUB	
[7dd]	PUSH1	00
[7df]	DUP4	
[7e0]	ADD	
[7e1]	MSTORE	
[7e2]	PUSH2	06d5
[7e5]	DUP2	
[7e6]	DUP5	
[7e7]	PUSH2	0682
[7ea]	JUMP	
[7eb]	JUMPDEST	
[7ec]	SWAP1	
[7ed]	POP	
[7ee]	SWAP3	
[7ef]	SWAP2	
[7f0]	POP	
[7f1]	POP	
[7f2]	JUMP	
[7f3]	JUMPDEST	
[7f4]	PUSH1	00
[7f6]	DUP1	
[7f7]	REVERT	
[7f8]	JUMPDEST	
[7f9]	PUSH1	00
[7fb]	PUSH20	ffffffffffffffffffffffffffffffffffffffff
[810]	DUP3	
[811]	AND	
[812]	SWAP1	
[813]	POP	
[814]	SWAP2	
[815]	SWAP1	
[816]	POP	
[817]	JUMP	
[818]	JUMPDEST	
[819]	PUSH1	00
[81b]	PUSH2	070d
[81e]	DUP3	
[81f]	PUSH2	06e2
[822]	JUMP	
[823]	JUMPDEST	
[824]	SWAP1	
[825]	POP	
[826]	SWAP2	
[827]	SWAP1	
[828]	POP	
[829]	JUMP	
[82a]	JUMPDEST	
[82b]	PUSH2	071d
[82e]	DUP2	
[82f]	PUSH2	0702
[832]	JUMP	
[833]	JUMPDEST	
[834]	DUP2	
[835]	EQ	
[836]	PUSH2	0728
[839]	JUMPI	
[83a]	PUSH1	00
[83c]	DUP1	
[83d]	REVERT	
[83e]	JUMPDEST	
[83f]	POP	
[840]	JUMP	
[841]	JUMPDEST	
[842]	PUSH1	00
[844]	DUP2	
[845]	CALLDATALOAD	
[846]	SWAP1	
[847]	POP	
[848]	PUSH2	073a
[84b]	DUP2	
[84c]	PUSH2	0714
[84f]	JUMP	
[850]	JUMPDEST	
[851]	SWAP3	
[852]	SWAP2	
[853]	POP	
[854]	POP	
[855]	JUMP	
[856]	JUMPDEST	
[857]	PUSH1	00
[859]	DUP2	
[85a]	SWAP1	
[85b]	POP	
[85c]	SWAP2	
[85d]	SWAP1	
[85e]	POP	
[85f]	JUMP	
[860]	JUMPDEST	
[861]	PUSH2	0753
[864]	DUP2	
[865]	PUSH2	0740
[868]	JUMP	
[869]	JUMPDEST	
[86a]	DUP2	
[86b]	EQ	
[86c]	PUSH2	075e
[86f]	JUMPI	
[870]	PUSH1	00
[872]	DUP1	
[873]	REVERT	
[874]	JUMPDEST	
[875]	POP	
[876]	JUMP	
[877]	JUMPDEST	
[878]	PUSH1	00
[87a]	DUP2	
[87b]	CALLDATALOAD	
[87c]	SWAP1	
[87d]	POP	
[87e]	PUSH2	0770
[881]	DUP2	
[882]	PUSH2	074a
[885]	JUMP	
[886]	JUMPDEST	
[887]	SWAP3	
[888]	SWAP2	
[889]	POP	
[88a]	POP	
[88b]	JUMP	
[88c]	JUMPDEST	
[88d]	PUSH1	00
[88f]	DUP1	
[890]	PUSH1	40
[892]	DUP4	
[893]	DUP6	
[894]	SUB	
[895]	SLT	
[896]	ISZERO	
[897]	PUSH2	078d
[89a]	JUMPI	
[89b]	PUSH2	078c
[89e]	PUSH2	06dd
[8a1]	JUMP	
[8a2]	JUMPDEST	
[8a3]	JUMPDEST	
[8a4]	PUSH1	00
[8a6]	PUSH2	079b
[8a9]	DUP6	
[8aa]	DUP3	
[8ab]	DUP7	
[8ac]	ADD	
[8ad]	PUSH2	072b
[8b0]	JUMP	
[8b1]	JUMPDEST	
[8b2]	SWAP3	
[8b3]	POP	
[8b4]	POP	
[8b5]	PUSH1	20
[8b7]	PUSH2	07ac
[8ba]	DUP6	
[8bb]	DUP3	
[8bc]	DUP7	
[8bd]	ADD	
[8be]	PUSH2	0761
[8c1]	JUMP	
[8c2]	JUMPDEST	
[8c3]	SWAP2	
[8c4]	POP	
[8c5]	POP	
[8c6]	SWAP3	
[8c7]	POP	
[8c8]	SWAP3	
[8c9]	SWAP1	
[8ca]	POP	
[8cb]	JUMP	
[8cc]	JUMPDEST	
[8cd]	PUSH1	00
[8cf]	DUP2	
[8d0]	ISZERO	
[8d1]	ISZERO	
[8d2]	SWAP1	
[8d3]	POP	
[8d4]	SWAP2	
[8d5]	SWAP1	
[8d6]	POP	
[8d7]	JUMP	
[8d8]	JUMPDEST	
[8d9]	PUSH2	07cb
[8dc]	DUP2	
[8dd]	PUSH2	07b6
[8e0]	JUMP	
[8e1]	JUMPDEST	
[8e2]	DUP3	
[8e3]	MSTORE	
[8e4]	POP	
[8e5]	POP	
[8e6]	JUMP	
[8e7]	JUMPDEST	
[8e8]	PUSH1	00
[8ea]	PUSH1	20
[8ec]	DUP3	
[8ed]	ADD	
[8ee]	SWAP1	
[8ef]	POP	
[8f0]	PUSH2	07e6
[8f3]	PUSH1	00
[8f5]	DUP4	
[8f6]	ADD	
[8f7]	DUP5	
[8f8]	PUSH2	07c2
[8fb]	JUMP	
[8fc]	JUMPDEST	
[8fd]	SWAP3	
[8fe]	SWAP2	
[8ff]	POP	
[900]	POP	
[901]	JUMP	
[902]	JUMPDEST	
[903]	PUSH2	07f5
[906]	DUP2	
[907]	PUSH2	0740
[90a]	JUMP	
[90b]	JUMPDEST	
[90c]	DUP3	
[90d]	MSTORE	
[90e]	POP	
[90f]	POP	
[910]	JUMP	
[911]	JUMPDEST	
[912]	PUSH1	00
[914]	PUSH1	20
[916]	DUP3	
[917]	ADD	
[918]	SWAP1	
[919]	POP	
[91a]	PUSH2	0810
[91d]	PUSH1	00
[91f]	DUP4	
[920]	ADD	
[921]	DUP5	
[922]	PUSH2	07ec
[925]	JUMP	
[926]	JUMPDEST	
[927]	SWAP3	
[928]	SWAP2	
[929]	POP	
[92a]	POP	
[92b]	JUMP	
[92c]	JUMPDEST	
[92d]	PUSH1	00
[92f]	DUP1	
[930]	PUSH1	00
[932]	PUSH1	60
[934]	DUP5	
[935]	DUP7	
[936]	SUB	
[937]	SLT	
[938]	ISZERO	
[939]	PUSH2	082f
[93c]	JUMPI	
[93d]	PUSH2	082e
[940]	PUSH2	06dd
[943]	JUMP	
[944]	JUMPDEST	
[945]	JUMPDEST	
[946]	PUSH1	00
[948]	PUSH2	083d
[94b]	DUP7	
[94c]	DUP3	
[94d]	DUP8	
[94e]	ADD	
[94f]	PUSH2	072b
[952]	JUMP	
[953]	JUMPDEST	
[954]	SWAP4	
[955]	POP	
[956]	POP	
[957]	PUSH1	20
[959]	PUSH2	084e
[95c]	DUP7	
[95d]	DUP3	
[95e]	DUP8	
[95f]	ADD	
[960]	PUSH2	072b
[963]	JUMP	
[964]	JUMPDEST	
[965]	SWAP3	
[966]	POP	
[967]	POP	
[968]	PUSH1	40
[96a]	PUSH2	085f
[96d]	DUP7	
[96e]	DUP3	
[96f]	DUP8	
[970]	ADD	
[971]	PUSH2	0761
[974]	JUMP	
[975]	JUMPDEST	
[976]	SWAP2	
[977]	POP	
[978]	POP	
[979]	SWAP3	
[97a]	POP	
[97b]	SWAP3	
[97c]	POP	
[97d]	SWAP3	
[97e]	JUMP	
[97f]	JUMPDEST	
[980]	PUSH1	00
[982]	PUSH1	ff
[984]	DUP3	
[985]	AND	
[986]	SWAP1	
[987]	POP	
[988]	SWAP2	
[989]	SWAP1	
[98a]	POP	
[98b]	JUMP	
[98c]	JUMPDEST	
[98d]	PUSH2	087f
[990]	DUP2	
[991]	PUSH2	0869
[994]	JUMP	
[995]	JUMPDEST	
[996]	DUP3	
[997]	MSTORE	
[998]	POP	
[999]	POP	
[99a]	JUMP	
[99b]	JUMPDEST	
[99c]	PUSH1	00
[99e]	PUSH1	20
[9a0]	DUP3	
[9a1]	ADD	
[9a2]	SWAP1	
[9a3]	POP	
[9a4]	PUSH2	089a
[9a7]	PUSH1	00
[9a9]	DUP4	
[9aa]	ADD	
[9ab]	DUP5	
[9ac]	PUSH2	0876
[9af]	JUMP	
[9b0]	JUMPDEST	
[9b1]	SWAP3	
[9b2]	SWAP2	
[9b3]	POP	
[9b4]	POP	
[9b5]	JUMP	
[9b6]	JUMPDEST	
[9b7]	PUSH1	00
[9b9]	PUSH1	20
[9bb]	DUP3	
[9bc]	DUP5	
[9bd]	SUB	
[9be]	SLT	
[9bf]	ISZERO	
[9c0]	PUSH2	08b6
[9c3]	JUMPI	
[9c4]	PUSH2	08b5
[9c7]	PUSH2	06dd
[9ca]	JUMP	
[9cb]	JUMPDEST	
[9cc]	JUMPDEST	
[9cd]	PUSH1	00
[9cf]	PUSH2	08c4
[9d2]	DUP5	
[9d3]	DUP3	
[9d4]	DUP6	
[9d5]	ADD	
[9d6]	PUSH2	072b
[9d9]	JUMP	
[9da]	JUMPDEST	
[9db]	SWAP2	
[9dc]	POP	
[9dd]	POP	
[9de]	SWAP3	
[9df]	SWAP2	
[9e0]	POP	
[9e1]	POP	
[9e2]	JUMP	
[9e3]	JUMPDEST	
[9e4]	PUSH1	00
[9e6]	DUP1	
[9e7]	PUSH1	40
[9e9]	DUP4	
[9ea]	DUP6	
[9eb]	SUB	
[9ec]	SLT	
[9ed]	ISZERO	
[9ee]	PUSH2	08e4
[9f1]	JUMPI	
[9f2]	PUSH2	08e3
[9f5]	PUSH2	06dd
[9f8]	JUMP	
[9f9]	JUMPDEST	
[9fa]	JUMPDEST	
[9fb]	PUSH1	00
[9fd]	PUSH2	08f2
[a00]	DUP6	
[a01]	DUP3	
[a02]	DUP7	
[a03]	ADD	
[a04]	PUSH2	072b
[a07]	JUMP	
[a08]	JUMPDEST	
[a09]	SWAP3	
[a0a]	POP	
[a0b]	POP	
[a0c]	PUSH1	20
[a0e]	PUSH2	0903
[a11]	DUP6	
[a12]	DUP3	
[a13]	DUP7	
[a14]	ADD	
[a15]	PUSH2	072b
[a18]	JUMP	
[a19]	JUMPDEST	
[a1a]	SWAP2	
[a1b]	POP	
[a1c]	POP	
[a1d]	SWAP3	
[a1e]	POP	
[a1f]	SWAP3	
[a20]	SWAP1	
[a21]	POP	
[a22]	JUMP	
[a23]	JUMPDEST	
[a24]	PUSH32	4e487b7100000000000000000000000000000000000000000000000000000000
[a45]	PUSH1	00
[a47]	MSTORE	
[a48]	PUSH1	11
[a4a]	PUSH1	04
[a4c]	MSTORE	
[a4d]	PUSH1	24
[a4f]	PUSH1	00
[a51]	REVERT	
[a52]	JUMPDEST	
[a53]	PUSH1	00
[a55]	PUSH2	0947
[a58]	DUP3	
[a59]	PUSH2	0740
[a5c]	JUMP	
[a5d]	JUMPDEST	
[a5e]	SWAP2	
[a5f]	POP	
[a60]	PUSH2	0952
[a63]	DUP4	
[a64]	PUSH2	0740
[a67]	JUMP	
[a68]	JUMPDEST	
[a69]	SWAP3	
[a6a]	POP	
[a6b]	DUP3	
[a6c]	DUP3	
[a6d]	SUB	
[a6e]	SWAP1	
[a6f]	POP	
[a70]	DUP2	
[a71]	DUP2	
[a72]	GT	
[a73]	ISZERO	
[a74]	PUSH2	096a
[a77]	JUMPI	
[a78]	PUSH2	0969
[a7b]	PUSH2	090d
[a7e]	JUMP	
[a7f]	JUMPDEST	
[a80]	JUMPDEST	
[a81]	SWAP3	
[a82]	SWAP2	
[a83]	POP	
[a84]	POP	
[a85]	JUMP	
[a86]	JUMPDEST	
[a87]	PUSH1	00
[a89]	PUSH2	097b
[a8c]	DUP3	
[a8d]	PUSH2	0740
[a90]	JUMP	
[a91]	JUMPDEST	
[a92]	SWAP2	
[a93]	POP	
[a94]	PUSH2	0986
[a97]	DUP4	
[a98]	PUSH2	0740
[a9b]	JUMP	
[a9c]	JUMPDEST	
[a9d]	SWAP3	
[a9e]	POP	
[a9f]	DUP3	
[aa0]	DUP3	
[aa1]	ADD	
[aa2]	SWAP1	
[aa3]	POP	
[aa4]	DUP1	
[aa5]	DUP3	
[aa6]	GT	
[aa7]	ISZERO	
[aa8]	PUSH2	099e
[aab]	JUMPI	
[aac]	PUSH2	099d
[aaf]	PUSH2	090d
[ab2]	JUMP	
[ab3]	JUMPDEST	
[ab4]	JUMPDEST	
[ab5]	SWAP3	
[ab6]	SWAP2	
[ab7]	POP	
[ab8]	POP	
[ab9]	JUMP	
[aba]	INVALID	
[abb]	LOG2	
[abc]	PUSH5	6970667358
[ac2]	INVALID	
[ac3]	SLT	
[ac4]	KECCAK256	
[ac5]	INVALID	
[ac6]	NUMBER	
[ac7]	EQ	
[ac8]	LOG1	
[ac9]	CALLDATASIZE	
[aca]	INVALID	
[acb]	MULMOD	
[acc]	EXTCODEHASH	
[acd]	INVALID	
[ace]	CALL	
[acf]	INVALID	
[ad0]	SWAP15	
[ad1]	EXP	
[ad2]	INVALID	
[ad3]	INVALID	
[ad4]	SWAP12	
[ad5]	SIGNEXTEND	
[ad6]	INVALID	
[ad7]	INVALID	
[ad8]	PUSH30	3b8075bd604db89ce940aee364736f6c63430008130033
 */

pragma solidity ^0.8.25;

contract infinitegasforethereum {
    string public constant name = "Infinite GAS"; 
    string public constant symbol = "IGAS";  
    uint8 public constant decimals = 18;

    uint256 public constant totalSupply = 100000000000000000000000;
    
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

    function _approve(address owner, address spender, uint256 amount) internal {
        z[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}