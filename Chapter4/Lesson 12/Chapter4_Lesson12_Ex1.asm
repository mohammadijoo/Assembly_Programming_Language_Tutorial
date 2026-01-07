; Chapter 4 - Lesson 12 (Ex1)
; Implicit operands: MUL/IMUL write RDX:RAX, and have implicit source/dest rules.
; Target: Linux x86-64, NASM

bits 64
default rel
global _start

section .text
_start:
    ; Example 1: unsigned multiply rax * rbx -> rdx:rax
    mov     rax, 0x1122334455667788
    mov     rbx, 0x0000000000000010
    mul     rbx                 ; implicit: (RDX:RAX) = RAX * RBX  (unsigned)

    ; At this point:
    ;   RAX = low 64 bits
    ;   RDX = high 64 bits
    ; Pitfall: assuming MUL "only" changes RAX (it also clobbers RDX).

    ; Example 2: 3-operand IMUL does NOT use RDX:RAX
    mov     rcx, 7
    mov     r8,  9
    imul    r9, rcx, r8         ; r9 = 7*9, flags set, RDX/RAX untouched

    ; Exit(0)
    mov     eax, 60
    xor     edi, edi
    syscall
