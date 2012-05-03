.data
	.align 2
	.globl BOARD
	BOARD:	.space 512
	.globl X
	X:	.word 0
	.globl Y
	Y:	.word 0
    .globl PX
    PX: .word 0
    .globl PY
    PY: .word 0
	newline:		.asciiz "\n"

	.text

.globl main
main:				#main has to be a global label
	addu	$s7, $0, $ra	#save the return address in a global register

	jal		INITBOARD				# jump to INITBOARD
	jal		UPDATEBOARD				# jump to UPDATEBOARD

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
	addi	$t0, $t0, 1			    # $t0 = $t0 + 1
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

		add		$t4, $v1, $zero		# $t4 = $v1 + $zero

		add		$a0, $zero, $v0		# $a0 = $zero + $v0
		li		$v0, 1		# system call #4 - print string
		syscall				# execute

		# This is our test to see if we still have more board spaces to print
		addi	$t1, $zero, 1			# $t1 = $zero + 1
		beq		$t4, $t1, finprint	# if $v1 == $t0 then finprint

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
	# Print the board
	jal		PRINTBOARD				# jump to PRINTBOARD and save position to $ra

	# We want to load the board so we can update it with the new info from Python
	la		$t3, BOARD		# Load the address of the board

	updateloop:

        # Print an 8 to Python to prompt for new piece
        li        $a0, 8        # $a0 = 8
        li        $v0, 1        # $v0 = 1
        syscall

        # Print a new line
        li      $v0, 4      # system call #4 - print string
        la      $a0, newline    # $a0 = $zero + 15
        syscall             # execute

		# Make MIPS wait for integer input
		li		$v0, 5		# $v0 = 5
		syscall				# execute

		# Load the interger input into a register
		add		$t2, $zero, $v0		# $t2 = $zero + $v0

		# Determine which piece needs to be created
		addi	$t0, $zero, 1			# $t0 = $zer0 + 1
		beq		$t0, $t2, CREATEP	# if $t0 == $t2 then CREATEP

		addi	$t0, $zero, 2			# $t0 = $zero + 2
		beq		$t0, $t2, CREATES	# if $t0 == $t2 then CREATES

		addi	$t0, $zero, 3			# $t0 = $zero + 3
		beq		$t0, $t2, CREATEZ	# if $t0 == $t2 then CREATEZ

		addi	$t0, $zero, 4			# $t0 = $zero + 4
		beq		$t0, $t2, CREATEBZ	# if $t0 == $t2 then CREATEBZ

		addi	$t0, $zero, 5			# $t0 = $zero + 5
		beq		$t0, $t2, CREATEL	# if $t0 == $t2 then CREATEL

		addi	$t0, $zero, 6			# $t0 = $zero + 6
		beq		$t0, $t2, CREATEBL	# if $t0 == $t2 then CREATEBL

		addi	$t0, $zero, 7			# $t0 = $zero + 7
		beq		$t0, $t2, CREATET	# if $t0 == $t2 then CREATET

		# If we receive a 9 from Python, jump to the end
		addi	$t0, $zero, 9		# $t0 = $zero + 9
		beq		$t0, $t2, finupdate	# if $t0 == $t2 then finupdate

		# Jump back up to wait for more input from Python
		j finupdate

	# This routine is for when we are finished hearing from Python
	finupdate:

		j		GAMEOVER				# jump to GAMEOVER


.globl CREATEP
CREATEP:

	# We're picking our middle position to be 3 so let's move X there
	# We also want to make sure we're starting at our top row as well
	addi	$t0, $zero, 3			# $t0 = X + 3
	addi	$t1, $zero, 0			# $t1 = $zero + 0

    # Store the value for safe keeping
    sw      $t0, PX        #
    sw      $t1, PY        #

	# Store the first position of the board
	addi	$t2, $zero, 1		# $t1 = $zero + 1
	add		$a0, $zero, $t0		# $a0 = $zero + $t0
	add		$a1, $zero, $t1		# $a1 = $tzero+ $t1
	add		$a2, $zero, $t2		# $a2 = $zero + $t2
	jal		SETXY				# jump to SETXY and save position to $ra

	# $t9 holds the rotation state. 1 for vertical, 2 for horizontal
	addi	$t9, $zero, 1			# $t7 = $zero + 1

    # Start the piece loop
    j        ploop                # jump to ploop


	ploop:

        # We want to print our board back to Python
        jal     PRINTBOARD           # jump to PRINTBOARD and save position to $ra

        # Prompt for user input from Python
        li        $a0, 1        # $a0 = 1
        li        $v0, 1        # $v0 = 1
        syscall

        # Print a new line
        li      $v0, 4      # system call #4 - print string
        la      $a0, newline    # $a0 = $zero + 15
        syscall             # execute

		# Make MIPS wait for integer input
		li		$v0, 5		# $v0 = 5
		syscall				# execute

		# Load PX and PY
		lw		$t0, PX		#
		lw		$t1, PY		#

		# A counter for moving pieces
		addi	$t8, $zero, 1			# $t8 = $zero + 1

		# If Python sends us a 2 we want to shift our piece left
		addi	$t3, $zero, 1			# $t3 = $zero + 2
		beq		$v0, $t3, shiftpl	# if $v0 == $t3 then shiftpl

		# If Python sends us a 1 we want to shift our piece right
		addi	$t3, $zero, 2			# $t3 = $zero + 1
		beq		$v0, $t3, shiftpr	# if $v0 == $t3 then shiftpr

		# If Python sends us a 3 then we want to rotate the piece
		addi	$t3, $zero, 3			# $t3 = $zero + 3
		beq		$v0, $t3, rotatep	# if $v0 == $t3 then target

		# If our piece is in position 1 then drop vertical
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq		$t9, $t3, droppv	# if $t9 == $t3 then droppv

		# If our piece is in position 2 then drop horizontal
		addi	$t3, $zero, 2			# $t3 = $zero + 2
		beq		$t9, $t3, dropph	# if $t9 == $t3 then dropph

		# If we get here something is wrong so we wait for another input
		j		ploop				# jump to ploop

	shiftpr:

		# Load our X and Y values
		lw		$t0, PX		#
		lw		$t1, PY		#

		# We add one to our PX-value for testing purposes
		addi	$t0, $t0, 1			# $t0 = $t0 + 1

		# We need a counter initialized for looping purposes
		addi	$t8, $zero, 1			# $t8 = $zero + 1

		# If $t9 == 1 then the pipe is vertical so move to that loop
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq		$t9, $t3, shiftprvloop	# if $t9 == $t3 then shiftprvloop

		# If $t9 == 0 then the pipe is horizontal so move to that loop
		addi	$t3, $zero, 2			# $t3 = $zero + 2
		beq		$t9, $t3, shiftprhloop	# if $t9 == $t3 then shiftprhloop

		# If we don't hit one of these then something went wrong and it's best to change anything
		j		ploop				# jump to ploop


		shiftprvloop:

			# If we're moving past the end of the board we don't want to move
      	  	addi    $t7, $zero, 8       # $t7 = $zero + 8
       		beq     $t0, $t7, droppv    # if $t0 == $t7 then droppv

			# Get the value stored at PX,PY
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne		$v0, $zero, droppv	# if $v0 != $zero then droppv

			# Subtract 1 from y to move up
			addi	$t7, $zero, 1		# $t7 = $zero + 1
			sub		$t1, $t1, $t7		# $t1 = $t1 - $t7

			# If we've run this loop 4 times we've accounted for each square
			addi	$t8, $t8, 1			# $8 = $t8 + 1
			addi	$t7, $zero, 4		# $t7 = $zero + 1
			beq		$t8, $t7, moveprv	# if $t8 == $t1 then moveprv

			# If we're at the top row and we are here then we are free to move
			beq		$t1, $zero, moveprv	# if $t1 == $zero then moveprv

			# Jump back to the top of our loop
			j		shiftprvloop			# jump to shiftprloop

		shiftprhloop:

			# If we're moving past the end of the board we don't want to move
      	  	addi    $t7, $zero, 8       # $t7 = $zero + 8
       		beq     $t0, $t7, dropph    # if $t0 == $t7 then dropph

			# Get the value stored at PX,PY
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne		$v0, $zero, dropph	# if $t0 != $zero then dropph

			# Store a 1 in a register since we'll need it
			addi	$t3, $zero, 1		# $t3 = $zero + 1

			# If the spot is free we want to shift there
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1		# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# We want to store the new value of PX
			sw		$t0, PX		#

			# We now want to subtract to the beginning of the pipe
			sub		$t4, $t0, $t3		# $t4 = $t4 - $t3
			sub		$t4, $t4, $t3		# $t4 = $t4- $t3
			sub		$t4, $t4, $t3		# $t4 = $t4 - $t3
			sub		$t4, $t4, $t3		# $t4 = $t4 - $t3

			# Set this piece to 0 since we moved past the space
			add		$a0, $t4, $zero		# $a0 = $t4 + $zero
			add		$a1, $t1, $zero		# $a1 = $t4 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# We're done so let's drop our piece
			j		dropph				# jump to ploop


	shiftpl:

		# Load our X and Y values
		lw		$t0, PX		#
		lw		$t1, PY		#

		# We subtract 1 from our PX value for testing purposes
		addi	$t6, $zero, 1		# $t6 = $zero + 1
		sub		$t0, $t0, $t6		# $t0 = $t0 - $t6

		# If $t9 == 1 then the pipe is vertical so move to that loop
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq		$t9, $t3, shiftplvloop	# if $t9 == $t3 then shiftprvloop

		# If $t9 == 0 then the pipe is horizontal so move to that loop
		addi	$t3, $zero, 2			# $t3 = $zero + 2
		beq		$t9, $t3, shiftplhloop	# if $t9 == $t3 then shiftprhloop

		# If we don't hit one of these then something went wrong and it's best to change anything
		j		droppv				# jump to droppv

		shiftplvloop:

			# If we're in the first column we don't even want to bother shifting
			blt		$t0, $zero, droppv	# if $t0 == $zero then droppv

			# Get the value stored at PX,PY
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# We want to get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne		$v0, $zero, droppv	# if $v0 != $zero then droppv

			# If PY is 0 then we are at the top so we can move
			beq		$t1, $zero, moveplv	# if $t1 == $zero then moveprv

			# Subtract 1 from y to move up
			addi	$t7, $zero, 1		# $t7 = $zero + 1
			sub		$t1, $t1, $t7		# $t1 = $t1 - $t7

			# If we've run this loop 4 times we've accounted for each square
			addi	$t8, $t8, 1			# $8 = $t8 + 1
			addi	$t7, $zero, 4		# $t7 = $zero + 1
			beq		$t8, $t7, moveplv		# if $t8 == $t1 then moveprv

			# Jump back to the top of our loop
			j		shiftplvloop			# jump to shiftprloop

		shiftplhloop:

			# We will need this later
			addi	$t3, $zero, 1			# $t3 = $zero + 1

			# Since we subtracted one at the top, I'm in position
			# 3 in relation to the pivot. I need to get to 0
			# We stop to check if we're in the first column or not
			sub		$t4, $t0, $t3		# $t4 = $t0 - $t3
			sub		$t4, $t4, $t3		# $t4 = $t4 - $t3

			# If we're in the first column we don't even want to bother shifting
			beq		$t4, $zero, dropph	# if $t0 == $zero then droppv
			sub		$t4, $t4, $t3		# $t4 = $t4 - $t3

			# Get the value stored at PX,PY
			add		$a0, $t4, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our X and Y back
			add		$t4, $a0, $zero		# $t4 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne		$v0, $zero, dropph	# if $t0 != $zero then dropph

			# If the spot is free we want to shift there
			add		$a0, $t4, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# We want our X and Y back
			add		$t4, $a0, $zero		# $t4 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# We want to shift our X pivot to the left one
			lw		$t0, PX		#
			addi	$t2, $zero, 1			# $t2 = $zero + 1
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
			sw		$t0, PX		#

			# Since we subtracted once before coming here
			# We want to add 1 to get back to the space to set 0
			addi	$t0, $t0, 1			# $t0 = $t0 + 1

			# Set this piece to 0 since we moved past the space
			add		$a0, $t0, $zero		# $a0 = $t4 + $zero
			add		$a1, $t1, $zero		# $a1 = $t4 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# We're done so let's drop the piece
			j		dropph				# jump to dropph

	rotatep:

		# Determine which state the piece is currently in, then rotate
		addi	$t0, $zero, 1			# $t0 = $zero + 1
		beq		$t9, $t0, rotatepvh	# if $t9 == $t0 then rotatepvh

		addi	$t0, $zero, 2			# $t0 = $zero + 2
		beq		$t9, $t0, rotatephv	# if $t9 == $t0 then rotatephv

		rotatepvh:

			# Load X and Y
			lw		$t0, PX		#
			lw		$t1, PY		#

			# If the whole pipe isn't being shown, we don't allow rotations
			addi	$t2, $zero, 4		# $t2 = $zero + 4
			blt		$t1, $t2, droppv	# if $t1 < $t2 then droopv

			# If we're too far over, we won't rotate
			addi	$t2, $zero, 5		# $t2 = $zero + 6
			bgt		$t0, $t2, droppv	# if $t0 > $t2 then droppv

			# If we're too close to the left edge, we drop
			beq		$t0, $zero, droppv	# if $t0 == $zero then droppv

			# Subtract 2 from Y to get to our pivot point
			addi	$t2, $zero, 2		# $t2 = $zero + 2
			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

			# We subtract 1 from X to check if the space is clear
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

			# We get the value at this position
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# if this space isn't clear, we don't want to rotate
			bne		$v0, $zero, droppv	# if $v0 != $zero then dropv

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add two spaces to X to check that space
			addi	$t2, $zero, 2		# $t2 = $zero + 2
			add		$t0, $t0, $t2		# $t0 = $t0 + $t2

			# We get the value at this position
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# if this space isn't clear, we don't want to rotate
			bne		$v0, $zero, droppv	# if $v0 != $zero then dropv

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add 1 and check the final space
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			add		$t0, $t0, $t2		# $t0 = $t0 + $t2

			# We get the value at this position
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# if this space isn't clear, we don't want to rotate
			bne		$v0, $zero, droppv	# if $v0 != $zero then dropv

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If we make it this far, we are free to rotate

			# We reload our PX and PY values
			lw		$t0, PX		#
			lw		$t1, PY		#

			# Set this value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Decreent from Y to move up
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

			# Set this value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# We decrement Y by 2 to get the top square
			addi	$t2, $zero, 2			# $t2 = $zero + 2
			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

			# Set this value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add 1 to Y and Subtract 1 from X to get to the far left position
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			add		$t1, $t1, $t2		# $t1 = $t1 + $t2
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

			# Set this value to 1
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1			# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add 2 to X to get to the right position
			addi	$t2, $zero, 2		# $t2 = $zero + 2
			add		$t0, $t0, $t2		# $t0 = $t0 + $t2

			# Set this value to 1
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1		# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add 1 to X to move to the far right position
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			add		$t0, $t0, $t2		# $t0 = $t0 + $t2

			# Set this value to 1
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1		# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# We want to store the new X and Y value
			sw		$t0, PX		#
			sw		$t1, PY		#

			# Set our rotation register to indicate we are horizontal
			addi	$t9, $zero, 2		# $t9 = $zero + 2

			j		dropph				# jump to dropph


		rotatephv:

			# Load X and Y
			lw		$t0, PX		#
			lw		$t1, PY		#

			# If Y is 0 then we don't allow rotation
			beq		$t1, $zero, dropph	# if $t1 == $zero then dropph

			# Subtract 2 from X to get the right pivot position
			addi	$t2, $zero, 2		# $t2 = $zero + 2
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

			# Subtract 1 from Y to shift up a block
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

			# Get the value stored here
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this spot is not free do not allow a rotation
			bne		$v0, $zero, dropph	# if $v0 != $zero then dropph

			# Add 2 to Y to get the next position to check
			addi	$t2, $zero, 2		# $t2 = $zero + 2
			add		$t1, $t1, $t2		# $t1 = $t1 + $t2

			# Get the value stored here
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this spot is not free do not allow a rotation
			bne		$v0, $zero, dropph	# if $v0 != $zero then dropph

			# Add 1 to Y to get the last spot to check
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			add		$t1, $t1, $t2		# $t1 = $t1 + $t2

			# Get the value stored here
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this spot is not free do not allow a rotation
			bne		$v0, $zero, dropph	# if $v0 != $zero then dropph

			# If we make it to this point then we are free to rotate

			# Load our original X and Y values
			lw		$t0, PX		#
			lw		$t1, PY		#

			# Set this value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Subtract 1 from X to get the square
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

			# Set this value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Subtract 2 from X to get the far left square
			addi	$t2, $zero, 2		# $t2 = $zero + 2
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

			# Set this value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add one 1 X to get back to pivot point and subtract 1 from Y to get the top square
			addi	$t0, $t0, 1			# $t0 = $t0 + 1
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

			# Set this value to 1
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1		# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add 2 to Y to drop it below the pivot
			addi	$t1, $t1, 2			# $t1 = $t1 + 2

			# Set this value to 1
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1		# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add 1 to Y to get to the last square
			addi	$t1, $t1, 1			# $t1 = $t1 + 1

			# Set this value to 1
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1		# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Store our new pivot
			sw		$t0, PX		#
			sw		$t1, PY		#

			# Set out rotation value to 1
			addi	$t9, $zero, 1			# $t9 = $zero + 1

			# Jump back to ploop
			j		ploop				# jump to ploop

	droppv:

		# Load our PX and PY value
		lw		$t0, PX		#
		lw		$t1, PY		#

		# We add 1 to look at the square below ours
		addi	$t1, $t1, 1		# $t2 = $zero + 1

        # Check to make sure we haven't gone to the end of the board
        addi    $t4, $zero, 16           # $t4 = $zero + 16
        beq     $t1, $t4, CHECKBOARD    # if $t1 == $t4 then UPDATEBOARD

		# Check what value is stored at this location
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		jal		GETARGXY			# jump to GETARGXY and save position to $ra

        # If the space isn't empty, we're done so check the board
        bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

        # Load our PX and PY value
        lw      $t0, PX     #
        lw      $t1, PY     #

        # We add 1 to PY since we're dropping some
        addi    $t1, $t1, 1            # $t1 = $t1 + 1

        # If we're not done, we store our new pointer
        sw      $t0, PX        #
        sw      $t1, PY        #

		# Set our new value to 1
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		addi	$a2, $zero, 1		# $a2 = $t2 + 1
		jal		SETXY				# jump to SETXY and save position to $ra

        # Load our PX and PY value
        lw      $t0, PX     #
        lw      $t1, PY     #

		# Keep subtracting one to move up the piece unless we hit the top of the board
		addi	$t2, $zero, 1			# $t2 = $zero + 1

		sub		$t4, $t1, $t2		# $t4 = $t1 - $t2
		beq		$t4, $zero, ploop	# if $t4 == $zero then ploop

		sub		$t4, $t4, $t2		# $t4 = $t4 - $t2
		beq		$t4, $zero, ploop	# if $t4 == $zero then ploop

		sub		$t4, $t4, $t2		# $t4 = $t4 - $t2
		beq		$t4, $zero, ploop	# if $t4 == $zero then ploop

		sub		$t4, $t4, $t2		# $t4 = $t4 - $t2

		# Set this value to 0 since we dropped below it
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t4, $zero		# $a1 = $t4 + $zero
		add		$a2, $zero, $zero	# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

        beq     $t4, $zero, ploop   # if $t4 == $zero then ploop

        # After we drop, we print
        jal     PRINTBOARD       # jump to PRINTBOARD and save position to $ra

		# If we make it this far then we are mid drop so we want more input
		j		ploop				# jump to ploop

	dropph:

		# Load our PX and PY values
		lw		$t0, PX		#
		lw		$t1, PY		#

		# Add 1 to Y to check below us
		addi	$t1, $t1, 1			# $t1 = $t1 + 1

		# If we're at the end of the board, we're done
		addi	$t2, $zero, 16			# $t2 = $zero + 16
		beq		$t1, $t2, CHECKBOARD	# if $t1 == $t2 then CHECKBOARD

		# Check the value of the board at this position
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		jal		GETARGXY			# jump to GETARGXY and save position to $read

		# Get our X and Y values back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a + $t2

		# If there is a piece here we don't move and check the board
		bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

		# Subtract 1 from X to check the next space
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

		# Check the value of the board at this position
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		jal		GETARGXY			# jump to GETARGXY and save position to $ra

		# Get our X and Y values back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a + $t2

		# If there is a piece here we don't move and check the board
		bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

		# Subtract 1 from X to check the next space
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

		# Check the value of the board at this position
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		jal		GETARGXY			# jump to GETARGXY and save position to $ra

		# Get our X and Y values back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a + $t2

		# If there is a piece here we don't move and check the board
		bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

		# Subtract 1 from X to check the next space
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

		# Check the value of the board at this position
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		jal		GETARGXY			# jump to GETARGXY and save position to $ra

		# Get our X and Y values back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a + $t2

		# If there is a piece here we don't move and check the board
		bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

		# If we're at this point then we want to make the move

		# We load the original X and Y
		lw		$t0, PX		#
		lw		$t1, PY		#

		# We want to set these top four results to 0
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $zero, $zero	# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

		# Get our X and Y back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

		# Subtract 1 from X to move to the next positon
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

		# We want to set these top four results to 0
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $zero, $zero	# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

		# Get our X and Y back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

		# Subtract 1 from X to move to the next positon
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

		# We want to set these top four results to 0
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $zero, $zero	# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

		# Get our X and Y back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

		# Subtract 1 from X to move to the next positon
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

		# We want to set these top four results to 0
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $zero, $zero	# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

		# Get our X and Y back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

		# We add 1 to Y to move to the next row
		addi	$t1, $t1, 1			# $t1 = $t1 + 1

		# We want to set this value to 1
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $t2, $zero		# $a2 = $t2 + $zero
	 	jal		SETXY				# jump to SETXY and save position to $ra

	 	# Get X and Y back
	 	add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	 	add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	 	# Add 1 to X to set the next spot
	 	addi	$t0, $t0, 1		# $t0 = $zero + 1

	 	# We want to set this value to 1
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $t2, $zero		# $a2 = $t2 + $zero
	 	jal		SETXY				# jump to SETXY and save position to $ra

	 	# Get X and Y back
	 	add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	 	add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	 	# Add 1 to X to set the next spot
	 	addi	$t0, $t0, 1		# $t0 = $zero + 1

	 	# We want to set this value to 1
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $t2, $zero		# $a2 = $t2 + $zero
	 	jal		SETXY				# jump to SETXY and save position to $ra

	 	# Get X and Y back
	 	add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	 	add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	 	# Add 1 to X to set the next spot
	 	addi	$t0, $t0, 1		# $t0 = $zero + 1

	 	# We want to set this value to 1
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $t2, $zero		# $a2 = $t2 + $zero
	 	jal		SETXY				# jump to SETXY and save position to $ra

	 	# Get X and Y back
	 	add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	 	add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	 	# We want to store our new pointers
	 	sw		$t0, PX		#
	 	sw		$t1, PY		#

	 	jal		PRINTBOARD				# jump to PRINTBOARD and save position to $ra


	 	# Since we haven't hit anything we jump to ploop and wait
	 	j		ploop				# jump to ploop


	moveprv:

		# Load the original PX and PY
		lw		$t0, PX		#
		lw		$t1, PY		#

		# Shift our x value to the right once
		addi	$t2, $t0, 1			# $t0 = $t0 + 1
		sw		$t2, PX		#

		# Initialize some counters
		addi	$t6, $zero, 4			# $t6 = $zero + 4
		addi	$t5, $zero, 1			# $t5 = $zero + 1

		moveprvloop:

			# Load 1 into a register since that's what we use for this piece
			addi	$t3, $zero, 1			# $t3 = $zero + 1

			# Reload PX
			lw		$t2, PX		#

			# Set the value at the current position
			add		$a0, $zero, $t2		# $a0 = $zero + $t2
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $t3		# $a2 = $zero + $t3
			jal		SETXY				# jump to SETXY

			# Move our Y value back since it certainly moved
			add		$t1, $a1, $zero		# $t1 = $a0 + $zero

			# Reload X and move it to the previous spot
			lw		$t0, PX		#
			addi	$t3, $zero, 1		# $t3 = $zero + 1
			sub		$t0, $t0, $t3		# $t0 = $t0 - $t3

			# We want to set the spot we moved from to zero
			add		$a0, $zero, $t0		# $a0 = $zero + $t0
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Reset X and Y after the function call
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If we're at the top of the board or we're done shifting pieces we wait for the next input
			beq		$t1, $zero, droppv	# if $t1 == $zero then droppv
			beq		$t5, $t6, droppv	# if $t5 == $t6 then droppv

			# We need to increase our counter and move our y-value
			addi	$t4, $zero, 1		# $t4 = $zero + 1
			add		$t5, $t5, $t4		# $t5 = $t5 + $t4
			sub		$t1, $t1, $t4		# $t1 = $t1 - $t4

			j		moveprvloop			# jump to moveprvloop

	moveplv:

		# Load the original PX and PY
		lw		$t0, PX		#
		lw		$t1, PY		#

		# Shift our x value to the left once
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		sub		$t2, $t0, $t3		# $t2t = $t0 - $t3
		sw		$t2, PX		#

		# Initialize some counters
		addi	$t6, $zero, 4			# $t6 = $zero + 4
		addi	$t5, $zero, 1			# $t5 = $zero + 1

		moveplvloop:

			# Load 1 into a register since that's what we use for this piece
			addi	$t3, $zero, 1			# $t3 = $zero + 1

			# Set the value at the current position
			add		$a0, $zero, $t2		# $a0 = $zero + $t2
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $t3		# $a2 = $zero + $t3
			jal		SETXY				# jump to SETXY

			# Move our Y value back
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Reload X and move it to the previous spot
			lw		$t0, PX		#
			addi	$t0, $t0, 1		# $t0 = $t0 + 1

			# We want to set the spot we moved from to zero
			add		$a0, $zero, $t0		# $a0 = $zero + $t0
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# We need to set our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If we're at the top of the board or we're done shifting pieces we wait for the next input
			beq		$t1, $zero, droppv	# if $t1 == $zero then droppv
			beq		$t5, $t6, droppv	# if $t5 == $t6 then droppv

			# We need to increase our counter and move our y-value
			addi	$t4, $zero, 1		# $t4 = $zero + 1
			add		$t5, $t5, $t4		# $t5 = $t5 + $t4
			sub		$t1, $t1, $t4		# $t1 = $t1 - $t4

			j		moveplvloop			# jump to moveprvloop

