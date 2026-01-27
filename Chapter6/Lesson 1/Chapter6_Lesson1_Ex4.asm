; Chapter6_Lesson1_Ex4.asm
; "Manual" stack arguments: you can define your own calling convention.
; Here the caller pushes 3 arguments, then calls. The callee reads them from the stack.
;
; This is NOT SysV-style argument passing, but it is a great mental model for what CALL/RET do.
;
; Build:
;   nasm -felf64 Chapter6_Lesson1_Ex4.asm -o ex4.o
;   ld ex4.o -o ex4

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

; uint64_t sum3_stack(void)
; Stack layout at entry (high addresses at top):
;   [rsp]     = return address
;   [rsp+8]   = arg1
;   [rsp+16]  = arg2
;   [rsp+24]  = arg3
;
; We'll build a standard frame pointer first, so offsets become [rbp+16], [rbp+24], [rbp+32].
sum3_stack:
    push rbp
    mov rbp, rsp

    mov rax, [rbp+16]        ; arg1
    add rax, [rbp+24]        ; arg2
    add rax, [rbp+32]        ; arg3

    pop rbp
    ret

_start:
    ; Push args right-to-left (a common convention), though any order works if documented.
    push qword 3
    push qword 2
    push qword 1
    call sum3_stack           ; rax = 6
    add rsp, 24               ; caller cleans (3 args * 8 bytes)

    mov edi, eax
    mov eax, 60
    syscall
