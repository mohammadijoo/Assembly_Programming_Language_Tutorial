; Chapter 3 - Lesson 4 (Working with Constants)
; Example 11: 'struc' creates offset constants (structure layout as constants)

global _start
default rel

struc POINT
    .x  resd 1
    .y  resd 1
endstruc

; NASM defines:
;   POINT.x    (offset of field x)
;   POINT.y    (offset of field y)
;   POINT_size (total size)

section .data
hexdigits    db "0123456789ABCDEF"
hexbuf       db "0x0000000000000000", 10
hexbuf_len   equ $ - hexbuf

hdr          db "Structure offsets are constants: POINT.x, POINT.y, POINT_size", 10
hdr_len      equ $ - hdr

lbl0         db "POINT.x:", 10
lbl0_len     equ $ - lbl0
lbl1         db "POINT.y:", 10
lbl1_len     equ $ - lbl1
lbl2         db "POINT_size:", 10
lbl2_len     equ $ - lbl2

lbl3         db "Second point (x,y):", 10
lbl3_len     equ $ - lbl3

points:
    istruc POINT
        at POINT.x, dd 10
        at POINT.y, dd 20
    iend

    istruc POINT
        at POINT.x, dd -3
        at POINT.y, dd 7
    iend

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

    lea rsi, [lbl0]
    mov edx, lbl0_len
    write_stdout
    mov rax, POINT.x
    call print_hex64

    lea rsi, [lbl1]
    mov edx, lbl1_len
    write_stdout
    mov rax, POINT.y
    call print_hex64

    lea rsi, [lbl2]
    mov edx, lbl2_len
    write_stdout
    mov rax, POINT_size
    call print_hex64

    lea rsi, [lbl3]
    mov edx, lbl3_len
    write_stdout

    ; Access second element: base + 1*POINT_size + field_offset
    mov eax, [points + 1*POINT_size + POINT.x]
    movsx rax, eax
    call print_hex64

    mov eax, [points + 1*POINT_size + POINT.y]
    movsx rax, eax
    call print_hex64

    xor edi, edi
    exit
