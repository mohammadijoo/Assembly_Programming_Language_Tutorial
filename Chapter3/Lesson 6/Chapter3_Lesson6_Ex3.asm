BITS 64
default rel
%include "Chapter3_Lesson6_Ex1.asm"

global _start

section .rodata
h0: db "Example 2: CF vs OF in 8-bit addition (unsigned carry vs signed overflow)",10
h0_len: equ $-h0

c1: db "Case A: 200 + 100 (0xC8 + 0x64)",10
c1_len: equ $-c1
c2: db "Case B: 120 + 120 (0x78 + 0x78)",10
c2_len: equ $-c2

lab_sum: db "  sum (low 8 bits): ",0
lab_sum_len: equ $-lab_sum-1

lab_cf: db "  CF (unsigned carry-out): ",0
lab_cf_len: equ $-lab_cf-1

lab_of: db "  OF (signed overflow):    ",0
lab_of_len: equ $-lab_of-1

nl: db 10
nl_len: equ 1

section .text
_start:
    WRITE h0, h0_len

    ; ---------------------
    ; Case A
    ; ---------------------
    WRITE c1, c1_len
    mov al, 0xC8
    mov bl, 0x64
    add al, bl
    setc cl
    seto ch

    WRITE lab_sum, lab_sum_len
    movzx eax, al
    call write_hex64

    WRITE lab_cf, lab_cf_len
    movzx eax, cl
    call write_hex64

    WRITE lab_of, lab_of_len
    movzx eax, ch
    call write_hex64

    WRITE nl, nl_len

    ; ---------------------
    ; Case B
    ; ---------------------
    WRITE c2, c2_len
    mov al, 0x78
    mov bl, 0x78
    add al, bl
    setc cl
    seto ch

    WRITE lab_sum, lab_sum_len
    movzx eax, al
    call write_hex64

    WRITE lab_cf, lab_cf_len
    movzx eax, cl
    call write_hex64

    WRITE lab_of, lab_of_len
    movzx eax, ch
    call write_hex64

    EXIT 0
