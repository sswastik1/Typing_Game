#
# CMPUT 229 Public Materials License
# Version 1.0
#
# Copyright 2020 University of Alberta
# Copyright 2021 Emily Vandermeer
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
# Lab_Typing_Game Lab
#
# Author: 	swastik sharma
# Date: 	1 Nov 2021
# TA: 		Siva Chowdeswar Nandipati, Islam Ali 
#
#-------------------------------
.include "common.s"

.data
INPUT_1:	  		.asciz "Please enter 1, 2 or 3 to choose the level and start the game."
STRING1:		.asciz "points"
STRING2:		.asciz "000"
INTERRUPT_ERROR:	.asciz "Error: Unhandled interrupt with exception code: "
INSTRUCTION_ERROR:	.asciz "\n   Originating from the instruction at address: "
DISPLAY_CONTROL:	.word 0xFFFF0008
DISPLAY_DATA:		.word 0xFFFF000C
starr: 			.asciz "*"

.text

#------------------------------------------------------------------------------
# typing 
# Args:
#	a0: a pointer to the first element in the array of pointers
#	a5: moving the value of register a0 to a5
#	
# the main function in the program controlling all the execution.
#------------------------------------------------------------------------------
typing:
	li s11, 0 		# s11 is a global variable to store the points of the game
	mv a5, a0
	
	la t0, INPUT_1
    	mv a0, t0       	# moving the contents of t0 to a0 memory address of a0
    	li a1, 0         
    	li a2, 0        
    	jal printStr 		# calling function printStr to print the first sentance
    	
    	csrrwi zero, 0, 0x1	# for interrupts
    	li t6, 0x00000110	
    	csrrs zero, 4, t6	
    	
    	li s0, 0xFFFF0000	# loading immediate to s0
    	lw t5, 0(s0)		# loading the word stored at s0 
    	li t6, 0x00000002	# loading immediate to t6
    	or t5, t5, t6		# doing an or b/w t5 and t6 to set the first bit to 1 
    	sw t5, 0(s0)		# storing the updated bits at s0
    	
    	#loop for checking the difficulty level prompt
	Loop1:
		li s1, 0xFFFF0004	# loading the immediate value in s1
		lw t0, 0(s1)
		# storing the ASCII value		
		li t1, 49		
		li t2, 50
		li t3, 51
		beq t0, t1, Level1	#branching if the enterred value is 1
		beq t0, t2, Level2	#branching if the enterred value is 2
		beq t0, t3, Level3	#branching if the enterred value is 3
		jal Loop1		#looping around untill and unless we get either of the three options
		
	Level1:
		li t5, 1
	Level2:
		li t5, 2
	Level3:
		li t5, 3
	
	# the loop containing all the major operations
	MainLoop:
		mv s0, a0		# moving the contents of register a0 to s0  
		li a0, 12		# loading imme value 12 in a0 
		li a1, 0
		li a2, 0
		jal ra, printChar	# printing char will clear off all the screen
		mv a0, s0		# putting back the contents of a0 in it
		jal ra, Loop2		# Go to Loop 2 
		jal ra, random
	
	#for getting the memroy address of the phrase which is selected by random
	Loop5: 
		li a1, 4					# setting a1 to 4 so that it prints in 4th row
		li a2, 0					# seting a1 to 0
		lw t4, 0(t4)					# loading the random no. selected
		li t1, 4					 
		mul t4, t4, t1 					# multiplying 4 times t4 so that we get the req. string			
		add a5, a5, t4					# adding register values to get the final outcome	
		lw a4, 0(a5)					# loading the value at address 0(a5)	
		mv a6, a4					# moving the stored value to a6 to access afterwords
	
	# function for printing the random phrase
	Loop3:
		lbu a0, 0(a4)				#getting the value of 
		li t2, 10				# checking for new line character
		beq a0, t2, end				# branch 
		jal ra printChar			# print the character	
		li a1, 4				# loading imme 4 to a1 so that phrase prints in the 4th row
		addi a2, a2, 1				# increase the column no.
		addi a4, a4, 1				# increase the memory address of the string stored
		jal zero, Loop3	
		
	end:
		lbu t1, 0(a6)				# storing the ASCII value
		li a0, 42				# ascii value of *	
		li a1, 5				# 5th row	
		li a2, 0				# 0 th column
	
	Loop4:
		
		li s1, 0xFFFF0004			# Checking what is in the new input 
		li t2, 10				# loading the ascii value of newline character to t2
		lw t0, 0(s1)				# loading what is stored in 0(s1)
		beq t0, t1, star			# if found equal then go to star
		beq t1, t2, MainLoop			# if we found newline character then print a new phrase and go to mainLoop
		jal ra, Loop4
	
	# for printing the astriks (*)
	star:
		
		li a0, 42
		addi s11, s11, 1		#increasing the count of the points by 1
		jal ra, printChar		#printing the  point
						#printing the new points
		addi a6, a6, 1			# incresing the char in stored array by 1
		lbu t1, 0(a6)			# storing the  new ASCII value in t1
		addi a2, a2, 1			#increasing the a2
		jal ra, Loop4			# back to Loop4
	
	#loop for printing the points  
	Loop2:
		#li a0, 12			
		li s9, 10			
		rem s10, s11, s9		#this will get the remainder after dividing by 10
		addi s8, s10, 48  		#adding 48 to it so that we get the ASCII value of the digit
		add a0, s8, zero		#loading to a0 so that print Char works
		li a1, 0
		li a2, 2			# in column 2
		jal ra, printChar
		li a1, 0
		li a2, 1			# in column 1
		div s10, s11, s9 		# dividing by 10 so that we get the leftover 2 digits at tenth and hundredth place
		rem s8, s10, s9			#this will get the remainder after dividing by 1
		addi s8, s10, 48 		#adding 48 to it so that we get the ASCII value
		add a0, s8, zero 		#loading to a0 so that print Char works
		jal ra, printChar
		li a1, 0
		li a2, 0			# in column 0
		div s10, s10, s9		# dividing by 10 so that we get the leftover ones digit
		addi s8, s10, 48 		#adding 48 to it so that we get the ASCII value
		add a0, s8, zero 		#loading to a0 so that print Char works
		jal ra, printChar
		la a3, STRING1
		mv a0, a3
		li a1, 0
		li a2, 4			# loading the string in a0 and changing the coulmn number to 4
		jal ra, printStr		
