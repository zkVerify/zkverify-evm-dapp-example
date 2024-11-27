// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ZkFactorization} from "../src/ZkFactorization.sol";

contract ZkvVerifierContractScript is Script {
    ZkFactorization public zkFactorization;

    function run() public {
        vm.startBroadcast();

        address zkvContract = vm.envAddress("ETH_ZKVERIFY_CONTRACT_ADDRESS");
        bytes32 vkHash = vm.envBytes32("VK_HASH");
        zkFactorization = new ZkFactorization(zkvContract, vkHash);

        vm.stopBroadcast();
    }
}
