; Chapter4_Lesson9_Ex8.asm
; NASM macro layer for extension patterns (can be split into an .inc in real projects).

BITS 64
DEFAULT REL

GLOBAL _start

%macro U8_TO_U32 2
    ; %1 = dst32, %2 = src (r/m8)
    movzx %1, byte %2
%endmacro

%macro S8_TO_S64 2
    ; %1 = dst64, %2 = src (r/m8)
    movsx %1, byte %2
%endmacro

%macro SIGN_EXT32 2
    ; Sign-extend a %2-bit value already in %1 (a 32-bit register).
    ; Example: SIGN_EXT32 eax, 12
    %assign __sh (32-(%2))
    shl %1, __sh
    sar %1, __sh
%endmacro

SECTION .data
u8 db 200
s8 db -56
w  dw 0x0F34

SECTION .text
_start:
    U8_TO_U32 eax, [u8]       ; EAX=200
    S8_TO_S64 rbx, [s8]       ; RBX=-56

    movzx ecx, word [w]
    and ecx, 0x0FFF
    SIGN_EXT32 ecx, 12        ; ECX = sign-extended 12-bit value

    mov eax, 60
    xor edi, edi
    syscall
