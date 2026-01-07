; Chapter 3 - Lesson 3 (Ex11) - Exercise 3 Solution
; Very hard: Validate alignment constraints for mixed declarations.
; Print 1 line per object: 'OK\n' if aligned, else 'BAD\n'.
;
; Alignment rules (chosen for the exercise):
;   - db needs 1-byte alignment
;   - dw needs 2-byte alignment
;   - dd needs 4-byte alignment
;   - dq needs 8-byte alignment
;
; Build:
;   nasm -felf64 Chapter3_Lesson3_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o
;   ./ex11

default rel
global _start

section .data
ok_msg  db "OK", 10
ok_len  equ $-ok_msg
bad_msg db "BAD", 10
bad_len equ $-bad_msg

; Intentionally craft a mix: some aligned, some not.
x_db    db 0x11

x_dw    dw 0x2222          ; may be misaligned depending on placement
align 4
x_dd    dd 0x33333333      ; aligned to 4 by directive above

x_db2   db 0x44
x_dq1   dq 0x5555555555555555  ; likely misaligned due to x_db2

align 8
x_dq2   dq 0x6666666666666666  ; forced aligned

section .text

write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

; print_ok_bad(zf=1 => OK else BAD)
print_ok_bad:
    jnz .bad
    mov rsi, ok_msg
    mov rdx, ok_len
    jmp .out
.bad:
    mov rsi, bad_msg
    mov rdx, bad_len
.out:
    call write_stdout
    ret

; check_align(rsi=addr, rdx=align) -> sets ZF=1 if (addr & (align-1))==0
check_align:
    mov rax, rsi
    dec rdx
    and rax, rdx
    test rax, rax
    ret

_start:
    ; x_db: align 1
    lea rsi, [x_db]
    mov rdx, 1
    call check_align
    call print_ok_bad

    ; x_dw: align 2
    lea rsi, [x_dw]
    mov rdx, 2
    call check_align
    call print_ok_bad

    ; x_dd: align 4
    lea rsi, [x_dd]
    mov rdx, 4
    call check_align
    call print_ok_bad

    ; x_dq1: align 8
    lea rsi, [x_dq1]
    mov rdx, 8
    call check_align
    call print_ok_bad

    ; x_dq2: align 8
    lea rsi, [x_dq2]
    mov rdx, 8
    call check_align
    call print_ok_bad

    mov eax, 60
    xor edi, edi
    syscall
