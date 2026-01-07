; Chapter3_Lesson12_Ex15.asm
; Programming Exercise Solution:
;   Biquad IIR filter in fixed-point.
;
; Difference equation:
;   y[n] = b0*x[n] + b1*x[n-1] + b2*x[n-2] - a1*y[n-1] - a2*y[n-2]
;
; Representation:
;   x, y are Q1.31 (int32 scaled by 2^31)
;   coefficients are Q2.30 (int32 scaled by 2^30) so they can represent about [-2, 2)
;
; Multiply rule:
;   (Q2.30 * Q1.31) -> product has 61 fractional bits, convert to Q1.31 by shifting right 30.
;
; build:
;   nasm -felf64 Chapter3_Lesson12_Ex15.asm -o Chapter3_Lesson12_Ex15.o
;   ld -o Chapter3_Lesson12_Ex15 Chapter3_Lesson12_Ex15.o
;
; Inspect Y array in a debugger to validate the output samples.

BITS 64
default rel

%define SYS_exit  60

%define ROUND_30 0x20000000        ; 2^(30-1) for rounding when shifting by 30
%define Q31_MAX  0x7FFFFFFF
%define Q31_MIN  0x80000000

section .data
N equ 16

; Example coefficients (stable low-pass-like shape; not tuned for audio production)
; b0=0.067455, b1=0.134911, b2=0.067455, a1=-1.14298, a2=0.412802
; Stored in Q2.30:
b0 dd 0x0448F5C9
b1 dd 0x0891EB92
b2 dd 0x0448F5C9
a1 dd 0xB6B07A3E           ; negative
a2 dd 0x1A6C8C3B

; Input samples x[n] in Q1.31 (simple impulse + decay)
X dd 0x7FFFFFFF, 0x40000000, 0x20000000, 0x10000000, 0x08000000, 0x04000000, 0x02000000, 0x01000000, \
     0x00800000, 0x00400000, 0x00200000, 0x00100000, 0x00080000, 0x00040000, 0x00020000, 0x00010000

Y times N dd 0

section .text
global _start

; mul_q2_30_q1_31_to_q1_31:
;   EAX = coeff (Q2.30), EDX = sample (Q1.31)
;   returns EAX = rounded Q1.31 result
mul_q2_30_q1_31_to_q1_31:
    imul edx                     ; EDX:EAX = coeff * sample (signed)
    add eax, ROUND_30
    adc edx, 0
    shrd eax, edx, 30            ; >> 30 yields Q1.31
    ret

; sat_q31_from_r64:
;   input: RAX signed 64-bit accumulator, output: EAX saturated to Q1.31 range
sat_q31_from_r64:
    cmp rax, Q31_MAX
    jle .chk_min
    mov eax, Q31_MAX
    ret
.chk_min:
    cmp rax, 0xFFFFFFFF80000000
    jge .in_range
    mov eax, Q31_MIN
    ret
.in_range:
    mov eax, eax
    ret

_start:
    xor r8d, r8d                 ; n = 0
    xor r12d, r12d                ; x1
    xor r13d, r13d                ; x2
    xor r14d, r14d                ; y1
    xor r15d, r15d                ; y2

.loop_n:
    cmp r8d, N
    je .done

    ; x0 = X[n]
    mov r11d, [X + r8*4]

    ; acc = b0*x0 + b1*x1 + b2*x2 - a1*y1 - a2*y2
    xor r9, r9                    ; 64-bit accumulator in r9

    ; b0*x0
    mov eax, [b0]
    mov edx, r11d
    call mul_q2_30_q1_31_to_q1_31
    movsxd rcx, eax
    add r9, rcx

    ; b1*x1
    mov eax, [b1]
    mov edx, r12d
    call mul_q2_30_q1_31_to_q1_31
    movsxd rcx, eax
    add r9, rcx

    ; b2*x2
    mov eax, [b2]
    mov edx, r13d
    call mul_q2_30_q1_31_to_q1_31
    movsxd rcx, eax
    add r9, rcx

    ; -a1*y1 (subtract a1*y1)
    mov eax, [a1]
    mov edx, r14d
    call mul_q2_30_q1_31_to_q1_31
    movsxd rcx, eax
    sub r9, rcx

    ; -a2*y2
    mov eax, [a2]
    mov edx, r15d
    call mul_q2_30_q1_31_to_q1_31
    movsxd rcx, eax
    sub r9, rcx

    ; y0 = saturate(acc)
    mov rax, r9
    call sat_q31_from_r64
    mov [Y + r8*4], eax

    ; state update: x2=x1, x1=x0, y2=y1, y1=y0
    mov r13d, r12d
    mov r12d, r11d
    mov r15d, r14d
    mov r14d, eax

    inc r8d
    jmp .loop_n

.done:
    xor edi, edi
    mov eax, SYS_exit
    syscall
