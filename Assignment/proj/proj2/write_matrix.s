.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw ra, 20(sp)
    # 24(sp) stores row or col for fwrite to get
    
    mv s0, a0   # s0: &filename
    mv s1, a1   # s1: matrix
    mv s2, a2   # s2: rows
    mv s3, a3   # s3: cols
    
    # open file
    mv a1, s0
    li a2, 1 # write permission
    # call fopen
    jal ra, fopen
    # check if fopen fail
    li t0, -1
    beq a0, t0, fopen_err
    mv s4, a0 # s4: file descriptor
    
    # write file
    # write rows
    mv a1, s4
    sw s2, 24(sp)
    addi t0, sp, 24
    mv a2, t0
    li a3, 1
    li a4, 4
    jal ra, fwrite
    # check if fwrite fail
    li t0, 1
    bne a0, t0, fwrite_err
    # write cols
    mv a1, s4
    sw s3, 24(sp)
    addi t0, sp, 24
    mv a2, t0
    li a3, 1
    li a4, 4
    jal ra, fwrite
    # check if fwrite fail
    li t0, 1
    bne a0, t0, fwrite_err
    # write matrix
    mv a1, s4
    mv a2, s1
    # calculate matrix size
    mul t0, s2, s3
    mv a3, t0
    li a4, 4
    jal ra, fwrite
    # check if fwrite fail
    mul t0, s2, s3
    bne a0, t0, fwrite_err
    
    # close file
    # call fclose
    mv a1, s4
    jal ra, fclose
    # check if fclose fail
    li t0, -1
    beq a0, t0, fclose_err
    
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 28

    ret
    
fopen_err:
    li a1 93
    j exit2

fwrite_err:
    # close file
    # call fclose
    mv a1, s4
    jal ra, fclose
    # check if fclose fail
    li t0, -1
    beq a0, t0, fclose_err
    li a1 94
    j exit2

fclose_err:
    li a1 95
    j exit2