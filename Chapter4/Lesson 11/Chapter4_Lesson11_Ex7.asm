; Chapter 4 - Lesson 11 (Example 7)
; Conditional swap (compare-swap) using CMOV for signed 64-bit integers.
; If a > b then swap so that a <= b.
; Output:
;   line1: a' (min)
;   line2: b' (max)

bits 64
default rel
%include "Chapter4_Lesson11_Ex8.asm"

section .text
global _start

_start:
    mov rcx, 42
    mov rdx, -13

    ; compare-swap in registers using CMOV
    mov rax, rcx
    mov rbx, rdx
    cmp rcx, rdx
    cmovg rax, rdx          ; if rcx > rdx, rax = rdx (min)
    cmovg rbx, rcx          ; if rcx > rdx, rbx = rcx (max)

    mov rdi, rax
    call print_hex_u64
    mov rdi, rbx
    call print_hex_u64

    EXIT 0
