; Chapter7_Lesson8_Ex5.asm
; User vs kernel space (conceptual): attempt to read a kernel-space canonical address -> SIGSEGV.
; NASM, Linux x86-64 (ELF64)

%include "Chapter7_Lesson8_Ex9.asm"

default rel
global _start

section .data
msg_intro: db "Attempting to read from a kernel-space canonical address (expected SIGSEGV).", 10
len_intro: equ $-msg_intro

msg_caught: db "SIGSEGV caught: user mode cannot access kernel mappings.", 10
len_caught: equ $-msg_caught

sa_segv:
    dq segv_handler
    dq SA_RESTORER
    dq sig_restorer
    dq 0

section .text
_start:
    and rsp, -16

    syscall4 SYS_rt_sigaction, SIGSEGV, sa_segv, 0, 8
    syscall3 SYS_write, 1, msg_intro, len_intro

    ; Typical kernel half on x86-64 uses high canonical addresses.
    mov rbx, 0xffff800000000000
    mov rax, [rbx]            ; should fault in user mode

    syscall1 SYS_exit, 0

segv_handler:
    syscall3 SYS_write, 1, msg_caught, len_caught
    syscall1 SYS_exit, 0

sig_restorer:
    mov rax, 15               ; SYS_rt_sigreturn
    syscall
