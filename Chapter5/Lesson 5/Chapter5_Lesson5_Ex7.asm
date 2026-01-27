; Chapter5_Lesson5_Ex7.asm
; Exercise Solution 1 (Very Hard):
; Implement a strcspn-like routine: count bytes until any delimiter is found.
; Demonstrates nested loops with BREAK and CONTINUE.
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson5_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o

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
    s           db "hello,world;test", 0
    delims      db ",; ", 0

    msg         db "Length until delimiter: "
    msg_len     equ $ - msg

section .bss
    outbuf      resb 32

section .text
global _start
_start:
    xor     r12, r12                 ; len = 0
    xor     rbx, rbx                 ; i = 0

.outer_test:
    mov     al, [s + rbx]
    test    al, al
    jz      .done_len                ; BREAK outer at NUL

    ; scan delimiters
    xor     rcx, rcx                 ; j = 0
    xor     r13d, r13d               ; found_delim = 0

.inner_test:
    mov     dl, [delims + rcx]
    test    dl, dl
    jz      .inner_done              ; end of delimiter set

    cmp     al, dl
    jne     .inner_step

    mov     r13d, 1
    jmp     .inner_done              ; BREAK inner

.inner_step:
    inc     rcx
    jmp     .inner_test              ; CONTINUE inner scan

.inner_done:
    cmp     r13d, 1
    je      .done_len                ; BREAK outer if delimiter matched

    inc     r12                      ; len++
    inc     rbx
    jmp     .outer_test              ; CONTINUE outer

.done_len:
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
