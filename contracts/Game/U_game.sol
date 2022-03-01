// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
interface getRandom{
    function random_value(uint) external view returns(uint);
}
contract U_game{
    address private randomAddr;
    constructor(){
        randomAddr = 0xdEF6848f1bcaC8810bE96815175Ead4aCc1fd484;
    }
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
    function get_random(uint seed) private view returns(uint){
        return getRandom(randomAddr).random_value(seed);
    }
}
