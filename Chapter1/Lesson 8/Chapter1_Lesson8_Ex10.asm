# file: lineinfo_demo.s (GAS AT&T)
    .file 1 "lineinfo_demo.s"
    .text
    .globl _start
_start:
    .loc 1 10 0
    xorl %eax, %eax
    .loc 1 11 0
    incq %rax
    .loc 1 12 0
    ret
