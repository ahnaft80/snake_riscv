#
# CMPUT 229 Public Materials License
# Version 1.0
#
# Copyright 2020 University of Alberta
# Copyright 2022 Yufei Chen
# TODO: claim your copyright
# This software is distributed to students in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the disclaimer below in the documentation
#    and/or other materials provided with the distribution.
#
# 2. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
#-------------------------------
# Lab_Snake_Game Lab
#
# Author: Ahnaf Tajwar Rafid
#
#-------------------------------

.include "common.s"

.data
snakeX:		.word 12, 11, 10, 9
snakeY:		.word 5, 5, 5, 5

.align 2

DISPLAY_CONTROL:    .word 0xFFFF0008
DISPLAY_DATA:       .word 0xFFFF000C
direction:	    .word 100    
INTERRUPT_ERROR:	.asciz "Error: Unhandled interrupt with exception code: "
INSTRUCTION_ERROR:	.asciz "\n   Originating from the instruction at address: "
INPUT_PROMPT:		.asciz "Please enter 1,2 or 3 to choose the and the start the game"
EMPTY_STRING:		.asciz "                                                          "
BLANK:			.asciz " "


Brick:      .asciz "#"


.text

handler:
	csrrw	a0, 0x040, a0			#a0 <- usctratch and uscratch <- a0
   	sw 	t0, 0(a0)			#store the registers to be used
   	sw	t1, 4(a0)
   	sw	a1, 8(a0)
   	sw	t2, 12(a0)
   	sw	t3, 16(a0)
   	sw	t4, 20(a0)
   	sw	a2, 24(a0)
   	csrr	t0, 0x040			#store and save user a0
   	sw	t0, 28(a0)
   	
   	#if the error code is 4, this function executes update clock function, otherwise goes to handlerTerminate
   	li	t1, 0	
   	csrrw	t0, 0x42, t1			#t0 <- ucause and ucause <- 0
   	li	t1, 0x7fffffff
   	and	t1, t0, t1			#in t1, extract exception code field
   	beqz	t1, done
   	li	t1, 0x80000004
   	beq	t1, t0, update_clock
   	li 	t1, 0x80000008			# User External (Keyboard) interupt
	beq 	t1, t0, keyboard_handler
   	j	handlerTerminate
   	
   	keyboard_handler:
   	li	t4, 0				#this is the input by the keyboard
   	li	t1, 0xFFFF0004
	lw	t1, 0(t1)
	li	t2, 119 #w	
	beq	t1, t2, update_register
	li	t2, 91	#a
	beq	t1, t2, update_register
	li	t2, 115	#s
	beq	t1, t2, update_register
	li	t2, 100	#d
	beq	t1, t2, update_register
	
	update_register:
	#this registers the input by the keyboard
	#w,a,s,d are stored by ASCII code, if t4 is 0, no value was input
	#i.e the snake will continue the direction
	mv	t4, t2
   	
   	update_clock:
   	#increase the timecmp
   	lw	t1, 4(a0)
   	li	t0, 1000
   	add	t1, t0, t1			#add the timecmp by 1 second when the interruption occurs
   	sw	t1, 4(a0)
   	li	t0, 0xFFFF0020			#timecmp
   	sw	t1, 0(t0) 			#load second and increment by 1
   	#decrease the timer
   	lw 	t2, 12(a0)			# t2 is the time limit set by the player through levels
   	addi 	t2, t2, -1
   	sw 	t2, 12(a0)
   	j	update_screen
	
	update_screen:
   	# clear the old snake
   	li a0, 32 # head
	la a1, snakeY
	lw a1, 0(a1)
	la a2, snakeX
	lw a2, 0(a2)
	jal printChar
	
	li a0, 32 #body
	la a1, snakeY
	lw a1, 4(a1)
	la a2, snakeX
	lw a2, 4(a2)
	jal printChar
	
	li a0, 32 #body
	la a1, snakeY
	lw a1, 8(a1)
	la a2, snakeX
	lw a2, 8(a2)
	jal printChar
	
	li a0, 32 #body
	la a1, snakeY
	lw a1, 12(a1)
	la a2, snakeX
	lw a2, 12(a2)
	jal printChar
   	
   	# move the snake
   	la a1, snakeY
	la a2, snakeX
	lw t0, 8(a1)
	sw t0, 12(a1)
	lw t0, 4(a1)
	sw t0, 8(a1)
	lw t0, 0(a1)
	sw t0, 4(a1)
	lw t0, 8(a2)
	sw t0, 12(a2)
	lw t0, 4(a2)
	sw t0, 8(a2)
	lw t0, 0(a2)
	sw t0, 4(a2)
	
	la t1, direction 
	lw t1, 0(t1)
	li t2, 100
	beq t1, t2, right
	li t2, 119
	beq t1, t2, up
	li t2, 97
	beq t1, t2, left
	li t2, 115
	beq t1, t2, down	

