; Chapter 4 - Lesson 2 (Logical Instructions): Example 7
; NASM macro patterns for logical bit-twiddling. This is your "header-file" substitute.
; Note: macros expand at assembly-time; they do NOT exist at runtime.

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

%macro BIT_SET 2        ; BIT_SET dest, mask
    or %1, %2
%endmacro

%macro BIT_CLEAR 2      ; BIT_CLEAR dest, mask
    ; dest &= ~mask
    push r11
    mov r11, %2
    not r11
    and %1, r11
    pop r11
%endmacro

%macro BIT_TOGGLE 2     ; BIT_TOGGLE dest, mask
    xor %1, %2
%endmacro

SECTION .data
hex_digits db "0123456789ABCDEF"
msg0 db "Initial x  = ",0
len_msg0 equ $-msg0
msg1 db "After SET  = ",0
len_msg1 equ $-msg1
msg2 db "After CLEAR= ",0
len_msg2 equ $-msg2
msg3 db "After TOG  = ",0
len_msg3 equ $-msg3

x dq 0x0000000000000000
mask dq 0x00000000000000F0     ; bits 4..7

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
    mov rax, [x]
    lea rsi, [msg0]
    mov rdx, len_msg0
    call print_label_then_hex64

    mov rax, [x]
    BIT_SET rax, [mask]
    lea rsi, [msg1]
    mov rdx, len_msg1
    call print_label_then_hex64

    mov rax, [x]
    BIT_CLEAR rax, [mask]
    lea rsi, [msg2]
    mov rdx, len_msg2
    call print_label_then_hex64

    mov rax, [x]
    BIT_TOGGLE rax, [mask]
    lea rsi, [msg3]
    mov rdx, len_msg3
    call print_label_then_hex64

    mov rax, SYS_exit
    xor rdi, rdi
    syscall
