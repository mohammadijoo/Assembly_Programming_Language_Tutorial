; Chapter 2 - Lesson 7 (Execution Flow) - Example 4
; CALL/RET as explicit control-flow transfer.
; Build:
;   nasm -f elf64 Chapter2_Lesson7_Ex4.asm -o ex4.o
;   ld ex4.o -o ex4

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text
_start:
    ; Convention for this demo:
    ;   Input: RDI=a, RSI=b
    ;   Output: RAX = max(a,b)
    mov rdi, 27
    mov rsi, 42
    call max_u64

    ; Return value in RAX. Exit with low byte of max.
    and eax, 0xFF
    mov edi, eax
    mov eax, 60
    syscall

; uint64_t max_u64(uint64_t a, uint64_t b)
max_u64:
    ; If a >= b: return a else return b (unsigned compare).
    mov rax, rdi
    cmp rdi, rsi
    jae .done
    mov rax, rsi
.done:
    ret
