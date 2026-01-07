; Chapter3_Lesson12_Ex4.asm
; Q16.16 multiplication with symmetric rounding and saturation
;
; build:
;   nasm -felf64 Chapter3_Lesson12_Ex4.asm -o Chapter3_Lesson12_Ex4.o
;   ld -o Chapter3_Lesson12_Ex4 Chapter3_Lesson12_Ex4.o

BITS 64
default rel

%define SYS_exit 60

%define Q16_16_MAX 0x7FFFFFFF
%define Q16_16_MIN 0x80000000
%define FRAC_BITS 16
%define ROUND_BIAS (1 << (FRAC_BITS-1))

section .data
x dd 0x00018000     ; 1.5
y dd 0xFFFF8000     ; -0.5
z dd 0

section .text
global _start

; mul_q16_16_round_sat: EAX=x, EDX=y -> EAX=round((x*y)/2^16), saturated
mul_q16_16_round_sat:
    movsxd rax, eax
    movsxd rdx, edx
    imul rax, rdx                ; full 64-bit product is safe for 32x32

    ; symmetric rounding before arithmetic shift
    test rax, rax
    js .neg
    add rax, ROUND_BIAS
    jmp .shift
.neg:
    sub rax, ROUND_BIAS
.shift:
    sar rax, FRAC_BITS

    ; saturate to 32-bit signed range (still interpreted as Q16.16)
    cmp rax, Q16_16_MAX
    jle .chk_min
    mov eax, Q16_16_MAX
    ret
.chk_min:
    cmp rax, 0xFFFFFFFF80000000  ; -2^31 in 64-bit
    jge .in_range
    mov eax, Q16_16_MIN
    ret
.in_range:
    mov eax, eax
    ret

_start:
    mov eax, [x]
    mov edx, [y]
    call mul_q16_16_round_sat      ; expect -0.75 -> 0xFFFF4000
    mov [z], eax

    xor edi, edi
    mov eax, SYS_exit
    syscall
