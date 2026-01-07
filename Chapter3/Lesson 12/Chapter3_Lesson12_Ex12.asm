; Chapter3_Lesson12_Ex12.asm
; Programming Exercise Solution:
;   Dot product of two Q1.31 vectors with a 128-bit accumulator.
;   Produces a Q1.31 result (rounded) and prints it as 8 hex digits.
;
; build:
;   nasm -felf64 Chapter3_Lesson12_Ex12.asm -o Chapter3_Lesson12_Ex12.o
;   ld -o Chapter3_Lesson12_Ex12 Chapter3_Lesson12_Ex12.o

BITS 64
default rel

%define SYS_write 1
%define SYS_exit  60

%define ROUND_31 0x40000000
%define Q31_MAX  0x7FFFFFFF
%define Q31_MIN  0x80000000

section .data
N equ 8

; Example vectors in Q1.31 (approx values shown in comments)
A dd 0x40000000, 0x20000000, 0x60000000, 0xE0000000, 0x10000000, 0x7FFFFFFF, 0xC0000000, 0x30000000
;    0.5         0.25        0.75       -0.25        0.125       ~1.0       -0.5         0.375
B dd 0x20000000, 0x40000000, 0x10000000, 0x10000000, 0x70000000, 0x20000000, 0x20000000, 0xE0000000
;    0.25        0.5         0.125      0.125       0.875       0.25        0.25        -0.25

hex_digits db "0123456789ABCDEF", 10
outbuf     db "00000000", 10

section .text
global _start

; print_hex32:
;   input: EAX
;   prints 8 hex digits + newline
print_hex32:
    lea rsi, [outbuf]
    mov ecx, 8
    mov ebx, eax
.hex_loop:
    mov edx, ebx
    shr edx, 28
    and edx, 0xF
    mov dl, [hex_digits + rdx]
    mov [rsi], dl
    inc rsi
    shl ebx, 4
    dec ecx
    jnz .hex_loop

    ; newline
    mov byte [rsi], 10

    mov edi, 1
    lea rsi, [outbuf]
    mov edx, 9
    mov eax, SYS_write
    syscall
    ret

_start:
    ; 128-bit accumulator in RDX:RAX (signed)
    xor rax, rax
    xor rdx, rdx

    xor r8d, r8d               ; i=0
.loop:
    cmp r8d, N
    je .done

    mov eax, [A + r8*4]
    mov r9d, [B + r8*4]
    mov edx, r9d
    imul edx                    ; EDX:EAX = A[i]*B[i] in Q2.62

    ; sign-extend 64-bit product into R11 (low) and R10 (sign)
    mov r11d, eax
    mov r10d, edx
    shl r10, 32
    and r11, 0xFFFFFFFF
    or  r11, r10                ; R11 = 64-bit product

    mov r10, r11
    sar r10, 63                 ; R10 = 0 or -1 (sign extension)

    add rax, r11
    adc rdx, r10

    inc r8d
    jmp .loop

.done:
    ; rounding before shifting right by 31:
    ; If accumulator is negative, subtract bias; else add bias.
    mov r9, rdx
    sar r9, 63
    test r9, r9
    js .round_neg
    add rax, ROUND_31
    adc rdx, 0
    jmp .shift
.round_neg:
    sub rax, ROUND_31
    sbb rdx, 0

.shift:
    ; arithmetic shift right by 31 on 128-bit value
    shrd rax, rdx, 31
    sar  rdx, 31

    ; saturate to signed 32-bit (Q1.31)
    cmp rax, Q31_MAX
    jle .chk_min
    mov eax, Q31_MAX
    jmp .print
.chk_min:
    cmp rax, 0xFFFFFFFF80000000
    jge .in_range
    mov eax, Q31_MIN
    jmp .print
.in_range:
    mov eax, eax

.print:
    call print_hex32

    xor edi, edi
    mov eax, SYS_exit
    syscall
