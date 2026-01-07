; Chapter 4 - Lesson 2 (Logical Instructions): Example 4
; Bitwise "select"/mux:
; out = (sel AND x) OR ((NOT sel) AND y)
; This is the basis of masked blends and constant-time conditional selection.

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
hex_digits db "0123456789ABCDEF"

msg_sel db "sel = ",0
len_msg_sel equ $-msg_sel
msg_x   db "x   = ",0
len_msg_x equ $-msg_x
msg_y   db "y   = ",0
len_msg_y equ $-msg_y
msg_out db "out = ",0
len_msg_out equ $-msg_out

sel dq 0xFFFF0000FFFF0000
x   dq 0x1111222233334444
y   dq 0xAAAABBBBCCCCDDDD

SECTION .bss
hexbuf resb 2 + 16 + 1

SECTION .text
write_stdout:
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    ret

print_hex64:
    mov byte [hexbuf+0], '0'
    mov byte [hexbuf+1], 'x'
    mov rcx, 16
    lea rdi, [hexbuf+2+15]
.hex_loop:
    mov rbx, rax
    and rbx, 0xF
    mov bl, [hex_digits+rbx]
    mov [rdi], bl
    shr rax, 4
    dec rdi
    loop .hex_loop
    mov byte [hexbuf+2+16], 10
    lea rsi, [hexbuf]
    mov rdx, 2+16+1
    call write_stdout
    ret

print_label_then_hex64:
    push rax
    call write_stdout
    pop rax
    call print_hex64
    ret

_start:
    mov rax, [sel]
    lea rsi, [msg_sel]
    mov rdx, len_msg_sel
    call print_label_then_hex64

    mov rax, [x]
    lea rsi, [msg_x]
    mov rdx, len_msg_x
    call print_label_then_hex64

    mov rax, [y]
    lea rsi, [msg_y]
    mov rdx, len_msg_y
    call print_label_then_hex64

    ; out = (sel & x) | (~sel & y)
    mov rax, [sel]
    mov rcx, rax        ; rcx = sel
    and rax, [x]        ; rax = sel & x
    not rcx             ; rcx = ~sel
    and rcx, [y]        ; rcx = ~sel & y
    or  rax, rcx        ; rax = out
    lea rsi, [msg_out]
    mov rdx, len_msg_out
    call print_label_then_hex64

    mov rax, SYS_exit
    xor rdi, rdi
    syscall
