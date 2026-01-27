; Chapter5_Lesson5_Ex9.asm
; Exercise Solution 3 (Very Hard):
; Count primes up to 200 using trial division with BREAK/CONTINUE.
; Outer loop over n; inner loop over d; BREAK if divisible; CONTINUE outer if composite.
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson5_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o

BITS 64
default rel

%macro SYS_WRITE 2
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, %1
    mov     rdx, %2
    syscall
%endmacro

%macro SYS_EXIT 1
    mov     rax, 60
    mov     rdi, %1
    syscall
%endmacro

section .data
    msg         db "Prime count up to 200: "
    msg_len     equ $ - msg

section .bss
    outbuf      resb 32

section .text
global _start
_start:
    xor     r12, r12                 ; count = 0
    mov     rbx, 2                   ; n = 2

.outer_test:
    cmp     rbx, 200
    ja      .done

    mov     r13d, 1                  ; prime = 1
    mov     rcx, 2                   ; d = 2

.inner_test:
    ; while (d*d <= n)
    mov     rax, rcx
    imul    rax, rcx                 ; rax = d*d
    cmp     rax, rbx
    ja      .inner_done

    ; if (n % d == 0) => composite => BREAK inner
    mov     rax, rbx
    xor     rdx, rdx
    div     rcx
    test    rdx, rdx
    jne     .inner_step

    mov     r13d, 0                  ; prime = 0
    jmp     .inner_done              ; BREAK

.inner_step:
    inc     rcx
    jmp     .inner_test

.inner_done:
    cmp     r13d, 0
    je      .outer_step              ; CONTINUE outer (skip increment count)

    inc     r12                      ; count++

.outer_step:
    inc     rbx
    jmp     .outer_test

.done:
    SYS_WRITE msg, msg_len
    mov     rdi, r12
    call    print_u64_ln
    SYS_EXIT 0

; print_u64_ln: unsigned in RDI + newline
print_u64_ln:
    lea     r8,  [outbuf + 31]
    mov     byte [r8], 10
    lea     rsi, [outbuf + 30]

    mov     rax, rdi
    cmp     rax, 0
    jne     .conv
    mov     byte [rsi], '0'
    mov     rdx, 2
    jmp     .emit

.conv:
    mov     rbx, 10
.loop:
    xor     rdx, rdx
    div     rbx
    add     dl, '0'
    mov     [rsi], dl
    dec     rsi
    test    rax, rax
    jnz     .loop
    inc     rsi
    lea     rdx, [outbuf + 32]
    sub     rdx, rsi

.emit:
    SYS_WRITE rsi, rdx
    ret
