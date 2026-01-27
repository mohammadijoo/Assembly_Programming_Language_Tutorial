; Chapter 5 - Lesson 4 — Programming Exercise 1 (Solution)
; Very hard: Implement a bytecode interpreter with a jump-table dispatch.
;
; Instruction format (16 bytes each):
;   byte 0  : opcode (0..7)
;   bytes 1-7: padding
;   bytes 8-15: signed 64-bit operand (imm)
;
; Opcodes:
;   0: ACC += imm
;   1: ACC -= imm
;   2: ACC *= imm
;   3: ACC ^= imm
;   4: ACC <<= (imm & 63)
;   5: ACC >>= (imm & 63)   (logical shift)
;   6: ACC = -ACC
;   7: HALT
;
; Prints ACC as 0x + 16 hex digits + newline.
;
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o
;   ./ex12

default rel
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

%macro INSTR 2
    db %1
    times 7 db 0
    dq %2
%endmacro

section .rodata
hex: db "0123456789ABCDEF"
out: db "0x", 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 10
out_len: equ $-out

section .data
; Program:
;   acc = 0
;   acc += 5
;   acc *= 3
;   acc -= 1
;   acc ^= 0xFF
;   acc <<= 4
;   halt
program:
    INSTR 0, 5
    INSTR 2, 3
    INSTR 1, 1
    INSTR 3, 0xFF
    INSTR 4, 4
    INSTR 7, 0
program_end:

section .text
_start:
    xor r12, r12             ; ACC = 0 (callee-saved used as accumulator)
    lea r13, [program]       ; IP  (pointer to current instruction)
    lea r14, [program_end]   ; program end for safety

.dispatch:
    cmp r13, r14
    jae .halt                ; safety: avoid reading beyond program

    movzx eax, byte [r13]    ; opcode
    mov rbx, qword [r13 + 8] ; imm (may be unaligned; x86 handles it)

    cmp eax, 7
    ja  .bad_opcode

    lea r15, [jt]
    jmp qword [r15 + rax*8]

.op_add:
    add r12, rbx
    jmp .next
.op_sub:
    sub r12, rbx
    jmp .next
.op_mul:
    imul r12, rbx
    jmp .next
.op_xor:
    xor r12, rbx
    jmp .next
.op_shl:
    mov ecx, ebx
    and ecx, 63
    shl r12, cl
    jmp .next
.op_shr:
    mov ecx, ebx
    and ecx, 63
    shr r12, cl
    jmp .next
.op_neg:
    neg r12
    jmp .next
.op_halt:
    jmp .halt

.next:
    add r13, 16
    jmp .dispatch

.bad_opcode:
    ; Treat as halt for this exercise (could signal error instead)
.halt:
    ; Format: out = "0x" + 16 hex digits + "\n"
    mov rax, r12
    lea rdi, [out + 2]       ; write digits starting after "0x"
    mov ecx, 16
.hex_loop:
    mov rdx, rax
    shr rdx, 60              ; top nibble
    lea rsi, [hex]
    mov dl, byte [rsi + rdx]
    mov byte [rdi], dl
    inc rdi
    shl rax, 4
    dec ecx
    jnz .hex_loop

    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [out]
    mov edx, out_len
    syscall

    xor edi, edi
    mov eax, SYS_exit
    syscall

section .rodata
align 8
jt:
    dq .op_add, .op_sub, .op_mul, .op_xor, .op_shl, .op_shr, .op_neg, .op_halt
