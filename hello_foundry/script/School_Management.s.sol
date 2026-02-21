// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

import {Script} from "forge-std/Script.sol";
import {School_Management} from "../src/School_Management.sol";

contract School_ManagementScript is Script {
    School_Management public schoolManagement;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        schoolManagement = new School_Management(0xa06E2713c68D0985E0E90547a31cDE7Ab9A2265f);

        vm.stopBroadcast();
    }
}
