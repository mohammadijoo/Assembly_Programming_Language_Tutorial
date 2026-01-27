; Chapter5_Lesson5_Ex12.asm
; Exercise Solution 6 (Very Hard):
; Token counting (collapse whitespace runs):
; - CONTINUE to skip whitespace quickly
; - BREAK at end-of-string
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson5_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o

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
    s           db "  one   two three    four ", 0
    msg         db "Token count: "
    msg_len     equ $ - msg

section .bss
    outbuf      resb 32

section .text
global _start
_start:
    xor     r12, r12                 ; tokens = 0
    xor     rbx, rbx                 ; i = 0

.outer_scan:
    mov     al, [s + rbx]
    test    al, al
    jz      .done                    ; BREAK at NUL

    ; skip whitespace runs
    cmp     al, ' '
    jne     .begin_token
.skip_ws:
    inc     rbx
    mov     al, [s + rbx]
    test    al, al
    jz      .done                    ; BREAK at end
    cmp     al, ' '
    je      .skip_ws                 ; CONTINUE skipping
    ; fall through into token

.begin_token:
    inc     r12                      ; found a token

.consume_token:
    mov     al, [s + rbx]
    test    al, al
    jz      .done                    ; BREAK
    cmp     al, ' '
    je      .outer_scan              ; token ended, continue outer scan
    inc     rbx
    jmp     .consume_token

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
