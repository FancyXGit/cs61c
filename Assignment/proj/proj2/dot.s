.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:

    # Prologue
    # Validate vector length
    li t0, 1
    blt a2, t0, dot_fail_len
    # Validate vector length
    li t0, 1
    blt a3, t0, dot_fail_str
    # Validate vector length
    li t0, 1
    blt a4, t0, dot_fail_str
    # i for count
    mv t6, x0 # t6: i
    # index for arr
    mv t0, x0 # t0: i_v0
    mv t1, x0 # t1: i_v1
    # sum
    mv t2, x0 # t2: sum

loop_start:
    
    # when i == length end loop
    beq t6, a2, loop_end
    # get i with stride
    mul t0, t6, a3
    mul t1, t6, a4
    # get v0[i_v0]
    slli t3, t0, 2
    add t3, t3, a0
    lw t3, 0(t3)
    # get v1[i_v1]
    slli t4, t1, 2
    add t4, t4, a1
    lw t4, 0(t4)
    # sum += v0[i_v0] * v1[i_v1]
    mul t5, t3, t4
    add t2, t2, t5
    # i++
    addi t6, t6, 1
    j loop_start
    
loop_end:
    
    mv a0, t2

    # Epilogue

    
    ret   
    
dot_fail_len:
    li a7, 93
    li a0, 75
    ecall

dot_fail_str:
    li a7, 93
    li a0, 76
    ecall