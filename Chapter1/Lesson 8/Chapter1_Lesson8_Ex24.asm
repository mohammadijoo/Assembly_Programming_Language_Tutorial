; file: caller_bug.asm
extern broken_sum
global _start
section .text
_start:
    mov rbx, 123456          ; caller assumes rbx survives the call
    mov rdi, 10
    mov rsi, 20
    call broken_sum

    ; if rbx changed, the caller's invariant is broken
    ; exit(0) if intact, exit(1) if corrupted
    cmp rbx, 123456
    jne .bad
    mov rdi, 0
    jmp .done
.bad:
    mov rdi, 1
.done:
    mov rax, 60
    syscall
