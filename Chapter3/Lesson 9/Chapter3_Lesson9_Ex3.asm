; Chapter 3 - Lesson 9
; Ex3: Deriving signed ranges for n-bit two's complement (8/16/32/64)

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
hdr:  db "Two's complement signed ranges:",10,0
lbl8: db "  int8:  min=",0
mid8: db " max=",0
nl:   db 10,0

lbl16: db "  int16: min=",0
lbl32: db "  int32: min=",0
lbl64: db "  int64: min=",0

section .text
_start:
    PRINTZ hdr

    ; int8
    PRINTZ lbl8
    mov rax, 1
    shl rax, 7
    neg rax                      ; min = -2^(7)
    call print_i64_nl

    PRINTZ mid8
    mov rax, 1
    shl rax, 7
    dec rax                      ; max = 2^(7) - 1
    call print_i64_nl
    call print_nl

    ; int16
    PRINTZ lbl16
    mov rax, 1
    shl rax, 15
    neg rax
    call print_i64_nl

    PRINTZ mid8
    mov rax, 1
    shl rax, 15
    dec rax
    call print_i64_nl
    call print_nl

    ; int32
    PRINTZ lbl32
    mov rax, 1
    shl rax, 31
    neg rax
    call print_i64_nl

    PRINTZ mid8
    mov rax, 1
    shl rax, 31
    dec rax
    call print_i64_nl
    call print_nl

    ; int64
    PRINTZ lbl64
    mov rax, 1
    shl rax, 63
    ; Treating 0x8000.. as signed is already INT64_MIN; NEG would overflow and keep same.
    ; We'll print it as signed to verify.
    call print_i64_nl

    PRINTZ mid8
    mov rax, 1
    shl rax, 63
    dec rax                      ; INT64_MAX
    call print_i64_nl

    jmp exit0
