; Chapter5_Lesson5_Ex3.asm
; Topic: BREAK out of nested loops using a flag (break inner, then break outer)
; Example: Search a 4x5 matrix for a target value.
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson5_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o

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
    ; 4 rows, 5 cols, 32-bit signed ints (DD)
    cols        equ 5
    rows        equ 4
    matrix      dd  3,  7,  9,  1,  5
                dd 10, 42, 11,  6,  8
                dd  2,  4,  0, 13, 17
                dd 19, 23, 29, 31, 37
    target      dd 42

    msg_found   db "Found target at (row, col): ", 0
    msg_found_len equ $ - msg_found

    msg_nf      db "Target not found", 10
    msg_nf_len  equ $ - msg_nf

    msg_sep     db ", "
    msg_sep_len equ $ - msg_sep

section .bss
    outbuf      resb 32

section .text
global _start
_start:
    xor     r13d, r13d               ; found = 0
    xor     rbx, rbx                 ; i = 0 (row)
    xor     r14d, r14d               ; found_row
    xor     r15d, r15d               ; found_col

.outer_test:
    cmp     rbx, rows
    jae     .after_loops

    xor     rcx, rcx                 ; j = 0 (col)

.inner_test:
    cmp     rcx, cols
    jae     .outer_step

    ; idx = i*cols + j
    mov     rax, rbx
    imul    rax, cols
    add     rax, rcx
    mov     edx, [matrix + rax*4]

    cmp     edx, [target]
    jne     .inner_step

    ; found => BREAK inner loop
    mov     r13d, 1
    mov     r14d, ebx
    mov     r15d, ecx
    jmp     .outer_check_break

.inner_step:
    inc     rcx
    jmp     .inner_test

.outer_check_break:
    cmp     r13d, 1
    je      .after_loops             ; BREAK outer loop too

.outer_step:
    inc     rbx
    jmp     .outer_test

.after_loops:
    cmp     r13d, 1
    jne     .not_found

    SYS_WRITE msg_found, msg_found_len
    mov     rdi, r14                 ; row
    call    print_u64
    SYS_WRITE msg_sep, msg_sep_len
    mov     rdi, r15                 ; col
    call    print_u64_ln
    SYS_EXIT 0

.not_found:
    SYS_WRITE msg_nf, msg_nf_len
    SYS_EXIT 1

; print_u64: print unsigned integer in RDI (no newline)
print_u64:
    lea     r8,  [outbuf + 31]
    mov     byte [r8], 0
    lea     rsi, [outbuf + 30]

    mov     rax, rdi
    cmp     rax, 0
    jne     .conv
    mov     byte [rsi], '0'
    mov     rdx, 1
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
    lea     rdx, [outbuf + 31]
    sub     rdx, rsi                 ; length without NUL

.emit:
    SYS_WRITE rsi, rdx
    ret

; print_u64_ln: print unsigned integer in RDI + newline
print_u64_ln:
    call    print_u64
    ; write newline
    mov     byte [outbuf], 10
    SYS_WRITE outbuf, 1
    ret
