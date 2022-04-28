.data
	.align 2	# word align it
	board: 				.ascii 		"_______\n_______\n_______\n_______\n_______\n_______\0"
	
	.align 2	# word align counters
	counters: 			.byte 		5, 5, 5, 5, 5, 5, 5
	
	index:				.word		0

# ==========================================================================================
.text

main:
	# Loads board address into $s0
	la $s0, board
	jal drawBoard # graphical
	
newGame:
	jal drawboard # ASCII
	li $s7, 0	# turn counter
	gameplayloop:
		# put turnCounter % 2 in $t0
		andi $t0, $s7, 1
		# if turn is even it's player's turn, else AI's
		bne $t0, $zero, AI
			jal playerchoice
			j afterChoice
		AI:
			jal AIchoice
		afterChoice:
		
		jal droppiece
		jal drawboard
		# increment turn counter
		addi $s7, $s7, 1
		jal wincheck
	j gameplayloop

# ==========================================================================================

drawboard:
	# print a newline
	li $v0, 11
	li $a0, '\n'
	
	li $t1, 0
	Loop:
		syscall
		# print '|'
		li $a0, '|'	
		syscall
		
		# get next cell of board to print
		add $t0, $s0, $t1
		lb $a0, ($t0)
		# print cell

		#increment counter
		addi $t1, $t1, 1

	# break loop if we reach a null character
	bne $a0, '\0', Loop
	
	# print a newline
	li $a0, '\n'
	syscall

jr $ra

# ==========================================================================================
.include "Choice.asm"
.include "GameEnd.asm"
.include "Wincheck.asm"
.include "connectFourGraphics.asm"