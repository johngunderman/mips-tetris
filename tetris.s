.data
	.align 2
	.globl BOARD
	BOARD:	.space 512
	.globl X
	X:	.word 0
	.globl Y
	Y:	.word 0
	newline:		.asciiz "\n"

	.text
	
.globl main
main:				#main has to be a global label
	addu	$s7, $0, $ra	#save the return address in a global register
	
	jal		INITBOARD				# jump to INITBOARD
	jal		PRINTBOARD				# jump to PRINTBOARD
	jal		UPDATEBOARD				# jump to UPDATEBOARD
	jal		PRINTBOARD				# jump to PRINTBOARD and save position to $ra
	

#	jal		UPDATEBOARD				# jump to UPDATEBOARD and save position to $ra
#	jal		PRINTBOARD				# jump to PRINTBOARD
#	jal		UPDATEBOARD				# jump to UPDATEBOARD and save position to $ra
#	jal		PRINTBOARD				# jump to PRINTBOARD
#	jal		UPDATEBOARD				# jump to UPDATEBOARD and save position to $ra
#	jal		PRINTBOARD				# jump to PRINTBOARD
#	jal		UPDATEBOARD				# jump to UPDATEBOARD and save position to $ra
	
	
	li		$v0, 10			# Syscall to end program 
	syscall

.globl INITBOARD
INITBOARD:
	add $t0, $zero, $zero 
	sw $t0, X
	sw $t0, Y
	la $t0, BOARD		#current position in array
	addi $t1, $zero, 512		#counter for loop
	
	loopinit:
		sw $zero, ($t0)
		addi $t0, $t0, 4
		addi $t1, $t1, -4
		bne $t1, $zero, loopinit
		jr $ra
	
.globl GETINCREMENT	#returns value at x,y to $v0
GETINCREMENT:			#return 1 to $v1 if increment move past valid x,y values, else it return 0
	lw $t0, Y
	lw $t1, X
	sll $t0, $t0, 3		#multiply y by 8 to get to correct row
	add $t0, $t0, $t1	#add x to move to correct column within row
	sll $t0, $t0, 2		#mult by 4 to convert from index(words) to bytes
	la $t1, BOARD		#load address of BOARD to $t1
	add $t0, $t0, $t1	#address of current position
	lw $v0, ($t0)		#returns value at x,y
	lw $t0, X			#loading x so 	it can be incremented
	addi $t0, $t0, 1	#increment x
	addi $t1, $zero, 8
	blt $t0, $t1, skipincx	#check if we moved past the last column
	move $t0, $zero		#move to first column in next row
	sw $t0, X			#save new value of x
	lw $t0, Y			#loading y so it can be incremented
	addi $t0, $t0, 1	#increment y
	addi $t1, $zero, 16	
	blt $t0, $t1, skipincy	
	sw $zero, Y
	addi $v1, $zero, 1	#return 1 in $v1 to signal that you moved past the last row and column
	j	fin
	
	skipincx:
		sw $t0, X	
		move $v1, $zero
		j	fin

	skipincy:
		sw $t0, Y
		move $v1, $zero
		j	fin				# jump to fin
		
	
	fin:
		jr $ra
	
.globl GETXY			#returns value at x,y to $v0
GETXY:
	lw $t0, Y
	lw $t1, X
	sll $t0, $t0, 3		#multiply y by 8 to get to correct row
	add $t0, $t0, $t1	#add x to move to correct column within row
	sll $t0, $t0, 2		#mult by 4 to convert from index(words) to bytes
	la $t1, BOARD		#load address of BOARD to $t1
	add $t0, $t0, $t1	#address of current position
	lw $v0, ($t0)		#returns value at x,y
	jr $ra

