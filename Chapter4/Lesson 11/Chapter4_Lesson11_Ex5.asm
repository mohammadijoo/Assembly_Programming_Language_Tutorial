; Chapter 4 - Lesson 11 (Example 5)
; CMOVcc: clamp x into [lo, hi] without branches:
;   x = max(x, lo); x = min(x, hi)  (for signed values)
; Output:
;   line1: clamped x

bits 64
default rel
%include "Chapter4_Lesson11_Ex8.asm"

section .text
global _start

_start:
    mov rax, 150     ; x
    mov rbx, -10     ; lo
    mov rcx, 100     ; hi

    cmp rax, rbx
    cmovl rax, rbx   ; if x < lo, x = lo

    cmp rax, rcx
    cmovg rax, rcx   ; if x > hi, x = hi

    mov rdi, rax
    call print_hex_u64

    EXIT 0
