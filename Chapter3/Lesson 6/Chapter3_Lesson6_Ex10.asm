BITS 64
default rel
%include "Chapter3_Lesson6_Ex1.asm"

global _start

; Exercise 4 (Solution): decimal parsing to signed int32 with overflow detection.
; Interface:
;   parse_i32:
;     In : RSI -> NUL-terminated ASCII string, optional leading '+' or '-'
;     Out: EAX = parsed value on success
;          CF  = 0 on success
;          CF  = 1 on failure (invalid format or overflow)
;
; Strategy:
;   - For negative numbers, accumulate as a negative value to accept INT_MIN.
;   - Use pre-checked thresholds before multiplying by 10 and adding/subtracting digit.

%define POS_DIV10 214748364
%define POS_REM   7
%define NEG_DIV10 -214748364
%define NEG_REM   8

section .rodata
h0: db "Exercise 4 Solution: parse decimal string into signed int32 (with overflow)",10
h0_len: equ $-h0

lab_in: db "  input:  ",0
lab_in_len: equ $-lab_in-1
lab_ok: db "  result: ",0
lab_ok_len: equ $-lab_ok-1
lab_bad: db "  parse failed",10
lab_bad_len: equ $-lab_bad

nl: db 10
nl_len: equ 1

s1: db "2147483647",0
s1_len: equ $-s1-1
s2: db "2147483648",0
s2_len: equ $-s2-1
s3: db "-2147483648",0
s3_len: equ $-s3-1
s4: db "-2147483649",0
s4_len: equ $-s4-1
s5: db "+12345",0
s5_len: equ $-s5-1
s6: db "12x",0
s6_len: equ $-s6-1

section .data
tests:
    dq s1, s1_len
    dq s2, s2_len
    dq s3, s3_len
    dq s4, s4_len
    dq s5, s5_len
    dq s6, s6_len
test_count: equ 6

section .text
parse_i32:
    ; RSI -> string
    push rbx
    push rcx
    push rdx
    push rdi

    xor eax, eax          ; accumulator
    xor ebx, ebx          ; sign flag: 0=positive, 1=negative
    xor ecx, ecx          ; digit_count

    mov dl, [rsi]
    cmp dl, '+'
    jne .check_minus
    inc rsi
    jmp .loop

.check_minus:
    cmp dl, '-'
    jne .loop
    mov bl, 1
    inc rsi

.loop:
    mov dl, [rsi]
    test dl, dl
    jz .done

    cmp dl, '0'
    jb .fail
    cmp dl, '9'
    ja .fail

    sub dl, '0'           ; digit in DL (0..9)
    movzx edx, dl

    cmp bl, 0
    jne .neg_path

    ; Positive path: check overflow for eax*10 + digit
    cmp eax, POS_DIV10
    ja .fail
    jne .pos_ok
    cmp edx, POS_REM
    ja .fail
.pos_ok:
    imul eax, eax, 10
    add eax, edx
    inc ecx
    inc rsi
    jmp .loop

.neg_path:
    ; Negative path: accumulator kept negative (or zero):
    ; check overflow for eax*10 - digit
    cmp eax, NEG_DIV10
    jl .fail
    jne .neg_ok
    cmp edx, NEG_REM
    ja .fail
.neg_ok:
    imul eax, eax, 10
    sub eax, edx
    inc ecx
    inc rsi
    jmp .loop

.done:
    test ecx, ecx
    jz .fail              ; require at least one digit
    clc
    jmp .ret

.fail:
    stc
.ret:
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

_start:
    WRITE h0, h0_len

    xor ecx, ecx
.test_loop:
    mov rsi, [tests + rcx*16 + 0]
    mov rdi, [tests + rcx*16 + 8]     ; length for display

    WRITE lab_in, lab_in_len
    WRITE rsi, rdi
    WRITE nl, nl_len

    push rcx
    call parse_i32
    pop rcx
    jc .bad

    WRITE lab_ok, lab_ok_len
    movsxd rax, eax
    call write_hex64
    jmp .next

.bad:
    WRITE lab_bad, lab_bad_len

.next:
    WRITE nl, nl_len
    inc ecx
    cmp ecx, test_count
    jb .test_loop

    EXIT 0
