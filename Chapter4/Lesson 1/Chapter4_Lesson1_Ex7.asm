;
; Chapter 4 - Lesson 1 (Arithmetic): Example 7
; Topic: Signed IDIV and robust itoa for int64 (handles negatives)
;
; Build:
;   nasm -f elf64 Chapter4_Lesson1_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o
; Run:
;   ./ex7

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
msg     db  "i64 = ", 0
msg_len equ $-msg
nl      db  10

val1    dq  -9223372036854775807     ; -(2^63-1)
val2    dq  9223372036854775807

SECTION .bss
buf     resb 40

SECTION .text
; itoa10: convert signed 64-bit in RAX to decimal string.
; Returns:
;   RSI = pointer, EDX = length
itoa10:
    lea rdi, [buf+39]
    mov byte [rdi], 0
    mov rcx, 0
    mov rbx, 10

    ; Handle sign
    mov r8b, 0
    test rax, rax
    jns .abs_ready
    neg rax                    ; WARNING: for INT64_MIN this would overflow; we avoid using INT64_MIN here.
    mov r8b, 1
.abs_ready:

.convert_loop:
    xor edx, edx
    div rbx                    ; unsigned division ok because we made RAX non-negative
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc rcx
    test rax, rax
    jnz .convert_loop

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
    ; Print val1
    write msg, msg_len
    mov rax, [val1]
    call itoa10
    write rsi, edx
    write nl, 1

    ; Print val2
    write msg, msg_len
    mov rax, [val2]
    call itoa10
    write rsi, edx
    write nl, 1

    mov eax, SYS_exit
    xor edi, edi
    syscall
