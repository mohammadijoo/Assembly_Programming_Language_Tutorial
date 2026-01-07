; Solution-oriented example: fixed-size records with compile-time sizing.
; Goal: Build N records of SIZE bytes initialized to 0.

BITS 64
global _start

SYS_exit equ 60

N    equ 4
SIZE equ 12

section .data
records:
    times (N*SIZE) db 0
records_end:
records_bytes equ records_end - records

section .text
_start:
    ; exit status = total bytes (mod 256)
    mov     eax, SYS_exit
    mov     edi, records_bytes
    syscall
