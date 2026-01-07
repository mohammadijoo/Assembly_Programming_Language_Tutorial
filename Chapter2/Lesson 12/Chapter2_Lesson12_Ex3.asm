; Immediate size influences instruction length.
; For many ALU ops, small immediates use imm8 with sign-extension.

BITS 64
global _start

SYS_exit equ 60

section .text
_start:
    mov     eax, 10
    add     eax, 1          ; often uses imm8 form (shorter)
    add     eax, 0x12345678 ; requires imm32 (longer)

    mov     eax, SYS_exit
    xor     edi, edi
    syscall
