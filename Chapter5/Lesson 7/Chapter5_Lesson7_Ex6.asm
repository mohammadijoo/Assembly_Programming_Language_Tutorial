; Chapter 5 - Lesson 7 (Example 6)
; Computed branching for a tiny bytecode VM (threaded interpreter style).
; Demonstrates:
;   - dispatch via indirect jump (jmp [table + opcode*8])
;   - explicit bounds checking for opcode
;   - state machine loop (PC over bytecode)
;
; Bytecode format:
;   OP_ADD imm8   : acc += imm
;   OP_SUB imm8   : acc -= imm
;   OP_XOR imm8   : acc ^= imm
;   OP_HALT       : stop, exit with (acc & 255)
;
; Build+Run:
;   nasm -f elf64 Chapter5_Lesson7_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
;   ./ex6 ; echo $?

default rel
bits 64

%define OP_ADD   0
%define OP_SUB   1
%define OP_XOR   2
%define OP_HALT  3
%define OP_MAX   3

section .text
global _start

_start:
    lea rsi, [bytecode]            ; RSI = pc
    xor eax, eax                   ; EAX = acc (32-bit)
    jmp .dispatch

.dispatch:
    lodsb                          ; AL = opcode, RSI++
    movzx ecx, al                  ; ECX = opcode (0..255)
    cmp ecx, OP_MAX
    ja  .bad_opcode

    lea rdx, [op_table]
    jmp qword [rdx + rcx*8]

.op_add:
    lodsb
    movsx ecx, al
    add eax, ecx
    jmp .dispatch

.op_sub:
    lodsb
    movsx ecx, al
    sub eax, ecx
    jmp .dispatch

.op_xor:
    lodsb
    movzx ecx, al
    xor eax, ecx
    jmp .dispatch

.op_halt:
    and eax, 255
    mov edi, eax
    mov eax, 60                    ; SYS_exit
    syscall

.bad_opcode:
    mov edi, 111
    mov eax, 60
    syscall

section .rodata
align 8
op_table:
    dq .op_add, .op_sub, .op_xor, .op_halt

bytecode:
    db OP_ADD, 5
    db OP_XOR, 3
    db OP_SUB, 2
    db OP_HALT
