.data
	.globl wincheck
.text
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
	lw $t8, index
	la $s4, board
	add $s4, $s4, $t8
	add $t9, $zero, 0
	add $s2, $s4, 0
	rightloop: #Check the right side
		add $s4, $s4, 1 #Go to the next char
		lb $s1, ($s4)
		beq $s1, '\n', leftloop #If next right character is newline check left side
		bne $s1, $s5, leftloop #If next right character is not the currently played char check left
		add $t9, $t9, 1 #add 1 to counter if it is the same char
		beq $t9, 3, gameEnd #If there are 3 neighbouring consec chars + 1 played char, there is a winner
		j rightloop 
	
	leftloop:
		add $s2, $s2, -1 #Go to the prev char
		lb $s1, ($s2)
		beq $s1, '\n', breakhorizontal #If prev left character is newline, there are no winners
		bne $s1, $s5, breakhorizontal #If prev left character is not the currently played char, there are no winners
		add $t9, $t9, 1 #add 1 to counter if it is the same char
		beq $t9, 3, gameEnd #If there are 3 neighbouring consec chars + 1 played char, there is a winner
		j leftloop
		
	breakhorizontal:
	
	# check the | direction
	li $t0, 0
	Loop1:
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
	bne $t0, 23, Loop1
	
	# if all spots are filled
	beq $s7, 42, Tie
jr $ra