.globl GETARGXY			# $a0=x, $a1=y, $v0=return value
GETARGXY:
	add $t0, $zero, $a1
	add $t1, $zero, $a0
	sll $t0, $t0, 3		#multiply y by 8 to get to correct row
	add $t0, $t0, $t1	#add x to move to correct column within row
	sll $t0, $t0, 2		#mult by 4 to convert from index(words) to bytes
	la $t1, BOARD		#load address of BOARD to $t1
	add $t0, $t0, $t1	#address of current position
	lw $v0, ($t0)		#returns value at x,y
	jr $ra
	
.globl SETXY			#$a0=x, $a1=y, $a2=number to be stored
SETXY:
	sll $t0, $a1, 3		#multiply y by 8 to get to correct row
	add $t0, $t0, $a0	#add x to move to correct column within row
	sll $t0, $t0, 2		#mult by 4 to convert from index(words) to bytes
	la $t1, BOARD		#load address of BOARD to $t1
	add $t0, $t0, $t1	#address of inputted x,y
	sw $a2, ($t0)		#stores value to x,y
	jr $ra
	
.globl NEXT			#return 1 to $v0 if increment move past valid x,y values, else it return 0
NEXT:
	lw $t0, X			#loading x so it can be incremented
	addi $t0, $t0, 1	#increment x
	addi $t1, $zero, 8
	blt $t0, $t1, skipincxx	#check if we moved past the last column
	move $t0, $zero		#move to first column in next row
	sw $t0, X			#save new value of x
	lw $t0, Y			#loading y so it can be incremented
	addi $t0, $t0, 1	#increment y
	addi $t1, $zero, 16	
	blt $t0, $t1, skipincyy	
	sw $zero, Y
	addi $v0, $zero, 1	#return 1 in $v0 to signal that you moved past the last row and column
	j	finn
	
	skipincxx:
		sw $t0, X
		move $v0, $zero
		j	fin
	
	skipincyy:
		sw $t0, Y
		move $v0, $zero
	
	finn:
		jr $ra
	
.globl RESET			#resets x and y to 0
RESET:
	sw $zero, X
	sw $zero, Y
	jr $ra
	
.globl GETX			#returns the value of x to $v0
GETX:
	lw $v0, X
	jr $ra
			
.globl GETY			#returns the value of y to $v0
GETY:
	lw $v0, Y
	jr $ra


# This procedure jumps our global variables to the next line
# Returns 0 in $v0 if successful and 1 if not 
.globl NEXTROW
NEXTROW:
	lw		$t0, Y			#
	sw		$zero, X		# 
	addi	$t0, $zero, 1			# $t0 = $zero + 1
	addi	$t1, $zero, 16			# $t2 = $zero + 16
	blt		$t0, $t1, skiprowinc	# if $t0 < $t1 then skiprowinc
	sw		$zero, Y		# 
	addi	$v0, $zero, 1			# $v0 = $zero + 1
	j		finrowinc				# jump to finrowinc
		

	skiprowinc:
		sw		$t0, Y		# 
		add		$v0, $zero, $zero		# $v0 = $zero + $zero
		j		finrowinc				# jump to finrowinc
		
	finrowinc:
		jr		$ra					# jump to $ra
		
.globl PRINTBOARD
PRINTBOARD:
	sw		$ra, 0($sp)		# Store return address onto the stack 

	j		printloop				# jump to printloop
	

	# This is actually printing the board 
	printloop:
		
		jal		GETINCREMENT	# jump to GETINCREMENT and save position to $ra
		addi	$t1, $zero, 1			# $t0 = $zero + 1
		
		# This is our test to see if we still have more board spaces to print
		beq		$v1, $t1, finprint	# if $v1 == $t0 then finprint

		add		$a0, $zero, $v0		# $a0 = $zero + $v0
		li		$v0, 1		# system call #4 - print string
		syscall				# execute	

		j printloop

	finprint: 

		li		$v0, 4		# system call #4 - print string
		la		$a0, newline	# $a0 = $zero + 15
		syscall				# execute

		lw		$ra, 0($sp)			# Pop our return address off the stack 
		jr		$ra					# jump to $ra