.globl CREATET
CREATET:

	# We're picking our middle position to be 3 so let's move X there
	# We also want to make sure we're starting at our top row as well
	addi	$t0, $zero, 3			# $t0 = X + 3
	addi	$t1, $zero, 0			# $t1 = $zero + 0

    # Store the value for safe keeping
    sw      $t0, PX        #
    sw      $t1, PY        #

	# Store the first position of the board
	add		$a0, $zero, $t0		# $a0 = $zero + $t0
	add		$a1, $zero, $t1		# $a1 = $tzero+ $t1
	addi	$a2, $zero, 7		# $a2 = $zero + 7
	jal		SETXY				# jump to SETXY and save position to $ra

	# $t9 holds the rotation state.
	addi	$t9, $zero, 1			# $t7 = $zero + 1

    # Start the piece loop
    j        tloop                # jump to ploop

    tloop:
    	# We want to print our board back to Python
        jal     PRINTBOARD           # jump to PRINTBOARD and save position to $ra

        # Prompt for user input from Python
        li        $a0, 1        # $a0 = 1
        li        $v0, 1        # $v0 = 1
        syscall

        # Print a new line
        li      $v0, 4      # system call #4 - print string
        la      $a0, newline    # $a0 = $zero + 15
        syscall             # execute

		# Make MIPS wait for integer input
		li		$v0, 5		# $v0 = 5
		syscall				# execute

    	# Check the response from Python and jump to the corresponding branch
    	addi	$t2, $zero, 1		# $t2 = $zero + 1
    	beq		$v0, $t2, shifttl	# if $v0 == $t2 then shifttl

    	addi	$t2, $zero, 2		# $t2 = $zero + 2
    	beq		$v0, $t2, shifttr	# if $v0 == $t2 then shifttr

    	addi	$t2, $zero, 3		# $t2 = $zero + 3
    	beq		$v0, $t2, rotatet	# if $v0 == $t2 then rotatet

    	# If we get this far then we just want to drop our piece
    	j		dropt				# jump to dropt

    shifttl:

    	# Determine which rotation state of the board and move to the correct shift loop
    	addi	$t0, $zero, 1			# $t0 = $zero + 1
    	beq		$t0, $t9, shifttlone	# if $t0 == $t9 then shifttlone

    	addi	$t0, $zero, 2			# $t0 = $zero + 2
    	beq		$t0, $t9, shifttltwo	# if $t0 == $t9 then shifttltwo

    	addi	$t0, $zero, 3			# $t0 = $zero + 3
    	beq		$t0, $t9, shifttlthree	# if $t0 == $t9 then shifttlthree

    	addi	$t0, $zero, 4			# $t0 = $zero + 4
    	beq		$t0, $t9, shifttlfour	# if $t0 == $t9 then shifttlfour

    	j		dropt				# jump to dropt

    	shifttlone:
    		# Load our X and Y values
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Subtract 1 from X to look to the left of the tooth
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

    		# If X is 0 we are at the edge and do not allow shift
    		beq		$t0, $zero, dropt	# if $t0 == $zero then dropt

    		# Get the value at this location
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this space isn't free we don't allow shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# Subtract 1 from X and Y to get to the top left edge
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

    		# Get the value at this location
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this space isn't free we don't allow shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# If we get to this part in the code we can shift

    		# Reload our X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Set this value to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Subtract 1 from Y and add 1 to X
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1

    		# Set this value to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Subtract 3 from X to get to the new far left
    		addi	$t2, $zero, 3		# $t2 = $zero + 3
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

    		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 1 to X and Y to get to new tooth
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1
    		addi	$t1, $t1, 1			# $t1 = $t1 + 1

    		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Store our new X and Y
    		sw		$t0, PX		#
    		sw		$t1, PY		#

    		# Drop our piece
    		j		dropt				# jump to dropt

    	shifttltwo:
    		# Load our X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# If X = 0 we dont allow the shift
    		beq		$t0, $zero, dropt	# if $t0 == $zero then dropt

    		# Subtract 1 from Y to check position above the tooth
    		addi	$t2, $zero, 1			# $t2 = $zero + 1
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

     		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY				# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero

    		# If this space isnt' clear we leave
    		bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

    		# Add 2 to Y to get the spot below the tooth
    		addi	$t1, $t1, 2			# $t1 = $t1 + 2

      		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY				# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero

    		# If this space isnt' clear we leave
    		bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

    		# Subtract 1 from X and Y to get to new position
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

    		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY				# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero

    		# If this space isnt' clear we leave
    		bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

    		# If we get to this part we're free to shift

    		# Reload our X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Add 1 to X to set that space 0
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1

    		# Set this value to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero		# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero


    		# Subtract 1 from Y to set that space to 0
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

    		# Set this value to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero		# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 2 to Y to get the bottom square
    		addi	$t1, $t1, 2			# $t1 = $t1 + 2

    		# Set this value to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Reload X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Subtract 1 from Y to get the new top
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

    		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 2 to Y to get the new bottom
    		addi	$t1, $t1, 2			# $t1 = $t1 + 2

       		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Subtract 1 from X and Y to get the new tooth
    		addi	$t2, $zero, 1			# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

       		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Store our new X and Y
    		sw		$t0, PX		#
    		sw		$t1, PY		#

    		# Drop our piece
    		j		dropt				# jump to dropt

    	shifttlthree:
    		# Load X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Subtract 1 from X to get the left side
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

    		# If we are along the edge dont allow shift
    		beq		$t0, $zero, dropt	# if $t0 == $zero then dropt

    		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# if this space is not 0 we dont shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# Add 1 to Y and subtract 1 from X to check left side
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
    		addi	$t1, $t1, 1			# $t1 = $t1 + 1

    		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# if this space is not 0 we dont shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# If we get to this point, we are free to shift

    		# Reload X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Set this value to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 1 to X and Y to get far right piece
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1
    		addi	$t1, $t1, 1			# $t1 = $t1 + 1

     		# Set this value to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Subtract 3 from X to get to new left side
    		addi	$t2, $zero, 3		# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

      		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 1 to X and subtract 1 from Y to get to new tooth
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1

     		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Store our new pointer
    		sw		$t0, PX		#
    		sw		$t1, PY		#

    		# Drop our piece
    		j		dropt				# jump to dropt

    	shifttlfour:
    		# Load X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Subtract 1 from X to get to the edge
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

    		# If X is 0 then we don't want to shift left
    		beq		$t0, $zero, dropt	# if $t0 == $zero then dropt

    		# Subtract 1 more for X to get to the empty space
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

    		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this value is not 0 then we get out
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# Subtract 1 from Y to look at the top space
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

    		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this value is not 0 then we get out
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# Add 2 to Y to get the bottom space
    		addi	$t1, $t1, 2			# $t1 = $t1 + 2

    		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this value is not 0 then we get out
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# If we get to this point then we can shift

    		# Reload X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Set this space to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Subtract 1 from X and Y to get top piece
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

     		# Set this space to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 2 to Y to get the bottom piece
    		addi	$t1, $t1, 2			# $t1 = $t1 + 2

    		# Set this space to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Subtract 1 from X to get the next space
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

    		# Set this space to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Subtract 1 from Y to get the middle space
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

    		# Set this space to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Subtract 1 from Y to get the top space
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

    		# Set this space to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 1 to X and Y to get the new tooth
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1
    		addi	$t1, $t1, 1			# $t1 = $t1 + 1

    		# Store our new pointer
    		sw		$t0, PX		#
    		sw		$t1, PY		#

    		# Drop our piece
    		j		dropt				# jump to dropt

    shifttr:

    	# Determine which rotation state of the board and move to the correct shift loop
    	addi	$t0, $zero, 1			# $t0 = $zero + 1
    	beq		$t0, $t9, shifttrone	# if $t0 == $t9 then shifttlone

    	addi	$t0, $zero, 2			# $t0 = $zero + 2
    	beq		$t0, $t9, shifttrtwo	# if $t0 == $t9 then shifttltwo

    	addi	$t0, $zero, 3			# $t0 = $zero + 3
    	beq		$t0, $t9, shifttrthree	# if $t0 == $t9 then shifttlthree

    	addi	$t0, $zero, 4			# $t0 = $zero + 4
    	beq		$t0, $t9, shifttrfour	# if $t0 == $t9 then shifttlfour

    	j		dropt				# jump to dropt

    	shifttrone:
   			# Load our X and Y values
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Add 1 to X to look to the right of the tooth
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1

    		# If X is 8 we are at the right edge and do not allow shift
    		addi	$t2, $zero, 7			# $t2 = $zero + 7
    		beq		$t0, $t2, dropt			# if $t0 == $t2 then dropt

    		# Get the value at this location
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this space isn't free we don't allow shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# Add 1 to X and subtract 1 from Y to get to upper right edge
    		addi	$t2, $zero, 1		# $t2 = $zero + 2
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1

    		# Get the value at this location
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this space isn't free we don't allow shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# If we get to this part in the code we can shift

    		# Reload our X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Set this value to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Subtract 1 from Y and X
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

    		# Set this value to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 3 to X to get to the new far left
    		addi	$t0, $t0, 3			# $t0 = $t0 + 3

    		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Subtract 1 from X and add 1 to Y
    		addi	$t2, $zero, 1			# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
    		addi	$t1, $t1, 1			# $t1 = $t1 + 1

    		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Store our new X and Y
    		sw		$t0, PX		#
    		sw		$t1, PY		#

    		# Drop our piece
    		j		dropt				# jump to dropt

    	shifttrtwo:
    		# Load our X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Add 1 to X to get the right-most edge
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1

    		# If this value is 7 then we don't want to shift
    		addi	$t2, $zero, 7		# $t2 = $zero + 7
    		beq		$t0, $t2, dropt	# if $t0 == $t2 then dropt

    		# Add one more to X to get the next space
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1

    		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this space isnt empty dont shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# Subtract 1 from Y to check the space above
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

     		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this space isnt empty dont shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# Add 1 to Y to get the bottom piece
    		addi	$t1, $t1, 2			# $t1 = $t1 + 1
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this space isnt empty dont shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# If we get to this place in the code we can shift

    		# Reload X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Set this position to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 1 to X and Y to get bottom piece
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1
    		addi	$t1, $t1, 1			# $t1 = $t1 + 1

    		# Set this position to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Subtract 2 from Y to get top piece
    		addi	$t2, $zero, 2		# $t2 = $zero + 2
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

    		# Set this position to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 1 to X to shift to new space
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1

    		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 1 to Y to get to the middle piece
    		addi	$t1, $t1, 1			# $t1 = $t1 + 1

    		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 1 to Y to set bottom piece
    		addi	$t1, $t1, 1			# $t1 = $t1 + 2

    		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Subtract 1 from X and Y to get to new tooth
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

    		# Store the new pointer
    		sw		$t0, PX		#
    		sw		$t1, PY		#

    		# Drop piece
    		j		dropt				# jump to dropt

    	shifttrthree:
    		# Load X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Add 1 to X to check right of the tooth
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1

    		#  If we're at the edge of the board, don't allow shift
    		addi	$t2, $zero, 7			# $t2 = $zero + 7
    		beq		$t0, $t2, dropt	# if $t0 == $t2 then dropt

    		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY				# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this space isn't 0, don't allow shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# Add 1 to X and Y to check far right side
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1
    		addi	$t1, $t1, 1			# $t1 = $t1 + 1

    		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this space isn't 0, don't allow shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# If we get to this point then we are cleared to shift

    		# Reload our X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Set this space to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 1 to Y and subtract 1 from X to get to left piece
    		addi	$t2, $zero, 1			# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
    		addi	$t1, $t1, 1			# $t1 = $t1 + 1

    		# Set this space to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 3 to X to get to new far side
    		addi	$t0, $t0, 3			# $t0 = $t0 + 3

    		# Set this space to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7 		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Subtract 1 from X and Y to get to new tooth
    		addi	$t2, $zero, 1			# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

   			# Set this space to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7 		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Store our new pointer
    		sw		$t0, PX		#
    		sw		$t1, PY		#

    		# Drop our piece
    		j		dropt				# jump to dropt

    	shifttrfour:
    		# Load our X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# If this space is at the edge of the board, don't shift
    		addi	$t2, $zero, 7		# $t2 = $zero + 7
    		beq		$t0, $t2, dropt	# if $t0 == $t2 then dropt

    		# Subtract 1 from Y to test the space above the tooth
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

    		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this space isn't 0, don't allow shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# Add 2 to Y to check the space below the tooth
    		addi	$t1, $t1, 2			# $t1 = $t1 + 2

    		# Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this space isn't 0, don't allow shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# Subtract 1 from Y and add 1 to X to check the right side
    		addi	$t2, $zero, 1		# $t2 = $zero + 1
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1

    		 # Get the value at this space
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# If this space isn't 0, don't allow shift
    		bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

    		# If we get to this point in the code we can shift

    		# Reload our X and Y
    		lw		$t0, PX		#
    		lw		$t1, PY		#

    		# Subtract 1 from X and Y to get the top piece
    		addi	$t2, $zero, 1			# $t2 = $zero + 1
    		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

    		# Set this space to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 1 to Y to get the next space
    		addi	$t1, $t1, 1			# $t1 = $t1 + 1

    		# Set this space to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 1 to Y to get the bottom piece
    		addi	$t1, $t1, 1			# $t1 = $t1 + 1

    		# Set this space to 0
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		add		$a2, $zero, $zero	# $a2 = $zero + $zero
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 1 to X to set the next piece
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1

    		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Subtract 2 from Y to get the new top piece
    		addi	$t2, $zero, 2		# $t2 = $zero + 1
    		sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

    		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Add 1 to X and Y to get the new tooth
    		addi	$t0, $t0, 1			# $t0 = $t0 + 1
    		addi	$t1, $t1, 1			# $t1 = $t1 + 1

    		# Set this value to 7
    		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
    		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
    		addi	$a2, $zero, 7		# $a2 = $zero + 7
    		jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
    		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
    		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

    		# Store our new pointer
    		sw		$t0, PX		#
    		sw		$t1, PY		#

    		# Drop the piece
    		j		dropt				# jump to dropt

   	dropt:

   		# We need to determine what the rotation state is
   		addi	$t0, $zero, 1			# $t0 = $zero + 1
   		beq		$t9, $t1, droptone	# if $t9 == $t1 then droptone

   		addi	$t0, $zero, 2			# $t0 = $zero + 2
   		beq		$t9, $t0, dropttwo	# if $t9 == $t0 then dropttwo

   		addi	$t0, $zero, 3			# $t0 = $zero + 3
   		beq		$t9, $t0, droptthree	# if $t9 == $t0 then dropthree

   		addi	$t0, $zero, 4			# $t0 = $zero + 4
   		beq		$t9, $t0, droptfour	# if $t9 == $t0 then droptfour


   		droptone:
	   		# Load our X and Y values
	   		lw		$t0, PX		#
	   		lw		$t1, PY		#

	   		# Add 1 to X to check the square to the right of the tooth
	   		addi	$t0, $t0, 1		# $t0 = $zero + 1

	   		# Get the value at this location
	   		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
	   		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
	   		jal		GETARGXY			# jump to GETARGXY and save position to $ra

	   		# Get our X and Y values back
	   		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	   		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	   		# If we detect a collision we kick out
	   		bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

	   		# We subtract two from X to get the other side of the tooth
	   		addi	$t2, $zero, 2		# $t2 = $zero + 2
	   		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

	   		# Get the value at this location
	   		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
	   		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
	   		jal		GETARGXY			# jump to GETARGXY and save position to $ra

	   		# Get our X and Y values back
	   		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	   		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	   		# If we detect a collision we kick out
	   		bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

	   		# We add 1 to X and Y look at the square below the tooth
			addi	$t1, $t1, 1		# $t2 = $zero + 1
			addi	$t0, $t0, 1		# $t0 = $t0 + 1

	        # Check to make sure we haven't gone to the end of the board
	        addi    $t4, $zero, 16           # $t4 = $zero + 16
	        beq     $t1, $t4, CHECKBOARD    # if $t1 == $t4 then UPDATEBOARD

			# Check what value is stored at this location
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	        # If the space isn't empty, we're done so check the board
	        bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

	        # We want to store the new Y value
			sw		$t1, PY		#

	        # Load our PX and PY value
	        lw      $t0, PX     #
	        lw      $t1, PY     #

			# Set our new value to 7
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 7		# $a2 = $t2 + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			#  We need to get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# We subtract 1 from Y to get to the top of the T
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

			# Set our new value to 7
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 7		# $a2 = $t2 + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Subtract 1 from X to get the left side
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

			# Set our new value to 7
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 7		# $a2 = $t2 + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add 2 to X to get the other end
			addi	$t0, $t0, 2			# $t0 = $t0 + 2

			# Set our new value to 7
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 7		# $a2 = $t2 + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If Y is 0 then we are done
			beq		$t1, $zero, tloop	# if $t1 == $zero then tloop

			# If we get to this point we need to clear the upper row

			# We subtract one from Y to get to the row above
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

			# Set our new value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Subtract 1 from X to get the middle-upper block
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

			# Set our new value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Subtract 1 from X to get the upper-left block
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

			# Set our new value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero		# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Done
			j		tloop				# jump to tloop

   		dropttwo:
   			# Load our X and Y
   			lw		$t0, PX		#
   			lw		$t1, PY		#

   			# Add 1 to Y to check square below tooth
   			addi	$t1, $t1, 1			# $t1 = $t1 + 1

   			# Get the value here
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			jal		GETARGXY			# jump to GETARGXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# If this value isn't 0, we have a collision
 			bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

   			# Add 1 to X and Y to check the bottom-most edge
   			addi	$t0, $t0, 1			# $t0 = $t0 + 1
   			addi	$t1, $t1, 1			# $t1 = $t1 + 1

   			# Get the value here
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			jal		GETARGXY			# jump to GETARGXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# If this value isn't 0, we have a collision
   			bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

   			# Check to make sure we haven't gone to the end of the board
	        addi    $t4, $zero, 16           # $t4 = $zero + 16
	        beq     $t1, $t4, CHECKBOARD    # if $t1 == $t4 then UPDATEBOARD

   			# If we get to this point then we can drop

   			# Load X and Y
   			lw		$t0, PX		#
   			lw		$t1, PY		#

   			# Set this value to 0
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			add		$a2, $zero, $zero	# $a2 = $zero + $zero
   			jal		SETXY				# jump to SETXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Add 1 to X and subtract 1 from Y to get top-most space
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2
   			addi	$t0, $t0, 1			# $t0 = $t0 + 1

   			# Set this value to 0
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			add		$a2, $zero, $zero	# $a2 = $zero + $zero
   			jal		SETXY				# jump to SETXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Add 3 to Y to get bottom-most piece
   			addi	$t1, $t1, 3			# $t1 = $t1 + 3

   			# Set this value to 7
   			add		$a0, $t0, $zero		# $a0 = $a0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			addi	$a2, $zero, 7		# $a2 = $zero + 7
   			jal		SETXY				# jump to SETXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Subtract 1 from Y and X to get to new tooth
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
   			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

   			# Set this value to 7
   			add		$a0, $t0, $zero		# $a0 = $a0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			addi	$a2, $zero, 7		# $a2 = $zero + 7
   			jal		SETXY				# jump to SETXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Store the new X and Y values
   			sw		$t0, PX		#
   			sw		$t1, PY		#

   			j		tloop				# jump to tloop

   		droptthree:
   			# Load our X and Y values
   			lw		$t0, PX		#
   			lw		$t1, PY		#

   			# Add 2 to Y to get to the bottom
   			addi	$t1, $t1, 2			# $t1 = $t1 + 2

   			# Check to make sure we haven't gone to the end of the board
	        addi    $t4, $zero, 16          # $t4 = $zero + 16
	        beq     $t1, $t4, CHECKBOARD    # if $t1 == $t4 then UPDATEBOARD

	        # Get the value at this space
	        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
	        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
	        jal		GETARGXY			# jump to GETARGXY and save position to $ra

	        # Get our X and Y back
	        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	        # if this space isnt 0 we leave
	        bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

	        # Add 1 to X to check the right space
	        addi	$t0, $t0, 1			# $t0 = $t0 + 1

	        # Get the value at this space
	        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
	        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
	        jal		GETARGXY			# jump to GETARGXY and save position to $ra

	        # Get our X and Y back
	        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	        # if this space isnt 0 we leave
	        bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

	        # Subtract 2 from X to check the other side
	        addi	$t2, $zero, 2		# $t2 = $zero + 2
	        sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

	        # Get the value at this space
	        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
	        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
	        jal		GETARGXY			# jump to GETARGXY and save position to $ra

	        # Get our X and Y back
	        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	        # if this space isnt 0 we leave
	        bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

	        # If we get to this point then we can drop

	        # Reload X and Y
	        lw		$t0, PX		#
	        lw		$t1, PY		#

	        # Set this value to 0
	        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
	        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
	        add		$a2, $zero, $zero	# $a2 = $zero + $zero
	        jal		SETXY				# jump to SETXY and save position to $ra

	        # Get our X and Y back
	        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	        # Add 1 to X and Y to get right piece
	        addi	$t0, $t0, 1			# $t0 = $t0 + 1
	        addi	$t1, $t1, 1			# $t1 = $t1 + 1

	        # Set this value to 0
	        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
	        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
	        add		$a2, $zero, $zero	# $a2 = $zero + $zero
	        jal		SETXY				# jump to SETXY and save position to $ra

	        # Get our X and Y back
	        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	        # Subtract 2 from X to get left side
	        addi	$t2, $zero, 2		# $t2 = $zero + 2
	        sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

	        # Set this value to 0
	        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
	        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
	        add		$a2, $zero, $zero	# $a2 = $zero + $zero
	        jal		SETXY				# jump to SETXY and save position to $ra

	        # Get our X and Y back
	        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	        # Add 1 to Y to add the next space
	        addi	$t1, $t1, 1			# $t1 = $t1 + 1

	        # Set this value to 7
	        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
	        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
	        addi	$a2, $zero, 7		# $a2 = $zero + 7
	        jal		SETXY				# jump to SETXY and save position to $ra

	       	# Get our X and Y back
	        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	        # Add 1 to X to get the new middle piece
	        addi	$t0, $t0, 1			# $t0 = $t0 + 1

	        # Set this value to 7
	        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
	        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
	        addi	$a2, $zero, 7		# $a2 = $zero + 7
	        jal		SETXY				# jump to SETXY and save position to $ra

	       	# Get our X and Y back
	        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	        # Add 1 to X to get the new right piece
	        addi	$t0, $t0, 1			# $t0 = $t0 + 1

	        # Set this value to 7
	        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
	        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
	        addi	$a2, $zero, 7		# $a2 = $zero + 7
	        jal		SETXY				# jump to SETXY and save position to $ra

	       	# Get our X and Y back
	        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	        # Subtract 1 from X and Y to get back to tooth
	        addi	$t2, $zero, 1		# $t2 = $zero + 1
	        sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
	        sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

	        # Store the new pointer
	        sw		$t0, PX		#
	        sw		$t1, PY		#

	        # Wait for more input
	        j		tloop				# jump to tloop

   		droptfour:
   			# Load our X and Y
   			lw		$t0, PX		#
   			lw		$t1, PY		#

   			# Add 1 to Y to check the space below the tooth
   			addi	$t1, $t1, 1			# $t1 = $t1 + 1

   			# Get the value at this position
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			jal		GETARGXY			# jump to GETARGYXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# If this value is not 0 we have a collision
   			bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

   			# Subtract 1 from X and add 1 to Y to get to bottom space
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
   			addi	$t1, $t1, 1			# $t1 = $t1 + 2

   			# If this space is 16 then we're done
   			addi	$t2, $zero, 16			# $t2 = $zero + 17
   			beq		$t1, $t2, CHECKBOARD	# if $t1 == $t2 then CHECKBOARD

   			# Get the value at this space
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			jal		GETARGXY			# jump to GETARGXY and save position to $ra

    		# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# If this value is not 0 we have a collision
   			bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

   			# If we make it to this point then we can drop

   			# Reload our X and Y
   			lw		$t0, PX		#
   			lw		$t1, PY		#

   			# Set this space to 0
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			add		$a2, $zero, $zero	# $a2 = $zero + $zero
   			jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Subtract 1 from X and Y to get the top piece
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
   			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

   			# Set this space to 0
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			add		$a2, $zero, $zero	# $a2 = $zero + $zero
   			jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Add 3 to Y to get to the new bottom piece
   			addi	$t1, $t1, 3			# $t1 = $t1 + 3

   			# Set this value to 7
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			addi	$a2, $zero, 7		# $a2 = $zero + $zero
   			jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Add 1 to X and subtract 1 Y to get to the new tooth
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2
   			addi	$t0, $t0, 1			# $t0 = $t0 + 1

   			# Set this value to 7
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			addi	$a2, $zero, 7		# $a2 = $zero + $zero
   			jal		SETXY				# jump to SETXY and save position to $ra

    		# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Store our new pointer
   			sw		$t0, PX		#
   			sw		$t1, PY		#

   			# Wait for new input
   			j		tloop				# jump to tloop

   	rotatet:

   		# We need to determine what the rotation state is
   		addi	$t0, $zero, 1			# $t0 = $zero + 1
   		beq		$t9, $t0, rotatetone	# if $t9 == $t1 then rotatetone

   		addi	$t0, $zero, 2			# $t0 = $zero + 2
   		beq		$t9, $t0, rotatettwo	# if $t9 == $t0 then rotatettwo

   		addi	$t0, $zero, 3			# $t0 = $zero + 3
   		beq		$t9, $t0, rotatetthree	# if $t9 == $t0 then rotatetthree

   		addi	$t0, $zero, 4			# $t0 = $zero + 4
   		beq		$t9, $t0, rotatetfour	# if $t9 == $t0 then rotatetfour

   		rotatetone:
   			# Load our X and Y values
   			lw		$t0, PX		#
   			lw		$t1, PY		#

   			# If only the first block is up, don't rotate
   			beq		$t1, $zero, dropt	# if $t1 == $zero then dropt

   			# Subtract 1 from Y to get the top edge
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

   			# If this is along the top row don't allow rotate
   			beq		$t1, $zero, dropt	# if $t1 == $zero then dropt

   			# Subtract 1 from Y to get where the new block will be
   			addi	$t2, $zero, 1		# $t2 = $zero + 2
   			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

   			# Check the value at this block
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			jal		GETARGXY			# jump to GETARGXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# If this value is not zero, do not allow rotation
   			bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

   			# If we make it this far, we are free to rotate

   			# Reload our X and Y
   			lw		$t0, PX		#
   			lw		$t1, PY		#

   			# Subtract 1 from Y and add 1 to X to get to the right space
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2
   			addi	$t0, $t0, 1			# $t0 = $t0 + 1

   			# Set this space to zero
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			add		$a2, $zero, $zero	# $a2 = $zero + $zero
   			jal		SETXY				# jump to SETXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Subtract 1 from X and Y to get to the top piece
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
   			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

   			# Set this value to 7
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			addi	$a2, $zero, 7		# $a2 = $zero + 7
   			jal		SETXY				# jump to SETXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Add 1 to Y and subtract 1 from X to get back to the new tooth
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
   			addi	$t1, $t1, 1			# $t1 = $t1 + 1

   			# Set this value to 7
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			addi	$a2, $zero, 7		# $a2 = $zero + 7
   			jal		SETXY				# jump to SETXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Store the new pivot
   			sw		$t0, PX		#
   			sw		$t1, PY		#

   			# Set our rotation marker to 2
   			addi	$t9, $zero, 2		# $t9 = $zero + 2

   			# Drop piece
   			j		dropt				# jump to dropt

   		rotatettwo:
   			# Load our X and Y values
   			lw		$t0, PX		#
   			lw		$t1, PY		#

   			# Add 1 to X to get to the right edge
   			addi	$t0, $t0, 1			# $t0 = $t0 + 1

   			# If we're at the edge we do not allow rotate
   			addi	$t2, $zero, 7		# $t2 = $zero + 7
   			beq		$t0, $t2, dropt	# if $t0 == $t2 then dropt

   			# Add 1 more to X to get to the next space
   			addi	$t0, $t0, 1			# $t0 = $t0 + 1

   			# Get the value at this location
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			jal		GETARGXY			# jump to GETARGXY and save position to $ra

   			# If this space is not zero do not allow rotate
   			bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

   			# If we get to this point in our code, we can rotate

   			# Reload our X and Y
   			lw		$t0, PX		#
   			lw		$t1, PY		#

   			# Add 1 to X and Y to get the bottom piece
   			addi	$t0, $t0, 1			# $t0 = $t0 + 1
   			addi	$t1, $t1, 1			# $t1 = $t1 + 1

   			# Set this value to 0
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			add		$a2, $zero, $zero	# $a2 = $zero + $zero
   			jal		SETXY				# jump to SETXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Subtract 1 from Y and add 1 to X to get far right piece
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2
   			addi	$t0, $t0, 1			# $t0 = $t0 + 1

   			# Set this value to 7
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			addi	$a2, $zero, 7		# $a2 = $zero + 7
   			jal		SETXY				# jump to SETXY and save position to $ra

   			# Get our X and Y values back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Subtract 1 from X and Y to get the new tooth
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
   			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

   			# Set this value to 7
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			addi	$a2, $zero, 7		# $a2 = $zero + 7
   			jal		SETXY				# jump to SETXY and save position to $ra

   			# Get our X and Y values back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Set our new pointer
   			sw		$t0, PX		#
   			sw		$t1, PY		#

   			# Set our rotation state to 3
   			addi	$t9, $zero, 3			# $t9 = $zero + 3

   			# Drop the piece
   			j		dropt				# jump to dropt


   		rotatetthree:
   			# Load our X and Y
   			lw		$t0, PX		#
   			lw		$t1, PY		#

   			# Add 2 to Y to get to the space below our piece
   			addi	$t1, $t1, 2			# $t1 = $t1 + 2

   			# If this space 17 then we don't allow rotation
   			addi	$t2, $zero, 17		# $t2 = $zero + 17
   			beq		$t1, $t2, dropt 	# if $t1 == $t2 then dropt

   			# Get the value at this space
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			jal		GETARGXY				# jump to GETARGXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# If this space isn't 0 then we don't allow rotation
   			bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

   			# If we make it to this point then we are clear to rotate

   			# Reload X and Y
   			lw		$t0, PX		#
   			lw		$t1, PY		#

   			# Add 1 to Y and subtract 1 from X to get to far left piece
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
   			addi	$t1, $t1, 1			# $t1 = $t1 + 1

   			# Set this piece to 0
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			add		$a2, $zero, $zero	# $a2 = $zero + $zero
   			jal		SETXY				# jump to SETXY and save position to $ra

  			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Add 1 to X and Y to get new bottom piece
   			addi	$t0, $t0, 1			# $to = $to + 1
   			addi	$t1, $t1, 1			# $t1 = $t1 + 1

   			# Set the piece to 7
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			addi	$a2, $zero, 7		# $a2 = $zero + $zero
   			jal		SETXY				# jump to SETXY and save position to $ra

  			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Subtract 1 from Y and add 1 to X to get new tooth
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2
   			addi	$t0, $t0, 1			# $t0 = $t0 + 1

  			# Set the piece to 7
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			addi	$a2, $zero, 7		# $a2 = $zero + $zero
   			jal		SETXY				# jump to SETXY and save position to $ra

  			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Store the new pointer
   			sw		$t0, PX		#
   			sw		$t1, PY		#

   			# Set our rotation value to 4
   			addi	$t9, $zero, 4			# $t9 = $zero + 4

   			# Drop the piece
   			j		dropt				# jump to dropt

   		rotatetfour:
   			# Load our X and Y
   			lw		$t0, PX		#
   			lw		$t1, PY		#

   			# Subtract 1 from X to get to the edge
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

   			# If this position is 0 we do not allow rotation
   			beq		$t0, $zero, dropt	# if $t0 == $zero then dropt

   			# Subtract 1 from X to get to the space over
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

   			# Get the value at this space
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			jal		GETARGXY			# jump to GETARGXY and save position to $ra

   			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# If this space isn't 0 then we don't allow rotation
   			bne		$v0, $zero, dropt	# if $v0 != $zero then dropt

   			# If we get to this point then we are allowed to rotate

   			# Reload our X and Y
   			lw		$t0, PX		#
   			lw		$t1, PY		#

   			# Subtract 1 from X and Y to get the top piece
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
   			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

   			# Set this piece to 0
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			add		$a2, $zero, $zero	# $a2 = $zero + $zero
   			jal		SETXY				# jump to SETXY and save position to $ra

  			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Add 1 to Y and subtract 1 from X to get right side
   			addi	$t2, $zero, 1		# $t2 = $zero + 1
   			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
   			addi	$t1, $t1, 1			# $t1 = $t1 + 1

   			# Set the piece to 7
   			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
   			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
   			addi	$a2, $zero, 7		# $a2 = $zero + $zero
   			jal		SETXY				# jump to SETXY and save position to $ra

  			# Get our X and Y back
   			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
   			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

   			# Add 1 to X and Y to get the new tooth
   			addi	$t0, $t0, 1			# $t0 = $t0 + 1
   			addi	$t1, $t1, 1			# $t1 = $t1 + 1

   			# Store our new pointer
   			sw		$t0, PX		#
   			sw		$t1, PY		#

   			# Set our rotation to 1
   			addi	$t9, $zero, 1			# $t9 = $zero + 1

   			# Drop our piece
   			j		dropt				# jump to dropt

