#
# CMPUT 229 Student Submission License
# Version 1.0
#
# Copyright 2021 <lukas waschuk>
#
# Redistribution is forbidden in all circumstances. Use of this
# software without explicit authorization from the author or CMPUT 229
# Teaching Staff is prohibited.
#
# This software was produced as a solution for an assignment in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada. This solution is confidential and remains confidential 
# after it is submitted for grading.
#
# Copying any part of this solution without including this copyright notice
# is illegal.
#
# If any portion of this software is included in a solution submitted for
# grading at an educational institution, the submitter will be subject to
# the sanctions for plagiarism at that institution.
#
# If this software is found in any public website or public repository, the
# person finding it is kindly requested to immediately report, including 
# the URL or other repository locating information, to the following email
# address:
#
#          cmput229@ualberta.ca
#
#---------------------------------------------------------------
# CCID:                 <  lwaschuk  >
# Lecture Section:      <  d01  >
# Instructor:           <  Nelson Amaral  >
# Lab Section:          <  unknown  >
# Teaching Assistant:   <  unknown  >
#---------------------------------------------------------------
# 

.include "common.s"
# NOTE: for the below to work, you must delete the .include "common.s" from your arm_alu.s file
.include "arm_alu.s" 

.data	
.align 2 
	RAT:			.space 2048
	BTT: 			.space 2048
.text

#----------------------------------
#        STUDENT SOLUTION
#----------------------------------
#---------------------------------------------------------------
# RISCVtoARM:
# arguments:
# 		a0:    pointer to memory containing a RISC-V function. The end of 
#	 		the RISC-V instructions is marked by the sentinel word 0xFFFFFFFF.
#
# 		a1:    a pointer to preallocated memory where you will have to write
#	 		ARM instructions.
#
# Returns:
# a0: number of bytes worth of instructions generated by RISCVtoARM.
#---------------------------------------------------------------
RISCVtoARM:
	addi sp,sp,-40			# sp <-- sp - 24
	sw s0, 0(sp)			# 0(sp) <-- s0
	sw s1, 4(sp)			# 4(sp) <-- s1
	sw s2, 8(sp)			# 8(sp) <-- s2
	sw s10, 12(sp)			# 12(sp) <-- s10
	sw s11, 16(sp)			# 16(sp) <-- s11
	sw ra, 20(sp)			# 20(sp) <-- ra
	sw s8, 24(sp)			# 24(sp) <-- s8
	sw s9, 28(sp)			# 28(sp) <-- s9 
	sw s7, 32(sp)			# 32(sp) <-- s7 
	sw s6, 36(sp)			# 36(sp) <-- s6
	mv s7, a0			# hold start of a0 
	mv s6 ,a1 			# hold start of return 
	mv s0, a0			# s0 <-- a0 ( move pointer to memory to s0, we need a0)
	mv s1, a1			# s1 <-- a1 ( move solution to s1)
	la s8, RAT			# s8 <-- RAT
	la s9, BTT 			# s9 <-- BTT 
	li s10, -1			# s10 <-- sentinal value -1
	li s11, 0 			# s11 <-- counter for the bytes
loopARM:				# loop to iterate over till we git sentenal 
	sw s1, 0(s8)			# add address to RAT
	addi s8,s8,4			# increment RAT
	lw s2, 0(s0)			# s2 <-- instruction to be translated
	mv a0, s2			# argument in a0
	jal translate			# jump to translate to find out what we need to translate 
	sw a0, 0(s1)			# a1 <-- translated arm inst
	beqz a1, continue		# if nothing is in a1 goto continue 
	addi s1,s1,4			# increment solution file 
	addi s11, s11, 4		# increment byte counter
	sw a1, 0(s1)			# store a1 into output aswell 
