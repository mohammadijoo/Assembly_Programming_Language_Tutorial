;
; Chapter 2 - Lesson 8 - Example 9
; Shifts and rotates: observing CF and (for count=1) OF behavior.
;
; Build:
;   nasm -felf64 Chapter2_Lesson8_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o

%include "Chapter2_Lesson8_Ex1.asm"

BITS 64
default rel
global _start

section .rodata
h: db "Shift/rotate flag effects",10
h_len: equ $-h
c1: db "1) SHL by 1, input has top bit set",10
c1_len: equ $-c1
c2: db "2) SHR by 1, input has low bit set",10
c2_len: equ $-c2
c3: db "3) ROL by 1, observe CF",10
c3_len: equ $-c3
lab_res: db "Result  = ",0
lab_res_len: equ 9
lab_rfl: db "Flags   : ",0
lab_rfl_len: equ 9

section .text
_start:
    SYS_WRITE h, h_len
    call print_nl

    ; 1) SHL
    SYS_WRITE c1, c1_len
    mov rax, 0x8000000000000000
    shl rax, 1
    lea rsi, [lab_res]
    mov rdx, lab_res_len
    call print_str
    call print_hex64_rax
    pushfq
    pop rbx
    lea rsi, [lab_rfl]
    mov rdx, lab_rfl_len
    call print_str
    mov rax, rbx
    call dump_flags_basic
    call print_nl

    ; 2) SHR
    SYS_WRITE c2, c2_len
    mov rax, 1
    shr rax, 1
    lea rsi, [lab_res]
    mov rdx, lab_res_len
    call print_str
    call print_hex64_rax
    pushfq
    pop rbx
    lea rsi, [lab_rfl]
    mov rdx, lab_rfl_len
    call print_str
    mov rax, rbx
    call dump_flags_basic
    call print_nl

    ; 3) ROL
    SYS_WRITE c3, c3_len
    mov rax, 0x8000000000000001
    rol rax, 1
    lea rsi, [lab_res]
    mov rdx, lab_res_len
    call print_str
    call print_hex64_rax
    pushfq
    pop rbx
    lea rsi, [lab_rfl]
    mov rdx, lab_rfl_len
    call print_str
    mov rax, rbx
    call dump_flags_basic

    SYS_EXIT 0
