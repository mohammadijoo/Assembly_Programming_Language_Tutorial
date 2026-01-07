BITS 64
default rel
global _start

section .data
buf db 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA
buf_len equ $ - buf

section .text
_start:
    ; Exercise solution: memchr-like search with simple unrolling.
    ; Inputs (hardcoded here):
    ;   RSI = &buf
    ;   RCX = buf_len
    ;   AL  = needle
    ; Output:
    ;   RAX = index (0..len-1) or -1 if not found
    ;
    ; We unroll by 4 iterations per loop to reduce loop overhead.

    lea rsi, [rel buf]
    mov ecx, buf_len
    mov al, 0x77              ; needle

    xor edx, edx              ; index = 0

    test ecx, ecx
    jz .not_found

.main:
    cmp ecx, 4
    jb  .tail

    ; unroll 4 byte checks
    cmp byte [rsi], al
    je  .found
    cmp byte [rsi+1], al
    je  .found1
    cmp byte [rsi+2], al
    je  .found2
    cmp byte [rsi+3], al
    je  .found3

    add rsi, 4
    add edx, 4
    sub ecx, 4
    jmp .main

.tail:
    ; remaining 0..3 bytes
.tail_loop:
    test ecx, ecx
    jz .not_found
    cmp byte [rsi], al
    je  .found
    inc rsi
    inc edx
    dec ecx
    jmp .tail_loop

.found1:
    add edx, 1
    jmp .found
.found2:
    add edx, 2
    jmp .found
.found3:
    add edx, 3

.found:
    mov eax, edx              ; index in EAX
    jmp .exit

.not_found:
    mov rax, -1

.exit:
    ; exit( found?0:1 ) based on (rax == -1)
    cmp rax, -1
    jne .ok
    mov edi, 1
    jmp .do_exit
.ok:
    xor edi, edi
.do_exit:
    mov eax, 60
    syscall
