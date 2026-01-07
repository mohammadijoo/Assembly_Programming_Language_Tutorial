; Chapter3_Lesson12_Ex2.asm
; Conversions between int32 and Q16.16 (truncation and rounding)
;
; build:
;   nasm -felf64 Chapter3_Lesson12_Ex2.asm -o Chapter3_Lesson12_Ex2.o
;   ld -o Chapter3_Lesson12_Ex2 Chapter3_Lesson12_Ex2.o

BITS 64
default rel

%define SYS_exit 60

section .data
i_value       dd -37
q_value       dd 0
back_trunc    dd 0
back_round    dd 0

section .text
global _start

; int32 in EAX -> Q16.16 in EAX
int_to_q16_16:
    shl eax, 16
    ret

; Q16.16 in EAX -> int32 by truncation (SAR corresponds to floor for negatives)
q16_16_to_int_trunc:
    sar eax, 16
    ret

; Q16.16 in EAX -> int32 rounded to nearest (ties away from zero)
q16_16_to_int_round:
    test eax, eax
    js .neg
    add eax, 0x00008000
    jmp .shift
.neg:
    sub eax, 0x00008000
.shift:
    sar eax, 16
    ret

_start:
    ; q_value = i_value << 16
    mov eax, [i_value]
    call int_to_q16_16
    mov [q_value], eax

    ; back_trunc = trunc(q_value)
    mov eax, [q_value]
    call q16_16_to_int_trunc
    mov [back_trunc], eax

    ; back_round = round(q_value + 0.25)
    mov eax, [q_value]
    add eax, 0x00004000              ; +0.25
    call q16_16_to_int_round
    mov [back_round], eax

    xor edi, edi
    mov eax, SYS_exit
    syscall
