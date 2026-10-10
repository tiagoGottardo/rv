    .section .text
    .globl _start
_start:
    addi t0, x0, 0
    addi t1, x0, 1
    addi t2, x0, 10

loop:
    beq  t2, x0, ready
    add  t3, t0, t1
    addi t0, t1, 0 
    addi t1, t3, 0 
    addi t2, t2, -1
    jal  x0, loop

ready:
    sw   t0, 0(x0)
    ebreak
