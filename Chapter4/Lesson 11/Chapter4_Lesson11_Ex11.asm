; Chapter 4 - Lesson 11 (Exercise Solution 3)
; Constant-time (branchless) selection between two 16-byte blocks using a mask.
;   if cond==1 -> dst = a
;   if cond==0 -> dst = b
; cond is derived from SETcc (no branches).
;
; Output:
;   prints the selected block as two hex lines (qword0 then qword1).

bits 64
default rel
%include "Chapter4_Lesson11_Ex8.asm"

section .rodata
Ablock dq 0xAAAAAAAAAAAAAAAA, 0xBBBBBBBBBBBBBBBB
Bblock dq 0x1111111111111111, 0x2222222222222222

section .bss
Outblk resq 2

section .text
global _start

; ------------------------------------------------------------
; ct_select_16
;   Inputs : RDI=dst, RSI=a, RDX=b, ECX=cond (0/1)
;   Output : dst[0..15] selected
;   Clobbers: R8-R15
; ------------------------------------------------------------
ct_select_16:
    mov r8d, ecx
    neg r8                      ; r8 = 0 or -1 (mask)

    mov r9,  [rsi + 0]
    mov r10, [rsi + 8]
    mov r11, [rdx + 0]
    mov r12, [rdx + 8]

    mov r13, r8
    not r13                     ; ~mask

    ; qword0
    mov r14, r9
    and r14, r8
    mov r15, r11
    and r15, r13
    or  r14, r15
    mov [rdi + 0], r14

    ; qword1
    mov r14, r10
    and r14, r8
    mov r15, r12
    and r15, r13
    or  r14, r15
    mov [rdi + 8], r14

    ret

_start:
    ; Derive cond = (5 < 7) as signed, using SETcc
    mov eax, 5
    cmp eax, 7
    xor ecx, ecx
    setl cl                     ; cond=1

    lea rdi, [rel Outblk]
    lea rsi, [rel Ablock]
    lea rdx, [rel Bblock]
    call ct_select_16

    mov rdi, [rel Outblk + 0]
    call print_hex_u64
    mov rdi, [rel Outblk + 8]
    call print_hex_u64

    EXIT 0
