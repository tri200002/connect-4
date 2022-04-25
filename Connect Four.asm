.data
	userprompt: 	.asciiz 	"\nEnter the row (1-7) you want to place your piece: "
	usererror: 		.asciiz 	"\nInvalid input. Please enter a row from 1-7" 
	cputurn: 		.asciiz 	"\nCPU's turn: "
	rowFullMsg:		.asciiz		"\nRow is full, choose a different one"
	
	TieMsg:				.asciiz	 	"Game was a Tie :|"
	AIWinMsg:			.asciiz		"You lost :("
	PlayerWinMsg:		.asciiz		"You Won! :D"
	
	.align 2	# word align it
	board: 			.ascii 		"_______\n_______\n_______\n_______\n_______\n_______\0"
	
	.align 2	# word align counters
	counters: 		.byte 		5, 5, 5, 5, 5, 5, 5

# ==========================================================================================
.text

main:
	# Loads board address into $s0
	la $s0, board
	li $s7, 0	# turn counter
	
	jal drawboard
	jal drawBoard
	
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

AIchoice:
	# Generate random number between 0-6 inclusive
	li $v0, 42
	li $a1, 7
	syscall
	
	validate:
		# if row is full, choose a new row
		lb $t0, counters($a0)
		bltz $t0, AIchoice
	
	# save cpu's choice
	addi $s6, $a0, 0
	
	# Prompt that its CPUs turn
	li $v0, 4
	la $a0, cputurn
	syscall
	
	# print cpu's choice
	li $v0, 1
	addi $a0, $s6, 1
	syscall
	
	# set $s5 to AI play value
	li $s5, 'X'
	lw $a2, P2Color
jr $ra

# ==========================================================================================

playerchoice:
	# Prompt user for their turn
	li $v0, 4
	la $a0, userprompt
	syscall
	
	# get user input
	li $v0, 5
	syscall
	
	# Validate user input
		addi $t2, $v0, -1
		bgt $t2, 6, inputerror
		blt $t2, 0, inputerror
	
		# if row is full, choose a new row
		lb $t0, counters($t2)
		bltz $t0, inputerror
		
	# save user input
	addi $s6, $t2, 0
	li $s5, 'O'
	lw $a2, P1Color
jr $ra

inputerror:
	# Prompt the error
	li $v0, 4
	la $a0, usererror
	syscall
# Go back to player choice and try again.
j playerchoice

rowFull:
	# Prompt the error
	li $v0, 4
	la $a0, rowFullMsg
	syscall
# Go back to player choice and try again.
j playerchoice

# ==========================================================================================

droppiece:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# Get the coressponding row's counter
	lb $t3, counters($s6)
	
	# Calculate index
	mul $t4, $t3, 8
	add $t5, $t4, $s6 # t5 contains index
	add $t0, $s0, $t5
	sb $s5, ($t0)
	
	#Decrement counter
	add $t3, $t3, -1
	sb $t3, counters($s6)
	
	addi $a0, $s6, 0
	addi $a1, $t3, 1
	jal drawToken
		
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

# ==========================================================================================
	
wincheck:
	# check the \ direction
	li $t0, 0
	backDiagonalLoop1:
		add $t4, $t0, $s0
		
		li $t1, 0
		backDiagonalLoop2:
			add $t5, $t4, $t1
			
			li $t2, 0 					# loop iterator
			backDiagonalLoop3:
				add $t6, $t5, $t2 		# $t4 holds address of cell that needs to be checked
				lb $t7, 0($t6)
				
				# if one of the pieces isn't the correct type, we don't need to check any more, it can't be at this location
				bne $t7, $s5, breakBackDiagonalLoop3
				
			addi $t2, $t2, 9
			bne $t2, 36, backDiagonalLoop3
			j gameEnd					# if the code reaches here, then four are in a row
			# or alternatively change a register to some value that indicates a win, and jr $ra
		
		breakBackDiagonalLoop3:
		addi $t1, $t1, 1
		bne $t1, 4, backDiagonalLoop2
	
	addi $t0, $t0, 8
	bne $t0, 24, backDiagonalLoop1
	
	# check the / direction
	li $t0, 0
	frontDiagonalLoop1:
		add $t4, $t0, $s0
		
		li $t1, 3
		frontDiagonalLoop2:
			add $t5, $t4, $t1
			
			li $t2, 0					# loop iterator
			frontDiagonalLoop3:
				add $t6, $t5, $t2 		# $t4 holds address of cell that needs to be checked
				lb $t7, 0($t6)
				
				# if one of the pieces isn't the correct type, we don't need to check any more, it can't be at this location
				bne $t7, $s5, breakFrontDiagonalLoop3
				
			addi $t2, $t2, 7
			bne $t2, 28, frontDiagonalLoop3
			j gameEnd					# if the code reaches here, then four are in a row
			# or alternatively change a register to some value that indicates a win, and jr $ra
		
		breakFrontDiagonalLoop3:
		addi $t1, $t1, 1
		bne $t1, 7, frontDiagonalLoop2
	
	addi $t0, $t0, 8
	bne $t0, 24, frontDiagonalLoop1
	
	# check the - direction
	
	
	# check the | direction
	
	
	# if all spots are filled
	beq $s7, 42, Tie
jr $ra

# ==========================================================================================
# check who won
gameEnd:		
		# if previous turn is odd AI Won, else player won
		andi $t0, $s6, 1
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
# =============		
exit: 
	#End program
	li $v0, 10
	syscall

.include "connectFourGraphics.asm"