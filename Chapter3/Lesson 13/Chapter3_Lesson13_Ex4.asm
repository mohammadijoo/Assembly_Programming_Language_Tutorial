; Chapter 3 - Lesson 13 Example 4: Extracting sign/exponent/fraction from binary32
; File: Chapter3_Lesson13_Ex4.asm
;
; Build:
;   nasm -felf64 Chapter3_Lesson13_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o
;   ./ex4

BITS 64
default rel

%include "Chapter3_Lesson13_Ex1.asm"
%include "Chapter3_Lesson13_Ex2.asm"

section .rodata
msg_title: db "binary32 field extraction demo", 0
msg_bits:  db "bits      = ", 0
msg_sign:  db "sign      = ", 0
msg_exp:   db "exp (raw)  = ", 0
msg_ub:    db "exp (unb)  = ", 0
msg_frac:  db "frac       = ", 0

; 13.25 = 1101.01b = 1.10101b * 2^3
; Should decode to:
;   sign=0
;   exp_unbiased=3
;   frac corresponds to 10101... (stored without the leading 1)
val_13p25: dd 13.25

section .text
global _start

_start:
    lea rdi, [msg_title]
    call print_cstr
    call print_nl

    ; Load float32, then capture raw bits
    movss xmm0, dword [val_13p25]
    movd eax, xmm0            ; eax = raw bits

    lea rdi, [msg_bits]
    call print_cstr
    mov edi, eax
    call print_hex32
    call print_nl

    ; Extract fields
    call fp32_get_fields       ; eax=bits -> ecx=sign, edx=exp, r8d=frac

    lea rdi, [msg_sign]
    call print_cstr
    movzx rdi, cl
    call print_u64
    call print_nl

    lea rdi, [msg_exp]
    call print_cstr
    movzx rdi, dx
    call print_u64
    call print_nl

    lea rdi, [msg_ub]
    call print_cstr
    call fp32_unbias_exp       ; edx -> edx
    movsxd rdi, edx
    call print_i64
    call print_nl

    lea rdi, [msg_frac]
    call print_cstr
    mov edi, r8d
    call print_hex32
    call print_nl

    mov eax, SYS_exit
    xor edi, edi
    syscall