right:
	lw t0, 0(a2) # X: column
	addi t0, t0, 1
	sw t0, 0(a2)
	beq t0, t0, update
up:
	lw t0, 0(a1)
	addi t0, t0, -1
	sw t0, 0(a1)
	beq t0, t0, update
left:
	lw t0, 0(a2)
	addi t0, t0, -1
	sw t0, 0(a2)
	beq t0, t0, update
down:
	lw t0, 0(a1)
	addi t0, t0, 1
	sw t0, 0(a1)
	beq t0, t0, update

update:
	# print snake
	li a0, 64 # head
	la a1, snakeY
	lw a1, 0(a1)
	la a2, snakeX
	lw a2, 0(a2)
	jal printChar
	
	li a0, 42 #body
	la a1, snakeY
	lw a1, 4(a1)
	la a2, snakeX
	lw a2, 4(a2)
	jal printChar
	
	li a0, 42 #body
	la a1, snakeY
	lw a1, 8(a1)
	la a2, snakeX
	lw a2, 8(a2)
	jal printChar
	
	li a0, 42 #body
	la a1, snakeY
	lw a1, 12(a1)
	la a2, snakeX
	lw a2, 12(a2)
	jal printChar


   	
   	#restores the registers and returns
   	done:
   	csrrsi	t0, 0x41, 0			#t0 <- EPC
   	addi	t0, t0, 4			#increment EPC so it starts executing from the next line
   	csrrw	t1, 0x41, t0			#restore updated EPC
   	lw	t0, 28(a0)			#t0 <- USERa0
   	csrw	t0, 0x40			#uscratch <- usera0
   	lw 	t0, 0(a0) 
   	lw 	t1, 4(a0) 
   	lw 	a1, 8(a0)
   	lw	t2, 12(a0)
   	lw	t3, 16(a0)
   	lw	t4, 20(a0)
   	lw	a2, 24(a0)			#restore the rest of the registers
   	csrrw 	a0, 0x040, a0			#a0 -> usctratch and uscratch -> a0
   	uret
   	
handlerTerminate:
	# Print error msg before terminating
	li     a7, 4
	la     a0, INTERRUPT_ERROR
	ecall
	li     a7, 34
	csrrci a0, 66, 0
	ecall
	li     a7, 4
	la     a0, INSTRUCTION_ERROR
	ecall
	li     a7, 34
	csrrci a0, 65, 0
	ecall
handlerQuit:
	li     a7, 10
	ecall	# End of program


