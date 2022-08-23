// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicTacToe {
    address public playerX; // const? 
    address public playerO;
    uint256 public betAmount; // const? 

    address public whosTurn;
    address[3][3] public board;

    uint256 turnNumber;

    enum GameStatus {
        INCOMPLETE,
        DRAW,
        WIN
    }

    struct GameResult {
        GameStatus status;
        address winner;
        bool playerXWithdrew;
        bool playerOWithdrew;
    }
    GameResult public result;

    constructor() payable {
        playerX = msg.sender;
        betAmount = msg.value;
    }

    modifier onlyPlayer {
        require((msg.sender == playerX) || (msg.sender == playerO), "only callable by player");
        _;
    }

    modifier gameFinished {
        require((result.status != GameStatus.INCOMPLETE), "game in progress");
        _;
    }
    
    modifier hasTwoPlayers {
        require(playerO != address(0), "must have two players");
        _;
    }

    function joinGame() public payable {
        require (playerO == address(0), "game is full");
        require (msg.value == betAmount, "must deposit correct bet amount");

        playerO = msg.sender;
    }

    function takeTurn(uint256 _x, uint256 _y) public onlyPlayer hasTwoPlayers {
        require(result.status == GameStatus.INCOMPLETE, "game is finished");
        if (whosTurn == address(0)) {
            // whoever calls takeTurn first goes first
            whosTurn = msg.sender;
        }
        
        require(whosTurn == msg.sender, "not your turn");
        if (msg.sender == playerX) {
            whosTurn = playerO;
        }
        else {
            whosTurn = playerX;
        }
        require(board[_x][_y] == address(0), "board position taken");
        

        board[_x][_y] = msg.sender; 
        ++turnNumber;

        bool isWinner = isWinningMove(_x, _y, msg.sender);
        if (isWinner) {
            result.status = GameStatus.WIN;
            result.winner = msg.sender;
        }
        else if (turnNumber == 9) {
            result.status = GameStatus.DRAW;
        }
    }

    function withdraw() payable onlyPlayer gameFinished public {
        if (result.status == GameStatus.WIN) {
            require(msg.sender == result.winner, "only winner can withdraw");
            payable(msg.sender).transfer(address(this).balance);
        }
        else {
            if (msg.sender == playerX) {
                require(!result.playerXWithdrew, "already withdrew");
                result.playerXWithdrew = true;
                payable(msg.sender).transfer(betAmount);
            }
            else if (msg.sender == playerO) {
                require(!result.playerOWithdrew, "already withdrew");
                result.playerOWithdrew = true;
                payable(msg.sender).transfer(betAmount);
            }
        }
    }

    function isWinningMove(uint256 _x, uint256 _y, address _playerAddress) internal view returns(bool) {
        // horizontal
        for (uint i = 0; i < 3; i++) {    
            if (board[_x][i] != _playerAddress) {
                break;
            }
            if (i == 2) {
                return true;
            }
        }

        // vertical
        for (uint i = 0; i < 3; i++) {
            if (board[i][_y] != _playerAddress) {
                break;
            }
            if (i == 2) {
                return true;
            }
        }

        // diagonal
        if (_x == _y) {
            for (uint i = 0; i < 3; i++) {
                if (board[i][i] != _playerAddress) {
                    break;
                }
                if (i == 2) {
                    return true;
                }
            }

        }

        // other diagonal
        if ((_x + _y) == 2) {
            for (uint i = 0; i < 3; i++) {
                if (board[i][2-i] != _playerAddress) {
                    break;
                }
                if (i == 2) {
                    return true;
                }
            }
        }

        return false;
    }

    function balance() public returns(uint256) {
        return address(this).balance;
    }
}
