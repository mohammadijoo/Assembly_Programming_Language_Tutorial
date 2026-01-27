; Chapter6_Lesson3_Ex4.asm
; Example 4 (SysV AMD64 / Linux): passing pointer + length (by reference).
;
; Signature:
;   int64 sum_array_qword(const int64 *p, uint64 n)
; SysV: p=RDI, n=RSI
;
; Build:
;   nasm -f elf64 Chapter6_Lesson3_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o
; Run:
;   ./ex4 ; exit code = 15

global _start

section .data
arr dq 1, 2, 3, 4, 5

section .text

sum_array_qword:
    xor     eax, eax          ; sum = 0
    test    rsi, rsi
    jz      .done

.loop:
    add     rax, [rdi]
    add     rdi, 8
    dec     rsi
    jnz     .loop

.done:
    ret

_start:
    lea     rdi, [rel arr]
    mov     esi, 5
    call    sum_array_qword

    mov     edi, eax
    mov     eax, 60
    syscall
