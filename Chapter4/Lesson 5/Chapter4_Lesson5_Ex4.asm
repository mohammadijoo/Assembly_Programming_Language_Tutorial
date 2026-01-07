; Chapter 4 - Lesson 5
; File: Chapter4_Lesson5_Ex4.asm
; Topic: Signed vs unsigned comparisons: JL/JG vs JB/JA after CMP.
; Build:
;   nasm -felf64 Chapter4_Lesson5_Ex4.asm -o ex4.o
;   ld ex4.o -o ex4

%include "Chapter4_Lesson5_Ex1.asm"

global _start

section .data
msg_s_yes: db "Signed compare: -1 < 1 (JL taken)", 10, 0
msg_s_no:  db "Signed compare: -1 !< 1 (JL not taken)", 10, 0
msg_u_yes: db "Unsigned compare: 255 < 1 (JB taken)", 10, 0
msg_u_no:  db "Unsigned compare: 255 !< 1 (JB not taken)", 10, 0

section .text
_start:
    mov al, 0xFF           ; -1 signed, 255 unsigned
    mov bl, 0x01

    cmp al, bl
    jl .signed_lt
.signed_not_lt:
    lea rsi, [rel msg_s_no]
    call print_cstr
    jmp .unsigned_check
.signed_lt:
    lea rsi, [rel msg_s_yes]
    call print_cstr

.unsigned_check:
    ; Re-do CMP (printing clobbers flags)
    mov al, 0xFF
    mov bl, 0x01
    cmp al, bl
    jb .unsigned_lt
.unsigned_not_lt:
    lea rsi, [rel msg_u_no]
    call print_cstr
    SYS_EXIT 0
.unsigned_lt:
    lea rsi, [rel msg_u_yes]
    call print_cstr
    SYS_EXIT 0
