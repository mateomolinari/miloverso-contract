// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/ERC721A/contracts/ERC721A.sol";
import "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Miloverso is ERC721A, Ownable {
    using ECDSA for bytes32;

    uint256 public maxSupply;
    uint256 public tokenPrice;
    uint256 public status;
    bytes32 public whitelistMerkleRoot;
    string public baseURI;
    bool public revealed;
    mapping(address => bool) public claimedWhitelist;

    constructor(string memory unrevealedURI, bytes32 initialMerkleRoot)
        ERC721A("Miloverso", "MILO")
    {
        status = 0;
        baseURI = unrevealedURI;
        whitelistMerkleRoot = initialMerkleRoot;
        tokenPrice = 0.029 ether;
        maxSupply = 2_222;
    }

    // USER PUBLIC MINT
    function whitelistMint(uint256 amount, bytes32[] memory proof)
        public
        payable
    {
        require(status == 1, "whitelist mint has not started");
        require(
            MerkleProof.verify(
                proof,
                whitelistMerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "not whitelisted"
        );
        require(
            !claimedWhitelist[msg.sender],
            "whitelisetd user already claimed"
        );
        require(totalSupply() + amount <= maxSupply, "max supply reached");
        require(amount <= 3, "max mint amount is 3");
        require(msg.value >= amount * tokenPrice, "not enough eth sent");

        claimedWhitelist[msg.sender] = true;
        _mint(msg.sender, amount);
    }

    function publicMint(uint256 amount) public payable {
        require(status == 2, "public mint has not started");
        require(totalSupply() + amount <= maxSupply, "max supply reached");
        require(amount <= 3, "max mint amount is 3");
        require(msg.value >= amount * tokenPrice, "not enough eth sent");
        _mint(msg.sender, amount);
    }

    // OWNER ACTIONS
    function airdrop(address[] memory recipients, uint256[] calldata amounts)
        public
        onlyOwner
    {
        uint length = recipients.length;
        require(length == amounts.length, "different length arrays");
        for (uint i = 0; i < length; ) {
            _mint(recipients[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    function updateStatus(uint256 newStatus) public onlyOwner {
        status = newStatus;
    }

    function reveal(string memory revealedURI) public onlyOwner {
        revealed = true;
        baseURI = revealedURI;
    }

    function increaseSupply(uint256 newSupply) public onlyOwner {
        require(
            newSupply >= maxSupply && newSupply <= 11_111,
            "invalid new supply"
        );
        maxSupply = newSupply;
    }

    function updatePrice(uint256 newPrice) public onlyOwner {
        tokenPrice = newPrice;
    }

    function withdraw(address recipient) public onlyOwner {
        (bool success, ) = recipient.call{value: address(this).balance}("");
        require(success, "ether transfer failed");
    }

    function updateWhitelist(bytes32 newMerkleRoot) public onlyOwner {
        whitelistMerkleRoot = newMerkleRoot;
    }

    // OVERRIDES
    function _baseURI()
        internal
        view
        virtual
        override(ERC721A)
        returns (string memory)
    {
        return baseURI;
    }
}
