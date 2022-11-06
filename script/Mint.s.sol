// // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Miloverso.sol";

contract Mint is Script {
    Miloverso public milo;

    function setUp() public {
        milo = Miloverso();
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("GOERLI_TEST_KEY");
        vm.startBroadcast(deployerPrivateKey);

        milo.updateStatus(2);
        milo.publicMint{value: 0.029 ether * 3}(3);

        vm.stopBroadcast();
    }
}
