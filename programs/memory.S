    .section .text
    .globl _start
_start:
    lui  t0, 0x12345
    addi t0, t0, 0x678
    sw   t0, 4(x0)

    lb   t1, 4(x0)
    lbu  t2, 5(x0)
    lh   t3, 4(x0)
    lhu  t4, 6(x0)
    lw   t5, 4(x0)
    sw   t1, 8(x0)
    sw   t2, 12(x0)
    sw   t3, 16(x0)
    sw   t4, 20(x0)
    sw   t5, 24(x0)

    addi t6, x0, -1
    sb   t6, 28(x0)
    sh   t6, 30(x0)
    ebreak
