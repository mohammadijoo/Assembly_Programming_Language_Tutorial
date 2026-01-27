; Chapter 5 - Lesson 4 (NASM, x86-64 Linux)
; Example 1: Switch-case via compare/branch chain (small number of cases)
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
;   ./ex1

default rel
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .rodata
msg0:      db "case 0: cold path", 10
msg0_len:  equ $-msg0
msg1:      db "case 1: fast path", 10
msg1_len:  equ $-msg1
msg5:      db "case 5: special path", 10
msg5_len:  equ $-msg5
msgD:      db "default: out of range", 10
msgD_len:  equ $-msgD

section .data
x: dd 5

section .text
_start:
    mov eax, dword [x]      ; switch value (32-bit)

    ; Chain: O(#cases) compares. Good for a few cases or very predictable ones.
    cmp eax, 0
    je  .case0
    cmp eax, 1
    je  .case1
    cmp eax, 5
    je  .case5
    jmp .default

.case0:
    lea rsi, [msg0]
    mov edx, msg0_len
    jmp .print_and_exit

.case1:
    lea rsi, [msg1]
    mov edx, msg1_len
    jmp .print_and_exit

.case5:
    lea rsi, [msg5]
    mov edx, msg5_len
    jmp .print_and_exit

.default:
    lea rsi, [msgD]
    mov edx, msgD_len

.print_and_exit:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall

    xor edi, edi
    mov eax, SYS_exit
    syscall
