BITS 64
default rel
global _start

; Short-circuit AND example:
;   if (den != 0 && (num/den) > 10) -> "big"
;   else -> "small_or_invalid"
;
; Key: do not execute IDIV when den == 0.

section .data
num dq 123
den dq 7

msg_big db "Condition true: den!=0 AND num/den > 10", 10
msg_big_len equ $-msg_big

msg_else db "Condition false: den==0 OR num/den <= 10", 10
msg_else_len equ $-msg_else

section .text
_start:
    mov rbx, [den]
    test rbx, rbx
    jz .else_branch                 ; short-circuit: den == 0 -> else

    mov rax, [num]
    cqo                             ; sign-extend RAX into RDX for IDIV
    idiv rbx                        ; quotient in RAX

    cmp rax, 10
    jle .else_branch

.then_branch:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_big
    mov rdx, msg_big_len
    syscall
    jmp .exit

.else_branch:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_else
    mov rdx, msg_else_len
    syscall

.exit:
    mov rax, 60
    xor rdi, rdi
    syscall