snakeGame:	
	#input screen
	input_screen:	
	la	a0, INPUT_PROMPT
	li	a1, 0
	li	a2, 0
	jal	printStr
		
	check_input_level:
	li	t0, 0xFFFF0004	#load ASCII of the last value pressed
	lw	t0, 0(t0)
	li	t1, 49
	beq	t0, t1, setup_l1#load for each levels if input matches
	li	t1, 50
	beq	t0, t1, setup_l2
	li	t1, 51
	beq	t0, t1, setup_l3
	j	check_input_level

	#match with the stats
	setup_l1:
	li	t2, 120		#total time
	li	t3, 8		#allowed increment
	j	environment_setup
		
	setup_l2:
	li	t2, 30
	li	t3, 5
	j	environment_setup
	
	setup_l3:
	li	t2, 15
	li	t3, 3
	j	environment_setup
	
	
	#-----------------------------------------------------------------------------------------#
	#actual game
	environment_setup:
	#stack
	addi	sp, sp, -12
	sw	ra, 0(sp)
	sw	t1, 4(sp)
	sw	t2, 8(sp)
	
	#print the game stage
	la	a0, EMPTY_STRING #clear the input 
	li	a1, 0
	li	a2, 0
	jal	printStr
	jal 	printAllWalls	 #print walls
	#print the 000
	li	a0, 3
	li	a1, 0
	li	a2, 24
	li	a3, 48
	jal	printMultipleSameChars
	
	#mod ustatus bit
	li	t0, 0
	csrrw	t1, 0, t0	#ustatus 0 bit -> 1
	addi	t1, t1, 1
	csrrw	t0, 0, t1
	
	#activate keyboard control handler bit
	li	t0, 0xFFFF0000	
	lw	t1, 0(t0)
	addi	t1, t1, 2
	sw	t1, 0(t0)
	
	#update the utvec register
	li	t0, 0x0040001c
	csrrw	t1, 5, t0
	
	#handle uie register
	li	t0, 0x00000110	#uie 4 and 8 bit -> 1
	li	t2, 0
	csrrw	t1, 4, t2
	add	t1, t1, t0
	csrw	t1, 4
	
	#update the timecmp register (value -> 1 second)
	li 	t0, 0xFFFF0020
	li 	t2, 0xFFFF0018
	lw	t2, 0(t2)
	li 	t1, 1000
	add	t1, t1, t2
	sw 	t1, 0(t0)		#t1 is the timecmp which needs to be added every interruption 
		
	#apple generation
	jal	random
	mv	t5, a0
	addi	t5, t5, 1
	jal	random
	mv	t6, a0
	addi	t6, t6, 1
	li	a0, 97
	mv	a1, t5
	mv	a2, t6
	jal	printChar
	
	#draw snake
	jal	draw_snake
	
	play_loop:
	#if (row <= 0 || row >= 10 || col <= 0 || col >= 20), go to input screen
	#la	t0, snakeX	
	#lw	t0, 0(t0)	#column
	#la	t1, snakeY	
	#lw	t1, 0(t1)	#row
	#li	t2, 0
	#ble	t1, t2, game_over
	#li	t2, 10
	#bge	t1, t2, game_over
	#li	t2, 0
	#ble	t0, t2, game_over
	#li	t2, 20
	#bge	t1, t2, game_over
	
	##2
	#j	continue_game	
	#game_over:
	#j	input_screen
	#continue_game:
	#j	play_loop
	li a1, 0xFFFF0000	# Keyboard control
	li t0, 0x002
	sw t0, 0(a1)	
	
random:
	
	#generation of the random number
	la	t0, XiVar
	lw	t0, 0(t0)
	la	t1, aVar
	lw	t1, 0(t1)
	la	t2, cVar
	lw	t2, 0(t2)
	la	t3, mVar
	lw	t3, 0(t3)
	mul	a0, t1, t0
	add	a0, a0, t2
	rem	a0, a0, t3
	la	t0, XiVar
	sw	a0, 0(t0)
	
	ret		





#---------------------------------------------------------------------------------------------
# printAllWalls
#
# Subroutine description: This subroutine prints all the walls within which the snake moves
# 
#   Args:
#  		None
#
# Register Usage
#      s0: the current row
#      s1: the end row
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
printAllWalls:
	# Stack
	addi   sp, sp, -12
	sw     ra, 0(sp)
	sw     s0, 4(sp)
	sw     s1, 8(sp)
	# print the top wall
	li     a0, 21
	li     a1, 0
	li     a2, 0
	la     a3, Brick
	lbu    a3, 0(a3)
	jal    ra, printMultipleSameChars

	li     s0, 1	# s0 <- startRow
	li     s1, 10	# s1 <- endRow
