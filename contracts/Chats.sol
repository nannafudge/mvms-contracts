pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Roles.sol";

/*
    SHARED_DHKE - Shared Diffie Hellman Key Exchange mode
    DUKPT - Derived Unique Key per Transaction mode
*/
enum ChatMode {
    SHARED_ECDHKE,
    DUKPT
}

struct Chat {
    uint256 genesis;
    mapping(address => bool) admins;
    mapping(address => bool) participants;
    mapping(address => bool) banned;
}

contract Chats {
    uint256 public chatIds;

    mapping(address => mapping(uint256 => bool)) public userChats;
    mapping(uint256 => Chat) public chats;

    event ChatModified(uint256 chatId);
    event Message(uint256 chatId, bytes message);

    modifier senderOwnsAddress(address memory addr) {
        require(msg.sender == addr, "Sender does not own address");
        _;
    }

    function _isParticipant(uint256 calldata chatId, address calldata addr) internal view returns (bool) {
        return this.chats[chatId].participants[addr];
    }

    function _isAdmin(uint256 calldata chatId, address calldata addr) internal view returns (bool) {
        return this.chats[chatId].admins[addr];
    }

    function _isBanned(uint256 calldata chatId, address calldata addr) internal view returns (bool) {
        return this.chats[chatId].banned[addr];
    }

    function isParticipant(uint256 calldata chatId) public view returns (bool) {
        return this._isParticipant(chatId, msg.sender);
    }

    function isAdmin(uint256 calldata chatId) public view returns (bool) {
        return this._isAdmin(chatId, msg.sender);
    }

    function isBanned(uint256 calldata chatId) public view returns (bool) {
        return this._isBanned(chatId, msg.sender);
    }

    modifier mChatExists(uint256 memory chatId) {
        require(this.chats[chatId].genesis != 0, "No chat exists");
        _;
    }

    modifier mIsParticipant(uint256 memory chatId, address calldata addr) {
        require(this.isParticipant(chatId, addr), "User is not a chat participant");
        _;
    }

    modifier mIsAdmin(uint256 memory chatId, address calldata addr) {
        require(this.isAdmin(chatId, addr), "User is not an admin of the chat");
        _;
    }

    modifier mIsNotBanned(uint256 memory chatId, address calldata addr) {
        require(!this.isBanned(chatId, addr), "User is banned from this chat");
        _;
    }

    function nextId() private returns (uint256) {
        return this.chatIds++;
    }

    function create(address calldata participant) public returns (uint256) {
        uint256 memory id = nextId();

        chats[id].genesis = block.number;
        chats[id].admins[msg.sender] = true;
        chats[id].participants[msg.sender] = true;
        chats[id].participants[participant] = true;

        emit ChatModified(id);

        return id;
    }

    function addParticipant(uint256 calldata chatId, address calldata participant) public chatExists(chatId) mIsAdmin(chatId, msg.sender) {
        chats[chatId].participants[participant] = true;

        emit ChatModified(chatId);
    }

    function addParticipants(uint256 calldata chatId, address[] calldata participants) public chatExists(chatId) mIsAdmin(chatId, msg.sender) {
        for (uint256 memory i = 0; i < participants.length; i++) {
            chats[chatId].participants[participants[i]] = true;
        }

        emit ChatModified(chatId);
    }

    function addAdmin(uint256 calldata chatId, address calldata admin) public chatExists(chatId) mIsAdmin(chatId, msg.sender) mIsParticipant(chatId, admin) {
        chats[chatId].admins[admin] = true;

        emit ChatModified(chatId);
    }

    function addAdmins(uint256 calldata chatId, address[] calldata admins) public chatExists(chatId) mIsAdmin(chatId, msg.sender) {
        for (uint256 memory i = 0; i < admins.length; i++) {
            if (isParticipant(chatId, admins[i])) chats[chatId].admins[admins[i]] = true;
        }

        emit ChatModified(chatId);
    }

    function addBan(uint256 calldata chatId, address calldata banRecipient) public chatExists(chatId) mIsAdmin(chatId, msg.sender) {
        chats[chatId].banned[banRecipient] = true;

        emit ChatModified(chatId);
    }

    function addBans(uint256 calldata chatId, address[] calldata banRecipients) public chatExists(chatId) mIsAdmin(chatId, msg.sender) {
        for (uint256 memory i = 0; i < banRecipients.length; i++) {
            chats[chatId].banned[banRecipients[i]] = true;
        }

        emit ChatModified(chatId);
    }

    function removeParticipant(uint256 calldata chatId, address calldata participant) public chatExists(chatId) mIsAdmin(chatId, msg.sender) {
        chats[chatId].participants[participant] = false;

        emit ChatModified(chatId);
    }

    function removeParticipants(uint256 calldata chatId, address[] calldata participants) public chatExists(chatId) mIsAdmin(chatId, msg.sender) {
        for (uint256 memory i = 0; i < participants.length; i++) {
            chats[chatId].participants[participants[i]] = false;
        }

        emit ChatModified(chatId);
    }

    function removeAdmin(uint256 calldata chatId, address calldata admin) public chatExists(chatId) mIsAdmin(chatId, msg.sender) {
        chats[chatId].admins[admin] = false;

        emit ChatModified(chatId);
    }

    function removeAdmins(uint256 calldata chatId, address[] calldata admins) public chatExists(chatId) mIsAdmin(chatId, msg.sender) {
        for (uint256 memory i = 0; i < admins.length; i++) {
            chats[chatId].admins[admins[i]] = false;
        }

        emit ChatModified(chatId);
    }

    function removeBan(uint256 calldata chatId, address calldata banRecipient) public chatExists(chatId) mIsAdmin(chatId, msg.sender) {
        chats[chatId].banned[banRecipient] = false;

        emit ChatModified(chatId);
    }

    function removeBans(uint256 calldata chatId, address[] calldata banRecipients) public chatExists(chatId) mIsAdmin(chatId, msg.sender) {
        for (uint256 memory i = 0; i < banRecipients.length; i++) {
            chats[chatId].banned[banRecipients[i]] = false;
        }

        emit ChatModified(chatId);
    }

    function message() public chatExists(chatId) _isParticipant(chatId) _isNotBanned(chatId) {

    }
}