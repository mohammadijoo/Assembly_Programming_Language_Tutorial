; Chapter 3 - Lesson 13 Example 6: ucomiss/ucomisd and NaN-aware comparisons
; File: Chapter3_Lesson13_Ex6.asm
;
; Build:
;   nasm -felf64 Chapter3_Lesson13_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
;   ./ex6
;
; Key point:
;   ucomiss sets ZF/CF/PF for ordered vs unordered comparisons.
;   If either operand is NaN, PF=1 (unordered) and ZF/CF are also set in specific ways.
;   Therefore, FP compare code often checks PF first.

BITS 64
default rel

%include "Chapter3_Lesson13_Ex1.asm"

section .rodata
msg_title: db "NaN-aware compare demo using UCOMISS", 0
msg_case1: db "Case 1: a=1.0, b=2.0", 0
msg_case2: db "Case 2: a=qNaN, b=1.0", 0
msg_flags: db "Flags after UCOMISS: CF=", 0
msg_zf:    db " ZF=", 0
msg_pf:    db " PF=", 0
msg_note1: db "Interpretation: CF=1 means a is less-than b, ZF=1 means a equals b, PF=1 means unordered (NaN).", 0

; constants
a1:   dd 1.0
b1:   dd 2.0
anan: dd 0x7FC00001

section .text
global _start

; print_ucomiss_flags expects AH from LAHF in al? We'll implement as:
;   input: ah contains flags (LAHF)
;   output: prints CF/ZF/PF as 0/1
print_ucomiss_flags:
    ; CF is bit0, PF is bit2, ZF is bit6 in AH.
    movzx eax, ah

    ; CF
    lea rdi, [msg_flags]
    call print_cstr
    mov edx, eax
    and edx, 1
    movzx rdi, dl
    call print_u64

    ; ZF
    lea rdi, [msg_zf]
    call print_cstr
    mov edx, eax
    shr edx, 6
    and edx, 1
    movzx rdi, dl
    call print_u64

    ; PF
    lea rdi, [msg_pf]
    call print_cstr
    mov edx, eax
    shr edx, 2
    and edx, 1
    movzx rdi, dl
    call print_u64

    call print_nl
    ret

_start:
    lea rdi, [msg_title]
    call print_cstr
    call print_nl

    ; ---- Case 1 (ordered) ----
    lea rdi, [msg_case1]
    call print_cstr
    call print_nl

    movss xmm0, dword [a1]
    movss xmm1, dword [b1]
    ucomiss xmm0, xmm1
    lahf
    call print_ucomiss_flags

    ; ---- Case 2 (unordered due to NaN) ----
    lea rdi, [msg_case2]
    call print_cstr
    call print_nl

    movss xmm0, dword [anan]
    movss xmm1, dword [a1]
    ucomiss xmm0, xmm1
    lahf
    call print_ucomiss_flags

    lea rdi, [msg_note1]
    call print_cstr
    call print_nl

    mov eax, SYS_exit
    xor edi, edi
    syscall
