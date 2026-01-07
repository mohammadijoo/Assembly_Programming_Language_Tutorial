; Chapter 3 - Lesson 13 Example 8: MXCSR exception flags (invalid, div-by-zero, overflow, underflow, inexact)
; File: Chapter3_Lesson13_Ex8.asm
;
; Build:
;   nasm -felf64 Chapter3_Lesson13_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o
;   ./ex8
;
; Notes:
;   - By default, exceptions are masked; operations do not trap, but MXCSR flags are set.
;   - MXCSR flags are bits 0..5:
;       0 IE invalid, 1 DE denormal, 2 ZE div-by-zero,
;       3 OE overflow, 4 UE underflow, 5 PE precision (inexact)

BITS 64
default rel

%include "Chapter3_Lesson13_Ex1.asm"

section .rodata
msg_title:  db "MXCSR flags demo (masked exceptions)", 0
msg_before: db "MXCSR (before) = ", 0
msg_after:  db "MXCSR (after)  = ", 0
msg_ie:     db "  IE (invalid)      = ", 0
msg_ze:     db "  ZE (div-by-zero)  = ", 0
msg_oe:     db "  OE (overflow)     = ", 0
msg_ue:     db "  UE (underflow)    = ", 0
msg_pe:     db "  PE (inexact)      = ", 0

mxcsr_before: dd 0
mxcsr_work:   dd 0
mxcsr_after:  dd 0

neg_one: dd -1.0
zero:    dd 0.0
one:     dd 1.0
big:     dd 3.4e38           ; near max finite float32
tiny:    dd 1.0e-38          ; small finite float32 (may underflow on multiplication)

section .text
global _start

print_flag_bit:
    ; input: eax = mxcsr, ecx = bit index, rdi = label string
    push rax
    push rcx
    call print_cstr
    pop rcx
    pop rax

    bt eax, ecx
    setc dl
    movzx rdi, dl
    call print_u64
    call print_nl
    ret

_start:
    lea rdi, [msg_title]
    call print_cstr
    call print_nl
    call print_nl

    stmxcsr [mxcsr_before]
    lea rdi, [msg_before]
    call print_cstr
    mov eax, dword [mxcsr_before]
    mov edi, eax
    call print_hex32
    call print_nl
    call print_nl

    ; Clear flags bits 0..5, keep masks/mode bits
    mov eax, dword [mxcsr_before]
    and eax, 0xFFFFFFC0
    mov dword [mxcsr_work], eax
    ldmxcsr [mxcsr_work]

    ; Trigger invalid: sqrt(-1.0) -> qNaN, sets IE
    movss xmm0, dword [neg_one]
    sqrtss xmm0, xmm0

    ; Trigger div-by-zero: 1.0 / 0.0 -> +inf, sets ZE
    movss xmm1, dword [one]
    movss xmm2, dword [zero]
    divss xmm1, xmm2

    ; Trigger overflow: big * big -> +inf, sets OE and PE
    movss xmm3, dword [big]
    mulss xmm3, xmm3

    ; Trigger underflow/inexact: tiny * tiny -> may underflow to 0 or subnormal, sets UE/PE
    movss xmm4, dword [tiny]
    mulss xmm4, xmm4

    stmxcsr [mxcsr_after]
    lea rdi, [msg_after]
    call print_cstr
    mov eax, dword [mxcsr_after]
    mov edi, eax
    call print_hex32
    call print_nl
    call print_nl

    mov eax, dword [mxcsr_after]

    lea rdi, [msg_ie]
    mov ecx, 0
    call print_flag_bit

    lea rdi, [msg_ze]
    mov ecx, 2
    call print_flag_bit

    lea rdi, [msg_oe]
    mov ecx, 3
    call print_flag_bit

    lea rdi, [msg_ue]
    mov ecx, 4
    call print_flag_bit

    lea rdi, [msg_pe]
    mov ecx, 5
    call print_flag_bit

    mov eax, SYS_exit
    xor edi, edi
    syscall
