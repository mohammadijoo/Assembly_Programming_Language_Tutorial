; Chapter 5 - Lesson 4 (NASM, x86-64 Linux)
; Example 4: Signed-range switch with negative case values (L..H)
; Domain: -2..2  (five cases)
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o
;   ./ex4

default rel
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

%define L -2
%define H  2

section .rodata
m_2: db "case -2", 10
l_2: equ $-m_2
m_1: db "case -1", 10
l_1: equ $-m_1
m0:  db "case 0", 10
l0:  equ $-m0
m1:  db "case 1", 10
l1:  equ $-m1
m2:  db "case 2", 10
l2:  equ $-m2
mD:  db "default (outside -2..2)", 10
lD:  equ $-mD

section .data
x: dd -1

section .text
_start:
    mov eax, dword [x]     ; signed 32-bit value

    ; Signed bounds checks (explicit): if x < L or x > H -> default.
    cmp eax, L
    jl  .default
    cmp eax, H
    jg  .default

    ; Normalize: idx = x - L  (so L maps to 0)
    sub eax, L             ; eax = x - (-2) = x + 2
    lea rbx, [jt]
    jmp qword [rbx + rax*8]

.case0: lea rsi, [m_2]  ; idx 0 -> -2
        mov edx, l_2
        jmp .print_exit
.case1: lea rsi, [m_1]  ; idx 1 -> -1
        mov edx, l_1
        jmp .print_exit
.case2: lea rsi, [m0]   ; idx 2 -> 0
        mov edx, l0
        jmp .print_exit
.case3: lea rsi, [m1]   ; idx 3 -> 1
        mov edx, l1
        jmp .print_exit
.case4: lea rsi, [m2]   ; idx 4 -> 2
        mov edx, l2
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
    dq .case0, .case1, .case2, .case3, .case4
