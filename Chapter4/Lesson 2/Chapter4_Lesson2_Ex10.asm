; Chapter 4 - Lesson 2 (Logical Instructions): Exercise 3 Solution
; Bitset operations on arrays of qwords:
; union[i] = A[i] OR  B[i]
; inter[i] = A[i] AND B[i]
; symd[i]  = A[i] XOR B[i]
; Also computes popcount via x &= (x-1) loop (uses AND from this lesson, SUB from Lesson 1).

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
hex_digits db "0123456789ABCDEF"

A dq 0x0123456789ABCDEF, 0x1111111111111111, 0x0F0F0F0F0F0F0F0F, 0x8000000000000001
B dq 0xFEDCBA9876543210, 0x3333333333333333, 0x00FF00FF00FF00FF, 0x7FFFFFFFFFFFFFFE
NQ equ 4

msg_u db "Popcount(UNION)      = ",0
len_msg_u equ $-msg_u
msg_i db "Popcount(INTERSECT)  = ",0
len_msg_i equ $-msg_i
msg_s db "Popcount(SYMMDIFF)   = ",0
len_msg_s equ $-msg_s

SECTION .bss
union  resq NQ
inter  resq NQ
symd   resq NQ
hexbuf  resb 2 + 16 + 1

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

; popcount64: input RAX, output RAX=count (0..64)
; clobbers: rbx
popcount64:
    xor rbx, rbx              ; count
.pc_loop:
    test rax, rax
    jz .pc_done
    mov rcx, rax
    sub rcx, 1
    and rax, rcx              ; x &= x-1
    inc rbx
    jmp .pc_loop
.pc_done:
    mov rax, rbx
    ret

_start:
    ; Build derived bitsets
    xor rcx, rcx
.build_loop:
    mov rax, [A + rcx*8]
    mov rbx, [B + rcx*8]

    mov r8, rax
    or  r8, rbx
    mov [union + rcx*8], r8

    mov r9, rax
    and r9, rbx
    mov [inter + rcx*8], r9

    mov r10, rax
    xor r10, rbx
    mov [symd + rcx*8], r10

    inc rcx
    cmp rcx, NQ
    jb .build_loop

    ; Popcount totals (sum across words)
    xor r12, r12
    xor r13, r13
    xor r14, r14

    xor rcx, rcx
.sum_loop:
    mov rax, [union + rcx*8]
    call popcount64
    add r12, rax

    mov rax, [inter + rcx*8]
    call popcount64
    add r13, rax

    mov rax, [symd + rcx*8]
    call popcount64
    add r14, rax

    inc rcx
    cmp rcx, NQ
    jb .sum_loop

    ; Print totals as hex for simplicity
    mov rax, r12
    lea rsi, [msg_u]
    mov rdx, len_msg_u
    call print_label_then_hex64

    mov rax, r13
    lea rsi, [msg_i]
    mov rdx, len_msg_i
    call print_label_then_hex64

    mov rax, r14
    lea rsi, [msg_s]
    mov rdx, len_msg_s
    call print_label_then_hex64

    mov rax, SYS_exit
    xor rdi, rdi
    syscall
