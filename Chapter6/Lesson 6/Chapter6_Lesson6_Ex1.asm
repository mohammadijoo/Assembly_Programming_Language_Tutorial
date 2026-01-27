; Chapter 6 - Lesson 6 (Calling Conventions Overview)
; Example 1: SysV AMD64 - register arguments and RAX return (Linux ELF64)
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson6_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
; Run:
;   ./ex1 ; exit status is (7+11+13)&255

BITS 64
DEFAULT REL
GLOBAL _start

SECTION .text

; int64 sum3(int64 a, int64 b, int64 c)
; SysV AMD64: a=RDI, b=RSI, c=RDX, return=RAX
sum3:
    lea rax, [rdi + rsi]
    add rax, rdx
    ret

_start:
    mov rdi, 7
    mov rsi, 11
    mov rdx, 13
    call sum3

    ; Linux x86-64 exit(status)
    mov rdi, rax
    and rdi, 255
    mov eax, 60
    syscall
