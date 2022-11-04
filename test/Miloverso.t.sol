// // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Miloverso.sol";

contract MiloversoTest is Test {
    Miloverso public milo;
    address deployer = vm.addr(999);
    address OWNER = vm.addr(1);
    bytes32 merkleRoot =
        0x7ebd42ada81436f0b9a7572d090431c1ac0db02f0e67ab9d4cb2a9cfd0dbbf31;

    bytes NOT_OWNER = bytes("Ownable: caller is not the owner");
    address[] public payees;
    uint256[] public shares;

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

        vm.prank(OWNER);
        milo = new Miloverso(
            "https://qurable-main.mypinata.cloud/ipfs/QmWQSzb4dzNNCV4jRzDbWiztddM27JbM5HtNoAE1Mo1ic1/",
            merkleRoot,
            payees,
            shares
        );
    }

    function makePublic() internal {
        vm.prank(OWNER);
        milo.updateStatus(2);
    }

    function testInitialVars() public {
        assertEq(milo.status(), 0);
        assertEq(milo.tokenPrice(), 0.029 ether);
        assertEq(milo.maxSupply(), 2_222);
        assertEq(milo.whitelistMerkleRoot(), merkleRoot);
        assertEq(
            milo.baseURI(),
            "https://qurable-main.mypinata.cloud/ipfs/QmWQSzb4dzNNCV4jRzDbWiztddM27JbM5HtNoAE1Mo1ic1/"
        );
        assertEq(milo.revealed(), false);
    }

    function testPublicMint() public {
        makePublic();

        vm.deal(vm.addr(1001), 10 ether);
        vm.prank(vm.addr(1001));
        milo.publicMint{value: 0.029 ether}(1);
        assertEq(milo.balanceOf(vm.addr(1001)), 1);
        assertEq(milo.totalSupply(), 1);

        vm.deal(vm.addr(1002), 10 ether);
        vm.prank(vm.addr(1002));
        milo.publicMint{value: 0.029 ether * 2}(2);
        assertEq(milo.balanceOf(vm.addr(1002)), 2);
        assertEq(milo.totalSupply(), 3);

        vm.deal(vm.addr(1003), 10 ether);
        vm.prank(vm.addr(1003));
        milo.publicMint{value: 0.029 ether * 3}(3);
        assertEq(milo.balanceOf(vm.addr(1003)), 3);
        assertEq(milo.totalSupply(), 6);
    }

    function testPublicMintWrongValue() public {
        makePublic();

        vm.expectRevert(
            abi.encodeWithSelector(
                Miloverso.WrongValueSent.selector,
                0.028 ether,
                0.029 ether
            )
        );
        milo.publicMint{value: 0.028 ether}(1);

        vm.expectRevert(
            abi.encodeWithSelector(
                Miloverso.WrongValueSent.selector,
                0.057 ether,
                0.029 ether * 2
            )
        );
        milo.publicMint{value: 0.057 ether}(2);

        vm.expectRevert(
            abi.encodeWithSelector(
                Miloverso.WrongValueSent.selector,
                0.086 ether,
                0.029 ether * 3
            )
        );
        milo.publicMint{value: 0.086 ether}(3);
    }

    function testWithdraw(address notOwner) public {
        vm.assume(notOwner != OWNER);

        vm.deal(address(milo), 100 ether);

        vm.prank(notOwner);
        vm.expectRevert(NOT_OWNER);
        milo.withdraw(notOwner);

        vm.prank(OWNER);
        milo.withdraw(vm.addr(1337));
        assertEq(address(vm.addr(1337)).balance, 100 ether);
    }

    function testTransferOwnership(address notOwner) public {
        vm.assume(notOwner != address(0));
        vm.assume(notOwner != OWNER);

        vm.prank(notOwner);
        vm.expectRevert(NOT_OWNER);
        milo.transferOwnership(notOwner);

        vm.prank(OWNER);
        milo.transferOwnership(notOwner);
        assertEq(milo.owner(), notOwner);
    }

    function testReveal() public {
        assertEq(milo.revealed(), false);
        assertEq(
            milo.baseURI(),
            "https://qurable-main.mypinata.cloud/ipfs/QmWQSzb4dzNNCV4jRzDbWiztddM27JbM5HtNoAE1Mo1ic1/"
        );

        vm.prank(OWNER);
        milo.updateRevealStatus(true, "revealed/");
        assertEq(milo.revealed(), true);
        assertEq(milo.baseURI(), "revealed/");
    }

    function testAirdrop() public {
        address[] memory recipients = new address[](800);
        uint256[] memory amounts = new uint256[](800);
        for (uint i = 0; i < 800; ) {
            recipients[i] = vm.addr(i + 1);
            amounts[i] = 1;
            unchecked {
                ++i;
            }
        }
        vm.prank(OWNER);
        milo.airdrop(recipients, amounts);
        for (uint i = 0; i < 800; ) {
            assertEq(milo.balanceOf(recipients[i]), amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    function testTokenURI() public {
        makePublic();
        milo.publicMint{value: 0.029 ether * 3}(3);
        string memory uri = milo.tokenURI(0);
        assertEq(
            uri,
            "https://qurable-main.mypinata.cloud/ipfs/QmWQSzb4dzNNCV4jRzDbWiztddM27JbM5HtNoAE1Mo1ic1/0.json"
        );
    }

    function testAuth(address notOwner) public {
        vm.assume(notOwner != address(0));
        vm.assume(notOwner != OWNER);

        vm.startPrank(notOwner);

        vm.expectRevert(NOT_OWNER);
        milo.updateStatus(1);

        vm.expectRevert(NOT_OWNER);
        milo.updateRevealStatus(true, "newuri");

        vm.expectRevert(NOT_OWNER);
        milo.increaseSupply(10000);

        vm.expectRevert(NOT_OWNER);
        milo.updatePrice(5 ether);

        vm.expectRevert(NOT_OWNER);
        milo.updateWhitelist(merkleRoot);

        address[] memory recipients = new address[](2);
        uint256[] memory amounts = new uint256[](2);

        recipients[0] = vm.addr(3223);
        recipients[1] = vm.addr(2332);
        amounts[0] = 2;
        amounts[1] = 3;
        vm.expectRevert(NOT_OWNER);
        milo.airdrop(recipients, amounts);
    }

    function testUpdatePrice() public {
        assertEq(milo.tokenPrice(), 0.029 ether);

        vm.prank(OWNER);
        milo.updatePrice(1 ether);
        assertEq(milo.tokenPrice(), 1 ether);
    }

    function testIncreaseSupply() public {
        assertEq(milo.maxSupply(), 2_222);

        vm.prank(OWNER);
        milo.increaseSupply(11_111);
        assertEq(milo.maxSupply(), 11_111);
    }

    function testPayment(uint256 contractBalance) public {
        contractBalance = bound(contractBalance, 0.05 ether, 500 ether);
        require(contractBalance >= 0.05 ether && contractBalance <= 500 ether);
        vm.deal(address(milo), contractBalance);

        vm.prank(OWNER);
        milo.pay();

        for (uint i = 0; i < payees.length; ) {
            assertEq(payees[i].balance, (contractBalance * shares[i]) / 100);
            unchecked {
                ++i;
            }
        }

        assertLt(address(milo).balance, 0.0001 ether);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
