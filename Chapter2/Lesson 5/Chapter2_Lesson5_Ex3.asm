; Chapter 2 - Lesson 5 - Ex3 (Intel syntax, NASM/YASM)
; long sum_i32(const int* arr, long n) => sum_{i=0..n-1} (long)arr[i]
bits 64
default rel

section .text
global sum_i32

sum_i32:
    xor eax, eax            ; sum in RAX (zero-extend)
    xor ecx, ecx            ; i = 0

.loop:
    cmp rcx, rsi
    jge .done

    movsxd rdx, dword [rdi + rcx*4] ; sign-extend int32 -> int64
    add rax, rdx

    inc rcx
    jmp .loop

.done:
    ret
