; Chapter4_Lesson9_Ex9.asm
; Exercise Solution 1: sum_i8_to_i64
;   int64_t sum_i8_to_i64(const int8_t *p, size_t n);
; SysV ABI: RDI=p, RSI=n, return RAX.
;
; Debug note: a test harness is included but prints nothing; inspect RAX.

BITS 64
DEFAULT REL

GLOBAL _start
GLOBAL sum_i8_to_i64

SECTION .data
test_arr db -7, 100, -50, 3
test_len equ $-test_arr

SECTION .text
sum_i8_to_i64:
    xor rax, rax
    test rsi, rsi
    jz .done
.loop:
    movsx rdx, byte [rdi]
    add rax, rdx
    inc rdi
    dec rsi
    jnz .loop
.done:
    ret

_start:
    lea rdi, [test_arr]
    mov rsi, test_len
    call sum_i8_to_i64        ; expected: -7+100-50+3 = 46 (RAX=46)
    mov eax, 60
    xor edi, edi
    syscall
