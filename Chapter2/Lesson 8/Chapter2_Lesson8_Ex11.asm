;
; Chapter 2 - Lesson 8 - Example 11 (Exercise Solution 1)
; Very hard: unsigned 128-bit compare returning -1/0/1 without branches in the core logic.
;
; Representation:
;   a = [a_lo, a_hi]  (little-endian limbs)
;   b = [b_lo, b_hi]
;
; Output:
;   EAX = -1 if a < b, 0 if a == b, 1 if a > b
;
; Build:
;   nasm -felf64 Chapter2_Lesson8_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o

%include "Chapter2_Lesson8_Ex1.asm"

BITS 64
default rel
global _start

section .rodata
h: db "cmp_u128 demo: result is printed as hex (0x...0001 / 0x...0000 / 0x...FFFF_FFFF_FFFF_FFFF)",10
h_len: equ $-h

lab_res: db "cmp_u128(a,b) = ",0
lab_res_len: equ 17

section .data
a_lo: dq 0xFFFFFFFFFFFFFFF0
a_hi: dq 0x0000000000000001
b_lo: dq 0x0000000000000005
b_hi: dq 0x0000000000000002

section .text

; Branchless compare using setcc + boolean algebra:
; gt = gt_hi OR (eq_hi AND gt_lo)
; lt = lt_hi OR (eq_hi AND lt_lo)
; result = gt - lt  (1,0,-1)
cmp_u128:
    ; rdi -> a_lo, rsi -> b_lo
    mov rax, [rdi+8]      ; a_hi
    mov rdx, [rsi+8]      ; b_hi
    cmp rax, rdx
    seta r8b              ; gt_hi
    setb r9b              ; lt_hi
    sete r10b             ; eq_hi

    mov rax, [rdi]        ; a_lo
    mov rdx, [rsi]        ; b_lo
    cmp rax, rdx
    seta r11b             ; gt_lo
    setb r12b             ; lt_lo

    ; eq_hi & gt_lo
    and r11b, r10b
    ; eq_hi & lt_lo
    and r12b, r10b

    ; gt = gt_hi | (eq_hi & gt_lo)
    or r8b, r11b
    ; lt = lt_hi | (eq_hi & lt_lo)
    or r9b, r12b

    movzx eax, r8b
    movzx edx, r9b
    sub eax, edx          ; eax = 1, 0, or -1
    ret

_start:
    SYS_WRITE h, h_len
    lea rsi, [lab_res]
    mov rdx, lab_res_len
    call print_str

    lea rdi, [a_lo]
    lea rsi, [b_lo]
    call cmp_u128
    cdqe
    call print_hex64_rax

    SYS_EXIT 0
