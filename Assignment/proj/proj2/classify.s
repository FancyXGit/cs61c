.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    addi sp, sp, -64
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw ra, 40(sp)
    # 44(sp)
    # 48(sp)
    sw s10, 52(sp)
    sw s11, 56(sp)
    sw a2, 60(sp) # 60(sp): print_classification
    
    # check if parameter number correct
    li t0, 5
    bne a0, t0, incorrect_args_num
    # load parameter  
    lw s0, 4(a1)    # s0: m0_file_path
    lw s1, 8(a1)    # s1: m1_file_path
    lw s2, 12(a1)   # s2; input_matrix_path
    lw s3, 16(a1)   # s3: output_matrix_path
    

	# =====================================
    # LOAD MATRICES
    # =====================================

    # Load pretrained m0

    mv a0, s0
    addi t0, sp, 44
    mv a1, t0   # set 44(sp) to m0_rows
    addi t0, sp, 48
    mv a2, t0   # set 48(sp) to m0_cols
    jal ra, read_matrix
    mv s0, a0   # overlap m0_file_path; s0: m0_matrix
    lw s4, 44(sp)   # s4: m0_rows
    lw s5, 48(sp)   # s5: m0_cols

    # Load pretrained m1

    mv a0, s1
    addi t0, sp, 44
    mv a1, t0   # set 44(sp) to m1_rows
    addi t0, sp, 48
    mv a2, t0   # set 48(sp) to m1_cols
    jal ra, read_matrix
    mv s1, a0   # overlap m1_file_path; s1: m1_matrix
    lw s6, 44(sp)   # s6: m1_rows
    lw s7, 48(sp)   # s7: m1_cols

    # Load input matrix

    mv a0, s2
    addi t0, sp, 44
    mv a1, t0   # set 44(sp) to input_rows
    addi t0, sp, 48
    mv a2, t0   # set 48(sp) to input_cols
    jal ra, read_matrix
    mv s2, a0   # overlap input_file_path; s2: input_matrix
    lw s8, 44(sp)   # s8: input_rows
    lw s9, 48(sp)   # s9: input_cols

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    
    # alloc memory for res matrix
    mul t0, s4, s9
    slli t0, t0, 2
    mv a0, t0
    jal ra, malloc
    # check if malloc fail
    beq a0, x0, malloc_err
    mv s10, a0  # s10: m0 * input
    
    mv a0, s0
    mv a1, s4
    mv a2, s5
    mv a3, s2
    mv a4, s8
    mv a5, s9
    mv a6, s10
    jal ra, matmul
    
    
    
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    
    mv a0, s10
    mul t0, s4, s9
    mv a1, t0
    jal ra, relu
    
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
  
    # alloc memory for res matrix
    mul t0, s6, s9
    slli t0, t0, 2
    mv a0, t0
    jal ra, malloc
    # check if malloc fail
    beq a0, x0, malloc_err
    mv s11, a0  # s11: res
    
    mv a0, s1
    mv a1, s6
    mv a2, s7
    mv a3, s10
    mv a4, s4
    mv a5, s9
    mv a6, s11
    jal ra, matmul
    
    # free s10(middle matrix)
    mv a0, s10
    jal ra, free

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix

    mv a0, s3
    mv a1, s11
    mv a2, s6
    mv a3, s9
    jal ra, write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax

    mv a0, s11
    mul t0, s6, s9
    mv a1, t0
    jal ra, argmax
    mv s10, a0  # s10: largest index in s11
    

    # Print classification
    
    lw t0, 60(sp)
    bne t0, x0, continue
    
    mv a1, s10
    jal ra, print_int

    # Print newline afterwards for clarity
    li a1, '\n'
    jal ra, print_char
    

continue:
    # Free heap allocations created by read_matrix/malloc
    mv a0, s0
    jal ra, free
    mv a0, s1
    jal ra, free
    mv a0, s2
    jal ra, free
    mv a0, s11
    jal ra, free

    # Return classification in a0
    mv a0, s10

    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw ra, 40(sp)
    lw s10, 52(sp)
    lw s11, 56(sp)
    addi sp, sp, 64
    ret
    
incorrect_args_num:
    li a1 89
    j exit2
    
malloc_err:
    li a1 88
    j exit2
