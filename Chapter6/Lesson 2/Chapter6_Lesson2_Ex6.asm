; Chapter 6 - Lesson 2 - Example 6
; File: Chapter6_Lesson2_Ex6.asm
; Topic: Declaring and calling an external procedure (libc puts)
;
; Build (Linux, SysV AMD64):
;   nasm -felf64 Chapter6_Lesson2_Ex6.asm -o ex6.o
;   gcc -no-pie -o ex6 ex6.o
; Run:
;   ./ex6

default rel

section .rodata
hello: db "Hello from NASM procedures!", 0

section .text
global main
extern puts

main:
    ; On entry (SysV), RSP % 16 = 8. Push RBP to realign to 16 before CALL.
    push rbp
    mov rbp, rsp

    lea rdi, [rel hello]   ; arg1 = char* (RDI)
    call puts              ; returns int in EAX (ignored)

    xor eax, eax           ; return 0 from main
    pop rbp
    ret
