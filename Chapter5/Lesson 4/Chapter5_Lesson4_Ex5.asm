; Chapter 5 - Lesson 4 (NASM, x86-64 Linux)
; Example 5: Jump table using 32-bit relative offsets (smaller table, PIC-friendly)
; Domain: 10..15 (6 cases)
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o
;   ./ex5

default rel
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

%define L 10
%define H 15

section .rodata
m10: db "case 10", 10
l10: equ $-m10
m11: db "case 11", 10
l11: equ $-m11
m12: db "case 12", 10
l12: equ $-m12
m13: db "case 13", 10
l13: equ $-m13
m14: db "case 14", 10
l14: equ $-m14
m15: db "case 15", 10
l15: equ $-m15
mD:  db "default", 10
lD:  equ $-mD

section .data
x: dd 14

section .text
_start:
    mov eax, dword [x]
    ; Fast unsigned range check via normalization:
    ; idx = x - L; if idx > (H-L) -> default
    sub eax, L
    cmp eax, (H - L)
    ja  .default

    lea rbx, [jt_off]                 ; base of offset table
    movsxd rax, dword [rbx + rax*4]   ; sign-extend 32-bit offset
    lea rcx, [rbx + rax]              ; target = base + offset
    jmp rcx

.case10: lea rsi, [m10]
         mov edx, l10
         jmp .print_exit
.case11: lea rsi, [m11]
         mov edx, l11
         jmp .print_exit
.case12: lea rsi, [m12]
         mov edx, l12
         jmp .print_exit
.case13: lea rsi, [m13]
         mov edx, l13
         jmp .print_exit
.case14: lea rsi, [m14]
         mov edx, l14
         jmp .print_exit
.case15: lea rsi, [m15]
         mov edx, l15
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
align 4
jt_off:
    dd .case10 - jt_off
    dd .case11 - jt_off
    dd .case12 - jt_off
    dd .case13 - jt_off
    dd .case14 - jt_off
    dd .case15 - jt_off
