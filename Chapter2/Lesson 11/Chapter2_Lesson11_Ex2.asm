; Demonstrates: section .data, labels, equ, and referencing labels from .text

BITS 64
global _start

SYS_write equ 1
SYS_exit  equ 60
STDOUT    equ 1

section .data
msg:        db "Hello from Chapter 2 / Lesson 11", 10
msg_len:    equ $ - msg          ; assembler-time length

section .text
_start:
    ; write(STDOUT, msg, msg_len)
    mov     eax, SYS_write
    mov     edi, STDOUT
    lea     rsi, [rel msg]
    mov     edx, msg_len
    syscall

    ; exit(0)
    mov     eax, SYS_exit
    xor     edi, edi
    syscall
