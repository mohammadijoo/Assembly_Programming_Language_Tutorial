; Chapter7_Lesson2_Ex3.asm
; Lesson 2 (Chapter 7): Stack Frames and Stack Operations
; Demo: Frame pointer (RBP) addressing for locals.
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter7_Lesson2_Ex3.asm -o ex3.o
;   gcc -no-pie ex3.o -o ex3
; Run:
;   ./ex3

default rel
extern printf
global main

section .rodata
fmt: db "local a=%ld at %p, local b=%ld at %p", 10, 0

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32                ; locals + alignment

    ; locals: [rbp-8]=a, [rbp-16]=b
    mov qword [rbp-8],  1234
    mov qword [rbp-16], -77

    lea rdi, [fmt]
    mov rsi, [rbp-8]           ; a
    lea rdx, [rbp-8]           ; &a
    mov rcx, [rbp-16]          ; b
    lea r8,  [rbp-16]          ; &b
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret
