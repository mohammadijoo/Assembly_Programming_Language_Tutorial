; Chapter7_Lesson8_Ex4.asm
; NX enforcement demo: execute from a RW (non-exec) page -> SIGSEGV, caught by handler.
; NASM, Linux x86-64 (ELF64)

%include "Chapter7_Lesson8_Ex9.asm"

default rel
global _start

%define PAGESZ 4096

section .data
msg_intro: db "NX demo: attempting to execute from RW page (expected SIGSEGV).", 10
len_intro: equ $-msg_intro

msg_caught: db "SIGSEGV caught: execution blocked (page had no X permission).", 10
len_caught: equ $-msg_caught

section .data
; struct sigaction (x86-64 kernel UAPI):
;   sa_handler  (8)
;   sa_flags    (8)
;   sa_restorer (8)
;   sa_mask     (8)
sa_segv:
    dq segv_handler
    dq SA_RESTORER
    dq sig_restorer
    dq 0

section .text
_start:
    and rsp, -16

    ; Install SIGSEGV handler: rt_sigaction(SIGSEGV, &sa_segv, NULL, sizeof(sigset_t)=8)
    syscall4 SYS_rt_sigaction, SIGSEGV, sa_segv, 0, 8

    syscall3 SYS_write, 1, msg_intro, len_intro

    ; Allocate RW page (no exec)
    syscall6 SYS_mmap, 0, PAGESZ, (PROT_READ|PROT_WRITE), (MAP_PRIVATE|MAP_ANONYMOUS), -1, 0
    mov r12, rax

    ; Place trivial code: ret
    mov byte [r12], 0xC3

    ; This call should fault (NX)
    call r12

    ; If NX isn't active, you'd reach here (rare on modern systems).
    syscall1 SYS_exit, 0

segv_handler:
    syscall3 SYS_write, 1, msg_caught, len_caught
    syscall1 SYS_exit, 0

sig_restorer:
    mov rax, 15               ; SYS_rt_sigreturn
    syscall
