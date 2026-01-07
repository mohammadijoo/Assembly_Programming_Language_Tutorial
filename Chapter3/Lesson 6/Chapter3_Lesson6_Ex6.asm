BITS 64
default rel
%include "Chapter3_Lesson6_Ex1.asm"

global _start

section .rodata
h0: db "Example 5: mixed-width promotion (movzx vs movsx) changes results",10
h0_len: equ $-h0

lab_u: db "Unsigned sum of bytes (zero-extend each): ",0
lab_u_len: equ $-lab_u-1

lab_s: db "Signed sum of bytes (sign-extend each):   ",0
lab_s_len: equ $-lab_s-1

lab_note: db "Array bytes: 0x80, 0x7F, 0xFF, 0x01",10,10
lab_note_len: equ $-lab_note

section .data
arr: db 0x80, 0x7F, 0xFF, 0x01
arr_len: equ 4

section .text
_start:
    WRITE h0, h0_len
    WRITE lab_note, lab_note_len

    ; Unsigned accumulation
    xor eax, eax           ; sum_u in EAX
    xor ecx, ecx
.u_loop:
    movzx edx, byte [arr + rcx]
    add eax, edx
    inc ecx
    cmp ecx, arr_len
    jb .u_loop

    WRITE lab_u, lab_u_len
    movzx rax, eax
    call write_hex64

    ; Signed accumulation
    xor eax, eax           ; sum_s in EAX
    xor ecx, ecx
.s_loop:
    movsx edx, byte [arr + rcx]
    add eax, edx
    inc ecx
    cmp ecx, arr_len
    jb .s_loop

    WRITE lab_s, lab_s_len
    movsxd rax, eax
    call write_hex64

    EXIT 0
