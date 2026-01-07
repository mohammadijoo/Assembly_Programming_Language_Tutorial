; Chapter 3 - Lesson 9
; Ex5: SUB overflow vs borrow (OF vs CF) for 8-bit arithmetic

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
case1: db "Case 1: (-128) - 1 in int8 (signed overflow expected)",10,0
res_s: db "  result as signed:   ",0
res_u: db "  result as unsigned: ",0
oflbl: db "  OF (signed overflow flag): ",0
cflbl: db "  CF (unsigned borrow flag): ",0

case2: db 10,"Case 2: 0 - 1 in uint8 (borrow expected, signed overflow NOT expected)",10,0

section .text
_start:
    ; ---------------- Case 1 ----------------
    PRINTZ case1
    mov al, 0x80                 ; -128 as int8
    sub al, 1
    seto bl
    setc bh
    mov dl, al

    PRINTZ res_s
    movsx rax, dl
    call print_i64_nl

    PRINTZ res_u
    movzx rax, dl
    call print_u64_nl

    PRINTZ oflbl
    movzx rax, bl
    call print_u64_nl

    PRINTZ cflbl
    movzx rax, bh
    call print_u64_nl

    ; ---------------- Case 2 ----------------
    PRINTZ case2
    mov al, 0
    sub al, 1
    seto bl
    setc bh
    mov dl, al

    PRINTZ res_s
    movsx rax, dl
    call print_i64_nl

    PRINTZ res_u
    movzx rax, dl
    call print_u64_nl

    PRINTZ oflbl
    movzx rax, bl
    call print_u64_nl

    PRINTZ cflbl
    movzx rax, bh
    call print_u64_nl

    jmp exit0
