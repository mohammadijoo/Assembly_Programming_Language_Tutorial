; Chapter 2 - Lesson 5 - Ex9 (Intel syntax, NASM/YASM)
; Demonstrates common NASM directives: %define, equ, db, times, global, section.
bits 64
default rel

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
msg: db "Intel syntax: directives demo", 10
msg_len equ $ - msg

pad: times 16 db 0x90

section .text
global _start

_start:
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [msg]
    mov edx, msg_len
    syscall

    mov eax, SYS_exit
    xor edi, edi
    syscall
