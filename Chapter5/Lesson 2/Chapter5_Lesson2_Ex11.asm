; Chapter5_Lesson2_Ex11.asm
; Programming Exercise (Very Hard) — Robust atoi (signed 64-bit) with overflow detection
;
; Parse a signed decimal ASCII string into int64:
;   - optional leading spaces
;   - optional sign '+' or '-'
;   - digits required
;   - detect overflow (range: [-2^63, 2^63-1])
;
; On success: prints "value=<n>" and exits 0.
; On error:   prints "error" and exits 1.
;
; Build:
;   nasm -felf64 Chapter5_Lesson2_Ex11.asm -o Chapter5_Lesson2_Ex11.o
;   ld -o Chapter5_Lesson2_Ex11 Chapter5_Lesson2_Ex11.o

BITS 64
default rel

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
; Try changing these inputs:
; in_str: db "   -9223372036854775808", 0
; in_str: db "9223372036854775807", 0
; in_str: db "9223372036854775808", 0         ; overflow
; in_str: db " -00123xyz", 0                  ; stops at 'x' (accepted here)
in_str: db "   -123456789012345", 0

ok_msg:  db "value=", 0
ok_len   equ $-ok_msg-1
err_msg: db "error", 10
err_len  equ $-err_msg

section .bss
outbuf: resb 40

section .text
global _start

write_stdout:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    ret

print_u64_nl:
    mov rbx, 10
    lea rdi, [outbuf + 39]
    mov byte [rdi], 10
    dec rdi
.convert:
    xor edx, edx
    div rbx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz .convert
    inc rdi
    lea rsi, [rdi]
    lea rcx, [outbuf + 40]
    sub rcx, rsi
    mov rdx, rcx
    jmp write_stdout

print_i64_nl:
    test rax, rax
    jns .pos
    lea rsi, [minus]
    mov edx, 1
    call write_stdout
    not rax
    add rax, 1
    jmp print_u64_nl
.pos:
    jmp print_u64_nl

minus: db "-"

_start:
    lea rsi, [in_str]

    ; skip leading spaces (ASCII <= ' ')
.skip_ws:
    mov al, [rsi]
    cmp al, ' '
    ja  .parse_sign
    test al, al
    je  .error
    inc rsi
    jmp .skip_ws

.parse_sign:
    xor ebx, ebx              ; BL = sign (0 positive, 1 negative)
    mov al, [rsi]
    cmp al, '-'
    jne .check_plus
    mov bl, 1
    inc rsi
    jmp .need_digit
.check_plus:
    cmp al, '+'
    jne .need_digit
    inc rsi

.need_digit:
    mov al, [rsi]
    cmp al, '0'
    jb  .error
    cmp al, '9'
    ja  .error

    xor r8, r8                ; R8 = magnitude accumulator (unsigned)

    ; limit = 2^63-1 (positive) or 2^63 (negative)
    mov r12, 9223372036854775807
    test bl, bl
    jz .loop
    mov r12, 9223372036854775808

.loop:
    mov al, [rsi]
    cmp al, '0'
    jb  .finish
    cmp al, '9'
    ja  .finish

    movzx r13, al
    sub r13, '0'              ; digit in R13

    ; threshold = (limit - digit)/10
    mov rax, r12
    sub rax, r13
    xor edx, edx
    mov rcx, 10
    div rcx                   ; unsigned => RAX = threshold
    mov r9, rax

    cmp r8, r9
    ja  .error                ; would overflow

    ; magnitude = magnitude*10 + digit (strength-reduced)
    lea r8, [r8*8 + r8*2]
    add r8, r13

    inc rsi
    jmp .loop

.finish:
    ; magnitude in R8; produce signed value in RAX
    mov rax, r8
    test bl, bl
    jz .emit_ok

    ; negative: special-case INT64_MIN
    cmp r8, 9223372036854775808
    jne .negate
    mov rax, 0x8000000000000000
    jmp .emit_ok

.negate:
    not rax
    add rax, 1

.emit_ok:
    lea rsi, [ok_msg]
    mov edx, ok_len
    call write_stdout
    call print_i64_nl

    xor edi, edi
    mov eax, SYS_exit
    syscall

.error:
    lea rsi, [err_msg]
    mov edx, err_len
    call write_stdout
    mov edi, 1
    mov eax, SYS_exit
    syscall
