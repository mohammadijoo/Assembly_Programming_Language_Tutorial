; Chapter 4 - Lesson 11 (Example 6)
; Branching vs CMOV: branching can SKIP expensive work.
; We count how many loop-iterations "expensive" executes.
; Output (work_count as hex):
;   1) branch_select cond=0  -> 0
;   2) cmov_select   cond=0  -> iters
;   3) branch_select cond=1  -> iters
;   4) cmov_select   cond=1  -> iters

bits 64
default rel
%include "Chapter4_Lesson11_Ex8.asm"

section .bss
work_count resq 1

section .text
global _start

expensive:
    ; RCX = iteration count
    xor rax, rax
.loop:
    add qword [rel work_count], 1
    imul rax, rax, 3
    add rax, 1
    dec rcx
    jne .loop
    ret

branch_select:
    ; EDI = cond (0/1), ECX = iters
    test edi, edi
    jz .zero
    call expensive
    ret
.zero:
    xor eax, eax
    ret

cmov_select:
    ; EDI = cond (0/1), ECX = iters
    call expensive
    mov rbx, rax            ; expensive result
    xor eax, eax            ; else-value = 0
    test edi, edi
    cmovne rax, rbx         ; if cond!=0, select expensive result
    ret

_start:
    ; cond=0, branch version
    mov qword [rel work_count], 0
    mov edi, 0
    mov ecx, 1000
    call branch_select
    mov rdi, [rel work_count]
    call print_hex_u64

    ; cond=0, cmov version
    mov qword [rel work_count], 0
    mov edi, 0
    mov ecx, 1000
    call cmov_select
    mov rdi, [rel work_count]
    call print_hex_u64

    ; cond=1, branch version
    mov qword [rel work_count], 0
    mov edi, 1
    mov ecx, 1000
    call branch_select
    mov rdi, [rel work_count]
    call print_hex_u64

    ; cond=1, cmov version
    mov qword [rel work_count], 0
    mov edi, 1
    mov ecx, 1000
    call cmov_select
    mov rdi, [rel work_count]
    call print_hex_u64

    EXIT 0
