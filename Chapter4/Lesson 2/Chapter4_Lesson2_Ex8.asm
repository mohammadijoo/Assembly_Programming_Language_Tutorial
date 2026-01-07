; Chapter 4 - Lesson 2 (Logical Instructions): Exercise 1 Solution
; Constant-time buffer equality (secure memcmp):
; diff |= (a[i] XOR b[i]) for all i, then diff==0 => equal.
; This avoids data-dependent branches on the contents.

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
a db 1,2,3,4,5,6,7,8,  9,10,11,12,13,14,15,16,  17,18,19,20,21,22,23,24,  25,26,27,28,29,30,31,32
b db 1,2,3,4,5,6,7,8,  9,10,11,12,13,14,15,16,  17,18,19,20,21,22,23,24,  25,26,27,28,29,30,31,32
n equ 32

msg_eq db "Buffers are EQUAL (constant-time check).",10,0
len_msg_eq equ $-msg_eq
msg_ne db "Buffers are DIFFERENT (constant-time check).",10,0
len_msg_ne equ $-msg_ne

SECTION .text
write_stdout:
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    ret

_start:
    xor rdx, rdx            ; rdx low byte will hold diff accumulator (DL)
    xor rcx, rcx            ; i = 0
.loop:
    mov al, [a+rcx]
    mov bl, [b+rcx]
    xor al, bl              ; al = a[i] XOR b[i]
    or  dl, al              ; diff |= al
    inc rcx
    cmp rcx, n
    jb .loop

    test dl, dl
    jz .equal

    lea rsi, [msg_ne]
    mov rdx, len_msg_ne
    call write_stdout
    jmp .done

.equal:
    lea rsi, [msg_eq]
    mov rdx, len_msg_eq
    call write_stdout

.done:
    mov rax, SYS_exit
    xor rdi, rdi
    syscall
