; Chapter4_Lesson9_Ex11.asm
; Exercise Solution 3: load_s24_le
;   int32_t load_s24_le(const uint8_t *p3);
; Reads 3 little-endian bytes, returns sign-extended 24->32 in EAX.
; SysV ABI: RDI=p, return EAX.

BITS 64
DEFAULT REL

GLOBAL _start
GLOBAL load_s24_le

SECTION .data
val3 db 0x80, 0x00, 0x80      ; 24-bit value 0x800080 (sign bit set) -> negative
SECTION .text
load_s24_le:
    movzx eax, byte [rdi]
    movzx ecx, byte [rdi+1]
    shl ecx, 8
    or  eax, ecx
    movzx ecx, byte [rdi+2]
    shl ecx, 16
    or  eax, ecx

    ; sign-extend 24->32
    shl eax, 8
    sar eax, 8
    ret

_start:
    lea rdi, [val3]
    call load_s24_le
    mov eax, 60
    xor edi, edi
    syscall
