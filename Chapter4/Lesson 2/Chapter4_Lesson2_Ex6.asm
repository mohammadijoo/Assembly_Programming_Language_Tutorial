; Chapter 4 - Lesson 2 (Logical Instructions): Example 6
; XOR idioms:
; 1) Zeroing a register: xor reg,reg (dependency-breaking, fast on modern CPUs)
; 2) XOR-swap (educational; avoid in production for readability/pitfalls)

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
hex_digits db "0123456789ABCDEF"

msg1 db "Zeroing demo:",10,0
len_msg1 equ $-msg1
msg2 db "  After xor eax,eax, RAX = ",0
len_msg2 equ $-msg2
msg3 db "  After mov rax,0x1122334455667788 then xor al,al, RAX = ",0
len_msg3 equ $-msg3

msg4 db "XOR-swap demo (R8 <-> R9):",10,0
len_msg4 equ $-msg4
msg5 db "  Before: R8 = ",0
len_msg5 equ $-msg5
msg6 db "          R9 = ",0
len_msg6 equ $-msg6
msg7 db "  After : R8 = ",0
len_msg7 equ $-msg7

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
    ; Zeroing demo
    lea rsi, [msg1]
    mov rdx, len_msg1
    call write_stdout

    mov rax, 0xFFFFFFFFFFFFFFFF
    xor eax, eax                  ; 32-bit write zero-extends: RAX becomes 0
    lea rsi, [msg2]
    mov rdx, len_msg2
    call print_label_then_hex64

    mov rax, 0x1122334455667788
    xor al, al                    ; clears ONLY low byte, not the full register
    lea rsi, [msg3]
    mov rdx, len_msg3
    call print_label_then_hex64

    ; XOR-swap demo
    lea rsi, [msg4]
    mov rdx, len_msg4
    call write_stdout

    mov r8, 0x1111222233334444
    mov r9, 0xAAAABBBBCCCCDDDD

    mov rax, r8
    lea rsi, [msg5]
    mov rdx, len_msg5
    call print_label_then_hex64

    mov rax, r9
    lea rsi, [msg6]
    mov rdx, len_msg6
    call print_label_then_hex64

    ; Swap: r8 ^= r9; r9 ^= r8; r8 ^= r9
    xor r8, r9
    xor r9, r8
    xor r8, r9

    mov rax, r8
    lea rsi, [msg7]
    mov rdx, len_msg7
    call print_label_then_hex64

    mov rax, r9
    lea rsi, [msg6]
    mov rdx, len_msg6
    call print_label_then_hex64

    mov rax, SYS_exit
    xor rdi, rdi
    syscall
