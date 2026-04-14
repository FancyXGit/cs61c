# Ans

## Exercise 1

1. `.data`声明后续内容放入数据段;`.word`放在`.data`内，分配4个字节给初始量;`.text`是存放指令的区域
2. 程序产出结果34，是从0，1开始斐波那契数列的第10项（从1计数）
3. `0x10000010`
4. 循环开始前修改`t3`的值为12即可

## Exercise 2

1. `t0`
2. `s0`
3. `source`:`s1`;`dest`:`s2`
4. 代码如下:

```assembly
loop:
    slli s3, t0, 2
    add t1, s1, s3
    lw t2, 0(t1)
    beq t2, x0, exit
    add a0, x0, t2
    addi sp, sp, -8
    sw t0, 0(sp)
    sw t2, 4(sp)
    jal fun
    lw t0, 0(sp)
    lw t2, 4(sp)
    addi sp, sp, 8
    add t2, x0, a0
    add t3, s2, s3
    sw t2, 0(t3)
    add s0, s0, t2
    addi t0, t0, 1
    jal x0, loop
exit:
```

5. 指针不断+1

## Exercise 4

1. 保存寄存器使用之前没有保存在栈上
2. 不需要，他们不是函数，寄存器由所在函数负责
3. 因为`inc_arr`调用了`helper_fn`，会使得`ra`变成返回`inc_arr`的地址
4. 不知道为什么我只写了`lw`和`sw`就`0 warnings`了

