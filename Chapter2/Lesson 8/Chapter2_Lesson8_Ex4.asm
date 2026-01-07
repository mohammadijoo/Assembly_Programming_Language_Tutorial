;
; Chapter 2 - Lesson 8 - Example 4
; Unsigned comparisons: CMP sets flags as if (a - b); use JB/JA/SETcc.
;
; Build:
;   nasm -felf64 Chapter2_Lesson8_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o

%include "Chapter2_Lesson8_Ex1.asm"

BITS 64
default rel
global _start

section .rodata
h: db "Unsigned compares (a=5, b=250): observe SETcc results",10
h_len: equ $-h

lab_setb: db "setb  (a lt_u b) = ",0
lab_setb_len: equ 20
lab_seta: db "seta  (a gt_u b) = ",0
lab_seta_len: equ 20
lab_setae: db "setae (a ge_u b) = ",0
lab_setae_len: equ 20
lab_setbe: db "setbe (a le_u b) = ",0
lab_setbe_len: equ 20

section .text
_start:
    SYS_WRITE h, h_len

    mov eax, 5
    mov ebx, 250

    ; CMP performs (EAX - EBX) only for flags
    cmp eax, ebx

    lea rsi, [lab_setb]
    mov rdx, lab_setb_len
    call print_str
    setb al
    and eax, 1
    call print_hex64_rax

    cmp eax, eax ; clean flags not needed; demonstrate independent SETcc usage pattern
    ; Recompute CMP because above ops clobbered flags
    mov eax, 5
    mov ebx, 250
    cmp eax, ebx

    lea rsi, [lab_seta]
    mov rdx, lab_seta_len
    call print_str
    seta al
    and eax, 1
    call print_hex64_rax

    mov eax, 5
    mov ebx, 250
    cmp eax, ebx
    lea rsi, [lab_setae]
    mov rdx, lab_setae_len
    call print_str
    setae al
    and eax, 1
    call print_hex64_rax

    mov eax, 5
    mov ebx, 250
    cmp eax, ebx
    lea rsi, [lab_setbe]
    mov rdx, lab_setbe_len
    call print_str
    setbe al
    and eax, 1
    call print_hex64_rax

    SYS_EXIT 0
