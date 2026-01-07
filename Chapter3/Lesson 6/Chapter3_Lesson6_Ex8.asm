BITS 64
default rel
%include "Chapter3_Lesson6_Ex1.asm"

global _start

; Exercise 2 (Solution): unsigned 128-bit addition using carry chains.
; Adds A and B (each 128-bit little-endian: low qword first).

section .rodata
h0: db "Exercise 2 Solution: 128-bit unsigned addition (ADD/ADC carry chain)",10
h0_len: equ $-h0

lab_a0: db "  A.low : ",0
lab_a0_len: equ $-lab_a0-1
lab_a1: db "  A.high: ",0
lab_a1_len: equ $-lab_a1-1

lab_b0: db "  B.low : ",0
lab_b0_len: equ $-lab_b0-1
lab_b1: db "  B.high: ",0
lab_b1_len: equ $-lab_b1-1

lab_s0: db "  S.low : ",0
lab_s0_len: equ $-lab_s0-1
lab_s1: db "  S.high: ",0
lab_s1_len: equ $-lab_s1-1

lab_c:  db "  carry-out (CF): ",0
lab_c_len: equ $-lab_c-1

section .data
A: dq 0xFFFFFFFFFFFFFFFF, 0x0000000000000001
B: dq 0x0000000000000002, 0x0000000000000003
S: dq 0, 0

section .text
_start:
    WRITE h0, h0_len

    ; Print A and B
    WRITE lab_a0, lab_a0_len
    mov rax, [A+0]
    call write_hex64
    WRITE lab_a1, lab_a1_len
    mov rax, [A+8]
    call write_hex64

    WRITE lab_b0, lab_b0_len
    mov rax, [B+0]
    call write_hex64
    WRITE lab_b1, lab_b1_len
    mov rax, [B+8]
    call write_hex64

    ; Compute S = A + B (128-bit)
    mov rax, [A+0]
    add rax, [B+0]
    mov [S+0], rax

    mov rax, [A+8]
    adc rax, [B+8]
    mov [S+8], rax

    setc cl   ; carry-out beyond 128 bits (0 or 1)

    ; Print S and carry-out
    WRITE lab_s0, lab_s0_len
    mov rax, [S+0]
    call write_hex64
    WRITE lab_s1, lab_s1_len
    mov rax, [S+8]
    call write_hex64

    WRITE lab_c, lab_c_len
    movzx eax, cl
    call write_hex64

    EXIT 0
