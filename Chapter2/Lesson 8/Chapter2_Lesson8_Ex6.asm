;
; Chapter 2 - Lesson 8 - Example 6
; CMOVcc for branchless selection (signed vs unsigned variants).
;
; Build:
;   nasm -felf64 Chapter2_Lesson8_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o

%include "Chapter2_Lesson8_Ex1.asm"

BITS 64
default rel
global _start

section .rodata
h: db "Branchless min selection",10
h_len: equ $-h
m1: db "Signed min of a=-10 and b=7",10
m1_len: equ $-m1
m2: db "Unsigned min of a=0xFFFFFFFFFFFFFFF0 and b=7",10
m2_len: equ $-m2
lab_min: db "min = ",0
lab_min_len: equ 6

section .text
_start:
    SYS_WRITE h, h_len
    call print_nl

    ; ---- Signed min
    SYS_WRITE m1, m1_len
    mov rax, -10
    mov rbx, 7
    mov rcx, rax          ; rcx = candidate min (a)
    cmp rax, rbx
    cmovg rcx, rbx        ; if a > b (signed), min = b
    lea rsi, [lab_min]
    mov rdx, lab_min_len
    call print_str
    mov rax, rcx
    call print_hex64_rax
    call print_nl

    ; ---- Unsigned min (note: a is "huge" as unsigned)
    SYS_WRITE m2, m2_len
    mov rax, 0xFFFFFFFFFFFFFFF0
    mov rbx, 7
    mov rcx, rax
    cmp rax, rbx
    cmova rcx, rbx        ; if a > b (unsigned), min = b
    lea rsi, [lab_min]
    mov rdx, lab_min_len
    call print_str
    mov rax, rcx
    call print_hex64_rax

    SYS_EXIT 0
