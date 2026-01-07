bits 64
default rel

global _start

; Chapter 3, Lesson 7, Example 4
; UTF-8 encoder: codepoint -> 1..4 bytes (reject surrogates and out-of-range).
; Demo: encodes [$, ¢, €, 😀] and writes UTF-8 bytes to stdout (terminal must be UTF-8).

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    cps:    dd 0x24, 0xA2, 0x20AC, 0x1F600
    cps_n:  equ 4

    nl:     db 10

section .bss
    outbuf: resb 64

section .text

_start:
    lea r12, [outbuf]          ; output cursor
    xor ebx, ebx               ; i=0

.loop:
    cmp ebx, cps_n
    jae .emit

    mov edi, dword [cps + rbx*4]   ; codepoint
    mov rsi, r12                    ; out pointer
    call utf8_encode
    test eax, eax
    jz .bad

    add r12, rax
    inc ebx
    jmp .loop

.emit:
    ; newline
    mov byte [r12], 10
    inc r12

    ; write outbuf..r12
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [outbuf]
    mov rdx, r12
    sub rdx, rsi
    syscall

    xor edi, edi
    mov eax, SYS_exit
    syscall

.bad:
    ; If encoding fails, exit with code 1.
    mov edi, 1
    mov eax, SYS_exit
    syscall

; -------------------------------------------------------
; utf8_encode
; IN:  EDI = Unicode code point (0..0x10FFFF)
;      RSI = pointer to output buffer (at least 4 bytes)
; OUT: EAX = number of bytes written (1..4), or 0 on error
; Clobbers: rax, rcx, rdx
; -------------------------------------------------------
utf8_encode:
    mov eax, edi
    cmp eax, 0x10FFFF
    ja  .err

    ; reject surrogate range: 0xD800..0xDFFF
    cmp eax, 0xD800
    jb  .not_sur
    cmp eax, 0xDFFF
    jbe .err
.not_sur:

    cmp eax, 0x7F
    jbe .one

    cmp eax, 0x7FF
    jbe .two

    cmp eax, 0xFFFF
    jbe .three

    jmp .four

.one:
    mov [rsi], al
    mov eax, 1
    ret

.two:
    ; b1 = 110xxxxx = 0xC0 | (cp >> 6)
    ; b2 = 10xxxxxx = 0x80 | (cp & 0x3F)
    mov ecx, eax
    shr ecx, 6
    or  cl, 0xC0
    mov [rsi], cl

    and eax, 0x3F
    or  al, 0x80
    mov [rsi+1], al

    mov eax, 2
    ret

.three:
    mov ecx, eax
    shr ecx, 12
    or  cl, 0xE0
    mov [rsi], cl

    mov ecx, eax
    shr ecx, 6
    and ecx, 0x3F
    or  cl, 0x80
    mov [rsi+1], cl

    and eax, 0x3F
    or  al, 0x80
    mov [rsi+2], al

    mov eax, 3
    ret

.four:
    mov ecx, eax
    shr ecx, 18
    or  cl, 0xF0
    mov [rsi], cl

    mov ecx, eax
    shr ecx, 12
    and ecx, 0x3F
    or  cl, 0x80
    mov [rsi+1], cl

    mov ecx, eax
    shr ecx, 6
    and ecx, 0x3F
    or  cl, 0x80
    mov [rsi+2], cl

    and eax, 0x3F
    or  al, 0x80
    mov [rsi+3], al

    mov eax, 4
    ret

.err:
    xor eax, eax
    ret
