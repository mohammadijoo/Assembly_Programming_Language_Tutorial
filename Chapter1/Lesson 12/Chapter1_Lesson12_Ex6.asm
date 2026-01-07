# hello_gas_intel.s (Linux x86-64, GAS Intel mode)
# Assemble: as --64 hello_gas_intel.s -o hello_gas_intel.o

    .intel_syntax noprefix

    .section .rodata
msg:
    .ascii  "Hello from GAS (Intel mode)!\n"
msg_end:
    .equ msg_len, msg_end - msg

    .section .text
    .globl _start
_start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rip + msg]
    mov rdx, msg_len
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

    .att_syntax prefix