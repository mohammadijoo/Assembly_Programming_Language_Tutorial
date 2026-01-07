;
; Chapter 2 - Lesson 8 - Example 2
; Capturing RFLAGS with PUSHFQ/POPFQ after arithmetic and printing key flags.
;
; Build:
;   nasm -felf64 Chapter2_Lesson8_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
; Run:
;   ./ex2

%include "Chapter2_Lesson8_Ex1.asm"

BITS 64
default rel
global _start

section .rodata
t1: db "Case A: 0x7FFF..FFF + 1 (signed overflow expected)",10
t1_len: equ $-t1
t2: db "Case B: 0xFFFF..FFF + 1 (carry and zero expected)",10
t2_len: equ $-t2
t3: db "Case C: 0 - 1 (borrow expected)",10
t3_len: equ $-t3
lab_rflags: db "RFLAGS = ",0
lab_rflags_len: equ 9

section .text
_start:
    ; ---- Case A: INT64_MAX + 1 => OF=1, SF=1, CF=0
    SYS_WRITE t1, t1_len
    mov rax, 0x7FFFFFFFFFFFFFFF
    add rax, 1
    pushfq
    pop rbx

    SYS_WRITE lab_rflags, lab_rflags_len
    mov rax, rbx
    call print_hex64_rax
    mov rax, rbx
    call dump_flags_basic
    call print_nl

    ; ---- Case B: -1 + 1 => ZF=1, CF=1
    SYS_WRITE t2, t2_len
    mov rax, 0xFFFFFFFFFFFFFFFF
    add rax, 1
    pushfq
    pop rbx

    SYS_WRITE lab_rflags, lab_rflags_len
    mov rax, rbx
    call print_hex64_rax
    mov rax, rbx
    call dump_flags_basic
    call print_nl

    ; ---- Case C: 0 - 1 => CF=1 (borrow), SF=1
    SYS_WRITE t3, t3_len
    xor rax, rax
    sub rax, 1
    pushfq
    pop rbx

    SYS_WRITE lab_rflags, lab_rflags_len
    mov rax, rbx
    call print_hex64_rax
    mov rax, rbx
    call dump_flags_basic

    SYS_EXIT 0
