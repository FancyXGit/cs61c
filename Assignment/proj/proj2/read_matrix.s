.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -32
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw ra, 28(sp)
    
    mv s0, a0   # s0: &filename
    
    # set rows and cols return address
    mv s1, a1   # s1: rows_ret_add
    mv s2, a2   # s2: cols_ret_add
	
    # open data file
    # call fopen
    mv a1, s0
    li a2, 0    # read only
    jal ra, fopen
    mv s3, a0 # s3: file descriptor
    # check if fopen fail
    li t0, -1
    beq s3, t0, fopen_err
    
    # read data file
    # read the first byte to get rows
    mv a1, s3
    mv a2, s1
    li a3, 4  
    jal ra, fread
    # check if fread fail
    li t0, 4
    bne t0, a0, fread_err_no_mem
    lw s5, 0(s1) # s5: rows
    # read the second byte to get col
    mv a1, s3
    mv a2, s2
    li a3, 4  
    jal ra, fread
    # check if fread fail
    li t0, 4
    bne t0, a0, fread_err_no_mem
    lw s6, 0(s2) # s6: cols
    
    # malloc heap memory
    # call malloc
    # calulate memory size
    mul t0, s5, s6
    slli t0, t0, 2
    # call malloc
    mv a0, t0
    jal ra, malloc
    mv s4, a0 # s4: allocated heap memory
    # check if malloc fail
    beq a0, x0, malloc_err
    
    # call fread
    mv a1, s3
    mv a2, s4
    # calculate how many bytes
    mul t0, s5, s6
    slli t0, t0, 2
    mv a3, t0
    jal ra, fread
    # check if fread fail
    mul t0, s5, s6
    slli t0, t0, 2
    bne t0, a0, fread_err
    
    # close data file
    # call fclose
    mv a1, s3
    jal ra, fclose
    # check if fclose fail
    li t0, -1
    beq a0, t0, fclose_err
    
    # store return value
    mv a0, s4
    
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32

    ret

malloc_err:
    li a1 88
    j exit2

fopen_err:
    # call before malloc, no need to free memory
    li a1 90
    j exit2
    
fread_err_no_mem:
    # exit
    li a1 91
    j exit2
    
fread_err:
    # free heap memory first
    mv a0, s4
    jal ra, free
    # check if malloc fail
    beq a0, x0, malloc_err
    # exit
    li a1 91
    j exit2
    
fclose_err:
    # free heap memory first
    mv a0, s4
    jal ra, free
    # check if malloc fail
    beq a0, x0, malloc_err
    # exit
    li a1 92
    j exit2