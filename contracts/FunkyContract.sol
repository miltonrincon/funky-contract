// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Royalties/ERC2981ContractWideRoyalties.sol";

/// @title Funky Contract
/// @author Milton Rincon
/// @dev Status: On development
contract FunkyContract is ERC721URIStorage, ERC721Enumerable, Ownable, ERC2981ContractWideRoyalties {
	
	uint256 PRICE = 0.05 ether;
	uint256 PRESALE_PRICE = 0.03 ether;
	uint256 MAX_PER_ADDRESS = 5;
	uint256 MAX_TOKENS = 10000;
	uint256 tokenCount = 0;
	address[] public whitelist;
	bool public paused = true;
	bool public presale = true;
	string public CONTRACT_NAME = "FunkyContract";
	string public CONTRACT_SYMBOL = "FC1";
	
	using Counters for Counters.Counter;
	Counters.Counter private _tokenIds;
	
	constructor() ERC721(CONTRACT_NAME, CONTRACT_SYMBOL) {}
	
	function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
		super._beforeTokenTransfer(from, to, tokenId);
	}
	
	function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
		super._burn(tokenId);
	}
	
	function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory){
		return super.tokenURI(tokenId);
	}
	
	/// @inheritdoc	ERC165
	function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981Base, ERC721Enumerable) returns (bool){
		return super.supportsInterface(interfaceId);
	}
	
	/// @notice pause all the minting interactions with the contract
	/// @param _value true to pause the contract false to enable minting
	function setPause(bool _value) public onlyOwner {
		paused = _value;
	}
	
	/// @notice mange the presale functionalities with the contract
	/// @param _value true to enable the presale, false to disable the presale
	function setPresale(bool _value) public onlyOwner {
		presale = _value;
	}
	
	/// @notice replace the array of the whitelisted addresses
	/// @param _addresses  array of wallet addresses
	function setWhiteList(address[] calldata _addresses) public onlyOwner {
		delete whitelist;
		whitelist = _addresses;
	}
	
	/// @notice verify if an address is on the whitelist
	/// @param _address address to check
	function isWhitelisted(address _address) public view returns (bool) {
		for (uint i = 0; i < whitelist.length; i++) {
			if (whitelist[i] == _address) {
				return true;
			}
		}
		return false;
	}
	
	/// @notice transfer the collected amount to the contract owner
	function withdraw() public payable onlyOwner {
		uint balance = address(this).balance;
		require(balance > 0, "No ether left to withdraw");
		// =============================================================================
		(bool os,) = payable(owner()).call{value : address(this).balance}("");
		require(os, "Transfer to owner failed");
		// =============================================================================
	}
	
	function internalMint(address receiver, string memory metadata) internal returns (uint256){
		_tokenIds.increment();
		uint256 newItemId = _tokenIds.current();
		_mint(receiver, newItemId);
		_setTokenURI(newItemId, metadata);
		tokenCount += 1;
		return newItemId;
	}
	
	/// @notice Manage the common minting logic
	/// @param receiver address of the receiver of the transaction
	/// @param metadataURL url for the metadata on ifps
	function mintFunky(address receiver, string memory metadataURL) internal returns (uint256){
		require(!paused, "PAUSED");
		require(tokenCount < MAX_PER_ADDRESS, "Sold out");
		require(!(balanceOf(receiver) >= MAX_PER_ADDRESS), "MAX_TOKENS_REACHED");
		if (presale) {
			require(isWhitelisted(receiver), "NOT_WHITELISTED");
			require(msg.value >= PRESALE_PRICE, "Must pay resale price");
			uint256 newItemId = internalMint(receiver, metadataURL);
			return newItemId;
		} else {
			require(msg.value >= PRICE, "Must pay price");
			uint256 newItemId = internalMint(receiver, metadataURL);
			return newItemId;
		}
	}
}
