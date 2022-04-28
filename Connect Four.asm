.data
userprompt: .asciiz "\nEnter the row (1-7) you want to place your piece: "
userrow: .word 32
cpurow: .word 32
usererror: .asciiz "\nInvalid input. Please enter a row from 1-7" 
cputurn: .asciiz "\nCPU's turn: "
board: .ascii "_______\0_______\n_______\n_______\n_______\n_______\n_______\0"
counters: .word 6, 6, 6, 6, 6, 6, 6
X: .byte 'X'
O: .byte 'O'
turn: .word 0
wincounter: .word 32
turncounter: .word 0
newline: .asciiz "\n"
currIndex: .word 32

.text
drawboard:
	#print newline
	li $v0, 4
	la $a0, newline
	syscall
	
	# Loads board address into $s0
	la $s0, board
	
	# load print char argument into $v0
	li $v0, 11

	# load start of board into $t0
	la $t0, 8($s0)

	#initiate counter
	li $t1, 0
	
	Loop:
	# print ë|í
	li $a0, '|'	
	syscall

	# get next cell of board to print
	add $a0, $t0, $t1
	lb $a0, ($a0)

	# print cell
	syscall

	#increment counter
	addi $t1, $t1, 1

	# break loop if we reach a null character
	bne $a0, '\0', Loop
	
	lw $t0, turn
	beq $t0, $zero, AIchoice
	j playerchoice
	
AIchoice:
	#Prompt that its CPUs turn and display CPUs choice
	li $v0, 4
	la $a0, cputurn
	syscall
	#Generate random number between 1-7
	li $v0, 42
	li $a1, 8
	syscall
	
	validate:
		blt $a0, 1, AIchoice
	
	
	li $v0, 1
	syscall
	
	sw $a0, cpurow
	
	j droppiece
playerchoice:
	#Prompt user for their turn
	li $v0, 4
	la $a0, userprompt
	syscall
	
	#Save their input
	li $v0, 5
	syscall
	sw $v0, userrow
	
	#Validate user input
	li $t0, 7
	li $t1, 1
	lw $t2, userrow
	bgt $t2, $t0, inputerror
	blt $t2, $t1, inputerror
	
	j droppiece
inputerror:
	#Prompt the error
	li $v0, 4
	la $a0, usererror
	syscall
	
	#Go back to player choice and try again.
	j playerchoice
	
droppiece:
	lw $t1, turn
	beq $t1, $zero, AIturn
	j Playerturn
	AIturn:
		#Load cpu's row
		lw $t1, cpurow
	
		#Load X
		lb $t6, X
		
		#Swicth turn
		lw $t0, turn
		add $t0, $t0, 1
		sw $t0, turn
		j continue
	Playerturn:
		#Load user row
		lw $t1, userrow
	
		#Load O
		lb $t6, O
		
		#Change turn
		lw $t0, turn
		add $t0, $t0, -1
		sw $t0, turn
		
		j continue

	continue:
		#load board address
		la $t0, board
		#Get the coressponding row's counter
		add $t1, $t1, -1
		mul $t2, $t1, 4
		lw $t3, counters($t2)
	
		#Calculate index
		mul $t4, $t3, 8
		add $t5, $t4, $t1 #t5 contains index
		sw $t5, currIndex
		add $t0, $t0, $t5
		sb $t6, ($t0)
	
		#Decrement counter
		add $t3, $t3, -1
		sw $t3, counters($t2)
		
		j wincheck
wincheck:
	lw $t9, turncounter
	beq $t9, 42, main
	
	add $s7, $t6, $zero
	addi $s0, 8
	
	li $t0, 0
	backDiagonalLoop1:
		add $t4, $t0, $s0
		
		li $t1, 0
		backDiagonalLoop2:
			add $t4, $t4, $t1
			
			li $t2, 0 					# loop iterator
			backDiagonalLoop3:
				add $t4, $t4, $t2 		# $t4 holds address of cell that needs to be checked
				lb $t5, 0($t4)
				
				# if one of the pieces isn't the correct type, we don't need to check any more, it can't be at this location
				bne $t5, $s7, breakBackDiagonalLoop3
				
			addi $t2, 9
			bne $t2, 27, backDiagonalLoop3
			j gameEnd					# if the code reaches here, then four are in a row
			# or alternatively change a register to some value that indicates a win, and jr $ra
		
		breakBackDiagonalLoop3:
		addi $t1, $t1, 1
		bne $t1, 4, backDiagonalLoop2
	
	addi $t0, $t0, 8
	bne $t0, 24, backDiagonalLoop1
	
	
	
	li $t0, 0
	frontDiagonalLoop1:
		add $t4, $t0, $s0
		
		li $t1, 4
		frontDiagonalLoop2:
			add $t4, $t4, $t1
			
			li $t2, 0					# loop iterator
			frontDiagonalLoop3:
				add $t4, $t4, $t2 		# $t4 holds address of cell that needs to be checked
				lb $t5, 0($t4)
				
				# if one of the pieces isn't the correct type, we don't need to check any more, it can't be at this location
				bne $t5, $s7, breakFrontDiagonalLoop3
				
			addi $t2, 7
			bne $t2, 21, frontDiagonalLoop3
			j gameEnd					# if the code reaches here, then four are in a row
			# or alternatively change a register to some value that indicates a win, and jr $ra
		
		breakFrontDiagonalLoop3:
		addi $t1, $t1, 1
		bne $t1, 8, frontDiagonalLoop2
	
	addi $t0, $t0, 8
	bne $t0, 24, frontDiagonalLoop1
	
	# check the | direction
	li $t0, 0
	Loop1:
		beq $t0, 23, breakvertical
		move $t2, $t0
		li $t3, 0
		Loop2:
			lb $t1, board($t2)
			bne $s5, $t1, Cont
			addi $t2, $t2, 8
			addi $t3, $t3, 1
			beq $t3, 4, gameEnd
			j Loop2
		Cont:
		addi $t0, $t0, 1
		j Loop1
	
	breakvertical:
	
	
	j drawboard
				
main: 
	#End program
	li $v0, 10
	syscall
