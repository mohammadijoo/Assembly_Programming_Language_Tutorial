; x86-64 NASM: capture signed overflow using SETO after ADD.
; Exit 1 if signed overflow occurred (OF==1), else 0.

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    mov     al, 120
    add     al, 120         ; signed 8-bit: 120+120=240 -> overflow, OF=1

    seto    bl
    movzx   edi, bl
    mov     eax, SYS_exit
    syscall
