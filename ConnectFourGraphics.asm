.data
	# to set up: open bitmap and set it to 512x512 with 4x4 pixels, and set the base address to heap
	bitmap: 					.word 	0x10040000
			
	frameColor:					.word	0x0000FF	# blue
	bgColor:					.word	0xFFFFFF	# white
	P1Color:					.word	0xFFFF00	# yellow
	P2Color:					.word	0xFF0000	# red
	
	circleLineArray:			.byte	4,	8,	10,	12,	12,	14,	14,	14,	14,	12,	12,	10,	8,	4
	circleXOffsetArray:			.byte	5,	3,	2,	1,	1,	0,	0,	0,	0,	1,	1,	2,	3,	5

	smallCircleLineArray:		.byte	4,	6,	8,	8,	8,	8,	6,	4
	smallCircleXOffsetArray:	.byte	2,	1,	0,	0,	0,	0,	1,	2
	
	.globl main
	.globl drawBoard
	.globl drawToken
	.globl P1Color
	.globl P2Color
	.globl clearBoard
.text

# ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈

# $a0: X value of leftmost value
# $a1: Y value of topmost value
# $a2: Color
drawToken:
addi $sp, $sp, -16
sw $a2, 12($sp)
sw $a1, 8($sp)
sw $a0, 4($sp)
sw $ra, 0($sp)
	
	jal clearChevron
	jal drawChevron
	
	# draw a circle
	lw $a1, 8($sp)
	lw $a0, 4($sp)
	jal drawCircle
	
	# slightly darken the color
	subi $a2, $a2, 0x200000
	beq $a2, 0xdf0000, next
		subi $a2, $a2, 0x2000
	next:
	
	# draw a smaller circle
	jal drawSmallCircle

lw $a2, 12($sp)
lw $a1, 8($sp)
lw $a0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp, 16

jr $ra
# ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈

drawBoard:
addi $sp, $sp, -4
sw $ra, 0($sp)
	
	# draw frame
	# basically color everything blue
		lw $t1, frameColor	# blue
		li $t0, 0
		lw $t3, bitmap
		addi $t3, $t3, 0x2200
		loop:
			add $t4, $t3, $t0
			sw $t1, ($t4)
		addi $t0, $t0, 4
		bne $t0, 63336, loop
	
		jal drawCells
	
	# end and return	
		
lw $ra, 0($sp)
addi $sp, $sp, 4
	
jr $ra		

# ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈
clearBoard:
addi $sp, $sp, -4
sw $ra, 0($sp)

	jal drawCells
	jal clearChevron
	
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra
# ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈

# draws the empty cells
drawCells:
addi $sp, $sp, -4
sw $ra, 0($sp)
	# draw cells
		lw $a2, bgColor	# white
		# set Y value to 3 so there is an edge
		li $a1, 0
		outerLoop:
			# set X value to 3 so there is an edge
			li $a0, 0
			
			# draw a row of circles
			innerLoop:
				# draw a circle
				jal drawCircle
				
			# increment X by 18 for the next circle
			addi $a0, $a0, 1
			
			# if we've finished drawing 7 circles; break
			bne $a0, 7, innerLoop
			
		# increment Y value by 18 for the next row
		addi $a1, $a1, 1
		# if we've finished drawing 6 rows; break
		bne $a1, 6, outerLoop

lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

# ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈

# a0: column number
# a1: row number
# a2: color
drawCircle:
addi $sp, $sp, -20
sw $a1, 16($sp)
sw $a0, 12($sp)
sw $s1, 8($sp)
sw $s0, 4($sp)
sw $ra, 0($sp)

	# put 17 * X in $s0
	sll $s0, $a0, 4
	#sll $a0, $a0, 2
	add $s0, $s0, $a0
	# add 3
	addi $s0, $s0, 5
	
	# put 17 * X in $s0
	sll $t0, $a1, 4
	#sll $a1, $a1, 2
	add $a1, $a1, $t0
	# add 3
	addi $a1, $a1, 0x16
	
	# initiate counter
	li $s1, 0
	drawCircleLoop:
		# get line length and offset from outer square
		lb $a3, circleLineArray($s1)
		lb $t1,	circleXOffsetArray($s1)
		
		# set X to correct value
		add $a0, $s0, $t1
		jal drawHorzLine
		# increment counter and Y value
		addi $a1, $a1, 1
		addi $s1, $s1, 1
	# if all circle lines have been drawn exit
	bne $s1, 14, drawCircleLoop
	
