; Chapter3_Lesson12_Ex5.asm
; Q16.16 division with rounding: z = round((num * 2^16) / den)
;
; build:
;   nasm -felf64 Chapter3_Lesson12_Ex5.asm -o Chapter3_Lesson12_Ex5.o
;   ld -o Chapter3_Lesson12_Ex5 Chapter3_Lesson12_Ex5.o

BITS 64
default rel

%define SYS_exit 60
%define FRAC_BITS 16

section .data
num dd 0x00030000     ; 3.0
den dd 0x00020000     ; 2.0
quo dd 0

section .text
global _start

; div_q16_16_round: EAX=num, EDX=den -> EAX=rounded quotient
; If den is zero, returns 0.
div_q16_16_round:
    test edx, edx
    jnz .nonzero
    xor eax, eax
    ret

.nonzero:
    movsxd rax, eax          ; numerator in 64-bit
    shl rax, FRAC_BITS       ; scale up: num * 2^16
    movsxd rbx, edx          ; divisor in 64-bit

    ; abs(den) into R8
    mov r8, rbx
    mov r9, r8
    sar r9, 63               ; sign mask 0 or -1
    xor r8, r9
    sub r8, r9               ; r8 = abs(den)
    shr r8, 1                ; half = abs(den)/2

    ; if (num xor den) is negative, subtract half; else add half
    mov r10, rax
    xor r10, rbx
    test r10, r10
    js .opp_sign
    add rax, r8
    jmp .do_div
.opp_sign:
    sub rax, r8

.do_div:
    cqo
    idiv rbx                 ; quotient in RAX
    mov eax, eax
    ret

_start:
    mov eax, [num]
    mov edx, [den]
    call div_q16_16_round    ; 3/2 = 1.5 -> 0x00018000
    mov [quo], eax

    xor edi, edi
    mov eax, SYS_exit
    syscall
