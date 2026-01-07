; Many x86-64 instructions sign-extend imm32 to 64-bit.
; But imm8 can be even shorter if the value fits [-128,127].

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    mov     rax, 0
    add     rax, 5           ; imm8 form likely
    add     rax, 0x7FFFFFFF  ; requires imm32

    mov     eax, SYS_exit
    xor     edi, edi
    syscall
