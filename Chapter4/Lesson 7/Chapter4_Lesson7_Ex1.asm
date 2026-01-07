BITS 64
default rel
global _start

section .data
ptr dq 0

section .text
_start:
    ; Example 1: direct relative jump (NASM chooses short/near automatically)
    jmp short stage1

embedded_bytes:
    db 0xDE, 0xAD, 0xBE, 0xEF  ; proof you can jump over inline data safely

stage1:
    ; Example 2: indirect jump via register
    lea rbx, [rel stage2]
    jmp rbx

stage2:
    ; Example 3: indirect jump via memory (pointer loaded/stored)
    lea rcx, [rel stage3]
    mov [rel ptr], rcx
    jmp qword [rel ptr]

stage3:
    ; exit(0)
    mov eax, 60
    xor edi, edi
    syscall
