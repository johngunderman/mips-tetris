.data
	.align 2
	.globl BOARD
	BOARD:	.space 512
	.globl X
	X:	.word 0
	.globl Y
	Y:	.word 0
	P:	.word 0
	filename: 		.asciiz "tetrisboard.txt"
	newline:		.asciiz "\n"
	print0:			.asciiz "0"
	print1:			.asciiz "1"
	print2:			.asciiz "2"
	print3:			.asciiz "3"
	print4:			.asciiz "4"
	print5:			.asciiz "5"
	print6:			.asciiz "6"
	
	.text
	
.globl main
main:				#main has to be a global label
	addu	$s7, $0, $ra	#save the return address in a global register
	
	jal		INITBOARD				# jump to INITBOARD
	jal		PRINTBOARD				# jump to PRINTBOARD
	
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
	# This opens our file to append to the end
	la		$a0, filename	# Ouput filename	
	li		$a1, 0x010A		# Mark file for writing and append

	li		$a2, 0x0080		# Mode is ignored
	li		$v0, 13			# Syscall for file open
	syscall
	move 	$s6, $v0 		# Save the file descriptor

	sw		$ra, 0($sp)		# Store return address onto the stack 


	j		printloop				# jump to printloop
	

	# This is actually printing the board 
	printloop:
		
		jal		GETINCREMENT	# jump to GETINCREMENT and save position to $ra
		addi	$t1, $zero, 1			# $t0 = $zero + 1
		
		# This is our test to see if we still have more board spaces to print
		beq		$v1, $t1, finprint	# if $v1 == $t0 then finprint

		# These lines check which number to print we have to do it this way due to weird behavior in MIPS
		addi	$t1, $zero, 0			# $1 = $zero + 0
		beq		$v1, $t1, prin0	# if $v1 == $t1 then prin0

		addi	$t1, $zero, 1			# $t1 = $zero + 1
		beq		$v1, $t1, prin01 # if $v1 == $t1 then prin0
		
		addi	$t1, $zero, 2			# $t1 = $zero + 2
		beq		$v1, $t1, prin2	# if $v1 == $t1 then prin2

		addi	$t1, $zero, 3			# $t1 = $zero + 3
		beq		$v1, $t1, prin3	# if $v1 == $t1 then prin3
		
		addi	$t1, $zero, 4			# $t1 = $zero + 4
		beq		$v1, $t1, prin4	# if $v1 == $t1 then prin4
		
		addi	$t1, $zero, 5			# $t1 = $zero + 5
		beq		$v1, $t1, prin5	# if $v1 == $t1 then prin5
		
		addi	$t1, $zero, 6			# $t1 = $zero + 6
		beq		$v1, $t1, prin6	# if $v1 == $t1 then prin6
		
		j finprint
		

	prin0:
		move	$a0, $s6 		# File descriptor
		la		$a1, print0		# Print the value '0'
		

		
		li		$a2, 1			# Hard coded buffer length
		li		$v0, 15			# Syscall for write to file
		syscall

		j		printloop				# jump to printloop

	prin1:
		move	$a0, $s6 		# File descriptor
		la		$a1, print1		# Print the value '1'
		
	
		li		$a2, 1			# Hard coded buffer length
		li		$v0, 15			# Syscall for write to file
		syscall

		j		printloop				# jump to printloop

	prin2:
		move	$a0, $s6 		# File descriptor
		la		$a1, print2		# Print the value '2'
		
	
		li		$a2, 1			# Hard coded buffer length
		li		$v0, 15			# Syscall for write to file
		syscall

		j		printloop				# jump to printloop		
	
	prin3:
		move	$a0, $s6 		# File descriptor
		la		$a1, print3		# Print the value '3'
		
	
		li		$a2, 1			# Hard coded buffer length
		li		$v0, 15			# Syscall for write to file
		syscall

		j		printloop				# jump to printloop

	prin4:
		move	$a0, $s6 		# File descriptor
		la		$a1, print4		# Print the value '4'
		
	
		li		$a2, 1			# Hard coded buffer length
		li		$v0, 15			# Syscall for write to file
		syscall

		j		printloop				# jump to printloop

	prin5:
		move	$a0, $s6 		# File descriptor
		la		$a1, print5		# Print the value '5'
		
	
		li		$a2, 1			# Hard coded buffer length
		li		$v0, 15			# Syscall for write to file
		syscall

		j		printloop				# jump to printloop

	prin6:
		move	$a0, $s6 		# File descriptor
		la		$a1, print6		# Print the value '6'
		
	
		li		$a2, 1			# Hard coded buffer length
		li		$v0, 15			# Syscall for write to file
		syscall

		j		printloop				# jump to printloop

	finprint:

		# Before we close the file we print a newline
		# This allows us to keep track of previous board states
		# as well as the current state 
		move 	$a0, $s6
		la		$a1, newline		# Print a newline 
		li		$a2, 1		# $a2 = 1
		li		$v0, 15		# Syscall to write to file
		syscall

		# This will close our file 
		li		$v0, 16			# Syscall for close file
		move	$a0, $s6  		# File descriptor to close
		syscall
		lw		$ra, 0($sp)		# Pop the return value from the stack. 

		jr		$ra					# jump to $ra