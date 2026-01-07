; Chapter 3 - Lesson 13 Example 7: Rounding control (MXCSR) and CVTSS2SI vs CVTTSS2SI
; File: Chapter3_Lesson13_Ex7.asm
;
; Build:
;   nasm -felf64 Chapter3_Lesson13_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o
;   ./ex7
;
; CVTSS2SI uses MXCSR rounding mode; CVTTSS2SI truncates regardless of MXCSR.

BITS 64
default rel

%include "Chapter3_Lesson13_Ex1.asm"

section .rodata
msg_title:  db "Rounding + float-to-int conversion demo", 0
msg_a:      db "Input x (float32 bits) = ", 0
msg_mode:   db "MXCSR rounding mode = ", 0
msg_near:   db "nearest-even", 0
msg_down:   db "down (toward -inf)", 0
msg_up:     db "up (toward +inf)", 0
msg_trunc:  db "truncate (toward 0)", 0
msg_cvt:    db "  cvtss2si  result = ", 0
msg_cvtt:   db "  cvttss2si result = ", 0

x_pos: dd 1.9
x_neg: dd -1.9

; MXCSR default is typically 0x1F80.
; Rounding control bits are 14:13:
;   00 nearest-even, 01 down, 10 up, 11 truncate
mxcsr_saved: dd 0
mxcsr_near:  dd 0x00001F80
mxcsr_down:  dd 0x00001F80 | 0x00002000
mxcsr_up:    dd 0x00001F80 | 0x00004000
mxcsr_trunc: dd 0x00001F80 | 0x00006000

section .text
global _start

; run_one_mode(rdi=ptr_mode_name, rsi=ptr_mxcsr, xmm0=scalar float)
run_one_mode:
    ; load mxcsr
    ldmxcsr [rsi]

    lea rdi, [msg_mode]
    call print_cstr
    mov rdi, rdi             ; mode string already in rdi
    call print_cstr
    call print_nl

    ; cvtss2si (obeys rounding)
    cvtss2si eax, xmm0
    lea rdi, [msg_cvt]
    call print_cstr
    movsxd rdi, eax
    call print_i64
    call print_nl

    ; cvttss2si (truncate regardless)
    cvttss2si eax, xmm0
    lea rdi, [msg_cvtt]
    call print_cstr
    movsxd rdi, eax
    call print_i64
    call print_nl

    call print_nl
    ret

_start:
    lea rdi, [msg_title]
    call print_cstr
    call print_nl
    call print_nl

    ; Save current MXCSR and restore at end
    stmxcsr [mxcsr_saved]

    ; ---- x = +1.9 ----
    lea rdi, [msg_a]
    call print_cstr
    movss xmm0, dword [x_pos]
    movd edi, xmm0
    call print_hex32
    call print_nl
    call print_nl

    lea rdi, [msg_near]
    lea rsi, [mxcsr_near]
    call run_one_mode

    lea rdi, [msg_down]
    lea rsi, [mxcsr_down]
    call run_one_mode

    lea rdi, [msg_up]
    lea rsi, [mxcsr_up]
    call run_one_mode

    lea rdi, [msg_trunc]
    lea rsi, [mxcsr_trunc]
    call run_one_mode

    ; ---- x = -1.9 ----
    lea rdi, [msg_a]
    call print_cstr
    movss xmm0, dword [x_neg]
    movd edi, xmm0
    call print_hex32
    call print_nl
    call print_nl

    lea rdi, [msg_near]
    lea rsi, [mxcsr_near]
    call run_one_mode

    lea rdi, [msg_down]
    lea rsi, [mxcsr_down]
    call run_one_mode

    lea rdi, [msg_up]
    lea rsi, [mxcsr_up]
    call run_one_mode

    lea rdi, [msg_trunc]
    lea rsi, [mxcsr_trunc]
    call run_one_mode

    ; Restore original MXCSR
    ldmxcsr [mxcsr_saved]

    mov eax, SYS_exit
    xor edi, edi
    syscall
