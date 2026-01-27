; Chapter 6 - Lesson 8 (Example 2)
; Correct callee: preserves RBX (callee-saved) using push/pop.
; Build (Linux x86-64):
;   nasm -felf64 Chapter6_Lesson8_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
;   ./ex2

BITS 64
default rel
global _start

section .rodata
msg_ok   db "OK: RBX preserved by callee", 10
len_ok   equ $-msg_ok
msg_fail db "FAIL: RBX changed", 10
len_fail equ $-msg_fail

section .text
good_callee:
    ; SysV AMD64: RBX must be preserved by the callee.
    push rbx
    xor rbx, rbx
    ; ... body that uses RBX ...
    pop rbx
    ret

_start:
    mov rbx, 0x1122334455667788
    call good_callee

    cmp rbx, 0x1122334455667788
    jne .fail

    mov eax, 1
    mov edi, 1
    lea rsi, [rel msg_ok]
    mov edx, len_ok
    syscall

    mov eax, 60
    xor edi, edi
    syscall

.fail:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel msg_fail]
    mov edx, len_fail
    syscall

    mov eax, 60
    mov edi, 1
    syscall
