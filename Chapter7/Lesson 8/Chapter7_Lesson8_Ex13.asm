; Chapter7_Lesson8_Ex13.asm
; Exercise Solution: Minimal errno decoder for negative syscall returns.
; Demonstrates reading a negative rax and mapping a few common codes to messages.
; NASM, Linux x86-64 (ELF64)

%include "Chapter7_Lesson8_Ex9.asm"

default rel
global _start

section .data
msg_intro: db "Errno decode demo: call write() with invalid ptr; decode -errno.", 10
len_intro: equ $-msg_intro

msg_raw: db "raw rax: "
len_raw: equ $-msg_raw

msg_efault: db "decoded: EFAULT (bad address)", 10
len_efault: equ $-msg_efault

msg_einval: db "decoded: EINVAL (invalid argument)", 10
len_einval: equ $-msg_einval

msg_other: db "decoded: other errno", 10
len_other: equ $-msg_other

nl: db 10

section .bss
numbuf: resb 32

section .text
_start:
    and rsp, -16

    syscall3 SYS_write, 1, msg_intro, len_intro

    ; Force failure: invalid pointer
    mov rsi, 0xffff800000000000
    syscall3 SYS_write, 1, rsi, 8       ; rax negative on failure

    ; Print raw return
    syscall3 SYS_write, 1, msg_raw, len_raw
    mov rdi, rax
    call i64_to_dec
    syscall3 SYS_write, 1, rsi, rdx
    syscall3 SYS_write, 1, nl, 1

    ; errno = -rax
    mov rbx, rax
    neg rbx

    cmp rbx, 14               ; EFAULT is typically 14
    je .efault
    cmp rbx, 22               ; EINVAL is typically 22
    je .einval

    syscall3 SYS_write, 1, msg_other, len_other
    syscall1 SYS_exit, 0

.efault:
    syscall3 SYS_write, 1, msg_efault, len_efault
    syscall1 SYS_exit, 0

.einval:
    syscall3 SYS_write, 1, msg_einval, len_einval
    syscall1 SYS_exit, 0

; Convert signed rdi to decimal ASCII (no trailing newline)
; Output: rsi=ptr, rdx=len
i64_to_dec:
    push rbx
    lea rbx, [rel numbuf + 31]
    mov byte [rbx], 0
    dec rbx

    mov rax, rdi
    cmp rax, 0
    jge .pos
    neg rax
    mov r10b, 1
    jmp .conv
.pos:
    mov r10b, 0

.conv:
    cmp rax, 0
    jne .loop
    mov byte [rbx], '0'
    jmp .done_digits

.loop:
    xor rdx, rdx
    mov rcx, 10
    div rcx
    add dl, '0'
    mov [rbx], dl
    dec rbx
    test rax, rax
    jne .loop

.done_digits:
    inc rbx

    cmp r10b, 0
    je .emit
    dec rbx
    mov byte [rbx], '-'

.emit:
    mov rsi, rbx
    lea rdx, [rel numbuf + 32]
    sub rdx, rsi
    pop rbx
    ret
