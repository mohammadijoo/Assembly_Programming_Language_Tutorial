; Chapter 4 - Lesson 5 (Exercise Solution)
; File: Chapter4_Lesson5_Ex11.asm
; Task: Compare two 128-bit unsigned integers (hi:lo) and return -1/0/+1.
; Build:
;   nasm -felf64 Chapter4_Lesson5_Ex11.asm -o ex11.o
;   ld ex11.o -o ex11

%include "Chapter4_Lesson5_Ex1.asm"

global _start

section .data
A_hi: dq 0x0000000000000001
A_lo: dq 0x0000000000000000

B_hi: dq 0x0000000000000000
B_lo: dq 0xFFFFFFFFFFFFFFFF

msg_lt: db "A < B (u128)", 10, 0
msg_eq: db "A == B (u128)", 10, 0
msg_gt: db "A > B (u128)", 10, 0

section .text
; int64 u128_cmp( rsi=&A_hi, rdi=&B_hi ) -> rax in {-1,0,+1}
; layout: [0]=hi, [8]=lo
u128_cmp:
    mov rax, [rsi]         ; A_hi
    mov rbx, [rdi]         ; B_hi
    cmp rax, rbx
    jne .hi_diff

    mov rax, [rsi+8]       ; A_lo
    mov rbx, [rdi+8]       ; B_lo
    cmp rax, rbx
    je .eq
    jb .lt
    ja .gt

.hi_diff:
    jb .lt
    ja .gt

.eq:
    xor eax, eax
    ret
.gt:
    mov eax, 1
    ret
.lt:
    mov eax, -1
    cdqe
    ret

_start:
    lea rsi, [rel A_hi]
    lea rdi, [rel B_hi]
    call u128_cmp

    cmp rax, 0
    je .print_eq
    jl .print_lt
    jg .print_gt

.print_eq:
    lea rsi, [rel msg_eq]
    call print_cstr
    SYS_EXIT 0
.print_lt:
    lea rsi, [rel msg_lt]
    call print_cstr
    SYS_EXIT 0
.print_gt:
    lea rsi, [rel msg_gt]
    call print_cstr
    SYS_EXIT 0
