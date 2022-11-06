// // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Miloverso.sol";

contract Pay is Script {
    Miloverso public milo;

    function setUp() public {
        milo = Miloverso(payable(0xBC56479cED29961297956f0f3ABcA6b83677b73E));
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("GOERLI_TEST_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address(milo).call{value: 1 ether}("");
        milo.pay();

        vm.stopBroadcast();
    }
}
