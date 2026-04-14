.globl factorial

.data
n: .word 8

.text
main:
    la t0, n
    lw a0, 0(t0)
    jal ra, factorial

    addi a1, a0, 0
    addi a0, x0, 1
    ecall # Print Result

    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

factorial:
    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    add s0, x0, a0 #s0存结果
    addi s1, a0, -1 #s1存次数
    add s2, x0, ra #s2存返回main的ra
    beq s0, x0, Exit0
Loop:
    blt s1, x0, Exit #小于0退出
    beq s1, x0, Exit #等于0退出
    add a0, x0, s0 #加载n * (n - 1) ……到a0
    add a1, s1, x0 #加载剩余次数到a1
    jal ra, mul #进行乘法运算
    add s0, x0, a0 #提取乘法结果
    addi s1, s1, -1 #剩余次数-1
    j Loop
        
Exit:
    add ra, s2, x0 #获取ra
    add a0, s0, x0 #存储结果
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 12
    jr ra
    
Exit0:
    add ra, s2, x0 #获取ra
    addi a0, x0, 1
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 12
    jr ra
        
mul:
    addi t0, a0, 0
    addi t1, a1, 0
    add t2, x0, x0
    Loop1:
        beq t1, x0, mul_Exit1
        add t2, t2, t0
        addi t1, t1, -1
        j Loop1
mul_Exit1:
    add a0, x0, t2
    jr ra
        
        