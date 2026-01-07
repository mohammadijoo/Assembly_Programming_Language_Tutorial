; Chapter 3 - Lesson 9
; Ex12: Saturating add for int8 (clamp to [-128, 127]) using OF + sign

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
hdr:   db "Saturating int8 add demo:",10,0
lbl_a: db "  a=",0
lbl_b: db " b=",0
lbl_s: db " sum_sat=",0

section .text

; sat_add_i8
;   Inputs:  AL = a (int8), BL = b (int8)
;   Output:  AL = saturating(a+b) (int8)
;   Clobbers: DL
sat_add_i8:
    mov dl, al                    ; save sign of a
    add al, bl
    jno .done

    test dl, dl                   ; if a was negative => negative overflow
    js .neg_overflow
    mov al, 0x7F                  ; +127
    ret
.neg_overflow:
    mov al, 0x80                  ; -128
.done:
    ret

; print_case
;   Inputs: AL=a, BL=b
;   Clobbers: RAX, RDX
print_case:
    ; Preserve original a,b across printing calls
    mov dl, al
    mov dh, bl

    PRINTZ lbl_a
    movsx rax, dl
    call print_i64_nl

    PRINTZ lbl_b
    movsx rax, dh
    call print_i64_nl

    ; Restore a,b and compute saturated sum
    mov al, dl
    mov bl, dh
    call sat_add_i8

    PRINTZ lbl_s
    movsx rax, al
    call print_i64_nl
    call print_nl
    ret

_start:
    PRINTZ hdr

    ; Case 1: 120 + 10 => clamp to 127
    mov al, 120
    mov bl, 10
    call print_case

    ; Case 2: -120 + -20 => clamp to -128
    mov al, -120
    mov bl, -20
    call print_case

    ; Case 3: 50 + 40 => 90 (no clamp)
    mov al, 50
    mov bl, 40
    call print_case

    ; Case 4: -60 + 10 => -50 (no clamp)
    mov al, -60
    mov bl, 10
    call print_case

    jmp exit0
