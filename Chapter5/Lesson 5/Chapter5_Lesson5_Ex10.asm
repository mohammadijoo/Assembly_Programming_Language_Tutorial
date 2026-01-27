; Chapter5_Lesson5_Ex10.asm
; Exercise Solution 4 (Very Hard):
; Multi-level BREAK with a direct jump (no flag).
; Find first (a,b) in [1..30]x[1..30] such that a*b == 221.
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson5_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o

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
    target      dq 221

    msg_found   db "Found factors (a, b): "
    msg_found_len equ $ - msg_found

    msg_sep     db ", "
    msg_sep_len equ $ - msg_sep

    msg_nf      db "No factors found in range", 10
    msg_nf_len  equ $ - msg_nf

section .bss
    outbuf      resb 32

section .text
global _start
_start:
    mov     r14, 0                   ; found = 0
    mov     rbx, 1                   ; a = 1
    xor     r12, r12                 ; save_a
    xor     r13, r13                 ; save_b

.outer:
    cmp     rbx, 30
    ja      .finish

    mov     rcx, 1                   ; b = 1
.inner:
    cmp     rcx, 30
    ja      .next_a

    mov     rax, rbx
    imul    rax, rcx
    cmp     rax, [target]
    jne     .next_b

    mov     r14, 1
    mov     r12, rbx
    mov     r13, rcx
    jmp     .found_all               ; BREAK both loops

.next_b:
    inc     rcx
    jmp     .inner

.next_a:
    inc     rbx
    jmp     .outer

.found_all:
    ; fall through to finish with found=1
.finish:
    cmp     r14, 1
    jne     .not_found

    SYS_WRITE msg_found, msg_found_len
    mov     rdi, r12
    call    print_u64
    SYS_WRITE msg_sep, msg_sep_len
    mov     rdi, r13
    call    print_u64_ln
    SYS_EXIT 0

.not_found:
    SYS_WRITE msg_nf, msg_nf_len
    SYS_EXIT 1

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
