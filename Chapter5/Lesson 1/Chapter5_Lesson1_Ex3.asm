BITS 64
default rel
global _start

section .data
a dq 100
b dq 200

x dq 0x1111111111111111
y dq 0x2222222222222222
result dq 0

msg_x db "Selected X (a < b unsigned)", 10
msg_x_len equ $-msg_x

msg_y db "Selected Y (a >= b unsigned)", 10
msg_y_len equ $-msg_y

section .text
_start:
    mov rax, [a]
    mov rbx, [b]

    ; Unsigned compare:
    ; If a < b, then CF=1 after CMP a,b.
    cmp rax, rbx
    sbb rcx, rcx                    ; rcx = -1 if CF=1 else 0

    mov rdx, [x]
    mov r8,  [y]

    ; result = (x & rcx) | (y & ~rcx)
    and rdx, rcx
    not rcx
    and r8, rcx
    or  rdx, r8

    mov [result], rdx

    ; Verify selection with a simple branch (for messaging only).
    cmp rdx, [x]
    jne .print_y

.print_x:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_x
    mov rdx, msg_x_len
    syscall
    jmp .exit

.print_y:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_y
    mov rdx, msg_y_len
    syscall

.exit:
    mov rax, 60
    xor rdi, rdi
    syscall
