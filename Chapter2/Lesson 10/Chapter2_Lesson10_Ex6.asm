; Chapter 2 - Lesson 10 - Example 6
; Swapping two memory locations with XCHG (requires a register temp; no mem<->mem XCHG)
; Build:
;   nasm -felf64 Chapter2_Lesson10_Ex6.asm -o ex6.o && ld ex6.o -o ex6 && ./ex6 ; echo $?

global _start

section .data
    a dq 0x1111111111111111
    b dq 0x2222222222222222

section .text
_start:
    ; Swap (a, b):
    ; tmp = a
    mov rax, [rel a]
    ; rax <-> b  => b gets old a, rax gets old b
    xchg rax, [rel b]
    ; a = old b
    mov [rel a], rax

    ; Verify
    xor edi, edi
    cmp qword [rel a], 0x2222222222222222
    je .ok1
    or edi, 1
.ok1:
    cmp qword [rel b], 0x1111111111111111
    je .ok2
    or edi, 2
.ok2:
    mov eax, 60
    syscall
