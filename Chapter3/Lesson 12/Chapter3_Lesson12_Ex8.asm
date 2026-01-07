; Chapter3_Lesson12_Ex8.asm
; Polynomial evaluation in Q16.16 using Horner-like structuring:
;   y = 0.5*x^3 - 1.25*x + 2.0
;
; build:
;   nasm -felf64 Chapter3_Lesson12_Ex8.asm -o Chapter3_Lesson12_Ex8.o
;   ld -o Chapter3_Lesson12_Ex8 Chapter3_Lesson12_Ex8.o

BITS 64
default rel

%define SYS_exit 60
%define FRAC_BITS 16
%define ROUND_BIAS (1 << (FRAC_BITS-1))

section .data
x dd 0x00018000           ; x = 1.5 in Q16.16
y dd 0

; coefficients in Q16.16
c_half    dd 0x00008000    ; 0.5
c_neg125  dd 0xFFFEC000    ; -1.25
c_two     dd 0x00020000    ; 2.0

section .text
global _start

; mul_q16_16_round: EAX=a, EDX=b -> EAX=round((a*b)/2^16)
mul_q16_16_round:
    movsxd rax, eax
    movsxd rdx, edx
    imul rax, rdx
    test rax, rax
    js .neg
    add rax, ROUND_BIAS
    jmp .shift
.neg:
    sub rax, ROUND_BIAS
.shift:
    sar rax, FRAC_BITS
    mov eax, eax
    ret

_start:
    ; t = 0.5 * x
    mov eax, [c_half]
    mov edx, [x]
    call mul_q16_16_round           ; EAX = t

    ; t = t * x  -> 0.5*x^2
    mov edx, [x]
    call mul_q16_16_round

    ; t = t + (-1.25) -> t - 1.25
    add eax, [c_neg125]

    ; t = t * x -> 0.5*x^3 - 1.25*x
    mov edx, [x]
    call mul_q16_16_round

    ; t = t + 2.0
    add eax, [c_two]
    mov [y], eax

    xor edi, edi
    mov eax, SYS_exit
    syscall
