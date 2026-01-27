; Chapter 6 - Lesson 12 (Example 5)
; Tail-call safety with stack-passed arguments on SysV AMD64.
; Signature with 8 args: a1..a8. First 6 in registers, a7/a8 on the stack.
; If we tail-jump to another function with the SAME signature, we can reuse
; the caller-provided stack arg slots without pushing anything.

BITS 64
DEFAULT REL

global _start

section .text

; uint64_t g8(a1,a2,a3,a4,a5,a6,a7,a8) = sum(args)
g8:
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    add rax, rcx
    add rax, r8
    add rax, r9
    add rax, [rsp + 8]      ; a7 (above return address)
    add rax, [rsp + 16]     ; a8
    ret

; uint64_t f8(a1..a8): returns g8(a1+1, a2..a8) via tail jump
f8:
    add rdi, 1              ; modify a1
    jmp g8                  ; tail call (stack layout unchanged)

_start:
    ; Provide 8 args. a1..a6 in regs, a7/a8 on stack.
    mov rdi, 1
    mov rsi, 2
    mov rdx, 3
    mov rcx, 4
    mov r8,  5
    mov r9,  6

    ; Kernel enters _start with 16-byte aligned RSP on Linux x86-64.
    push 8                  ; a8
    push 7                  ; a7
    call f8
    add rsp, 16             ; clean a7/a8 (cdecl-style at this call site)

    mov rdi, rax
    mov rax, 60
    syscall
