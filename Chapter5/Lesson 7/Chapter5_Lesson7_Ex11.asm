; Chapter 5 - Lesson 7 (Exercise 3 - Solution)
; Very hard: Threaded VM with 8 opcodes, using computed branching and a stack.
;
; VM state:
;   - data stack of 16 64-bit slots
;   - sp points to next free slot
;   - ip points into bytecode
;
; Bytecode instructions (1-byte opcode, followed by operands as specified):
;   0: PUSH8 imm8        ; push sign-extended imm8
;   1: ADD               ; pop a,b -> push (a+b)
;   2: MUL               ; pop a,b -> push (a*b)
;   3: AND               ; pop a,b -> push (a&b)
;   4: DUP               ; duplicate top
;   5: SWAP              ; swap top two
;   6: JNZ rel8          ; pop x; if x!=0 then ip += signext(rel8)
;   7: HALT              ; exit with (top & 255), or 0 if empty
;
; Demonstrates:
;   - computed branching
;   - structured state loop
;   - defensive opcode bounds checking
;   - small relative branch in bytecode (rel8)
;
; Build+Run:
;   nasm -f elf64 Chapter5_Lesson7_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o
;   ./ex11 ; echo $?

default rel
bits 64

%define OP_PUSH8 0
%define OP_ADD   1
%define OP_MUL   2
%define OP_AND   3
%define OP_DUP   4
%define OP_SWAP  5
%define OP_JNZ   6
%define OP_HALT  7
%define OP_MAX   7

section .text
global _start

_start:
    lea rsi, [bytecode]            ; ip
    lea rbx, [stack]               ; stack base
    xor ecx, ecx                   ; sp = 0 (in slots)
    jmp .dispatch

.dispatch:
    lodsb
    movzx edx, al                  ; opcode in EDX
    cmp edx, OP_MAX
    ja  .bad

    lea r8, [op_table]
    jmp qword [r8 + rdx*8]

; Helpers:
; top element address = stack + (sp-1)*8
; sp is in ECX

.op_push8:
    lodsb
    movsx rax, al
    mov [rbx + rcx*8], rax
    inc ecx
    jmp .dispatch

.op_add:
    cmp ecx, 2
    jb  .bad
    dec ecx
    mov rax, [rbx + rcx*8]
    dec ecx
    add rax, [rbx + rcx*8]
    mov [rbx + rcx*8], rax
    inc ecx
    jmp .dispatch

.op_mul:
    cmp ecx, 2
    jb  .bad
    dec ecx
    mov rax, [rbx + rcx*8]
    dec ecx
    imul rax, [rbx + rcx*8]
    mov [rbx + rcx*8], rax
    inc ecx
    jmp .dispatch

.op_and:
    cmp ecx, 2
    jb  .bad
    dec ecx
    mov rax, [rbx + rcx*8]
    dec ecx
    and rax, [rbx + rcx*8]
    mov [rbx + rcx*8], rax
    inc ecx
    jmp .dispatch

.op_dup:
    cmp ecx, 1
    jb  .bad
    mov rax, [rbx + (rcx-1)*8]
    mov [rbx + rcx*8], rax
    inc ecx
    jmp .dispatch

.op_swap:
    cmp ecx, 2
    jb  .bad
    mov rax, [rbx + (rcx-1)*8]
    mov rdx, [rbx + (rcx-2)*8]
    mov [rbx + (rcx-1)*8], rdx
    mov [rbx + (rcx-2)*8], rax
    jmp .dispatch

.op_jnz:
    lodsb
    movsx rdx, al                  ; rel8 in RDX
    cmp ecx, 1
    jb  .bad
    dec ecx
    mov rax, [rbx + rcx*8]
    test rax, rax
    jz  .dispatch
    add rsi, rdx                   ; ip += rel8
    jmp .dispatch

.op_halt:
    xor edi, edi
    cmp ecx, 1
    jb  .exit
    mov rax, [rbx + (rcx-1)*8]
    and eax, 255
    mov edi, eax
.exit:
    mov eax, 60
    syscall

.bad:
    mov edi, 200
    mov eax, 60
    syscall

section .rodata
align 8
op_table:
    dq .op_push8, .op_add, .op_mul, .op_and, .op_dup, .op_swap, .op_jnz, .op_halt

; Program:
;   push 7
;   push 6
;   mul            ; 42
;   dup            ; 42, 42
;   push 1
;   subloop:
;   push 1
;   add            ; 42+1 = 43
;   push 0
;   jnz back       ; will not jump because pop 0
;   halt
;
; We do not implement SUB opcode here on purpose; it keeps opcode set minimal.
; Instead, we show a conditional jump that does not loop.
bytecode:
    db OP_PUSH8, 7
    db OP_PUSH8, 6
    db OP_MUL
    db OP_DUP
    db OP_PUSH8, 1
    db OP_ADD
    db OP_PUSH8, 0
    db OP_JNZ, -2
    db OP_HALT

section .bss
align 8
stack:  resq 16
