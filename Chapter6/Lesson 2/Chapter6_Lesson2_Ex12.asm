; Chapter 6 - Lesson 2 - Exercise Solution 4
; File: Chapter6_Lesson2_Ex12.asm
; Topic: Robust decimal parser as a procedure with structured helper calls
;
; Signature:
;   uint64_t asm_parse_u64(const char* s, uint64_t max_len, uint64_t* err)
; Error codes:
;   0 = OK
;   1 = invalid char / empty
;   2 = overflow
;   3 = exceeds max_len without NUL
;
; SysV args:
;   RDI = s
;   RSI = max_len
;   RDX = err (uint64_t*)
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson2_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o
; Run:
;   ./ex12 ; exit 0 if tests pass

default rel
%include "Chapter6_Lesson2_Ex8.asm"

section .data
t1: db "18446744073709551615", 0   ; UINT64_MAX
t2: db "18446744073709551616", 0   ; overflow
t3: db "12a3", 0                   ; invalid
t4: db "123456", 0                 ; for max_len test
err: dq 0

section .text
global _start
global asm_parse_u64

; is_digit(ch) -> AL=1 if '0'..'9' else 0
; DIL = ch
is_digit:
    mov al, dil
    sub al, '0'
    cmp al, 9
    setbe al
    ret

; mul10_add_u64(acc, digit) -> RAX=new_acc, CF=1 on overflow
; RDI=acc, SIL=digit_value(0..9)
mul10_add_u64:
    ; new = acc*10 + digit
    mov rax, rdi
    mov rcx, 10
    mul rcx          ; unsigned: RDX:RAX = RAX*10
    test rdx, rdx
    jnz .of
    movzx ecx, sil
    add rax, rcx
    jc .of
    clc
    ret
.of:
    stc
    ret

asm_parse_u64:
    ; err=0 initially
    mov qword [rdx], 0

    xor rax, rax        ; acc
    xor rcx, rcx        ; i
    xor r8d, r8d        ; saw_digit = 0

.loop:
    cmp rcx, rsi
    jae .maxlen_reached

    mov bl, [rdi + rcx]
    test bl, bl
    je .end

    mov dil, bl
    call is_digit
    test al, al
    jz .invalid

    ; digit_value in SIL
    mov sil, bl
    sub sil, '0'

    mov r8d, 1          ; saw_digit = 1

    mov rdi, rax        ; acc
    call mul10_add_u64
    jc .overflow

    inc rcx
    jmp .loop

.end:
    test r8d, r8d
    jz .invalid         ; empty string

    ; ok
    mov qword [rdx], 0
    ret

.invalid:
    mov qword [rdx], 1
    xor eax, eax
    ret

.overflow:
    mov qword [rdx], 2
    xor eax, eax
    ret

.maxlen_reached:
    ; If max_len reached without NUL, treat as error 3.
    mov qword [rdx], 3
    xor eax, eax
    ret

_start:
    ; t1 should parse to UINT64_MAX
    lea rdi, [rel t1]
    mov rsi, 64
    lea rdx, [rel err]
    call asm_parse_u64
    cmp qword [rel err], 0
    jne .fail
    cmp rax, 0xffffffffffffffff
    jne .fail

    ; t2 should overflow
    lea rdi, [rel t2]
    mov rsi, 64
    lea rdx, [rel err]
    call asm_parse_u64
    cmp qword [rel err], 2
    jne .fail

    ; t3 invalid
    lea rdi, [rel t3]
    mov rsi, 64
    lea rdx, [rel err]
    call asm_parse_u64
    cmp qword [rel err], 1
    jne .fail

    ; max_len=3 on "123456" should error 3 (no NUL within len)
    lea rdi, [rel t4]
    mov rsi, 3
    lea rdx, [rel err]
    call asm_parse_u64
    cmp qword [rel err], 3
    jne .fail

    SYS_EXIT 0
.fail:
    SYS_EXIT 1
