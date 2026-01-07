; Chapter 3 - Lesson 4 (Working with Constants)
; Example 7: Constants as bit masks and shifts for packed fields

global _start
default rel

; Field layout of a 32-bit "header" (example):
;   bits  0..3   : type   (4 bits)
;   bits  4..11  : length (8 bits)
;   bits 12..31  : payload_id (20 bits)

TYPE_SHIFT     equ 0
TYPE_WIDTH     equ 4
LEN_SHIFT      equ 4
LEN_WIDTH      equ 8
PAY_SHIFT      equ 12
PAY_WIDTH      equ 20

TYPE_MASK      equ ((1 << TYPE_WIDTH) - 1) << TYPE_SHIFT
LEN_MASK       equ ((1 << LEN_WIDTH)  - 1) << LEN_SHIFT
PAY_MASK       equ ((1 << PAY_WIDTH)  - 1) << PAY_SHIFT

; Example values
TYPE_VAL       equ 0xA
LEN_VAL        equ 0x3C
PAY_VAL        equ 0xABCDE

PACKED_HEADER  equ ((TYPE_VAL << TYPE_SHIFT) | (LEN_VAL << LEN_SHIFT) | (PAY_VAL << PAY_SHIFT))

section .data
hexdigits    db "0123456789ABCDEF"
hexbuf       db "0x0000000000000000", 10
hexbuf_len   equ $ - hexbuf

hdr          db "Packed header constant (32-bit) and extracted fields:", 10
hdr_len      equ $ - hdr

lbl0         db "PACKED_HEADER:", 10
lbl0_len     equ $ - lbl0
lbl1         db "type:", 10
lbl1_len     equ $ - lbl1
lbl2         db "length:", 10
lbl2_len     equ $ - lbl2
lbl3         db "payload_id:", 10
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

    lea rsi, [lbl0]
    mov edx, lbl0_len
    write_stdout
    mov eax, PACKED_HEADER
    movzx rax, eax
    call print_hex64

    ; Extract type
    lea rsi, [lbl1]
    mov edx, lbl1_len
    write_stdout
    mov eax, PACKED_HEADER
    and eax, TYPE_MASK
    shr eax, TYPE_SHIFT
    movzx rax, eax
    call print_hex64

    ; Extract length
    lea rsi, [lbl2]
    mov edx, lbl2_len
    write_stdout
    mov eax, PACKED_HEADER
    and eax, LEN_MASK
    shr eax, LEN_SHIFT
    movzx rax, eax
    call print_hex64

    ; Extract payload id
    lea rsi, [lbl3]
    mov edx, lbl3_len
    write_stdout
    mov eax, PACKED_HEADER
    and eax, PAY_MASK
    shr eax, PAY_SHIFT
    movzx rax, eax
    call print_hex64

    xor edi, edi
    exit
