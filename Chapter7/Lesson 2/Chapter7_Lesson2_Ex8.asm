; Chapter7_Lesson2_Ex8.asm
; Lesson 2 (Chapter 7): Stack Frames and Stack Operations
; Demo: ENTER/LEAVE as an alternative prologue/epilogue.
; Note: ENTER is usually slower on modern CPUs; shown for completeness.
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter7_Lesson2_Ex8.asm -o ex8.o
;   gcc -no-pie ex8.o -o ex8
; Run:
;   ./ex8

default rel
extern printf
global main

section .rodata
fmt: db "ENTER frame local x=%ld at %p", 10, 0

section .text
main:
    enter 32, 0                 ; like: push rbp; mov rbp,rsp; sub rsp,32

    mov qword [rbp-8], 2026     ; local x at [rbp-8]

    lea rdi, [fmt]
    mov rsi, [rbp-8]
    lea rdx, [rbp-8]
    xor eax, eax
    call printf

    xor eax, eax
    leave                       ; mov rsp,rbp; pop rbp
    ret
