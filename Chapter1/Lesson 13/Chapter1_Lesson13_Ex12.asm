# src/main_gas.S (GAS, AT&T syntax)
    .globl _start
    .extern print_str_gas

    .section .rodata
msg:
    .asciz "Hello from GAS workflow!\n"

    .section .text
_start:
    leaq msg(%rip), %rdi
    call print_str_gas

    mov $60, %eax        # SYS_exit
    xor %edi, %edi
    syscall
