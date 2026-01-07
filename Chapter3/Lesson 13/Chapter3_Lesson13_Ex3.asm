; Chapter 3 - Lesson 13 Example 3: Seeing IEEE-754 bit patterns for constants
; File: Chapter3_Lesson13_Ex3.asm
;
; Build (Linux x86-64):
;   nasm -felf64 Chapter3_Lesson13_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o
;   ./ex3

BITS 64
default rel

%include "Chapter3_Lesson13_Ex1.asm"

section .rodata
msg_title:      db "IEEE-754 raw bits demo (binary32 / binary64)", 0
msg_sp:         db "Single-precision (binary32):", 0
msg_dp:         db "Double-precision (binary64):", 0
msg_name_1:     db "  +1.5        : ", 0
msg_name_2:     db "  -0.0 (bits) : ", 0
msg_name_3:     db "  +Inf (bits) : ", 0
msg_name_4:     db "  qNaN (bits) : ", 0
msg_name_5:     db "  +1.5        : ", 0
msg_name_6:     db "  -0.0 (bits) : ", 0
msg_name_7:     db "  +Inf (bits) : ", 0
msg_name_8:     db "  qNaN (bits) : ", 0

; Declaring FP constants in NASM:
;   dd 1.5  -> binary32 encoding produced by assembler
;   dq 1.5  -> binary64 encoding produced by assembler
;
; For special values, using explicit bit patterns is often clearer/reproducible.
sp_1p5:     dd 1.5
sp_neg0:    dd 0x80000000
sp_inf:     dd 0x7F800000
sp_qnan:    dd 0x7FC00001

dp_1p5:     dq 1.5
dp_neg0:    dq 0x8000000000000000
dp_inf:     dq 0x7FF0000000000000
dp_qnan:    dq 0x7FF8000000000001

section .text
global _start

_start:
    lea rdi, [msg_title]
    call print_cstr
    call print_nl
    call print_nl

    ; --- binary32 ---
    lea rdi, [msg_sp]
    call print_cstr
    call print_nl

    lea rdi, [msg_name_1]
    call print_cstr
    movss xmm0, dword [sp_1p5]
    movd edi, xmm0            ; move raw 32-bit bits into EDI
    call print_hex32
    call print_nl

    lea rdi, [msg_name_2]
    call print_cstr
    movss xmm0, dword [sp_neg0]
    movd edi, xmm0
    call print_hex32
    call print_nl

    lea rdi, [msg_name_3]
    call print_cstr
    movss xmm0, dword [sp_inf]
    movd edi, xmm0
    call print_hex32
    call print_nl

    lea rdi, [msg_name_4]
    call print_cstr
    movss xmm0, dword [sp_qnan]
    movd edi, xmm0
    call print_hex32
    call print_nl
    call print_nl

    ; --- binary64 ---
    lea rdi, [msg_dp]
    call print_cstr
    call print_nl

    lea rdi, [msg_name_5]
    call print_cstr
    movsd xmm0, qword [dp_1p5]
    movq rdi, xmm0            ; move raw 64-bit bits into RDI
    call print_hex64
    call print_nl

    lea rdi, [msg_name_6]
    call print_cstr
    movsd xmm0, qword [dp_neg0]
    movq rdi, xmm0
    call print_hex64
    call print_nl

    lea rdi, [msg_name_7]
    call print_cstr
    movsd xmm0, qword [dp_inf]
    movq rdi, xmm0
    call print_hex64
    call print_nl

    lea rdi, [msg_name_8]
    call print_cstr
    movsd xmm0, qword [dp_qnan]
    movq rdi, xmm0
    call print_hex64
    call print_nl

    ; exit(0)
    mov eax, SYS_exit
    xor edi, edi
    syscall
