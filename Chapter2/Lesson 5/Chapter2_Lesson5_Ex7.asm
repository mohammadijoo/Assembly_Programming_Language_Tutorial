; Chapter 2 - Lesson 5 - Ex7 (Intel syntax, NASM/YASM)
; Demonstrates indirect CALL/JMP and RIP-relative global loads with NASM 'default rel'.
bits 64
default rel

section .data
global funcptr
funcptr: dq 0

section .text
global call_indirect_demo

call_indirect_demo:
    ; Inputs:
    ;   RDI = function pointer: long f(long)
    ;   RSI = argument
    mov rax, rdi
    mov rdi, rsi
    call rax

    ; Jump through global function pointer storage (RIP-relative due to 'default rel')
    jmp qword [funcptr]
