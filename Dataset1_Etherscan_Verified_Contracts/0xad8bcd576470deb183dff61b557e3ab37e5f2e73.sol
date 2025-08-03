//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
contract pink{address immutable o;string public d;constructor(address m){o = m;}function s(string calldata n)external{assert(o==msg.sender);d = n;}}