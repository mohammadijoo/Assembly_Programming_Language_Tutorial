; Chapter 6 - Lesson 7 - Example 6
; Title: SysV stack arguments beyond registers (sum8: 8 integer args)
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson7_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

_start:
    ; Pass 1..6 in registers (SysV order):
    mov edi, 1
    mov esi, 2
    mov edx, 3
    mov ecx, 4
    mov r8d, 5
    mov r9d, 6

    ; Stack args (7th, 8th). We must keep RSP 16-aligned before CALL.
    ; At _start, RSP is 16-aligned.
    sub rsp, 16
    mov qword [rsp + 0], 7
    mov qword [rsp + 8], 8

    call sum8_u64

    add rsp, 16

    ; Exit with low byte of sum (1+..+8=36)
    mov edi, eax
    mov eax, 60
    syscall

; uint64_t sum8_u64(a1..a8)
; a1..a6: regs, a7..a8: stack
sum8_u64:
    push rbp
    mov rbp, rsp

    ; a7 and a8 are at [rbp+16] and [rbp+24] because:
    ;   [rbp+0]  = old RBP
    ;   [rbp+8]  = return address
    ;   [rbp+16] = 7th arg
    ;   [rbp+24] = 8th arg
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    add rax, rcx
    add rax, r8
    add rax, r9
    add rax, [rbp + 16]
    add rax, [rbp + 24]

    pop rbp
    ret
