; NASM x86-64: unlike pure load/store ISAs, x86 can perform ALU ops directly on memory.
; Here we increment a dword in memory without an explicit load to a separate register.

BITS 64
global _start
SYS_exit equ 60

section .data
x: dd 41

section .text
_start:
    add     dword [rel x], 1   ; memory operand allowed on x86

    mov     eax, dword [rel x]
    mov     edi, eax
    mov     eax, SYS_exit
    syscall
