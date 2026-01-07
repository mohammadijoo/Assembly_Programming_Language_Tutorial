; Chapter2_Lesson9_Ex2.asm
; Build:
;   nasm -felf64 Chapter2_Lesson9_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o

default rel
global _start

section .data
b   db 0
w   dw 0
d   dd 0
q   dq 0
arr dq 1, 2, 3, 4

section .text
_start:
    ; Storing to memory: you must disambiguate the operand size.
    mov byte  [b], 0x7F
    mov word  [w], 0x1234
    mov dword [d], 0x89ABCDEF
    mov qword [q], 0x1122334455667788

    ; Loading from memory: destination register implies the size.
    movzx eax, byte [b]          ; EAX = 0x0000007F
    movzx ebx, word [w]          ; EBX = 0x00001234
    mov  ecx, dword [d]          ; ECX = 0x89ABCDEF, RCX zero-extended
    mov  rdx, qword [q]          ; RDX = 0x1122334455667788

    ; Indexed addressing for an array of qwords:
    lea r8, [arr]                ; base pointer
    mov r9, [r8 + 8*2]            ; arr[2] = 3

    ; Exit status = arr[2] (3).
    mov eax, 60
    mov edi, r9d
    syscall
