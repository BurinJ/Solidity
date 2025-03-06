// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./TimeUnit.sol";
import "./CommitReveal.sol";
contract RPS {
    uint public numPlayer = 0;
    uint public reward = 0;
    mapping(address => uint) public player_choice; // 0 - Rock, 1 - Paper, 2 - Scissors, 3 - Lizard, 4 - Spock
    mapping(address => bool) public player_not_played;
    mapping(address => bool) public player_not_revealed;
    address[] public players;
    uint public numInput = 0;
    uint public numReveal = 0;
    TimeUnit public timeUnit = new TimeUnit();
    CommitReveal public commitReveal0 = new CommitReveal();
    CommitReveal public commitReveal1 = new CommitReveal();
    uint public minutesElapsed = 0;
    mapping(address => bool) public allowedPlayers;

    constructor() {
        allowedPlayers[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = true;
        allowedPlayers[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = true;
        allowedPlayers[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = true;
        allowedPlayers[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = true;
    }

    modifier onlyAllowed() {
        require(allowedPlayers[msg.sender], "Not authorized to play");
        _;
    }

    function addPlayer() public payable onlyAllowed {
        require(numPlayer < 2, "Game already has two players");
        if (numPlayer > 0) {
            require(msg.sender != players[0], "Player already added");
        } else {
            timeUnit.setStartTime();
        }
        require(msg.value == 1 ether, "Must send exactly 1 ether");
        reward += msg.value;
        player_not_played[msg.sender] = true;
        players.push(msg.sender);
        numPlayer++;
    }

     function withdrawEarly() public onlyAllowed {
        require(numPlayer > 0, "Game is empty");
        minutesElapsed = timeUnit.elapsedMinutes();
        require(minutesElapsed >= 10, "Timeout period not reached");
        address payable account0 = payable(players[0]);
        if (numPlayer == 1) {
            require(msg.sender == players[0], "Only player0 can withdraw");
            account0.transfer(reward);
        } else {
            address payable account1 = payable(players[1]);
            require(!player_not_played[msg.sender], "Only player who picked a choice can withdraw");
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        }
        _resetGame();
    }

    function input(uint dataHash) public onlyAllowed {
        require(numPlayer == 2, "Not enough players");
        require(player_not_played[msg.sender], "Already played");

        if (msg.sender == players[0])
            commitReveal0.commit(bytes32(dataHash));
        else
            commitReveal1.commit(bytes32(dataHash));
        player_not_played[msg.sender] = false;
        player_not_revealed[msg.sender] = true;
        numInput++;

    }

    function inputReveal(uint revealHash) public onlyAllowed {
        require(numInput == 2, "All players haven't committed a choice yet");
        require(player_not_revealed[msg.sender], "Already revealed");
        if (msg.sender == players[0]) {
            commitReveal0.reveal(bytes32(revealHash));
            require(commitReveal0.isRevealed(), "Revealed input error");
        } else {
            commitReveal1.reveal(bytes32(revealHash));
            require(commitReveal1.isRevealed(), "Revealed input error");
        }

        player_choice[msg.sender] = revealHash & 0xFF;
        player_not_revealed[msg.sender] = false;
        numReveal++;

        if (numReveal == 2) {
            _checkWinnerAndPay();
        }
    }

    function _checkWinnerAndPay() private {
        uint p0Choice = player_choice[players[0]];
        uint p1Choice = player_choice[players[1]];
        address payable account0 = payable(players[0]);
        address payable account1 = payable(players[1]);

        if (_isWinner(p0Choice, p1Choice)) {
            account0.transfer(reward);
        } else if (_isWinner(p1Choice, p0Choice)) {
            account1.transfer(reward);
        } else {
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        }

        _resetGame();
    }

    function _isWinner(uint choice0, uint choice1) private pure returns (bool) {
        return (choice0 == 0 && (choice1 == 2 || choice1 == 3)) ||  // Rock beats Scissors & Lizard
               (choice0 == 1 && (choice1 == 0 || choice1 == 4)) ||  // Paper beats Rock & Spock
               (choice0 == 2 && (choice1 == 1 || choice1 == 3)) ||  // Scissors beats Paper & Lizard
               (choice0 == 3 && (choice1 == 1 || choice1 == 4)) ||  // Lizard beats Paper & Spock
               (choice0 == 4 && (choice1 == 0 || choice1 == 2));    // Spock beats Rock & Scissors
    }

    function _resetGame() private {
        players = new address[](2);
        timeUnit = new TimeUnit();
        commitReveal0 = new CommitReveal();
        commitReveal1 = new CommitReveal();
        numPlayer = 0;
        numInput = 0;
        numReveal = 0;
        reward = 0;
    }
}