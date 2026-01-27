; Chapter 6 - Lesson 12 (Example 7)
; Tail-calling with callee-saved registers: you must restore them BEFORE the jump.
; Here we save RBX, do some work, then tail-call g(x).

BITS 64
DEFAULT REL

global _start

section .text

g:
    ; return x xor 0x55
    mov rax, rdi
    xor eax, 0x55
    ret

f_save:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 16

    mov rbx, 0x123456789ABCDEF0
    ; pretend rbx influences the argument
    xor rdi, rbx

    add rsp, 16
    pop rbx                 ; restore callee-saved
    leave
    jmp g                   ; tail call after restoring ABI state

_start:
    mov rdi, 0x1111
    call f_save
    mov rdi, rax
    mov rax, 60
    syscall
