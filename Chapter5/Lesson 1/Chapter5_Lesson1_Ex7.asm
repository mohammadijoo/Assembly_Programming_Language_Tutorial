BITS 64
default rel
global _start

; "Structured if" macros using NASM preprocessor contexts.
; These macros let you write:
;   cmp rax, rbx
;   IF l
;       ; then-block (if a < b, signed)
;   ELSE
;       ; else-block
;   ENDIF

%macro IF 1
    %push ifctx
    j%1 %$then
    jmp %$else
%$then:
%endmacro

%macro ELSE 0
    jmp %$endif
%$else:
%endmacro

%macro ENDIF 0
%$endif:
    %pop
%endmacro

section .data
a dq 5
b dq 9

msg_then db "THEN: a < b", 10
msg_then_len equ $-msg_then

msg_else db "ELSE: a >= b", 10
msg_else_len equ $-msg_else

section .text
_start:
    mov rax, [a]
    mov rbx, [b]
    cmp rax, rbx

    IF l
        mov rax, 1
        mov rdi, 1
        mov rsi, msg_then
        mov rdx, msg_then_len
        syscall
    ELSE
        mov rax, 1
        mov rdi, 1
        mov rsi, msg_else
        mov rdx, msg_else_len
        syscall
    ENDIF

    mov rax, 60
    xor rdi, rdi
    syscall
