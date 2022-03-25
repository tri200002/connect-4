# import <iostream>

int main() {
    // False = ‘X’
    // True = ‘O’
    bool playerTurn = false;
    
    char** board = { {'_', '_', '_', '_', '_', '_', '_'},
                       {'_', '_', '_', '_', '_', '_', '_'}, 
                       {'_', '_', '_', '_', '_', '_', '_'},
                       {'_', '_', '_', '_', '_', '_', '_'},
                       {'_', '_', '_', '_', '_', '_', '_'},
                       {'_', '_', '_', '_', '_', '_', '_'},
                       {'_', '_', '_', '_', '_', '_', '_'} };
    
    int choice;
    
    
    int counter = 0;
    while(counter < 42) {
        drawBoard(board);
        
        if(playerTurn){
            choice = playerChoice(board);
    
        } else {
            choice = AIChoice(board);
        }
    
        int[] play = addPiece(board, choice, playerTurn); // row and col of play
    
        bool win = winCheck(board, play);
        if(win){
            if(playerTurn) {
                // You win
            } else {
                // You lost
            }
        }
        
        playerTurn = !playerTurn;
    }
    // You Tied
    return 0;
}


public void drawBoard(char** b) {
    for(int r = 0; r < sizeof(b) ; r++) {
        for(int c = 0; c < sizeof(b[r] ); c++) {
            cout << "|" << b[r][c]; 
        }
        cout << "|" << endl;
    }
}


public bool winCheck(char** board, int* play) {
    
}


public int aIChoice(char** board, int* play) {
    
}

public int playerChoice(char** board, int* play) {
    bool good = false;
    int choice;
    while(!good) {
        cout << "chose a col between 0 and 6 (inclusive)" << endl;
        cin >> choice;
        // if choice is in range
        if(choice >= 0 && choice <= 6) {
            // if there is still space in choice column
            if(board[6][choice] == '_') {
                good = true;
                break;
            } else {
                cout << "Invalid input: must be a column with space" << endl;
            }
        } else {
            cout << "Invalid input: must be between 0 and 6 (inclusive)" << endl;
        }
    }
    return choice;
}

public int* addPiece (char** board, int choice, boolean playerTurn) {
    static int[] result = {-1, choice}
    
    for (int row = 0; row < 6; row++) {
        if(board[row][choice] == '_') {
            if(!playerTurn) {
                board[row][choice] = 'X';
                result[0] = row;
                return result;
            
            } else {
                board[row][choice] = 'O';
                result[0] = row;
                return result;
            }
        
        }
    }
    
}
