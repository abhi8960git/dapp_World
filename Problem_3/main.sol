// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SolahParchiThap {
    
    address owner;
    bool gameInProgress;
    mapping(address => uint) wins;
    address[4] players;
    uint8[4][4] parchis;
    uint currPlayer = 0;
    uint deadline;

    constructor(){
        owner = msg.sender;
        deadline = block.timestamp + 60 minutes;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    function getPlayerID(address addr) public view returns (uint){
        for(uint i = 0; i < 4; i++){
            if(players[i] == addr){
                return i;
            }
        }
        return 5;
    }

    function isPLayer(address _player) public view returns (bool){
        for(uint i = 0; i < 4; i++){
            if(_player == players[i]){
                return true;
            }
        }
        return false;
    }

    // To start the game
    function startGame(address  p1, address  p2, address  p3, address  p4) public onlyOwner{
        require(p1 != address(0) && p2 != address(0) && p3 != address(0) && p4 != address(0));
        
        players[0] = p1;
        players[1] = p2;
        players[2] = p3;
        players[3] = p4;
        for(uint i = 0; i < 3; i++){
            for(uint j = i+1; j < 4; j++){
                if(players[i] == players[j]){
                    revert();
                }
            }
            if(players[i] == owner){
                revert();
            }
        }
        if(players[3] == owner){
            revert();
        }

        for(uint i = 0; i < 4; i++){
            uint temp_sum = 5;
            for(uint j = 0; j < 4; j++){
                uint8 random = uint8(block.timestamp % temp_sum);
                parchis[j][i] = random;
                temp_sum -= random;
            }
        }
    }
    
    // To set and start the game
    function setState(address[4] memory _players, uint8[4][4] memory _parchis) public {
        require(!gameInProgress);
        for(uint i = 0; i < 4; i++){
            if (_players[i] == owner){
                revert();
            }
        }
        for(uint i = 0; i < 4; i++){
            require((_parchis[0][i] + _parchis[1][i] + _parchis[2][i] + _parchis[3][i]) < 5);
        }
        require((_parchis[0][0] + _parchis[0][1] + _parchis[0][2] + _parchis[0][3]) < 5);
        players = _players;
        parchis = _parchis;
        gameInProgress = true;
    }

    // To pass the parchi to next player
    function passParchi(uint8 parchi) public {
        parchi -= 1;
        require(gameInProgress);
        require(isPLayer(msg.sender));
        require(getPlayerID(msg.sender) != 5);
        require(getPlayerID(msg.sender) == currPlayer);
        require(parchis[currPlayer][parchi] > 0);

        parchis[currPlayer][parchi]--;
        uint nextPlayer = (currPlayer + 1) % 4;
        parchis[nextPlayer][parchi]++;
        currPlayer = nextPlayer;
    }

    // To claim win
    function claimWin() public {
        require(gameInProgress);
        require(getPlayerID(msg.sender) != 5);
        uint claimer = getPlayerID(msg.sender);
        for(uint j = 0; j < 4; j++){
            if(parchis[claimer][j] == 4){
                wins[msg.sender]++;
                gameInProgress = false;
                return;
            }
        }
        revert();
    }

    // To end the game
    function endGame() public {
        require(gameInProgress);
        require(isPLayer(msg.sender));
        require(block.timestamp >= deadline);
        gameInProgress = false;
    }

    // To see the number of wins
    function getWins(address add) public view returns (uint256) {
        if(isPLayer(add)){
            return wins[add];
        }
        revert();
    }

    // To see the parchis held by the caller of this function
    function myParchis() public view returns (uint8[4] memory) {
        require(gameInProgress);
        if(getPlayerID(msg.sender) < 5){
            uint caller = getPlayerID(msg.sender);
            return parchis[caller];
        }
        revert();
    }

    // To get the state of the game
    function getState() public view returns (address[4] memory, address , uint8[4][4] memory) {
        require(gameInProgress);
        return (players, players[currPlayer], parchis);
    }

}