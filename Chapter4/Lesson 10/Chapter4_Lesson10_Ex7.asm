bits 64
default rel

; LEA is commonly used to take the address of a stack local: &local.
; This example builds two locals and writes one byte from each (for demonstration).

global _start

section .text
_start:
    ; Reserve 32 bytes of stack space (keep alignment reasonable)
    sub rsp, 32

    ; locals:
    ; [rsp+0]  = byte local_a
    ; [rsp+8]  = qword local_b
    mov byte [rsp+0], 'A'
    mov qword [rsp+8], 0x0A42424242424242  ; '\n' + 'B's (little-endian)

    ; rsi = &local_a
    lea rsi, [rsp+0]
    mov edx, 1
    mov eax, 1
    mov edi, 1
    syscall

    ; rsi = &local_b (print first byte only)
    lea rsi, [rsp+8]
    mov edx, 1
    mov eax, 1
    mov edi, 1
    syscall

    add rsp, 32
    mov eax, 60
    xor edi, edi
    syscall
