;
; Chapter 4 - Lesson 1 (Arithmetic): Exercise 5 (Very Hard) - Solution
; Topic: Q16.16 fixed-point multiply with rounding (signed)
;
; Representation:
;   value = integer / 2^16
; Multiply:
;   (a * b) in Q32.32, then shift right 16 with rounding to return to Q16.16.
;
; Build:
;   nasm -f elf64 Chapter4_Lesson1_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o
; Run:
;   ./ex12

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
; a = 1.5  -> 1.5 * 2^16 = 98304
; b = -2.25 -> -2.25 * 2^16 = -147456
a_q1616 dq  98304
b_q1616 dq  -147456
msg db  "q16.16 product = ", 0
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
    ; 128-bit signed product p = a*b in RDX:RAX
    mov rax, [a_q1616]
    imul qword [b_q1616]

    ; Rounding: add 0.5 ulp at bit 15 of the shifted result.
    ; Since we will shift right by 16, the rounding constant is 1<<15 added to the 128-bit product.
    add rax, 0x8000
    adc rdx, 0

    ; Arithmetic right shift 16 of 128-bit RDX:RAX into RCX (low 64 bits result)
    ; We want: result = (p + 0x8000) >> 16
    ; Technique: shift the pair.
    mov rcx, rax
    shrd rcx, rdx, 16        ; RCX = (RDX:RAX) >> 16 (logical for bits)
    ; For sign-correctness when high bit is set, ensure arithmetic behavior by preserving sign in RDX before SHRD.
    ; Here RDX already holds the signed high half from IMUL; SHRD with that RDX works for two's complement when interpreted as signed.

    mov rax, rcx

    write msg, msg_len
    call itoa10
    write rsi, edx
    write nl, 1

    mov eax, SYS_exit
    xor edi, edi
    syscall
