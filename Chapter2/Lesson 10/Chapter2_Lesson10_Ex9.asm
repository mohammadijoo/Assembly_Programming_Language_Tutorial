; Chapter 2 - Lesson 10 - Exercise 1 Solution
; Task: Implement memcpy_qword(dst, src, qword_count) using MOV and LEA (plus loop control).
; Self-test: copies 8 qwords and returns checksum difference (should be 0 on success).
;
; Build:
;   nasm -felf64 Chapter2_Lesson10_Ex9.asm -o ex9.o && ld ex9.o -o ex9 && ./ex9 ; echo $?

global _start

section .data
    src dq 0x10, 0x20, 0x30, 0x40, 0x50, 0x60, 0x70, 0x80

section .bss
    dst resq 8

section .text
; rdi=dst, rsi=src, rcx=count (qwords)
memcpy_qword:
    ; Compute end pointers to avoid decrement-count dependency if desired
    ; end = src + count*8
    lea r8, [rsi + rcx*8]
.loop:
    cmp rsi, r8
    je .done
    mov rax, [rsi]
    mov [rdi], rax
    lea rsi, [rsi + 8]
    lea rdi, [rdi + 8]
    jmp .loop
.done:
    ret

_start:
    lea rdi, [rel dst]
    lea rsi, [rel src]
    mov ecx, 8
    call memcpy_qword

    ; Verify and compute checksum diff (dst[i] XOR src[i] OR-reduced)
    xor eax, eax
    lea rdi, [rel dst]
    lea rsi, [rel src]
    mov ecx, 8
.vloop:
    mov r8, [rdi]
    mov r9, [rsi]
    xor r8, r9
    or rax, r8
    lea rdi, [rdi + 8]
    lea rsi, [rsi + 8]
    dec ecx
    jnz .vloop

    ; Exit: 0 if rax == 0 else 1
    test rax, rax
    setnz al
    movzx edi, al
    mov eax, 60
    syscall
