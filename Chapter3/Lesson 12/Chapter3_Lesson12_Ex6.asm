; Chapter3_Lesson12_Ex6.asm
; Rescaling between different Q formats: Q8.8 <-> Q16.16
;
; build:
;   nasm -felf64 Chapter3_Lesson12_Ex6.asm -o Chapter3_Lesson12_Ex6.o
;   ld -o Chapter3_Lesson12_Ex6 Chapter3_Lesson12_Ex6.o

BITS 64
default rel

%define SYS_exit 60

section .data
; Q8.8 stored in 16-bit signed words:
; 0x0190 = 1.5625 because 0x0190 / 256 = 400 / 256
temp_q8_8     dw 0x0190
bias_q16_16   dd 0x0000C000     ; 0.75 in Q16.16

temp_q16_16   dd 0
sum_q16_16    dd 0
back_q8_8     dw 0

section .text
global _start

; convert Q8.8 in AX to Q16.16 in EAX
q8_8_to_q16_16:
    movsx eax, ax
    shl eax, 8                ; raise frac bits: 8 -> 16
    ret

; convert Q16.16 in EAX to Q8.8 in AX with rounding and int16 clamp
q16_16_to_q8_8_round:
    test eax, eax
    js .neg
    add eax, 0x00000080       ; add 0.5 ulp of Q8.8 before shifting
    jmp .shift
.neg:
    sub eax, 0x00000080
.shift:
    sar eax, 8

    ; clamp to int16 range (still interpreted as Q8.8)
    cmp eax, 32767
    jle .chk_min
    mov eax, 32767
    jmp .out
.chk_min:
    cmp eax, -32768
    jge .out
    mov eax, -32768
.out:
    mov ax, ax
    ret

_start:
    mov ax, [temp_q8_8]
    call q8_8_to_q16_16
    mov [temp_q16_16], eax

    mov eax, [temp_q16_16]
    add eax, [bias_q16_16]
    mov [sum_q16_16], eax

    mov eax, [sum_q16_16]
    call q16_16_to_q8_8_round
    mov [back_q8_8], ax

    xor edi, edi
    mov eax, SYS_exit
    syscall
