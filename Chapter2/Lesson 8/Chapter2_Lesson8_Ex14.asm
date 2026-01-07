;
; Chapter 2 - Lesson 8 - Example 14 (Exercise Solution 4)
; Very hard: compute absolute difference |a-b| and return a_ge_b flag, branchlessly using borrow.
;
; absdiff_u64(a,b):
;   diff = |a-b|
;   ge   = 1 if a >= b (unsigned), else 0
;
; Demo-only calling:
;   RDI=a, RSI=b
;   Returns:
;     RAX = diff
;     DL  = ge
;
; Build:
;   nasm -felf64 Chapter2_Lesson8_Ex14.asm -o ex14.o
;   ld -o ex14 ex14.o

%include "Chapter2_Lesson8_Ex1.asm"

BITS 64
default rel
global _start

section .rodata
h: db "absdiff_u64 demo: |a-b| and ge flag printed as hex",10
h_len: equ $-h
lab_diff: db "diff = ",0
lab_diff_len: equ 7
lab_ge: db "ge   = ",0
lab_ge_len: equ 7

section .text
absdiff_u64:
    mov rax, rdi
    sub rax, rsi          ; rax = a - b (wraps); CF=1 if borrow (a < b)

    ; mask = 0xFFFF..FFFF if borrow else 0
    sbb rdx, rdx

    ; diff = (a-b) xor mask - mask  (two's complement abs using mask)
    xor rax, rdx
    sub rax, rdx

    ; ge = 1 if no borrow => CF=0. Since mask is -1 on borrow, ge is (mask == 0)
    ; Use SETZ on mask after test.
    test rdx, rdx
    setz dl
    ret

_start:
    SYS_WRITE h, h_len

    ; Case: a < b
    mov rdi, 5
    mov rsi, 100
    call absdiff_u64
    lea rsi, [lab_diff]
    mov rdx, lab_diff_len
    call print_str
    call print_hex64_rax
    lea rsi, [lab_ge]
    mov rdx, lab_ge_len
    call print_str
    movzx eax, dl
    call print_hex64_rax

    SYS_EXIT 0
