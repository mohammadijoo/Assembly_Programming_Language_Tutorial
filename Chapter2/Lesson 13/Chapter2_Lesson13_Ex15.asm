; NASM x86-64: flags are overwritten by many instructions.
; Correct pattern: cmp/test -> branch/setcc immediately (or save result).

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    mov     eax, 5
    mov     ebx, 5

    cmp     eax, ebx
    ; The following instruction would clobber flags if it were an arithmetic op.
    ; We keep a flag-neutral instruction here for illustration:
    mov     ecx, 123

    sete    dl          ; OK: flags still from cmp
    movzx   edi, dl
    mov     eax, SYS_exit
    syscall
