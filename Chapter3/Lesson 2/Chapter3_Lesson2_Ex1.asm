; Chapter 3 - Lesson 2 (Example 1)
; Declaring and using a byte variable (Linux x86-64, NASM)

BITS 64
default rel

section .data
ch      db 'A'
nl      db 10

section .text
global _start

_start:
    ; write initial ch
    mov     eax, 1          ; SYS_write
    mov     edi, 1          ; stdout
    lea     rsi, [ch]
    mov     edx, 1
    syscall

    ; newline
    mov     eax, 1
    mov     edi, 1
    lea     rsi, [nl]
    mov     edx, 1
    syscall

    ; modify variable in memory
    mov     byte [ch], 'Z'

    ; write modified ch
    mov     eax, 1
    mov     edi, 1
    lea     rsi, [ch]
    mov     edx, 1
    syscall

    ; newline
    mov     eax, 1
    mov     edi, 1
    lea     rsi, [nl]
    mov     edx, 1
    syscall

    ; exit(0)
    mov     eax, 60         ; SYS_exit
    xor     edi, edi
    syscall
