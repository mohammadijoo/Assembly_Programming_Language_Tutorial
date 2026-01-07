BITS 64
default rel
%include "Chapter3_Lesson8_Ex3.asm"

; Demonstrating NASM numeric literal forms that represent the same value.
VAL_DEC  equ 42
VAL_DEC2 equ 42d
VAL_HEX  equ 0x2A
VAL_HEX2 equ 02Ah
VAL_BIN  equ 0b101010
VAL_BIN2 equ 101010b
VAL_OCT  equ 52o

section .rodata
title db "Chapter 3 Lesson 8: Numeric literal equivalence in NASM",10,0
l1    db "VAL_DEC  (42, 42d)            = ",0
l2    db "VAL_HEX  (0x2A, 02Ah)         = ",0
l3    db "VAL_BIN  (0b101010, 101010b)  = ",0
l4    db "VAL_OCT  (52o)                = ",0
l5    db "XOR check (should be 0): VAL_DEC XOR VAL_HEX XOR VAL_BIN = ",0
l6    db "Now the same value printed in hex and binary (bit-level view):",10,0
sep   db "  ",0

section .text
global _start

_start:
    mov rdi, STDOUT
    lea rsi, [title]
    call print_cstr

    mov rdi, STDOUT
    lea rsi, [l1]
    call print_cstr
    mov rdi, VAL_DEC
    call print_dec_u64
    call print_nl

    mov rdi, STDOUT
    lea rsi, [l2]
    call print_cstr
    mov rdi, VAL_HEX
    call print_dec_u64
    call print_nl

    mov rdi, STDOUT
    lea rsi, [l3]
    call print_cstr
    mov rdi, VAL_BIN
    call print_dec_u64
    call print_nl

    mov rdi, STDOUT
    lea rsi, [l4]
    call print_cstr
    mov rdi, VAL_OCT
    call print_dec_u64
    call print_nl

    mov rdi, STDOUT
    lea rsi, [l5]
    call print_cstr
    mov rax, VAL_DEC
    xor rax, VAL_HEX
    xor rax, VAL_BIN
    mov rdi, rax
    call print_hex64
    call print_nl

    mov rdi, STDOUT
    lea rsi, [l6]
    call print_cstr

    ; Show the same value through two standard debugging notations.
    mov rdi, STDOUT
    lea rsi, [sep]
    call print_cstr
    mov rdi, VAL_DEC
    call print_hex64
    call print_nl

    mov rdi, STDOUT
    lea rsi, [sep]
    call print_cstr
    mov rdi, VAL_DEC
    call print_bin64
    call print_nl

    mov eax, SYS_exit
    xor edi, edi
    syscall
