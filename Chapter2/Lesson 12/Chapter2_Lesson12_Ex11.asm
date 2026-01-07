; Zero-check idioms have different encodings.
; test eax,eax sets flags like cmp eax,0 but is often shorter.

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    mov     eax, 0

    test    eax, eax   ; typically 2 bytes
    jz      .is_zero

    cmp     eax, 0     ; typically 3 bytes (or more depending)
    jz      .is_zero

.is_zero:
    mov     eax, SYS_exit
    xor     edi, edi
    syscall
