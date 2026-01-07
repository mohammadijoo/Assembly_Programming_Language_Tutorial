; Chapter 3 - Lesson 9
; Ex4: ADD overflow vs carry (OF vs CF) for 8-bit arithmetic

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
case1: db "Case 1: 120 + 10 in int8 (signed overflow expected)",10,0
res_s: db "  result as signed:   ",0
res_u: db "  result as unsigned: ",0
oflbl: db "  OF (signed overflow flag): ",0
cflbl: db "  CF (unsigned carry flag):  ",0

case2: db 10,"Case 2: 250 + 10 in uint8 (carry expected, signed overflow NOT expected)",10,0

section .text
_start:
    ; ---------------- Case 1 ----------------
    PRINTZ case1
    mov al, 120
    add al, 10
    seto bl
    setc bh
    mov dl, al                   ; preserve result byte

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
    mov al, 250
    add al, 10
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
