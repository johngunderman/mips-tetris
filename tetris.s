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
	jal		UPDATEBOARD				# jump to UPDATEBOARD and save position to $ra
	jal		PRINTBOARD				# jump to PRINTBOARD
	jal		UPDATEBOARD				# jump to UPDATEBOARD and save position to $ra
	jal		PRINTBOARD				# jump to PRINTBOARD
	jal		UPDATEBOARD				# jump to UPDATEBOARD and save position to $ra
	jal		PRINTBOARD				# jump to PRINTBOARD
	jal		UPDATEBOARD				# jump to UPDATEBOARD and save position to $ra
	
	
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
	sw		$ra, 0($sp)		# Store return address onto the stack 


	# We want to load the board so we can update it with the new info from Python 
	la		$t3, BOARD		# Load the address of the board 

	updateloop:
	
		# Make MIPS wait for integer input 
		li		$v0, 5		# $v0 = 5	
		syscall				# execute

		# We're using 9 as an escape code from Python
		# We load it for comparison purposes 
		addi	$t0, $zero, 9		# $t0 = $zero + 9
		add		$t2, $zero, $v0		# $t2 = $zero + $v0
		
		# If we receive a 9 from Python, jump to the end 
		beq		$t0, $t2, finupdate	# if $t0 == $t2 then finupdate

		# Store our read in value into the board and move to the next space 
		sw		$t2, ($t3)			# 
		addi	$t3, $t3, 4			# $t3 = $t3 + 4
		
		# Print the data back out to STDOUT to see if Python receives it correctly 
		add		$a0, $zero, $v0		# $a0 = $zero + $v0
		li		$v0, 1				# $v0 = 1
		syscall

		lw		$ra, 0($sp)			# Pop our return address off the stack 

		# Jump back up to wait for more input from Python 
		j updateloop

	# This routine is for when we are finished hearing from Python 
	finupdate:

	#	jal		CHECKBOARD				# jump to CHECKBOARD and save position to $ra
		

		# Print a new line to let Python know we're done 
		li		$v0, 4		# system call #4 - print string
		la		$a0, newline	# $a0 = $zero + 15
		syscall				# execute

		# Return 
		jr $ra 

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
	