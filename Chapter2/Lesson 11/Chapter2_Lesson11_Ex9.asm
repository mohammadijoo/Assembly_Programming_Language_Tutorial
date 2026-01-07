; Demonstrates: times directive for repeated data emission

BITS 64
global _start

SYS_exit equ 60

section .data
pad16:      times 16 db 0xCC      ; 16 bytes of 0xCC (common debug fill pattern)

section .text
_start:
    ; Exit with status = first byte of pad16 (0xCC -> 204)
    mov     eax, SYS_exit
    movzx   edi, byte [rel pad16]
    syscall
