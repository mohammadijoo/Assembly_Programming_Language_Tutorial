; Chapter 5 - Lesson 4 (NASM, x86-64 Linux)
; Example 7: Hybrid strategy (rare cases via branches + dense jump table for core range)
; Cases:
;   0      -> rare
;   10..20 -> dense
;   1000   -> rare
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o
;   ./ex7

default rel
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

%define L 10
%define H 20

section .rodata
m0:    db "rare case 0", 10
l0:    equ $-m0
m1000: db "rare case 1000", 10
l1000: equ $-m1000
mD:    db "default", 10
lD:    equ $-mD

; Messages for 10..20
%assign i 10
%rep 11
m%+i: db "dense case ", `i`, 10
l%+i: equ $-m%+i
%assign i i+1
%endrep

section .data
x: dd 14

section .text
_start:
    mov eax, dword [x]

    cmp eax, 0
    je  .case0
    cmp eax, 1000
    je  .case1000

    ; Dense core: 10..20
    sub eax, L
    cmp eax, (H-L)
    ja  .default
    lea rbx, [jt]
    jmp qword [rbx + rax*8]

.case0:
    lea rsi, [m0]
    mov edx, l0
    jmp .print_exit

.case1000:
    lea rsi, [m1000]
    mov edx, l1000
    jmp .print_exit

.default:
    lea rsi, [mD]
    mov edx, lD
    jmp .print_exit

; Dense cases
%assign j 10
%rep 11
.case%+j:
    lea rsi, [m%+j]
    mov edx, l%+j
    jmp .print_exit
%assign j j+1
%endrep

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
    dq .case10, .case11, .case12, .case13, .case14, .case15, .case16, .case17, .case18, .case19, .case20