# This routine will read in code from STDIN and update our board 
.globl UPDATEBOARD
UPDATEBOARD:
	sw		$ra, 4($sp)		# Store return address onto the stack 


	# We want to load the board so we can update it with the new info from Python 
	la		$t3, BOARD		# Load the address of the board 

	updateloop:
	
		# Make MIPS wait for integer input 
		li		$v0, 5		# $v0 = 5	
		syscall				# execute

		# Load the interger input into a register
		add		$t2, $zero, $v0		# $t2 = $zero + $v0

		# Determine which piece needs to be created 
		addi	$t0, $zero, 1			# $t0 = $zer0 + 1
		beq		$t0, $t2, CREATEP	# if $t0 == $t2 then CREATEP
		
		addi	$t0, $zero, 2			# $t0 = $zero + 2	
#		beq		$t0, $t2, CREATES	# if $t0 == $t2 then CREATES
		
		addi	$t0, $zero, 3			# $t0 = $zero + 3	
#		beq		$t0, $t2, CREATEZ	# if $t0 == $t2 then CREATEZ
		
		addi	$t0, $zero, 4			# $t0 = $zero + 4
#		beq		$t0, $t2, CREATEBZ	# if $t0 == $t2 then CREATEBZ
		
		addi	$t0, $zero, 5			# $t0 = $zero + 5
#		beq		$t0, $t2, CREATEL	# if $t0 == $t2 then CREATEL
		
		addi	$t0, $zero, 6			# $t0 = $zero + 6
#		beq		$t0, $t2, CREATEBL	# if $t0 == $t2 then CREATEBL
		
		addi	$t0, $zero, 7			# $t0 = $zero + 7
#		beq		$t0, $t2, CREATET	# if $t0 == $t2 then CREATET
		
		# If we receive a 9 from Python, jump to the end 
		addi	$t0, $zero, 9		# $t0 = $zero + 9
		beq		$t0, $t2, finupdate	# if $t0 == $t2 then finupdate

		# Jump back up to wait for more input from Python 
		j finupdate

	# This routine is for when we are finished hearing from Python 
	finupdate:

		lw		$ra, 4($sp)		# Load return address from stack 
		
		# Return 
		jr $ra 

