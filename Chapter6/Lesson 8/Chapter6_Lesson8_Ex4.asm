; Chapter 6 - Lesson 8 (Example 4)
; Non-leaf function that uses callee-saved registers and must also maintain stack alignment.
; Implements dot4(a[4], b[4]) calling mul64 in the loop.
; Build (Linux x86-64):
;   nasm -felf64 Chapter6_Lesson8_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o
;   ./ex4

BITS 64
default rel
global _start

section .rodata
msg_ok   db "OK: dot4 computed expected result", 10
len_ok   equ $-msg_ok
msg_fail db "FAIL: dot4 mismatch", 10
len_fail equ $-msg_fail

section .data
a dq 1, 2, 3, 4
b dq 10, 20, 30, 40

section .text
write_msg:
    mov eax, 1
    mov edi, 1
    syscall
    ret

mul64:
    ; leaf: rdi * rsi -> rax
    mov rax, rdi
    imul rax, rsi
    ret

dot4:
    ; SysV AMD64:
    ;   args: rdi=ptrA, rsi=ptrB
    ;   returns: rax
    ; Uses RBX, R12, R13, R14 (callee-saved), and performs CALLs -> must align stack.
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8              ; align RSP to 16 bytes before CALL (entry is 16n+8)

    mov r12, rdi            ; keep pointers in callee-saved regs
    mov r13, rsi
    xor r14, r14            ; accumulator
    xor ebx, ebx            ; i=0..3

.loop:
    mov rdi, [r12 + rbx*8]
    mov rsi, [r13 + rbx*8]
    call mul64              ; clobbers caller-saved regs (allowed)
    add r14, rax

    inc ebx
    cmp ebx, 4
    jne .loop

    mov rax, r14

    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

_start:
    lea rdi, [rel a]
    lea rsi, [rel b]
    call dot4

    cmp rax, 300
    jne .fail

    lea rsi, [rel msg_ok]
    mov edx, len_ok
    call write_msg
    mov eax, 60
    xor edi, edi
    syscall

.fail:
    lea rsi, [rel msg_fail]
    mov edx, len_fail
    call write_msg
    mov eax, 60
    mov edi, 1
    syscall
