; Register choice changes encoding on x86-64 (REX prefixes).
; r8..r15 require a REX prefix, even for simple operations.

BITS 64
global _start

SYS_exit equ 60

section .text
_start:
    xor     eax, eax        ; 2 bytes
    xor     r8d, r8d        ; 3 bytes (includes REX prefix)

    mov     eax, SYS_exit
    xor     edi, edi
    syscall
