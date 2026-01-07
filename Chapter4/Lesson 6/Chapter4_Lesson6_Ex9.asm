; Chapter 4 - Lesson 6 (Stack Operations) - Exercise 3 Solution (Very Hard)
; Build a small call chain and walk the frame-pointer (RBP) chain to print return addresses.
; This requires functions to use RBP as a frame pointer (push rbp / mov rbp,rsp).

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

backtrace:
    push rbp
    mov rbp, rsp

    mov rbx, [rbp + 16]                          ; rbx = starting frame pointer
    mov ecx, 16                                  ; max frames

.bt_loop:
    test rbx, rbx
    jz .bt_done
    mov rax, [rbx + 8]                           ; return address saved by CALL in that frame
    call print_hex64
    mov rbx, [rbx]                               ; previous frame pointer
    loop .bt_loop

.bt_done:
    pop rbp
    ret

f3:
    push rbp
    mov rbp, rsp

    ; Walk from current frame pointer
    mov rdi, rbp
    call backtrace

    pop rbp
    ret

f2:
    push rbp
    mov rbp, rsp
    call f3
    pop rbp
    ret

f1:
    push rbp
    mov rbp, rsp
    call f2
    pop rbp
    ret

_start:
    ; Initialize "bottom" of the RBP chain.
    xor ebp, ebp

    call f1

    mov eax, 60
    xor edi, edi
    syscall
