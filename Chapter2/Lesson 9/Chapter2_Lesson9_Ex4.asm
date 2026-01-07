; Chapter2_Lesson9_Ex4.asm
; Build:
;   nasm -felf64 Chapter2_Lesson9_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o

default rel
global _start

section .data
array dq 10, 20, 30, 40, 50, 60, 70, 80

section .text
_start:
    mov ecx, 5                    ; index = 5
    lea rbx, [array]              ; base pointer (address of array[0])

    ; Effective address computation:
    ;   &array[index] = base + index*8
    lea rax, [rbx + rcx*8]

    mov rdx, [rax]                ; value = 60

    ; Compute &array[index+1] without touching FLAGS:
    lea rsi, [rax + 8]
    mov r8, [rsi]                 ; value2 = 70

    ; Exit status = (60 + 70) mod 256 = 130.
    add edx, r8d
    mov eax, 60
    mov edi, edx
    syscall
