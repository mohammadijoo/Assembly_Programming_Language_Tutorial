; Chapter 3 - Lesson 9
; Ex2: Same bits, different meanings (signed vs unsigned) + sign/zero extension

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
msg0: db "Bit pattern 0xFF as 8-bit unsigned (255): ",0
msg1: db "Bit pattern 0xFF as 8-bit signed (-1):     ",0
msg2: db "Bit pattern 0x80 as 8-bit unsigned (128): ",0
msg3: db "Bit pattern 0x80 as 8-bit signed (-128):  ",0
msg4: db "Zero-extend AL to RAX (MOVZX):            ",0
msg5: db "Sign-extend AL to RAX (MOVSX):            ",0

section .text
_start:
    ; 0xFF
    PRINTZ msg0
    mov al, 0xFF
    movzx rax, al
    call print_u64_nl

    PRINTZ msg1
    mov al, 0xFF
    movsx rax, al
    call print_i64_nl

    ; 0x80
    PRINTZ msg2
    mov al, 0x80
    movzx rax, al
    call print_u64_nl

    PRINTZ msg3
    mov al, 0x80
    movsx rax, al
    call print_i64_nl

    ; Show explicit MOVZX / MOVSX outcomes for the same AL
    mov al, 0xF6                ; 0xF6 = 246 unsigned, -10 signed

    PRINTZ msg4
    movzx rax, al
    call print_hex64_nl          ; expect 0x000...00F6

    PRINTZ msg5
    movsx rax, al
    call print_hex64_nl          ; expect 0xFFF...FFF6

    jmp exit0
