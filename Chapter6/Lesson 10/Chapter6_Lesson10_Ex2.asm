; Chapter 6 - Lesson 10 (Ex2): SysV AMD64 - Calling printf with a double vararg
; Key point: for variadic calls, AL must be an upper bound on the number of XMM regs used.
; Build (Linux x86-64):
;   nasm -f elf64 Chapter6_Lesson10_Ex2.asm -o ex2.o
;   gcc -no-pie ex2.o -o ex2
; Run:
;   ./ex2

default rel
bits 64

extern printf
global main

section .rodata
fmt:  db "x=%f, y=%ld", 10, 0
xval: dq 0x3ff4000000000000     ; 1.25 (IEEE-754 double)

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32                 ; 16-byte aligned before CALL

    mov rdi, fmt                ; format
    movsd xmm0, [xval]          ; 1st vararg (double) goes in XMM0
    mov rsi, 7                  ; 2nd vararg (long) goes in RSI

    mov eax, 1                  ; AL=1 (we used XMM0)
    call printf

    xor eax, eax
    leave
    ret
