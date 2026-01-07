BITS 64
default rel
global _start

section .data
s0 db "case 0", 10
s0_len equ $ - s0
s1 db "case 1", 10
s1_len equ $ - s1
s2 db "case 2", 10
s2_len equ $ - s2
s3 db "case 3", 10
s3_len equ $ - s3
sd db "default", 10
sd_len equ $ - sd

jump_table:
    dq case0, case1, case2, case3

section .text
_start:
    ; Jump-table "switch" using an *indirect* JMP through memory:
    ;   if (x > 3) goto default; else goto jump_table[x]

    mov eax, 2                 ; x (try changing 0..3; others hit default)
    cmp eax, 3
    ja  default_case

    ; rax is 0..3 here. Scale by 8 for 64-bit addresses.
    jmp qword [rel jump_table + rax*8]

case0:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel s0]
    mov edx, s0_len
    syscall
    jmp exit0

case1:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel s1]
    mov edx, s1_len
    syscall
    jmp exit0

case2:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel s2]
    mov edx, s2_len
    syscall
    jmp exit0

case3:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel s3]
    mov edx, s3_len
    syscall
    jmp exit0

default_case:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel sd]
    mov edx, sd_len
    syscall

exit0:
    mov eax, 60
    xor edi, edi
    syscall