lw $a1, 16($sp)
lw $a0, 12($sp)
lw $s1, 8($sp)
lw $s0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp, 20
	
jr $ra

# ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈

# a0: X value of left side
# a1: Y value of upper side
# a2: color
drawSmallCircle:
addi $sp, $sp, -20
sw $a1, 16($sp)
sw $a0, 12($sp)
sw $s1, 8($sp)
sw $s0, 4($sp)
sw $ra, 0($sp)

	# put 17 * X in $s0
	sll $s0, $a0, 4
	#sll $a0, $a0, 2
	add $s0, $s0, $a0
	# add 3
	addi $s0, $s0, 8
	
	# put 17 * X in $s0
	sll $t0, $a1, 4
	#sll $a1, $a1, 2
	add $a1, $a1, $t0
	# add 3
	addi $a1, $a1, 0x19
	
	# initiate counter
	li $s1, 0
	drawSmallCircleLoop:
		# get line length and offset from outer square
		lb $a3, smallCircleLineArray($s1)
		lb $t1,	smallCircleXOffsetArray($s1)
		
		# set X to correc value
		add $a0, $s0, $t1
		jal drawHorzLine
		# increment counter and Y value
		addi $a1, $a1, 1
		addi $s1, $s1, 1
	# if all circle lines have been drawn exit
	bne $s1, 8, drawSmallCircleLoop
	
lw $a1, 16($sp)
lw $a0, 12($sp)
lw $s1, 8($sp)
lw $s0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp, 20
	
jr $ra

# ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈

# a0: X value of left-most point
# a1: Y value
# a2: color
# a3: length
drawHorzLine:
addi $sp, $sp, -8
sw $a3, 4($sp)
sw $ra, 0($sp)
	
	# draw pixel, decrement length and increment X value, repeat till length is 0
	drawHorzLineLoop:
		jal drawPixel
		addi $a3, $a3, -1
		addi $a0, $a0, 1
	bnez $a3, drawHorzLineLoop
	
lw $ra, 0($sp)
lw $a3, 4($sp)
addi $sp, $sp, 8

jr $ra

# ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈

clearChevron:
addi $sp, $sp, -12
sw $ra, 0($sp)
sw $a0, 4($sp)
sw $a2, 8($sp)
	
	li $a0, 0
	li $a2, 0
	jal drawChevron
	addi $a0, $a0, 1
	jal drawChevron
	addi $a0, $a0, 1
	jal drawChevron
	addi $a0, $a0, 1
	jal drawChevron
	addi $a0, $a0, 1
	jal drawChevron
	addi $a0, $a0, 1
	jal drawChevron
	addi $a0, $a0, 1
	jal drawChevron

lw $ra, 0($sp)
lw $a0, 4($sp)
lw $a2, 8($sp)
addi $sp, $sp, 12

jr $ra
# ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈

# $a0: X value of left
# $a2: Color
drawChevron:
addi $sp, $sp, -12
sw $ra, 0($sp)
sw $a0, 4($sp)
sw $s0, 8($sp)
	
	# put 17 * X in $s0
	sll $s0, $a0, 4
	add $a0, $s0, $a0
	# add 3
	addi $a0, $a0, 4
	
	li $a1, 4
	li $a3, 4
	li $s0, 0
	downLoop:
		jal drawHorzLine
		addi $a0, $a0, -3
		addi $a1, $a1, 1
	addi $s0, $s0, 1
	bne $s0, 6, downLoop
	
	upLoop:
		jal drawHorzLine
		addi $a0, $a0, -3
		addi $a1, $a1, -1
	addi $s0, $s0, 1
	bne $s0, 13, upLoop


lw $s0, 8($sp)
lw $a0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp, 12

jr $ra

# ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈

# a0: X value
# a1: Y value
# a2: color
drawPixel:
	
	# word align the X and Y values
	sll $t0, $a0, 2
	sll $t1, $a1, 2
	
	# multiply Y value by the row size to get the Y pos
	sll $t1, $t1, 7
	
	# add X, Y, and bitmap together to get the actual pos
	add $t2, $t0, $t1
	lw $v0, bitmap
	add $v0, $v0, $t2
	
	sw $a2, ($v0)
	
jr $ra
