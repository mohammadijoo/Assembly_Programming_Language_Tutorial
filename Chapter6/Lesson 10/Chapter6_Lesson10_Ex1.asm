; Chapter 6 - Lesson 10 (Ex1): SysV AMD64 - Calling a variadic function (printf) with integer-only args
; Build (Linux x86-64):
;   nasm -f elf64 Chapter6_Lesson10_Ex1.asm -o ex1.o
;   gcc -no-pie ex1.o -o ex1
; Run:
;   ./ex1

default rel
bits 64

extern printf
global main

section .rodata
fmt: db "sum=%ld, a=%ld, b=%ld", 10, 0

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32                ; keep stack 16-byte aligned before CALL

    mov rdi, fmt               ; 1st arg (named): format string
    mov rsi, 30                ; 2nd arg (variadic): long
    mov rdx, 10                ; 3rd arg (variadic): long
    mov rcx, 20                ; 4th arg (variadic): long

    xor eax, eax               ; SysV varargs: AL = number of vector regs used (0 here)
    call printf

    xor eax, eax               ; return 0 from main
    leave
    ret
