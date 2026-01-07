; Chapter 3 - Lesson 9 (Programming Exercises with Solutions)
; Ex13 (Exercise 1 Solution):
;   Implement add_i32_checked(a,b) WITHOUT using JO/JNO/SETO.
;   Use only bitwise logic to compute overflow for 32-bit signed addition.
;
; Contract:
;   Inputs:  EAX = a (int32), EBX = b (int32)
;   Outputs: EAX = sum (int32), BL = overflow (0/1)
;
; Test harness prints:
;   - a, b, sum (as i64), overflow

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
hdr:  db "Exercise 1: add_i32_checked without OF flag",10,0
lbl_a: db "  a=",0
lbl_b: db " b=",0
lbl_s: db " sum=",0
lbl_o: db " ovf=",0
nl:   db 10,0

section .text

add_i32_checked:
    ; sum = a + b
    mov ecx, eax
    add ecx, ebx

    ; overflow = ((a ^ sum) & (b ^ sum)) signbit
    mov edx, eax
    xor edx, ecx
    mov esi, ebx
    xor esi, ecx
    and edx, esi
    shr edx, 31                  ; 0/1

    mov eax, ecx
    mov bl, dl
    ret

print_case:
    ; Inputs: EAX=a, EBX=b
    push rax
    push rbx

    PRINTZ lbl_a
    movsxd rax, eax
    call print_i64_nl

    PRINTZ lbl_b
    mov rax, rbx                 ; RBX currently holds b in low 32; sign extend
    movsxd rax, ebx
    call print_i64_nl

    pop rbx
    pop rax

    call add_i32_checked          ; returns sum in EAX, ovf in BL

    PRINTZ lbl_s
    movsxd rax, eax
    call print_i64_nl

    PRINTZ lbl_o
    movzx rax, bl
    call print_u64_nl
    call print_nl
    ret

_start:
    PRINTZ hdr

    ; Case 1: 2147483647 + 1 => overflow
    mov eax, 0x7FFFFFFF
    mov ebx, 1
    call print_case

    ; Case 2: -1000000000 + -1500000000 => overflow
    mov eax, -1000000000
    mov ebx, -1500000000
    call print_case

    ; Case 3: -2000000000 + 1000000000 => no overflow
    mov eax, -2000000000
    mov ebx, 1000000000
    call print_case

    ; Case 4: 123456789 + 987654321 => no overflow
    mov eax, 123456789
    mov ebx, 987654321
    call print_case

    jmp exit0
