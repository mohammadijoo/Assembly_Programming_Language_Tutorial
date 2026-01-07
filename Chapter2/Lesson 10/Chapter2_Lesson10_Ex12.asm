; Chapter 2 - Lesson 10 - Exercise 4 Solution (Hard)
; Task: memswap_byte(a, b, n): swap two byte ranges in-place.
; Constraint: no temp buffer in memory; use MOV and XCHG reg/mem or MOV staging.
; Self-test: swaps two 8-byte regions and checks both sides.
;
; Build:
;   nasm -felf64 Chapter2_Lesson10_Ex12.asm -o ex12.o && ld ex12.o -o ex12 && ./ex12 ; echo $?

global _start

section .data
    left  db 1,2,3,4,5,6,7,8
    right db 101,102,103,104,105,106,107,108
    n     equ 8

section .text
; rdi=a, rsi=b, rcx=n
memswap_byte:
.loop:
    test rcx, rcx
    je .done
    ; Using XCHG with memory: swap AL with [rdi], then AL with [rsi], then write back to [rdi]
    ; This keeps a single-byte temp in AL and uses XCHG's swap semantics.
    mov al, [rdi]
    xchg al, [rsi]
    mov [rdi], al

    lea rdi, [rdi + 1]
    lea rsi, [rsi + 1]
    dec rcx
    jmp .loop
.done:
    ret

_start:
    lea rdi, [rel left]
    lea rsi, [rel right]
    mov ecx, n
    call memswap_byte

    ; Validate: left now equals old right[0]=101, and right now equals old left[0]=1
    xor edi, edi
    cmp byte [rel left], 101
    je .c1
    or edi, 1
.c1:
    cmp byte [rel right], 1
    je .c2
    or edi, 2
.c2:
    cmp byte [rel left + 7], 108
    je .c3
    or edi, 4
.c3:
    cmp byte [rel right + 7], 8
    je .c4
    or edi, 8
.c4:
    mov eax, 60
    syscall