printAllWallsLoop:
	bge    s0, s1, printAllWallsLoopEnd
	# print the first brick
	la     a0, Brick	# a0 <- address(Brick)
	lbu    a0, 0(a0)	# a0 <- '#'
	mv     a1, s0		# a1 <- row
	li     a2, 0		# a2 <- col
	jal    ra, printChar
	# print the second brick
	la     a0, Brick
	lbu    a0, 0(a0)
	mv     a1, s0
	li     a2, 20
	jal    ra, printChar
	
	addi   s0, s0, 1
	jal    zero, printAllWallsLoop

printAllWallsLoopEnd:
	# print the bottom wall
	li     a0, 21
	li     a1, 10
	li     a2, 0
	la     a3, Brick
	lbu    a3, 0(a3)
	jal    ra, printMultipleSameChars

	# Unstack
	lw     ra, 0(sp)
	lw     s0, 4(sp)
	lw     s1, 8(sp)
	addi   sp, sp, 12
	jalr   zero, ra, 0


#---------------------------------------------------------------------------------------------
# printMultipleSameChars
# 
# Subroutine description: This subroutine prints white spaces in the Keyboard and Display MMIO Simulator terminal at the
# given row and column.
# 
#   Args:
#   a0: length of the chars
# 	a1: row - The row to print on.
# 	a2: col - The column to start printing on.
#   a3: char to print
#
# Register Usage
#      s0: the remaining number of cahrs
#      s1: the current row
#      s2: the current column
#      s3: the char to be printed
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
printMultipleSameChars:
	# Stack
	addi   sp, sp, -20
	sw     ra, 0(sp)
	sw     s0, 4(sp)
	sw     s1, 8(sp)
	sw     s2, 12(sp)
	sw     s3, 16(sp)

	mv     s0, a0
	mv     s1, a1
	mv     s2, a2
	mv     s3, a3

# the loop for printing the chars
printMultipleSameCharsLoop:
	beq    s0, zero, printMultipleSameCharsLoopEnd   # branch if there's no remaining white space to print
	# Print character
	mv     a0, s3	# a0 <- char
	mv     a1, s1	# a1 <- row
	mv     a2, s2	# a2 <- col
	jal    ra, printChar
		
	addi   s0, s0, -1	# s0--
	addi   s2, s2, 1	# col++
	jal    zero, printMultipleSameCharsLoop

# All the printing chars work is done
printMultipleSameCharsLoopEnd:	
	# Unstack
	lw     ra, 0(sp)
	lw     s0, 4(sp)
	lw     s1, 8(sp)
	lw     s2, 12(sp)
	lw     s3, 16(sp)
	addi   sp, sp, 20
	jalr   zero, ra, 0


#------------------------------------------------------------------------------
# printStr
#
# Subroutine description: Prints a string in the Keyboard and Display MMIO Simulator terminal at the
# given row and column.
#
# Args:
# 	a0: strAddr - The address of the null-terminated string to be printed.
# 	a1: row - The row to print on.
# 	a2: col - The column to start printing on.
#
# Register Usage
#      s0: The address of the string to be printed.
#      s1: The current row
#      s2: The current column
#      t0: The current character
#      t1: '\n'
#
# Return Values:
#	None
#
# References: This peice of code is adjusted from displayDemo.s(Zachary Selk, Jul 18, 2019)
#------------------------------------------------------------------------------
printStr:
	# Stack
	addi   sp, sp, -16
	sw     ra, 0(sp)
	sw     s0, 4(sp)
	sw     s1, 8(sp)
	sw     s2, 12(sp)

	mv     s0, a0
	mv     s1, a1
	mv     s2, a2

# the loop for printing string
printStrLoop:
	# Check for null-character
	lb     t0, 0(s0)
	# Loop while(str[i] != '\0')
	beq    t0, zero, printStrLoopEnd

	# Print Char
	mv     a0, t0
	mv     a1, s1
	mv     a2, s2
	jal    ra, printChar

	addi   s0, s0, 1	# i++
	addi   s2, s2, 1	# col++
	jal    zero, printStrLoop

printStrLoopEnd:
	# Unstack
	lw     ra, 0(sp)
	lw     s0, 4(sp)
	lw     s1, 8(sp)
	lw     s2, 12(sp)
	addi   sp, sp, 16
	jalr   zero, ra, 0



