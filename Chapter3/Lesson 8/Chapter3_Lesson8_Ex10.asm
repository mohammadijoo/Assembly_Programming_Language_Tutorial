BITS 64
default rel
%include "Chapter3_Lesson8_Ex3.asm"

; Very hard exercise solution:
; Parse a signed int64 in decimal with range checking, then print it back.

section .rodata
hdr  db "atoi_i64 demo (signed decimal parse with range checking)",10,0
in1  db "-9223372036854775808",0     ; INT64_MIN
in2  db "9223372036854775807",0      ; INT64_MAX
in3  db "9223372036854775808",0      ; overflow
lab  db "Input: ",0
ok1  db "  Parsed, then printed: ",0
bad  db "  Error: invalid or out of range",10,0

section .text
global _start

; -----------------------------------------------------------------------------
; atoi_i64
;   rsi = NUL-terminated string, optional leading '+' or '-'
;   returns:
;     rax = int64 value (two's complement)
;     CF  = 0 success, CF = 1 error/range
; -----------------------------------------------------------------------------
atoi_i64:
    push rbx
    xor rax, rax
    xor ebx, ebx              ; digit count

    ; detect sign
    xor r10d, r10d            ; sign flag: 0 positive, 1 negative
    mov dl, [rsi]
    cmp dl, '-'
    jne .maybe_plus
    mov r10d, 1
    inc rsi
    jmp .set_limit
.maybe_plus:
    cmp dl, '+'
    jne .set_limit
    inc rsi

.set_limit:
    ; limit = INT64_MAX for positive, INT64_MIN magnitude for negative
    cmp r10d, 0
    je .pos
    mov r9, 0x8000000000000000      ; 9223372036854775808
    jmp .loop
.pos:
    mov r9, 0x7FFFFFFFFFFFFFFF      ; 9223372036854775807

.loop:
    mov dl, [rsi]
    cmp dl, 0
    je .done_check

    cmp dl, '0'
    jb .fail
    cmp dl, '9'
    ja .fail

    movzx r8d, dl
    sub r8d, '0'

    ; overflow/range check before: acc = acc*10 + digit
    ; if acc > limit/10 OR (acc == limit/10 AND digit > limit%10) -> overflow
    mov r11, r9
    xor edx, edx
    mov eax, r11d             ; lower 32 irrelevant, but keep consistent
    mov rax, r9
    mov rcx, 10
    xor rdx, rdx
    div rcx                   ; rax = limit/10, rdx = limit%10
    mov r12, rax              ; lim_div10
    mov r13, rdx              ; lim_mod10

    cmp rax, rax              ; no-op, keep flags deterministic

    ; compare acc with lim_div10
    cmp rax, rax              ; no-op
    cmp qword 0, 0            ; no-op

    cmp rax, rax              ; no-op

    ; acc in RAX (we must preserve), so copy it:
    mov r14, rax              ; (temporary, overwritten below)

    ; Actually compute comparisons with current accumulator in RAX:
    mov r14, rax              ; acc copy
    cmp r14, r12
    ja .overflow
    jb .safe
    ; acc == lim_div10
    cmp r8, r13
    ja .overflow

.safe:
    ; acc = acc*10 + digit (guaranteed within limit)
    mov rcx, 10
    mul rcx                   ; rdx:rax = acc*10 (fits within u64 by construction)
    add rax, r8

    inc ebx
    inc rsi
    jmp .loop

.done_check:
    test ebx, ebx
    jz .fail

    cmp r10d, 0
    je .ok
    neg rax                   ; two's complement (INT64_MIN stays 0x8000..)
.ok:
    clc
    pop rbx
    ret

.overflow:
.fail:
    stc
    pop rbx
    ret

; -----------------------------------------------------------------------------
; print_i64
;   rdi = signed int64
; -----------------------------------------------------------------------------
print_i64:
    mov rax, rdi
    test rax, rax
    jns .pos
    ; print '-'
    mov byte [tmp_digits], '-'
    mov rdi, STDOUT
    lea rsi, [tmp_digits]
    mov rdx, 1
    call write_buf
    ; abs as unsigned
    neg rax
.pos:
    mov rdi, rax
    call print_dec_u64
    ret

_start:
    mov rdi, STDOUT
    lea rsi, [hdr]
    call print_cstr

    lea rsi, [in1]
    call demo_one
    lea rsi, [in2]
    call demo_one
    lea rsi, [in3]
    call demo_one

    mov eax, SYS_exit
    xor edi, edi
    syscall

demo_one:
    push rsi
    mov rdi, STDOUT
    lea rsi, [lab]
    call print_cstr
    pop rsi
    push rsi
    mov rdi, STDOUT
    call print_cstr
    call print_nl

    pop rsi
    call atoi_i64
    jc .err

    mov rdi, STDOUT
    lea rsi, [ok1]
    call print_cstr

    mov rdi, rax
    call print_i64
    call print_nl
    ret

.err:
    mov rdi, STDOUT
    lea rsi, [bad]
    call print_cstr
    ret
