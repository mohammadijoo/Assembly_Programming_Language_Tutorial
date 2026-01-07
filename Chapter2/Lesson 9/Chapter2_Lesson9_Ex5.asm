; Chapter2_Lesson9_Ex5.asm
; Chapter2_Lesson9_Ex5.asm
; Build:
;   nasm -felf64 Chapter2_Lesson9_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o

global _start
section .text
_start:
    mov eax, 37

    ; LEA for arithmetic (no memory access, flags unchanged):
    ; y = 5*x + 17 = (x + 4*x) + 17
    lea ecx, [rax + rax*4]
    add ecx, 17

    ; z = 9*x - 3 = (8*x + x) - 3
    lea edx, [rax*8 + rax]
    sub edx, 3

    ; Exit status = (y XOR z) mod 256 (arbitrary observable result).
    xor ecx, edx
    and ecx, 0xFF

    mov eax, 60
    mov edi, ecx
    syscall
