;
; Chapter 2 - Lesson 8 - Example 12 (Exercise Solution 2)
; Very hard: signed 64-bit saturating add using OF and CMOVO (overflow-aware, branchless selection).
;
; sat_add_s64(a,b):
;   returns a+b, but if signed overflow occurs, clamps to INT64_MAX or INT64_MIN.
;
; Calling convention (SysV AMD64, simplified for demo):
;   Input: RDI=a, RSI=b
;   Output: RAX=result
;
; Build:
;   nasm -felf64 Chapter2_Lesson8_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o

%include "Chapter2_Lesson8_Ex1.asm"

BITS 64
default rel
global _start

section .rodata
h: db "sat_add_s64 demo: printing results as hex",10
h_len: equ $-h
lab1: db "1) INT64_MAX + 1 => clamp to INT64_MAX",10
lab1_len: equ $-lab1
lab2: db "2) INT64_MIN + (-1) => clamp to INT64_MIN",10
lab2_len: equ $-lab2
lab3: db "3) 100 + (-7) => 93",10
lab3_len: equ $-lab3
lab_res: db "result = ",0
lab_res_len: equ 9

section .text
sat_add_s64:
    mov rax, rdi
    mov rcx, rdi          ; preserve a for sign decision
    add rax, rsi          ; sets OF on signed overflow

    ; sat = (a is negative) ? INT64_MIN : INT64_MAX
    mov rdx, 0x7FFFFFFFFFFFFFFF
    mov r8,  0x8000000000000000
    test rcx, rcx
    cmovs rdx, r8

    ; If overflow, select saturation value
    cmovo rax, rdx
    ret

_start:
    SYS_WRITE h, h_len
    call print_nl

    SYS_WRITE lab1, lab1_len
    mov rdi, 0x7FFFFFFFFFFFFFFF
    mov rsi, 1
    call sat_add_s64
    lea rsi, [lab_res]
    mov rdx, lab_res_len
    call print_str
    call print_hex64_rax
    call print_nl

    SYS_WRITE lab2, lab2_len
    mov rdi, 0x8000000000000000
    mov rsi, -1
    call sat_add_s64
    lea rsi, [lab_res]
    mov rdx, lab_res_len
    call print_str
    call print_hex64_rax
    call print_nl

    SYS_WRITE lab3, lab3_len
    mov rdi, 100
    mov rsi, -7
    call sat_add_s64
    lea rsi, [lab_res]
    mov rdx, lab_res_len
    call print_str
    call print_hex64_rax

    SYS_EXIT 0
