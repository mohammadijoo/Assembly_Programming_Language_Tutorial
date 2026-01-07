; Chapter 3 - Lesson 9 (Programming Exercises with Solutions)
; Ex14 (Exercise 2 Solution):
;   Generic sign extension of an n-bit two's complement integer stored in low bits.
;
; Contract:
;   Inputs:  RAX = x (only low n bits are meaningful)
;            CL  = n (1..63)
;   Output:  RAX = sign-extended to 64-bit
;
; Technique:
;   shift = 64 - n
;   (x << shift) >>arith shift

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
hdr: db "Exercise 2: sign_extend_nbits via shifts",10,0
t1:  db "Test 1: n=12, x=0x7FF (expected +2047)",10,0
t2:  db 10,"Test 2: n=12, x=0x800 (expected -2048)",10,0
t3:  db 10,"Test 3: n=5,  x=0x1F (expected -1)",10,0
t4:  db 10,"Test 4: n=5,  x=0x0F (expected +15)",10,0
lbl_in:  db "  input bits (hex): ",0
lbl_out: db "  sign-extended (i64): ",0

section .text

sign_extend_nbits:
    ; RAX=x, CL=n
    mov r8b, cl                  ; save n
    mov cl, 64
    sub cl, r8b                  ; CL = shift = 64 - n
    shl rax, cl
    sar rax, cl
    ret

show:
    ; Inputs: RAX=x, CL=n
    PRINTZ lbl_in
    call print_hex64_nl

    call sign_extend_nbits

    PRINTZ lbl_out
    call print_i64_nl
    ret

_start:
    PRINTZ hdr

    PRINTZ t1
    mov rax, 0x7FF
    mov cl, 12
    call show

    PRINTZ t2
    mov rax, 0x800
    mov cl, 12
    call show

    PRINTZ t3
    mov rax, 0x1F
    mov cl, 5
    call show

    PRINTZ t4
    mov rax, 0x0F
    mov cl, 5
    call show

    jmp exit0