.globl CREATEP
CREATEP:

	# Store our return address on the stack 
	sw		$ra, 0($sp)		# 
	

	# Load X and Y
	lw		$t0, X		# 
	lw		$t1, Y		# 
	
	# We're picking our middle position to be 3 so let's move X there
	# We also want to make sure we're starting at our top row as well 
	addi	$t0, $zero, 3			# $t0 = X + 3 
	addi	$t1, $zero, 0			# $t1 = $zero + 0
	
	
	# Store the first position of the board 
	addi	$t2, $zero, 1		# $t1 = $zero + 1
	add		$a0, $zero, $t0		# $a0 = $zero + $t0
	add		$a1, $zero, $t1		# $a1 = $tzero+ $t1
	add		$a2, $zero, $t2		# $a2 = $zero + $t2
	jal		SETXY				# jump to SETXY and save position to $ra
	

	# $t9 holds the rotation state. 1 for vertical, 2 for horizontal 
	addi	$t9, $zero, 1			# $t7 = $zero + 1

	ploop:

		# Make MIPS wait for integer input 
		li		$v0, 5		# $v0 = 5	
		syscall				# execute

		# Load X and Y
		lw		$t0, X		# 
		lw		$t1, Y		# 

		# A counter for moving pieces 
		addi	$t8, $zero, 1			# $t8 = $zero + 1
		

		# If Python sends us a 1 we want to shift our piece right
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq		$v0, $t3, shiftpr	# if $v0 == $t3 then shiftpr

		# If Python sends us a 2 we want to shift our piece left
		addi	$t3, $zero, 2			# $t3 = $zero + 2
		beq		$v0, $t3, shiftpl	# if $v0 == $t3 then shiftpl

		# If Python sends us a 3 then we want to rotate the piece 
		addi	$t3, $zero, 3			# $t3 = $zero + 3
		beq		$v0, $t3, rotatep	# if $v0 == $t3 then target
		
		j		dropp				# jump to dropp

	shiftpr:
		addi	$t0, $t0, 1			# $t0 = $t0 + 1

		# If $t9 == 1 then the pipe is vertical so move to that loop 
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq		$t9, $t3, shiftprvloop	# if $t9 == $t3 then shiftprvloop
		
		# If $t9 == 0 then the pipe is horizontal so move to that loop 
		addi	$t3, $zero, 2			# $t3 = $zero + 2
		beq		$t9, $t3, shiftprhloop	# if $t9 == $t3 then shiftprhloop
		
		# If we don't hit one of these then something went wrong and it's best to change anything 
		j		finprint				# jump to finprint
		

		shiftprvloop:
			# If we're moving past the end of the board we don't want to move
			addi	$t7, $zero, 8			# $t7 = $zero + 8
			beq		$t0, $t7, finp	# if $t0 == $t7 then finp

			# Get the value stored at X,Y
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY				# jump to GETARGXY and save position to $ra

			# If this position is not free, then we don't want to shift 
			bne		$v0, $zero, finp	# if $v0 != $zero then finp

			# If the position is free, then we store a 1 in $t3
			addi	$t3, $zero, 1		# $t3 = $zero + 1

			# If Y is 0 then we are at the top so we can move
			beq		$t1, $zero, moveprv	# if $t1 == $zero then moveprv
			
			# Subtract 1 from y to move up 
			addi	$t7, $zero, 1		# $t7 = $zero + 1
			sub		$t1, $t1, $t7		# $t1 = $t1 - $t7

			# If we've run this loop 4 times we've accounted for each square
			addi	$t8, $t8, 1			# $8 = $t8 + 1
			addi	$t7, $zero, 1		# $t7 = $zero + 1
			beq		$t8, $t7, moveprv		# if $t8 == $t1 then moveprv

			# Jump back to the top of our loop 
			j		shiftprvloop			# jump to shiftprloop
			
	shiftpl:

	rotatep:

	dropp:

	moveprv:

		addi	$t6, $zero, 4			# $t6 = $zero + 4
		addi	$t5, $zero, 1			# $t5 = $zero + 1
		
		moveprvloop:

			# Load the original X and Y
			lw		$t0, X		# 
			lw		$t1, Y		# 
			
			# Shift our x value to the right once 
			addi	$t2, $t0, 1			# $t0 = $t0 + 1
	 
			# Load 1 into a register since that's what we use for this piece 
			addi	$t3, $zero, 1			# $t3 = $zero + 1
					
			# Set the value at the current position 
			add		$a0, $zero, $t2		# $a0 = $zero + $t2
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $t3		# $a2 = $zero + $t3
			jal		SETXY				# jump to SETXY

			# We want to set the spot we moved from to zero 
			add		$a0, $zero, $t0		# $a0 = $zero + $t0
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra
		
			# If we're at the top of the board or we're done shifting pieces we wait for the next input
			beq		$t1, $zero, ploop	# if $t1 == $zero then ploop
			beq		$t5, $t6, ploop		# if $t5 == $t6 then ploop


			# We need to increase our counter and move our y-value 
			addi	$t4, $zero, 1		# $t4 = $zero + 1
			add		$t5, $t5, $t4		# $t5 = $t5 + $t4
			sub		$t1, $t1, $t4		# $t1 = $t1 - $t4
						
			j		moveprvloop			# jump to moveprvloop
			
	finp:
		jr		$ra					# jump to $ra
	  

