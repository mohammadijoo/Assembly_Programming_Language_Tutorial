;
; Chapter 2 - Lesson 8 - Example 5
; Signed comparisons: CMP sets flags; use JL/JG/SETL/SETG (SF and OF interplay).
;
; Build:
;   nasm -felf64 Chapter2_Lesson8_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o

%include "Chapter2_Lesson8_Ex1.asm"

BITS 64
default rel
global _start

section .rodata
h: db "Signed compares (a=-5, b=3): observe SETcc results",10
h_len: equ $-h

lab_setl: db "setl  (a lt_s b) = ",0
lab_setl_len: equ 20
lab_setg: db "setg  (a gt_s b) = ",0
lab_setg_len: equ 20
lab_setge: db "setge (a ge_s b) = ",0
lab_setge_len: equ 20
lab_setle: db "setle (a le_s b) = ",0
lab_setle_len: equ 20

section .text
_start:
    SYS_WRITE h, h_len

    mov eax, -5
    mov ebx, 3
    cmp eax, ebx

    lea rsi, [lab_setl]
    mov rdx, lab_setl_len
    call print_str
    setl al
    and eax, 1
    call print_hex64_rax

    mov eax, -5
    mov ebx, 3
    cmp eax, ebx
    lea rsi, [lab_setg]
    mov rdx, lab_setg_len
    call print_str
    setg al
    and eax, 1
    call print_hex64_rax

    mov eax, -5
    mov ebx, 3
    cmp eax, ebx
    lea rsi, [lab_setge]
    mov rdx, lab_setge_len
    call print_str
    setge al
    and eax, 1
    call print_hex64_rax

    mov eax, -5
    mov ebx, 3
    cmp eax, ebx
    lea rsi, [lab_setle]
    mov rdx, lab_setle_len
    call print_str
    setle al
    and eax, 1
    call print_hex64_rax

    SYS_EXIT 0
