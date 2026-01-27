; Chapter 6 - Lesson 8 (Example 6)
; Leaf function discipline: if you avoid callee-saved regs, you can omit prologue/epilogue.
; Compares a leaf polynomial function vs a version that uses RBX (forcing save/restore).
; Build (Linux x86-64):
;   nasm -felf64 Chapter6_Lesson8_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
;   ./ex6

BITS 64
default rel
global _start

section .rodata
msg_ok   db "OK: leaf vs saved-reg version match", 10
len_ok   equ $-msg_ok
msg_fail db "FAIL: mismatch", 10
len_fail equ $-msg_fail

section .text
write_msg:
    mov eax, 1
    mov edi, 1
    syscall
    ret

; f(x) = (x*x + 3*x + 7) mod 2^64 (wraparound)
poly_leaf:
    ; args: rdi=x
    mov rax, rdi
    imul rax, rdi           ; x*x
    lea rax, [rax + rdi*3]  ; x*x + 3*x
    add rax, 7
    ret

poly_uses_rbx:
    ; Same computation, but uses RBX as a temporary -> must preserve it.
    push rbx
    mov rbx, rdi
    mov rax, rbx
    imul rax, rbx
    lea rax, [rax + rbx*3]
    add rax, 7
    pop rbx
    ret

_start:
    mov rbx, 0xA0A0A0A0A0A0A0A0    ; sentinel: must be preserved across poly_uses_rbx
    mov rdi, 123456789
    call poly_leaf
    mov r12, rax                  ; save result in callee-saved (safe here in _start)

    mov rdi, 123456789
    call poly_uses_rbx

    cmp rbx, 0xA0A0A0A0A0A0A0A0
    jne .fail
    cmp rax, r12
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
