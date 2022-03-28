# include <iostream>
using namespace std;

void drawBoard(char** b) {
    for(int r = 0; r < sizeof(b) ; r++) {
        for(int c = 0; c < sizeof(b[r] ); c++) {
            cout << "|" << b[r][c]; 
        }
        cout << "|" << endl;
    }
}


bool winCheck(char** board, int* play) {
    
}


int aIChoice(char** board) {
    
}

int playerChoice(char** board) {
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

int* addPiece (char** board, int choice, bool playerTurn) {
    static int result[] = {-1, choice};
    
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

char** setUpBoard() {
    static char* result[6];
    for(int i = 0; i < 6; i++ ){
        static char row[] = {'_', '_', '_', '_', '_', '_', '_'};
        result[i] = row;
    }
    return result;
}

// ======================================================================================
// ======================================================================================

int main() {
    // False = ‘X’
    // True = ‘O’
    bool playerTurn = false;
    
    char** board = setUpBoard();
    
    int choice;
    
    
    int counter = 0;
    while(counter < 42) {
        drawBoard(board);
        
        if(playerTurn){
            choice = playerChoice(board);
    
        } else {
            choice = aIChoice(board);
        }
    
        int* play = addPiece(board, choice, playerTurn); // row and col of play
    
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
