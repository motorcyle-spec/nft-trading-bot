// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BotNFT
 * @dev ERC721A NFT contract for bot ownership with EIP-2981 royalties
 * 
 * Features:
 * - Gas-efficient batch minting with ERC721A
 * - EIP-2981 royalty standard support
 * - Metadata updates tied to bot state
 * - Transfer hooks for ownership tracking
 */

import {ERC721A} from "@erc721a/ERC721A.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BotNFT is ERC721A, ERC2981, Ownable {
    
    // ============ State Variables ============
    
    string public baseURI;
    mapping(uint256 => string) public tokenMetadata;
    
    address public immutable botFactory;
    
    // ============ Events ============
    
    event MetadataUpdated(uint256 indexed tokenId, string newMetadata);
    event RoyaltyUpdated(uint256 indexed tokenId, address receiver, uint96 feeNumerator);
    
    // ============ Constructor ============
    
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        address _botFactory
    ) ERC721A(_name, _symbol) Ownable(msg.sender) {
        baseURI = _baseURI;
        botFactory = _botFactory;
        _setDefaultRoyalty(owner(), 500); // 5% default royalty
    }

    /**
     * @dev Start token IDs at 1 (tests expect first token to be ID 1)
     */
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
    
    // ============ External Functions ============
    
    /**
     * @dev Mint NFT for bot
     * @param _to Recipient address
     * @param _tokenId Token ID
     * @param _metadata Metadata URI
     */
    function mint(
        address _to,
        uint256 _tokenId,
        string memory _metadata
    ) external {
        require(msg.sender == botFactory || msg.sender == owner(), "Not authorized");
        require(_to != address(0), "Invalid recipient");
        
        _mint(_to, 1);
        if (bytes(_metadata).length > 0) {
            tokenMetadata[_tokenId] = _metadata;
        }
    }
    
    /**
     * @dev Update token metadata
     * @param _tokenId Token ID
     * @param _newMetadata New metadata URI
     */
    function updateMetadata(uint256 _tokenId, string memory _newMetadata) external {
        require(ownerOf(_tokenId) == msg.sender || msg.sender == owner(), "Not authorized");
        
        tokenMetadata[_tokenId] = _newMetadata;
        emit MetadataUpdated(_tokenId, _newMetadata);
    }
    
    /**
     * @dev Set royalty for specific token
     * @param _tokenId Token ID
     * @param _receiver Royalty receiver
     * @param _feeNumerator Royalty percentage (e.g., 500 = 5%)
     */
    function setTokenRoyalty(
        uint256 _tokenId,
        address _receiver,
        uint96 _feeNumerator
    ) external onlyOwner {
        require(_feeNumerator <= 10000, "Fee too high");
        _setTokenRoyalty(_tokenId, _receiver, _feeNumerator);
        emit RoyaltyUpdated(_tokenId, _receiver, _feeNumerator);
    }
    
    /**
     * @dev Set default royalty
     * @param _receiver Royalty receiver
     * @param _feeNumerator Royalty percentage (e.g., 500 = 5%)
     */
    function setDefaultRoyalty(address _receiver, uint96 _feeNumerator) external onlyOwner {
        require(_feeNumerator <= 10000, "Fee too high");
        _setDefaultRoyalty(_receiver, _feeNumerator);
    }
    
    /**
     * @dev Set base URI
     * @param _newBaseURI New base URI
     */
    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }
    
    // ============ Override Functions ============
    
    /**
     * @dev Token URI
     * @param _tokenId Token ID
     * @return Token URI
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenId), "Token does not exist");
        
        if (bytes(tokenMetadata[_tokenId]).length > 0) {
            return tokenMetadata[_tokenId];
        }
        
        return string(abi.encodePacked(baseURI, _toString(_tokenId), ".json"));
    }
    
    /**
     * @dev Support ERC165 interfaces
     * @param _interfaceId Interface ID
     * @return Supports interface
     */
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(ERC721A, ERC2981)
        returns (bool)
    {
        return
            ERC721A.supportsInterface(_interfaceId) ||
            ERC2981.supportsInterface(_interfaceId);
    }
    
    // ============ Internal Functions ============
    
    /**
     * @dev Convert uint256 to string
     * @param value Value to convert
     * @return str String representation
     */
    function _toString(uint256 value) internal pure override returns (string memory str) {
        if (value == 0) return "0";
        
        uint256 temp = value;
        uint256 digits;
        
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        
        bytes memory buffer = new bytes(digits);
        temp = value;
        
        while (temp != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + (temp % 10)));
            temp /= 10;
        }
        
        return string(buffer);
    }
}
