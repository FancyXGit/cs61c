.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Prologue
    
    # Validate vector length
    li t0, 1
    blt a1, t0, relu_fail
    
    # i = 0
    mv t0, x0

loop_start:
    beq t0, a1, loop_end # stop when i == length
    
    # Load arr[i]
    slli t1, t0, 2
    add t2, t1, a0
    lw t3, 0(t2)
    
    bge t3, x0, loop_continue # if arr[i] >= 0, do not overwrite

    sw x0, 0(t2) # if arr[i] < 0, set arr[i] = 0

loop_continue:

    addi t0, t0, 1
    j loop_start

loop_end:

    # Epilogue

	ret
    
relu_fail:
    li a7, 93
    li a0, 78
    ecall
