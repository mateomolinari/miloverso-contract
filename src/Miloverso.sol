// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/ERC721A/contracts/ERC721A.sol";

contract MiloVerso is ERC721A {
    address public owner;
    uint256 public maxSupply = 10_000;
    uint256 public constant tokenPrice = 0.1 ether;
    string public baseURI;
    SaleStatus public status;
    bytes32 public whitelistMerkleRoot;
    mapping(address => bool) public claimedWhitelist;

    enum SaleStatus {
        NOT_STARTED,
        ACTIVE,
        REVEALED
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner allowed");
        _;
    }

    constructor(
        address initialOwner,
        string memory unrevealedURI,
        bytes32 initialMerkleRoot
    ) ERC721A("Miloverso", "MILO") {
        status = SaleStatus.NOT_STARTED;
        owner = initialOwner;
        baseURI = unrevealedURI;
        whitelistMerkleRoot = initialMerkleRoot;
    }

    // USER PUBLIC MINT
    function publicMint(uint256 amount) public payable {
        require(
            status != SaleStatus.NOT_STARTED,
            "public mint has not started"
        );
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

    function ownerMint(address recipient, uint256 amount) public onlyOwner {
        _safeMint(recipient, amount);
    }

    function startMint() public onlyOwner {
        status = SaleStatus.ACTIVE;
    }

    function reveal(string memory revealedURI) public onlyOwner {
        status = SaleStatus.REVEALED;
        baseURI = revealedURI;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "address zero can't be owner");
        owner = newOwner;
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
