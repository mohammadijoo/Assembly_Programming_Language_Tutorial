; Chapter 5 - Lesson 8, Example 5
; Indirect calls through a table (harder target prediction than direct branches).
; Target: Linux x86-64, NASM

BITS 64
DEFAULT REL

global _start

section .data
targets dq f0, f1, f2, f3
idxs    dq 0,1,2,3,2,1,0,3,1,2,0,3
n_idxs  dq 12
acc     dq 0

section .text
f0: add qword [acc], 10
    ret
f1: add qword [acc], 20
    ret
f2: add qword [acc], 30
    ret
f3: add qword [acc], 40
    ret

_start:
    xor     rcx, rcx
    mov     rbx, [n_idxs]
.loop:
    cmp     rcx, rbx
    je      .done
    mov     rax, [idxs + rcx*8]
    call    qword [targets + rax*8]
    inc     rcx
    jmp     .loop
.done:
    mov     eax, 60
    xor     edi, edi
    syscall
