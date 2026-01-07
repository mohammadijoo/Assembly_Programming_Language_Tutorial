; Chapter 4 - Lesson 2 (Logical Instructions): Exercise 4 Solution
; Bitfield packing/unpacking with AND/OR/XOR/NOT plus shifts (positioning).
; Layout (32-bit word):
;   [31..22] user_id  (10 bits)
;   [21..12] group_id (10 bits)
;   [11..0]  perms    (12 bits)

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
hex_digits db "0123456789ABCDEF"
msg_w db "packed word = ",0
len_msg_w equ $-msg_w
msg_u db "user_id     = ",0
len_msg_u equ $-msg_u
msg_g db "group_id    = ",0
len_msg_g equ $-msg_g
msg_p db "perms       = ",0
len_msg_p equ $-msg_p

user_id  dd 777          ; <= 1023
group_id dd 42           ; <= 1023
perms    dd 0xA55         ; <= 0xFFF

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
    ; Pack
    mov eax, [user_id]
    and eax, 0x3FF
    shl eax, 22

    mov ebx, [group_id]
    and ebx, 0x3FF
    shl ebx, 12
    or  eax, ebx

    mov ebx, [perms]
    and ebx, 0xFFF
    or  eax, ebx

    ; Print packed word (in RAX)
    movzx rax, eax
    lea rsi, [msg_w]
    mov rdx, len_msg_w
    call print_label_then_hex64

    ; Unpack: user_id = (word >> 22) & 0x3FF
    mov ebx, eax
    shr ebx, 22
    and ebx, 0x3FF
    mov rax, rbx
    lea rsi, [msg_u]
    mov rdx, len_msg_u
    call print_label_then_hex64

    ; group_id = (word >> 12) & 0x3FF
    mov ebx, eax
    shr ebx, 12
    and ebx, 0x3FF
    mov rax, rbx
    lea rsi, [msg_g]
    mov rdx, len_msg_g
    call print_label_then_hex64

    ; perms = word & 0xFFF
    mov ebx, eax
    and ebx, 0xFFF
    mov rax, rbx
    lea rsi, [msg_p]
    mov rdx, len_msg_p
    call print_label_then_hex64

    mov rax, SYS_exit
    xor rdi, rdi
    syscall
