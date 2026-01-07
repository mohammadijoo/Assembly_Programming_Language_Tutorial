; Chapter 4 - Lesson 5 (Exercise Solution)
; File: Chapter4_Lesson5_Ex9.asm
; Task: Implement strcmp-like lexicographic compare returning -1 / 0 / +1 (unsigned char semantics).
; Build:
;   nasm -felf64 Chapter4_Lesson5_Ex9.asm -o ex9.o
;   ld ex9.o -o ex9

%include "Chapter4_Lesson5_Ex1.asm"

global _start

section .data
s1: db "alpha", 0
s2: db "alpHa", 0

msg_lt: db "strcmp3(s1,s2) = -1 (s1 < s2)", 10, 0
msg_eq: db "strcmp3(s1,s2) =  0 (equal)", 10, 0
msg_gt: db "strcmp3(s1,s2) = +1 (s1 > s2)", 10, 0

section .text
; int64 strcmp3(rsi=s1, rdi=s2) -> rax in {-1,0,+1}
strcmp3:
.loop:
    mov al, [rsi]
    mov bl, [rdi]
    cmp al, bl
    jne .diff
    test al, al
    je .eq
    inc rsi
    inc rdi
    jmp .loop

.diff:
    ; unsigned comparison for bytes
    ja .gt
    jb .lt

.eq:
    xor eax, eax
    ret

.gt:
    mov eax, 1
    ret

.lt:
    mov eax, -1
    cdqe                   ; sign-extend eax into rax
    ret

_start:
    lea rsi, [rel s1]
    lea rdi, [rel s2]
    call strcmp3

    cmp rax, 0
    je .print_eq
    jl .print_lt
    jg .print_gt

.print_eq:
    lea rsi, [rel msg_eq]
    call print_cstr
    SYS_EXIT 0

.print_lt:
    lea rsi, [rel msg_lt]
    call print_cstr
    SYS_EXIT 0

.print_gt:
    lea rsi, [rel msg_gt]
    call print_cstr
    SYS_EXIT 0
