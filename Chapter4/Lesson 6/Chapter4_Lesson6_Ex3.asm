; Chapter 4 - Lesson 6 (Stack Operations) - Example 3
; Immediate pushes: imm8 and imm32 are sign-extended when pushed in 64-bit mode.

default rel
global _start

section .data
hex_digits: db "0123456789ABCDEF"
hex_buf:    db "0x", 16 dup("0"), 10

section .text
write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

to_hex64:
    push rbx
    lea rbx, [hex_digits]
    mov rcx, 16
.hex_loop:
    mov rdx, rax
    and rdx, 0xF
    mov dl, [rbx + rdx]
    mov [rdi + rcx - 1], dl
    shr rax, 4
    loop .hex_loop
    pop rbx
    ret

print_hex64:
    sub rsp, 8
    lea rdi, [hex_buf + 2]
    call to_hex64
    lea rsi, [hex_buf]
    mov edx, 19
    call write_stdout
    add rsp, 8
    ret

_start:
    ; PUSH imm8: sign-extends imm8 to 64-bit before storing.
    push byte -1
    pop rax
    call print_hex64                             ; 0xFFFFFFFFFFFFFFFF

    ; PUSH imm32: sign-extends imm32 to 64-bit before storing.
    push dword 0x7FFFFFFF
    pop rax
    call print_hex64                             ; 0x000000007FFFFFFF

    push dword 0x80000000
    pop rax
    call print_hex64                             ; 0xFFFFFFFF80000000

    mov eax, 60
    xor edi, edi
    syscall
