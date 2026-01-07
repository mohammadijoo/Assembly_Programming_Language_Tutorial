; Chapter3_Lesson12_Ex11.asm
; Using an include-style file for fixed-point primitives.
;
; build:
;   nasm -felf64 Chapter3_Lesson12_Ex11.asm -o Chapter3_Lesson12_Ex11.o
;   ld -o Chapter3_Lesson12_Ex11 Chapter3_Lesson12_Ex11.o
; run:
;   ./Chapter3_Lesson12_Ex11
;
; Expected output: a single fixed-point number in decimal.

BITS 64
default rel

%define SYS_write 1
%define SYS_exit  60

%include "Chapter3_Lesson12_Ex10.asm"

section .data
; a = 5.25, b = -2.5, c = 3.0, one = 1.0   (all Q16.16)
a_q dd 0x00054000
b_q dd 0xFFFD8000
c_q dd 0x00030000
one dd 0x00010000

section .bss
buf resb 64

section .text
global _start

; print_q16_16_4dp: (same as Chapter3_Lesson12_Ex9.asm)
print_q16_16_4dp:
    movsxd rax, eax
    mov r10, rax
    test rax, rax
    jns .abs_done
    neg rax
.abs_done:
    mov r8, rax
    shr r8, 16
    mov r9, rax
    and r9, 0xFFFF

    mov rax, r9
    imul rax, 10000
    add rax, 32768
    shr rax, 16
    mov r9, rax

    lea rdi, [buf + 63]
    mov byte [rdi], 10
    dec rdi

    mov rcx, 4
.frac_loop:
    mov eax, r9d
    xor edx, edx
    mov ebx, 10
    div ebx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    mov r9d, eax
    dec rcx
    jnz .frac_loop

    mov byte [rdi], '.'
    dec rdi

    mov r9, r8
    test r9, r9
    jnz .int_loop
    mov byte [rdi], '0'
    dec rdi
    jmp .int_done

.int_loop:
    mov rax, r9
    xor rdx, rdx
    mov rbx, 10
    div rbx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    mov r9, rax
    test r9, r9
    jnz .int_loop

.int_done:
    test r10, r10
    jns .sign_done
    mov byte [rdi], '-'
    dec rdi
.sign_done:
    lea rsi, [rdi + 1]
    lea rdx, [buf + 64]
    sub rdx, rsi
    mov edi, 1
    mov eax, SYS_write
    syscall
    ret

_start:
    ; y = (a*b)/c + 1
    mov eax, [a_q]
    mov edx, [b_q]
    call mul_q16_16_round_sat      ; EAX = a*b

    mov edx, [c_q]
    call div_q16_16_round          ; EAX = (a*b)/c

    mov edx, [one]
    call sat_add_q16_16            ; EAX = (a*b)/c + 1

    call print_q16_16_4dp

    xor edi, edi
    mov eax, SYS_exit
    syscall
