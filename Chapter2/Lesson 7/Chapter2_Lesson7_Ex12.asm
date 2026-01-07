; Chapter 2 - Lesson 7 (Execution Flow) - Exercise Solution 3
; Very hard: Collatz steps count with overflow detection for 3n+1.
; Build:
;   nasm -f elf64 Chapter2_Lesson7_Ex12.asm -o ex12.o
;   ld ex12.o -o ex12

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .data
n dq 27

SECTION .text
_start:
    mov rax, [n]            ; current value
    xor rcx, rcx            ; steps = 0

    ; max_safe = floor((2^64 - 2) / 3) to ensure 3n+1 does not overflow
    mov r8, 0x5555555555555554

.loop:
    cmp rax, 1
    je  .done

    test rax, 1
    jz   .even

.odd:
    cmp rax, r8
    ja   .overflow
    lea rax, [rax*3 + 1]
    inc rcx
    jmp .loop

.even:
    shr rax, 1
    inc rcx
    jmp .loop

.overflow:
    ; Signal overflow by exiting with status 1
    mov eax, 60
    mov edi, 1
    syscall

.done:
    ; Exit with steps modulo 256 (low byte) for observation.
    mov eax, ecx
    and eax, 0xFF
    mov edi, eax
    mov eax, 60
    syscall
