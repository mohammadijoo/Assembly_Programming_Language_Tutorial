; Chapter 2 - Lesson 5 - Ex18 (Intel syntax, NASM/YASM)
; Demonstrates NASM macro style and the idea of "header-like" include files.
; In a real project, you would move the %define/%macro blocks into a separate .inc file
; and import it with: %include "asm_common.inc"
bits 64
default rel

%define SYS_write 1
%define STDOUT    1

%macro SYSCALL3 4
    ; SYSCALL3 nr, arg1, arg2, arg3 (SysV Linux x86-64 syscall ABI)
    mov eax, %1
    mov edi, %2
    mov rsi, %3
    mov edx, %4
    syscall
%endmacro

section .data
msg: db "NASM macro demo: write(1, msg, len)", 10
len equ $ - msg

section .text
global _start

_start:
    SYSCALL3 SYS_write, STDOUT, msg, len
    ; fall through into an infinite loop for debugging convenience
.hang:
    jmp .hang
