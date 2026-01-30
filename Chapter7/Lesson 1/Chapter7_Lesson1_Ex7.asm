; Chapter 7 - Lesson 1
; Exercise Solution 1:
;   Robust register save/restore macros + "stack cookie" to detect imbalance.
;
; The goal is to make it HARD to accidentally mismatch PUSH/POP sets.
;
; Build:
;   nasm -felf64 Chapter7_Lesson1_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o
;   ./ex7

global _start

%define STACK_COOKIE 0x7a6b5c4d3e2f1a0b

section .data
ok:   db "OK: stack cookie verified; regs restored",10
ok_l: equ $-ok
bad:  db "FAIL: stack imbalance detected",10
bad_l: equ $-bad

section .text

; Save a chosen set of GPRs (SysV) and drop a cookie.
; You can tailor which regs you consider part of your function's "callee saves".
%macro SAVE_GPRS 0
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rax, STACK_COOKIE
    push rax
%endmacro

%macro RESTORE_GPRS 0
    ; verify cookie first
    pop rax
    cmp rax, STACK_COOKIE
    jne .stack_bad
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
%endmacro

_start:
    ; poison registers so we can see they come back intact
    mov rbx, 0x1111
    mov r12, 0x2222
    mov r13, 0x3333
    mov r14, 0x4444
    mov r15, 0x5555

    call demo

    ; if demo restored, we should see original values
    cmp rbx, 0x1111
    jne .stack_bad
    cmp r12, 0x2222
    jne .stack_bad
    cmp r13, 0x3333
    jne .stack_bad
    cmp r14, 0x4444
    jne .stack_bad
    cmp r15, 0x5555
    jne .stack_bad

    mov rdi, ok
    mov rsi, ok_l
    call write_buf
    xor edi, edi
    jmp do_exit

.stack_bad:
    mov rdi, bad
    mov rsi, bad_l
    call write_buf
    mov edi, 1

do_exit:
    mov eax, 60
    syscall

demo:
    ; Suppose demo is a complex function that must preserve non-volatile regs.
    SAVE_GPRS

    ; do arbitrary work that clobbers regs
    xor rbx, rbx
    xor r12, r12
    xor r13, r13
    xor r14, r14
    xor r15, r15

    RESTORE_GPRS
    ret

write_buf:
    mov eax, 1
    mov edi, 1
    mov rdx, rsi
    mov rsi, rdi
    syscall
    ret
