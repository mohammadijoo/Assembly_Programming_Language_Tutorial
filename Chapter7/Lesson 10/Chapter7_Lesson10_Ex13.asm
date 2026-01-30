; Chapter7_Lesson10_Ex13.asm
; Programming Exercise Solution 1:
; Topic: bounded_memcpy between two slices (dst, dst_len, src, src_len, n)
; Behavior: copy only if n <= dst_len AND n <= src_len, else fail.
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex13.asm -o ex13.o
;   ld -o ex13 ex13.o

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

section .data
src        db "abcdefghijklmnopqrstuvwxyz0123456789"
src_len    equ $-src

dst        times 24 db 0
dst_len    equ $-dst

n1         dq 16
n2         dq 40

msg_ok     db "bounded_memcpy OK.", 10
msg_ok_len equ $-msg_ok
msg_bad    db "bounded_memcpy rejected.", 10
msg_bad_len equ $-msg_bad

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

; bounded_memcpy(dst=rdi, dst_len=rsi, src=rdx, src_len=rcx, n=r8) -> rax=0 ok / 1 fail
bounded_memcpy:
    cmp r8, rsi
    ja .fail
    cmp r8, rcx
    ja .fail
    cld
    mov r9, rdi
    mov r10, rdx
    mov rdi, r9
    mov rsi, r10
    mov rcx, r8
    rep movsb
    xor eax, eax
    ret
.fail:
    mov eax, 1
    ret

_start:
    ; Case 1: success
    lea rdi, [dst]
    mov rsi, dst_len
    lea rdx, [src]
    mov rcx, src_len
    mov r8, [n1]
    call bounded_memcpy
    test eax, eax
    jne .bad

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call write_stdout

    ; Case 2: fail
    lea rdi, [dst]
    mov rsi, dst_len
    lea rdx, [src]
    mov rcx, src_len
    mov r8, [n2]
    call bounded_memcpy
    test eax, eax
    je .bad_should_fail

    lea rsi, [msg_bad]
    mov edx, msg_bad_len
    call write_stdout

    xor edi, edi
    jmp exit_

.bad_should_fail:
.bad:
    mov edi, 1
    jmp exit_
