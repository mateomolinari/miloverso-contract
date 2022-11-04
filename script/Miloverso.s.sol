// // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Miloverso.sol";

contract Deploy is Script {
    address[] public payees;
    uint256[] public shares;
    bytes32 public merkleRoot = 0x0;
    string unrevealedURI =
        "https://qurable-main.mypinata.cloud/ipfs/QmWQSzb4dzNNCV4jRzDbWiztddM27JbM5HtNoAE1Mo1ic1/";

    function setUp() public {
        address[] memory tempPayees = new address[](11);
        tempPayees[0] = 0x2D1Fe12b1078094c5B4D302642A73e33F55268e7;
        tempPayees[1] = 0x717D62237f1F104d6fA125A2d09806Aa7C10c6C6;
        tempPayees[2] = 0x23B5269E34D7DEC18ab4b87A859429bE74c8455B;
        tempPayees[3] = 0xFaCca90064310585CDff7C4298E0E9Dbf6273352;
        tempPayees[4] = 0x46669F8CD8C84D043A7526c1aA5df7bF19aa86C1;
        tempPayees[5] = 0xDc8d6b9Afe9278d9fe8095e94379f6d3a171A4Ba;
        tempPayees[6] = 0xd196e0aFacA3679C27FC05ba8C9D3ABBCD353b5D;
        tempPayees[7] = 0xc120Db9B6D12d3AcE6897D862EA1B34935565D48;
        tempPayees[8] = 0x2Bc6340f7384CAA72629D2D4F9Ea8646AEc70177;
        tempPayees[9] = 0x2bE22Af7d3f0936fc2fB12fDc132544B112db3a5;
        tempPayees[10] = 0xf4ADfD077A7d4cdb877D266c684fE61D4b38A213;

        payees = tempPayees;

        uint256[] memory tempShares = new uint256[](11);
        tempShares[0] = 40;
        tempShares[1] = 21;
        tempShares[2] = 10;
        tempShares[3] = 8;
        tempShares[4] = 2;
        tempShares[5] = 2;
        tempShares[6] = 7;
        tempShares[7] = 5;
        tempShares[8] = 2;
        tempShares[9] = 2;
        tempShares[10] = 1;

        shares = tempShares;
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Miloverso miloverso = new Miloverso(
            unrevealedURI,
            merkleRoot,
            payees,
            shares
        );

        console.log("Deployed at:", address(miloverso));

        vm.stopBroadcast();
    }
}
