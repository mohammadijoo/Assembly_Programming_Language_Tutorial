; Chapter 6 - Lesson 2 - Example 4
; File: Chapter6_Lesson2_Ex4.asm
; Topic: Callee-saved register discipline (RBX must be preserved in SysV)
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson2_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o
; Run:
;   ./ex4 ; exit 0 if RBX preserved, else exit 1

default rel
section .text
global _start

; use_rbx_demo(uint64_t x) -> RAX = x*3
; Uses RBX internally but preserves it.
use_rbx_demo:
    push rbx
    mov rbx, rdi
    lea rax, [rbx + rbx*2]   ; 3*x
    pop rbx
    ret

_start:
    mov rbx, 0x1122334455667788
    mov rdi, 7
    call use_rbx_demo

    ; Check RBX preserved
    cmp rbx, 0x1122334455667788
    jne .fail

    ; Also check result 21 (optional)
    cmp rax, 21
    jne .fail

    mov eax, 60
    xor edi, edi
    syscall

.fail:
    mov eax, 60
    mov edi, 1
    syscall