#------------------------------------------------------------------------------
# printChar
#
# Subroutine description: Prints a single character to the Keyboard and Display MMIO Simulator terminal
# at the given row and column.
#
# Args:
# 	a0: char - The character to print
#	a1: row - The row to print the given character
#	a2: col - The column to print the given character
#
# Register Usage
#      s0: The character to be printed.
#      s1: the current row
#      s2: the current column
#      t0: Bell ascii 7
#      t1: DISPLAY_DATA
#
# Return Values:
#	None
#
# References: This peice of code is adjusted from displayDemo.s(Zachary Selk, Jul 18, 2019)
#------------------------------------------------------------------------------
printChar:
	# Stack
	addi   sp, sp, -16
	sw     ra, 0(sp)
	sw     s0, 4(sp)
	sw     s1, 8(sp)
	sw     s2, 12(sp)
	# save parameters
	mv     s0, a0
	mv     s1, a1
	mv     s2, a2

	jal    ra, waitForDisplayReady

	# Load bell and position into a register
	addi   t0, zero, 7	# Bell ascii
	slli   s1, s1, 8	# Shift row into position
	slli   s2, s2, 20	# Shift col into position
	or     t0, t0, s1
	or     t0, t0, s2	# Combine ascii, row, & col
	
	# Move cursor
	lw     t1, DISPLAY_DATA
	sw     t0, 0(t1)
	jal    waitForDisplayReady	# Wait for display before printing
	
	# Print char
	lw     t0, DISPLAY_DATA
	sw     s0, 0(t0)
	
	# Unstack
	lw     ra, 0(sp)
	lw     s0, 4(sp)
	lw     s1, 8(sp)
	lw     s2, 12(sp)
	addi   sp, sp, 16
	jalr   zero, ra, 0



#------------------------------------------------------------------------------
# waitForDisplayReady
#
# Subroutine description: A method that will check if the Keyboard and Display MMIO Simulator terminal
# can be writen to, busy-waiting until it can.
#
# Args:
# 	None
#
# Register Usage
#      t0: used for DISPLAY_CONTROL
#
# Return Values:
#	None
#
# References: This peice of code is adjusted from displayDemo.s(Zachary Selk, Jul 18, 2019)
#------------------------------------------------------------------------------
waitForDisplayReady:
	# Loop while display ready bit is zero
	lw     t0, DISPLAY_CONTROL
	lw     t0, 0(t0)
	andi   t0, t0, 1
	beq    t0, zero, waitForDisplayReady
	jalr   zero, ra, 0
	
draw_snake:
	la	t0, snakeX
	la	t1, snakeY
	lw	a2, 0(t0)
	lw	a1, 0(t1)
	li	a0, 64
	#addi	sp, sp, -4
	#sw	ra, 0(sp)
	
	#stack
	addi	sp, sp, -12
	sw	t0, 0(sp)
	sw	t1, 4(sp)
	sw	ra, 8(sp)
	
	#draw the head
	jal	printChar
	
	#unstack
	lw	t0, 0(sp)
	lw	t1, 4(sp)
	lw	ra, 8(sp)
	addi	sp, sp, 12
	
	#add the address
	addi	t0, t0, 4
	addi	t1, t1, 4
	
	#draw the body
	li	t2, 3		#introduce flag for loop
	draw_body:
	beqz	t2, done_body
	#stack
	addi	sp, sp, -16
	sw	t0, 0(sp)
	sw	t1, 4(sp)
	sw	t2, 8(sp)
	sw	ra, 12(sp)
	lw	a2, 0(t0)
	lw	a1, 0(t1)
	li	a0, 42
	jal	printChar
	#unstack
	lw	t0, 0(sp)
	lw	t1, 4(sp)
	lw	t2, 8(sp)
	lw	ra, 12(sp)
	addi	sp, sp, 16
	#change flag
	addi	t2, t2, -1
	#add the address
	addi	t0, t0, 4
	addi	t1, t1, 4
	j	draw_body
	
	done_body:	
	ret
	
check_hitting:
	#li	t1, 0xFFFF0018 	#time
	#lw	t1, 0(t1)
	#mv	a0, t1
	#li	a7, 1
	#ecall