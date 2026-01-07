# GAS AT&T syntax example (x86-64)
# file: hello_puts.s

    .globl main
    .extern puts

    .section .rodata
msg:
    .asciz "Hello from assembly (puts)!"

    .text
main:
    leaq msg(%rip), %rdi
    xorl %eax, %eax
    call puts
    xorl %eax, %eax
    ret
