; Chapter 4 - Lesson 6 (Stack Operations) - Example 1
; Demonstrates LIFO order with PUSH/POP and prints popped values.

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
    ; PUSH pushes to lower addresses; POP returns the most recently pushed value (LIFO).
    push qword 0x1111111111111111
    push qword 0x2222222222222222

    pop rbx                                     ; rbx = 0x2222...
    pop rcx                                     ; rcx = 0x1111...

    mov rax, rbx
    call print_hex64
    mov rax, rcx
    call print_hex64

    mov eax, 60                                 ; SYS_exit
    xor edi, edi
    syscall