.globl CREATEL
CREATEL:
        # We're picking our middle position to be 3 so let's move X there
        # We also want to make sure we're starting at our top row as well
        addi	$t0, $zero, 3			# $t0 = X + 3
        addi	$t1, $zero, 0			# $t1 = $zero + 0

        # Store the value for safe keeping
        sw      $t0, PX        #
        sw      $t1, PY        #

        # Store the first position of the board
        addi	$t2, $zero, 5		# $t1 = $zero + 1
        add		$a0, $zero, $t0		# $a0 = $zero + $t0
        add		$a1, $zero, $t1		# $a1 = $tzero+ $t1
        add		$a2, $zero, $t2		# $a2 = $zero + $t2
        jal		SETXY				# jump to SETXY and save position to $ra

        lw      $t0, PX        #
        lw      $t1, PY        #

        addi		$a0, $t0, 1		# $a0 = $zero + $t0
        add		$a1, $zero, $t1		# $a1 = $tzero+ $t1
        add		$a2, $zero, $t2		# $a2 = $zero + $t2
        jal		SETXY				# jump to SETXY and save position to $ra

        # $t9 holds the rotation state. 1 for vertical, 2 for horizontal
        ##  for this piece (the L), we'll need two more values:
        ## 3 for upside down, and 4 for horizontal in the opposite directon
        ## I'll probably implement this as a clock face moving widdershins,
        ## where 1 is 6, 2 is 3, 3 is 12, and 4 is 9.
        ##
        ## obviously we start in a vertical state
        addi	$t9, $zero, 1			# $t7 = $zero + 1

        ## start our loop for the L piece
        j lloop

