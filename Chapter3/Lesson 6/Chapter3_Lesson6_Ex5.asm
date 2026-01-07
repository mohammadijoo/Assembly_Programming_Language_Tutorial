BITS 64
default rel
%include "Chapter3_Lesson6_Ex1.asm"

global _start

section .rodata
h0: db "Example 4: DIV vs IDIV and the required EDX extension",10
h0_len: equ $-h0

u0: db "Unsigned: 156 / 7",10
u0_len: equ $-u0

s0: db "Signed:   -100 / 7",10
s0_len: equ $-s0

lab_q: db "  quotient: ",0
lab_q_len: equ $-lab_q-1

lab_r: db "  remainder: ",0
lab_r_len: equ $-lab_r-1

nl: db 10
nl_len: equ 1

section .text
_start:
    WRITE h0, h0_len

    ; ---------------------
    ; Unsigned division: EDX:EAX is an unsigned 64-bit dividend
    ; For DIV r/m32, dividend is EDX:EAX, quotient in EAX, remainder in EDX.
    ; ---------------------
    WRITE u0, u0_len
    mov eax, 156
    xor edx, edx           ; zero-extend into EDX:EAX
    mov ecx, 7
    div ecx

    WRITE lab_q, lab_q_len
    movzx rax, eax
    call write_hex64

    WRITE lab_r, lab_r_len
    movzx rax, edx
    call write_hex64

    WRITE nl, nl_len

    ; ---------------------
    ; Signed division: EDX:EAX is a signed 64-bit dividend
    ; CDQ sign-extends EAX into EDX.
    ; For IDIV r/m32, quotient in EAX, remainder in EDX.
    ; ---------------------
    WRITE s0, s0_len
    mov eax, -100
    cdq                   ; sign-extend into EDX:EAX
    mov ecx, 7
    idiv ecx

    WRITE lab_q, lab_q_len
    movsxd rax, eax
    call write_hex64

    WRITE lab_r, lab_r_len
    movsxd rax, edx
    call write_hex64

    EXIT 0
