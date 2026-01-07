; Chapter 2 - Lesson 7 (Execution Flow) - Example 8
; A tiny threaded interpreter (dispatch loop) using a jump table.
; Build:
;   nasm -f elf64 Chapter2_Lesson7_Ex8.asm -o ex8.o
;   ld ex8.o -o ex8

BITS 64
DEFAULT REL

%include "Chapter2_Lesson7_Ex5.asm"

GLOBAL _start

SECTION .data
; Program opcodes: 0=INC, 1=DEC, 2=HALT
program: db 0, 0, 1, 0, 2
program_len equ $-program

msg_val db "Final accumulator (low byte) is exit status.", 10
len_val equ $-msg_val

ALIGN 8
op_table:
    dq op_inc, op_dec, op_halt

SECTION .text
_start:
    xor ebx, ebx            ; accumulator in EBX
    lea rsi, [program]      ; instruction pointer into program bytes
    lea rdi, [program + program_len]

.dispatch:
    cmp rsi, rdi
    jae op_halt             ; safety: ran past program

    movzx eax, byte [rsi]   ; fetch opcode
    inc rsi                 ; advance to next byte
    cmp eax, 2
    ja  op_halt             ; unknown opcode => halt

    lea rdx, [op_table]
    jmp qword [rdx + rax*8] ; computed goto

op_inc:
    inc ebx
    jmp .dispatch

op_dec:
    dec ebx
    jmp .dispatch

op_halt:
    PRINT msg_val, len_val
    mov eax, ebx
    and eax, 0xFF
    EXIT eax
