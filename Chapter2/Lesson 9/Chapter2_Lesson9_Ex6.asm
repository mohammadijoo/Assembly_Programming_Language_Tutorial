; Chapter2_Lesson9_Ex6.asm
; Build:
;   nasm -felf64 Chapter2_Lesson9_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o

default rel
global _start

section .data
a dq 0x1111111122222222
b dq 0x3333333344444444

section .text
_start:
    mov rax, [a]
    mov rbx, [b]

    ; XCHG: swap two registers.
    xchg rax, rbx

    mov [a], rax
    mov [b], rbx

    ; XCHG: swap a register with memory (memory is both read and written).
    xchg rax, [a]                 ; now [a] gets previous rax, rax gets previous [a]

    ; Exit status = low byte of RAX.
    movzx edi, al
    mov eax, 60
    syscall
