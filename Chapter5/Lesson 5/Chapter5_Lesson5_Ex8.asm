; Chapter5_Lesson5_Ex8.asm
; Exercise Solution 2 (Very Hard):
; Parse a signed decimal integer from a string with leading spaces.
; CONTINUE skips spaces; BREAK stops at first non-digit after digits.
; Build (Linux x86-64):
;   nasm -felf64 Chapter5_Lesson5_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o

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
    txt         db "   -12345xyz", 0
    msg         db "Parsed integer: "
    msg_len     equ $ - msg

section .bss
    outbuf      resb 64

section .text
global _start
_start:
    xor     r12, r12                 ; result = 0
    xor     r13d, r13d               ; sign = 0 (0 => positive, 1 => negative)
    xor     r14d, r14d               ; started = 0
    xor     rbx, rbx                 ; i = 0

.scan:
    mov     al, [txt + rbx]
    test    al, al
    jz      .finish                  ; end of string

    cmp     r14d, 0
    jne     .after_leading

    ; leading spaces
    cmp     al, ' '
    je      .step_continue           ; CONTINUE

    ; optional sign (only before digits)
    cmp     al, '-'
    jne     .check_plus
    mov     r13d, 1
    mov     r14d, 1                  ; started (after sign)
    jmp     .step_continue

.check_plus:
    cmp     al, '+'
    jne     .after_leading
    mov     r14d, 1
    jmp     .step_continue

.after_leading:
    ; digit?
    cmp     al, '0'
    jb      .finish_if_started
    cmp     al, '9'
    ja      .finish_if_started

    ; result = result*10 + (al - '0')
    mov     rax, r12
    imul    rax, 10
    movzx   rdx, al
    sub     rdx, '0'
    add     rax, rdx
    mov     r12, rax
    mov     r14d, 2                  ; started and have digits
    jmp     .step_continue

.finish_if_started:
    ; if we have digits, BREAK
    cmp     r14d, 2
    je      .finish
    ; otherwise ignore and finish
    jmp     .finish

.step_continue:
    inc     rbx
    jmp     .scan

.finish:
    ; apply sign
    cmp     r13d, 1
    jne     .print
    neg     r12

.print:
    SYS_WRITE msg, msg_len
    mov     rdi, r12                 ; may be negative
    call    print_i64_ln
    SYS_EXIT 0

; print_i64_ln: print signed integer in RDI + newline
; clobbers: RAX,RBX,RCX,RDX,RSI,R8,R9
print_i64_ln:
    lea     r8, [outbuf + 63]
    mov     byte [r8], 10
    lea     rsi, [outbuf + 62]

    mov     rax, rdi
    test    rax, rax
    jns     .abs_ready

    ; negative: print '-' and convert abs
    neg     rax
    mov     r9b, 1
    jmp     .conv_start

.abs_ready:
    xor     r9d, r9d                 ; no minus

.conv_start:
    cmp     rax, 0
    jne     .conv
    mov     byte [rsi], '0'
    dec     rsi
    jmp     .done_digits

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

.done_digits:
    cmp     r9b, 1
    jne     .emit_prep
    mov     byte [rsi], '-'
    dec     rsi

.emit_prep:
    inc     rsi
    lea     rdx, [outbuf + 64]
    sub     rdx, rsi
    SYS_WRITE rsi, rdx
    ret
