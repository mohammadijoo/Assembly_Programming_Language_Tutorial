;
; Chapter 4 - Lesson 1 (Arithmetic): Exercise 3 (Very Hard) - Solution
; Topic: Euclidean GCD using DIV (unsigned), returning gcd(a,b) for 64-bit inputs
;
; Build:
;   nasm -f elf64 Chapter4_Lesson1_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o
; Run:
;   ./ex10

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
a   dq  4294967295          ; 2^32-1
b   dq  65535               ; 2^16-1
msg db  "gcd = ", 0
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

; gcd_u64(a=RDI, b=RSI) -> RAX
gcd_u64:
    mov rax, rdi
    mov rbx, rsi
.loop:
    test rbx, rbx
    jz .done
    xor rdx, rdx
    div rbx               ; rax/rbx -> quotient, remainder
    mov rax, rbx          ; next a = b
    mov rbx, rdx          ; next b = a mod b
    jmp .loop
.done:
    ret

_start:
    mov rdi, [a]
    mov rsi, [b]
    call gcd_u64

    write msg, msg_len
    call utoa10
    write rsi, edx
    write nl, 1

    mov eax, SYS_exit
    xor edi, edi
    syscall
