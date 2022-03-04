// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
contract U_game{
    struct Map{
        uint quantityOfEnemy;
    }
    struct Player{
        uint8 player_site;
        bool isInited;
    }
    Map[10] public map;
    constructor(){
        map[2].quantityOfEnemy = 2;
        map[3].quantityOfEnemy = 3;
        map[4].quantityOfEnemy = 4;
        map[5].quantityOfEnemy = 5;
        map[6].quantityOfEnemy = 6;
        map[7].quantityOfEnemy = 7;
        map[8].quantityOfEnemy = 8;
        map[9].quantityOfEnemy = 9;
    }
    mapping (address => Player) private player;

    function initPlayer() external {
        require(player[msg.sender].isInited == false, "You had been inited!");
        player[msg.sender].player_site = 1;
    }

    function readSite(address _player) external view returns(uint8){
        return player[_player].player_site;
    }

    function moveSite(uint8 _NextSite) external {
        require(_NextSite >= 2 && _NextSite <= 10, "Your input nextsite is unreasonable!");
        player[msg.sender].player_site = _NextSite;
    }

    function killEnemy(uint _index, uint _quantityOfEnemy) external{
        require(_index >= 2 && _index <= 9, "Your input index is unreasonable!");
        require(_quantityOfEnemy >= 1, "Your input quantityOfEnemy is unreasonable!");
        require(_quantityOfEnemy <= map[_index].quantityOfEnemy, "Your input quantityOfEnemy is out of range!");
        map[_index].quantityOfEnemy -= _quantityOfEnemy;
    }
    function random_value(uint _seed) internal view returns(uint){
        uint seed_temp =  uint(keccak256(abi.encodePacked(blockhash(block.number - 1), _seed)));
        return seed_temp;
    }
}