#------------------------------------------------------------------------------
# random
# Args:
# 	t0: Loading the value of global register XiVar in it.
# 	t1: Loading the value of global register aVar in it.
# 	t2: Loading the value of global register cVar in it.
#	t3: Loading the value of global register mVar in it.
#	t4: temperary register to load address 	and then update the seed value
#
# random function for getting the LCG algorithm work
# 
#------------------------------------------------------------------------------
random:
	#loading the values from the global variables
	lw t0, XiVar
	lw t1, aVar
	lw t2, cVar
	lw t3, mVar
	mul t0, t0, t1			#multiplying the registers
	add t0, t0, t2			#adding the constant
	rem t0, t0, t3			# getting the modulus
	la t4, XiVar			#loading the address of seed 	
	sw t0, 0(t4)			# storing the updated value seed register address
	jal Loop5
#------------------------------------------------------------------------------
# handler
# Args:
# 	t5: temp registers
# 	t6: temp registers
# 	
#
# function for handling all kinds of interrupts
#------------------------------------------------------------------------------
handler:
	#saving the registers
	csrrw a0, uscratch, a0	# storing registers
	sw s0, 0(a0) 
	sw t5, 4(a0)
	sw t6, 8(a0)
	sw s1, 12(a0)
	sw s4, 16(a0)
	sw t1, 20(a0)
	sw s6, 24(a0)
	
	csrr t0, uscratch
	sw t0, 28(a0)

	li s0, 0xFFFF0000
    	lw t5, 0(s0)
    	li t6, 0x00000000
    	and t5, t5, t6
    	sw t5, 0(s0)
    	csrrwi s1, ucause, 0  
    	li t1, 0x8
    	beq s1, t1, Keyboard_Interrupt
    	
    	# making the keyboard interrupt
    	Keyboard_Interrupt:
    	    	li s0, 0xFFFF0000		
    		lw t5, 0(s0)
    		li t6, 0x00000002
    		or t5, t5, t6
    		sw t5, 0(s0)
    		
    		la a0, iTrapData
    		lw t0, 28(a0)
    		csrw t0, uscratch
    		
    		# restoring the registers
    		lw s0, 0(a0) 
		lw t5, 4(a0)
		lw t6, 8(a0)
		lw s1, 12(a0)
		lw s4, 16(a0)
		lw t1, 20(a0)
		lw s6, 24(a0)
		csrrw a0, uscratch, a0
    		
    		uret


