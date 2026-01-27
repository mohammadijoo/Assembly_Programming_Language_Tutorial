BITS 64
default rel

global _start

section .data
msg_ok db "sum3_leaf(): used locals addressed off RSP (no RBP frame)", 10
msg_ok_len equ $-msg_ok

section .text
_start:
    mov rdi, 10
    mov rsi, 20
    mov rdx, 30
    call sum3_leaf

    ; Exit status = low 8 bits of result (60)
    mov edi, eax

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call write_str_rsi_rdx

    mov eax, 60
    syscall

; sum3_leaf(x=rdi, y=rsi, z=rdx) -> rax
; Leaf function: no nested calls, so we may ignore alignment here.
; Demonstrates locals addressed relative to RSP.
sum3_leaf:
    sub rsp, 24
    mov [rsp+0],  rdi
    mov [rsp+8],  rsi
    mov [rsp+16], rdx

    mov rax, [rsp+0]
    add rax, [rsp+8]
    add rax, [rsp+16]

    add rsp, 24
    ret

; write_str_rsi_rdx(rsi=ptr, rdx=len) using sys_write(fd=1)
write_str_rsi_rdx:
    mov edi, 1
    mov eax, 1
    syscall
    ret
