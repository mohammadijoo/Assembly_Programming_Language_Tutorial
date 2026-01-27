; Chapter 5 - Lesson 7 (Example 3)
; Dense switch lowered to a *relative-offset* jump table (4-byte signed deltas).
; This reduces table size (useful for I-cache and code size) and is common in compilers.
; Build:
;   nasm -f elf64 Chapter5_Lesson7_Ex3.asm -o ex3.o

default rel
bits 64

section .text
global switch_dense_rel

; int switch_dense_rel(int x)
; Input:  EDI = x
; Output: EAX = result
switch_dense_rel:
    mov eax, edi
    cmp eax, 5
    ja  .default

    lea rdx, [jt_base]             ; base for relative offsets
    mov ecx, eax                   ; idx in ECX
    movsxd rax, dword [rdx + rcx*4]
    add rax, rdx                   ; absolute target
    jmp rax

.case0:
    mov eax, 101
    ret
.case1:
    mov eax, 102
    ret
.case2:
    mov eax, 103
    ret
.case3:
    mov eax, 104
    ret
.case4:
    mov eax, 105
    ret
.case5:
    mov eax, 106
    ret

.default:
    mov eax, -1
    ret

section .rodata
align 4
jt_base:
    dd .case0 - jt_base
    dd .case1 - jt_base
    dd .case2 - jt_base
    dd .case3 - jt_base
    dd .case4 - jt_base
    dd .case5 - jt_base
