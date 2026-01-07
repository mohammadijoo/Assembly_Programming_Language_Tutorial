;
; Chapter 2 - Lesson 8 - Example 7
; Multi-precision addition with ADC (128-bit add on 64-bit machine).
;
; Build:
;   nasm -felf64 Chapter2_Lesson8_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o

%include "Chapter2_Lesson8_Ex1.asm"

BITS 64
default rel
global _start

section .rodata
h: db "128-bit addition: (A_hi:A_lo) + (B_hi:B_lo)",10
h_len: equ $-h
lab_sum_lo: db "sum_lo = ",0
lab_sum_lo_len: equ 9
lab_sum_hi: db "sum_hi = ",0
lab_sum_hi_len: equ 9
lab_cf: db "final CF (carry out of high limb) = ",0
lab_cf_len: equ 37

section .text
_start:
    SYS_WRITE h, h_len
    ; A = 0x0000000000000001_FFFFFFFFFFFFFFFF
    mov rdx, 0x0000000000000001
    mov rax, 0xFFFFFFFFFFFFFFFF
    ; B = 0x0000000000000002_0000000000000005
    mov rcx, 0x0000000000000002
    mov rbx, 0x0000000000000005

    ; sum = A + B (little-endian limb order: low then high)
    add rax, rbx
    adc rdx, rcx

    lea rsi, [lab_sum_lo]
    mov rdx, lab_sum_lo_len
    call print_str
    call print_hex64_rax

    lea rsi, [lab_sum_hi]
    mov rdx, lab_sum_hi_len
    call print_str
    mov rax, rdx
    call print_hex64_rax

    ; carry out (CF) after high limb is current CF
    pushfq
    pop r8
    lea rsi, [lab_cf]
    mov rdx, lab_cf_len
    call print_str
    bt r8, 0
    setc al
    and eax, 1
    call print_hex64_rax

    SYS_EXIT 0
