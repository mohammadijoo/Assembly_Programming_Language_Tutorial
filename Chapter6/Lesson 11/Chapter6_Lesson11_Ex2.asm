; Chapter 6 - Lesson 11, Example 2
; File: Chapter6_Lesson11_Ex2.asm
; Topic: True leaf function (no stack frame, no calls), register-only work
; Build:
;   nasm -felf64 Chapter6_Lesson11_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
; Run:
;   ./ex2 ; exit code should be (10+20+30)=60

global _start

section .text

; int64_t add3_leaf(int64_t a, int64_t b, int64_t c)
; a in RDI, b in RSI, c in RDX, return in RAX
add3_leaf:
    lea rax, [rdi + rsi]   ; rax = a + b
    add rax, rdx           ; rax = a + b + c
    ret

_start:
    mov rdi, 10
    mov rsi, 20
    mov rdx, 30
    call add3_leaf

    ; exit(status = RAX & 0xFF)
    mov edi, eax
    mov eax, 60
    syscall
