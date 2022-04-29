.data
	
	userprompt: 		.asciiz 	"\nEnter the row (1-7) you want to place your piece: "
	usererror: 			.asciiz 	"\nInvalid input. Please enter a row from 1-7" 
	cputurn: 			.asciiz 	"\nCPU's turn: "
	rowFullMsg:			.asciiz		"\nRow is full, choose a different one"
	
	.globl AIchoice
	.globl playerchoice
	.globl droppiece
.text
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
	sw $t5, index
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
