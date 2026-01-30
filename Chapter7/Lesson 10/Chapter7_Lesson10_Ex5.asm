; Chapter7_Lesson10_Ex5.asm
; Topic: Checked copy: dst capacity is a hard precondition (fail-closed)
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

section .data
src        db "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
src_len    equ $-src

dst        times 16 db 0
dst_cap    equ $-dst

n_good     dq 12
n_bad      dq 24

msg_ok     db "Copy succeeded.", 10
msg_ok_len equ $-msg_ok
msg_bad    db "Copy rejected (would overflow dst).", 10
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

; checked_copy(dst=rdi, cap=rsi, src=rdx, n=rcx) -> rax = 0 ok, 1 fail
checked_copy:
    cmp rcx, rsi
    ja .fail
    ; For realism, also check src has at least n bytes (here src is static, so omit)
    cld
    mov r8, rdi
    mov r9, rdx
    mov rdi, r8
    mov rsi, r9
    mov rdx, rcx
    mov rcx, rdx
    rep movsb
    xor eax, eax
    ret
.fail:
    mov eax, 1
    ret

_start:
    ; Good copy
    lea rdi, [dst]
    mov rsi, dst_cap
    lea rdx, [src]
    mov rcx, [n_good]
    call checked_copy
    test eax, eax
    jne .bad

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call write_stdout

    ; Bad copy (too large)
    lea rdi, [dst]
    mov rsi, dst_cap
    lea rdx, [src]
    mov rcx, [n_bad]
    call checked_copy
    test eax, eax
    je .bad_should_not

    lea rsi, [msg_bad]
    mov edx, msg_bad_len
    call write_stdout

    xor edi, edi
    jmp exit_

.bad_should_not:
.bad:
    mov edi, 2
    jmp exit_
