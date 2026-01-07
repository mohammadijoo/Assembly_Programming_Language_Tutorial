;
; Chapter 4 - Lesson 1 (Arithmetic): Exercise 2 (Very Hard) - Solution
; Topic: Compute (a*b) mod m for 64-bit unsigned inputs using 128-bit MUL and DIV
;
; Preconditions:
;   m != 0
;   For DIV with 128-bit numerator, m must be 64-bit (it is), quotient must fit in RAX (it will).
;
; Build:
;   nasm -f elf64 Chapter4_Lesson1_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o

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
a   dq  1234567890123456789
b   dq  9876543210987654321
m   dq  1000000007
msg db  "(a*b) mod m = ", 0
msg_len equ $-msg
nl  db  10

SECTION .bss
buf resb 32

SECTION .text
utoa10:
    lea rdi, [buf+31]
    mov byte [rdi], 0
    mov rcx, 0
    mov rbx, 10
.loop:
    xor edx, edx
    div rbx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc rcx
    test rax, rax
    jnz .loop
    mov rsi, rdi
    mov edx, ecx
    ret

_start:
    ; Compute 128-bit product p = a*b in RDX:RAX
    mov rax, [a]
    mul qword [b]

    ; Reduce modulo m using DIV: (RDX:RAX) / m -> remainder in RDX
    mov rcx, [m]
    test rcx, rcx
    jz .divzero

    div rcx              ; quotient in RAX, remainder in RDX
    mov rax, rdx         ; remainder -> RAX for printing

    write msg, msg_len
    call utoa10
    write rsi, edx
    write nl, 1

    mov eax, SYS_exit
    xor edi, edi
    syscall

.divzero:
    ; If m==0, exit with code 1
    mov eax, SYS_exit
    mov edi, 1
    syscall
