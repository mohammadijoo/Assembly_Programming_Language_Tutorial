; Chapter 4 - Lesson 2 (Logical Instructions): Exercise 5 Solution
; Hamming distance between two buffers of qwords:
;   distance = sum(popcount(A[i] XOR B[i]))
; Uses XOR (this lesson) and popcount via x &= x-1 (AND from this lesson).

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
hex_digits db "0123456789ABCDEF"

A dq 0x0123456789ABCDEF, 0x0000000000000000, 0xFFFFFFFFFFFFFFFF, 0x13579BDF2468ACE0
B dq 0x0123456789ABCDE0, 0xFFFFFFFFFFFFFFFF, 0x0F0F0F0F0F0F0F0F, 0x13579BDF2468ACE0
NQ equ 4

msg db "Hamming distance (hex) = ",0
len_msg equ $-msg

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

; popcount64: input RAX, output RAX=count
popcount64:
    xor rbx, rbx
.pc_loop:
    test rax, rax
    jz .pc_done
    mov rcx, rax
    sub rcx, 1
    and rax, rcx
    inc rbx
    jmp .pc_loop
.pc_done:
    mov rax, rbx
    ret

_start:
    xor r12, r12          ; total distance
    xor rcx, rcx
.loop:
    mov rax, [A + rcx*8]
    xor rax, [B + rcx*8]  ; diff word
    call popcount64
    add r12, rax

    inc rcx
    cmp rcx, NQ
    jb .loop

    mov rax, r12
    lea rsi, [msg]
    mov rdx, len_msg
    call print_label_then_hex64

    mov rax, SYS_exit
    xor rdi, rdi
    syscall
