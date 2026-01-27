; Chapter 5 - Lesson 7 (Example 1)
; Dense switch lowered to an absolute-address jump table (8-byte pointers).
; Target: Linux x86-64, NASM
; Build (object only): nasm -f elf64 Chapter5_Lesson7_Ex1.asm -o ex1.o

default rel
bits 64

section .text
global switch_dense_abs

; int switch_dense_abs(int x)
; Input:  EDI = x
; Output: EAX = result
switch_dense_abs:
    ; Range: 0..5
    mov eax, edi
    cmp eax, 5
    ja  .default

    lea rdx, [jt]          ; base of jump table
    jmp qword [rdx + rax*8]

.case0:
    mov eax, 11
    ret
.case1:
    mov eax, 22
    ret
.case2:
    mov eax, 33
    ret
.case3:
    mov eax, 44
    ret
.case4:
    mov eax, 55
    ret
.case5:
    mov eax, 66
    ret

.default:
    mov eax, -1
    ret

section .rodata
align 8
jt:
    dq .case0, .case1, .case2, .case3, .case4, .case5
