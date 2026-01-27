BITS 64
default rel

global _start

section .data
msg db "mul_add(): computed (a+b)*c into a global slot", 10
msg_len equ $-msg

align 8
g_result dq 0

section .text
_start:
    ; a=11, b=7, c=5 => (11+7)*5 = 90
    mov rdi, 11
    mov rsi, 7
    mov rdx, 5
    call mul_add

    mov [g_result], rax

    lea rdi, [msg]
    mov esi, msg_len
    call write_str

    mov eax, 60
    xor edi, edi
    syscall

; mul_add(a=rdi, b=rsi, c=rdx) -> rax
; Demonstrates local variables in a stack frame (frame pointer style).
mul_add:
    push rbp
    mov rbp, rsp
    ; After push rbp, RSP is 16-byte aligned on SysV AMD64.
    ; Allocate 32 bytes for locals (multiple of 16 keeps alignment).
    sub rsp, 32

    ; Spill arguments into local slots for readability/debuggability.
    mov [rbp-8],  rdi    ; local a
    mov [rbp-16], rsi    ; local b
    mov [rbp-24], rdx    ; local c

    mov rax, [rbp-8]
    add rax, [rbp-16]
    imul rax, [rbp-24]

    leave
    ret

write_str:
    mov edx, esi
    mov rsi, rdi
    mov edi, 1
    mov eax, 1
    syscall
    ret
