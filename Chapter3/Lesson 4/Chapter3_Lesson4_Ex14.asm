; Chapter 3 - Lesson 4 (Working with Constants)
; Example 14 (Exercise Solution): Generic PACK/UNPACK macros for bitfields (compile-time checked)

global _start
default rel

; PACK_FIELD dst32, src32, shift, width
;   dst32 |= ((src32 & ((1<<width)-1)) << shift)
%macro PACK_FIELD 4
    %if (%4 <= 0) || (%4 > 32)
        %error PACK_FIELD: width out of range
    %endif
    %if (%3 < 0) || (%3 > 31)
        %error PACK_FIELD: shift out of range
    %endif
    %if ((%3 + %4) > 32)
        %error PACK_FIELD: field does not fit in 32-bit container
    %endif

    mov eax, %2
    and eax, (1 << %4) - 1
    shl eax, %3
    or  %1, eax
%endmacro

; UNPACK_FIELD dst32, src32, shift, width
;   dst32 = (src32 >> shift) & ((1<<width)-1)
%macro UNPACK_FIELD 4
    %if (%4 <= 0) || (%4 > 32)
        %error UNPACK_FIELD: width out of range
    %endif
    %if (%3 < 0) || (%3 > 31)
        %error UNPACK_FIELD: shift out of range
    %endif
    %if ((%3 + %4) > 32)
        %error UNPACK_FIELD: field does not fit in 32-bit container
    %endif

    mov %1, %2
    shr %1, %3
    and %1, (1 << %4) - 1
%endmacro

; Field layout (shift,width) chosen so the three fields exactly fill 32 bits.
F1_SHIFT equ 0
F1_WIDTH equ 5
F2_SHIFT equ 5
F2_WIDTH equ 10
F3_SHIFT equ 15
F3_WIDTH equ 17

section .data
hexdigits    db "0123456789ABCDEF"
hexbuf       db "0x0000000000000000", 10
hexbuf_len   equ $ - hexbuf

hdr          db "Packing/unpacking 3 fields into a 32-bit word:", 10
hdr_len      equ $ - hdr

lbl0         db "packed word:", 10
lbl0_len     equ $ - lbl0
lbl1         db "field1:", 10
lbl1_len     equ $ - lbl1
lbl2         db "field2:", 10
lbl2_len     equ $ - lbl2
lbl3         db "field3:", 10
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

    ; Input values (pretend they arrived from elsewhere)
    mov ebx, 17          ; field1 (5 bits)
    mov ecx, 0x3AA       ; field2 (10 bits)
    mov esi, 0x1234      ; field3 (17 bits; here only 0x1234 is used)

    ; Pack into r8d (preserve across syscalls/labels)
    xor r8d, r8d
    PACK_FIELD r8d, ebx, F1_SHIFT, F1_WIDTH
    PACK_FIELD r8d, ecx, F2_SHIFT, F2_WIDTH
    PACK_FIELD r8d, esi, F3_SHIFT, F3_WIDTH

    lea rsi, [lbl0]
    mov edx, lbl0_len
    write_stdout
    mov eax, r8d
    movzx rax, eax
    call print_hex64

    lea rsi, [lbl1]
    mov edx, lbl1_len
    write_stdout
    UNPACK_FIELD eax, r8d, F1_SHIFT, F1_WIDTH
    movzx rax, eax
    call print_hex64

    lea rsi, [lbl2]
    mov edx, lbl2_len
    write_stdout
    UNPACK_FIELD eax, r8d, F2_SHIFT, F2_WIDTH
    movzx rax, eax
    call print_hex64

    lea rsi, [lbl3]
    mov edx, lbl3_len
    write_stdout
    UNPACK_FIELD eax, r8d, F3_SHIFT, F3_WIDTH
    movzx rax, eax
    call print_hex64

    xor edi, edi
    exit
