; Chapter7_Lesson10_Ex6.asm
; Topic: Deterministic initialization + poisoning patterns (rep stosq/stosb)
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

section .data
msg_ok     db "Initialized and poisoned buffer deterministically.", 10
msg_ok_len equ $-msg_ok

section .text
global _start

write_stdout:
    mov eax, SYS_write
    mov edi, 1
    syscall
    ret

exit_:
    mov eax, SYS_exit
    syscall

_start:
    ; Reserve 64 bytes on stack (keep alignment simple here)
    sub rsp, 64
    mov rdi, rsp

    ; 1) Zero-init as "known safe default"
    xor eax, eax
    mov rcx, 64/8
    rep stosq

    ; 2) Poison-init as "detect use of uninitialized/after-reset"
    mov rdi, rsp
    mov al, 0xCC
    mov rcx, 64
    rep stosb

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call write_stdout

    add rsp, 64
    xor edi, edi
    jmp exit_
