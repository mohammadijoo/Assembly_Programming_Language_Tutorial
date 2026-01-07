;
; Chapter 2 - Lesson 8 - Example 8
; INC/DEC do NOT affect CF. Demonstrate by forcing CF=1 then INC.
;
; Build:
;   nasm -felf64 Chapter2_Lesson8_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o

%include "Chapter2_Lesson8_Ex1.asm"

BITS 64
default rel
global _start

section .rodata
h: db "INC preserves CF: set CF=1 with STC, then INC and observe",10
h_len: equ $-h
lab_before: db "Before INC: ",0
lab_before_len: equ 12
lab_after: db "After  INC: ",0
lab_after_len: equ 12

section .text
_start:
    SYS_WRITE h, h_len

    stc                 ; CF=1
    mov rax, 41
    pushfq
    pop rbx
    lea rsi, [lab_before]
    mov rdx, lab_before_len
    call print_str
    mov rax, rbx
    call dump_flags_basic

    inc rax             ; affects ZF/SF/OF/AF/PF, but not CF
    pushfq
    pop rbx
    lea rsi, [lab_after]
    mov rdx, lab_after_len
    call print_str
    mov rax, rbx
    call dump_flags_basic

    SYS_EXIT 0
