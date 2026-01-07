; Demonstrates: multiple sections (.rodata, .text), and label naming conventions

BITS 64
global _start

SYS_write equ 1
SYS_exit  equ 60
STDOUT    equ 1

section .rodata
banner:     db "Read-only data section (.rodata) example", 10
banner_len: equ $ - banner

section .text
_start:
    mov     eax, SYS_write
    mov     edi, STDOUT
    lea     rsi, [rel banner]
    mov     edx, banner_len
    syscall

    mov     eax, SYS_exit
    xor     edi, edi
    syscall
