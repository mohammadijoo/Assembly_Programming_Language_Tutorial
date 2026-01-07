; Chapter4_Lesson9_Ex13.asm
; Exercise Solution 5 (Very Hard): unpack two signed 12-bit samples from 3 bytes.
;   void unpack2_s12(const uint8_t *p3, int32_t out[2]);
; Layout (little-endian 24-bit container):
;   sample0 = bits 0..11
;   sample1 = bits 12..23
; Both samples are signed 12-bit and must be sign-extended to 32-bit.
; SysV ABI: RDI=p, RSI=out.

BITS 64
DEFAULT REL

GLOBAL _start
GLOBAL unpack2_s12

SECTION .data
; Packed 24-bit:
; low 12 bits = 0x7F0 (positive), high 12 bits = 0xF10 (negative)
p3 db 0xF0, 0x17, 0xF1
out dd 0, 0

SECTION .text
unpack2_s12:
    ; Load 24-bit into EAX
    movzx eax, byte [rdi]
    movzx ecx, byte [rdi+1]
    shl ecx, 8
    or  eax, ecx
    movzx ecx, byte [rdi+2]
    shl ecx, 16
    or  eax, ecx

    ; sample0
    mov edx, eax
    and edx, 0x0FFF
    shl edx, 20
    sar edx, 20
    mov [rsi], edx

    ; sample1
    shr eax, 12
    and eax, 0x0FFF
    shl eax, 20
    sar eax, 20
    mov [rsi+4], eax
    ret

_start:
    lea rdi, [p3]
    lea rsi, [out]
    call unpack2_s12
    ; Expected:
    ; out[0] = 0x7F0 = 2032
    ; out[1] = 0xF10 as signed 12-bit -> -240
    mov eax, 60
    xor edi, edi
    syscall
