; Chapter 4 - Lesson 6 (Stack Operations) - Example 5
; PUSHFQ/POPFQ: snapshot and modify RFLAGS via the stack.

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
    ; Clear Carry Flag (CF)
    clc
    pushfq
    pop rax                                      ; flags with CF=0
    call print_hex64

    ; Set Carry Flag (CF)
    stc
    pushfq
    pop rbx                                      ; flags with CF=1
    mov rax, rbx
    call print_hex64

    ; Toggle CF in a saved flags image, then load via POPFQ.
    xor rbx, 1                                   ; bit 0 is CF
    push rbx
    popfq                                        ; loads (some bits may be masked in user mode)

    pushfq
    pop rcx                                      ; re-read flags
    mov rax, rcx
    call print_hex64

    mov eax, 60
    xor edi, edi
    syscall
