BITS 64
default rel

global _start
global call_count

section .data
msg db "call_count(): static local storage using a NASM local label (.counter)", 10
msg_len equ $-msg

section .text
_start:
    call call_count
    call call_count
    call call_count
    ; EAX now holds 3

    lea rdi, [msg]
    mov esi, msg_len
    call write_str

    mov eax, 60
    xor edi, edi
    syscall

; call_count() -> rax
; Each call increments a *static* cell that persists across calls.
call_count:
    mov rax, [rel .counter]
    inc rax
    mov [rel .counter], rax
    ret

section .data
align 8
.counter dq 0

section .text
write_str:
    mov edx, esi
    mov rsi, rdi
    mov edi, 1
    mov eax, 1
    syscall
    ret
