; File A of a two-file project: export a symbol with global.
; Build (example):
;   nasm -felf64 Chapter2_Lesson11_Ex5.asm -o ex5.o

BITS 64
global add42

section .text
add42:
    ; Return rax = 42
    mov     eax, 42
    ret
