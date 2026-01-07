; Compare encodings: MOV reg,imm vs XOR reg,reg
; Use a disassembler to inspect bytes (objdump -d or ndisasm).
; Goal: see why idioms matter for size.

BITS 64
global _start

SYS_exit equ 60

section .text
_start:
    mov     eax, 0          ; typically 5 bytes: B8 00 00 00 00
    xor     eax, eax        ; typically 2 bytes: 31 C0

    ; exit(0)
    mov     eax, SYS_exit
    xor     edi, edi
    syscall
