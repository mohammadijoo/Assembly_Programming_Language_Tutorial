BITS 64
default rel
%include "Chapter3_Lesson6_Ex1.asm"

global _start

; Exercise 1 (Solution): signed 16-bit saturating add
; sat_add16 clamps the true mathematical sum to the range [-32768, 32767].

section .rodata
h0: db "Exercise 1 Solution: saturating add for signed 16-bit",10
h0_len: equ $-h0

lab_a: db "  a:        ",0
lab_a_len: equ $-lab_a-1
lab_b: db "  b:        ",0
lab_b_len: equ $-lab_b-1
lab_y: db "  sat(a+b): ",0
lab_y_len: equ $-lab_y-1
nl: db 10
nl_len: equ 1

section .data
; Pairs (a,b) stored as signed 16-bit (little-endian).
pairs:
    dw  32760, 100          ; overflow to +32767
    dw -32760, -100         ; overflow to -32768
    dw  1234, -2000         ; no overflow
    dw -1, 1                ; edge cancel
pair_count: equ 4

section .text
sat_add16:
    ; In : AX=a, BX=b
    ; Out: AX=saturating sum
    mov dx, ax
    add dx, bx
    jo .ovf
    mov ax, dx
    ret

.ovf:
    ; overflow in addition only occurs when operands have same sign.
    test ax, ax
    js .neg_sat
    mov ax, 0x7FFF
    ret
.neg_sat:
    mov ax, 0x8000
    ret

_start:
    WRITE h0, h0_len

    xor ecx, ecx
.loop:
    mov ax, [pairs + rcx*4 + 0]
    mov bx, [pairs + rcx*4 + 2]

    ; Print a
    WRITE lab_a, lab_a_len
    movsx rax, ax
    call write_hex64

    ; Print b
    WRITE lab_b, lab_b_len
    movsx rax, bx
    call write_hex64

    ; Compute and print saturating sum
    call sat_add16
    WRITE lab_y, lab_y_len
    movsx rax, ax
    call write_hex64

    WRITE nl, nl_len

    inc ecx
    cmp ecx, pair_count
    jb .loop

    EXIT 0
