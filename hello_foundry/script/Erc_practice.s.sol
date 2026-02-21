// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

import {Script} from "forge-std/Script.sol";
import {Erc_practice} from "../src/Erc_practice.sol";

contract Erc_practiceScript is Script {
    Erc_practice public erc_practice;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        erc_practice = new Erc_practice();

        vm.stopBroadcast();
    }
}