lloop:
        ## print out our board
        jal PRINTBOARD

        # Prompt for user input from Python
        li        $a0, 1        # $a0 = 1
        li        $v0, 1        # $v0 = 1
        syscall

        # Print a new line
        li      $v0, 4      # system call #4 - print string
        la      $a0, newline    # $a0 = $zero + 15
        syscall             # execute

                        # Make MIPS wait for integer input
        li		$v0, 5		# $v0 = 5
        syscall				# execute

        # Load PX and PY
        lw		$t0, PX		#
        lw		$t1, PY		#

        # A counter for moving pieces
        addi	$t8, $zero, 1			# $t8 = $zero + 1

        # If Python sends us a 2 we want to shift our piece left
        addi	$t3, $zero, 1			# $t3 = $zero + 2
        beq	$v0, $t3, shiftll	# if $v0 == $t3 then shiftll

        # If Python sends us a 1 we want to shift our piece right
        addi	$t3, $zero, 2			# $t3 = $zero + 1
        beq	$v0, $t3, shiftlr	# if $v0 == $t3 then shiftlr

        # If Python sends us a 3 then we want to rotate the piece
        addi	$t3, $zero, 3			# $t3 = $zero + 3
        beq	$v0, $t3, rotatel	# if $v0 == $t3 then target

        # If our piece is in position 1 then drop vertical
        addi	$t3, $zero, 1			# $t3 = $zero + 1
        beq	$t9, $t3, droplv	# if $t9 == $t3 then droplv

        # If our piece is in position 2 then drop horizontal
        addi	$t3, $zero, 2			# $t3 = $zero + 2
        beq	$t9, $t3, droplh	# if $t9 == $t3 then droplh

        # If we get here something is wrong so we wait for another input
        j		lloop				# jump to lloop

