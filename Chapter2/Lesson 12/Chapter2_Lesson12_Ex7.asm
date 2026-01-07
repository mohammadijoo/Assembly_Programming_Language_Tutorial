; Operand size affects prefixes/opcodes.
; Observe how 16-bit ops require a size-override prefix (0x66).

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    mov     ax, 1           ; 16-bit immediate
    mov     eax, 1          ; 32-bit immediate
    mov     rax, 1          ; 64-bit immediate (often longer)

    mov     eax, SYS_exit
    xor     edi, edi
    syscall
