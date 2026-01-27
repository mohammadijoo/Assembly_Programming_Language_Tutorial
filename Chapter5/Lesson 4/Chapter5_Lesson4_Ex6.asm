; Chapter 5 - Lesson 4 (NASM, x86-64 Linux)
; Example 6: Sparse switch-case via hand-written binary search (O(log n))
; Cases: 3, 7, 20, 55, 100
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
;   ./ex6

default rel
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .rodata
m3:   db "case 3", 10
l3:   equ $-m3
m7:   db "case 7", 10
l7:   equ $-m7
m20:  db "case 20", 10
l20:  equ $-m20
m55:  db "case 55", 10
l55:  equ $-m55
m100: db "case 100", 10
l100: equ $-m100
mD:   db "default (not in set)", 10
lD:   equ $-mD

section .data
x: dd 55

section .text
_start:
    mov eax, dword [x]

    ; Binary search decision tree (balanced-ish)
    cmp eax, 20
    je  .case20
    jl  .left
    ; right side: {55, 100}
    cmp eax, 55
    je  .case55
    cmp eax, 100
    je  .case100
    jmp .default

.left:
    ; left side: {3, 7}
    cmp eax, 3
    je  .case3
    cmp eax, 7
    je  .case7
    jmp .default

.case3:
    lea rsi, [m3]
    mov edx, l3
    jmp .print_exit
.case7:
    lea rsi, [m7]
    mov edx, l7
    jmp .print_exit
.case20:
    lea rsi, [m20]
    mov edx, l20
    jmp .print_exit
.case55:
    lea rsi, [m55]
    mov edx, l55
    jmp .print_exit
.case100:
    lea rsi, [m100]
    mov edx, l100
    jmp .print_exit

.default:
    lea rsi, [mD]
    mov edx, lD

.print_exit:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    xor edi, edi
    mov eax, SYS_exit
    syscall
