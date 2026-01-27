bits 64
default rel

global _start
section .text

; Ex9: Indirect branching through a pointer table (manual "computed jump").
; This is the fundamental mechanism behind jump tables and some dispatch loops.
; The jump itself has no rel8/rel32 constraint; the pointer value determines the target.

_start:
    ; rdi selects which target (0 or 1)
    xor edi, edi

    lea rbx, [rel targets]
    mov rax, [rbx + rdi*8]
    jmp rax

target0:
    mov edi, 0
    mov eax, 60
    syscall

target1:
    mov edi, 1
    mov eax, 60
    syscall

section .rodata
align 8
targets:
    dq target0
    dq target1
