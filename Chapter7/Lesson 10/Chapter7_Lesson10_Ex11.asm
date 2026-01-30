; Chapter7_Lesson10_Ex11.asm
; Topic: checked_strlen: scan for NUL but stop at a hard maximum (repne scasb)
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

section .data
s1          db "hello", 0
s2          db "no-nul-in-first-8-bytes!!"  ; NUL exists later, but we cap at 8

msg_ok      db "Found NUL within bound.", 10
msg_ok_len  equ $-msg_ok
msg_bad     db "Rejected: no NUL within bound.", 10
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

; checked_strlen(ptr=rdi, max=rcx) -> rax=len, rdx=0 ok / 1 fail
checked_strlen:
    mov al, 0
    mov rsi, rdi              ; save start
    repne scasb               ; scans [rdi], rcx times max
    jne .fail                 ; ZF=0 => not found within max
    ; Found: rdi points 1 past NUL
    mov rax, rdi
    sub rax, rsi
    dec rax
    xor edx, edx
    ret
.fail:
    xor eax, eax
    mov edx, 1
    ret

_start:
    ; Case 1: OK (max=8)
    lea rdi, [s1]
    mov rcx, 8
    call checked_strlen
    test edx, edx
    jne .bad

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call write_stdout

    ; Case 2: FAIL (max=8)
    lea rdi, [s2]
    mov rcx, 8
    call checked_strlen
    test edx, edx
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
