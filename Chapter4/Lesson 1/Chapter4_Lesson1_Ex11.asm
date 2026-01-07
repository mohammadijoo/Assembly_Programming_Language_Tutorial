;
; Chapter 4 - Lesson 1 (Arithmetic): Exercise 4 (Very Hard) - Solution
; Topic: Overflow-safe average of two signed 64-bit integers without using wider-than-64-bit arithmetic.
;
; Mathematical identity (two's complement):
;   avg = (a & b) + ((a ^ b) >> 1)
; This avoids overflow that can occur in (a+b)/2.
;
; Build:
;   nasm -f elf64 Chapter4_Lesson1_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o
; Run:
;   ./ex11

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60

%macro write 2
    mov eax, SYS_write
    mov edi, 1
    mov rsi, %1
    mov edx, %2
    syscall
%endmacro

SECTION .data
a   dq  9223372036854775807      ; INT64_MAX
b   dq  9223372036854775806
msg db  "avg = ", 0
msg_len equ $-msg
nl  db  10

SECTION .bss
buf resb 40

SECTION .text
itoa10:
    lea rdi, [buf+39]
    mov byte [rdi], 0
    mov rcx, 0
    mov rbx, 10
    mov r8b, 0

    test rax, rax
    jns .abs_ready
    neg rax
    mov r8b, 1
.abs_ready:
.loop:
    xor edx, edx
    div rbx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc rcx
    test rax, rax
    jnz .loop
    cmp r8b, 0
    je .done
    dec rdi
    mov byte [rdi], '-'
    inc rcx
.done:
    mov rsi, rdi
    mov edx, ecx
    ret

_start:
    mov rax, [a]
    mov rbx, [b]

    mov rcx, rax
    and rcx, rbx           ; (a & b)

    mov rdx, rax
    xor rdx, rbx           ; (a ^ b)
    sar rdx, 1             ; arithmetic shift right

    add rcx, rdx           ; avg in RCX
    mov rax, rcx

    write msg, msg_len
    call itoa10
    write rsi, edx
    write nl, 1

    mov eax, SYS_exit
    xor edi, edi
    syscall
