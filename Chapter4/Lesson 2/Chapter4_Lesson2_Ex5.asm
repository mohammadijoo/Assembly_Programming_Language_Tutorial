; Chapter 4 - Lesson 2 (Logical Instructions): Example 5
; NOT does bitwise complement and does NOT modify flags.
; Demonstrates: ~x == x XOR -1 (all-ones mask).

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
hex_digits db "0123456789ABCDEF"

msg_x   db "x        = ",0
len_msg_x equ $-msg_x
msg_not db "~x (NOT)  = ",0
len_msg_not equ $-msg_not
msg_xor db "~x (XOR)  = ",0
len_msg_xor equ $-msg_xor
msg_eq  db "Check: (~x) XOR (x XOR -1) == 0 ? ",0
len_msg_eq equ $-msg_eq
msg_yes db "YES",10,0
len_msg_yes equ $-msg_yes
msg_no  db "NO",10,0
len_msg_no equ $-msg_no

x dq 0x0123456789ABCDEF

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
    lea rsi, [msg_x]
    mov rdx, len_msg_x
    call print_label_then_hex64

    ; ~x via NOT
    mov rax, [x]
    not rax
    mov r8, rax                     ; save ~x
    lea rsi, [msg_not]
    mov rdx, len_msg_not
    call print_label_then_hex64

    ; ~x via XOR with all-ones
    mov rax, [x]
    xor rax, -1
    mov r9, rax                     ; save x XOR -1
    lea rsi, [msg_xor]
    mov rdx, len_msg_xor
    call print_label_then_hex64

    ; Check equality: r8 XOR r9 should be 0
    lea rsi, [msg_eq]
    mov rdx, len_msg_eq
    call write_stdout

    mov rax, r8
    xor rax, r9
    test rax, rax
    jz .eq
    lea rsi, [msg_no]
    mov rdx, len_msg_no
    call write_stdout
    jmp .done
.eq:
    lea rsi, [msg_yes]
    mov rdx, len_msg_yes
    call write_stdout
.done:
    mov rax, SYS_exit
    xor rdi, rdi
    syscall
