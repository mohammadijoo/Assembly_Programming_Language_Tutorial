; Chapter 6 - Lesson 12 (Example 1)
; Naive recursion (NOT tail-recursive): factorial(n) = n * factorial(n-1)

BITS 64
DEFAULT REL

global _start

section .text

; uint64_t fact_naive(uint64_t n)
;   input : rdi = n
;   output: rax = n!
fact_naive:
    cmp rdi, 1
    jbe .base
    push rdi                ; save n
    dec rdi                 ; n-1
    call fact_naive
    pop rcx                 ; restore n
    imul rax, rcx           ; rax *= n
    ret
.base:
    mov rax, 1
    ret

_start:
    mov rdi, 10             ; n = 10
    call fact_naive
    ; Keep result in RAX for debugging; exit code is low 8 bits
    mov rdi, rax
    mov rax, 60             ; sys_exit
    syscall
