int main() {
    // False = ‘X’
    // True = ‘O’
    boolean playerTurn = false;


    Scanner kb = new Scanner(System.in);
    char[][] board = { {‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’},
                       {‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’}, 
                       {‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’},
                       {‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’},
                       {‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’},
                       {‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’},
                       {‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’, ‘_’} };
 
    int choice;


    int counter = 0
    while(counter < 42):
        drawBoard(board);
        
    if(playerTurn){
        cout << “chose a col between 0 and 6 (inclusive)” << endl;
        choice = kb.nextInt();
        while(choice < 0 || choice > 6) {
            cout << “Invalid input: must be between 0 and 6 (inclusive)” << endl;
            choice = kb.nextInt();
        }
    
   } else {
        choice = AIChoice()
   }
        int[] play = addPiece(board, choice, playerTurn); // row and col of play


  return 0;
}


public drawBoard(String[][] b) {
    for(int r = 0; r < b.length; r++) {
        for(int c = 0; c < b[r].length; c++) {
            cout << “|” << b[r][c]; 
        }
        cout << “|” << endl;
    }
}


public boolean winCheck(char[][] board, int[] play) {
        
}


public aIChoice(char[][] board, int[] play) {
        
}


public void addPiece (char[][] board, int choice, boolean playerTurn) {
    for (int row = 0; row < 6; row++) {
        if(board[row][choice] == '_') {
            if(!playerTurn) {
                board[row][choice] = 'X';
                break;
            }
            board[row][choice] = 'O';
            break;
        }
    }
    playerTurn = !playerTurn;
}
