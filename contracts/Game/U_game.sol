// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
contract U_game{
    struct Player{
        uint8 player_site;
        bool isInited;
    }
    mapping (address => Player) private player;

    function initPlayer() external {
        require(player[msg.sender].isInited == false, "You had been inited!");
        player[msg.sender].player_site = 1;
    }

    function readSite(address _player) external view returns(uint8){
        return player[_player].player_site;
    }

    function moveSite(uint8 NextSite) external {
        player[msg.sender].player_site = NextSite;
    }

    function entityOperation() external {

    }
}