continue:				# if a1 is zero add nothing to output 
	addi s0,s0,4			# increment the pointer containing risc-v function
	addi s1,s1,4			# increment the solution file
	addi s11, s11, 4		# increment byte counter
	lw s2, 0(s0)			# s2 <-- instruction to be translated refresh it
	bne s2, s10, loopARM		# goto loopARM if s2 != -1
	mv a0, s7			# load base of input 
	la a1, RAT			# load base of RAT
	la a2, BTT			# load base of BTT
	jal updateBranch		# goto update branch 
	mv a0, s11 			# a0 <-- counter as return value
	lw s0, 0(sp)			# s0 <-- 0(sp)
	lw s1, 4(sp)			# s1 <-- 4(sp)
	lw s2, 8(sp)			# s2 <-- 8(sp)
	lw s10, 12(sp)			# s10 <-- 12(sp)
	lw s11, 16(sp)			# s11 <-- 16(sp)
	lw ra, 20(sp)			# ra <-- 20(sp)
	lw s3, 24(sp)			# s3 <-- 24(sp)
	lw s4, 28(sp)			# s4 <-- 28(sp)
	lw s7, 32(sp)			# s7 <-- 32(sp)
	lw s6, 36(sp)			# s6 <-- 36(sp)
	addi sp,sp,40			# sp <-- sp + 40
	jr ra 				# goto ra
#---------------------------------------------------------------
# Update Branch
#			This is called after a first "run through" of the input list 
#			It will takes values stored in BTT and RAT to update the offset on 
#			function calls that require it 
# arguments:
# 		a0:     pointer to memory containing a RISC-V function. The end of 
#	 		the RISC-V instructions is marked by the sentinel word 0xFFFFFFFF.
#			this will only be used to check for sentinal 
#
# 		a1:    	memory location of RAT
#
#		a2:   	memory location of BTT 

# Returns:		nothing 
#---------------------------------------------------------------
updateBranch:
	li t5, -1 			# t5 <-- -1 
	lw t2, 0(a2)			# address of BTT value in the output 
	lw t6, 0(a0)			# load the risc-v code to check for sentinal 
	beq t6, t5, leaveUpdateBranch	# if sentenal leave 
	beqz t2, next			# if its 0 iterate and go again
	lw t1, 0(a1)			# this is the value in rat 
	addi t1,t1,4			# this is the mem address of branch inst in output (ARM branch address)
	lw t3, 0(t1)			# this is the actual binary of arm translation 
	lw t2, 0(t2)			# load the value the BTT has stored at its address
	sub t6, t2, t1			# target - address 
	addi t6,t6,-0x8			# take away 8, this is the offset 
	srai t6,t6,2			# shift right by 2 while holding sign value 
	lui t0, 0x00FFF			# t0 <-- 0000 0000 1111 1111 1111
	li t2, 0xFFF			# t2 <-- 1111 1111 1111 
	or t0, t0, t2			# t0 <-- 0000 0000 1111 1111 1111 1111 1111 1111 FOR A MASK
	and t6,t6,t0			# mask them 
	or t3, t3, t6 			# this should update the offset 
	sw t3, 0(t1)			# save the new offset 
	j next				# goto next 
next:					# iterates everything by one and goes to next 
	addi a0,a0,4			# a0 <-- a0 + 4 
	addi a1,a1,4			# a1 <-- a1 + 4 
	addi a2,a2,4			# a2 <-- a2 + 4 
	j updateBranch			# goto updateBranch
leaveUpdateBranch:			# to go back 
	jr ra 				# goto ra 
	
#---------------------------------------------------------------
# translate:
# to find out what the inctruction is <control> or <alu> 
# arguments:
# 		a0:     untranslated RISC-V instruction.
# Returns: 	nothing it will direct the program to other functions.
#---------------------------------------------------------------
translate:
	addi sp, sp, -8 		# make room for ra on sp 
	sw ra, 0(sp)			# 0(sp) <-- ra 
	sw s0, 4(sp)			# 4(sp) <-- s0
	li t1, 0x67			# opcode for jal 	0110 0111
	li t2, 0x63			# opcode for branchs 	0110 0011
	li t3, 0x7f			# sentinal 
	mv s0, a0 			# s0 <-- untranslated risc-v code
	andi t0, s0, 0x7F		# get opcode
	beq t1, t0, gotoControl		# if opcode is 0110 0111 goto control 
	beq t2, t0, gotoControl		# if opcode is 0110 0011 goto control 
	beq t3, t0, done		# opcode = 111 1111 leave 
	j gotoALU			# else goto ALU 
