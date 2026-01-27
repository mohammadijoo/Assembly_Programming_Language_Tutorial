; Chapter 5 - Lesson 8, Exercise Solution 2
; Branchless in-range count/sum using SETcc + mask.
; Target: Linux x86-64, NASM

BITS 64
DEFAULT REL

global _start

%define N 65536

section .bss
arr     resq N

section .data
seed    dq 1
a       dq -1000
b       dq  1000
count   dq 0
sum     dq 0

section .text
fill:
    test rcx, rcx
    je   .done
.loop:
    imul rax, rax, 2862933555777941757
    add  rax, 3037000493
    mov  [rdi], rax
    add  rdi, 8
    dec  rcx
    jne  .loop
.done:
    ret

_start:
    mov rax, [seed]
    lea rdi, [arr]
    mov rcx, N
    call fill

    xor rbx, rbx
    xor r12, r12
    xor rcx, rcx
.loop2:
    cmp rcx, N
    je  .done2
    mov r8, [arr + rcx*8]

    mov r9, [a]
    cmp r8, r9
    setge r10b

    mov r9, [b]
    cmp r8, r9
    setle r11b

    and r10b, r11b
    movzx r10, r10b
    add r12, r10

    neg r10
    and r8, r10
    add rbx, r8

    inc rcx
    jmp .loop2
.done2:
    mov [sum], rbx
    mov [count], r12
    mov eax, 60
    xor edi, edi
    syscall