shiftlr:

        # If we're moving past the end of the board we don't want to move
        addi    $t7, $zero, 6       # $t7 = $zero + 8
        beq     $t0, $t7, droplv    # if $t0 == $t7 then droplv

        # We add one to our PX-value for testing purposes
        addi	$t0, $t0, 1			# $t0 = $t0 + 1

        ## we add one to our PY value for testing purposes:
        addi    $t1, $t1, 1

        # We need a counter initialized for looping purposes
        addi	$t8, $zero, 1			# $t8 = $zero + 1

        # If $t9 == 1 then the pipe is vertical so move to that loop
        addi	$t3, $zero, 1			# $t3 = $zero + 1
        beq		$t9, $t3, shiftlrvloop	# if $t9 == $t3 then shiftlrvloop

        # If $t9 == 0 then the pipe is horizontal so move to that loop
        addi	$t3, $zero, 2			# $t3 = $zero + 2
        beq		$t9, $t3, shiftlrhloop	# if $t9 == $t3 then shiftlrhloop

        # If we don't hit one of these then something went wrong and it's best to change anything
        j		lloop				# jump to lloop

        shiftlrvloop1:
                ## check if our L bottom right is valid
                lw      $t0, PX
                lw      $t1, PY

                addi    $t0, $t0, 2

                add     $a0, $t0, $zero
                add     $a1, $t1, $zero
                jal     GETARGXY

                ## if we can't shift, drop
                bne     $v0, $zero, droplv

                b       movelrv

        shiftlrvloop:

                # Get the value stored at PX,PY
                add		$a0, $t0, $zero		# $a0 = $t0 + $zero
                add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                jal		GETARGXY			# jump to GETARGXY and save position to $ra

                # Get our values of x and y back
                add		$t0, $a0, $zero		# $t0 = $a0 + $zero
                add		$t1, $a1, $zero		# $t1 = $a1 + $zero

                # If this position is not free, then we don't want to shift
                bne		$v0, $zero, droplv	# if $v0 != $zero then droplv

                # Subtract 1 from y to move up
                addi	$t7, $zero, 1		# $t7 = $zero + 1
                sub		$t1, $t1, $t7		# $t1 = $t1 - $t7

                # If we've run this loop 3 times we've accounted for each square
                ## in the vertical
                addi	$t8, $t8, 1			# $8 = $t8 + 1
                addi	$t7, $zero, 2		# $t7 = $zero + 1
                beq	$t8, $t7, shiftlrvloop1	# if $t8 == $t1 then movelrv

                # If we're at the top row and we are here then we are free to move
                beq		$t1, $zero, movelrv	# if $t1 == $zero then movelrv

                # Jump back to the top of our loop
                j		shiftlrvloop			# jump to shiftlrloop

        shiftlrhloop:

                # Get the value stored at PX,PY
                add		$a0, $t0, $zero		# $a0 = $t0 + $zero
                add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                jal		GETARGXY			# jump to GETARGXY and save position to $ra

                # If this position is not free, then we don't want to shift
                bne		$t0, $zero, droplh	# if $t0 != $zero then droplh

                # Store a 1 in a register since we'll need it
                addi	$t3, $zero, 5			# $t3 = $zero + 1

                # If the spot is free we want to shift there
                add		$a0, $t0, $zero		# $a0 = $t0 + $zero
                add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                add		$a2, $t3, $zero		# $a2 = $t3 + $zero
                jal		SETXY				# jump to SETXY and save position to $ra

                # We want to store the new value of PX
                sw		$t0, PX		#

                # We now want to subtract to the beginning of the pipe
                sub		$t4, $t0, $t3		# $t4 = $t4 - $t3
                sub		$t4, $t4, $t3		# $t4 = $t4- $t3
                sub		$t4, $t4, $t3		# $t4 = $t4 - $t3
                sub		$t4, $t4, $t3		# $t4 = $t4 - $t3

                # Set this piece to 0 since we moved past the space
                add		$a0, $t4, $zero		# $a0 = $t4 + $zero
                add		$a1, $t1, $zero		# $a1 = $t4 + $zero
                add		$a2, $zero, $zero	# $a2 = $zero + $zero

                # We're done so let's drop our piece
                j		droplh				# jump to lloop


        shiftll:

                # If we're in the first column we don't even want to bother shifting
                beq		$t0, $zero, droplv	# if $t0 == $zero then droplv

                # We subtract 1 from our PX value for testing purposes
                addi	$t6, $zero, 1		# $t6 = $zero + 1
                sub		$t0, $t0, $t6		# $t0 = $t0 - $t6

                # If $t9 == 1 then the pipe is vertical so move to that loop
                addi	$t3, $zero, 1			# $t3 = $zero + 1
                beq		$t9, $t3, shiftllvloop	# if $t9 == $t3 then shiftlrvloop

                # If $t9 == 0 then the pipe is horizontal so move to that loop
                addi	$t3, $zero, 2			# $t3 = $zero + 2
                beq		$t9, $t3, shiftllhloop	# if $t9 == $t3 then shiftlrhloop

                # If we don't hit one of these then something went wrong and it's best to change anything
                j		droplv				# jump to droplv



                shiftllvloop:

                        # Get the value stored at PX,PY
                        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
                        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                        jal		GETARGXY			# jump to GETARGXY and save position to $ra

                        # We want to get our X and Y values back
                        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
                        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

                        # If this position is not free, then we don't want to shift
                        bne		$v0, $zero, droplv	# if $v0 != $zero then droplv

                        # If PY is 0 then we are at the top so we can move
                        beq		$t1, $zero, movellv	# if $t1 == $zero then movelrv

                        # Subtract 1 from y to move up
                        addi	$t7, $zero, 1		# $t7 = $zero + 1
                        sub		$t1, $t1, $t7		# $t1 = $t1 - $t7

                        # If we've run this loop 4 times we've accounted for each square
                        addi	$t8, $t8, 1			# $8 = $t8 + 1
                        addi	$t7, $zero, 4		# $t7 = $zero + 1
                        beq		$t8, $t7, movellv		# if $t8 == $t1 then movelrv

                        # Jump back to the top of our loop
                        j		shiftllvloop			# jump to shiftlrloop

                shiftllhloop:

                        # We will need this later
                        addi	$t3, $zero, 5			# $t3 = $zero + 1

                        # Since we subtracted one at the top, I'm in position
                        # 3 in relation to the pivot. I need to get to 0
                        sub		$t4, $t0, $t3		# $t4 = $t0 - $t3
                        sub		$t4, $t4, $t3		# $t4 = $t4 - $t3
                        sub		$t4, $t4, $t3		# $t4 = $t4 - $t3


                        # Get the value stored at PX,PY
                        add		$a0, $t4, $zero		# $a0 = $t0 + $zero
                        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                        jal		GETARGXY			# jump to GETARGXY and save position to $ra

                        # If this position is not free, then we don't want to shift
                        bne		$t0, $zero, droplh	# if $t0 != $zero then droplh

                        # If the spot is free we want to shift there
                        add		$a0, $t4, $zero		# $a0 = $t0 + $zero
                        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                        add		$a2, $t3, $zero		# $a2 = $t3 + $zero
                        jal		SETXY				# jump to SETXY and save position to $ra

                        # We want to store this value in PX since it represents the new pivot
                        sw		$t0, PX		#

                        # Since we subtracted once before coming here
                        # We want to add 1 to get back to the space to set 0
                        add		$t0, $t0, $t3		# $t0 = $t0 + $t3

                        # Set this piece to 0 since we moved past the space
                        add		$a0, $t0, $zero		# $a0 = $t4 + $zero
                        add		$a1, $t4, $zero		# $a1 = $t4 + $zero
                        add		$a2, $zero, $zero	# $a2 = $zero + $zero

                        # We're done so let's drop the piece
                        j		droplh				# jump to droplh

        rotatel:

        droplv:

                # Load our PX and PY value
                lw		$t0, PX		#
                lw		$t1, PY		#

                # We add 1 to look at the square below ours
                addi	$t1, $t1, 1		# $t2 = $zero + 1

                # Check to make sure we haven't gone to the end of the board
                addi    $t4, $zero, 16           # $t4 = $zero + 16
                beq     $t1, $t4, CHECKBOARD    # if $t1 == $t4 then UPDATEBOARD

                # Check what value is stored at this location
                add		$a0, $t0, $zero		# $a0 = $t0 + $zero
                add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                jal		GETARGXY			# jump to GETARGXY and save position to $ra

		        # If the space isn't empty, we're done so check the board
		        bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		        # Load our PX and PY value
		        lw      $t0, PX     #
		        lw      $t1, PY     #

		        # We add 1 to PY since we're dropping some
		        addi    $t1, $t1, 1            # $t1 = $t1 + 1

		        # If we're not done, we store our new pointer
		        sw      $t0, PX        #
		        sw      $t1, PY        #

                # Set our new value to 1
		        add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		        add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		        addi	$a2, $zero, 5		# $a2 = $t2 + 1
		        jal	SETXY			# jump to SETXY and save position to $ra

		        lw      $t0, PX     #
		        lw      $t1, PY     #

		        ##  now let's take care of the bottom of the L
		        addi    $a0, $t0, 1
		        add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		        addi	$a2, $zero, 5		# $a2 = $t2 + 1
		        jal	SETXY			# jump to SETXY and save position to $ra

		        lw      $t0, PX     #
		        lw      $t1, PY     #

		        ## time to erase our previous bottom of the L
		        addi    $a0, $t0, 1
		        addi	$a1, $t1, -1		# $a1 = $t1 + $zero
		        addi	$a2, $zero, 0		# $a2 = $t2 + 1
		        jal	SETXY			# jump to SETXY and save position to $ra

		        # Load our PX and PY value
		        lw      $t0, PX     #
		        lw      $t1, PY     #

		        # Keep subtracting one to move up the piece unless we hit the top of the board
		        addi	$t2, $zero, 1			# $t2 = $zero + 1

		        sub	$t4, $t1, $t2		# $t4 = $t1 - $t2
		        beq	$t4, $zero, lloop	# if $t4 == $zero then lloop

		        sub	$t4, $t4, $t2		# $t4 = $t4 - $t2
		        beq	$t4, $zero, lloop	# if $t4 == $zero then lloop

		        sub	$t4, $t4, $t2		# $t4 = $t4 - $t2

		        # Set this value to 0 since we dropped below it
		        add     $a0, $t0, $zero		# $a0 = $t0 + $zero
		        add	$a1, $t4, $zero		# $a1 = $t4 + $zero
		        add	$a2, $zero, $zero	# $a2 = $zero + $zero
		        jal	SETXY				# jump to SETXY and save position to $ra

		        beq     $t4, $zero, lloop   # if $t4 == $zero then lloop

		        # After we drop, we print
		        jal     PRINTBOARD       # jump to PRINTBOARD and save position to $ra

		        # If we make it this far then we are mid drop so we want more input
		        j		lloop				# jump to ploop

        droplh:

        movelrv:

                # Load the original PX and PY
                lw	$t0, PX		#
                lw	$t1, PY		#

                # Shift our x value to the right once
                addi	$t2, $t0, 1			# $t0 = $t0 + 1
                sw	$t2, PX		#

                # Initialize some counters
                addi	$t6, $zero, 4			# $t6 = $zero + 4
                addi	$t5, $zero, 1			# $t5 = $zero + 1

                movelrvloop:

                # Load 1 into a register since that's what we use for this piece
                addi	$t3, $zero, 5			# $t3 = $zero + 1

                # Reload PX
                lw	$t2, PX		#

                # Set the value at the current position
                add	$a0, $zero, $t2		# $a0 = $zero + $t2
                add	$a1, $zero, $t1		# $a1 = $zero + $t1
                add	$a2, $zero, $t3		# $a2 = $zero + $t3
                jal	SETXY				# jump to SETXY

                # Move our Y value back since it certainly moved
                add	$t1, $a1, $zero		# $t1 = $a0 + $zero

                # Reload X and move it to the previous spot
                lw	$t0, PX		#
                addi	$t3, $zero, 1		# $t3 = $zero + 1
                sub	$t0, $t0, $t3		# $t0 = $t0 - $t3

                # We want to set the spot we moved from to zero
                add	$a0, $zero, $t0		# $a0 = $zero + $t0
                add	$a1, $zero, $t1		# $a1 = $zero + $t1
                add	$a2, $zero, $zero	# $a2 = $zero + $zero
                jal	SETXY				# jump to SETXY and save position to $ra

                # Reset X and Y after the function call
                add	$t0, $a0, $zero		# $t0 = $a0 + $zero
                add	$t1, $a1, $zero		# $t1 = $a1 + $zero

                # If we're at the top of the board or we're done shifting pieces we wait for the next input
                beq	$t1, $zero, droplv	# if $t1 == $zero then droplv
                beq	$t5, $t6, droplv	# if $t5 == $t6 then droplv

                # We need to increase our counter and move our y-value
                addi	$t4, $zero, 1		# $t4 = $zero + 1
                add	$t5, $t5, $t4		# $t5 = $t5 + $t4
                sub	$t1, $t1, $t4		# $t1 = $t1 - $t4

                j	movelrvloop			# jump to movelrvloop

        movellv:

                # Load the original PX and PY
                lw	$t0, PX		#
                lw	$t1, PY		#

                # Shift our x value to the left once
                addi	$t3, $zero, 1			# $t3 = $zero + 1
                sub	$t2, $t0, $t3		# $t2t = $t0 - $t3
                sw	$t2, PX		#

                # Initialize some counters
                addi	$t6, $zero, 3			# $t6 = $zero + 4
                addi	$t5, $zero, 1			# $t5 = $zero + 1

                ## move our derpy bottom of the L piece
                addi    $a0, $t2, 2
                add     $a1, $zero, $t1
                add     $a2, $zero, $zero
                jal     SETXY

                # We need to set our X and Y back
                add	$t0, $a0, $zero		# $t0 = $a0 + $zero
                add	$t1, $a1, $zero		# $t1 = $a1 + $zero

                movellvloop:

                        # Load 1 into a register since that's what we use for this piece
                        addi	$t3, $zero, 5			# $t3 = $zero + 1

                        # Set the value at the current position
                        add		$a0, $zero, $t2		# $a0 = $zero + $t2
                        add		$a1, $zero, $t1		# $a1 = $zero + $t1
                        add		$a2, $zero, $t3		# $a2 = $zero + $t3
                        jal		SETXY				# jump to SETXY

                        # Move our Y value back
                        add	$t1, $a1, $zero		# $t1 = $a1 + $zero

                        # Reload X and move it to the previous spot
                        lw		$t0, PX		#
                        addi	$t0, $t0, 1		# $t0 = $t0 + 1

                        # We want to set the spot we moved from to zero
                        add		$a0, $zero, $t0		# $a0 = $zero + $t0
                        add		$a1, $zero, $t1		# $a1 = $zero + $t1
                        add		$a2, $zero, $zero	# $a2 = $zero + $zero
                        jal		SETXY				# jump to SETXY and save position to $ra

                        # We need to set our X and Y back
                        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
                        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

                        # If we're at the top of the board or we're done shifting pieces we wait for the next input
                        beq		$t1, $zero, droplv	# if $t1 == $zero then droplv
                        beq		$t5, $t6, droplv	# if $t5 == $t6 then droplv

                        # We need to increase our counter and move our y-value
                        addi	$t4, $zero, 1		# $t4 = $zero + 1
                        add		$t5, $t5, $t4		# $t5 = $t5 + $t4
                        sub		$t1, $t1, $t4		# $t1 = $t1 - $t4

                        j		movellvloop			# jump to movelrvloop


.globl CREATEBL
CREATEBL:

	# We're picking our middle position to be 3 so let's move X there
	# We also want to make sure we're starting at our top row as well
	#the PX and PY are the corner of the L
	addi	$t0, $zero, 4			# $t0 = X + 3
	addi	$t1, $zero, 0			# $t1 = $zero + 0

	# Store the value for safe keeping
	sw      $t0, PX        #
	sw      $t1, PY        #

	#store the first two blocks on the board
	addi	$t2, $zero, 6
	add	$a0, $zero, $t0
	add	$a1, $zero, $t1
	add	$a2, $zero, $t2
	jal	SETXY

	addi	$t0, $a0, -1
	add	$t1, $zero, $a1

	addi	$t2, $zero, 6
	add	$a0, $zero, $t0
	add	$a1, $zero, $t1
	add	$a2, $zero, $t2
	jal	SETXY

	# $t9 holds the rotation state. 1=bL, 2=horizontalupright, 3=r, 4=horizontaldown
	addi	$t9, $zero, 1			# $t7 = $zero + 1

	j	blloop

	blloop:
		# We want to print our board back to Python
		jal     PRINTBOARD           # jump to PRINTBOARD and save position to $ra

		# Prompt for user input from Python
		li        $a0, 1        # $a0 = 1
		li        $v0, 1        # $v0 = 1
		syscall

	# Print a new line
		li      $v0, 4      # system call #4 - print string
		la      $a0, newline    # $a0 = $zero + 15
		syscall             # execute

		# Make MIPS wait for integer input
		li	$v0, 5		# $v0 = 5
		syscall				# execute

		# Load PX and PY
		lw	$t0, PX		#
		lw	$t1, PY		#

		# A counter for moving pieces
		addi	$t8, $zero, 1			# $t8 = $zero + 1

		# If Python sends us a 1 we want to shift our piece left
		addi	$t3, $zero, 1			# $t3 = $zero + 2
		beq	$v0, $t3, shiftbll	# if $v0 == $t3 then shiftbll

		# If Python sends us a 2 we want to shift our piece right
		addi	$t3, $zero, 2			# $t3 = $zero + 1
		beq	$v0, $t3, shiftblr	# if $v0 == $t3 then shiftblr

		# If Python sends us a 3 then we want to rotate the piece
		addi	$t3, $zero, 3			# $t3 = $zero + 3
		beq	$v0, $t3, rotatebl	# if $v0 == $t3 then rotatebl

		# Otherwise dropbl
		j	dropbl				# jump to dropbl


