; Chapter 3 - Lesson 9 (Programming Exercises with Solutions)
; Ex16 (Exercise 4 Solution):
;   Implement add_i64_checked in a "mostly branchless" style:
;     - compute sum
;     - compute overflow flag using SETO
;     - if overflow, return saturated result (INT64_MAX or INT64_MIN)
;
; Contract:
;   Inputs:  RAX = a (int64), RBX = b (int64)
;   Outputs: RAX = sum if no overflow else saturated
;            BL  = overflow (0/1)
;
; This uses:
;   - ADD + SETO to capture overflow
;   - CMOV to select saturation without branching on data-dependent paths

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
hdr:   db "Exercise 4: add_i64_checked with saturation (SETO + CMOV)",10,0
lbl_a: db "  a=",0
lbl_b: db " b=",0
lbl_r: db " result=",0
lbl_o: db " ovf=",0
nl:    db 10,0

section .text

add_i64_checked_sat:
    ; RAX=a, RBX=b
    mov rcx, rax                 ; keep a sign
    add rax, rbx
    seto bl                      ; capture overflow into BL (0/1)

    ; Prepare saturation candidates in R8 and R9
    mov r8, 0x7FFFFFFFFFFFFFFF   ; INT64_MAX
    mov r9, 0x8000000000000000   ; INT64_MIN

    ; If overflow occurred, saturation sign depends on sign of a (and b).
    ; For two's complement add overflow, a and b have same sign.
    ; If a>=0 => positive overflow => INT64_MAX, else INT64_MIN.
    test rcx, rcx
    cmovs r8, r9                 ; if a negative, choose INT64_MIN into R8

    ; If overflow, move saturation into RAX
    test bl, bl
    cmovne rax, r8
    ret

print_case:
    ; Inputs: RAX=a, RBX=b
    push rax
    push rbx

    PRINTZ lbl_a
    mov rax, [rsp + 8]           ; a
    call print_i64_nl

    PRINTZ lbl_b
    mov rax, [rsp]               ; b
    call print_i64_nl

    pop rbx
    pop rax

    call add_i64_checked_sat

    PRINTZ lbl_r
    call print_i64_nl

    PRINTZ lbl_o
    movzx rax, bl
    call print_u64_nl
    call print_nl
    ret

_start:
    PRINTZ hdr

    ; Case 1: INT64_MAX + 1 => overflow => clamp to INT64_MAX
    mov rax, 0x7FFFFFFFFFFFFFFF
    mov rbx, 1
    call print_case

    ; Case 2: INT64_MIN + (-1) => overflow => clamp to INT64_MIN
    mov rax, 0x8000000000000000
    mov rbx, -1
    call print_case

    ; Case 3: 123 + 456 => no overflow
    mov rax, 123
    mov rbx, 456
    call print_case

    ; Case 4: -500 + 200 => no overflow
    mov rax, -500
    mov rbx, 200
    call print_case

    jmp exit0
