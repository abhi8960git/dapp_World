// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SolahParchiThap {
    address owner;
    bool gameInProgress;
    mapping(address => uint) wins;
    address[4] players;
    uint8[4][4] parchis;
    mapping(address => uint8[4]) parchisMap;
    uint currPlayer = 0;
    uint deadline;

    constructor(){
        owner = msg.sender;
        deadline = block.timestamp + 60 minutes;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }
    
    // @notice: Get the player ID for a given address
    function getPlayerID(address addr) public view returns (uint){
        for(uint i = 0; i < 4; i++){
            if(players[i] == addr){
                return i;
            }
        }
        return 5;
    }

    // @notice: Check if an address is a player in the game
    function isPlayer(address _player) public view returns (bool){
        for(uint i = 0; i < 4; i++){
            if(_player == players[i]){
                return true;
            }
        }
        return false;
    }
    
    // @notice: Set and start the game with specified players and parchis
    function setState(address[4] memory _players, uint8[4][4] memory _parchis) public {
        require(!gameInProgress, "Game is already in progress.");
        for(uint i = 0; i < 4; i++){
            require(_players[i] != owner, "Owner cannot be a player.");
        }

        for(uint i = 0; i < 4; i++){
            require((_parchis[0][i] + _parchis[1][i] + _parchis[2][i] + _parchis[3][i]) < 5, "Parchis count must be less than 5.");
        }
        require((_parchis[0][0] + _parchis[0][1] + _parchis[0][2] + _parchis[0][3]) < 5, "Parchis count for the owner must be less than 5.");
        
        players = _players;
        parchis = _parchis;
        gameInProgress = true;
    }

    // @notice: Pass a parchi to the next player
    function passParchi(uint8 parchi) public {
        parchi -= 1;
        require(gameInProgress, "Game is not in progress.");
        require(isPlayer(msg.sender), "Only players can pass parchis.");
        require(getPlayerID(msg.sender) != 5, "Address is not a player.");
        require(getPlayerID(msg.sender) == currPlayer, "It's not the current player's turn.");
        require(parchis[currPlayer][parchi] > 0, "Parchi count is insufficient.");

        parchis[currPlayer][parchi]--;
        uint nextPlayer = (currPlayer + 1) % 4;
        parchis[nextPlayer][parchi]++;
        currPlayer = nextPlayer;
    }

    // @notice: Claim a win
    function claimWin() public {
        require(gameInProgress, "Game is not in progress.");
        require(getPlayerID(msg.sender) != 5, "Address is not a player.");
        uint claimer = getPlayerID(msg.sender);
        for(uint j = 0; j < 4; j++){
            if(parchis[claimer][j] == 4){
                wins[msg.sender]++;
                gameInProgress = false;
                return;
            }
        }
        revert("No parchis claimable.");
    }

    // @notice: End the game
    function endGame() public {
        require(gameInProgress, "Game is not in progress.");
        require(isPlayer(msg.sender), "Only players can end the game.");
        require(block.timestamp >= deadline, "Game can only be ended after the deadline.");
        gameInProgress = false;
    }

    // @notice: Get the number of wins for a specific player
    function getWins(address add) public view returns (uint256) {
        if(isPlayer(add)){
            return wins[add];
        }
        revert("Address is not a player.");
    }

    // @notice: Get the parchis held by the caller of this function
    function myParchis() public view returns (uint8[4] memory) {
        require(gameInProgress, "Game is not in progress.");
        if(getPlayerID(msg.sender) < 5){
            uint caller = getPlayerID(msg.sender);
            return parchis[caller];
        }
        revert("Address is not a player.");
    }

    // @notice: Get the current state of the game
    function getState() public view onlyOwner returns (address[4] memory, address, uint8[4][4] memory) {
        require(gameInProgress, "Game is not in progress.");
        return (players, players[currPlayer], parchis);
    }
}
