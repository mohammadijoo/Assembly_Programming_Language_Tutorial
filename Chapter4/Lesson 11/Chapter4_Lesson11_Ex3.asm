; Chapter 4 - Lesson 11 (Example 3)
; Turning flags into a full mask (0 or -1) and using AND/OR selection.
; Demonstrates:
;   (A) SBB reg,reg from CF
;   (B) SETb + NEG to build mask

bits 64
default rel
%include "Chapter4_Lesson11_Ex8.asm"

section .text
global _start

_start:
    ; Choose between x and y based on unsigned (a < b)
    mov rax, 0x1111111111111111    ; x
    mov rbx, 0x2222222222222222    ; y
    mov ecx, 10                    ; a (unsigned)
    mov edx, 20                    ; b (unsigned)

    ; ----------------------------
    ; A) mask = 0 or -1 via SBB
    cmp ecx, edx
    sbb r8, r8                     ; r8 = -CF (0 or -1)

    mov r9, r8
    not r9                         ; ~mask
    mov r10, rax
    and r10, r8                    ; mask & x
    mov r11, rbx
    and r11, r9                    ; ~mask & y
    or  r10, r11                   ; selected
    mov rdi, r10
    call print_hex_u64

    ; ----------------------------
    ; B) mask = 0 or -1 via SETb + NEG
    cmp ecx, edx
    xor r8d, r8d
    setb r8b                       ; r8b = CF
    neg r8                         ; 0 -> 0, 1 -> -1

    mov r9, r8
    not r9
    mov r10, rax
    and r10, r8
    mov r11, rbx
    and r11, r9
    or  r10, r11
    mov rdi, r10
    call print_hex_u64

    EXIT 0
