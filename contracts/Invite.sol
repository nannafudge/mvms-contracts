//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { Account } from "./Accounts.sol";

library InviteSystem {
    
}

contract Invite {
    address owner public;

    modifier ownsInvite() {
        require(msg.sender == owner, "");
        _;
    }

    function create(address calldata chat) public {

    }
}