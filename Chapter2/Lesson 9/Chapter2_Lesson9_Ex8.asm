; Chapter2_Lesson9_Ex8.asm
; Build:
;   nasm -felf64 Chapter2_Lesson9_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o
;
; Note:
;   On x86, XCHG with a memory operand is an atomic read-modify-write.
;   This example is a minimal spinlock; it is for learning purposes only.

default rel
global _start

section .bss
lock resd 1

section .text
_start:
    mov dword [lock], 0

.acquire:
    mov eax, 1
    xchg eax, [lock]               ; atomic exchange
    test eax, eax
    jnz .acquire

    ; critical section (placeholder)
    mov eax, 0x55

.release:
    mov dword [lock], 0

    mov edi, eax
    mov eax, 60
    syscall