handlerTerminate:
	# Print error msg before terminating
	li	a7, 4
	la	a0, INTERRUPT_ERROR
	ecall
	li	a7, 34
	csrrci	a0, 66, 0
	ecall
	li	a7, 4
	la	a0, INSTRUCTION_ERROR
	ecall
	li	a7, 34
	csrrci	a0, 65, 0
	ecall
handlerQuit:
	li	a7, 10
	ecall	# End of program
	
#------------------------------------------------------------------------------
# printStr
# Args:
# 	a0: strAddr - The address of the null-terminated string to be printed.
# 	a1: row - The row to print on.
# 	a2: col - The column to start printing on.
#
# Prints a string in the Keyboard and Display MMIO Simulator terminal at the
# given row and column.
#------------------------------------------------------------------------------
printStr:
	# Stack
	addi	sp, sp, -16
	sw	ra, 0(sp)
	sw	s0, 4(sp)
	sw	s1, 8(sp)
	sw	s2, 12(sp)
	
	mv	s0, a0
	mv	s1, a1
	mv	s2, a2
	printStrLoop:
		# Check for null-character
		lb	t0, 0(s0)	# t0 <- char = str[i]
		# Loop while(str[i] != '\0')
		beq	t0, zero, printStrLoopEnd
		
		# Print character
		mv	a0, t0		# a0 <- char
		mv	a1, s1		# a1 <- row
		mv	a2, s2		# a2 <- col
		jal	printChar
		
		addi	s0, s0, 1	# i++
		addi	s2, s2, 1	# col++
		j	printStrLoop
	printStrLoopEnd:
	
	# Unstack
	lw	ra, 0(sp)
	lw	s0, 4(sp)
	lw	s1, 8(sp)
	lw	s2, 12(sp)
	addi	sp, sp, 16
	jalr	zero, ra, 0

	
#------------------------------------------------------------------------------
# printChar
# Args:
#	a0: char - The character to print
#	a1: row - The row to print the given character
#	a2: col - The column to print the given character
#
# Prints a single character to the Keyboard and Display MMIO Simulator terminal
# at the given row and column.
#------------------------------------------------------------------------------
printChar:
	# Stack
	addi	sp, sp, -16
	sw	ra, 0(sp)
	sw	s0, 4(sp)
	sw	s1, 8(sp)
	sw	s2, 12(sp)
	
	# Save parameters
	add	s0, a0, zero
	add	s1, a1, zero
	add	s2, a2, zero
	
	jal	waitForDisplayReady	# Wait for display before printing
	
	# Load bell and position into a register
	addi	t0, zero, 7	# Bell ascii
	slli	s1, s1, 8	# Shift row into position
	slli	s2, s2, 20	# Shift col into position
	or	t0, t0, s1
	or	t0, t0, s2	# Combine ascii, row, & col
	
	# Move cursor
	lw	t1, DISPLAY_DATA
	sw	t0, 0(t1)
	
	jal	waitForDisplayReady	# Wait for display before printing
	
	# Print char
	lw	t0, DISPLAY_DATA
	sw	s0, 0(t0)
	
	# Unstack
	lw	ra, 0(sp)
	lw	s0, 4(sp)
	lw	s1, 8(sp)
	lw	s2, 12(sp)
	addi	sp, sp, 16
	jalr    zero, ra, 0
	
	
#------------------------------------------------------------------------------
# waitForDisplayReady
#
# A method that will check if the Keyboard and Display MMIO Simulator terminal
# can be writen to, busy-waiting until it can.
#------------------------------------------------------------------------------
waitForDisplayReady:
	# Loop while display ready bit is zero
	lw	t0, DISPLAY_CONTROL
	lw	t0, 0(t0)
	andi	t0, t0, 1
	beq	t0, zero, waitForDisplayReady
	
	jalr    zero, ra, 0
