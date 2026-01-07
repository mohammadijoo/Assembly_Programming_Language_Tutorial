;
; Chapter 2 - Lesson 8 - Example 13 (Exercise Solution 3)
; Very hard: multi-limb subtraction using SBB across arrays (little-endian qword limbs).
;
; sub_big(out, a, b, n_qwords):
;   out[i] = a[i] - b[i] for i in [0..n-1], with borrow chain
;   returns AL = final borrow (1 if a < b as unsigned big-int)
;
; Inputs:
;   RDI = out pointer
;   RSI = a pointer
;   RDX = b pointer
;   RCX = n_qwords
; Output:
;   AL  = borrow
;
; Build:
;   nasm -felf64 Chapter2_Lesson8_Ex13.asm -o ex13.o
;   ld -o ex13 ex13.o

%include "Chapter2_Lesson8_Ex1.asm"

BITS 64
default rel
global _start

section .rodata
h: db "sub_big demo: subtracting 4-limb values and printing out[0] and final borrow",10
h_len: equ $-h
lab_out0: db "out[0] = ",0
lab_out0_len: equ 9
lab_borrow: db "final borrow = ",0
lab_borrow_len: equ 15

section .data
a: dq 0x0000000000000000, 0x0000000000000000, 0x0000000000000001, 0x0000000000000000
b: dq 0x0000000000000001, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000
out: dq 0,0,0,0

section .text
sub_big:
    ; CF is the borrow-in for SBB; clear it for initial limb
    clc
.loop:
    mov rax, [rsi]
    sbb rax, [rdx]
    mov [rdi], rax

    add rsi, 8
    add rdx, 8
    add rdi, 8
    dec rcx
    jnz .loop

    ; CF now is final borrow
    setc al
    ret

_start:
    SYS_WRITE h, h_len

    lea rdi, [out]
    lea rsi, [a]
    lea rdx, [b]
    mov rcx, 4
    call sub_big

    ; print out[0]
    lea rsi, [lab_out0]
    mov rdx, lab_out0_len
    call print_str
    mov rax, [out]
    call print_hex64_rax

    ; print borrow
    lea rsi, [lab_borrow]
    mov rdx, lab_borrow_len
    call print_str
    movzx eax, al
    call print_hex64_rax

    SYS_EXIT 0
