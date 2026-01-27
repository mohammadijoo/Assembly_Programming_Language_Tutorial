BITS 64
default rel

global _start

section .data
msg db "Exercise Solution: u64_to_dec + write_u64 (stack local buffer)", 10
msg_len equ $-msg

section .text
_start:
    lea rdi, [msg]
    mov esi, msg_len
    call write_str

    ; print 18446744073709551615 (2^64-1)
    mov rdi, -1
    call write_u64

    mov eax, 60
    xor edi, edi
    syscall

; write_u64(val=rdi)
; Uses a 32-byte local buffer on the stack.
write_u64:
    push rbp
    mov rbp, rsp
    sub rsp, 48            ; 32 bytes buffer + padding (multiple of 16)

    lea rsi, [rbp-32]      ; buf base
    mov edx, 32            ; buf capacity
    call u64_to_dec        ; returns rax=ptr, ecx=len

    ; write number
    mov rsi, rax
    mov edx, ecx
    mov edi, 1
    mov eax, 1
    syscall

    ; write newline
    mov byte [rbp-1], 10
    lea rsi, [rbp-1]
    mov edx, 1
    mov edi, 1
    mov eax, 1
    syscall

    leave
    ret

; u64_to_dec(val=rdi, buf=rsi, cap=edx) -> rax=ptr_to_digits, ecx=len
; Writes digits right-aligned in [buf, buf+cap).
; Requires cap >= 1. Does not write a terminator.
u64_to_dec:
    ; Strategy: fill from end backwards using DIV 10.
    mov rax, rdi
    lea r8, [rsi+rdx]      ; end
    mov rcx, 0             ; len

    ; Special-case 0
    test rax, rax
    jnz .loop
    dec r8
    mov byte [r8], '0'
    mov ecx, 1
    mov rax, r8
    ret

.loop:
    xor edx, edx
    mov r9, 10
    div r9                 ; rax/=10, rdx=remainder
    dec r8
    add dl, '0'
    mov [r8], dl
    inc ecx
    test rax, rax
    jnz .loop

    mov rax, r8
    ret

write_str:
    mov edx, esi
    mov rsi, rdi
    mov edi, 1
    mov eax, 1
    syscall
    ret
