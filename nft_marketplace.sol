// SPDX-License-Identifier: GPL-3.0
// Import necessary modules
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Create a contract for the NFT platform
contract NFTPlatform is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Create a struct for paintings
    struct Painting {
        uint256 id;
        address payable owner;
        string name;
        string artist;
        string description;
        uint256 price;
    }

    // Create an array of paintings
    Painting[] public paintings;

    // Create a mapping of NFTs to paintings
    mapping (uint256 => Painting) public nftToPainting;

    // Create an event for when a new painting is listed
    event PaintingListed(uint256 id, address owner, string name, uint256 price);

    // Create a constructor for the NFT platform
    constructor() ERC721("NFTPlatform", "NFTP") {}

    // Create a function to list a new painting for sale
    function listPainting(string memory _name, string memory _artist, string memory _description, uint256 _price) public returns (uint256) {
        _tokenIds.increment();
        uint256 newPaintingId = _tokenIds.current();

        // Mint an NFT for the new painting
        _mint(msg.sender, newPaintingId);

        // Create a new painting and add it to the array
        Painting memory newPainting = Painting(newPaintingId, payable(msg.sender), _name, _artist, _description, _price);
        paintings.push(newPainting);

        // Associate the new painting with the NFT
        nftToPainting[newPaintingId] = newPainting;

        // Emit an event for the new painting
        emit PaintingListed(newPaintingId, msg.sender, _name, _price);

        // Return the ID of the new painting
        return newPaintingId;
    }

    // Create a function for buying a painting
    function buyPainting(uint256 _nftId) public payable {
        Painting memory painting = nftToPainting[_nftId];

        // Require that the buyer sends the correct amount of ether
        require(msg.value == painting.price, "Insufficient funds.");

        // Transfer the ether to the seller
        painting.owner.transfer(msg.value);

        // Transfer the ownership of the NFT to the buyer
        _transfer(painting.owner, msg.sender, _nftId);

        // Update the owner of the painting
        painting.owner = payable(msg.sender);

        // Update the mapping of NFTs to paintings
        nftToPainting[_nftId] = painting;
    }

    // Create a function to get all the paintings
    function getAllPaintings() public view returns (Painting[] memory) {
        return paintings;
    }

    // Create a function to get the owner of an NFT
    function getNftOwner(uint256 _nftId) public view returns (address) {
        require(_nftId<paintings.length,"NFT Does Not Exist");
        return ownerOf(_nftId);
    }
}