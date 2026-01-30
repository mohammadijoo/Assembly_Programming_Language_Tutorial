; Chapter7_Lesson8_Ex8.asm
; Kernel validates user pointers: write(fd=1, buf=invalid, len=8) returns -EFAULT (no crash).
; NASM, Linux x86-64 (ELF64)

%include "Chapter7_Lesson8_Ex9.asm"

default rel
global _start

section .data
msg_intro: db "write() with invalid user pointer returns negative errno (expected EFAULT).", 10
len_intro: equ $-msg_intro

msg_ret: db "syscall return (signed): "
len_ret: equ $-msg_ret

nl: db 10

section .bss
numbuf: resb 32

section .text
_start:
    and rsp, -16

    syscall3 SYS_write, 1, msg_intro, len_intro

    ; invalid pointer (likely unmapped / kernel range)
    mov rsi, 0xffff800000000000
    syscall3 SYS_write, 1, rsi, 8       ; rax will be negative on failure

    ; Print signed return
    syscall3 SYS_write, 1, msg_ret, len_ret
    mov rdi, rax                        ; signed value
    call i64_to_dec
    syscall3 SYS_write, 1, rsi, rdx

    syscall3 SYS_write, 1, nl, 1
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
