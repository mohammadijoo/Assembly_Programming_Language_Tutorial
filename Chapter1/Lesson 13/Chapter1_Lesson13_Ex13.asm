# src/print_gas.S (GAS)
    .globl print_str_gas

    .include "syscalls_linux_x86_64_gas.inc"

    .section .text
print_str_gas:
    push %rbx
    mov %rdi, %rbx

1:
    cmpb $0, (%rbx)
    je 2f
    inc %rbx
    jmp 1b

2:
    mov %rbx, %rdx
    sub %rdi, %rdx

    mov $SYS_write, %eax
    mov $1, %edi
    mov %rdi, %rsi
    syscall

    pop %rbx
    ret
