.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks
    
    # check if rows and colomns make sense
    li t0, 1
    blt a1, t0, fail_matmul_m0
    blt a2, t0, fail_matmul_m0
    blt a4, t0, fail_matmul_m1
    blt a5, t0, fail_matmul_m1
    
    # check if m0 and m1 match
    bne a2, a4, fail_matmul_match
    
    # Prologue
    addi sp, sp, -40
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw ra, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)

    # save arguments
    mv s0, a0 # m0
    mv s1, a1 # m0 rows
    mv s2, a2 # m0 cols
    mv s3, a3 # m1
    mv s4, a4 # m1 rows
    mv s5, a5 # m1 cols
    mv s6, a6 # d
    
    # i for rows
    li s7, 0 # s7: i
    # j for colomns
    li s8, 0 # s8: j

outer_loop_start:
    # exit outer_loop when i == m0_row
    beq s7, s1, outer_loop_end

inner_loop_start:
    # exit inner_loop when j == m1_col
    beq s8, s5, inner_loop_end
    # get m1 row vector address
    mul t0, s7, s2
    slli t0, t0, 2
    add a0, s0, t0
    # get m2 col vector adddress
    slli t1, s8, 2
    add a1, t1, s3
    # set length
    mv a2, s2
    # set stride
    li a3, 1
    mv a4, s5
    # cal dot
    jal ra, dot
    # get d[i][j] address
    mul t0, s7, s5
    add t0, t0, s8
    slli t0, t0, 2
    add t0, s6, t0
    # set vector dot res
    sw a0, 0(t0)
    # j++
    addi s8, s8, 1
    # next loop
    j inner_loop_start
    
inner_loop_end:
    # i++
    addi s7, s7, 1
    # j = 0
    li s8, 0
    # next loop
    j outer_loop_start

outer_loop_end:
    
    # Epilogue
    lw s8, 36(sp)
    lw s7, 32(sp)
    lw ra, 28(sp)
    lw s6, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 40
    ret
    
fail_matmul_m0:
    li a7, 93
    li a0, 72
    ecall
fail_matmul_m1:
    li a7, 93
    li a0, 73
    ecall
fail_matmul_match:
    li a7, 93
    li a0, 74
    ecall