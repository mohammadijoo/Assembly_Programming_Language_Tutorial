; Chapter 5 - Lesson 4 (NASM, x86-64 Linux)
; Example 2: Dense switch-case via jump table (O(1) dispatch)
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
;   ./ex2

default rel
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .rodata
msg0: db "case 0", 10
l0:   equ $-msg0
msg1: db "case 1", 10
l1:   equ $-msg1
msg2: db "case 2", 10
l2:   equ $-msg2
msg3: db "case 3", 10
l3:   equ $-msg3
msg4: db "case 4", 10
l4:   equ $-msg4
msg5: db "case 5", 10
l5:   equ $-msg5
msgD: db "default", 10
lD:   equ $-msgD

section .data
x: dd 3

section .text
_start:
    mov eax, dword [x]      ; value x
    ; Dense domain: 0..5
    cmp eax, 5
    ja  .default            ; unsigned check: negatives treated as huge -> default too
    lea rbx, [jt]
    jmp qword [rbx + rax*8]

.case0: lea rsi, [msg0]  ; note: each case ends with an unconditional branch (like "break")
        mov edx, l0
        jmp .print_exit
.case1: lea rsi, [msg1]
        mov edx, l1
        jmp .print_exit
.case2: lea rsi, [msg2]
        mov edx, l2
        jmp .print_exit
.case3: lea rsi, [msg3]
        mov edx, l3
        jmp .print_exit
.case4: lea rsi, [msg4]
        mov edx, l4
        jmp .print_exit
.case5: lea rsi, [msg5]
        mov edx, l5
        jmp .print_exit
.default:
        lea rsi, [msgD]
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
    dq .case0, .case1, .case2, .case3, .case4, .case5
