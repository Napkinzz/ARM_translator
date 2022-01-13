.data

.align 2
# space for the representation of the RISC-V input program
binary: 	.space 2052
# space where the representation of the generated ARM program is to be placed
codeSection: 	.space 2048

noFileStr:	.asciz "Couldn't open specified file.\n"
createFileStr:	.asciz "Couldn't create specified file.\n"
format:		.asciz "\n"
# all generated output files are named 'out.bin'
outfile:      	.asciz "out.bin"

.text
main:
    lw      a0, 0(a1)				    # put the filename pointer into a0
    li      a1, 0   		           	# read Only
    li	    a7, 1024		    		# open File
    ecall
    bltz    a0, main_err	    		# negative means open failed

    la      a1, binary	        		# write into my binary space
    li      a2, 2048	        		# read a file of at max 2kb
    li      a7, 63		            	# read File System call
    ecall

    la      t0, binary
    add     t0, t0, a0	       			# point to end of binary space

    li      t1, 0xFFFFFFFF	    		# place ending sentinel
    sw      t1, 0(t0)

    la      a0, binary
    la      a1, codeSection
    jal     ra, RISCVtoARM      		# run student solution
    jal     ra, writeFile       		# write student's solution result to file

    jal     zero, main_done

main_err:
    la      a0, noFileStr
    li      a7, 4
    ecall

main_done:
    li      a7, 10
    ecall

#-------------------------------------------------------------------------------------------------------------------------
# writeFile
# This function opens file and writes student's translated ARM instructions into the file.
# 
# Arguments
#   - a0: number of bytes total for the translation result, value provided by the student
#-------------------------------------------------------------------------------------------------------------------------
writeFile:
    addi    sp, sp, -4
    sw      s0, 0(sp)
    mv      s0, a0
    # open file
    la      a0, outfile         # filename for writing to
    li      a1, 1   		    # Write flag
    li      a7, 1024            # Open File
    ecall
    bltz	a0, writeOpenErr	# Negative means open failed
    # write to file
    la      a1, codeSection     # address of buffer from which to start the write from
    mv      a2, s0              # buffer length
    li      a7, 64              # system call for write to file
    ecall                       # write to file
    # close file
    la      a0, outfile         # file descriptor to close
    li      a7, 57              # system call for close file
    ecall                       # close file
    jal     zero, writeFileDone

writeOpenErr:
    la      a0, createFileStr
    li      a7, 4
    ecall

writeFileDone:
    lw      s0, 0(sp)
    addi    sp, sp 4
    jalr    zero, ra, 0
#-------------------------------------end common--------------------------------------------
