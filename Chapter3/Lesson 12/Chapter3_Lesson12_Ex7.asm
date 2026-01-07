; Chapter3_Lesson12_Ex7.asm
; Q1.31 multiplication using SHRD to extract (EDX:EAX) >> 31 with rounding
;
; build:
;   nasm -felf64 Chapter3_Lesson12_Ex7.asm -o Chapter3_Lesson12_Ex7.o
;   ld -o Chapter3_Lesson12_Ex7 Chapter3_Lesson12_Ex7.o

BITS 64
default rel

%define SYS_exit 60

%define ROUND_31 0x40000000     ; 2^(31-1)

section .data
a dd 0x60000000     ; ~0.75 in Q1.31
b dd 0x20000000     ; ~0.25 in Q1.31
p dd 0

section .text
global _start

; mul_q1_31_round: EAX=a, EDX=b -> EAX=round((a*b)/2^31)
mul_q1_31_round:
    imul edx                 ; EDX:EAX = EAX * EDX (signed 32x32)

    ; add rounding bias to 64-bit product
    add eax, ROUND_31
    adc edx, 0

    ; result = (EDX:EAX) >> 31
    shrd eax, edx, 31
    ret

_start:
    mov eax, [a]
    mov edx, [b]
    call mul_q1_31_round      ; 0.75 * 0.25 = 0.1875 (approx)
    mov [p], eax

    xor edi, edi
    mov eax, SYS_exit
    syscall
