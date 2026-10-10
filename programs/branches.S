    .section .text
    .globl _start
_start:
    addi t0, x0, -1
    addi t1, x0, 1
    addi t2, x0, 0

    blt  t0, t1, signed_ok
    addi t2, t2, 1
signed_ok:
    bltu t0, t1, no_leap
    ori  t2, t2, 2
no_leap:
    bne  t0, t1, different
    addi t2, t2, 4
different:
    slt  t3, t0, t1
    sltu t4, t0, t1
    slli t3, t3, 3
    or   t2, t2, t3
    slli t4, t4, 4
    or   t2, t2, t4
    ori  t2, t2, 0x35

    jal  ra, double
    sw   t2, 0(x0)
    sw   a0, 4(x0)
    ebreak

double:
    addi a0, x0, 8
    slli a0, a0, 1
    auipc t5, 0
    jalr x0, 0(ra)
