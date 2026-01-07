; Chapter 4 - Lesson 6 (Stack Operations) - Exercise 1 Solution (Hard)
; Implement a stack-based calling convention function: add3_stack(a,b,c).
; Caller pushes args right-to-left (cdecl-like): push c; push b; push a; call.
; Callee reads args from [rbp+16], [rbp+24], [rbp+32] and returns sum in RAX.

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

add3_stack:
    push rbp
    mov rbp, rsp
    mov rax, [rbp + 16]                         ; a
    add rax, [rbp + 24]                         ; + b
    add rax, [rbp + 32]                         ; + c
    pop rbp
    ret

_start:
    ; Mark bottom of frame chain for later debugging patterns
    xor ebp, ebp

    ; Push args right-to-left: c, b, a
    push qword 30
    push qword 20
    push qword 10
    call add3_stack
    add rsp, 24                                  ; caller cleans (cdecl-like)

    ; Print result (expected 60)
    call print_hex64

    mov eax, 60
    xor edi, edi
    syscall
