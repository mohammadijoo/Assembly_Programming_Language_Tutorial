; Chapter 3 - Lesson 4 (Working with Constants)
; Example 12: ALIGN, TIMES, '$$', and layout-oriented constants

global _start
default rel

ALIGNMENT   equ 16
PAD_BYTE    equ 0xCC

section .data
hexdigits    db "0123456789ABCDEF"
hexbuf       db "0x0000000000000000", 10
hexbuf_len   equ $ - hexbuf

hdr          db "ALIGN/TIMES and section-base '$$' for layout constants", 10
hdr_len      equ $ - hdr

lbl1         db "Offset of aligned_tbl from start of .data (aligned to 16):", 10
lbl1_len     equ $ - lbl1

; Fill some bytes, then align
filler       times 7 db 0x11

align ALIGNMENT, db PAD_BYTE
aligned_tbl:
    times 8 dq 0          ; 8 qwords, all zero

aligned_off  equ aligned_tbl - $$     ; constant offset from section base
aligned_size equ $ - aligned_tbl

lbl2         db "aligned_off:", 10
lbl2_len     equ $ - lbl2

lbl3         db "aligned_size:", 10
lbl3_len     equ $ - lbl3

section .text
%define SYS_write 1
%define SYS_exit 60
%define FD_STDOUT 1

%macro write_stdout 0
    mov eax, SYS_write
    mov edi, FD_STDOUT
    syscall
%endmacro

%macro exit 0
    mov eax, SYS_exit
    syscall
%endmacro

print_hex64:
    mov rbx, rax
    lea rdi, [hexbuf + 2 + 15]
    mov rcx, 16
.loop:
    mov rax, rbx
    and eax, 0xF
    mov al, [hexdigits + rax]
    mov [rdi], al
    shr rbx, 4
    dec rdi
    loop .loop
    lea rsi, [hexbuf]
    mov edx, hexbuf_len
    write_stdout
    ret

_start:
    lea rsi, [hdr]
    mov edx, hdr_len
    write_stdout

    lea rsi, [lbl1]
    mov edx, lbl1_len
    write_stdout

    lea rsi, [lbl2]
    mov edx, lbl2_len
    write_stdout
    mov rax, aligned_off
    call print_hex64

    lea rsi, [lbl3]
    mov edx, lbl3_len
    write_stdout
    mov rax, aligned_size
    call print_hex64

    xor edi, edi
    exit
