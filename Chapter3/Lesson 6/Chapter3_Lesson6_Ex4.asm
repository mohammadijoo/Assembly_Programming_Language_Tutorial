BITS 64
default rel
%include "Chapter3_Lesson6_Ex1.asm"

global _start

section .rodata
h0: db "Example 3: MUL vs IMUL (same bits, different algebra)",10
h0_len: equ $-h0

lab_a: db "  multiplicand bits (AL): ",0
lab_a_len: equ $-lab_a-1

lab_b: db "  multiplier bits (BL):   ",0
lab_b_len: equ $-lab_b-1

lab_mul:  db "  unsigned MUL result (AX): ",0
lab_mul_len: equ $-lab_mul-1

lab_imul: db "  signed IMUL result (AX):  ",0
lab_imul_len: equ $-lab_imul-1

lab_cf: db "  CF after op: ",0
lab_cf_len: equ $-lab_cf-1

lab_of: db "  OF after op: ",0
lab_of_len: equ $-lab_of-1

nl: db 10
nl_len: equ 1

section .text
_start:
    WRITE h0, h0_len

    mov al, 0xFD              ; bits for -3 (signed) or 253 (unsigned)
    mov bl, 7

    WRITE lab_a, lab_a_len
    movzx eax, al
    call write_hex64

    WRITE lab_b, lab_b_len
    movzx eax, bl
    call write_hex64

    ; ---------------------
    ; Unsigned MUL (AL * BL -> AX)
    ; ---------------------
    mov al, 0xFD
    mul bl
    setc cl
    seto ch

    WRITE lab_mul, lab_mul_len
    movzx eax, ax
    call write_hex64

    WRITE lab_cf, lab_cf_len
    movzx eax, cl
    call write_hex64

    WRITE lab_of, lab_of_len
    movzx eax, ch
    call write_hex64

    WRITE nl, nl_len

    ; ---------------------
    ; Signed IMUL (AL * BL -> AX)
    ; ---------------------
    mov al, 0xFD
    imul bl
    setc cl
    seto ch

    WRITE lab_imul, lab_imul_len
    movzx eax, ax
    call write_hex64

    WRITE lab_cf, lab_cf_len
    movzx eax, cl
    call write_hex64

    WRITE lab_of, lab_of_len
    movzx eax, ch
    call write_hex64

    EXIT 0
