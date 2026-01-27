; Chapter5_Lesson5_Ex6.asm
; Topic: Label discipline (explicit test/step/end labels) and safe CONTINUE/BREAK targets
; Example: Count non-space bytes in a string, stop at NUL, skip spaces via CONTINUE.
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson5_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o

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
    s           db "a b  c   d", 0
    msg         db "Non-space byte count: "
    msg_len     equ $ - msg

section .bss
    outbuf      resb 32

section .text
global _start
_start:
    xor     r12, r12                 ; count = 0
    xor     rbx, rbx                 ; i = 0

.L_for_test:
    mov     al, [s + rbx]
    test    al, al
    jz      .L_for_end               ; BREAK (string end)

    cmp     al, ' '
    je      .L_for_step              ; CONTINUE to step

    inc     r12                      ; count++

.L_for_step:
    inc     rbx                      ; i++
    jmp     .L_for_test

.L_for_end:
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
