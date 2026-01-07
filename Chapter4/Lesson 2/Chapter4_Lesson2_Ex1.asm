; Chapter 4 - Lesson 2 (Logical Instructions): Example 1
; Demonstrates AND / OR / XOR / NOT on registers and memory (NASM, x86-64 Linux).

BITS 64
DEFAULT REL

GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
hex_digits db "0123456789ABCDEF"

msg_a db "A = ",0
len_msg_a equ $-msg_a
msg_b db "B = ",0
len_msg_b equ $-msg_b
msg_and db "A AND B = ",0
len_msg_and equ $-msg_and
msg_or  db "A OR  B = ",0
len_msg_or equ $-msg_or
msg_xor db "A XOR B = ",0
len_msg_xor equ $-msg_xor
msg_not db "NOT A   = ",0
len_msg_not equ $-msg_not

nl db 10

A dq 0xF0F0F0F012345678
B dq 0x0F0F0F0F89ABCDEF
memword dq 0xFFFFFFFFFFFFFFFF

SECTION .bss
hexbuf resb 2 + 16 + 1        ; "0x" + 16 hex digits + "\n"

SECTION .text

; ----------------------------
; write(STDOUT, rsi, rdx)
; ----------------------------
write_stdout:
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    ret

; ----------------------------
; print_hex64: prints RAX as 0xXXXXXXXXXXXXXXXX\n
; clobbers: rbx, rcx, rdx, rsi, rdi
; ----------------------------
print_hex64:
    mov byte [hexbuf+0], '0'
    mov byte [hexbuf+1], 'x'

    mov rcx, 16                ; 16 nibbles
    lea rdi, [hexbuf+2+15]     ; last hex digit position
.hex_loop:
    mov rbx, rax
    and rbx, 0xF
    mov bl, [hex_digits+rbx]
    mov [rdi], bl
    shr rax, 4
    dec rdi
    loop .hex_loop

    mov byte [hexbuf+2+16], 10 ; '\n'
    lea rsi, [hexbuf]
    mov rdx, 2 + 16 + 1
    call write_stdout
    ret

; ----------------------------
; print_label_then_hex64:
; RSI=label, RDX=len(label), RAX=value
; ----------------------------
print_label_then_hex64:
    push rax
    call write_stdout
    pop rax
    call print_hex64
    ret

_start:
    ; Print A
    mov rax, [A]
    lea rsi, [msg_a]
    mov rdx, len_msg_a
    call print_label_then_hex64

    ; Print B
    mov rax, [B]
    lea rsi, [msg_b]
    mov rdx, len_msg_b
    call print_label_then_hex64

    ; A AND B
    mov rax, [A]
    and rax, [B]
    lea rsi, [msg_and]
    mov rdx, len_msg_and
    call print_label_then_hex64

    ; A OR B
    mov rax, [A]
    or rax, [B]
    lea rsi, [msg_or]
    mov rdx, len_msg_or
    call print_label_then_hex64

    ; A XOR B
    mov rax, [A]
    xor rax, [B]
    lea rsi, [msg_xor]
    mov rdx, len_msg_xor
    call print_label_then_hex64

    ; NOT A (unary)
    mov rax, [A]
    not rax
    lea rsi, [msg_not]
    mov rdx, len_msg_not
    call print_label_then_hex64

    ; Memory operand example: clear low 8 bits of memword using AND
    ; (memword = memword AND 0xFFFFFFFFFFFFFF00)
    and qword [memword], 0xFFFFFFFFFFFFFF00

    ; Exit
    mov rax, SYS_exit
    xor rdi, rdi
    syscall
