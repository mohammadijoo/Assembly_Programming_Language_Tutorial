; Demonstrates: label arithmetic, equ expressions, and constant folding

BITS 64
global _start

SYS_exit equ 60

section .data
bytes:      db 1,2,3,4,5,6,7,8
bytes_end:
bytes_len   equ bytes_end - bytes

; Useful derived constants
half_len    equ bytes_len / 2
mask_low3   equ (1 << 3) - 1

section .text
_start:
    ; Exit with status = half_len (for quick verification via: echo $?)
    mov     eax, SYS_exit
    mov     edi, half_len
    syscall
