; Chapter 6 - Lesson 8 (Example 1)
; Demonstration of a callee that violates the SysV AMD64 callee-saved contract (RBX).
; Build (Linux x86-64):
;   nasm -felf64 Chapter6_Lesson8_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
;   ./ex1

BITS 64
default rel
global _start

section .rodata
msg_fail db "FAIL: RBX clobbered by callee", 10
len_fail equ $-msg_fail
msg_ok   db "OK: RBX preserved (unexpected here)", 10
len_ok   equ $-msg_ok

section .text
bad_callee:
    ; BUG: RBX is callee-saved in SysV AMD64, but we overwrite it without saving.
    xor rbx, rbx
    ret

_start:
    mov rbx, 0x1122334455667788
    call bad_callee

    cmp rbx, 0x1122334455667788
    jne .fail

.ok:
    mov eax, 1          ; sys_write
    mov edi, 1          ; fd=stdout
    lea rsi, [rel msg_ok]
    mov edx, len_ok
    syscall

    mov eax, 60         ; sys_exit
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
