; Chapter 2 - Lesson 7 (Execution Flow) - Example 2
; Demonstrates conditional branches and the signed vs unsigned distinction.
; Build:
;   nasm -f elf64 Chapter2_Lesson7_Ex2.asm -o ex2.o
;   ld ex2.o -o ex2

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .data
msg_intro  db "Compare A=-5 and B=3 using signed and unsigned branches:", 10
len_intro  equ $-msg_intro

msg_s_lt   db "Signed: A < B (JL taken)", 10
len_s_lt   equ $-msg_s_lt

msg_s_ge   db "Signed: A >= B (JL not taken)", 10
len_s_ge   equ $-msg_s_ge

msg_u_lt   db "Unsigned: A < B (JB taken)", 10
len_u_lt   equ $-msg_u_lt

msg_u_ge   db "Unsigned: A >= B (JB not taken)", 10
len_u_ge   equ $-msg_u_ge

SECTION .text
_start:
    ; print intro
    mov eax, 1
    mov edi, 1
    lea rsi, [msg_intro]
    mov edx, len_intro
    syscall

    mov eax, -5             ; A (32-bit, sign-extended to 64-bit in RAX)
    mov ebx, 3              ; B

    ; Signed comparison: uses SF, OF, ZF (JL/JGE family).
    cmp eax, ebx
    jl  .signed_less
.signed_ge:
    mov eax, 1
    mov edi, 1
    lea rsi, [msg_s_ge]
    mov edx, len_s_ge
    syscall
    jmp .unsigned_part
.signed_less:
    mov eax, 1
    mov edi, 1
    lea rsi, [msg_s_lt]
    mov edx, len_s_lt
    syscall

.unsigned_part:
    ; Unsigned comparison: uses CF, ZF (JB/JAE family).
    mov eax, -5
    mov ebx, 3
    cmp eax, ebx
    jb  .unsigned_less
.unsigned_ge:
    mov eax, 1
    mov edi, 1
    lea rsi, [msg_u_ge]
    mov edx, len_u_ge
    syscall
    jmp .exit
.unsigned_less:
    mov eax, 1
    mov edi, 1
    lea rsi, [msg_u_lt]
    mov edx, len_u_lt
    syscall

.exit:
    mov eax, 60
    xor edi, edi
    syscall
