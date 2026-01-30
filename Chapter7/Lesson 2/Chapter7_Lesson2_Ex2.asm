; Chapter7_Lesson2_Ex2.asm
; Lesson 2 (Chapter 7): Stack Frames and Stack Operations
; Demo: CALL pushes a return address. At callee entry, [rsp] is the return address.
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter7_Lesson2_Ex2.asm -o ex2.o
;   gcc -no-pie ex2.o -o ex2
; Run:
;   ./ex2

default rel
extern printf
global main

section .rodata
fmt1: db "Inside callee: [entry rsp] return address = %p", 10, 0
fmt2: db "Inside callee: [rbp+8]   return address = %p", 10, 0

section .text
callee:
    ; At entry, [rsp] holds the return address pushed by CALL.
    mov r10, [rsp]

    push rbp
    mov rbp, rsp
    sub rsp, 32                ; keep alignment for printf

    lea rdi, [fmt1]
    mov rsi, r10
    xor eax, eax
    call printf

    ; After prologue, the return address is at [rbp+8].
    mov r10, [rbp+8]
    lea rdi, [fmt2]
    mov rsi, r10
    xor eax, eax
    call printf

    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    call callee

    xor eax, eax
    leave
    ret
