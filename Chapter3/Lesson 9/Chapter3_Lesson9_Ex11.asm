; Chapter 3 - Lesson 9
; Ex11: SAR vs SHR (arithmetic vs logical right shift) on negative values

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
hdr:  db "SAR vs SHR demo:",10,0
p1:   db "Start with RAX = -2",10,0
lbl0: db "  RAX (hex): ",0
lbl1: db "  SAR 1  (signed divide by 2, rounds toward -inf): ",0
lbl2: db "  SHR 1  (logical shift, fills with zeros):       ",0

section .text
_start:
    PRINTZ hdr
    PRINTZ p1

    mov rax, -2
    PRINTZ lbl0
    call print_hex64_nl

    mov rax, -2
    sar rax, 1
    PRINTZ lbl1
    call print_i64_nl

    mov rax, -2
    shr rax, 1
    PRINTZ lbl2
    call print_hex64_nl

    jmp exit0
