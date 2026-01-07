;
; Chapter 2 - Lesson 8 - Example 10
; LAHF/SAHF: snapshot and restore subset of flags via AH.
; LAHF loads AH with: SF:ZF:0:AF:0:PF:1:CF
; SAHF stores those bits back (OF is not affected).
;
; Build:
;   nasm -felf64 Chapter2_Lesson8_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o

%include "Chapter2_Lesson8_Ex1.asm"

BITS 64
default rel
global _start

section .rodata
h: db "LAHF/SAHF demo (subset of flags in AH)",10
h_len: equ $-h
lab_ah: db "AH snapshot (hex) = ",0
lab_ah_len: equ 21
lab_after: db "After toggling CF in AH and SAHF:",10
lab_after_len: equ $-lab_after

section .text
_start:
    SYS_WRITE h, h_len

    ; Create a known flag pattern
    ; - CF=0 (via CLC)
    ; - ZF=1 (via XOR)
    clc
    xor eax, eax          ; ZF=1, PF=1, SF=0, OF=0, CF=0

    lahf                  ; AH gets flags subset
    lea rsi, [lab_ah]
    mov rdx, lab_ah_len
    call print_str
    movzx eax, ah
    call print_hex64_rax

    ; Toggle CF bit (bit0) inside AH, then restore
    xor ah, 1
    sahf

    SYS_WRITE lab_after, lab_after_len
    pushfq
    pop rbx
    mov rax, rbx
    call dump_flags_basic

    SYS_EXIT 0
