; Chapter 5 - Lesson 4 — Programming Exercise 4 (Solution)
; Very hard: Table-driven state machine for parsing a signed decimal integer.
;
; Input: ASCII string ending with '\n' (newline). Example: "-12345\n"
; Output: prints parsed value in hex as 0x + 16 digits, or prints "parse error".
;
; States:
;   0 START: expecting optional sign or digit
;   1 SIGN : after '+' or '-', expecting digit
;   2 DIG  : reading digits, can stop at '\n'
;   3 DONE : success
;   4 ERR  : failure
;
; Char classes (from byte->class table):
;   0 DIGIT ('0'..'9')
;   1 SIGN  ('+' or '-')
;   2 NL    ('\n')
;   3 OTHER
;
; Two-level dispatch:
;   switch(state) { switch(class) { ... } }
; Implemented as:
;   state_jt[state] -> handler
; where each state handler uses class_jt[class] -> action.
;
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex15.asm -o ex15.o
;   ld -o ex15 ex15.o
;   ./ex15

default rel
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .rodata
hex: db "0123456789ABCDEF"
out: db "0x", 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 10
out_len: equ $-out
msg_err: db "parse error", 10
len_err: equ $-msg_err

; Input (change to test)
inp: db "-12345", 10
inp_len: equ $-inp

section .text
_start:
    ; Registers:
    ; r12 = accumulator (unsigned magnitude)
    ; r13 = sign (0=positive, 1=negative)
    ; r14 = pointer into input
    ; r15d = state (0..4)

    xor r12, r12
    xor r13d, r13d
    lea r14, [inp]
    xor r15d, r15d              ; START

.next_char:
    movzx eax, byte [r14]
    inc r14

    lea rbx, [class_tbl]
    movzx eax, byte [rbx + rax] ; class in eax (0..3)

    lea rbx, [state_jt]
    mov ecx, r15d
    jmp qword [rbx + rcx*8]

; ---------------- State handlers ----------------

.state_start:
    lea rbx, [class_jt_start]
    jmp qword [rbx + rax*8]

.state_sign:
    lea rbx, [class_jt_sign]
    jmp qword [rbx + rax*8]

.state_digits:
    lea rbx, [class_jt_digits]
    jmp qword [rbx + rax*8]

.state_done:
    jmp .emit_value

.state_err:
    jmp .emit_error

; ---------------- Actions for START ----------------
.start_digit:
    movzx eax, byte [r14-1]
    sub eax, '0'
    imul r12, r12, 10
    add r12, rax
    mov r15d, 2                 ; DIGITS
    jmp .next_char

.start_sign:
    movzx eax, byte [r14-1]
    cmp al, '-'
    sete dl
    movzx edx, dl
    mov r13d, edx               ; sign=1 if '-'
    mov r15d, 1                 ; SIGN
    jmp .next_char

.start_nl:
.start_other:
    mov r15d, 4
    jmp .emit_error

; ---------------- Actions for SIGN ----------------
.sign_digit:
    movzx eax, byte [r14-1]
    sub eax, '0'
    imul r12, r12, 10
    add r12, rax
    mov r15d, 2                 ; DIGITS
    jmp .next_char

.sign_sign:
.sign_nl:
.sign_other:
    mov r15d, 4
    jmp .emit_error

; ---------------- Actions for DIGITS ----------------
.dig_digit:
    movzx eax, byte [r14-1]
    sub eax, '0'
    imul r12, r12, 10
    add r12, rax
    jmp .next_char

.dig_nl:
    mov r15d, 3                 ; DONE
    jmp .emit_value

.dig_sign:
.dig_other:
    mov r15d, 4
    jmp .emit_error

; ---------------- Output paths ----------------
.emit_value:
    mov rax, r12
    test r13d, r13d
    jz .fmt
    neg rax

.fmt:
    lea rdi, [out + 2]
    mov ecx, 16
.hex_loop:
    mov rdx, rax
    shr rdx, 60
    lea rsi, [hex]
    mov dl, byte [rsi + rdx]
    mov byte [rdi], dl
    inc rdi
    shl rax, 4
    dec ecx
    jnz .hex_loop

    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [out]
    mov edx, out_len
    syscall

    xor edi, edi
    mov eax, SYS_exit
    syscall

.emit_error:
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [msg_err]
    mov edx, len_err
    syscall
    mov edi, 1
    mov eax, SYS_exit
    syscall

section .rodata
align 8
state_jt:
    dq .state_start, .state_sign, .state_digits, .state_done, .state_err

align 8
class_jt_start:
    dq .start_digit, .start_sign, .start_nl, .start_other

align 8
class_jt_sign:
    dq .sign_digit, .sign_sign, .sign_nl, .sign_other

align 8
class_jt_digits:
    dq .dig_digit, .dig_sign, .dig_nl, .dig_other

; 256-byte classification table generated at assembly time.
; default=3, digits=0, sign=1, newline=2.
align 16
class_tbl:
%assign b 0
%rep 256
    %if (b >= '0') && (b <= '9')
        db 0
    %elif (b == '+') || (b == '-')
        db 1
    %elif (b == 10)
        db 2
    %else
        db 3
    %endif
%assign b b+1
%endrep
