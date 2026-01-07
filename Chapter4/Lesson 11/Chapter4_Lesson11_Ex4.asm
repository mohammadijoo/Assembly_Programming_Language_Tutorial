; Chapter 4 - Lesson 11 (Example 4)
; CMOVcc: branchless min/max for signed 64-bit integers.
; Output:
;   line1: min(a,b)
;   line2: max(a,b)

bits 64
default rel
%include "Chapter4_Lesson11_Ex8.asm"

section .text
global _start

_start:
    mov rax, -7
    mov rbx, 3

    mov r8, rax      ; min candidate
    mov r9, rbx      ; max candidate

    cmp rax, rbx
    cmovg r8, rbx    ; if a > b, min = b
    cmovg r9, rax    ; if a > b, max = a

    mov rdi, r8
    call print_hex_u64
    mov rdi, r9
    call print_hex_u64

    EXIT 0
