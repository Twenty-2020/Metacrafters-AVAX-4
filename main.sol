// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*Minting new tokens: The platform should be able to create new tokens and distribute them to players as rewards. Only the owner can mint tokens.
Transferring tokens: Players should be able to transfer their tokens to others.
Redeeming tokens: Players should be able to redeem their tokens for items in the in-game store.
Checking token balance: Players should be able to check their token balance at any time.
Burning tokens: Anyone should be able to burn tokens, that they own, that are no longer needed.*/

contract DegenMusicStore is ERC20, Ownable {
    uint public constant subscribePrice = 1; 
    uint public constant albumPrice = 5; 
    uint public albumStock = 50;
    uint public albumSold;
    mapping(address => uint) public redeemed;
    mapping(address => bool) public subscribers;

    modifier subscriberOnly() {
        require(subscribers[msg.sender], "You must be a subscriber to perform this action.");
        _;
    }

    constructor(address owner) ERC20("Degen", "DGN") Ownable(owner) {}

    function mint(address to, uint amount) external onlyOwner {
        require(to != address(0), "Invalid address");
        require(amount > 0, "Amount must be greater than zero");
        _mint(to, amount * 10**decimals());
    }

    function burn(uint amount) public {
        _burn(msg.sender, amount * 10**decimals());
    }

    function subscribe() public {
        require(!subscribers[msg.sender], "You are already subscribed");
        require(balanceOf(msg.sender) >= subscribePrice * 10**decimals(), "Insufficient token balance to subscribe");

        _burn(msg.sender, subscribePrice * 10**decimals());
        subscribers[msg.sender] = true;
    }

    function redeem() public subscriberOnly {
        require(balanceOf(msg.sender) >= albumPrice * 10**decimals(), "Insufficient token balance to redeem the album");
        require(albumSold < albumStock, "Album out of stock");
        require(redeemed[msg.sender] < 2, "You can only redeem up to 2 albums");

        _burn(msg.sender, albumPrice * 10**decimals());
        redeemed[msg.sender]++;
        albumSold++;
        albumStock--;
    }

    function refund() public subscriberOnly {
        require(redeemed[msg.sender] > 0, "You haven't redeemed any albums to refund");

        redeemed[msg.sender]--;
        albumSold--;
        albumStock++;

        _mint(msg.sender, albumPrice * 10**decimals());
    }

    function getTokenBalance() public view returns (uint) {
        return balanceOf(msg.sender) / 10**decimals();
    }

    function tokenTransfer(address destination, uint amount) public {
        require(destination != address(0), "Invalid address");
        require(amount > 0, "Cannot transfer a value below zero");
        
        _transfer(_msgSender(), destination, amount * 10**decimals());
    }
}