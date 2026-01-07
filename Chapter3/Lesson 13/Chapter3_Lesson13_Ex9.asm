; Chapter 3 - Lesson 13 Exercise Solution 1 (Very Hard): Decompose + classify binary64 values
; File: Chapter3_Lesson13_Ex9.asm
;
; Goal:
;   Given raw binary64 bit patterns, print sign, raw exponent, unbiased exponent,
;   fraction (hex), and classification (zero/subnormal/normal/inf/qNaN/sNaN).
;
; Build:
;   nasm -felf64 Chapter3_Lesson13_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o
;   ./ex9

BITS 64
default rel

%include "Chapter3_Lesson13_Ex1.asm"
%include "Chapter3_Lesson13_Ex2.asm"

section .rodata
msg_title: db "Exercise Solution 1: binary64 decompose + classify", 0
msg_hdr:   db "format: bits  sign  exp_raw  exp_unb  frac  class", 0
msg_spc:   db "  ", 0

tbl:
    dq 0x0000000000000000      ; +0
    dq 0x8000000000000000      ; -0
    dq 0x0000000000000001      ; smallest +subnormal
    dq 0x0010000000000000      ; smallest +normal (exp=1, frac=0)
    dq 0x3FF0000000000000      ; +1.0
    dq 0xBFF0000000000000      ; -1.0
    dq 0x7FF0000000000000      ; +inf
    dq 0xFFF0000000000000      ; -inf
    dq 0x7FF8000000000001      ; qNaN
    dq 0x7FF0000000000001      ; sNaN-ish (top frac bit 0)
tbl_end:

section .text
global _start

_start:
    lea rdi, [msg_title]
    call print_cstr
    call print_nl
    lea rdi, [msg_hdr]
    call print_cstr
    call print_nl

    lea rbx, [tbl]
.loop:
    cmp rbx, tbl_end
    jae .done

    mov rax, qword [rbx]        ; bits

    ; bits
    mov rdi, rax
    call print_hex64
    lea rdi, [msg_spc]
    call print_cstr

    ; fields
    push rbx
    call fp64_get_fields         ; rax=bits -> rcx sign, rdx exp, r8 frac

    ; sign
    mov rdi, rcx
    call print_u64
    lea rdi, [msg_spc]
    call print_cstr

    ; exp raw
    movzx rdi, dx
    call print_u64
    lea rdi, [msg_spc]
    call print_cstr

    ; exp unbiased
    mov edx, edx
    call fp64_unbias_exp
    movsxd rdi, edx
    call print_i64
    lea rdi, [msg_spc]
    call print_cstr

    ; frac hex (lower 52 bits)
    ; print as hex64 but it includes leading zeros; good for inspection
    mov rdi, r8
    call print_hex64
    lea rdi, [msg_spc]
    call print_cstr

    ; classification
    mov rax, qword [rbx]
    call fp64_classify
    mov rdi, rax
    call print_cstr

    call print_nl
    pop rbx

    add rbx, 8
    jmp .loop

.done:
    mov eax, SYS_exit
    xor edi, edi
    syscall
