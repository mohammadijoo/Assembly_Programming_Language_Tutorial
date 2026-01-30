; Chapter7_Lesson2_Ex1.asm
; Lesson 2 (Chapter 7): Stack Frames and Stack Operations
; Demo: Observe stack alignment (SysV AMD64) using printf.
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter7_Lesson2_Ex1.asm -o ex1.o
;   gcc -no-pie ex1.o -o ex1
; Run:
;   ./ex1

default rel
extern printf
global main

section .rodata
fmt: db "Entry stack: RSP=%p, (RSP mod 16)=%d", 10, 0

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32                ; keep rsp 16-byte aligned before call

    mov rax, rsp
    mov rcx, rax
    and rcx, 15                ; rcx = rsp mod 16

    lea rdi, [fmt]             ; arg0: format
    mov rsi, rax               ; arg1: rsp as pointer
    mov edx, ecx               ; arg2: mod value (int)
    xor eax, eax               ; SysV: AL=0 for variadic calls
    call printf

    xor eax, eax
    leave
    ret
