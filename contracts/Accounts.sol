// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct Account {
    address owner;
    string name;
    string avatar;
    string description;
    bytes pubkey;
}

contract Accounts {
    mapping(address => Account) public accounts;

    modifier notHasAccount() {
        require(accounts[msg.sender].owner == address(0), "Account already exists for address");
        _;
    }

    modifier hasAccount() {
        require(accounts[msg.sender].owner != address(0), "No account exists for address");
        _;
    }

    modifier ownsAccount() {
        require(accounts[msg.sender].owner == msg.sender, "Address does not have ownership of account");
        _;
    }

    modifier createAllowed(Account memory account) {
        require(msg.sender == account.owner, "Cannot create account for other address");
    }

    function createAccount(Account calldata account) public notHasAccount createAllowed(account) {
        accounts[msg.sender] = account;
    }

    function createAccount(bytes calldata pubkey) public notHasAccount {
        accounts[msg.sender] = Account({owner: msg.sender, name: "", avatar: "", description: "", pubkey: pubkey});
    }

    function updateAccount(Account calldata account) public hasAccount ownsAccount {
        accounts[msg.sender] = account;
    }

    function updateAccount(string calldata name, string calldata avatar, string calldata description, bytes calldata pubkey) public hasAccount ownsAccount {
        Account storage account = accounts[msg.sender];

        if (bytes(name).length > 0) account.name = name;
        if (bytes(avatar).length > 0) account.avatar = avatar;
        if (bytes(description).length > 0) account.description = description;
        if (pubkey.length > 0) account.pubkey = pubkey;
    }

    function updateKey(bytes calldata pubkey) public hasAccount ownsAccount {
        require(pubkey.length > 0, "Empty pubkey provided");
        accounts[msg.sender].pubkey = pubkey;
    }

    function deleteAccount() public hasAccount ownsAccount {
        delete accounts[msg.sender];
    }
}