; Chapter7_Lesson8_Ex6.asm
; Guard page demo: map 2 pages RW, protect the second page as PROT_NONE, then overflow into it.
; NASM, Linux x86-64 (ELF64)

%include "Chapter7_Lesson8_Ex9.asm"

default rel
global _start

%define PAGESZ 4096

section .data
msg_intro: db "Guard page demo: writing past 1 page into a PROT_NONE page (expected SIGSEGV).", 10
len_intro: equ $-msg_intro

msg_caught: db "SIGSEGV caught: guard page stopped an out-of-bounds write.", 10
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

    ; base = mmap(NULL, 2*PAGESZ, RW, anonymous)
    syscall6 SYS_mmap, 0, (2*PAGESZ), (PROT_READ|PROT_WRITE), (MAP_PRIVATE|MAP_ANONYMOUS), -1, 0
    mov r12, rax

    ; Protect the second page: mprotect(base+PAGESZ, PAGESZ, PROT_NONE)
    lea rdi, [r12 + PAGESZ]
    syscall3 SYS_mprotect, rdi, PAGESZ, PROT_NONE

    ; Write at the first byte of the guard page -> fault
    mov byte [r12 + PAGESZ], 0xAA

    syscall1 SYS_exit, 0

segv_handler:
    syscall3 SYS_write, 1, msg_caught, len_caught
    syscall1 SYS_exit, 0

sig_restorer:
    mov rax, 15               ; SYS_rt_sigreturn
    syscall
