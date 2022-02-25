// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
contract U_game{
    struct Player{
        uint8 player_site;
    }
    mapping (address => Player) private player;

    function readSite() external returns(uint8){
        if(player[msg.sender].player_site == 0)
            player[msg.sender].player_site = 1;
        return player[msg.sender].player_site;
    }

    function moveSite(uint8 NextSite) external {
        player[msg.sender].player_site = NextSite;
    }

    function entityOperation() external {

    }
}