gotoControl:				# goto control (this lab) 
	jal translateControl		# goto control if is is a control opcode
	j done				# goto done 
gotoALU:				# goto the alu function from last lab 
	jal translateALU		# go to alu if the opcode is a alu 
	li t0, 0			# t0 <-- 0
	sw t0, 0(s9)			# store a 0 into the branch stack 
	addi s9,s9,4			# increment 
	li a1, 0			# set a1 to zero 
	j done 				# goto done
done:					# leave 
	lw ra, 0(sp)			# ra <-- 0(sp)
	lw s0, 4(sp)			# s0 <-- 4(sp)
	addi sp,sp,8			# restore sp 
	jr ra 
	
#---------------------------------------------------------------
# translateControl:
# 		when it is determined we need to translate a control instruction 
# arguments:
# 		a0:     untranslated RISC-V instruction. ( will be control) 
# 
# Returns:
# 		a0: first translated ARM instruction. This should either be a wholly tanslated BX instruction, or a CMP instruction.
# 		a1: 0 or second translated ARM instruction. When non-zero, it should return a branch with 0 offset.
#---------------------------------------------------------------
translateControl:
	addi sp,sp,-28			# sp <-- sp - 28
	sw ra, 0(sp)			# 0(sp) <-- ra
	sw s0, 4(sp)			# 4(sp) <-- s0
	sw s1, 8(sp)			# 8(sp) <-- s1
	sw s2, 12(sp)			# 12(sp) <-- s2
	sw s3, 16(sp)			# 16(sp) <-- s3
	sw s4, 20(sp)			# 20(sp) <-- s4
	sw s5, 24(sp)			# 24(sp) <-- s5
					# find what the instruction OPCODE is
	mv s0, a0 			# s0 <-- untranslated risc-v code
	andi t0, s0, 0x7F		# get opcode
	li t1, 0x67			# opcode for jal 	0110 0111
	li t2, 0x63			# opcode for branchs 	0110 0011
	li t3, 0x7F			# t3 <-- 0111 1111 leave
	beq t0, t1, BX			# if t0 == 0110 0111
	beq t0, t2, branch		# if t0 == 0110 0011 
	beq t0, t3, leaveARM		# if opcode = 7F we leave
	j leaveARM			# goto leave ARM
BX: 					# come here if funct 3 if a jal 
	slli t0, s0, 12			# clear rightmost bits 
	srli t0, t0, 27			# get rd in LS bits 
	mv a0, t0			# move into argument 
	jal translateRegister		# goto translate reg 
	lui t0, 0xE12FF			# load 1110 0001 0010 1111 1111 
	li t1, 0xF1			# load 1111 0001 into t1 
	slli t1, t1, 4 			# make it 1111 0001 0000 
	or t0, t0, t1			# combine them
	or a0, a0, t0			# or everything together to return ( including register)
	li a1, 0 			# set a1 to 0 becuase it is BX
	sw a1, 0(s9)			# store onto the branch storage 
	addi s9,s9,4			# incrment 
	j leaveARM			# leave  
