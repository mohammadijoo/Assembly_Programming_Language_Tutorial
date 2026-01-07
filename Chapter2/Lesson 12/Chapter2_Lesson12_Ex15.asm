; Solution-oriented: create two equivalent code paths and compare assembled sizes with NASM listing.
; Assemble with: nasm -felf64 -l listing.lst Chapter2_Lesson12_Ex15.asm

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    ; Path A: MOV zero
    mov     eax, 0
    mov     ebx, 0

    ; Path B: XOR zero
    xor     ecx, ecx
    xor     edx, edx

    mov     eax, SYS_exit
    xor     edi, edi
    syscall
