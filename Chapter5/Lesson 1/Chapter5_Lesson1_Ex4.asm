BITS 64
default rel
global _start

; Else-if ladder example:
;   if score >= 90 -> A
;   else if score >= 80 -> B
;   else if score >= 70 -> C
;   else if score >= 60 -> D
;   else -> F

section .data
score dq 85

msg_A db "Grade: A", 10
msg_A_len equ $-msg_A
msg_B db "Grade: B", 10
msg_B_len equ $-msg_B
msg_C db "Grade: C", 10
msg_C_len equ $-msg_C
msg_D db "Grade: D", 10
msg_D_len equ $-msg_D
msg_F db "Grade: F", 10
msg_F_len equ $-msg_F

section .text
_start:
    mov rax, [score]

    cmp rax, 90
    jge .A
    cmp rax, 80
    jge .B
    cmp rax, 70
    jge .C
    cmp rax, 60
    jge .D
    jmp .F

.A:
    mov rsi, msg_A
    mov rdx, msg_A_len
    jmp .print
.B:
    mov rsi, msg_B
    mov rdx, msg_B_len
    jmp .print
.C:
    mov rsi, msg_C
    mov rdx, msg_C_len
    jmp .print
.D:
    mov rsi, msg_D
    mov rdx, msg_D_len
    jmp .print
.F:
    mov rsi, msg_F
    mov rdx, msg_F_len

.print:
    mov rax, 1
    mov rdi, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall
