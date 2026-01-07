; Chapter 3 - Lesson 9 (Programming Exercises with Solutions)
; Ex15 (Exercise 3 Solution):
;   Saturating accumulation of signed int16 array into int32 range.
;
; Contract:
;   Inputs:  RSI = ptr to int16 array
;            ECX = count
;   Output:  EAX = saturated int32 sum
;
; Saturate to INT32_MAX= 2147483647 and INT32_MIN= -2147483648.
; Here we use JO after 32-bit ADD (this exercise focuses on saturation, not "no flags").

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
hdr: db "Exercise 3: Saturating sum of int16 array into int32",10,0
lbl: db "  saturated sum (i64): ",0

; Deliberately crafted to overflow a 32-bit signed accumulator if naively summed many times.
arr: dw 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000
     dw 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000
cnt: equ ($ - arr)/2

section .text

sat_add_i32:
    ; Inputs: EAX=acc, EDX=delta
    ; Output: EAX=saturated(acc+delta)
    add eax, edx
    jno .done

    ; overflow: if delta had same sign as acc, clamp accordingly.
    ; We need original sign of delta; reconstruct by checking EDX sign.
    test edx, edx
    js .neg_overflow

    mov eax, 0x7FFFFFFF
    ret
.neg_overflow:
    mov eax, 0x80000000
.done:
    ret

sat_sum_i16_to_i32:
    ; RSI=ptr, ECX=count
    xor eax, eax                 ; acc = 0
.loop:
    movsx edx, word [rsi]        ; sign-extend int16 -> int32 delta
    call sat_add_i32
    add rsi, 2
    dec ecx
    jnz .loop
    ret

_start:
    PRINTZ hdr
    lea rsi, [arr]
    mov ecx, cnt
    call sat_sum_i16_to_i32

    PRINTZ lbl
    movsxd rax, eax
    call print_i64_nl

    jmp exit0
