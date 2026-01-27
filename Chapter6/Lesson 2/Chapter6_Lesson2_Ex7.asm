; Chapter 6 - Lesson 2 - Example 7
; File: Chapter6_Lesson2_Ex7.asm
; Topic: Procedure table + indirect call with bounds checks (safe dispatch)
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson2_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o
; Run:
;   ./ex7 ; exits 0 on success

default rel

section .text
global _start

op_add:
    ; RSI=a, RDX=b -> RAX=a+b
    lea rax, [rsi + rdx]
    ret

op_sub:
    ; RAX=a-b
    mov rax, rsi
    sub rax, rdx
    ret

op_mul:
    ; RAX=a*b
    mov rax, rsi
    imul rax, rdx
    ret

dispatch_op:
    ; Inputs:
    ;   EDI = op (0 add, 1 sub, 2 mul)
    ;   RSI = a, RDX = b
    ; Output:
    ;   RAX = result
    ;   CF=1 if invalid op (and RAX=0)
    cmp edi, 2
    ja .bad

    movsxd rdi, edi
    call qword [rel op_table + rdi*8]
    clc
    ret

.bad:
    xor eax, eax
    stc
    ret

section .rodata
op_table: dq op_add, op_sub, op_mul

_start:
    ; Test: (7 * 6) = 42
    mov edi, 2
    mov rsi, 7
    mov rdx, 6
    call dispatch_op
    jc .fail
    cmp rax, 42
    jne .fail

    ; Test invalid op: 99 should set CF
    mov edi, 99
    mov rsi, 1
    mov rdx, 2
    call dispatch_op
    jnc .fail

    mov eax, 60
    xor edi, edi
    syscall

.fail:
    mov eax, 60
    mov edi, 1
    syscall
