; Chapter 4 - Lesson 6 (Stack Operations) - Example 4
; PUSH/POP with memory operands + swap registers via the stack.

default rel
global _start

section .data
hex_digits: db "0123456789ABCDEF"
hex_buf:    db "0x", 16 dup("0"), 10

src: dq 0x1122334455667788
dst: dq 0

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
    ; Memory form: PUSH qword [src] stores the loaded value to the stack.
    push qword [src]
    pop  qword [dst]

    mov rax, [dst]
    call print_hex64

    ; Swap registers using the stack (LIFO):
    mov rdi, 0xAAAABBBBCCCCDDDD
    mov rsi, 0x1111222233334444

    push rdi
    push rsi
    pop  rdi                                     ; rdi <- old rsi
    pop  rsi                                     ; rsi <- old rdi

    mov rax, rdi
    call print_hex64
    mov rax, rsi
    call print_hex64

    mov eax, 60
    xor edi, edi
    syscall