branch:					# come here is the funct3 is for branchs 
					# get rs1 
	slli t0, s0, 12			# clear rightmost bits 
	srli t0, t0, 27			# get rd in LS bits 
	mv a0, t0			# move into argument 
	jal translateRegister		# goto translate reg 
	mv s2, a0			# s1 <-- rs1
					# get rs2
	slli t0, s0, 7			# clear rightmost bits 
	srli t0, t0, 27			# get rd in LS bits 
	mv a0, t0			# move into argument 
	jal translateRegister		# goto translate reg 
	mv s3, a0			# s2 <-- rs2
					# get risc 5 offset 
	mv a0, s0			# untranslated risc-v code
	jal calculateRISCVBranchOffset	# goto calculateRISCVBranchOffset
	mv t5, a0			# move return value (risc-v offset) into t5 
	addi s8,s8,-4			# move back to current rat 
	mv t6, s8			# move s8 (RAT MEMORY ADDRESS) to t6 
	addi s8,s8,4			# restore to rat + 1 
	add t6,t6,t5			# new rat value 
	sw t6, 0(s9)			# save to branch 
	addi s9, s9, 4 			# increment 
					# get funct 3 
	li t1, 0x7000			# isolate funtc 3
	and t0, s0, t1			# t0 <-- isolated func3
	srli t0, t0, 12			# shift to the bottom
	mv s4, t0			# s4 <--- funct 3
	lui a0, 0xE1500			# load 0000 0001 0101 into upper bits of return 
	slli s2, s2, 16 		# move rs1 into place 
	or a0,a0,s2			# add rs1 ro return 
	or a0,a0,s3			# add rs2 to return 
	li t0, 0x0			# funct 3 = 0 
	li t1, 0x5			# finct 3 = 5 
	beq s4, t0, BEQ			# if funct3 = 0 goto BEQ 
	beq s4, t1, BGE			# if funct3 = 5 goto BGE
BEQ:
	lui a1, 0x0A000			# set bits for a BEQ offset 0 here 
	j leaveARM
BGE:
	lui a1, 0xAA000			# set bits for a BGE offset 0 
	j leaveARM
	
leaveARM: 				# reload regs and return to the translate where it will exit back to main 
	lw ra, 0(sp)			# ra <-- 0(sp)
	lw s0, 4(sp)			# s0 <-- 4(sp)
	lw s1, 8(sp)			# s1 <-- 8(sp)
	lw s2, 12(sp)			# s2 <-- 12(sp)
	lw s3, 16(sp)			# s3 <-- 16(sp)
	lw s4, 20(sp)			# s4 <-- 20(sp)
	lw s5, 24(sp)			# s5 <-- 24(sp)
	addi sp,sp,28			# sp <-- sp + 28
	jr ra 				# goto ra
	
#---------------------------------------------------------------
# calculateRISCVBranchOffset:
# 		This function performs simple computations to calculate the RISC-V branch offset. 
# 		Negative values calculated by this function should be returned with proper sign extension.
# Arguments:
# 		a0: RISC-V instruction.
# Return Values:
# 		a0: branch offset
#---------------------------------------------------------------
calculateRISCVBranchOffset:
					# get bit 12
	srli t0, a0, 31			# t0 <-- a0 >> 31
	slli t0, t0, 12			# t0 <-- t0 << 12 
					# get bit 11 
	slli t1, a0, 24			# t1 <-- a0 << 24 
	srli t1, t1, 31			# t1 <-- t1 >> 31
	slli t1, t1, 11			# t1 <-- t1 << 11 
					# get bit 10 -5 
	slli t2, a0, 1			# t2 <-- a0 << 1 
	srli t2, t2, 26			# t2 <-- t2 >> 26
	slli t2, t2, 5			# t2 <-- t2 << 5 
					# get bit 4 to 1 	
	slli t3, a0, 20			# t3 <-- a0 << 20 
	srli t3, t3, 28			# t2 <-- t3 >> 28 
	slli t3, t3, 1			# t3 <-- t3 << 1
					# combine everything together 
	li a0, 0			# a0 <-- 0 
	or a0, a0, t0			# a0 <-- a0 **OR** t0 (combine them)
	or a0, a0, t1			# a0 <-- a0 **OR** t1 (combine them)
	or a0, a0, t2			# a0 <-- a0 **OR** t2 (combine them)
	or a0, a0, t3			# a0 <-- a0 **OR** t3 (combine them)
					# shift left and right so we can sign extend 
	slli a0, a0, 19			# a0 <-- a0 << 20 
	srai a0, a0, 19 		# a0 <-- a0 >> 20 WITH SIGN EXTENTION 
	jr ra 				# goto ra 