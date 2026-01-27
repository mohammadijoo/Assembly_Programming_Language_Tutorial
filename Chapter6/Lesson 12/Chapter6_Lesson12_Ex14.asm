; Chapter 6 - Lesson 12 (Exercise 3 - Solution)
; Tail-call with stack-passed args (8 total) reusing caller-provided stack slots.

BITS 64
DEFAULT REL

global _start

section .text

g8_sum:
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    add rax, rcx
    add rax, r8
    add rax, r9
    add rax, [rsp + 8]
    add rax, [rsp + 16]
    ret

f8_affine:
    ; a1 = 3*a1 + 5
    lea rdi, [rdi + 2*rdi]
    add rdi, 5
    jmp g8_sum

_start:
    mov rdi, 1
    mov rsi, 2
    mov rdx, 3
    mov rcx, 4
    mov r8,  5
    mov r9,  6
    push 8
    push 7
    call f8_affine
    add rsp, 16

    mov rdi, rax
    mov rax, 60
    syscall
