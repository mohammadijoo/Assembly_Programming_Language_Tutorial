BITS 64
default rel

; Module A: defines a global variable and exports it + a getter.
; Build:
;   nasm -felf64 Chapter6_Lesson4_Ex7.asm -o a.o
;   nasm -felf64 Chapter6_Lesson4_Ex8.asm -o b.o
;   ld -o demo a.o b.o

global g_shared
global get_shared

section .data
align 8
g_shared dq 123

section .text
; get_shared() -> rax
get_shared:
    mov rax, [rel g_shared]
    ret
