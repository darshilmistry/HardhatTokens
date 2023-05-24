// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IERC721.sol";
import "./ERC721Reciever.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title Non FungibleToken Handeler
 * @author Darshil Mistry
 * @notice This is just designed to handle NFTS. The business logic can be found in the main solidity file.
 */
contract NFT is IERC721, ERC721Reciever {
    // state variables
    mapping(uint256 => address) TokenOwners;

    mapping(uint256 => string) TokenURIs;

    mapping(uint256 => address) Players;
    /**
     * @dev the tokenCount acts as the token ID
     */
    uint256 tokenCount;

    mapping(address => uint256) Balances;

    mapping(uint256 => address) TokenApprovals;

    mapping(address => mapping(address => bool)) OperatorApprovals;

    // immutables
    string name;
    string symbol;
    address i_owner;

    // events
    event Coin_NewPlayerSignedUp(address player);
    event Coin_TokenMinted(string tokenURI, uint256 tokenId);
    
    // errors
    error Coin__foundTrespassing(address trespasser);
    error Coin__contractNotERC721(bytes reason);
    error Coin__managingUnOwnedToken(address sender);

    // modifiers
    /** 
    *@dev this modifier reverts if the message sender is not the deployer.
    */
    modifier authorizedPersonnelOnly() {
        if (msg.sender != i_owner) revert Coin__foundTrespassing(msg.sender);
        _;
    }

    // transaction functions

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        i_owner = msg.sender;
        tokenCount = 0;
    }

    /**
     * @dev The mint function creates a token and adds the token to the owners address. 
     * Later when needed, the tokens can be transfered to another account. 
     */
    function mint(string memory tokenURI) authorizedPersonnelOnly private returns (uint256) {
        address owner = msg.sender;
        Balances[owner] += 1;
        attachURI(tokenCount, tokenURI);
        TokenOwners[tokenCount] = owner;
        emit Coin_TokenMinted(tokenURI, tokenCount);
        return(tokenCount);
    }

    /**
     * @dev This function works with the mint function to attach uris to newly generated NFTS 
     */
    function attachURI(uint256 tokenID, string memory URI) private authorizedPersonnelOnly {
        TokenURIs[tokenID] = URI;
    }

    /**
     * @dev This function is used to apoint a third party to transfer a token 
     * for a spencific ID on the behalf of the owner.
     * 
     * It will firstly check if the token being approved is actually owned by the sender.
     */
    function approve(address operator, uint256 tokenId) public override {
        if(TokenOwners[tokenId] == msg.sender) { 
            TokenApprovals[tokenId] = operator;
            emit Approval(msg.sender, operator, tokenId);
        } else {
            revert Coin__managingUnOwnedToken(msg.sender);
        }
    }

    /**
     * @dev This function can be used to appoint a third party to sell all of the tokens
     * 
     * In this use case the third party would be another constract.
     * It can be used to either provide or revoke the previllage.
     */
    function setApprovalForAll(
        address operator,
        bool approval
    ) public override {
        OperatorApprovals[msg.sender][operator] = approval;
        emit ApprovalForAll(msg.sender, operator, approval);
    }

    /** 
     * @dev This function is used to transfer a token from one addres to another.
     * 
     * it would first check if the message sender actually owns the token, 
     * if not it will be reverted.
     */
    function transferFrom(address from, address to, uint256 tokenId) public override {
            if(TokenOwners[tokenId] == msg.sender) {
            delete TokenApprovals[tokenId];
            TokenOwners[tokenId] = to;
            Balances[from] -= 1;
            Balances[to] += 1;
            emit Transfer(from, to, tokenId);
        } else {
            revert Coin__managingUnOwnedToken(msg.sender);
        }
    }

    /**
     * @dev this function first check if the reciever is a contract of a wallet. 
     * if its conttract it would be checked first that the contract would be able to handel the token.
     * 
     * It can be used with an empty data element ("") but its not so secure  
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override {
        checkOnERC721Received(from, to, tokenId, data);
        transferFrom(from, to, tokenId);
        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev This function is used to check if a reciever is a contract that can handle erc721 tokens. It is 
     * used before a safe transfer to prevent tokens getting stuck in places where the are not supposed to be 😅
     */
    function checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (Address.isContract(to)) {
            try ERC721Reciever(to).onERC721Recieved( msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == ERC721Reciever.onERC721Recieved.selector;
            } catch (bytes memory reason) {
                revert Coin__contractNotERC721(reason);
            }
        } else {
            return true;
        }
    }

    // public view functions

    function balanceOf(address owner) public view override returns (uint256) {
        return Balances[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return TokenOwners[tokenId];
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        return TokenApprovals[tokenId];
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool) {
        return OperatorApprovals[owner][operator];
    }

    function getName() public view returns (string memory) {
        return name;
    }

    function getSymbol() public view returns (string memory) {
        return symbol;
    }

    function onERC721Recieved(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {}
}