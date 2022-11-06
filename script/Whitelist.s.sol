// // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Miloverso.sol";

contract Whitelist is Script {
    Miloverso public milo;

    function setUp() public {
        milo = Miloverso(payable(0xBC56479cED29961297956f0f3ABcA6b83677b73E));
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("GOERLI_TEST_KEY");
        vm.startBroadcast(deployerPrivateKey);

        milo.updateWhitelist(
            0x40058babc838e04777a4ef7a80864d84a9b957af3f229ebe886aec9f14e9df34
        );
        // milo.updateStatus(1);

        vm.stopBroadcast();
    }
}
