;
; Chapter 4 - Lesson 1 (Arithmetic): Example 6
; Topic: Unsigned DIV and computing decimal digits with repeated division by 10 (u64 -> string)
;
; Build:
;   nasm -f elf64 Chapter4_Lesson1_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
; Run:
;   ./ex6

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
msg     db  "u64 = ", 0
msg_len equ $-msg

nl      db  10
val     dq  18446744073709551615     ; 2^64-1 (max u64)

SECTION .bss
buf     resb 32                       ; enough for 20 digits + newline + 0

SECTION .text
; utoa10: convert unsigned 64-bit in RAX to decimal string.
; Returns:
;   RSI = pointer to first character
;   EDX = length in bytes (no trailing 0)
utoa10:
    ; We build digits from the end of buf backwards.
    lea rdi, [buf+31]
    mov byte [rdi], 0
    mov rcx, 0                ; length
    mov rbx, 10

.convert_loop:
    xor edx, edx              ; RDX must be 0 for unsigned DIV of 64-bit numerator
    div rbx                   ; (RDX:RAX) / 10  -> quotient in RAX, remainder in RDX
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc rcx
    test rax, rax
    jnz .convert_loop

    mov rsi, rdi
    mov edx, ecx
    ret

_start:
    write msg, msg_len

    mov rax, [val]
    call utoa10
    write rsi, edx
    write nl, 1

    mov eax, SYS_exit
    xor edi, edi
    syscall
