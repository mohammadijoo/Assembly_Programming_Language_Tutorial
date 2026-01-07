; Chapter 2 - Lesson 7 (Execution Flow) - Example 3
; Demonstrates a counted loop using LOOP and a more common DEC/JNZ pattern.
; Build:
;   nasm -f elf64 Chapter2_Lesson7_Ex3.asm -o ex3.o
;   ld ex3.o -o ex3

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text
_start:
    ; Compute sum_{i=1..N} i in RAX with two loop styles.
    mov ecx, 10             ; N = 10
    xor eax, eax            ; sum = 0

.loop_with_LOOP:
    add rax, rcx            ; sum += i
    loop .loop_with_LOOP    ; RCX--, if RCX != 0 then jump

    ; Now RAX == 55. We'll recompute with DEC/JNZ for comparison.
    mov ecx, 10
    xor rbx, rbx

.loop_with_DECJNZ:
    add rbx, rcx
    dec rcx
    jnz .loop_with_DECJNZ

    ; Exit status shows that both methods matched:
    ; status = (RAX xor RBX) & 0xFF, expected 0.
    xor rax, rbx
    and eax, 0xFF
    mov edi, eax
    mov eax, 60
    syscall
