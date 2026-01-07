; Chapter 4 - Lesson 5 (Exercise Solution)
; File: Chapter4_Lesson5_Ex12.asm
; Task: Parse an unsigned decimal string into u64 with overflow detection (CMP/TEST-driven).
; Build:
;   nasm -felf64 Chapter4_Lesson5_Ex12.asm -o ex12.o
;   ld ex12.o -o ex12

%include "Chapter4_Lesson5_Ex1.asm"

global _start

section .data
; Try changing this value to force overflow:
;   "18446744073709551616" overflows u64.
num_str: db "18446744073709551615", 0  ; UINT64_MAX

msg_ok:  db "parse_u64 OK, value = ", 0
msg_ov:  db "parse_u64 overflow", 10, 0
msg_bad: db "parse_u64 invalid character", 10, 0

section .text
; int parse_u64(rsi=ptr) -> (rax=value, rdx=status)
; status: rdx=0 OK, rdx=1 overflow, rdx=2 invalid
parse_u64:
    xor eax, eax
    xor edx, edx

    ; threshold = UINT64_MAX / 10 = 1844674407370955161
    mov r8, 1844674407370955161
    mov r9b, 5            ; UINT64_MAX % 10

.loop:
    mov bl, [rsi]
    test bl, bl
    jz .done

    cmp bl, '0'
    jb .invalid
    cmp bl, '9'
    ja .invalid

    sub bl, '0'
    movzx ebx, bl         ; digit in rbx (0..9)

    ; if rax > threshold -> overflow
    cmp rax, r8
    ja .overflow
    jne .safe_mul

    ; if rax == threshold and digit > 5 -> overflow
    cmp bl, r9b
    ja .overflow

.safe_mul:
    imul rax, rax, 10
    add rax, rbx
    inc rsi
    jmp .loop

.done:
    xor edx, edx
    ret

.overflow:
    mov edx, 1
    ret

.invalid:
    mov edx, 2
    ret

_start:
    lea rsi, [rel num_str]
    call parse_u64

    test edx, edx
    jz .ok
    cmp edx, 1
    je .ov
    jmp .bad

.ok:
    lea rsi, [rel msg_ok]
    call print_cstr
    ; rax already holds the value
    call print_hex64
    SYS_EXIT 0

.ov:
    lea rsi, [rel msg_ov]
    call print_cstr
    SYS_EXIT 1

.bad:
    lea rsi, [rel msg_bad]
    call print_cstr
    SYS_EXIT 2
