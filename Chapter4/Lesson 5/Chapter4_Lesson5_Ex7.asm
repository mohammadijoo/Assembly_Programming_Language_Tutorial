; Chapter 4 - Lesson 5
; File: Chapter4_Lesson5_Ex7.asm
; Topic: TEST as non-destructive AND; clears CF and OF; sets ZF/SF/PF from AND result.
; Build:
;   nasm -felf64 Chapter4_Lesson5_Ex7.asm -o ex7.o
;   ld ex7.o -o ex7

%include "Chapter4_Lesson5_Ex1.asm"

global _start

section .data
msg_cf0: db "After STC; TEST: JC not taken because TEST clears CF.", 10, 0
msg_odd: db "TEST bit0: number is odd.", 10, 0
msg_even: db "TEST bit0: number is even.", 10, 0
msg_zero: db "TEST reg,reg: value is zero (ZF=1).", 10, 0
msg_nz: db "TEST reg,reg: value is non-zero (ZF=0).", 10, 0

section .text
_start:
    ; Demonstrate CF clearing
    stc                     ; CF = 1
    mov eax, 1
    test eax, eax           ; clears CF and OF
    jc .unexpected_cf
    lea rsi, [rel msg_cf0]
    call print_cstr

    ; Bit test via TEST (non-destructive)
    mov eax, 42
    test eax, 1
    jnz .is_odd
    lea rsi, [rel msg_even]
    call print_cstr
    jmp .zero_demo
.is_odd:
    lea rsi, [rel msg_odd]
    call print_cstr

.zero_demo:
    xor eax, eax
    test eax, eax
    jz .is_zero
    lea rsi, [rel msg_nz]
    call print_cstr
    SYS_EXIT 0
.is_zero:
    lea rsi, [rel msg_zero]
    call print_cstr
    SYS_EXIT 0

.unexpected_cf:
    ; Should not happen
    SYS_EXIT 2
