; Chapter 5 - Lesson 4 (NASM, x86-64 Linux)
; Example 11: Using reusable macros to implement a dense switch
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o
;   ./ex11
;
; Make sure Chapter5_Lesson4_Ex10.asm is in the same directory (it is %include'd).

default rel
global _start
%include "Chapter5_Lesson4_Ex10.asm"

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

%define L 4
%define H 8

section .rodata
m4: db "case 4", 10
l4: equ $-m4
m5: db "case 5", 10
l5: equ $-m5
m6: db "case 6", 10
l6: equ $-m6
m7: db "case 7", 10
l7: equ $-m7
m8: db "case 8", 10
l8: equ $-m8
mD: db "default", 10
lD: equ $-mD

section .data
x: dd 7

section .text
_start:
    mov eax, dword [x]
    SWITCH_DENSE_DISPATCH eax, L, H, jt, .default

.case4: lea rsi, [m4]  ; idx 0
        mov edx, l4
        jmp .print_exit
.case5: lea rsi, [m5]
        mov edx, l5
        jmp .print_exit
.case6: lea rsi, [m6]
        mov edx, l6
        jmp .print_exit
.case7: lea rsi, [m7]
        mov edx, l7
        jmp .print_exit
.case8: lea rsi, [m8]
        mov edx, l8
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

section .rodata
align 8
jt:
    dq .case4, .case5, .case6, .case7, .case8
