    .section .text
    .globl _start
_start:
    addi t0, x0, 19
    addi t1, x0, 23
    add  t2, t0, t1
    sw   t2, 0(x0)
    ebreak
