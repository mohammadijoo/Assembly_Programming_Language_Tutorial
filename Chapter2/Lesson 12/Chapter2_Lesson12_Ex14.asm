; High-level encoding breakdown (illustrative, not executable logic).
; x86 instruction length can be modeled as:
;   len = prefixes + opcode + modrm + sib + disp + imm

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    ; Example typical shape: mov rax, [rbx+8]
    mov     rax, [rbx+8]

    ; exit(0)
    mov     eax, SYS_exit
    xor     edi, edi
    syscall
