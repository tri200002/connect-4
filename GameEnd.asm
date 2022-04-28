.data
	TieMsg:				.asciiz	 	"Game was a Tie :| \n"
	AIWinMsg:			.asciiz		"You lost :( \n"
	PlayerWinMsg:		.asciiz		"You Won! :D \n"
	
	playAgainPrompt:	.asciiz		"Would you like to play again? (y/n) \n"
	InvalidExitChoice:	.asciiz		"Input must be either 'y' or 'n' \n"
	
	.globl gameEnd
.text
# ==========================================================================================
# check who won
gameEnd:		
		# if previous turn is odd AI Won, else player won
		andi $t0, $s7, 1
		beqz $t0, AIWin
		
# print 'You Won! :D', then exit
PlayerWin:	
		li $v0, 4
		la $a0, PlayerWinMsg
		syscall
		
		j exit
# ===================================
# print 'You Lost :(', then exit
AIWin:	
		li $v0, 4
		la $a0, AIWinMsg
		syscall
		j exit
# ===================================
# print 'Game was a Tie :|', then exit
Tie:			
		la $a0, TieMsg
		li $v0, 4
		syscall
		li $t4, 57
		j exit
# =============

resetBoard:
	li $t0, 0
	resetBoardLoop1:
		li $t1, 0
		resetBoardLoop2:
			add $t2, $t0, $t1
			li $t3 '_'
			sb $t3, board($t2)
			
		addi $t1, $t1, 1
		bne $t1, 7, resetBoardLoop2
		
	addi $t0, $t0, 8
	bne $t0, 48, resetBoardLoop1
	
	li $t0, 0x0505
	sh $t0, counters+0($zero)
	sh $t0, counters+2($zero)
	sh $t0, counters+4($zero)
	sb $t0, counters+6($zero)
	jal clearBoard
j newGame

# ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈

exit: 

	li $v0, 4
	la $a0, playAgainPrompt
	syscall
	
	li $v0, 12
	syscall
	
	beq $v0, 'n', trueExit
	beq $v0, 'y', resetBoard
	
	li $v0, 4
	la $a0, InvalidExitChoice
	syscall
	
	j exit
	
trueExit:	
	#End program
	li $v0, 10
	syscall