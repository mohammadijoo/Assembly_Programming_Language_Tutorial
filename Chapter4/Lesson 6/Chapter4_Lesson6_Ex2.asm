; Chapter 4 - Lesson 6 (Stack Operations) - Example 2
; Operand-size corner case: PUSH/POP with 16-bit operands in 64-bit mode.
; In long mode, PUSH r/m16 decrements RSP by 2 (not 8). This can break ABI alignment.

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
    mov rbx, rsp                                ; save original RSP

    mov ax, 0x1234
    push ax                                     ; RSP = RSP - 2

    mov rcx, rsp
    sub rbx, rcx                                ; rbx = bytes pushed (expected 2)
    mov r12, rbx                                ; preserve delta before restoring stack

    pop dx                                      ; DX = 0x1234, RSP restored

    ; Print delta (should be 0x...0002)
    mov rax, r12
    call print_hex64

    ; Print popped 16-bit value (zero-extended)
    movzx rax, dx
    call print_hex64

    mov eax, 60
    xor edi, edi
    syscall
