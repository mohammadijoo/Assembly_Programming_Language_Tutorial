; Chapter 3 - Lesson 9
; Ex6: Overflow detection WITHOUT using OF/JO (bitwise method on 32-bit signed add)
;
; Method:
;   overflow = ((a ^ sum) & (b ^ sum)) has sign-bit set
;   For 32-bit, check bit31 of that expression.

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
hdr:     db "Signed 32-bit add overflow detection:",10,0
case1:   db "Case 1:  2147483647 + 1",10,0
case2:   db 10,"Case 2: -1000000000 + -1500000000",10,0

lbl_sum: db "  sum (int32, sign-extended to i64): ",0
lbl_cpu: db "  CPU OF: ",0
lbl_bit: db "  Bitwise overflow: ",0

section .text
_start:
    PRINTZ hdr

    ; ---------------- Case 1 ----------------
    PRINTZ case1
    mov eax, 0x7FFFFFFF          ; a
    mov ebx, 1                   ; b
    mov ecx, eax
    add ecx, ebx                 ; sum in ECX
    seto dl                      ; CPU OF snapshot

    PRINTZ lbl_sum
    movsxd rax, ecx
    call print_i64_nl

    PRINTZ lbl_cpu
    movzx rax, dl
    call print_u64_nl

    mov edx, eax                 ; EDX = a
    xor edx, ecx                 ; a ^ sum
    mov esi, ebx                 ; ESI = b
    xor esi, ecx                 ; b ^ sum
    and edx, esi                 ; (a^sum) & (b^sum)
    shr edx, 31                  ; overflow bit -> 0/1

    PRINTZ lbl_bit
    mov eax, edx
    call print_u64_nl

    ; ---------------- Case 2 ----------------
    PRINTZ case2
    mov eax, -1000000000
    mov ebx, -1500000000
    mov ecx, eax
    add ecx, ebx
    seto dl

    PRINTZ lbl_sum
    movsxd rax, ecx
    call print_i64_nl

    PRINTZ lbl_cpu
    movzx rax, dl
    call print_u64_nl

    mov edx, eax
    xor edx, ecx
    mov esi, ebx
    xor esi, ecx
    and edx, esi
    shr edx, 31

    PRINTZ lbl_bit
    mov eax, edx
    call print_u64_nl

    jmp exit0
