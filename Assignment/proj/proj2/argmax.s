.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:

    # Prologue
    
    # Validate vector length
    li t0, 1
    blt a1, t0, argmax_fail
    
    # i = 0
    mv t0, x0 # t0:i
    # load max_value = arr[0]
    slli t4, t0, 2
    add t5, a0, t4
    lw t2, 0(t5)  # t2:max_value
    # i = 1
    li t0, 1
    # largest index = 0
    mv t1, x0 # t1:max_index


loop_start:
    # end if i == vector length
    beq t0, a1, loop_end
    #load arr[i]
    slli t4, t0, 2
    add t5, a0, t4
    lw t3, 0(t5)  # t3:arr[i]
    #when arr[i]<max_value
    blt t3, t2, loop_continue
    #when arr[i]<=max_value
    beq t3, t2, loop_continue
    # arr[i] > max_value
    mv t2, t3
    mv t1, t0
        
loop_continue:
    addi t0, t0, 1
    j loop_start

loop_end:
    mv a0 t1
    # Epilogue


    ret
    
argmax_fail:
    li a7, 93
    li a0, 77
    ecall
