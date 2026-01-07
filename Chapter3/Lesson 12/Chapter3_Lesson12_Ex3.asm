; Chapter3_Lesson12_Ex3.asm
; Saturating add/sub for signed Q16.16 using JO (overflow flag)
;
; build:
;   nasm -felf64 Chapter3_Lesson12_Ex3.asm -o Chapter3_Lesson12_Ex3.o
;   ld -o Chapter3_Lesson12_Ex3 Chapter3_Lesson12_Ex3.o

BITS 64
default rel

%define SYS_exit 60

%define Q16_16_MAX 0x7FFFFFFF
%define Q16_16_MIN 0x80000000

section .data
a dd 0x7FFF0000         ; 32767.0
b dd 0x00020000         ; 2.0
c dd 0x80010000         ; about -32767.0
d dd 0xFFFF0000         ; -1.0

res_add1 dd 0
res_add2 dd 0
res_sub1 dd 0

section .text
global _start

; sat_add_q16_16: EAX=a, EDX=b -> EAX=result
sat_add_q16_16:
    mov ecx, eax
    add ecx, edx
    jno .ok
    ; overflow: clamp based on sign of a
    test eax, eax
    js .neg
    mov ecx, Q16_16_MAX
    jmp .ok
.neg:
    mov ecx, Q16_16_MIN
.ok:
    mov eax, ecx
    ret

; sat_sub_q16_16: EAX=a, EDX=b -> EAX=a-b
sat_sub_q16_16:
    mov ecx, eax
    sub ecx, edx
    jno .ok
    test eax, eax
    js .neg
    mov ecx, Q16_16_MAX
    jmp .ok
.neg:
    mov ecx, Q16_16_MIN
.ok:
    mov eax, ecx
    ret

_start:
    ; 32767 + 2 saturates
    mov eax, [a]
    mov edx, [b]
    call sat_add_q16_16
    mov [res_add1], eax

    ; (-32767) + (-1) saturates
    mov eax, [c]
    mov edx, [d]
    call sat_add_q16_16
    mov [res_add2], eax

    ; (32767) - (-1) saturates
    mov eax, [a]
    mov edx, [d]
    call sat_sub_q16_16
    mov [res_sub1], eax

    xor edi, edi
    mov eax, SYS_exit
    syscall