rotatebl:
		#if $t9 = 1, rotate 1 to 2
		addi	$t3, $zero, 1
		beq	$t3, $t9, rotatebl1to2

		#if $t9 = 2, rotate 2 to 3
		addi	$t3, $zero, 2
		beq	$t3, $t9, rotatebl2to3

		#if $t9 = 3, rotate 3 to 4
		addi	$t3, $zero, 3
		beq	$t3, $t9, rotatebl3to4

		#otherwise rotate 4 to 1
		j	rotatebl4to1

		rotatebl1to2:
			#make sure we wont go off the edge
			addi	$t7, $zero, 5
			bge	$t0, $t7, dropbl

			#check if botton right is clear
			addi	$t0, $t0, 2

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

			#check if top left is clear
			addi	$t0, $t0, -1

			#check if its still on the board
			blt	$t1, $zero, dorotatebl1to2

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

		dorotatebl1to2:
			addi	$t3, $zero, 6

			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			addi	$t0, $t0, 1

			#mark new squares bottom row
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#add middle row squares
			addi	$t0, $t0, 1

			#check if its still on the board
			blt	$t1, $zero, endrotatebl1to2

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old squares in bottom row
			addi	$t0, $t0, -3

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#remove top of long part
			addi	$t1, $t1, -2
			addi	$t0, $t0, 1

			#check if its still on the board
			blt	$t1, $zero, endrotatebl1to2

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra

		endrotatebl1to2:
			addi	$t9, $zero, 2
			j	dropbl

		rotatebl2to3:
			#make sure we wont go off the edge
			addi	$t7, $zero, 13
			bge		$t2, $t7, dropbl

			#check to see if bottom is empty
			addi	$t1, $t1, 1

			#check if its still on the board
			blt	$t1, $zero, dorotatebl2to3

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

			#check to see if swing through is empty
			addi	$t1, $t1, 1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

		dorotatebl2to3:
			addi	$t3, $zero, 6

			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#erase far right
			addi	$t0, $t0, 2

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase spike
			addi	$t0, $t0, -2
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, endrotatebl2to3

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#add first piece
			addi	$t1, $t1, 2

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#add new bottom
			addi	$t1, $t1, 1

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

		endrotatebl2to3:
			addi	$t9, $zero, 3
			j	dropbl

		rotatebl3to4:
			#make sure we wont go off the edge
			addi	$t7, $zero, 2
			ble	$t0, $t7, dropbl

			#check if botton right is clear
			addi	$t0, $t0, -2

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

			#check if top left is clear
			addi	$t0, $t0, -2

			#check if its still on the board
			blt	$t1, $zero, dorotatebl3to4

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

		dorotatebl3to4:
			addi	$t3, $zero, 6

			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			addi	$t0, $t0, -2

			#mark new squares top row
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#add middle row squares
			addi	$t0, $t0, 1

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase above pivot
			addi	$t0, $t0, 2

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase next above
			addi	$t0, $t0, -1
			addi	$t1, $t1, 2

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra

		endrotatebl3to4:
			addi	$t9, $zero, 4
			j	dropbl


		rotatebl4to1:

			#make sure we wont go off the edge
			addi	$t7, $zero, 2
			ble		$t0, $t7, dropbl

			#check to see if top is empty
			addi	$t1, $t1, -2

			#check if its still on the board
			blt	$t1, $zero, dorotatebl4to1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

			#check to see if middle stack is free
			addi	$t1, $t1, 1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

		dorotatebl4to1:
			addi	$t3, $zero, 6

			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#erase far left
			addi	$t0, $t0, -2

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase spike
			addi	$t1, $t1, 1
			addi	$t0, $t0, 2

			#check if its still on the board
			blt	$t1, $zero, endrotatebl4to1

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#add first piece
			addi	$t1, $t1, -2

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#add new bottom
			addi	$t1, $t1, -1

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero


		endrotatebl4to1:
			addi	$t9, $zero, 1
			j	dropbl


	shiftbll:

		#if $t9 = 1, shiftbll1
		addi	$t3, $zero, 1
		beq	$t3, $t9, shiftbll1

		#if $t9 = 2, shiftbll2
		addi	$t3, $zero, 2
		beq	$t3, $t9, shiftbll2

		#if $t9 = 3, shiftbll3
		addi	$t3, $zero, 3
		beq	$t3, $t9, shiftbll3

		#otherwise shiftbll4
		j	shiftbll4

		shiftbll1:
			#move one to the left to check for space to move
			addi	$t0, $t0, -1

			#if in far left, don't shift, just drop
			beq	$t0, $zero, dropbl

			#move to left of bottom line
			addi	$t0, $t0, -1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

			#move to check to the left of the middle row
			addi	$t0, $t0, 1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftbll1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then droppv

			#move to check to the left of the top row
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftbll1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then droppv

		doshiftbll1:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the left
			addi	$t0, $t0, -1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 6

			#move to left of bottom row
			addi	$t0, $t0, -1

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in middle line
			addi	$t0, $t0, -1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropbl

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in top line
			addi	$t0, $t0, -1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropbl

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropbl

		shiftbll2:
			beq	$t0, $zero, dropbl

			#move one to the left to check for space to move
			addi	$t0, $t0, -1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

			#check to the left of the top row
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftbll2

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

		doshiftbll2:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the left
			addi	$t0, $t0, -1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 6

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot
			addi	$t0, $t0, 3
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in top line
			addi	$t0, $t0, -3
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropbl

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropbl
		shiftbll3:

			#if in far left, don't shift, just drop
			beq	$t0, $zero, dropbl

			#move one to the left to check for space to move
			addi	$t0, $t0, -1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

			#move to check to the left of the middle row
			addi	$t1, $t1, 1

			#check if its still on the board
			blt	$t1, $zero, doshiftbll3

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then droppv

			#move to check to the left of the top row
			addi	$t1, $t1, 1

			#check if its still on the board
			blt	$t1, $zero, doshiftbll3

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then droppv

		doshiftbll3:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the left
			addi	$t0, $t0, -1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 6

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in middle line
			addi	$t0, $t0, -2
			addi	$t1, $t1, 1

			#check if its still on the board
			blt	$t1, $zero, dropbl

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in top line
			addi	$t0, $t0, -1
			addi	$t1, $t1, 1

			#check if its still on the board
			blt	$t1, $zero, dropbl

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropbl


		shiftbll4:
			#move to left of top row
			addi	$t0, $t0, -2

			#if in far left, don't shift, just drop
			beq	$t0, $zero, dropbl

			#move one to the left to check for space to move
			addi	$t0, $t0, -1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

			#move to check to the left of the middle row
			addi	$t0, $t0, 2
			addi	$t1, $t1, 1

			#check if its still on the board
			blt	$t1, $zero, doshiftbll4

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then droppv

		doshiftbll4:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the left
			addi	$t0, $t0, -1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 6

			#move to left of top row
			addi	$t0, $t0, -2

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 3
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in middle line
			addi	$t0, $t0, -1
			addi	$t1, $t1, 1

			#check if its still on the board
			blt	$t1, $zero, dropbl

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropbl

	shiftblr:

		#if $t9 = 1, shiftblr1
		addi	$t3, $zero, 1
		beq	$t3, $t9, shiftblr1

		#if $t9 = 2, shiftblr2
		addi	$t3, $zero, 2
		beq	$t3, $t9, shiftblr2

		#if $t9 = 3, shiftblr3
		addi	$t3, $zero, 3
		beq	$t3, $t9, shiftblr3

		#otherwise shiftblr4
		j	shiftblr4

		shiftblr1:
			#if right side in far right, do not shift
			addi	$t0, $t0, 1
			addi	$t7, $zero, 8
			beq	$t0, $t7, dropbl

			#move one to the right to check for space to move
			addi	$t0, $t0, 1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

			#move one up to check for space to move
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftblr1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then droppv

			#move up one and left one for space to move
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftblr1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then droppv

		doshiftblr1:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the right
			addi	$t0, $t0, 1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 6

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of bottom line
			addi	$t0, $t0, -2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in middle line
			addi	$t0, $t0, 2
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropbl

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of middle line
			addi	$t0, $t0, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in top line
			addi	$t0, $t0, 1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropbl

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of top line
			addi	$t0, $t0, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropbl

		shiftblr2:

			addi	$t7, $zero, 5
			bge	$t0, $t7, dropbl

			#check for space to shift far right
			addi	$t0, $t0, 3

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

			#check for space to shift in the top line
			addi	$t0, $t0, -2
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftblr2

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then droppv

		doshiftblr2:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the right
			addi	$t0, $t0, 1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 6

			# writing the values in the new spots
			addi	$t0, $t0, 2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -3
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move blocks in top line
			addi	$t0, $t0, 1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropbl

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropbl
		shiftblr3:

			#if right side in far right, do not shift
			addi	$t0, $t0, 1
			addi	$t1, $t1, 2
			addi	$t7, $zero, 7
			beq	$t0, $t7, dropbl

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

			#move one up to check for space to move
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftblr3

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then droppv

			#move up one and left one for space to move
			addi	$t1, $t1, -1
			addi	$t0, $t0, 1

			#check if its still on the board
			blt	$t1, $zero, doshiftblr3

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then droppv

		doshiftblr3:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the right
			addi	$t0, $t0, 1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 6

			#move to new spot in top row
			addi	$t0, $t0, 1

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in middle line
			addi	$t0, $t0, 1
			addi	$t1, $t1, 1

			#check if its still on the board
			blt	$t1, $zero, dropbl

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of middle row
			addi	$t0, $t0, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in top line
			addi	$t0, $t0, 1
			addi	$t1, $t1, 1

			#check if its still on the board
			blt	$t1, $zero, dropbl

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra

			j	dropbl

		shiftblr4:
			#if right side in far right, do not shift
			addi	$t7, $zero, 7
			bge	$t0, $t7, dropbl

			#move one to the right to check for space to move
			addi	$t0, $t0, 1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then dropbl

			#move one up to check for space to move
			addi	$t1, $t1, 1

			#check if its still on the board
			blt	$t1, $zero, doshiftblr4

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbl	# if $v0 != $zero then droppv

		doshiftblr4:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the right
			addi	$t0, $t0, 1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 6

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of top row
			addi	$t0, $t0, -3
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in bottom line
			addi	$t0, $t0, 3
			addi	$t1, $t1, 1

			#check if its still on the board
			blt	$t1, $zero, dropbl

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of bottom row
			addi	$t0, $t0, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropbl


	dropbl:

		#if $t9 = 1, dropbl1
		addi	$t3, $zero, 1
		beq	$t3, $t9, dropbl1

		#if $t9 = 2, dropbl2
		addi	$t3, $zero, 2
		beq	$t3, $t9, dropbl2

		#if $t9 = 3, dropbl3
		addi	$t3, $zero, 3
		beq	$t3, $t9, dropbl3

		#otherwise dropbl4
		j	dropbl4

		dropbl1:
			#load our PX and PY values
			lw	$t0, PX
			lw	$t1, PY

			#add one to look at the sqare below ours
			addi	$t1, $t1, 1

			#check to make sure we don't go past the bottom of the board
			addi	$t4, $zero, 16
			beq 	$t1, $t4, CHECKBOARD

			#check what value is stored at this loaction
			add	$a0, $t0, $zero
			add	$a1, $t1, $zero
			jal	GETARGXY

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If the space isn't empty, we're done so check the board
			bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

			#check other hazard spot
			addi	$t0, $t0, -1

			#check what value is stored at this loaction
			add	$a0, $t0, $zero
			add	$a1, $t1, $zero
			jal	GETARGXY

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If the space isn't empty, we're done so check the board
			bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

			# Load our PX and PY value
			lw      $t0, PX     #
			lw      $t1, PY     #

			# We add 1 to PY since we're dropping some
			addi    $t1, $t1, 1            # $t1 = $t1 + 1

			# If we're not done, we store our new pointer
			sw      $t0, PX        #
			sw      $t1, PY        #

			#valueto be stored for the piece
			addi	$t3, $zero, 6

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot
			addi	$t1, $t1, -3
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#drop left column
			addi	$t0, $t0, -1
			addi	$t1, $t1, 3

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old top
			addi	$t1, $t1, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	blloop

		dropbl2:
			#load our PX and PY values
			lw	$t0, PX
			lw	$t1, PY

			#add one to look at the sqare below ours
			addi	$t1, $t1, 1

			#check to make sure we don't go past the bottom of the board
			addi	$t4, $zero, 16
			beq 	$t1, $t4, CHECKBOARD

			#check what value is stored at this loaction
			add	$a0, $t0, $zero
			add	$a1, $t1, $zero
			jal	GETARGXY

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If the space isn't empty, we're done so check the board
		    	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

			#check other hazard spot
			addi	$t0, $t0, 1

			#check what value is stored at this loaction
			add	$a0, $t0, $zero
			add	$a1, $t1, $zero
			jal	GETARGXY

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If the space isn't empty, we're done so check the board
		    	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

			#check other hazard spot
			addi	$t0, $t0, 1

			#check what value is stored at this loaction
			add	$a0, $t0, $zero
			add	$a1, $t1, $zero
			jal	GETARGXY

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If the space isn't empty, we're done so check the board
		    	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

			# Load our PX and PY value
		    	lw      $t0, PX     #
		    	lw      $t1, PY     #

		    	# We add 1 to PY since we're dropping some
		    	addi    $t1, $t1, 1            # $t1 = $t1 + 1

		    	# If we're not done, we store our new pointer
		    	sw      $t0, PX        #
		    	sw      $t1, PY        #

			#valueto be stored for the piece
			addi	$t3, $zero, 6

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot
			addi	$t1, $t1, -2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#drop middle column
			addi	$t0, $t0, 1
			addi	$t1, $t1, 2

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t1, $t1, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#drop right column
			addi	$t0, $t0, 1
			addi	$t1, $t1, 1

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t1, $t1, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	blloop

		dropbl3:

			#load our PX and PY values
			lw	$t0, PX
			lw	$t1, PY

			#add one to look at the sqare below ours
			addi	$t1, $t1, 3

			#check to make sure we don't go past the bottom of the board
			addi	$t4, $zero, 16
			beq 	$t1, $t4, CHECKBOARD

			#check what value is stored at this loaction
			add	$a0, $t0, $zero
			add	$a1, $t1, $zero
			jal	GETARGXY

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If the space isn't empty, we're done so check the board
			bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

			#check other hazard spot
			addi	$t0, $t0, 1
			addi	$t1, $t1, -2

			#check what value is stored at this loaction
			add	$a0, $t0, $zero
			add	$a1, $t1, $zero
			jal	GETARGXY

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If the space isn't empty, we're done so check the board
			bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

			# Load our PX and PY value
			lw      $t0, PX     #
			lw      $t1, PY     #

			# We add 1 to PY since we're dropping some
			addi    $t1, $t1, 1            # $t1 = $t1 + 1

			# If we're not done, we store our new pointer
			sw      $t0, PX        #
			sw      $t1, PY        #

			#valueto be stored for the piece
			addi	$t3, $zero, 6

			#move to bottom of left column
			addi	$t1, $t1, 2

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot
			addi	$t1, $t1, -3
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#drop left column
			addi	$t0, $t0, 1
			addi	$t1, $t1, 1

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old top
			addi	$t1, $t1, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	blloop

		dropbl4:

			#load our PX and PY values
			lw	$t0, PX
			lw	$t1, PY

			#look below spike
			addi	$t1, $t1, 2

			#check to make sure we don't go past the bottom of the board
			addi	$t4, $zero, 16
			beq 	$t1, $t4, CHECKBOARD

			#check what value is stored at this loaction
			add	$a0, $t0, $zero
			add	$a1, $t1, $zero
			jal	GETARGXY

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If the space isn't empty, we're done so check the board
		    bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

			#check other hazard spot
			addi	$t0, $t0, -1
			addi	$t1, $t1, -1

			#check what value is stored at this loaction
			add	$a0, $t0, $zero
			add	$a1, $t1, $zero
			jal	GETARGXY

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If the space isn't empty, we're done so check the board
		    	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

			#check other hazard spot
			addi	$t0, $t0, -1

			#check what value is stored at this loaction
			add	$a0, $t0, $zero
			add	$a1, $t1, $zero
			jal	GETARGXY

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If the space isn't empty, we're done so check the board
		    	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

			# Load our PX and PY value
	    	lw      $t0, PX     #
	    	lw      $t1, PY     #

	    	# We add 1 to PY since we're dropping some
	    	addi    $t1, $t1, 1            # $t1 = $t1 + 1

	    	# If we're not done, we store our new pointer
	    	sw      $t0, PX        #
	    	sw      $t1, PY        #

			#valueto be stored for the piece
			addi	$t3, $zero, 6

			#move to bottom of the right column
			addi	$t1, $t1, 1

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot
			addi	$t1, $t1, -2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#drop middle column
			addi	$t0, $t0,-1
			addi	$t1, $t1, 1

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t1, $t1, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#drop left column
			addi	$t0, $t0, -1

			# erase
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#draw spike
			addi	$t1, $t1, 1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	blloop





.globl CREATES
CREATES:

	# Left block is 3,so let's move X there
	# We also want to make sure we're starting at our top row as well
	addi	$t0, $zero, 3			# $t0 = X + 3
	addi	$t1, $zero, 0			# $t1 = $zero + 0

    # Store the value for safe keeping
    sw      $t0, PX        #
    sw      $t1, PY        #

	# Store the left side on the board, value = 2 for SQUARE
	addi	$t2, $zero, 2		# $t2 = $zero + 2
	add		$a0, $zero, $t0		# $a0 = $zero + $t0
	add		$a1, $zero, $t1		# $a1 = $tzero+ $t1
	add		$a2, $zero, $t2		# $a2 = $zero + $t2
	jal		SETXY				# jump to SETXY and save position to $ra

	# Right block is 4, X now starts on bottom right
	addi	$t0, $zero, 4
	addi 	$t1, $zero, 0

	# Store the value
	sw		$t0, PX
	sw		$t1, PY

	# Store right side on board
	add		$t2, $zero, 2
	add		$a0, $zero, $t0
	add		$a1, $zero, $t1
	add		$a2, $zero, $t2
	jal		SETXY

    # Start the piece loop
    j        sloop                # jump to sloop


	sloop:

        # We want to print our board back to Python
        jal     PRINTBOARD           # jump to PRINTBOARD and save position to $ra

        # Prompt for user input from Python
        li        $a0, 1        # $a0 = 1
        li        $v0, 1        # $v0 = 1
        syscall

        # Print a new line
        li      $v0, 4      # system call #4 - print string
        la      $a0, newline    # $a0 = $zero + 15
        syscall             # execute

		# Make MIPS wait for integer input
		li		$v0, 5		# $v0 = 5
		syscall				# execute

		# Load PX and PY
		lw		$t0, PX		#
		lw		$t1, PY		#

		# A counter for moving pieces
		addi	$t8, $zero, 1			# $t8 = $zero + 1

		# If Python sends us a 1 we want to shift our piece left
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq		$v0, $t3, shiftsl	# if $v0 == $t3 then shiftsl

		# If Python sends us a 2 we want to shift our piece right
		addi	$t3, $zero, 2			# $t3 = $zero + 2
		beq		$v0, $t3, shiftsr	# if $v0 == $t3 then shiftsr

		# Otherwise, we drop
		j		drops

	shiftsr:

        # If we're moving past the end of the board we don't want to move
        addi    $t7, $zero, 7       # $t7 = $zero + 8
        beq     $t0, $t7, drops    # if $t0 == $t7 then drops

		# We add one to our PX-value for testing purposes
		addi	$t0, $t0, 1			# $t0 = $t0 + 1

		# We need a counter initialized for looping purposes
		addi	$t8, $zero, 1			# $t8 = $zero + 1

		#need to do shift, goto shiftsrloop
		j		shiftsrloop

		shiftsrloop:

			# Get the value stored at PX,PY
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne		$v0, $zero, drops	# if $v0 != $zero then drops

			# Subtract 1 from y to move up
			addi	$t7, $zero, 1		# $t7 = $zero + 1
			sub		$t1, $t1, $t7		# $t1 = $t1 - $t7

			# If we've run this loop 2 times we've accounted for each square on the right
			addi	$t8, $t8, 1			# $8 = $t8 + 1
			addi	$t7, $zero, 3		# $t7 = $zero + 2
			beq		$t8, $t7, movesr	# if $t8 == $t1 then movesr

			# If we're at the top row and we are here then we are free to move
			beq		$t1, $zero, movesr	# if $t1 == $zero then movesr

			# Jump back to the top of our loop
			j		shiftsrloop			# jump to shiftsrloop

	shiftsl:
		#reload x and y
