; ex1_write_all.asm
; Build:
;   nasm -f elf64 ex1_write_all.asm -o ex1_write_all.o
;   ld -o ex1_write_all ex1_write_all.o

BITS 64

%define SYS_write 1
%define SYS_exit  60
%define STDOUT_FD 1

section .data
    msg db "Robust write_all: hello via loop", 10
    msg_len equ $ - msg

section .text
global _start

; write_all(rsi=buf, rdx=len) -> rax=0 on success, rax=-1 on error
; Clobbers: rax, rdi, rcx, r8
write_all:
    mov edi, STDOUT_FD      ; fd fixed to stdout
    xor r8d, r8d            ; written = 0

.loop:
    ; remaining = len - written
    mov rcx, rdx
    sub rcx, r8
    jz .ok

    mov eax, SYS_write
    ; rdi = fd
    ; rsi = buf + written
    lea rsi, [rsi + r8]
    mov rdx, rcx
    syscall

    ; If rax < 0, error (Linux returns -errno)
    test rax, rax
    js .err

    ; written += rax
    add r8, rax

    ; restore base pointer to original buffer:
    ; we advanced rsi in-place; recover by subtracting written so far
    ; (Alternatively: keep base in another register; this exercise forces you to manage it.)
    lea rsi, [rsi - r8]
    jmp .loop

.ok:
    xor eax, eax
    ret

.err:
    mov eax, -1
    ret

_start:
    lea rsi, [rel msg]
    mov edx, msg_len
    call write_all
    test rax, rax
    jz .exit_ok

.exit_err:
    mov eax, SYS_exit
    mov edi, 1
    syscall

.exit_ok:
    mov eax, SYS_exit
    xor edi, edi
    syscall
