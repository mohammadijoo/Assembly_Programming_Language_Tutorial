; hello.asm (NASM syntax, Linux x86-64)
; Build:
;   nasm -f elf64 hello.asm -o hello.o
;   ld -o hello hello.o
; Run:
;   ./hello

BITS 64

section .data
    msg     db  "Hello from x86-64 assembly!", 10
    msg_len equ $ - msg

section .text
global _start

_start:
    ; write(1, msg, msg_len)
    mov     eax, 1              ; SYS_write = 1 (EAX zero-extends into RAX)
    mov     edi, 1              ; fd = 1 (stdout)
    lea     rsi, [rel msg]      ; buffer address (RIP-relative)
    mov     edx, msg_len        ; count (32-bit is enough here; zero-extends)
    syscall

    ; exit(0)
    mov     eax, 60             ; SYS_exit = 60
    xor     edi, edi            ; status = 0
    syscall
