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

    function setUp() public {
        vm.prank(OWNER);
        milo = new Miloverso("unrevealed/", merkleRoot);
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
        assertEq(milo.baseURI(), "unrevealed/");
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

        vm.expectRevert(bytes("not enough eth sent"));
        milo.publicMint{value: 0.028 ether}(1);

        vm.expectRevert(bytes("not enough eth sent"));
        milo.publicMint{value: 0.057 ether}(2);

        vm.expectRevert(bytes("not enough eth sent"));
        milo.publicMint{value: 0.086 ether}(3);
    }

    function testWithdraw(address notOwner) public {
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
        assertEq(milo.baseURI(), "unrevealed/");

        vm.prank(OWNER);
        milo.reveal("revealed/");
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
        assertEq(uri, "unrevealed/0.json");
    }

    function testAuth(address notOwner) public {
        vm.assume(notOwner != address(0));
        vm.assume(notOwner != OWNER);

        vm.startPrank(notOwner);

        vm.expectRevert(NOT_OWNER);
        milo.updateStatus(1);

        vm.expectRevert(NOT_OWNER);
        milo.reveal("newuri");

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
}
