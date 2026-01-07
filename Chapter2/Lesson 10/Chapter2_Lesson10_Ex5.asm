; Chapter 2 - Lesson 10 - Example 5
; XCHG: swaps, and when used with a memory operand it is an atomic exchange on x86
; Demonstration: a simple spinlock (single-thread test only; illustrates semantics)
; Build:
;   nasm -felf64 Chapter2_Lesson10_Ex5.asm -o ex5.o && ld ex5.o -o ex5 && ./ex5 ; echo $?

global _start

section .bss
    lock    resd 1
    counter resq 1

section .text
_start:
    ; Initialize
    mov dword [lock], 0
    mov qword [counter], 0

    ; Acquire lock: try to set lock=1; success if old value was 0.
.acquire:
    mov eax, 1
    xchg eax, dword [lock]   ; atomic: EAX <-> [lock]
    test eax, eax
    jnz .acquire

    ; "Critical section": counter += 1, implemented with MOV + ADD
    mov rbx, [counter]
    add rbx, 1
    mov [counter], rbx

    ; Release lock (store 0). (XCHG is unnecessary for unlock in most designs.)
    mov dword [lock], 0

    ; Return counter mod 256 as exit code (should be 1)
    mov rax, [counter]
    and eax, 0xFF
    mov edi, eax
    mov eax, 60
    syscall