# This is the procedure that is going to handle a lot of our game logic
.globl CHECKBOARD
CHECKBOARD:

	sw		$ra, 0($sp)		# Store return address onto the stack 

	# We want to check the top row of our board
	addi	$t0, $zero, 8			# $t0 = $zero + 8
	addi	$t1, $zero, 0			# $t1 = $zero + 0
	addi	$t4, $zero, 0			# $t4 = $zero + 1
	
	j		toprow				# jump to toprow
	
	toprow:

		jal		GETINCREMENT				# jump to GETINCREMENT and save position to $ra

		# If any space in the top board is not zero then the game is over
		bne		$v0, $zero, GAMEOVER	# vf $t0 != $zero then GAMEOVER
		
		# If we hit space 8 on our board then we are on the second row 
		addi	$t1, $zero, 1			# $t1 = $zero + 1
		beq		$t1, $t0, aftertop	# if $t1 == $t0 then aftertop
		

		j		toprow				# jump to toprow
		
	aftertop:
		
		# Grab a value from the board
		jal		GETINCREMENT				# jump to GETINCREMENT and save position to $ra

		# Move the result of GETINCREMENT into a temp register
		add		$t2, $zero, $v0		# $t2 = $zero + $v0
		
		# If we read the end of the board, then we know we are finsihed checking
		addi	$t1, $zero, 1			# $t1 = $zero + 1
		beq		$t2, $t1, finishcheck	# if $v0 == $t1 then target

		# If the space we're looking at is 0 then we know we can't clear the row so we move on
		beq		$t2, $zero, NEXTROW	# if $v0 == $t1 then target

		# If our NEXTROW returns 1 then we have also finsihed checking 
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq		$v0, $t3, finishcheck	# if $v0 == $t3 then finishcheck

		# If our counter makes it to 8, then we have to clear this row 
		addi	$t4, $zero, 1			# $t4 = $zero + 1
		beq		$t4, $t0, clearrow	# if $t0 4= $t0 tclearrowrget
		
		j		aftertop				# jump to aftertop
	
	clearrow:
		# Load our X and Y values
		lw		$t0, X		# 
		lw		$t1, Y		# 

		# Recreate our comparison in case it got erased 
		addi	$t4, $zero, 8			# $t4 = $zero + 8
		
		# We want to make sure we are not looking at the top row, if we are, get out
		addi	$t2, $zero, 0			# $t2 = $zero + 0
		beq		$t1, $t2, CHECKBOARD	# if $t1 == $t2 then CHECKBOARD
		
		# Set X to zero to start at the beginning of the row 
		add		$t0, $zero, $zero		# $t0 = $zero + $zero
		
		# We want to move one row above our current row and store it in another register
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		sub		$t2, $t1, $t3		# $t2 = $t1 - $t2


		clearloop:

			# Call GETARGXY to get the value stored at our position 
			add		$a0, $zero, $t0		# $a0 = $zero + $t0
			add		$a1, $zero, $t2		# $a1 = $zero + $t2
			jal		GETARGXY				# jump to GETARGXY and save position to $ra
			
			# Call SETXY to set our new value
			add		$a1, $zero, $t1		# $a1 = $zero + $t1

			add		$a2, $zero, $v0		# $a2 = $zero + $v0
			jal		SETXY				# jump to SETXY and save position to $ra
			
			# Move to the next column 
			addi	$t0, $t0, 1			# $t0 = $t0 + 1
			beq		$t0, $t4, finclearloop	# if $t0 == $t4 then finclearloop

			j		clearloop				# jump to clearloop
			
		finclearloop:
			sw		$t2, Y		# 
			j		clearrow				# jump to clearrow											
		
	finishcheck:
		jr		$ra					# jump to $ra
		

.globl GAMEOVER
GAMEOVER:
	# When the game ends, we write a 9 to STDOUT to tell Python we're done as well 
	li		$v0, 1		# system call #4 - print string
	addi	$a0, $zero, 9			# $a0 = $zero + 9
	syscall				# execute

	jr		$ra					# jump to $ra
	