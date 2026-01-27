; Chapter5_Lesson5_Ex2.asm
; Topic: CONTINUE in a FOR-style loop (skip work, still advance)
; Example: Sum 1..50, skipping multiples of 3 (continue to step)
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson5_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o

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
    msg_sum     db "Sum of 1..50 skipping multiples of 3: "
    msg_sum_len equ $ - msg_sum

section .bss
    outbuf      resb 32

section .text
global _start
_start:
    xor     r12, r12                 ; sum = 0
    mov     rbx, 1                   ; i = 1

.for_test:
    cmp     rbx, 50
    ja      .done

    ; if (i % 3 == 0) CONTINUE
    mov     rax, rbx
    xor     rdx, rdx
    mov     rcx, 3
    div     rcx                      ; remainder in RDX
    test    rdx, rdx
    jz      .for_step                ; CONTINUE to step

    add     r12, rbx                 ; sum += i

.for_step:
    inc     rbx
    jmp     .for_test

.done:
    SYS_WRITE msg_sum, msg_sum_len
    mov     rdi, r12
    call    print_u64_ln
    SYS_EXIT 0

; print_u64_ln: print unsigned integer in RDI + newline
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
