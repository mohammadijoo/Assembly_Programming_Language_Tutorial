BITS 64
default rel
%include "Chapter3_Lesson6_Ex1.asm"

global _start

; Exercise 3 (Solution): branchless signed 64-bit three-way compare.
; Returns:
;   -1 if a < b
;    0 if a = b
;   +1 if a > b

section .rodata
h0: db "Exercise 3 Solution: branchless signed compare (SETcc, no JG/JL)",10
h0_len: equ $-h0

lab_a: db "  a: ",0
lab_a_len: equ $-lab_a-1
lab_b: db "  b: ",0
lab_b_len: equ $-lab_b-1
lab_r: db "  cmp(a,b) in RAX: ",0
lab_r_len: equ $-lab_r-1
nl: db 10
nl_len: equ 1

section .data
pairs:
    dq -1,  1
    dq  5,  5
    dq  7, -9
    dq -10, -20
pair_count: equ 4

section .text
cmp3_s64:
    ; In : RDI=a, RSI=b
    ; Out: RAX in {-1,0,1}
    cmp rdi, rsi
    setl al          ; signed less
    setg bl          ; signed greater
    movzx eax, al
    movzx ebx, bl
    sub ebx, eax     ; ebx = (gt) - (lt)
    movsxd rax, ebx
    ret

_start:
    WRITE h0, h0_len

    xor ecx, ecx
.loop:
    mov rdi, [pairs + rcx*16 + 0]
    mov rsi, [pairs + rcx*16 + 8]

    WRITE lab_a, lab_a_len
    mov rax, rdi
    call write_hex64

    WRITE lab_b, lab_b_len
    mov rax, rsi
    call write_hex64

    call cmp3_s64
    WRITE lab_r, lab_r_len
    call write_hex64

    WRITE nl, nl_len

    inc ecx
    cmp ecx, pair_count
    jb .loop

    EXIT 0
