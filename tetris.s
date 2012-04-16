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

                       #Usual stuff at the end of the main
	addu	$ra, $0, $s7	#restore the return address
	jr	$ra		#return to the main program
	add	$0, $0, $0	#nop

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

		# Jump back up to wait for more input from Python 
		j updateloop

	# This routine is for when we are finished hearing from Python 
	finupdate:

		######################################################
		# This is where we will house a lot of the game logic
		######################################################

		# Print a new line to let Python know we're done 
		li		$v0, 4		# system call #4 - print string
		la		$a0, newline	# $a0 = $zero + 15
		syscall				# execute

		# Return 
		jr $ra 