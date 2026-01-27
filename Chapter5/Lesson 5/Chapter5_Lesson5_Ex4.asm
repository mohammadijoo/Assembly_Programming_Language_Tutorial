; Chapter5_Lesson5_Ex4.asm
; Topic: CONTINUE the OUTER loop from inside the INNER loop (skip an entire row)
; Example: Sum each matrix row, but if any element is 0, skip printing that row.
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson5_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o

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
    cols        equ 5
    rows        equ 4
    matrix      dd  3,  7,  9,  1,  5
                dd 10, 42, 11,  6,  8
                dd  2,  4,  0, 13, 17   ; contains 0 -> row will be skipped
                dd 19, 23, 29, 31, 37

    msg_hdr     db "Row sums (rows containing 0 are skipped):", 10
    msg_hdr_len equ $ - msg_hdr

    msg_row     db "row "
    msg_row_len equ $ - msg_row

    msg_sep     db ": "
    msg_sep_len equ $ - msg_sep

section .bss
    outbuf      resb 32

section .text
global _start
_start:
    SYS_WRITE msg_hdr, msg_hdr_len

    xor     rbx, rbx                 ; i = 0

.outer_test:
    cmp     rbx, rows
    jae     .done

    xor     r12d, r12d               ; row_sum = 0
    xor     r13d, r13d               ; zero_found = 0
    xor     rcx, rcx                 ; j = 0

.inner_test:
    cmp     rcx, cols
    jae     .inner_done

    ; load matrix[i][j]
    mov     rax, rbx
    imul    rax, cols
    add     rax, rcx
    mov     edx, [matrix + rax*4]

    test    edx, edx
    jne     .accumulate

    ; if element == 0: CONTINUE OUTER (skip row)
    mov     r13d, 1
    jmp     .outer_step              ; CONTINUE OUTER (to step)

.accumulate:
    add     r12d, edx
    inc     rcx
    jmp     .inner_test

.inner_done:
    cmp     r13d, 1
    je      .outer_step              ; zero row: skip printing

    ; print: "row i: sum"
    SYS_WRITE msg_row, msg_row_len
    mov     rdi, rbx
    call    print_u64
    SYS_WRITE msg_sep, msg_sep_len
    mov     rdi, r12
    call    print_u64_ln

.outer_step:
    inc     rbx
    jmp     .outer_test

.done:
    SYS_EXIT 0

; print_u64: unsigned in RDI (no newline)
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
    sub     rdx, rsi

.emit:
    SYS_WRITE rsi, rdx
    ret

; print_u64_ln: unsigned in RDI + newline
print_u64_ln:
    call    print_u64
    mov     byte [outbuf], 10
    SYS_WRITE outbuf, 1
    ret
