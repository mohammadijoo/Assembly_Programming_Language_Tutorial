; Chapter 6 - Lesson 6 (Calling Conventions Overview)
; Example 3: SysV AMD64 - calling a C library function (puts) (Linux ELF64)
; Build (Linux, with libc):
;   nasm -felf64 Chapter6_Lesson6_Ex3.asm -o ex3.o
;   gcc -no-pie -o ex3 ex3.o
; Run:
;   ./ex3

BITS 64
DEFAULT REL
GLOBAL main
EXTERN puts

SECTION .rodata
msg db "Hello from SysV AMD64 via puts()", 0

SECTION .text
main:
    ; Typical System V prologue. We also align before calling puts.
    push rbp
    mov rbp, rsp

    ; After push rbp, RSP is 8 mod 16. Subtract 8 so RSP becomes 0 mod 16
    ; before the CALL instruction.
    sub rsp, 8

    lea rdi, [msg]          ; first arg in RDI
    call puts

    add rsp, 8
    xor eax, eax            ; return 0
    pop rbp
    ret
