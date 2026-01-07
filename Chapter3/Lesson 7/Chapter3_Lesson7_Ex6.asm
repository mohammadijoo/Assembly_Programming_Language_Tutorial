bits 64
default rel

global _start

; Chapter 3, Lesson 7, Example 6
; UTF-16LE code units in memory (DW) and conversion to UTF-8.
; Demonstrates surrogate handling and endianness assumptions.

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    ; UTF-16LE units: 'A', space, '€', space, '😀', newline, 0
    ; U+1F600 (😀) => high surrogate 0xD83D, low surrogate 0xDE00
    u16: dw 0x0041, 0x0020, 0x20AC, 0x0020, 0xD83D, 0xDE00, 0x000A, 0x0000

section .bss
    outbuf: resb 128

section .text

_start:
    lea rdi, [u16]
    lea rsi, [outbuf]
    call utf16le_to_utf8
    test eax, eax
    jz .bad

    ; write converted UTF-8 bytes
    mov edx, eax
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [outbuf]
    syscall

    xor edi, edi
    mov eax, SYS_exit
    syscall

.bad:
    mov edi, 1
    mov eax, SYS_exit
    syscall

; -------------------------------------------------------
; utf16le_to_utf8
; IN:  RDI = ptr to UTF-16LE units (uint16), 0-terminated
;      RSI = output buffer
; OUT: EAX = bytes written, or 0 on error
; -------------------------------------------------------
utf16le_to_utf8:
    push rbx
    push r12
    push r13

    mov rbx, rdi              ; input cursor
    mov r12, rsi              ; output cursor
    mov r13, rsi              ; output base

.loop:
    movzx eax, word [rbx]
    test ax, ax
    jz  .done

    ; check surrogate ranges
    cmp ax, 0xD800
    jb  .bmp
    cmp ax, 0xDBFF
    jbe .high_sur
    cmp ax, 0xDFFF
    jbe .err                   ; low surrogate without high surrogate
    jmp .bmp

.high_sur:
    ; need the next unit
    movzx ecx, word [rbx+2]
    cmp cx, 0xDC00
    jb  .err
    cmp cx, 0xDFFF
    ja  .err

    ; codepoint = 0x10000 + ((hi-0xD800) << 10) + (lo-0xDC00)
    mov edx, eax
    sub edx, 0xD800
    shl edx, 10

    mov esi, ecx
    sub esi, 0xDC00

    add edx, esi
    add edx, 0x10000
    mov edi, edx

    add rbx, 4                 ; consumed 2 UTF-16 code units
    jmp .emit_utf8

.bmp:
    ; reject surrogate code points inside BMP
    cmp ax, 0xD800
    jb  .bmp_ok
    cmp ax, 0xDFFF
    jbe .err
.bmp_ok:
    mov edi, eax
    add rbx, 2

.emit_utf8:
    mov rsi, r12
    call utf8_encode
    test eax, eax
    jz .err
    add r12, rax
    jmp .loop

.done:
    mov rax, r12
    sub rax, r13
    mov eax, eax
    jmp .ret

.err:
    xor eax, eax
.ret:
    pop r13
    pop r12
    pop rbx
    ret

; -------------------------------------------------------
; utf8_encode (same logic as Example 4, local)
; IN:  EDI = code point
;      RSI = out ptr
; OUT: EAX = bytes, or 0 on error
; -------------------------------------------------------
utf8_encode:
    mov eax, edi
    cmp eax, 0x10FFFF
    ja  .uerr
    cmp eax, 0xD800
    jb  .uok
    cmp eax, 0xDFFF
    jbe .uerr
.uok:
    cmp eax, 0x7F
    jbe .u1
    cmp eax, 0x7FF
    jbe .u2
    cmp eax, 0xFFFF
    jbe .u3
    jmp .u4
.u1:
    mov [rsi], al
    mov eax, 1
    ret
.u2:
    mov ecx, eax
    shr ecx, 6
    or  cl, 0xC0
    mov [rsi], cl
    and eax, 0x3F
    or  al, 0x80
    mov [rsi+1], al
    mov eax, 2
    ret
.u3:
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
.u4:
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
.uerr:
    xor eax, eax
    ret
