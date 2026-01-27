; Chapter 5 - Lesson 4 (NASM, x86-64 Linux)
; Example 8: "Branchless" selection for small switches using CMOV (select pointer+length)
; Note: This avoids Jcc to case labels, but still does a sequence of CMP + CMOV.
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o
;   ./ex8

default rel
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .rodata
m0: db "case 0 (selected by cmov)", 10
l0: equ $-m0
m1: db "case 1 (selected by cmov)", 10
l1: equ $-m1
m2: db "case 2 (selected by cmov)", 10
l2: equ $-m2
mD: db "default (selected by cmov)", 10
lD: equ $-mD

section .data
x: dd 2

section .text
_start:
    mov eax, dword [x]

    ; Default selection
    lea rsi, [mD]
    mov edx, lD

    ; Case 0
    lea rbx, [m0]
    mov ecx, l0
    cmp eax, 0
    cmove rsi, rbx
    cmove edx, ecx

    ; Case 1
    lea rbx, [m1]
    mov ecx, l1
    cmp eax, 1
    cmove rsi, rbx
    cmove edx, ecx

    ; Case 2
    lea rbx, [m2]
    mov ecx, l2
    cmp eax, 2
    cmove rsi, rbx
    cmove edx, ecx

    mov eax, SYS_write
    mov edi, STDOUT
    syscall

    xor edi, edi
    mov eax, SYS_exit
    syscall
