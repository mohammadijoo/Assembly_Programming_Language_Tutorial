; Chapter7_Lesson8_Ex11.asm
; Exercise Solution: Enforce W^X and prove it:
; 1) Map RW, write bytes, mprotect -> RX
; 2) Execute code (ok)
; 3) Attempt to write while RX -> SIGSEGV (caught), demonstrating "no W when X".
; NASM, Linux x86-64 (ELF64)

%include "Chapter7_Lesson8_Ex9.asm"

default rel
global _start

%define PAGESZ 4096

section .data
msg_intro: db "W^X proof: after mprotect RX, attempt a write (expected SIGSEGV).", 10
len_intro: equ $-msg_intro

msg_ok: db "Execution succeeded; now trying to modify RX page...", 10
len_ok: equ $-msg_ok

msg_caught: db "SIGSEGV caught: write blocked because page was RX (no W).", 10
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

    ; RW map
    syscall6 SYS_mmap, 0, PAGESZ, (PROT_READ|PROT_WRITE), (MAP_PRIVATE|MAP_ANONYMOUS), -1, 0
    mov r12, rax

    ; Emit: mov eax, 7 ; ret
    mov byte [r12+0], 0xB8
    mov dword [r12+1], 7
    mov byte [r12+5], 0xC3

    ; Flip to RX
    syscall3 SYS_mprotect, r12, PAGESZ, (PROT_READ|PROT_EXEC)

    ; Execute (should succeed)
    call r12
    syscall3 SYS_write, 1, msg_ok, len_ok

    ; Attempt to modify code while RX (should fault)
    mov byte [r12], 0x90      ; NOP (write into RX page) -> SIGSEGV

    syscall1 SYS_exit, 0

segv_handler:
    syscall3 SYS_write, 1, msg_caught, len_caught
    syscall1 SYS_exit, 0

sig_restorer:
    mov rax, 15               ; SYS_rt_sigreturn
    syscall
