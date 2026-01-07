bits 64
default rel

; Demonstrates RIP-relative address materialization for PIE/PIC:
;   lea reg, [rel symbol]
; Avoid: mov reg, symbol  (often becomes absolute relocation)

global _start

section .data
banner db "RIP-relative LEA is the default safe way to form addresses in 64-bit code.", 10
banner_len equ $ - banner

section .text
_start:
    lea rsi, [rel banner]
    mov edx, banner_len
    mov eax, 1
    mov edi, 1
    syscall

    mov eax, 60
    xor edi, edi
    syscall