#		lw	$t0, PX
#		lw	$t1, PY

		#add -1 to x to check left side of square
		addi	$t0, $t0, -1

		# If we're in the first column we don't even want to bother shifting
		beq		$t0, $zero, drops	# if $t0 == $zero then dropsv

		# We subtract 1 from our PX value to test outer left of square
		addi	$t0, $t0, -1		# $t0 = $t0 - 1

		#now do the shift
		j		shiftslloop

		shiftslloop:

			# Get the value stored at X-2,Y
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# We want to get our X-2 and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne		$v0, $zero, drops	# if $v0 != $zero then drops

			# If PY is 0 then we are at the top so we can move
			beq		$t1, $zero, movesl	# if $t1 == $zero then movesl

			# Subtract 1 from y to move up
			addi	$t1, $t1, -1		# $t1 = $t1 - 1

			# If we've run this loop 2 times we've accounted for each block in the square
			addi	$t8, $t8, 1			# $8 = $t8 + 1
			addi	$t7, $zero, 3		# $t7 = $zero + 2
			beq		$t8, $t7, movesl		# if $t8 == $t7 then movesl

			# Jump back to the top of our loop
			j		shiftslloop			# jump to shiftsrloop

	drops:

		# Load our PX and PY value
		lw		$t0, PX		#
		lw		$t1, PY		#

		# We add 1 to Y to look at the square below ours
		addi	$t1, $t1, 1		# $t1 = $t1 + 1

        # Check to make sure we haven't gone to the end of the board
        addi    $t4, $zero, 16           # $t4 = $zero + 16
        beq     $t1, $t4, CHECKBOARD    # if $t1 == $t4 then UPDATEBOARD

		# Check what value is stored at this location
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		jal		GETARGXY			# jump to GETARGXY and save position to $ra

        # If the space isn't empty, we're done so check the board
        bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

        # Load our PX and PY value
        lw      $t0, PX     #
        lw      $t1, PY     #

		# Check left side, x-1,y+1
		addi	$t0, $t0, -1
		addi	$t1, $t1, 1

		# Check what value is stored at this location
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		jal		GETARGXY			# jump to GETARGXY and save position to $ra

        # If the space isn't empty, we're done so check the board
        bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

        # Load our PX and PY value
        lw      $t0, PX     #
        lw      $t1, PY     #

        # We add 1 to PY since we're dropsing some
        addi    $t1, $t1, 1            # $t1 = $t1 + 1

        # If we're not done, we store our new pointer
        sw      $t0, PX        #
        sw      $t1, PY        #

		# Set our new value to 2
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		addi	$a2, $zero, 2		# $a2 = $t2 + 2
		jal		SETXY			# jump to SETXY and save position to $ra

        # Load our PX and PY value
        lw      $t0, PX     #
        lw      $t1, PY     #

		#add -1 to PX so working on left side and store
		addi	$t0, $t0, -1

		# Set left new value to 2
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		addi	$a2, $zero, 2		# $a2 = $t2 + 2
		jal		SETXY			# jump to SETXY and save position to $ra

        # Load our PX and PY value
        lw      $t0, PX     #
        lw      $t1, PY     #

		# Keep subtracting one to move up the piece unless we hit the top of the board
		addi	$t2, $zero, 1			# $t2 = $zero + 1

		sub		$t4, $t1, $t2		# $t4 = $t1 - $t2
		beq		$t4, $zero, sloop	# if $t4 == $zero then sloop

		sub		$t4, $t4, $t2		# $t4 = $t4 - $t2

		# Set this value to 0 since we dropsed below it
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t4, $zero		# $a1 = $t4 + $zero
		add		$a2, $zero, $zero	# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

		# Also set value of left side to 0 b/c dropsed below
		lw		$t0, PX
		addi	$a0, $t0, -1
		add		$a1, $t4, $zero
		add		$a2, $zero, $zero
		jal		SETXY

        beq     $t4, $zero, sloop   # if $t4 == $zero then sloop

        # After we drop, we print
        jal     PRINTBOARD       # jump to PRINTBOARD and save position to $ra

		# If we make it this far then we are mid drop so we want more input
		j		sloop				# jump to sloop

	movesr:

		# Load the original PX and PY
		lw		$t0, PX		#
		lw		$t1, PY		#

		# Shift our x value to the right once
		addi	$t0, $t0, 1		# $t0 = $t0 + 1
		sw		$t0, PX

		# Load 2 into a register since that's what we use for this piece
		addi	$t2, $zero, 2			# $t3 = $zero + 2

		#set x+1,y to 2
		add		$a0, $zero, $t0		# $a0 = $zero + $t0
		add		$a1, $zero, $t1		# $a1 = $zero + $t1
		add		$a2, $zero, $t2		# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

		#move to x-2
		add		$t0, $a0, $zero
		add		$t1, $a1, $zero
		addi	$t0, $t0, -2		# $t0 = $t0 - 2

		#set x-2 to 0
		add		$a0, $zero, $t0		# $a0 = $zero + $t2
		add		$a1, $zero, $t1		# $a1 = $zero + $t1
		add		$a2, $zero, $zero	# $a2 = $zero + $t3
		jal		SETXY				# jump to SETXY

		#move up a row, y-1
		add		$t0, $a0, $zero
		add		$t1, $a1, $zero
		addi	$t1, $t1, -1		# $t0 = $t0 - 2

		#set to 0
		add		$a0, $zero, $t0		# $a0 = $zero + $t2
		add		$a1, $zero, $t1		# $a1 = $zero + $t1
		add		$a2, $zero, $zero	# $a2 = $zero + $t3
		jal		SETXY				# jump to SETXY

		#top right square, x+2
		add		$t0, $a0, $zero
		add		$t1, $a1, $zero
		addi	$t0, $t0, 2		# $t0 = $t0 - 2

		#set to 2
		add		$a0, $zero, $t0		# $a0 = $zero + $t2
		add		$a1, $zero, $t1		# $a1 = $zero + $t1
		add		$a2, $zero, $t2		# $a2 = $zero + $t3
		jal		SETXY				# jump to SETXY

		#branch
		j		drops

	movesl:

		# Load the original PX and PY
		lw		$t0, PX		#
		lw		$t1, PY		#

		# Load 2 into a register since that's what we use for this piece
		addi	$t2, $zero, 2			# $t3 = $zero + 2

		#set x,y to 0
		add		$a0, $zero, $t0		# $a0 = $zero + $t0
		add		$a1, $zero, $t1		# $a1 = $zero + $t1
		add		$a2, $zero, $zero	# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

		#move to x-1,y
		add		$t0, $a0, $zero
		add		$t1, $a1, $zero
		addi	$t0, $t0, -1		# $t0 = $t0 - 2
		sw		$t0, PX

		#move to x-2, y
		addi	$t0, $t0, -1

		#set x-2, y to 2
		add			$a0, $zero, $t0		# $a0 = $zero + $t2
		add		$a1, $zero, $t1		# $a1 = $zero + $t1
		add		$a2, $zero, $t2		# $a2 = $zero + $t3
		jal		SETXY

		#move up a row, x-2,y-1
		add		$t0, $a0, $zero
		add		$t1, $a1, $zero
		addi	$t1, $t1, -1		# $t0 = $t0 - 2

		#set to 2
		add		$a0, $zero, $t0		# $a0 = $zero + $t2
		add		$a1, $zero, $t1		# $a1 = $zero + $t1
		add		$a2, $zero, $t2		# $a2 = $zero + $t3
		jal		SETXY				# jump to SETXY

		#move to x, y-1
		add		$t0, $a0, $zero
		add		$t1, $a1, $zero
		addi	$t0, $t0, 2		# $t0 = $t0 - 2

		#set to 0
		add		$a0, $zero, $t0		# $a0 = $zero + $t2
		add		$a1, $zero, $t1		# $a1 = $zero + $t1
		add		$a2, $zero, $zero	# $a2 = $zero + $t3
		jal		SETXY				# jump to SETXY

		#branch
		j		drops



.globl CREATEZ
CREATEZ:

	# We're picking our middle position to be 3 so let's move X there
	# We also want to make sure we're starting at our top row as well
	addi	$t0, $zero, 3			# $t0 = X + 3
	addi	$t1, $zero, 0			# $t1 = $zero + 0

	# Store the value for safe keeping
	sw      $t0, PX        #
	sw      $t1, PY        #

	#store the first two blocks on the board
	addi	$t2, $zero, 3
	add	$a0, $zero, $t0
	add	$a1, $zero, $t1
	add	$a2, $zero, $t2
	jal	SETXY

	addi	$t0, $a0, -1
	add	$t1, $zero, $a1

	addi	$t2, $zero, 3
	add	$a0, $zero, $t0
	add	$a1, $zero, $t1
	add	$a2, $zero, $t2
	jal	SETXY

	# $t9 holds the rotation state. 1 for vertical, 2 for horizontal
	addi	$t9, $zero, 2			# $t7 = $zero + 2

	j	zloop

	zloop:
		# We want to print our board back to Python
		jal     PRINTBOARD           # jump to PRINTBOARD and save position to $ra

		# Prompt for user input from Python
		li        $a0, 1        # $a0 = 1
		li        $v0, 1        # $v0 = 1
		syscall

	# Print a new line
		li      $v0, 4      # system call #4 - print string
		la      $a0, newline    # $a0 = $zero + 15
		syscall             # execute

		# Make MIPS wait for integer input
		li	$v0, 5		# $v0 = 5
		syscall				# execute

		# Load PX and PY
		lw	$t0, PX		#
		lw	$t1, PY		#

		# A counter for moving pieces
		addi	$t8, $zero, 1			# $t8 = $zero + 1

		# If Python sends us a 2 we want to shift our piece left
		addi	$t3, $zero, 1			# $t3 = $zero + 2
		beq	$v0, $t3, shiftzl	# if $v0 == $t3 then shiftzl

		# If Python sends us a 1 we want to shift our piece right
		addi	$t3, $zero, 2			# $t3 = $zero + 1
		beq	$v0, $t3, shiftzr	# if $v0 == $t3 then shiftzr

		# If Python sends us a 3 then we want to rotate the piece
		addi	$t3, $zero, 3			# $t3 = $zero + 3
		beq	$v0, $t3, rotatez	# if $v0 == $t3 then rotatez

		# If our piece is in position 1 then drop vertical
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq	$t9, $t3, dropzv	# if $t9 == $t3 then dropzv

		# If our piece is in position 2 then drop horizontal
		addi	$t3, $zero, 2			# $t3 = $zero + 2
		beq	$t9, $t3, dropzh	# if $t9 == $t3 then dropzh

		# If we get here something is wrong so we wait for another input
		j	zloop				# jump to zloop

rotatez:
		addi	$t3, $zero, 1
		beq	$t3, $t9, rotatezvtoh
		j	rotatezhtov

		rotatezvtoh:
			#pivot, PX, is bottom most square
			#make sure we wont go off the edge
			addi	$t7, $zero, 1
			ble	$t0, $t7, dropzv

			#check if top left is clear
			addi	$t0, $t0, -1
			addi	$t1, $t1, -2

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropzv	# if $v0 != $zero then dropzv

			#check if middle left is clear
			addi	$t0, $t0, 1

			#check if its still on the board
			blt	$t1, $zero, dorotatezvtoh

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropzv	# if $v0 != $zero then dropzv

		dorotatezvtoh:
			addi	$t3, $zero, 3

			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			addi	$t0, $t0, -1
			addi	$t1, $t1, -2

			#create new square top left
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#add middle row squares
			addi	$t0, $t0, 1

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#remove top right square
			addi	$t0, $t0, 1

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old bottom most square
			addi	$t0, $t0, -1
			addi	$t1, $t1, 2

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#set PX
			addi	$t0, $t0, 1
			addi	$t1, $t1, -1
			sw	$t0, PX
			sw	$t1, PY

		endrotatezvtoh:
			addi	$t9, $zero, 2
			j	dropzh

		rotatezhtov:
			#make sure we wont go off the edge
			addi $t7, $zero, 7
			beq	$t0, $t7, dropzh

			#check to see if top right is open
			addi	$t1, $t1, -2

			#check if its still on the board
			blt	$t1, $zero, dorotatezhtov

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropzh	# if $v0 != $zero then dropzh

			#check to see if middle right is open
			addi	$t1, $t1, 1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropzh	# if $v0 != $zero then dropzh

		dorotatezhtov:
			addi	$t3, $zero, 3

			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#erase bottom row
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase top left
			addi	$t0, $t0, -2
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, endrotatezhtov

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#add middle right
			addi	$t0, $t0, 2

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#add new top right
			addi	$t1, $t1, -1

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#set pivot
			addi	$t0, $t0, -1
			addi	$t1, $t1, 2
			sw	$t0, PX
			sw	$t1, PY

		endrotatezhtov:
			addi	$t9, $zero, 1
			j	dropzv

	shiftzl:
		addi	$t3, $zero, 1
		beq	$t3, $t9, shiftzvl
		j	shiftzhl

		shiftzvl:
			beq	$t0, $zero, dropzv

			#move one to the right to check for space to move
			addi	$t0, $t0, -1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropzv	# if $v0 != $zero then dropzv

			#move one up to check for space to move
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftzvl

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropzv	# if $v0 != $zero then droppv

			#move up one and left one for space to move
			addi	$t0, $t0, -1
			addi	$t1, $t1, 1

			#check if its still on the board
			blt	$t1, $zero, doshiftzvl

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropzv	# if $v0 != $zero then droppv

		doshiftzvl:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the right
			addi	$t0, $t0, -1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 3

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in middle line
			addi	$t0, $t0, -1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropzv

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in top line
			addi	$t0, $t0, -1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropzv

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropzv

		shiftzhl:

			addi	$t7, $t0, -2
			beq	$t7, $zero, dropzh

			#check for space to shift in the bottom line
			addi	$t0, $t0, -2

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropzh	# if $v0 != $zero then dropzh

			#check for space to shift in the top line
			addi	$t0, $t0, -1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftzhl

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropzv	# if $v0 != $zero then droppv
		doshiftzhl:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the right
			addi	$t0, $t0, -1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 3

			# writing the values in the new spots
			addi	$t0, $t0, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move blocks in top line
			addi	$t0, $t0, -3
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropzh

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropzh

	shiftzr:
		addi	$t3, $zero, 1
		beq	$t3, $t9, shiftzvr
		j	shiftzhr

		shiftzvr:
			addi	$t7, $zero, 7
			addi	$t6, $t0, 1
			beq	$t6, $t7, dropzv

			#move one to the left to check for space to move
			addi	$t0, $t0, 1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropzv	# if $v0 != $zero then dropzv

			#move to check to the left of the middle row
			addi	$t0, $t0, 1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftzvr

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropzv	# if $v0 != $zero then droppv

			#move to check to the left of the top row
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftzvr

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropzv	# if $v0 != $zero then droppv

		doshiftzvr:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the left
			addi	$t0, $t0, 1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 3

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in middle line
			addi	$t0, $t0, 2
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropzv

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in top line
			addi	$t0, $t0, 2
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropzv

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropzv

		shiftzhr:
			addi $t7, $zero, 7
			beq	$t0, $t7, dropzh

			#move one to the right to check for space to move
			addi	$t0, $t0, 1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropzh	# if $v0 != $zero then dropzh

			#check to the left of the top row
			addi	$t0, $t0, -1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftzhr

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropzh	# if $v0 != $zero then dropzh

		doshiftzhr:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the right
			addi	$t0, $t0, 1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 3

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in top line
			addi	$t0, $t0, 1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropzh

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropzh

	dropzv:
		#load our PX and PY values
		lw	$t0, PX
		lw	$t1, PY

		#add one to look at the sqare below ours
		addi	$t1, $t1, 1

		#check to make sure we don't go past the bottom of the board
		addi	$t4, $zero, 16
		beq 	$t1, $t4, CHECKBOARD

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board
        	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		#check other hazard spot
		addi	$t0, $t0, 1
		addi	$t1, $t1, -1

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board
        	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		# Load our PX and PY value
        	lw      $t0, PX     #
        	lw      $t1, PY     #

        	# We add 1 to PY since we're dropping some
        	addi    $t1, $t1, 1            # $t1 = $t1 + 1

        	# If we're not done, we store our new pointer
        	sw      $t0, PX        #
        	sw      $t1, PY        #

		#valueto be stored for the piece
		addi	$t3, $zero, 3

		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot
		addi	$t1, $t1, -2
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#drop left column
		addi	$t0, $t0, 1
		addi	$t1, $t1, 1

		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot of pivot
		addi	$t1, $t1, -2
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		j	zloop

	dropzh:
		#load our PX and PY values
		lw	$t0, PX
		lw	$t1, PY

		#add one to look at the sqare below ours
		addi	$t1, $t1, 1

		#check to make sure we don't go past the bottom of the board
		addi	$t4, $zero, 16
		beq 	$t1, $t4, CHECKBOARD

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board
        	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		#check other hazard spot
		addi	$t0, $t0, -1

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board
        	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		#check other hazard spot
		addi	$t0, $t0, -1
		addi	$t1, $t1, -1

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board
        	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		# Load our PX and PY value
        	lw      $t0, PX     #
        	lw      $t1, PY     #

        	# We add 1 to PY since we're dropping some
        	addi    $t1, $t1, 1            # $t1 = $t1 + 1

        	# If we're not done, we store our new pointer
        	sw      $t0, PX        #
        	sw      $t1, PY        #

		#valueto be stored for the piece
		addi	$t3, $zero, 3

		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot
		addi	$t1, $t1, -1
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#drop middle column
		addi	$t0, $t0, -1
		addi	$t1, $t1, 1

		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot of pivot
		addi	$t1, $t1, -2
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#drop right column
		addi	$t0, $t0, -1
		addi	$t1, $t1, 1

		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot of pivot
		addi	$t1, $t1, -1
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		j	zloop


