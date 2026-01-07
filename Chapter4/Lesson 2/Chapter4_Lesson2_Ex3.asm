; Chapter 4 - Lesson 2 (Logical Instructions): Example 3
; Masking patterns: set/clear/toggle specific bits and extract an aligned field.

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
hex_digits db "0123456789ABCDEF"

msg0 db "Initial x        = ",0
len_msg0 equ $-msg0
msg1 db "Set bits (OR)    = ",0
len_msg1 equ $-msg1
msg2 db "Clear bits (AND) = ",0
len_msg2 equ $-msg2
msg3 db "Toggle (XOR)     = ",0
len_msg3 equ $-msg3
msg4 db "Low-byte field   = ",0
len_msg4 equ $-msg4

x dq 0x123456789ABCDEF0

; Mask selects bits 8..15 (0xFF00)
mask dq 0x000000000000FF00

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
    ; Initial
    mov rax, [x]
    lea rsi, [msg0]
    mov rdx, len_msg0
    call print_label_then_hex64

    ; SET: x |= mask
    mov rax, [x]
    or rax, [mask]
    lea rsi, [msg1]
    mov rdx, len_msg1
    call print_label_then_hex64

    ; CLEAR: x &= ~mask
    mov rax, [x]
    mov rcx, [mask]
    not rcx
    and rax, rcx
    lea rsi, [msg2]
    mov rdx, len_msg2
    call print_label_then_hex64

    ; TOGGLE: x ^= mask
    mov rax, [x]
    xor rax, [mask]
    lea rsi, [msg3]
    mov rdx, len_msg3
    call print_label_then_hex64

    ; Extract aligned field: low byte (mask 0xFF)
    mov rax, [x]
    and rax, 0xFF
    lea rsi, [msg4]
    mov rdx, len_msg4
    call print_label_then_hex64

    mov rax, SYS_exit
    xor rdi, rdi
    syscall