.globl CREATEBZ
CREATEBZ:

	# Store our return address on the stack
	#sw		$ra, 0($sp)		#

	# We're picking our middle position to be 3 so let's move X there
	# We also want to make sure we're starting at our top row as well
	addi	$t0, $zero, 3			# $t0 = X + 3
	addi	$t1, $zero, 0			# $t1 = $zero + 0

	# Store the value for safe keeping
	sw      $t0, PX        #
	sw      $t1, PY        #

	#store the first two blocks on the board
	addi	$t2, $zero, 4
	add	$a0, $zero, $t0
	add	$a1, $zero, $t1
	add	$a2, $zero, $t2
	jal	SETXY

	addi	$t0, $a0, 1
	add	$t1, $zero, $a1

	addi	$t2, $zero, 4
	add	$a0, $zero, $t0
	add	$a1, $zero, $t1
	add	$a2, $zero, $t2
	jal	SETXY

	# $t9 holds the rotation state. 1 for vertical, 2 for horizontal
	addi	$t9, $zero, 2			# $t7 = $zero + 2

	j	bzloop

	bzloop:
		# We want to print our board back to Python
		jal     PRINTBOARD           # jump to PRINTBOARD and save position to $ra

		# Prompt for user input from Python
		li        $a0, 1        # $a0 = 1
		li        $v0, 1        # $v0 = 1
		syscall

	# Print a new line
		li      $v0, 4      # system call #4 - print string
		la      $a0, newline    # $a0 = $zero + 15
		syscall             # execute

		# Make MIPS wait for integer input
		li	$v0, 5		# $v0 = 5
		syscall				# execute

		# Load PX and PY
		lw	$t0, PX		#
		lw	$t1, PY		#

		# A counter for moving pieces
		addi	$t8, $zero, 1			# $t8 = $zero + 1

		# If Python sends us a 2 we want to shift our piece left
		addi	$t3, $zero, 1			# $t3 = $zero + 2
		beq	$v0, $t3, shiftbzl	# if $v0 == $t3 then shiftbzl

		# If Python sends us a 1 we want to shift our piece right
		addi	$t3, $zero, 2			# $t3 = $zero + 1
		beq	$v0, $t3, shiftbzr	# if $v0 == $t3 then shiftbzr

		# If Python sends us a 3 then we want to rotate the piece
		addi	$t3, $zero, 3			# $t3 = $zero + 3
		beq	$v0, $t3, rotatebz	# if $v0 == $t3 then rotatebz

		# If our piece is in position 1 then drop vertical
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq	$t9, $t3, dropbzv	# if $t9 == $t3 then dropbzv

		# If our piece is in position 2 then drop horizontal
		addi	$t3, $zero, 2			# $t3 = $zero + 2
		beq	$t9, $t3, dropbzh	# if $t9 == $t3 then dropbzh

		# If we get here something is wrong so we wait for another input
		j	bzloop				# jump to bzloop

rotatebz:
		addi	$t3, $zero, 1
		beq	$t3, $t9, rotatebzvtoh
		j	rotatebzhtov

		rotatebzvtoh:
			#make sure we wont go off the edge
			addi	$t7, $zero, 6
			bge	$t0, $t7, dropbzv

			#check if top middle is clear
			addi	$t1, $t1, -2

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropbzv	# if $v0 != $zero then dropbzv

			#check if top right is clear
			addi	$t0, $t0, 1

			#check if its still on the board
			blt	$t1, $zero, dorotatebzvtoh

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropbzv	# if $v0 != $zero then dropbzv


		dorotatebzvtoh:
			addi	$t3, $zero, 4

			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#eraseold start position
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#save new pivot
			addi	$t0, $t0, -1
			addi	$t1, $t1, -1
			sw	$t0, PX
			sw	$t1, PY

			#add top right
			addi	$t0, $t0, 2
			addi	$t1, $t1, -1

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#add middle row squares
			addi	$t0, $t0, -1

			#check if its still on the board
			blt	$t1, $zero, endrotatebzvtoh

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old squares in middle row
			addi	$t0, $t0, -1

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#check if its still on the board
			blt	$t1, $zero, endrotatebzvtoh

		endrotatebzvtoh:
			addi	$t9, $zero, 2
			j	dropbzh

		rotatebzhtov:
			#make sure we wont go off the edge
			beq	$t0, $zero, dropbzh

			#check to see if top left is empty
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dorotatebzhtov

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropbzh	# if $v0 != $zero then dropbzh

			#check to see if middle bottom is empty
			addi	$t0, $t0, 1
			addi	$t1, $t1, 2

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to rotate
			bne	$v0, $zero, dropbzh	# if $v0 != $zero then dropbzh

		dorotatebzhtov:
			addi	$t3, $zero, 4

			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#erase top right
			addi	$t0, $t0, 2
			addi	$t1, $t1, -1

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase middle top
			addi	$t0, $t0, -1

			#check if its still on the board
			blt	$t1, $zero, endrotatebzhtov

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#draw top left
			addi	$t0, $t0, -1

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#add new middle row squares
			addi	$t0, $t0, 1
			addi	$t1, $t1, 2

			sw	$t0, PX
			sw	$t1, PY

			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

		endrotatebzhtov:
			addi	$t9, $zero, 1
			j	dropbzv

	shiftbzl:
		addi	$t3, $zero, 1
		beq	$t3, $t9, shiftbzvl
		j	shiftbzhl

		shiftbzvl:
			addi	$t7, $zero, 1
			beq	$t0, $t7, dropbzv

			#move one to the left to check for space to move
			addi	$t0, $t0, -1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbzv	# if $v0 != $zero then dropbzv

			#move to check to the left of the middle row
			addi	$t0, $t0, -1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftbzvl

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbzv	# if $v0 != $zero then droppv

			#move to check to the left of the top row
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftbzvl

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbzv	# if $v0 != $zero then droppv

		doshiftbzvl:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the left
			addi	$t0, $t0, -1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 4

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in middle line
			addi	$t0, $t0, -2
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropbzv

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in top line
			addi	$t0, $t0, -2
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropbzv

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropbzv

		shiftbzhl:
			beq	$t0, $zero, dropbzh

			#move one to the left to check for space to move
			addi	$t0, $t0, -1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbzh	# if $v0 != $zero then dropbzh

			#check to the left of the top row
			addi	$t0, $t0, 1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftbzhl

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbzh	# if $v0 != $zero then dropbzh

		doshiftbzhl:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the left
			addi	$t0, $t0, -1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 4

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in top line
			addi	$t0, $t0, -1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropbzh

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, 2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropbzh

	shiftbzr:
		addi	$t3, $zero, 1
		beq	$t3, $t9, shiftbzvr
		j	shiftbzhr

		shiftbzvr:
			addi	$t7, $zero, 7
			beq	$t0, $t7, dropbzv

			#move one to the right to check for space to move
			addi	$t0, $t0, 1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbzv	# if $v0 != $zero then dropbzv

			#move one up to check for space to move
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftbzvr

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbzv	# if $v0 != $zero then droppv

			#move up one and left one for space to move
			addi	$t0, $t0, -1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftbzvr

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbzv	# if $v0 != $zero then droppv

		doshiftbzvr:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the right
			addi	$t0, $t0, 1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 4

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in middle line
			addi	$t0, $t0, 1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropbzv

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in top line
			addi	$t0, $t0, 1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropbzv

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropbzv

		shiftbzhr:

			addi	$t7, $zero, 5
			bge	$t0, $t7, dropbzh

			#check for space to shift in the bottom line
			addi	$t0, $t0, 2

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbzh	# if $v0 != $zero then dropbzh

			#check for space to shift in the top line
			addi	$t0, $t0, 1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftbzhr

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne	$v0, $zero, dropbzv	# if $v0 != $zero then droppv
		doshiftbzhr:
			# Load PX and PY
			lw	$t0, PX		#
			lw	$t1, PY		#

			#shift the pivot one to the right
			addi	$t0, $t0, 1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		#

			#valueto be stored for the piece
			addi	$t3, $zero, 4

			# writing the values in the new spots
			addi	$t0, $t0, 1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move blocks in top line
			addi	$t0, $t0, 3
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, dropbzh

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropbzh

	dropbzv:
		#load our PX and PY values
		lw	$t0, PX
		lw	$t1, PY

		#add one to look at the sqare below ours
		addi	$t1, $t1, 1

		#check to make sure we don't go past the bottom of the board
		addi	$t4, $zero, 16
		beq 	$t1, $t4, CHECKBOARD

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board
    	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		#check other hazard spot
		addi	$t0, $t0, -1
		addi	$t1, $t1, -1

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board
    	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		# Load our PX and PY value
    	lw      $t0, PX     #
    	lw      $t1, PY     #

    	# We add 1 to PY since we're dropping some
    	addi    $t1, $t1, 1            # $t1 = $t1 + 1

    	# If we're not done, we store our new pointer
    	sw      $t0, PX        #
    	sw      $t1, PY        #

		#valueto be stored for the piece
		addi	$t3, $zero, 4

		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot
		addi	$t1, $t1, -2
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#drop left column
		addi	$t0, $t0, -1
		addi	$t1, $t1, 1

		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot of pivot
		addi	$t1, $t1, -2
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		j	bzloop

	dropbzh:
		#load our PX and PY values
		lw	$t0, PX
		lw	$t1, PY

		#add one to look at the sqare below ours
		addi	$t1, $t1, 1

		#check to make sure we don't go past the bottom of the board
		addi	$t4, $zero, 16
		beq 	$t1, $t4, CHECKBOARD

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board
    	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		#check other hazard spot
		addi	$t0, $t0, 1

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board
    	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		#check other hazard spot
		addi	$t0, $t0, 1
		addi	$t1, $t1, -1

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board
    	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		# Load our PX and PY value
    	lw      $t0, PX     #
    	lw      $t1, PY     #

    	# We add 1 to PY since we're dropping some
    	addi    $t1, $t1, 1            # $t1 = $t1 + 1

    	# If we're not done, we store our new pointer
    	sw      $t0, PX        #
    	sw      $t1, PY        #

		#valueto be stored for the piece
		addi	$t3, $zero, 4

		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot
		addi	$t1, $t1, -1
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#drop middle column
		addi	$t0, $t0, 1
		addi	$t1, $t1, 1

		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot of pivot
		addi	$t1, $t1, -2
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#drop right column
		addi	$t0, $t0, 1
		addi	$t1, $t1, 1

		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot of pivot
		addi	$t1, $t1, -1
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		j	bzloop

# This is the procedure that is going to handle a lot of our game logic
.globl CHECKBOARD
CHECKBOARD:

	jal		RESET				# jump to RESET and save position to $ra

	# We want to check the top row of our board
	addi	$t7, $zero, 0			# $t1 = $zero + 0
	addi	$t4, $zero, 0			# $t4 = $zero + 0

	j		toprow				# jump to toprow

	toprow:

		jal		GETINCREMENT		# jump to GETINCREMENT and save position to $ra

		# If any space in the top board is not zero then the game is over
		bne		$v0, $zero, GAMEOVER	# vf $t0 != $zero then GAMEOVER

		# If we hit space 8 on our board then we are on the second row
		addi	$t0, $zero, 8		# $t0 = $zero + 8
		addi	$t7, $t7, 1			# $t1 = $zero + 1
		beq		$t7, $t0, aftertop	# if $t1 == $t0 then aftertop

		j		toprow				# jump to toprow

	aftertop:
		# Grab a value from the board
		jal		GETINCREMENT				# jump to GETINCREMENT and save position to $ra

		# Move the result of GETINCREMENT into a temp register
		add		$t2, $zero, $v0		# $t2 = $zero + $v0

		# If we read the end of the board, then we know we are finsihed checking
		addi	$t1, $zero, 1			# $t1 = $zero + 1
		beq		$v1, $t1, finishcheck	# if $v0 == $t1 then target

		# If the space we're looking at is 0 then we know we can't clear the row so we move on
		bne		$t2, $zero, controw	# if $v0 == $t1 then target
		add		$t4, $zero, $zero
		jal		NEXTROW

		# If our NEXTROW returns 1 then we have also finsihed checking
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq		$v0, $t3, finishcheck	# if $v1 == $t3 then finishcheck
	controw:
		# If our counter makes it to 8, then we know the first 7 spaces are filled
		addi	$t4, $t4, 1			# $t4 = $t4 + 1
		addi	$t0, $zero, 8			# $t0 = $zero + 8
		bne		$t4, $t0, aftertop

		#check the 8th space in the row, need to do this to make sure we ar eon the correct row when we move to clearrow
		jal		GETXY
		beq		$v0, $zero, aftertop

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
		addi	$t3, $zero, 1		# $t3 = $zero + 1
		sub		$t2, $t1, $t3		# $t2 = $t1 - $t2

		clearloop:
			add		$t7, $zero, $t1
			# Call GETARGXY to get the value stored at our position
			add		$a0, $zero, $t0		# $a0 = $zero + $t0
			add		$a1, $zero, $t2		# $a1 = $zero + $t2
			jal		GETARGXY				# jump to GETARGXY and save position to $ra

			add		$t0, $zero, $a0
			add		$t2, $zero, $a1
			add		$t1, $zero, $t7
			add		$t6, $zero, $v0

			# Call SETXY to set our new value
			add		$a0, $zero, $t0
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $t6		# $a2 = $zero + $v0
			jal		SETXY				# jump to SETXY and save position to $ra

			add		$t0, $zero, $a0
			add		$t1, $zero, $a1

			# Move to the next column
			addi	$t0, $t0, 1			# $t0 = $t0 + 1
			beq		$t0, $t4, finclearloop	# if $t0 == $t4 then finclearloop

			j		clearloop				# jump to clearloop

		finclearloop:
			sw		$t2, Y		#
			j		clearrow				# jump to clearrow

	finishcheck:
		j		UPDATEBOARD				# jump to UPDATEBOARD


.globl GAMEOVER
GAMEOVER:

	# Establish a counter for our row, starting from the bottom
	addi	$t9, $zero, 16		# $t3 = $zero + 1

	# Start the game ending loop
	j		gameoverloop		# jump to gameoverloop

	gameoverloop:

 		# Print out our board state. This will be printed at the completetion of each run
		jal		PRINTBOARD			# jump to PRINTBOARD and save position to $ra

		# Decrement our row by 1 to look at the next row up
		addi	$t0, $zero, 1		# $t0 = $zero + 1
		sub		$t9, $t9, $t0		# $t9 = $t9 - $t0

		# If we get to row -1 then we are outside the board so we stop
		addi	$t0, $zero, -1		# $t0 = $zero + -1
		beq		$t9, $t0, endgame	# if $t8 == $t0 then endgame

		# This will be a X counter starting from the end
		addi	$t8, $zero, 7		# $t1 = $zero + 0

		# Jump to the loop that controls each row
		j		printgameover		# jump to printgameover

		printgameover:

			# Set the value at X,Y to the color for that columns number
			add		$a0, $t8, $zero		# $a0 = $t8 + $zero
			add		$a1, $t9, $zero		# $a1 = $t9 + $zero
			add		$a2, $t8, $zero		# $a2 = $t8 + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Prompt for user input from Python
      		li        $a0, 1        # $a0 = 1
      		li        $v0, 1        # $v0 = 1
      		syscall

	        # Print a new line
	        li      $v0, 4      # system call #4 - print string
	        la      $a0, newline    # $a0 = $zero +
	        syscall             # execute

			# Make MIPS wait for integer input
			li		$v0, 5		# $v0 = 5
			syscall				# execute

			# If our X counter is 0 then we jump up to print the board and decrement rows
			beq		$t8, $zero, gameoverloop	# if $t8 == $zero then gameoverloop

			# Decrement our X counter
			addi	$t0, $zero, 1		# $t0 = $zero + 1
			sub		$t8, $t8, $t0		# $t8 = $t8 - $t0

			# Loop back to the top
			j		printgameover				# jump to printgameover

	endgame:

		# When the game ends, we write a 9 to STDOUT to tell Python we're done as well
		li		$v0, 1		# system call #4 - print string
		addi	$a0, $zero, 9			# $a0 = $zero + 9
		syscall				# execute

		# Print a new line
	    li      $v0, 4      # system call #4 - print string
	    la      $a0, newline    # $a0 = $zero + 15
	    syscall             # execute

	    # End the spim program
		li		$v0, 10			# Syscall to end program
		syscall
